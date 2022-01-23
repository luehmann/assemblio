const BoundingBox = @import("../bounding_box.zig").BoundingBox;
const Direction = @import("../direction.zig").Direction;
const Item = @import("../item.zig").Item;
const Slots = @import("../slots.zig").Slots;
const SlotState = @import("../slots.zig").SlotState;
const Vec2 = @import("../vec.zig").Vec2;
const w4 = @import("../wasm4.zig");
const globals = @import("../globals.zig");
const shared = @import("shared.zig");
const std = @import("std");
const Writer = @import("../Writer.zig");
const Reader = @import("../Reader.zig");

pos: Vec2(i8),
direction: Direction,
len: u8,
item: Item = Item.empty,
slots: Slots = Slots{},
slots_blocked: u8 = 0,

const Self = @This();

pub fn boundingBox(self: Self) BoundingBox(i32) {
    return BoundingBox(i32).fromPoints(
        self.pos.as(i32),
        self.pos.as(i32).add(self.direction.toVec().scale(@as(i32, self.len))),
    );
}

pub fn renderItems(self: Self) void {
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

pub fn advance(self: *Self, id: u8) void {
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
    for (globals.connections.toSlice()) |_, connection_index| {
        const connection = globals.connections.items[if (globals.alternating_sides_flag) globals.connections.len - 1 - connection_index else connection_index];
        if (connection.to != id) continue;
        const node = &globals.nodes.items[connection.from];
        const drop_off_point = node.dropOffPoint(connection.output_index);
        if (!drop_off_point.isWithin(self.boundingBox())) continue;

        const dest_index = @intCast(u8, self.pos.as(i32).subtract(drop_off_point).magnitude()); // TODO: full magnitude with sqrt not necessary
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
        node.advance(connection.from);
    }
}

pub fn outputItem(self: Self) Item {
    return switch (self.slots.get(self.len)) {
        .empty => Item.empty,
        else => self.item,
    };
}

pub fn takeItem(self: *Self) void {
    self.slots.set(self.len, .empty);

    if (!self.hasItems()) self.item = Item.empty;
}

pub fn hasItems(self: Self) bool {
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

pub fn dropOffPoint(self: Self) Vec2(i32) {
    return self.pos.as(i32).add(self.direction.toVec().scale(self.len + 1));
}

pub fn renderBelts(self: Self, is_wireframe: bool) void {
    var i: u8 = 0;
    while (i <= self.len) : (i += 1) {
        const pos = self.pos.as(i32).add(self.direction.toVec().scale(i));
        const has_line = is_wireframe;
        shared.renderBelt(pos, self.direction, has_line, is_wireframe);
    }
}

pub fn canConnect(self: Self, direction: Direction) bool {
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

pub fn serialize(self: Self, writer: *Writer) void {
    writer.writeByte(@bitCast(u8, self.pos.x));
    writer.writeByte(@bitCast(u8, self.pos.y));
    writer.writeByte(self.len);
}

pub fn deserialize(direction: Direction, reader: *Reader) Self {
    const pos = Vec2(i8){
        .x = @bitCast(i8, reader.readByte()),
        .y = @bitCast(i8, reader.readByte()),
    };
    const len = reader.readByte();
    return .{
        .pos = pos,
        .len = len,
        .direction = direction,
    };
}
