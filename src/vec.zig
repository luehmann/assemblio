const std = @import("std");
const BoundingBox = @import("bounding_box.zig").BoundingBox;

pub fn Vec2(comptime T: type) type {
    return struct {
        x: T,
        y: T,
        const Self = @This();
        const UnsignedT = std.meta.Int(.unsigned, std.meta.bitCount(T));

        pub fn divFloor(self: Self, denominator: T) Self {
            return Self{ .x = @divFloor(self.x, denominator), .y = @divFloor(self.y, denominator) };
        }
        pub fn add(self: Self, b: Self) Self {
            return Self{ .x = self.x + b.x, .y = self.y + b.y };
        }
        pub fn addX(self: Self, n: T) Self {
            return Self{ .x = self.x + n, .y = self.y };
        }
        pub fn addY(self: Self, n: T) Self {
            return Self{ .x = self.x, .y = self.y + n };
        }
        pub fn subtract(self: Self, b: Self) Self {
            return Self{ .x = self.x - b.x, .y = self.y - b.y };
        }
        pub fn scale(self: Self, factor: T) Self {
            return Self{ .x = self.x * factor, .y = self.y * factor };
        }
        pub fn intCast(self: Self, comptime DestType: type) Vec2(DestType) {
            return .{
                .x = @intCast(DestType, self.x),
                .y = @intCast(DestType, self.y),
            };
        }
        pub fn clamp(self: Self, lower: Self, upper: Self) Self {
            return .{
                .x = std.math.clamp(self.x, lower.x, upper.x),
                .y = std.math.clamp(self.y, lower.y, upper.x),
            };
        }

        pub fn as(self: Self, comptime DestType: type) Vec2(DestType) {
            return .{
                .x = @as(DestType, self.x),
                .y = @as(DestType, self.y),
            };
        }

        pub fn isWithin(self: Self, bounding_box: BoundingBox(T)) bool {
            return !(bounding_box.min.x > self.x or bounding_box.max.x < self.x or bounding_box.min.y > self.y or bounding_box.max.y < self.y);
        }

        pub fn magnitude(self: Self) T {
            return @intCast(T, std.math.sqrt(@intCast(UnsignedT, self.x * self.x) + @intCast(UnsignedT, self.y * self.y)));
        }

        pub const zero = Self{ .x = 0, .y = 0 };
    };
}
