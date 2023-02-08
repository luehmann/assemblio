const std = @import("std");
const root = @import("main");
const w4 = @import("wasm4");

const globals = root.globals;

const Vec2 = root.Vec2;

pub const width = 21;
pub const height = 21;
const Bitset = std.StaticBitSet(width * height);

bitset: Bitset,

const Self = @This();

pub fn get(self: Self, x: u32, y: u32) bool {
    const index = @intCast(u32, x + y * width);
    return self.bitset.isSet(index);
}

pub fn set(self: *Self, world_pos: Vec2(i32)) void {
    const x = @intCast(usize, world_pos.x - @divFloor(globals.camera_pos.x, 8));
    const y = @intCast(usize, world_pos.y - @divFloor(globals.camera_pos.y, 8));
    const index = @intCast(u32, x + y * width);
    return self.bitset.set(index);
}

pub fn reset(self: *Self) void {
    self.bitset = Bitset.initEmpty();
}
