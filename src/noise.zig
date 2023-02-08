const std = @import("std");

const simplex_noise = @import("simplexnoise1234.zig");

pub fn noise2d(x: f32, y: f32) f32 {
    return simplex_noise.snoise2(x, y);
}

pub fn noise3d(x: f32, y: f32, z: f32) f32 {
    return simplex_noise.snoise3(x, y, z);
}

// test "perlin2d" {
//     std.debug.print("\n{d}\n\n", .{simplex_noise.snoise2(10, 200)});
//     try std.testing.expect(false);
// }
