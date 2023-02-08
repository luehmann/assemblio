const std = @import("std");
const root = @import("main");

const Belt = root.nodes.Belt;

const Direction = root.Direction;

/// State of a slot of a belt
pub const SlotState = enum(u2) {
    empty,
    filled,
    filled_from_the_right,
    filled_from_the_left,

    pub fn getFillDirection(from: Direction, to: Direction) SlotState {
        if (from.rotateClockwise() == to) return .filled_from_the_right;
        if (from.rotateCounterClockwise() == to) return .filled_from_the_left;
        if (from == to) return .filled;
        unreachable;
    }
};

const PackedArray = std.PackedIntArray(std.meta.Tag(SlotState), Belt.max_length);
packed_array: PackedArray = std.mem.zeroes(PackedArray),

comptime {
    if (false) {
        @compileLog("Belt", @sizeOf(PackedArray));
    }
}

const Self = @This();

pub fn get(self: Self, slot: u8) SlotState {
    return @intToEnum(SlotState, self.packed_array.get(slot));
}

pub fn set(self: *Self, slot: u8, state: SlotState) void {
    self.packed_array.set(slot, @enumToInt(state));
}

test "get & set" {
    var slots = Self{};

    try std.testing.expectEqual(SlotState.empty, slots.get(0));
    slots.set(0, .filled);
    try std.testing.expectEqual(SlotState.filled, slots.get(0));

    try std.testing.expectEqual(SlotState.empty, slots.get(63));
    slots.set(63, .filled_from_the_right);
    try std.testing.expectEqual(SlotState.filled_from_the_right, slots.get(63));

    try std.testing.expectEqual(SlotState.empty, slots.get(31));
    slots.set(31, .filled_from_the_right);
    try std.testing.expectEqual(SlotState.filled_from_the_right, slots.get(31));
}
