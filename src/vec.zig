const std = @import("std");
const root = @import("main");

const Rect = root.Rect;

pub fn Vec2(comptime T: type) type {
    return struct {
        x: T = 0,
        y: T = 0,

        const Self = @This();

        pub fn divFloor(self: Self, denominator: T) Self {
            return Self{ .x = @divFloor(self.x, denominator), .y = @divFloor(self.y, denominator) };
        }

        pub fn add(self: Self, b: Self) Self {
            return Self{ .x = self.x + b.x, .y = self.y + b.y };
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

        pub fn isWithin(self: Self, bounding_box: Rect(T)) bool {
            return !(bounding_box.min.x > self.x or bounding_box.max.x < self.x or bounding_box.min.y > self.y or bounding_box.max.y < self.y);
        }

        pub fn magnitudeSquared(self: Self) T {
            return self.x * self.x + self.y * self.y;
        }
    };
}

test "magnitudeSquared" {
    try std.testing.expectEqual(@as(f64, 34), Vec2(f64).magnitudeSquared(.{ .x = 3.0, .y = -5.0 }));
    try std.testing.expectEqual(@as(i8, 34), Vec2(i8).magnitudeSquared(.{ .x = -3, .y = 5 }));
}
