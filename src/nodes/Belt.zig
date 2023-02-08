const std = @import("std");
const root = @import("main");
const w4 = @import("wasm4");

const globals = root.globals;
const utils = root.utils;

const shared = @import("shared.zig");

const Direction = root.Direction;
const Item = root.Item;
const NodeId = root.NodeId;
const Reader = root.Reader;
const Rect = root.Rect;
const Slots = root.Slots;
const SlotState = Slots.SlotState;
const Vec2 = root.Vec2;
const Writer = root.Writer;
const Network = root.Network;

pos: Vec2(i8),
direction: Direction,
len: u8,
item: Item = Item.empty,
slots: Slots = Slots{},
slots_blocked: u8 = 0,

const Self = @This();
pub const max_length = 64;

pub fn boundingBox(self: *const Self) Rect(i32) {
    return Rect(i32).fromPoints(
        self.pos.as(i32),
        self.pos.as(i32).add(self.direction.toVec().scale(@as(i32, self.len))),
    );
}

pub fn renderItems(self: *const Self) void {
    var i: u8 = 0;
    while (i <= self.len) : (i += 1) {
        const direction_coming_from = switch (self.slots.get(i)) {
            .empty => continue,
            .filled => self.direction.opposite(),
            .filled_from_the_left => self.direction.rotateCounterClockwise(),
            .filled_from_the_right => self.direction.rotateClockwise(),
        };
        const pos = self.pos.as(i32).add(self.direction.toVec().scale(i));
        const is_blocked = self.len - i < self.slots_blocked;
        shared.renderItem(self.item, pos, direction_coming_from, is_blocked);
    }
}

pub fn advance(self: *Self, network: *Network, id: NodeId, advance_queue: *Network.AdvanceQueue) void {
    self.updateBlockedCount();
    if (self.slots_blocked <= self.len) {
        var j: u8 = self.len - self.slots_blocked;
        while (j > 0) : (j -= 1) {
            self.slots.set(j, self.slots.get(j - 1));
        }
    }

    if (self.slots_blocked < self.len) {
        self.slots.set(0, .empty);
    }
    var i: u8 = 0;
    while (i <= self.len) : (i += 1) {
        self.slots.set(i, switch (self.slots.get(i)) {
            .empty => .empty,
            else => .filled,
        });
    }
    for (network.connections) |_, connection_index| {
        const connection = network.connections[if (network.alternating_sides_flag) network.connections.len - 1 - connection_index else connection_index];
        if (connection.to != id) continue;
        const node = &network.nodes[connection.from];
        const drop_off_point = node.dropOffPoint(connection.output_index);
        if (!drop_off_point.isWithin(self.boundingBox())) continue;

        const dest_index = getDestIndex(self.pos.as(i32), drop_off_point);
        if (self.slots.get(dest_index) == .empty) {
            const output_item = node.outputItem(connection.output_index);
            if (!output_item.eql(Item.empty)) {
                if (self.item.eql(Item.empty) or self.item.eql(output_item)) {
                    node.takeItem(connection.output_index);
                    self.item = output_item;

                    self.slots.set(dest_index, SlotState.getFillDirection(node.direction(), self.direction));
                }
            }
        }
        advance_queue.append(connection.from);
    }
}

fn getDestIndex(pos: Vec2(i32), drop_off_point: Vec2(i32)) u8 {
    const delta = pos.subtract(drop_off_point);
    std.debug.assert(delta.x == 0 or delta.y == 0);
    return @intCast(u8, std.math.absInt(delta.x + delta.y) catch unreachable);
}

test "getDestIndex" {
    try std.testing.expectEqual(getDestIndex(.{ .x = -57, .y = 100 }, .{ .x = 10, .y = 100 }), 67);
}

pub fn outputItem(self: *const Self) Item {
    return switch (self.slots.get(self.len)) {
        .empty => Item.empty,
        else => self.item,
    };
}

pub fn takeItem(self: *Self) void {
    self.slots.set(self.len, .empty);

    if (!self.hasItems()) self.item = Item.empty;
}

fn hasItems(self: *const Self) bool {
    var slot_index: u8 = 0;
    while (slot_index <= self.len) : (slot_index += 1) {
        if (self.slots.get(slot_index) != .empty) return true;
    }
    return false;
}

pub fn updateBlockedCount(self: *Self) void {
    var slot_index: u8 = 0;
    self.slots_blocked = while (slot_index <= self.len) : (slot_index += 1) {
        if (self.slots.get(self.len - slot_index) == .empty) break slot_index;
    } else self.len + 1;
}

pub fn dropOffPoint(self: *const Self) Vec2(i32) {
    return self.pos.as(i32).add(self.direction.toVec().scale(self.len + 1));
}

pub fn renderBelts(self: *const Self, is_wireframe: bool) void {
    var i: u8 = 0;
    while (i <= self.len) : (i += 1) {
        const pos = self.pos.as(i32).add(self.direction.toVec().scale(i));
        const has_line = is_wireframe;
        shared.renderBelt(pos, self.direction, has_line, is_wireframe);
    }
}

pub fn canConnect(self: *const Self, direction: Direction) bool {
    return direction.opposite() != self.direction;
}

const belt_texture_size = 13;

const vertical_belt = [belt_texture_size]u8{
    0b00000000,
    0b00000000,
    0b00011000,
    0b00111100,
    0b01100110,
    0b01000010,
    0b00000000,
    0b00000000,
    0b00011000,
    0b00111100,
    0b01100110,
    0b01000010,
    0b00000000,
};

const horizontal_belt = [belt_texture_size]u8{
    0b00000000,
    0b00000000,
    0b00001000,
    0b00011100,
    0b00110110,
    0b00100010,
    0b00000000,
    0b00000000,
    0b00001000,
    0b00011100,
    0b00110110,
    0b00100010,
    0b00000000,
};

const belt_frame_count = belt_texture_size - 7;

pub fn renderOnScreen(screen_pos: Vec2(i32), world_pos: Vec2(i32), direction: Direction, is_wireframe: bool, t: u32) void {
    var frame = (t / 6) % belt_frame_count;
    if (direction.isFacingNegative()) {
        frame = 5 - frame;
    }
    const cord = if (direction.isHorizontal()) world_pos.x else world_pos.y;
    var offset = (@intCast(u32, @mod(cord, 3)) * 4 + frame) % belt_frame_count;
    if (direction.isFacingNegative()) {
        offset = 5 - offset;
    }
    w4.draw_colors.* = if (is_wireframe) 0x41 else 0x12;
    const texture: [*]const u8 = if (direction.isHorizontal()) &horizontal_belt else &vertical_belt;
    w4.blit(
        texture + offset,
        screen_pos.x,
        screen_pos.y,
        8,
        8,
        direction.blitFlags(),
    );
}

pub fn renderLine(screen_pos: Vec2(i32), is_wireframe: bool) void {
    w4.draw_colors.* = if (is_wireframe) 0x4 else 0x3;
    w4.hline(screen_pos.x, screen_pos.y + 7, 8);
}

pub fn rotate(self: *Self) Direction {
    if (self.len == 0) {
        self.direction = self.direction.rotateClockwise();
    } else {
        self.pos = self.pos.add(self.direction.toVec().scale(self.len).intCast(i8));
        self.direction = self.direction.opposite();
    }
    self.slots = Slots{};

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
