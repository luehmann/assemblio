const std = @import("std");
const root = @import("main");
const w4 = @import("wasm4");

const utils = root.utils;
const noise = root.noise;
const globals = root.globals;

const Item = root.Item;
const Vec2 = root.Vec2;
const Tilemap = root.Tilemap;
const Rect = root.Rect;

pub fn render() void {
    const top_left = Vec2(i32){
        .x = -(globals.camera_pos.x & 7),
        .y = -(globals.camera_pos.y & 7),
    };
    var x: i32 = 0;
    while (x < Tilemap.width) : (x += 1) {
        var y: i32 = 0;
        while (y < Tilemap.height) : (y += 1) {
            const pos = top_left.add(.{
                .x = x * 8,
                .y = y * 8,
            });
            if (utils.isOutOfBounds(pos)) continue;
            const world_pos = utils.screenToWorld(pos);
            const item = getItemAt(world_pos);
            if (!item.eql(Item.empty)) {
                w4.draw_colors.* = 0x20;
                item.render(pos.x + 2, pos.y + 2);
            }
        }
    }
}

pub fn getItemAt(pos: Vec2(i32)) Item {
    const hardcoded_resource = getResourceAtPosition(pos);
    if (!hardcoded_resource.eql(Item.empty)) return hardcoded_resource;
    return getRandomResource(pos, 0);
}

fn getResourceAtPosition(pos: Vec2(i32)) Item {
    const a = pos.intCast(i8);
    if (!a.isWithin(hardcoded_resource_bounding_box)) return Item.empty;
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

fn getRandomResource(world_pos: Vec2(i32), seed: u8) Item {
    _ = seed;
    const random_value = noise.noise3d(@intToFloat(f32, world_pos.x) / 30, @intToFloat(f32, world_pos.y) / 30, std.math.pi);
    const random_value_2 = noise.noise3d(@intToFloat(f32, world_pos.x) / 30, @intToFloat(f32, world_pos.y) / 30, std.math.e * 1000.0);
    if (random_value > threshold(world_pos)) {
        return Item.circle;
    } else if (random_value < -threshold(world_pos)) {
        return Item.ring;
    } else if (random_value_2 > threshold(world_pos)) {
        return Item.square;
    }

    return Item.empty;
}

fn threshold(pos: Vec2(i32)) f32 {
    const x = @intToFloat(f32, std.math.max(std.math.absCast(pos.x), std.math.absCast(pos.y)));
    // const x = @intToFloat(f32, pos.subtract(.{}).magnitudeSquared());
    return 1.0 - 0.4 / 128.0 * x;
}

const hardcoded_resource_bounding_box = blk: {
    var bounding_box: Rect(i8) = .{ .min = .{}, .max = .{} };
    for (rings) |b| {
        if (b.x < bounding_box.min.x) bounding_box.min.x = b.x;
        if (b.y < bounding_box.min.y) bounding_box.min.y = b.y;
        if (b.x > bounding_box.max.x) bounding_box.max.x = b.x;
        if (b.y > bounding_box.max.y) bounding_box.max.y = b.y;
    }
    for (squares) |b| {
        if (b.x < bounding_box.min.x) bounding_box.min.x = b.x;
        if (b.y < bounding_box.min.y) bounding_box.min.y = b.y;
        if (b.x > bounding_box.max.x) bounding_box.max.x = b.x;
        if (b.y > bounding_box.max.y) bounding_box.max.y = b.y;
    }
    for (circles) |b| {
        if (b.x < bounding_box.min.x) bounding_box.min.x = b.x;
        if (b.y < bounding_box.min.y) bounding_box.min.y = b.y;
        if (b.x > bounding_box.max.x) bounding_box.max.x = b.x;
        if (b.y > bounding_box.max.y) bounding_box.max.y = b.y;
    }
    break :blk bounding_box;
};

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
