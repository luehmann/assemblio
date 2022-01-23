const globals = @import("globals.zig");

index: usize = 0,

const Self = @This();

pub fn readByte(self: *Self) u8 {
    const prev_index = self.index;
    self.index += 1;
    return globals.buffer[prev_index];
}
