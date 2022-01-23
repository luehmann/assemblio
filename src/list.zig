const std = @import("std");

pub fn List(comptime T: type, comptime len: comptime_int) type {
    return struct {
        items: [len]T = undefined,
        len: usize = 0,

        const Self = @This();

        pub fn add(self: *Self, item: T) void {
            // TODO: assert not already present
            self.items[self.len] = item;
            self.len += 1;
        }

        pub fn remove(self: *Self, item: T) void {
            var i: u32 = 0;
            while (i < self.len) : (i += 1) {
                if (std.meta.eql(self.items[i], item)) {
                    self.len -= 1;
                    while (i < self.len) : (i += 1) {
                        self.items[i] = self.items[i + 1];
                    }
                }
            }
        }
        pub fn removeAt(self: *Self, index: usize) void {
            std.debug.assert(index < self.len);
            var i: u32 = index;
            self.len -= 1;
            while (i < self.len) : (i += 1) {
                self.items[i] = self.items[i + 1];
            }
        }

        pub fn toSlice(self: *Self) []T {
            return self.items[0..self.len];
        }

        pub fn reset(self: *Self) void {
            self.len = 0;
        }

        pub fn get(self: Self, index: usize) T {
            return self.items[index];
        }
    };
}

test {
    var list = List(u32, 4){};
    list.add(1);
    list.add(2);
    list.add(3);
    list.add(4);
    try std.testing.expectEqual(@as(u32, 1), list.items[0]);
    try std.testing.expectEqual(@as(u32, 2), list.items[1]);
    try std.testing.expectEqual(@as(u32, 3), list.items[2]);
    try std.testing.expectEqual(@as(u32, 4), list.items[3]);
    try std.testing.expectEqual(@as(usize, 4), list.len);

    list.remove(2);

    try std.testing.expectEqual(@as(u32, 1), list.items[0]);
    try std.testing.expectEqual(@as(u32, 3), list.items[1]);
    try std.testing.expectEqual(@as(u32, 4), list.items[2]);
    try std.testing.expectEqual(@as(usize, 3), list.toSlice().len);
}
