const std = @import("std");
const Direction = @import("direction.zig").Direction;

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

/// This struct can hold 256 (0..255) 2-bit SlotStates
pub const Slots = struct {
    slots: [16]u32 = [_]u32{0} ** 16,

    pub fn get(self: Slots, slot: u8) SlotState {
        const section: u32 = self.slots[slot >> 4];
        const shift = @intCast(u5, 30 - ((slot & 0b1111) << 1));
        const int = (section >> shift) & 0b11;
        return @intToEnum(SlotState, @intCast(u2, int));
    }

    pub fn set(self: *Slots, slot: u8, state: SlotState) void {
        const shift = @intCast(u5, 30 - ((slot & 0b1111) << 1));
        const mask = @as(u32, 0b11) << shift;
        self.slots[slot >> 4] = (@as(u32, @enumToInt(state)) << shift) | (self.slots[slot >> 4] & ~mask);
    }
};

test "Slots.get & Slots.set" {
    var slots = Slots{};

    try std.testing.expectEqual(SlotState.empty, slots.get(0));
    slots.set(0, .filled);
    try std.testing.expectEqual(SlotState.filled, slots.get(0));

    try std.testing.expectEqual(SlotState.empty, slots.get(255));
    slots.set(255, .filled_from_the_right);
    try std.testing.expectEqual(SlotState.filled_from_the_right, slots.get(255));

    try std.testing.expectEqual(SlotState.empty, slots.get(127));
    slots.set(127, .filled_from_the_right);
    try std.testing.expectEqual(SlotState.filled_from_the_right, slots.get(127));
}
