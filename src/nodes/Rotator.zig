const std = @import("std");
const root = @import("main");
const w4 = @import("wasm4");

const box = root.box;
const globals = root.globals;
const shared = @import("shared.zig");
const utils = root.utils;

const Direction = root.Direction;
const Item = root.Item;
const Reader = root.Reader;
const Rect = root.Rect;
const Vec2 = root.Vec2;
const Writer = root.Writer;
const Network = root.Network;

const NodeId = root.Network.NodeId;

pub const max_length = 3;

pos: Vec2(i8),
direction: Direction,
len: u8,
slots: [max_length]Item = std.mem.zeroes([max_length]Item),
slots_blocked: u8 = 0,

const Self = @This();

pub fn advance(self: *Self, network: *Network, id: NodeId, advance_queue: *Network.AdvanceQueue) void {
    self.updateBlockedCount();
    if (self.slots_blocked <= self.len) {
        var j: u8 = self.len - self.slots_blocked;
        while (j > 0) : (j -= 1) {
            self.slots[j] = self.slots[j - 1].rotateClockwise();
        }
    }
    if (self.slots_blocked < self.len) {
        self.slots[0] = Item.empty;
    }

    for (network.connections) |connection| {
        if (connection.to != id) continue;
        const node = &network.nodes[connection.from];
        const drop_off_point = node.dropOffPoint(connection.output_index);
        if (!drop_off_point.isWithin(self.boundingBox())) continue;

        if (self.slots[0].eql(Item.empty)) {
            const output_item = node.outputItem(connection.output_index);
            node.takeItem(connection.output_index);
            self.slots[0] = output_item;
        }

        advance_queue.append(connection.from);
        break;
    }
}

fn updateBlockedCount(self: *Self) void {
    var slot_index: u8 = 0;
    self.slots_blocked = while (slot_index <= self.len) : (slot_index += 1) {
        if (self.slots[self.len - slot_index].eql(Item.empty)) break slot_index;
    } else self.len + 1;
}

pub fn outputItem(self: *const Self) Item {
    return self.slots[self.len].rotateClockwise();
}

pub fn takeItem(self: *Self) void {
    self.slots[self.len] = Item.empty;
}

pub fn boundingBox(self: *const Self) Rect(i32) {
    return Rect(i32).fromPoints(
        self.pos.as(i32),
        self.pos.as(i32).add(self.direction.toVec().scale(@as(i32, self.len))),
    );
}

pub fn renderBelts(self: *const Self, is_wireframe: bool) void {
    var i: u8 = 0;
    while (i <= self.len) : (i += 1) {
        const pos = self.pos.as(i32).add(self.direction.toVec().scale(i));
        shared.renderBelt(pos, self.direction, false, is_wireframe);
    }
}

pub fn renderItems(self: *const Self) void {
    var i: u8 = 0;
    while (i <= self.len) : (i += 1) {
        const pos = self.pos.as(i32).add(self.direction.toVec().scale(i));
        const is_blocked = self.len - i < self.slots_blocked;
        shared.renderItem(self.slots[i], pos, self.direction.opposite(), is_blocked);
    }
}

pub fn renderStructure(self: *const Self, is_wireframe: bool) void {
    var i: u8 = 0;
    while (i <= self.len) : (i += 1) {
        const pos = self.pos.as(i32).add(self.direction.toVec().scale(i));
        renderOnScreen(utils.worldToScreen(pos), self.direction, is_wireframe);
    }
}

pub fn renderOnScreen(screen_pos: Vec2(i32), direction: Direction, is_wireframe: bool) void {
    w4.draw_colors.* = if (is_wireframe) 0x41 else 0x31;
    box.renderTop(screen_pos.add(.{ .y = -3 }));
    if (!direction.isHorizontal()) w4.draw_colors.* = if (is_wireframe) 0x40 else 0x30;
    box.renderFront(screen_pos.add(.{ .y = 5 }));
    w4.draw_colors.* = if (is_wireframe) 0x40 else 0x20;
    w4.blit(&arrow_texture, screen_pos.x, screen_pos.y - 3, 8, 8, direction.blitFlagsRotate());
}

const arrow_texture = [8]u8{
    0b00000000,
    0b00000000,
    0b00001000,
    0b00111100,
    0b00101000,
    0b00100000,
    0b00000000,
    0b00000000,
};

pub fn renderInputsAndOutputs(self: *const Self, network: *const Network) void {
    utils.renderInput(network, self.inputPosition(), self.direction, self.direction == .south);
    utils.renderOutput(network, self.dropOffPoint(), self.direction, self.direction == .north);
}

fn inputPosition(self: Self) Vec2(i32) {
    return self.pos.as(i32).add(self.direction.toVec().scale(-1));
}

pub fn dropOffPoint(self: *const Self) Vec2(i32) {
    return self.pos.as(i32).add(self.direction.toVec().scale(self.len + 1));
}

pub fn canConnect(self: *const Self, position: Vec2(i32), direction: Direction) bool {
    return std.meta.eql(position, self.pos.as(i32)) and direction == self.direction;
}

pub fn rotate(self: *Self) Direction {
    if (self.len == 0) {
        self.direction = self.direction.rotateClockwise();
    } else {
        self.pos = self.pos.add(self.direction.toVec().scale(self.len).intCast(i8));
        self.direction = self.direction.opposite();
    }
    self.slots = std.mem.zeroes([3]Item);

    return self.direction;
}

pub fn serialize(self: *const Self, writer: *Writer) void {
    writer.write(self.pos.x);
    writer.write(self.pos.y);
    writer.write(self.len);
}

pub fn deserialize(direction: Direction, reader: *Reader) Self {
    const pos = Vec2(i8){
        .x = reader.read(i8),
        .y = reader.read(i8),
    };
    const len = reader.read(u8);
    return .{
        .pos = pos,
        .len = len,
        .direction = direction,
    };
}
