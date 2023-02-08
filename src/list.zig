const std = @import("std");

pub fn List(comptime T: type, comptime capacity: usize) type {
    return struct {
        buffer: [capacity]T = undefined,
        len: usize = 0,

        const Self = @This();

        pub fn items(self: *const Self) []const T {
            return self.buffer[0..self.len];
        }

        pub fn itemsMut(self: *Self) []T {
            return self.buffer[0..self.len];
        }

        pub fn append(self: *Self, item: T) void {
            std.debug.assert(self.len < capacity);
            self.buffer[self.len] = item;
            self.len += 1;
        }

        pub fn appendSlice(self: *Self, slice: []const T) void {
            // TODO: optimize
            for (slice) |item| {
                self.append(item);
            }
        }

        pub fn pop(self: *Self) ?T {
            if (self.len > 0) {
                self.len -= 1;
                return self.buffer[self.len];
            } else {
                return null;
            }
        }

        pub fn reset(self: *Self) void {
            self.len = 0;
        }
    };
}

test "memory usage" {
    try std.testing.expectEqual(@sizeOf(i32) * 10 + @sizeOf(usize), @sizeOf(List(i32, 10)));
}

test "append" {
    var list = List(i32, 10){};
    try std.testing.expectEqual(@as(usize, 0), list.len);
    list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.buffer[0]);
    try std.testing.expectEqual(@as(usize, 1), list.len);
    list.append(9);
    try std.testing.expectEqual(@as(i32, 42), list.buffer[0]);
    try std.testing.expectEqual(@as(i32, 9), list.buffer[1]);
    try std.testing.expectEqual(@as(usize, 2), list.len);
}

test "reset" {
    var list = List(i32, 10){};
    list.append(42);
    list.append(9);
    try std.testing.expectEqual(@as(usize, 2), list.len);
    list.reset();
    try std.testing.expectEqual(@as(usize, 0), list.len);
}

test "items" {
    var list = List(i32, 10){};
    list.append(42);
    list.append(9);
    try std.testing.expectEqualSlices(i32, &[2]i32{ 42, 9 }, list.items());
}

test "itemsMut" {
    var list = List(i32, 10){};
    list.append(42);
    list.append(9);
    const items = list.itemsMut();
    try std.testing.expectEqualSlices(i32, &[2]i32{ 42, 9 }, items);
    items[0] = 1;
    items[1] = 2;
    try std.testing.expectEqual(@as(i32, 1), list.buffer[0]);
    try std.testing.expectEqual(@as(i32, 2), list.buffer[1]);
}
