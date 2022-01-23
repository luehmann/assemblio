const Vec2 = @import("vec.zig").Vec2;
const Item = @import("item.zig").Item;
const w4 = @import("wasm4.zig");
const utils = @import("utils.zig");
const std = @import("std");

pub fn render() void {
    w4.draw_colors.* = 0x20;
    for (rings) |pos| {
        const screen_pos = utils.worldToScreen(pos.as(i32));
        if (!utils.isOutOfBounds(screen_pos)) {
            Item.ring.render(screen_pos.x + 2, screen_pos.y + 2);
        }
    }
    for (squares) |pos| {
        const screen_pos = utils.worldToScreen(pos.as(i32));
        if (!utils.isOutOfBounds(screen_pos)) {
            Item.square.render(screen_pos.x + 2, screen_pos.y + 2);
        }
    }
    for (circles) |pos| {
        const screen_pos = utils.worldToScreen(pos.as(i32));
        if (!utils.isOutOfBounds(screen_pos)) {
            Item.circle.render(screen_pos.x + 2, screen_pos.y + 2);
        }
    }
}

pub fn getItemAt(pos: Vec2(i32)) Item {
    const a = pos.intCast(i8);
    for (rings) |b| {
        if (std.meta.eql(a, b)) return Item.ring;
    }
    for (squares) |b| {
        if (std.meta.eql(a, b)) return Item.square;
    }
    for (circles) |b| {
        if (std.meta.eql(a, b)) return Item.circle;
    }
    return Item.empty;
}

const rings = [_]Vec2(i8){
    // patch 0
    .{ .x = -5, .y = 2 },
    .{ .x = -4, .y = 2 },
    .{ .x = -3, .y = 2 },
    .{ .x = -4, .y = 3 },
    .{ .x = -3, .y = 3 },
    .{ .x = -2, .y = 3 },
    .{ .x = -3, .y = 4 },
    .{ .x = -2, .y = 4 },
    // patch 1
    .{ .x = 11, .y = 7 },
    .{ .x = 12, .y = 7 },
    .{ .x = 11, .y = 6 },
    .{ .x = 10, .y = 6 },
    .{ .x = 10, .y = 5 },
    .{ .x = 11, .y = 5 },
    .{ .x = 11, .y = 4 },
    .{ .x = 12, .y = 5 },
    .{ .x = 13, .y = 5 },
    // patch 3
    .{ .x = 4, .y = -13 },
    .{ .x = 4, .y = -12 },
    .{ .x = 5, .y = -12 },
    .{ .x = 5, .y = -13 },
    .{ .x = 6, .y = -13 },
    .{ .x = 7, .y = -13 },
    .{ .x = 6, .y = -14 },
    .{ .x = 6, .y = -15 },
    .{ .x = 5, .y = -14 },
    .{ .x = 2, .y = -14 },
    .{ .x = 3, .y = -13 },
    // patch 4
    .{ .x = -36, .y = -21 },
    .{ .x = -35, .y = -21 },
    .{ .x = -35, .y = -22 },
    .{ .x = -35, .y = -20 },
    .{ .x = -36, .y = -19 },
    .{ .x = -34, .y = -19 },
    .{ .x = -33, .y = -19 },
    .{ .x = -34, .y = -20 },
    .{ .x = -34, .y = -21 },
    .{ .x = -32, .y = -21 },
    .{ .x = -32, .y = -20 },
    .{ .x = -32, .y = -22 },
    .{ .x = -33, .y = -22 },
    .{ .x = -33, .y = -23 },
    .{ .x = -32, .y = -24 },
    .{ .x = -32, .y = -25 },
    .{ .x = -34, .y = -26 },
};

const squares = [_]Vec2(i8){
    // patch 0
    .{ .x = -17, .y = -5 },
    .{ .x = -18, .y = -5 },
    .{ .x = -19, .y = -5 },
    .{ .x = -18, .y = -4 },
    .{ .x = -17, .y = -4 },
    .{ .x = -18, .y = -3 },
    .{ .x = -18, .y = -2 },
    .{ .x = -17, .y = -7 },
    .{ .x = -18, .y = -8 },
    .{ .x = -18, .y = -6 },
    // patch 2
    .{ .x = 19, .y = -20 },
    .{ .x = 18, .y = -20 },
    .{ .x = 19, .y = -19 },
    .{ .x = 19, .y = -18 },
    .{ .x = 18, .y = -19 },
    .{ .x = 20, .y = -19 },
    .{ .x = 21, .y = -18 },
    .{ .x = 21, .y = -20 },
    .{ .x = 20, .y = -20 },
    .{ .x = 22, .y = -21 },
    .{ .x = 19, .y = -21 },
    .{ .x = 18, .y = -21 },
    // patch 3
    .{ .x = 12, .y = 33 },
    .{ .x = 12, .y = 34 },
    .{ .x = 13, .y = 33 },
    .{ .x = 13, .y = 34 },
    .{ .x = 13, .y = 35 },
    .{ .x = 13, .y = 36 },
    .{ .x = 12, .y = 37 },
    .{ .x = 14, .y = 36 },
    .{ .x = 15, .y = 36 },
    .{ .x = 16, .y = 37 },
    .{ .x = 15, .y = 37 },
    .{ .x = 16, .y = 35 },
    .{ .x = 16, .y = 34 },
    .{ .x = 17, .y = 33 },
    .{ .x = 15, .y = 33 },
    .{ .x = 14, .y = 32 },
    .{ .x = 15, .y = 32 },
    .{ .x = 15, .y = 31 },
    .{ .x = 12, .y = 30 },
};

const circles = [_]Vec2(i8){
    //patch 0;
    .{ .x = -12, .y = 19 },
    .{ .x = -11, .y = 19 },
    .{ .x = -11, .y = 18 },
    .{ .x = -10, .y = 18 },
    .{ .x = -10, .y = 17 },
    .{ .x = -9, .y = 18 },
    .{ .x = -8, .y = 19 },
    .{ .x = -7, .y = 20 },
    .{ .x = -11, .y = 20 },
    .{ .x = -10, .y = 21 },
    .{ .x = -11, .y = 21 },
    // patch 1
    .{ .x = -21, .y = -26 },
    .{ .x = -21, .y = -27 },
    .{ .x = -20, .y = -27 },
    .{ .x = -20, .y = -28 },
    .{ .x = -19, .y = -28 },
    .{ .x = -19, .y = -27 },
    .{ .x = -19, .y = -26 },
    .{ .x = -19, .y = -25 },
    .{ .x = -18, .y = -26 },
    .{ .x = -18, .y = -27 },
    .{ .x = -17, .y = -28 },
    // patcj 3
    .{ .x = 31, .y = -4 },
    .{ .x = 32, .y = -4 },
    .{ .x = 33, .y = -4 },
    .{ .x = 34, .y = -4 },
    .{ .x = 35, .y = -5 },
    .{ .x = 34, .y = -5 },
    .{ .x = 33, .y = -6 },
    .{ .x = 32, .y = -6 },
    .{ .x = 33, .y = -7 },
    .{ .x = 35, .y = -3 },
    .{ .x = 37, .y = -2 },
    .{ .x = 36, .y = -2 },
    .{ .x = 35, .y = -2 },
    .{ .x = 35, .y = -1 },
    .{ .x = 36, .y = -1 },
    .{ .x = 34, .y = 0 },
    .{ .x = 35, .y = 0 },
    .{ .x = 37, .y = 1 },
    .{ .x = 33, .y = -2 },
    .{ .x = 32, .y = -3 },
    .{ .x = 34, .y = -1 },
    .{ .x = 32, .y = -1 },
    .{ .x = 31, .y = -1 },
    .{ .x = 31, .y = -5 },
};
