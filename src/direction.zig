const std = @import("std");
const root = @import("main");
const w4 = @import("wasm4");

const Vec2 = root.Vec2;

pub const Direction = enum(u2) {
    north = 0b00,
    east = 0b01,
    south = 0b10,
    west = 0b11,

    pub fn rotateClockwise(self: Direction) Direction {
        return @intToEnum(Direction, @enumToInt(self) +% 1);
    }

    pub fn rotateCounterClockwise(self: Direction) Direction {
        return @intToEnum(Direction, @enumToInt(self) -% 1);
    }

    pub fn opposite(self: Direction) Direction {
        return @intToEnum(Direction, @enumToInt(self) +% 2);
    }

    pub fn toVec(self: Direction) Vec2(i32) {
        return switch (self) {
            .north => .{ .x = 0, .y = -1 },
            .east => .{ .x = 1, .y = 0 },
            .south => .{ .x = 0, .y = 1 },
            .west => .{ .x = -1, .y = 0 },
        };
    }

    pub fn blitFlags(self: Direction) u32 {
        return switch (self) {
            .north => 0,
            .east => w4.BLIT_FLIP_Y | w4.BLIT_ROTATE,
            .south => w4.BLIT_FLIP_Y | w4.BLIT_FLIP_X,
            .west => w4.BLIT_ROTATE,
        };
    }
    pub fn blitFlagsRotate(self: Direction) u32 {
        return switch (self) {
            .north => 0,
            .east => w4.BLIT_FLIP_Y | w4.BLIT_FLIP_X | w4.BLIT_ROTATE,
            .south => w4.BLIT_FLIP_Y | w4.BLIT_FLIP_X,
            .west => w4.BLIT_ROTATE,
        };
    }

    pub fn isHorizontal(self: Direction) bool {
        return @enumToInt(self) & 0b1 == 0b1;
    }
    pub fn isFacingNegative(self: Direction) bool {
        return switch (self) {
            .north, .west => true,
            .south, .east => false,
        };
    }
};

test "rotateClockwise" {
    try std.testing.expectEqual(Direction.north, Direction.west.rotateClockwise());
    try std.testing.expectEqual(Direction.east, Direction.north.rotateClockwise());
    try std.testing.expectEqual(Direction.south, Direction.east.rotateClockwise());
    try std.testing.expectEqual(Direction.west, Direction.south.rotateClockwise());
}

test "rotateCounterClockwise" {
    try std.testing.expectEqual(Direction.north, Direction.east.rotateCounterClockwise());
    try std.testing.expectEqual(Direction.east, Direction.south.rotateCounterClockwise());
    try std.testing.expectEqual(Direction.south, Direction.west.rotateCounterClockwise());
    try std.testing.expectEqual(Direction.west, Direction.north.rotateCounterClockwise());
}

test "opposite" {
    try std.testing.expectEqual(Direction.north, Direction.south.opposite());
    try std.testing.expectEqual(Direction.east, Direction.west.opposite());
    try std.testing.expectEqual(Direction.south, Direction.north.opposite());
    try std.testing.expectEqual(Direction.west, Direction.east.opposite());
}
