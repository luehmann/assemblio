const std = @import("std");
const Vec2 = @import("vec.zig").Vec2;

/// A rectangle
pub fn BoundingBox(comptime T: type) type {
    return struct {
        min: Vec2(T),
        max: Vec2(T),

        const Self = @This();

        pub fn fromPoints(a: Vec2(T), b: Vec2(T)) Self {
            return .{
                .min = .{ .x = std.math.min(a.x, b.x), .y = std.math.min(a.y, b.y) },
                .max = .{ .x = std.math.max(a.x, b.x), .y = std.math.max(a.y, b.y) },
            };
        }

        pub fn fromPoint(point: Vec2(T)) Self {
            return .{ .min = point, .max = point };
        }

        pub fn intersects(b1: Self, b2: Self) bool {
            return !(b2.min.x > b1.max.x or b2.max.x < b1.min.x or b2.min.y > b1.max.y or b2.max.y < b1.min.y);
        }

        pub fn distance(a: Self, b: Self) Vec2(T) {
            if (a.intersects(b)) return Vec2(T).zero;
            const most_left = if (a.min.x < b.min.x) a else b;
            const most_right = if (b.min.x < a.min.x) a else b;

            const delta_x = most_right.min.x - most_left.max.x;

            const upper = if (a.min.y < b.min.y) a else b;
            const lower = if (b.min.y < a.min.y) a else b;

            const delta_y = lower.min.y - upper.max.y;

            return .{ .x = delta_x, .y = delta_y };
        }
    };
}

test "BoundingBox.distance" {
    const a = BoundingBox(i32){
        .min = .{ .x = 0, .y = 0 },
        .max = .{ .x = 5, .y = 5 },
    };
    const b = BoundingBox(i32){
        .min = .{ .x = 20, .y = 20 },
        .max = .{ .x = 25, .y = 25 },
    };
    try std.testing.expectEqual(Vec2(i32){ .x = 15, .y = 15 }, a.distance(b));
}
