const root = @import("main");

const globals = root.globals;

index: usize = 0,

const Self = @This();

pub fn read(self: *Self, comptime T: type) T {
    const size = @sizeOf(T);
    const prev_index = self.index;
    self.index += size;
    return @ptrCast(*align(1) T, &globals.buffer[prev_index]).*;
}
