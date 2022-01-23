const Vec2 = @import("../vec.zig").Vec2;
const Direction = @import("../direction.zig").Direction;
const BoundingBox = @import("../bounding_box.zig").BoundingBox;
const shared = @import("shared.zig");
const Item = @import("../item.zig").Item;
const std = @import("std");
const globals = @import("../globals.zig");
const w4 = @import("../wasm4.zig");
const box = @import("../box.zig");
const utils = @import("../utils.zig");
const Writer = @import("../Writer.zig");
const Reader = @import("../Reader.zig");

pos: Vec2(i8),
direction: Direction,
input: Item = Item.empty,
is_blocked: bool = false,
was_ticked: bool = false,

const Self = @This();

pub fn advance(self: *Self, id: u8) void {
    if (!self.input.eql(Item.empty)) self.is_blocked = true;
    if (self.was_ticked) {
        for (globals.connections.toSlice()) |connection| {
            if (connection.to != id) continue;
            const node = &globals.nodes.items[connection.from];
            const drop_off_point = node.dropOffPoint(connection.output_index);
            if (!drop_off_point.isWithin(self.boundingBox())) continue;

            const output_item = node.outputItem(connection.output_index);
            if (!output_item.eql(Item.empty)) {
                if (self.input.eql(Item.empty)) {
                    node.takeItem(connection.output_index);
                    self.input = output_item;
                }
            }

            node.advance(connection.from);
            break;
        }
    }

    self.was_ticked = !self.was_ticked;
}

pub fn boundingBox(self: Self) BoundingBox(i32) {
    return BoundingBox(i32).fromPoints(
        self.pos.as(i32),
        self.otherPos(),
    );
}

pub fn renderBelts(self: Self, is_wireframe: bool) void {
    shared.renderBelt(self.pos.as(i32), self.direction, false, is_wireframe);
    shared.renderBelt(self.otherPos(), self.direction, false, is_wireframe);
}

pub fn renderItems(self: Self) void {
    if (self.is_blocked or globals.belt_step == 0) {
        shared.renderItem(self.input.leftHalf(), self.pos.as(i32), self.direction.opposite(), true);
        shared.renderItem(self.input.rightHalf(), self.otherPos(), self.direction.opposite(), true);
    } else {
        shared.renderItem(self.input, self.pos.as(i32), self.direction.opposite(), false);
    }
}

pub fn renderStructure(self: Self, is_wireframe: bool) void {
    var pos = self.pos.as(i32);
    if (self.direction.rotateClockwise().isFacingNegative()) pos = pos.add(self.direction.rotateClockwise().toVec());
    renderOnScreen(utils.worldToScreen(pos), self.direction, is_wireframe, globals.t);
}

pub fn renderOnScreen(screen_pos: Vec2(i32), direction: Direction, is_wireframe: bool, t: u32) void {
    const top_pos = screen_pos.addY(-3);
    w4.draw_colors.* = if (is_wireframe) 0x41 else 0x31;
    if (direction.isHorizontal()) {
        box.renderFront(screen_pos.addY(13));
        box.renderTopTall(top_pos);
    } else {
        box.renderTopWide(top_pos);
        if (direction == .north) {
            box.renderFrontRight(screen_pos.addX(8).addY(5));
        } else {
            w4.draw_colors.* = if (is_wireframe) 0x40 else 0x30;
            box.renderFront(screen_pos.addX(8).addY(5));
        }
        w4.draw_colors.* = if (is_wireframe) 0x40 else 0x30;
        box.renderFront(screen_pos.addY(5));
    }
    const blade_tile = if (direction.rotateClockwise().isFacingNegative()) top_pos.add(direction.rotateCounterClockwise().toVec().scale(8)) else top_pos;
    const other_tile = if (direction.rotateCounterClockwise().isFacingNegative()) top_pos.add(direction.rotateClockwise().toVec().scale(8)) else top_pos;
    w4.draw_colors.* = if (is_wireframe) 0x40 else 0x20;
    const blit_flags = if (((t + 7) / 24) % 2 == 0) 0 else w4.BLIT_FLIP_X;
    w4.blit(&blade_texture, blade_tile.x, blade_tile.y, 8, 8, blit_flags);
    w4.blit(&other_texture, other_tile.x, other_tile.y, 8, 8, switch (direction) {
        .east => 0,
        .south => w4.BLIT_ROTATE | w4.BLIT_FLIP_X | w4.BLIT_FLIP_Y,
        .west => w4.BLIT_FLIP_X | w4.BLIT_FLIP_Y,
        .north => w4.BLIT_ROTATE,
    });
}

const other_texture = [8]u8{
    0b00010000,
    0b00010000,
    0b00010000,
    0b00010100,
    0b00011100,
    0b00000100,
    0b00000000,
    0b00000000,
};
const blade_texture = [8]u8{
    0b00000000,
    0b00010000,
    0b00001000,
    0b00010000,
    0b00001000,
    0b00010000,
    0b00001000,
    0b00000000,
};

pub fn outputItem(self: Self, output_index: u8) Item {
    return switch (output_index) {
        0 => self.input.leftHalf(),
        1 => self.input.rightHalf(),
        else => unreachable,
    };
}

pub fn takeItem(self: *Self, output_index: u8) void {
    self.input = switch (output_index) {
        0 => self.input.rightHalf(),
        1 => self.input.leftHalf(),
        else => unreachable,
    };
    if (self.input.eql(Item.empty)) self.is_blocked = false;
}

pub fn dropOffPoint(self: Self, output: u8) Vec2(i32) {
    return self.pos.as(i32).add(self.direction.rotateClockwise().toVec().scale(output).add(self.direction.toVec()));
}

pub fn canConnect(self: Self, position: Vec2(i32), direction: Direction) bool {
    return std.meta.eql(position, self.pos.as(i32)) and direction == self.direction;
}

fn otherPos(self: Self) Vec2(i32) {
    return self.pos.as(i32).add(self.direction.rotateClockwise().toVec());
}

pub fn serialize(self: Self, writer: *Writer) void {
    writer.writeByte(@bitCast(u8, self.pos.x));
    writer.writeByte(@bitCast(u8, self.pos.y));
}

pub fn deserialize(direction: Direction, reader: *Reader) Self {
    return .{
        .pos = .{
            .x = @bitCast(i8, reader.readByte()),
            .y = @bitCast(i8, reader.readByte()),
        },
        .direction = direction,
    };
}
