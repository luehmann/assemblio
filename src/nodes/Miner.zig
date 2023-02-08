const std = @import("std");
const root = @import("main");
const w4 = @import("wasm4");

const box = root.box;
const globals = root.globals;
const resources = root.resources;
const shared = @import("shared.zig");
const utils = root.utils;

const Direction = root.Direction;
const Item = root.Item;
const Reader = root.Reader;
const Rect = root.Rect;
const Vec2 = root.Vec2;
const Writer = root.Writer;
const Network = root.Network;

pos: Vec2(i8),
direction: Direction,
item: Item,

const Self = @This();

pub fn boundingBox(self: *const Self) Rect(i32) {
    return Rect(i32).fromPoint(self.pos.as(i32));
}

pub fn dropOffPoint(self: *const Self) Vec2(i32) {
    return self.pos.as(i32).add(self.direction.toVec());
}

pub fn outputItem(self: *const Self) Item {
    return self.item;
}

pub fn renderBelts(self: *const Self, is_wireframe: bool) void {
    shared.renderBelt(self.pos.as(i32), self.direction, false, is_wireframe);
}

pub fn renderStructure(self: *const Self, is_wireframe: bool) void {
    const pos = utils.worldToScreen(self.pos.as(i32));
    const is_open = self.direction == .south;
    renderOnScreen(pos, self.item, is_open, is_wireframe, globals.t);
}

pub fn renderOnScreen(screen_pos: Vec2(i32), item: Item, is_open: bool, is_wireframe: bool, t: u32) void {
    if (is_open) {
        w4.draw_colors.* = if (is_wireframe) 0x40 else 0x30;
    } else {
        w4.draw_colors.* = if (is_wireframe) 0x41 else 0x31;
    }
    box.renderFront(screen_pos.add(.{ .y = 5 }));
    w4.draw_colors.* = if (is_wireframe) 0x41 else 0x31;
    const is_mining = (t + 2) % (6 * 8) < 4;
    const offset: i32 = if (is_mining) 1 else 0;
    box.renderTop(screen_pos.add(.{ .y = -3 + offset }));

    w4.draw_colors.* = if (is_wireframe) 0x40 else 0x20;
    item.render(screen_pos.x + 2, screen_pos.y - 1 + offset);
}

pub fn renderInputsAndOutputs(self: *const Self, network: *const Network) void {
    utils.renderOutput(network, self.dropOffPoint(), self.direction, self.direction == .north);
}

pub fn rotate(self: *Self) Direction {
    self.direction = self.direction.rotateClockwise();
    return self.direction;
}

pub fn serialize(self: *const Self, writer: *Writer) void {
    writer.write(self.pos.x);
    writer.write(self.pos.y);
}

pub fn deserialize(direction: Direction, reader: *Reader) Self {
    const pos = Vec2(i8){
        .x = reader.read(i8),
        .y = reader.read(i8),
    };
    return .{
        .pos = pos,
        .direction = direction,
        .item = resources.getItemAt(pos.as(i32)),
    };
}
