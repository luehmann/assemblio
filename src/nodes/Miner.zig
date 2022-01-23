const Direction = @import("../direction.zig").Direction;
const Item = @import("../item.zig").Item;
const Vec2 = @import("../vec.zig").Vec2;
const BoundingBox = @import("../bounding_box.zig").BoundingBox;
const utils = @import("../utils.zig");
const w4 = @import("../wasm4.zig");
const shared = @import("shared.zig");
const box = @import("../box.zig");
const Writer = @import("../Writer.zig");
const Reader = @import("../Reader.zig");
const resources = @import("../resources.zig");
const globals = @import("../globals.zig");

pos: Vec2(i8),
direction: Direction,
item: Item,

const Self = @This();

pub fn boundingBox(self: Self) BoundingBox(i32) {
    return BoundingBox(i32).fromPoint(self.pos.as(i32));
}

pub fn dropOffPoint(self: Self) Vec2(i32) {
    return self.pos.as(i32).add(self.direction.toVec());
}

pub fn outputItem(self: Self) Item {
    return self.item;
}

pub fn renderBelts(self: Self, is_wireframe: bool) void {
    shared.renderBelt(self.pos.as(i32), self.direction, false, is_wireframe);
}

pub fn renderStructure(self: Self, is_wireframe: bool) void {
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
    box.renderFront(screen_pos.addY(5));
    w4.draw_colors.* = if (is_wireframe) 0x41 else 0x31;
    const is_mining = (t + 2) % (6 * 8) < 4;
    const offset: i32 = if (is_mining) 1 else 0;
    box.renderTop(screen_pos.addY(-3 + offset));

    w4.draw_colors.* = if (is_wireframe) 0x40 else 0x20;
    item.render(screen_pos.x + 2, screen_pos.y - 1 + offset);
}

pub fn serialize(self: Self, writer: *Writer) void {
    writer.writeByte(@bitCast(u8, self.pos.x));
    writer.writeByte(@bitCast(u8, self.pos.y));
}

pub fn deserialize(direction: Direction, reader: *Reader) Self {
    const pos = Vec2(i8){
        .x = @bitCast(i8, reader.readByte()),
        .y = @bitCast(i8, reader.readByte()),
    };
    return .{
        .pos = pos,
        .direction = direction,
        .item = resources.getItemAt(pos.as(i32)),
    };
}
