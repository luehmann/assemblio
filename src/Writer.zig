const globals = @import("globals.zig");

index: usize = 0,

const Self = @This();

pub fn writeByte(self: *Self, byte: u8) void {
    globals.buffer[self.index] = byte;
    self.index += 1;
}

/// Gives current address and advances index
pub fn writeByteLater(self: *Self) *u8 {
    const prev_index = self.index;
    self.index += 1;
    return &globals.buffer[prev_index];
}
