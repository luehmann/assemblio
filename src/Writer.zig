const root = @import("main");

const globals = root.globals;

index: usize = 0,

const Self = @This();

pub fn write(self: *Self, value: anytype) void {
    const T = @TypeOf(value);
    const size = @sizeOf(T);
    @ptrCast(*align(1) T, &globals.buffer[self.index]).* = value;
    self.index += size;
}

/// Gives current address and advances index
pub fn reserve(self: *Self, comptime T: type) *align(1) T {
    const size = @sizeOf(T);
    const prev_index = self.index;
    self.index += size;
    return @ptrCast(*align(1) T, &globals.buffer[prev_index]);
}
