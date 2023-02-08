const std = @import("std");
const root = @import("main");
const w4 = @import("wasm4");

const box = root.box;
const globals = root.globals;
const utils = root.utils;

const shared = @import("shared.zig");

const Direction = root.Direction;
const Item = root.Item;
const NodeId = root.NodeId;
const Reader = root.Reader;
const Rect = root.Rect;
const Vec2 = root.Vec2;
const Writer = root.Writer;
const Network = root.Network;
const OnScreenNodes = root.OnScreenNodes;

pub const max_length = 16;

pos: Vec2(i8),
direction: Direction,
len: u8,
slots: [max_length]Item = std.mem.zeroes([max_length]Item),
is_blocked: bool = false,

const Self = @This();

pub fn boundingBox(self: *const Self) Rect(i32) {
    return Rect(i32).fromPoints(
        self.pos.as(i32),
        self.pos.as(i32).add(self.direction.toVec().scale(@as(i32, self.len))),
    );
}

pub fn intersects(self: *const Self, rect: Rect(i32)) bool {
    return self.pos.as(i32).isWithin(rect) or self.otherPos().isWithin(rect);
}

pub fn getIntersection(self: *const Self, bounding_box: Rect(i32)) ?Rect(i32) {
    if (self.pos.as(i32).isWithin(bounding_box)) return Rect(i32).fromPoint(self.pos.as(i32));
    if (self.otherPos().isWithin(bounding_box)) return Rect(i32).fromPoint(self.otherPos());
    return null;
}

pub fn checkOnScreen(self: *const Self, on_screen_nodes: *OnScreenNodes, screen_box: Rect(i32), node_id: NodeId) void {
    if (self.pos.as(i32).isWithin(screen_box)) {
        on_screen_nodes.addToBucket(self.pos.y, node_id);
    }
    const other_pos = self.otherPos();
    if (other_pos.isWithin(screen_box)) {
        on_screen_nodes.addToBucket(other_pos.y, node_id | (0b1 << 15));
    }
}

fn otherPos(self: *const Self) Vec2(i32) {
    return self.pos.as(i32).add(self.direction.toVec().scale(@as(i32, self.len)));
}

pub fn advance(self: *Self, network: *Network, id: NodeId, advance_queue: *Network.AdvanceQueue) void {
    self.is_blocked = !self.slots[self.len].eql(Item.empty);
    var i: usize = self.len;
    while (i > 0) : (i -= 1) {
        self.slots[i] = self.slots[i - 1];
    }
    if (!self.is_blocked) self.slots[0] = Item.empty;

    for (network.connections) |connection| {
        if (connection.to != id) continue;
        const node = &network.nodes[connection.from];

        if (self.slots[0].eql(Item.empty)) {
            const output_item = node.outputItem(connection.output_index);
            if (!output_item.eql(Item.empty)) {
                node.takeItem(connection.output_index);
                self.slots[0] = output_item;
            }
        }
        advance_queue.append(connection.from);
        break;
    }
}

pub fn outputItem(self: *const Self) Item {
    return self.slots[self.len];
}

pub fn takeItem(self: *Self) void {
    self.is_blocked = false;
    self.slots[self.len] = Item.empty;
}

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

pub fn renderBelts(self: *const Self, is_wireframe: bool) void {
    const has_line = is_wireframe;
    shared.renderBelt(self.pos.as(i32), self.direction, has_line, is_wireframe);
    shared.renderBelt(self.otherPos(), self.direction, has_line, is_wireframe);
}

pub fn collidesWith(self: Self, position: Vec2(i32)) bool {
    return std.meta.eql(position, self.pos.as(i32)) or std.meta.eql(position, self.otherPos());
}

pub fn canConnect(self: *const Self, position: Vec2(i32), direction: Direction) bool {
    return std.meta.eql(position, self.pos.as(i32)) and direction == self.direction;
}

pub fn renderItems(self: *const Self) void {
    shared.renderItem(self.slots[0], self.pos.as(i32), self.direction.opposite(), self.is_blocked);
}

pub fn renderStructure(self: *const Self, is_wireframe: bool, is_exit: bool) void {
    if (is_exit) {
        if (self.len > 0) renderOnScreen(utils.worldToScreen(self.otherPos()), self.direction, .exit, is_wireframe);
    } else {
        renderOnScreen(utils.worldToScreen(self.pos.as(i32)), self.direction, .entrance, is_wireframe);
    }
}

pub const BuildingType = enum(u1) {
    entrance = 0,
    exit = 1,
};

pub fn renderOnScreen(screen_pos: Vec2(i32), direction: Direction, building_type: BuildingType, is_wireframe: bool) void {
    w4.draw_colors.* = if (is_wireframe) 0x41 else 0x31;
    box.renderTop(screen_pos.add(.{ .y = -3 }));
    if ((direction == .north and building_type == .entrance) or (direction == .south and building_type == .exit)) {
        w4.draw_colors.* = if (is_wireframe) 0x40 else 0x30;
    }
    box.renderFront(screen_pos.add(.{ .y = 5 }));
    w4.draw_colors.* = if (is_wireframe) 0x40 else 0x20;
    const texture = @ptrCast([*]const u8, &arrow_texture) + @enumToInt(building_type);
    w4.blit(texture, screen_pos.x, screen_pos.y - 3, 8, 8, direction.blitFlagsRotate());
}

const arrow_texture = [9]u8{
    0b00000000,
    0b00000000,
    0b00000000,
    0b00011000,
    0b00111100,
    0b00100100,
    0b00000000,
    0b00000000,
    0b00000000,
};

pub fn renderSelection(self: *const Self) void {
    if (self.len <= 1) {
        utils.renderSelection(self.boundingBox());
    } else {
        utils.renderSelection(Rect(i32).fromPoint(self.pos.as(i32)));
        utils.renderSelection(Rect(i32).fromPoint(self.otherPos()));
    }
}

pub fn rotate(self: *Self) Direction {
    self.pos = self.pos.add(self.direction.toVec().scale(self.len).intCast(i8));
    self.direction = self.direction.opposite();
    self.slots = std.mem.zeroes([max_length]Item);

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
