// This is autotranslated using `zig translate-c simplexnoise1234.c`
//
// Manual changes:
// - remove `export`s

pub const __builtin_bswap16 = @import("std").zig.c_builtins.__builtin_bswap16;
pub const __builtin_bswap32 = @import("std").zig.c_builtins.__builtin_bswap32;
pub const __builtin_bswap64 = @import("std").zig.c_builtins.__builtin_bswap64;
pub const __builtin_signbit = @import("std").zig.c_builtins.__builtin_signbit;
pub const __builtin_signbitf = @import("std").zig.c_builtins.__builtin_signbitf;
pub const __builtin_popcount = @import("std").zig.c_builtins.__builtin_popcount;
pub const __builtin_ctz = @import("std").zig.c_builtins.__builtin_ctz;
pub const __builtin_clz = @import("std").zig.c_builtins.__builtin_clz;
pub const __builtin_sqrt = @import("std").zig.c_builtins.__builtin_sqrt;
pub const __builtin_sqrtf = @import("std").zig.c_builtins.__builtin_sqrtf;
pub const __builtin_sin = @import("std").zig.c_builtins.__builtin_sin;
pub const __builtin_sinf = @import("std").zig.c_builtins.__builtin_sinf;
pub const __builtin_cos = @import("std").zig.c_builtins.__builtin_cos;
pub const __builtin_cosf = @import("std").zig.c_builtins.__builtin_cosf;
pub const __builtin_exp = @import("std").zig.c_builtins.__builtin_exp;
pub const __builtin_expf = @import("std").zig.c_builtins.__builtin_expf;
pub const __builtin_exp2 = @import("std").zig.c_builtins.__builtin_exp2;
pub const __builtin_exp2f = @import("std").zig.c_builtins.__builtin_exp2f;
pub const __builtin_log = @import("std").zig.c_builtins.__builtin_log;
pub const __builtin_logf = @import("std").zig.c_builtins.__builtin_logf;
pub const __builtin_log2 = @import("std").zig.c_builtins.__builtin_log2;
pub const __builtin_log2f = @import("std").zig.c_builtins.__builtin_log2f;
pub const __builtin_log10 = @import("std").zig.c_builtins.__builtin_log10;
pub const __builtin_log10f = @import("std").zig.c_builtins.__builtin_log10f;
pub const __builtin_abs = @import("std").zig.c_builtins.__builtin_abs;
pub const __builtin_fabs = @import("std").zig.c_builtins.__builtin_fabs;
pub const __builtin_fabsf = @import("std").zig.c_builtins.__builtin_fabsf;
pub const __builtin_floor = @import("std").zig.c_builtins.__builtin_floor;
pub const __builtin_floorf = @import("std").zig.c_builtins.__builtin_floorf;
pub const __builtin_ceil = @import("std").zig.c_builtins.__builtin_ceil;
pub const __builtin_ceilf = @import("std").zig.c_builtins.__builtin_ceilf;
pub const __builtin_trunc = @import("std").zig.c_builtins.__builtin_trunc;
pub const __builtin_truncf = @import("std").zig.c_builtins.__builtin_truncf;
pub const __builtin_round = @import("std").zig.c_builtins.__builtin_round;
pub const __builtin_roundf = @import("std").zig.c_builtins.__builtin_roundf;
pub const __builtin_strlen = @import("std").zig.c_builtins.__builtin_strlen;
pub const __builtin_strcmp = @import("std").zig.c_builtins.__builtin_strcmp;
pub const __builtin_object_size = @import("std").zig.c_builtins.__builtin_object_size;
pub const __builtin___memset_chk = @import("std").zig.c_builtins.__builtin___memset_chk;
pub const __builtin_memset = @import("std").zig.c_builtins.__builtin_memset;
pub const __builtin___memcpy_chk = @import("std").zig.c_builtins.__builtin___memcpy_chk;
pub const __builtin_memcpy = @import("std").zig.c_builtins.__builtin_memcpy;
pub const __builtin_expect = @import("std").zig.c_builtins.__builtin_expect;
pub const __builtin_nanf = @import("std").zig.c_builtins.__builtin_nanf;
pub const __builtin_huge_valf = @import("std").zig.c_builtins.__builtin_huge_valf;
pub const __builtin_inff = @import("std").zig.c_builtins.__builtin_inff;
pub const __builtin_isnan = @import("std").zig.c_builtins.__builtin_isnan;
pub const __builtin_isinf = @import("std").zig.c_builtins.__builtin_isinf;
pub const __builtin_isinf_sign = @import("std").zig.c_builtins.__builtin_isinf_sign;
pub const __has_builtin = @import("std").zig.c_builtins.__has_builtin;
pub const __builtin_assume = @import("std").zig.c_builtins.__builtin_assume;
pub const __builtin_unreachable = @import("std").zig.c_builtins.__builtin_unreachable;
pub const __builtin_constant_p = @import("std").zig.c_builtins.__builtin_constant_p;
pub const __builtin_mul_overflow = @import("std").zig.c_builtins.__builtin_mul_overflow;
pub fn snoise1(arg_x: f32) f32 {
    var x = arg_x;
    var @"i0": c_int = if (@intToFloat(f32, @floatToInt(c_int, x)) <= x) @floatToInt(c_int, x) else @floatToInt(c_int, x) - @as(c_int, 1);
    var @"i1": c_int = @"i0" + @as(c_int, 1);
    var x0: f32 = x - @intToFloat(f32, @"i0");
    var x1: f32 = x0 - 1.0;
    var n0: f32 = undefined;
    var n1: f32 = undefined;
    var t0: f32 = 1.0 - (x0 * x0);
    t0 *= t0;
    n0 = (t0 * t0) * grad1(@bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, @"i0" & @as(c_int, 255))])), x0);
    var t1: f32 = 1.0 - (x1 * x1);
    t1 *= t1;
    n1 = (t1 * t1) * grad1(@bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, @"i1" & @as(c_int, 255))])), x1);
    return 0.25 * (n0 + n1);
}
pub fn snoise2(arg_x: f32, arg_y: f32) f32 {
    var x = arg_x;
    var y = arg_y;
    var n0: f32 = undefined;
    var n1: f32 = undefined;
    var n2: f32 = undefined;
    var s: f32 = @floatCast(f32, @floatCast(f64, x + y) * 0.366025403);
    var xs: f32 = x + s;
    var ys: f32 = y + s;
    var i: c_int = if (@intToFloat(f32, @floatToInt(c_int, xs)) <= xs) @floatToInt(c_int, xs) else @floatToInt(c_int, xs) - @as(c_int, 1);
    var j: c_int = if (@intToFloat(f32, @floatToInt(c_int, ys)) <= ys) @floatToInt(c_int, ys) else @floatToInt(c_int, ys) - @as(c_int, 1);
    var t: f32 = @floatCast(f32, @floatCast(f64, @intToFloat(f32, i + j)) * 0.211324865);
    var X0: f32 = @intToFloat(f32, i) - t;
    var Y0: f32 = @intToFloat(f32, j) - t;
    var x0: f32 = x - X0;
    var y0: f32 = y - Y0;
    var @"i1": c_int = undefined;
    var j1: c_int = undefined;
    if (x0 > y0) {
        @"i1" = 1;
        j1 = 0;
    } else {
        @"i1" = 0;
        j1 = 1;
    }
    var x1: f32 = @floatCast(f32, @floatCast(f64, x0 - @intToFloat(f32, @"i1")) + 0.211324865);
    var y1: f32 = @floatCast(f32, @floatCast(f64, y0 - @intToFloat(f32, j1)) + 0.211324865);
    var x2: f32 = @floatCast(f32, @floatCast(f64, x0 - 1.0) + (@floatCast(f64, 2.0) * 0.211324865));
    var y2: f32 = @floatCast(f32, @floatCast(f64, y0 - 1.0) + (@floatCast(f64, 2.0) * 0.211324865));
    var ii: c_int = i & @as(c_int, 255);
    var jj: c_int = j & @as(c_int, 255);
    var t0: f32 = (0.5 - (x0 * x0)) - (y0 * y0);
    if (t0 < 0.0) {
        n0 = 0.0;
    } else {
        t0 *= t0;
        n0 = (t0 * t0) * grad2(@bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, ii + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, jj)])))])), x0, y0);
    }
    var t1: f32 = (0.5 - (x1 * x1)) - (y1 * y1);
    if (t1 < 0.0) {
        n1 = 0.0;
    } else {
        t1 *= t1;
        n1 = (t1 * t1) * grad2(@bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (ii + @"i1") + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, jj + j1)])))])), x1, y1);
    }
    var t2: f32 = (0.5 - (x2 * x2)) - (y2 * y2);
    if (t2 < 0.0) {
        n2 = 0.0;
    } else {
        t2 *= t2;
        n2 = (t2 * t2) * grad2(@bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (ii + @as(c_int, 1)) + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, jj + @as(c_int, 1))])))])), x2, y2);
    }
    return 40.0 * ((n0 + n1) + n2);
}
pub fn snoise3(arg_x: f32, arg_y: f32, arg_z: f32) f32 {
    var x = arg_x;
    var y = arg_y;
    var z = arg_z;
    var n0: f32 = undefined;
    var n1: f32 = undefined;
    var n2: f32 = undefined;
    var n3: f32 = undefined;
    var s: f32 = @floatCast(f32, @floatCast(f64, (x + y) + z) * 0.333333333);
    var xs: f32 = x + s;
    var ys: f32 = y + s;
    var zs: f32 = z + s;
    var i: c_int = if (@intToFloat(f32, @floatToInt(c_int, xs)) <= xs) @floatToInt(c_int, xs) else @floatToInt(c_int, xs) - @as(c_int, 1);
    var j: c_int = if (@intToFloat(f32, @floatToInt(c_int, ys)) <= ys) @floatToInt(c_int, ys) else @floatToInt(c_int, ys) - @as(c_int, 1);
    var k: c_int = if (@intToFloat(f32, @floatToInt(c_int, zs)) <= zs) @floatToInt(c_int, zs) else @floatToInt(c_int, zs) - @as(c_int, 1);
    var t: f32 = @floatCast(f32, @floatCast(f64, @intToFloat(f32, (i + j) + k)) * 0.166666667);
    var X0: f32 = @intToFloat(f32, i) - t;
    var Y0: f32 = @intToFloat(f32, j) - t;
    var Z0: f32 = @intToFloat(f32, k) - t;
    var x0: f32 = x - X0;
    var y0: f32 = y - Y0;
    var z0: f32 = z - Z0;
    var @"i1": c_int = undefined;
    var j1: c_int = undefined;
    var k1: c_int = undefined;
    var @"i2": c_int = undefined;
    var j2: c_int = undefined;
    var k2: c_int = undefined;
    if (x0 >= y0) {
        if (y0 >= z0) {
            @"i1" = 1;
            j1 = 0;
            k1 = 0;
            @"i2" = 1;
            j2 = 1;
            k2 = 0;
        } else if (x0 >= z0) {
            @"i1" = 1;
            j1 = 0;
            k1 = 0;
            @"i2" = 1;
            j2 = 0;
            k2 = 1;
        } else {
            @"i1" = 0;
            j1 = 0;
            k1 = 1;
            @"i2" = 1;
            j2 = 0;
            k2 = 1;
        }
    } else {
        if (y0 < z0) {
            @"i1" = 0;
            j1 = 0;
            k1 = 1;
            @"i2" = 0;
            j2 = 1;
            k2 = 1;
        } else if (x0 < z0) {
            @"i1" = 0;
            j1 = 1;
            k1 = 0;
            @"i2" = 0;
            j2 = 1;
            k2 = 1;
        } else {
            @"i1" = 0;
            j1 = 1;
            k1 = 0;
            @"i2" = 1;
            j2 = 1;
            k2 = 0;
        }
    }
    var x1: f32 = @floatCast(f32, @floatCast(f64, x0 - @intToFloat(f32, @"i1")) + 0.166666667);
    var y1: f32 = @floatCast(f32, @floatCast(f64, y0 - @intToFloat(f32, j1)) + 0.166666667);
    var z1: f32 = @floatCast(f32, @floatCast(f64, z0 - @intToFloat(f32, k1)) + 0.166666667);
    var x2: f32 = @floatCast(f32, @floatCast(f64, x0 - @intToFloat(f32, @"i2")) + (@floatCast(f64, 2.0) * 0.166666667));
    var y2: f32 = @floatCast(f32, @floatCast(f64, y0 - @intToFloat(f32, j2)) + (@floatCast(f64, 2.0) * 0.166666667));
    var z2: f32 = @floatCast(f32, @floatCast(f64, z0 - @intToFloat(f32, k2)) + (@floatCast(f64, 2.0) * 0.166666667));
    var x3: f32 = @floatCast(f32, @floatCast(f64, x0 - 1.0) + (@floatCast(f64, 3.0) * 0.166666667));
    var y3: f32 = @floatCast(f32, @floatCast(f64, y0 - 1.0) + (@floatCast(f64, 3.0) * 0.166666667));
    var z3: f32 = @floatCast(f32, @floatCast(f64, z0 - 1.0) + (@floatCast(f64, 3.0) * 0.166666667));
    var ii: c_int = i & @as(c_int, 255);
    var jj: c_int = j & @as(c_int, 255);
    var kk: c_int = k & @as(c_int, 255);
    var t0: f32 = ((0.5 - (x0 * x0)) - (y0 * y0)) - (z0 * z0);
    if (t0 < 0.0) {
        n0 = 0.0;
    } else {
        t0 *= t0;
        n0 = (t0 * t0) * grad3(@bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, ii + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, jj + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, kk)])))])))])), x0, y0, z0);
    }
    var t1: f32 = ((0.5 - (x1 * x1)) - (y1 * y1)) - (z1 * z1);
    if (t1 < 0.0) {
        n1 = 0.0;
    } else {
        t1 *= t1;
        n1 = (t1 * t1) * grad3(@bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (ii + @"i1") + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (jj + j1) + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, kk + k1)])))])))])), x1, y1, z1);
    }
    var t2: f32 = ((0.5 - (x2 * x2)) - (y2 * y2)) - (z2 * z2);
    if (t2 < 0.0) {
        n2 = 0.0;
    } else {
        t2 *= t2;
        n2 = (t2 * t2) * grad3(@bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (ii + @"i2") + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (jj + j2) + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, kk + k2)])))])))])), x2, y2, z2);
    }
    var t3: f32 = ((0.5 - (x3 * x3)) - (y3 * y3)) - (z3 * z3);
    if (t3 < 0.0) {
        n3 = 0.0;
    } else {
        t3 *= t3;
        n3 = (t3 * t3) * grad3(@bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (ii + @as(c_int, 1)) + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (jj + @as(c_int, 1)) + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, kk + @as(c_int, 1))])))])))])), x3, y3, z3);
    }
    return 72.0 * (((n0 + n1) + n2) + n3);
}
pub fn snoise4(arg_x: f32, arg_y: f32, arg_z: f32, arg_w: f32) f32 {
    var x = arg_x;
    var y = arg_y;
    var z = arg_z;
    var w = arg_w;
    var n0: f32 = undefined;
    var n1: f32 = undefined;
    var n2: f32 = undefined;
    var n3: f32 = undefined;
    var n4: f32 = undefined;
    var s: f32 = @floatCast(f32, @floatCast(f64, ((x + y) + z) + w) * 0.309016994);
    var xs: f32 = x + s;
    var ys: f32 = y + s;
    var zs: f32 = z + s;
    var ws: f32 = w + s;
    var i: c_int = if (@intToFloat(f32, @floatToInt(c_int, xs)) <= xs) @floatToInt(c_int, xs) else @floatToInt(c_int, xs) - @as(c_int, 1);
    var j: c_int = if (@intToFloat(f32, @floatToInt(c_int, ys)) <= ys) @floatToInt(c_int, ys) else @floatToInt(c_int, ys) - @as(c_int, 1);
    var k: c_int = if (@intToFloat(f32, @floatToInt(c_int, zs)) <= zs) @floatToInt(c_int, zs) else @floatToInt(c_int, zs) - @as(c_int, 1);
    var l: c_int = if (@intToFloat(f32, @floatToInt(c_int, ws)) <= ws) @floatToInt(c_int, ws) else @floatToInt(c_int, ws) - @as(c_int, 1);
    var t: f32 = @floatCast(f32, @intToFloat(f64, ((i + j) + k) + l) * 0.138196601);
    var X0: f32 = @intToFloat(f32, i) - t;
    var Y0: f32 = @intToFloat(f32, j) - t;
    var Z0: f32 = @intToFloat(f32, k) - t;
    var W0: f32 = @intToFloat(f32, l) - t;
    var x0: f32 = x - X0;
    var y0: f32 = y - Y0;
    var z0: f32 = z - Z0;
    var w0: f32 = w - W0;
    var c1: c_int = if (x0 > y0) @as(c_int, 32) else @as(c_int, 0);
    var c2: c_int = if (x0 > z0) @as(c_int, 16) else @as(c_int, 0);
    var c3: c_int = if (y0 > z0) @as(c_int, 8) else @as(c_int, 0);
    var c4: c_int = if (x0 > w0) @as(c_int, 4) else @as(c_int, 0);
    var c5: c_int = if (y0 > w0) @as(c_int, 2) else @as(c_int, 0);
    var c6: c_int = if (z0 > w0) @as(c_int, 1) else @as(c_int, 0);
    var c: c_int = ((((c1 + c2) + c3) + c4) + c5) + c6;
    var @"i1": c_int = undefined;
    var j1: c_int = undefined;
    var k1: c_int = undefined;
    var l1: c_int = undefined;
    var @"i2": c_int = undefined;
    var j2: c_int = undefined;
    var k2: c_int = undefined;
    var l2: c_int = undefined;
    var @"i3": c_int = undefined;
    var j3: c_int = undefined;
    var k3: c_int = undefined;
    var l3: c_int = undefined;
    @"i1" = if (@bitCast(c_int, @as(c_uint, simplex[@intCast(c_uint, c)][@intCast(c_uint, @as(c_int, 0))])) >= @as(c_int, 3)) @as(c_int, 1) else @as(c_int, 0);
    j1 = if (@bitCast(c_int, @as(c_uint, simplex[@intCast(c_uint, c)][@intCast(c_uint, @as(c_int, 1))])) >= @as(c_int, 3)) @as(c_int, 1) else @as(c_int, 0);
    k1 = if (@bitCast(c_int, @as(c_uint, simplex[@intCast(c_uint, c)][@intCast(c_uint, @as(c_int, 2))])) >= @as(c_int, 3)) @as(c_int, 1) else @as(c_int, 0);
    l1 = if (@bitCast(c_int, @as(c_uint, simplex[@intCast(c_uint, c)][@intCast(c_uint, @as(c_int, 3))])) >= @as(c_int, 3)) @as(c_int, 1) else @as(c_int, 0);
    @"i2" = if (@bitCast(c_int, @as(c_uint, simplex[@intCast(c_uint, c)][@intCast(c_uint, @as(c_int, 0))])) >= @as(c_int, 2)) @as(c_int, 1) else @as(c_int, 0);
    j2 = if (@bitCast(c_int, @as(c_uint, simplex[@intCast(c_uint, c)][@intCast(c_uint, @as(c_int, 1))])) >= @as(c_int, 2)) @as(c_int, 1) else @as(c_int, 0);
    k2 = if (@bitCast(c_int, @as(c_uint, simplex[@intCast(c_uint, c)][@intCast(c_uint, @as(c_int, 2))])) >= @as(c_int, 2)) @as(c_int, 1) else @as(c_int, 0);
    l2 = if (@bitCast(c_int, @as(c_uint, simplex[@intCast(c_uint, c)][@intCast(c_uint, @as(c_int, 3))])) >= @as(c_int, 2)) @as(c_int, 1) else @as(c_int, 0);
    @"i3" = if (@bitCast(c_int, @as(c_uint, simplex[@intCast(c_uint, c)][@intCast(c_uint, @as(c_int, 0))])) >= @as(c_int, 1)) @as(c_int, 1) else @as(c_int, 0);
    j3 = if (@bitCast(c_int, @as(c_uint, simplex[@intCast(c_uint, c)][@intCast(c_uint, @as(c_int, 1))])) >= @as(c_int, 1)) @as(c_int, 1) else @as(c_int, 0);
    k3 = if (@bitCast(c_int, @as(c_uint, simplex[@intCast(c_uint, c)][@intCast(c_uint, @as(c_int, 2))])) >= @as(c_int, 1)) @as(c_int, 1) else @as(c_int, 0);
    l3 = if (@bitCast(c_int, @as(c_uint, simplex[@intCast(c_uint, c)][@intCast(c_uint, @as(c_int, 3))])) >= @as(c_int, 1)) @as(c_int, 1) else @as(c_int, 0);
    var x1: f32 = @floatCast(f32, @floatCast(f64, x0 - @intToFloat(f32, @"i1")) + 0.138196601);
    var y1: f32 = @floatCast(f32, @floatCast(f64, y0 - @intToFloat(f32, j1)) + 0.138196601);
    var z1: f32 = @floatCast(f32, @floatCast(f64, z0 - @intToFloat(f32, k1)) + 0.138196601);
    var w1: f32 = @floatCast(f32, @floatCast(f64, w0 - @intToFloat(f32, l1)) + 0.138196601);
    var x2: f32 = @floatCast(f32, @floatCast(f64, x0 - @intToFloat(f32, @"i2")) + (@floatCast(f64, 2.0) * 0.138196601));
    var y2: f32 = @floatCast(f32, @floatCast(f64, y0 - @intToFloat(f32, j2)) + (@floatCast(f64, 2.0) * 0.138196601));
    var z2: f32 = @floatCast(f32, @floatCast(f64, z0 - @intToFloat(f32, k2)) + (@floatCast(f64, 2.0) * 0.138196601));
    var w2: f32 = @floatCast(f32, @floatCast(f64, w0 - @intToFloat(f32, l2)) + (@floatCast(f64, 2.0) * 0.138196601));
    var x3: f32 = @floatCast(f32, @floatCast(f64, x0 - @intToFloat(f32, @"i3")) + (@floatCast(f64, 3.0) * 0.138196601));
    var y3: f32 = @floatCast(f32, @floatCast(f64, y0 - @intToFloat(f32, j3)) + (@floatCast(f64, 3.0) * 0.138196601));
    var z3: f32 = @floatCast(f32, @floatCast(f64, z0 - @intToFloat(f32, k3)) + (@floatCast(f64, 3.0) * 0.138196601));
    var w3: f32 = @floatCast(f32, @floatCast(f64, w0 - @intToFloat(f32, l3)) + (@floatCast(f64, 3.0) * 0.138196601));
    var x4: f32 = @floatCast(f32, @floatCast(f64, x0 - 1.0) + (@floatCast(f64, 4.0) * 0.138196601));
    var y4: f32 = @floatCast(f32, @floatCast(f64, y0 - 1.0) + (@floatCast(f64, 4.0) * 0.138196601));
    var z4: f32 = @floatCast(f32, @floatCast(f64, z0 - 1.0) + (@floatCast(f64, 4.0) * 0.138196601));
    var w4: f32 = @floatCast(f32, @floatCast(f64, w0 - 1.0) + (@floatCast(f64, 4.0) * 0.138196601));
    var ii: c_int = i & @as(c_int, 255);
    var jj: c_int = j & @as(c_int, 255);
    var kk: c_int = k & @as(c_int, 255);
    var ll: c_int = l & @as(c_int, 255);
    var t0: f32 = (((0.5 - (x0 * x0)) - (y0 * y0)) - (z0 * z0)) - (w0 * w0);
    if (t0 < 0.0) {
        n0 = 0.0;
    } else {
        t0 *= t0;
        n0 = (t0 * t0) * grad4(@bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, ii + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, jj + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, kk + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, ll)])))])))])))])), x0, y0, z0, w0);
    }
    var t1: f32 = (((0.5 - (x1 * x1)) - (y1 * y1)) - (z1 * z1)) - (w1 * w1);
    if (t1 < 0.0) {
        n1 = 0.0;
    } else {
        t1 *= t1;
        n1 = (t1 * t1) * grad4(@bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (ii + @"i1") + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (jj + j1) + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (kk + k1) + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, ll + l1)])))])))])))])), x1, y1, z1, w1);
    }
    var t2: f32 = (((0.5 - (x2 * x2)) - (y2 * y2)) - (z2 * z2)) - (w2 * w2);
    if (t2 < 0.0) {
        n2 = 0.0;
    } else {
        t2 *= t2;
        n2 = (t2 * t2) * grad4(@bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (ii + @"i2") + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (jj + j2) + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (kk + k2) + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, ll + l2)])))])))])))])), x2, y2, z2, w2);
    }
    var t3: f32 = (((0.5 - (x3 * x3)) - (y3 * y3)) - (z3 * z3)) - (w3 * w3);
    if (t3 < 0.0) {
        n3 = 0.0;
    } else {
        t3 *= t3;
        n3 = (t3 * t3) * grad4(@bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (ii + @"i3") + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (jj + j3) + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (kk + k3) + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, ll + l3)])))])))])))])), x3, y3, z3, w3);
    }
    var t4: f32 = (((0.5 - (x4 * x4)) - (y4 * y4)) - (z4 * z4)) - (w4 * w4);
    if (t4 < 0.0) {
        n4 = 0.0;
    } else {
        t4 *= t4;
        n4 = (t4 * t4) * grad4(@bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (ii + @as(c_int, 1)) + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (jj + @as(c_int, 1)) + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, (kk + @as(c_int, 1)) + @bitCast(c_int, @as(c_uint, perm[@intCast(c_uint, ll + @as(c_int, 1))])))])))])))])), x4, y4, z4, w4);
    }
    return 62.0 * ((((n0 + n1) + n2) + n3) + n4);
}
pub var perm: [512]u8 = [512]u8{
    151,
    160,
    137,
    91,
    90,
    15,
    131,
    13,
    201,
    95,
    96,
    53,
    194,
    233,
    7,
    225,
    140,
    36,
    103,
    30,
    69,
    142,
    8,
    99,
    37,
    240,
    21,
    10,
    23,
    190,
    6,
    148,
    247,
    120,
    234,
    75,
    0,
    26,
    197,
    62,
    94,
    252,
    219,
    203,
    117,
    35,
    11,
    32,
    57,
    177,
    33,
    88,
    237,
    149,
    56,
    87,
    174,
    20,
    125,
    136,
    171,
    168,
    68,
    175,
    74,
    165,
    71,
    134,
    139,
    48,
    27,
    166,
    77,
    146,
    158,
    231,
    83,
    111,
    229,
    122,
    60,
    211,
    133,
    230,
    220,
    105,
    92,
    41,
    55,
    46,
    245,
    40,
    244,
    102,
    143,
    54,
    65,
    25,
    63,
    161,
    1,
    216,
    80,
    73,
    209,
    76,
    132,
    187,
    208,
    89,
    18,
    169,
    200,
    196,
    135,
    130,
    116,
    188,
    159,
    86,
    164,
    100,
    109,
    198,
    173,
    186,
    3,
    64,
    52,
    217,
    226,
    250,
    124,
    123,
    5,
    202,
    38,
    147,
    118,
    126,
    255,
    82,
    85,
    212,
    207,
    206,
    59,
    227,
    47,
    16,
    58,
    17,
    182,
    189,
    28,
    42,
    223,
    183,
    170,
    213,
    119,
    248,
    152,
    2,
    44,
    154,
    163,
    70,
    221,
    153,
    101,
    155,
    167,
    43,
    172,
    9,
    129,
    22,
    39,
    253,
    19,
    98,
    108,
    110,
    79,
    113,
    224,
    232,
    178,
    185,
    112,
    104,
    218,
    246,
    97,
    228,
    251,
    34,
    242,
    193,
    238,
    210,
    144,
    12,
    191,
    179,
    162,
    241,
    81,
    51,
    145,
    235,
    249,
    14,
    239,
    107,
    49,
    192,
    214,
    31,
    181,
    199,
    106,
    157,
    184,
    84,
    204,
    176,
    115,
    121,
    50,
    45,
    127,
    4,
    150,
    254,
    138,
    236,
    205,
    93,
    222,
    114,
    67,
    29,
    24,
    72,
    243,
    141,
    128,
    195,
    78,
    66,
    215,
    61,
    156,
    180,
    151,
    160,
    137,
    91,
    90,
    15,
    131,
    13,
    201,
    95,
    96,
    53,
    194,
    233,
    7,
    225,
    140,
    36,
    103,
    30,
    69,
    142,
    8,
    99,
    37,
    240,
    21,
    10,
    23,
    190,
    6,
    148,
    247,
    120,
    234,
    75,
    0,
    26,
    197,
    62,
    94,
    252,
    219,
    203,
    117,
    35,
    11,
    32,
    57,
    177,
    33,
    88,
    237,
    149,
    56,
    87,
    174,
    20,
    125,
    136,
    171,
    168,
    68,
    175,
    74,
    165,
    71,
    134,
    139,
    48,
    27,
    166,
    77,
    146,
    158,
    231,
    83,
    111,
    229,
    122,
    60,
    211,
    133,
    230,
    220,
    105,
    92,
    41,
    55,
    46,
    245,
    40,
    244,
    102,
    143,
    54,
    65,
    25,
    63,
    161,
    1,
    216,
    80,
    73,
    209,
    76,
    132,
    187,
    208,
    89,
    18,
    169,
    200,
    196,
    135,
    130,
    116,
    188,
    159,
    86,
    164,
    100,
    109,
    198,
    173,
    186,
    3,
    64,
    52,
    217,
    226,
    250,
    124,
    123,
    5,
    202,
    38,
    147,
    118,
    126,
    255,
    82,
    85,
    212,
    207,
    206,
    59,
    227,
    47,
    16,
    58,
    17,
    182,
    189,
    28,
    42,
    223,
    183,
    170,
    213,
    119,
    248,
    152,
    2,
    44,
    154,
    163,
    70,
    221,
    153,
    101,
    155,
    167,
    43,
    172,
    9,
    129,
    22,
    39,
    253,
    19,
    98,
    108,
    110,
    79,
    113,
    224,
    232,
    178,
    185,
    112,
    104,
    218,
    246,
    97,
    228,
    251,
    34,
    242,
    193,
    238,
    210,
    144,
    12,
    191,
    179,
    162,
    241,
    81,
    51,
    145,
    235,
    249,
    14,
    239,
    107,
    49,
    192,
    214,
    31,
    181,
    199,
    106,
    157,
    184,
    84,
    204,
    176,
    115,
    121,
    50,
    45,
    127,
    4,
    150,
    254,
    138,
    236,
    205,
    93,
    222,
    114,
    67,
    29,
    24,
    72,
    243,
    141,
    128,
    195,
    78,
    66,
    215,
    61,
    156,
    180,
};
pub fn grad1(arg_hash: c_int, arg_x: f32) f32 {
    var hash = arg_hash;
    var x = arg_x;
    var h: c_int = hash & @as(c_int, 15);
    var grad: f32 = 1.0 + @intToFloat(f32, h & @as(c_int, 7));
    if ((h & @as(c_int, 8)) != 0) {
        grad = -grad;
    }
    return grad * x;
}
pub fn grad2(arg_hash: c_int, arg_x: f32, arg_y: f32) f32 {
    var hash = arg_hash;
    var x = arg_x;
    var y = arg_y;
    var h: c_int = hash & @as(c_int, 7);
    var u: f32 = if (h < @as(c_int, 4)) x else y;
    var v: f32 = if (h < @as(c_int, 4)) y else x;
    return (if ((h & @as(c_int, 1)) != 0) -u else u) + (if ((h & @as(c_int, 2)) != 0) -2.0 * v else 2.0 * v);
}
pub fn grad3(arg_hash: c_int, arg_x: f32, arg_y: f32, arg_z: f32) f32 {
    var hash = arg_hash;
    var x = arg_x;
    var y = arg_y;
    var z = arg_z;
    var h: c_int = hash & @as(c_int, 15);
    var u: f32 = if (h < @as(c_int, 8)) x else y;
    var v: f32 = if (h < @as(c_int, 4)) y else if ((h == @as(c_int, 12)) or (h == @as(c_int, 14))) x else z;
    return (if ((h & @as(c_int, 1)) != 0) -u else u) + (if ((h & @as(c_int, 2)) != 0) -v else v);
}
pub fn grad4(arg_hash: c_int, arg_x: f32, arg_y: f32, arg_z: f32, arg_t: f32) f32 {
    var hash = arg_hash;
    var x = arg_x;
    var y = arg_y;
    var z = arg_z;
    var t = arg_t;
    var h: c_int = hash & @as(c_int, 31);
    var u: f32 = if (h < @as(c_int, 24)) x else y;
    var v: f32 = if (h < @as(c_int, 16)) y else z;
    var w: f32 = if (h < @as(c_int, 8)) z else t;
    return ((if ((h & @as(c_int, 1)) != 0) -u else u) + (if ((h & @as(c_int, 2)) != 0) -v else v)) + (if ((h & @as(c_int, 4)) != 0) -w else w);
}
pub var simplex: [64][4]u8 = [64][4]u8{
    [4]u8{
        0,
        1,
        2,
        3,
    },
    [4]u8{
        0,
        1,
        3,
        2,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        2,
        3,
        1,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        1,
        2,
        3,
        0,
    },
    [4]u8{
        0,
        2,
        1,
        3,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        3,
        1,
        2,
    },
    [4]u8{
        0,
        3,
        2,
        1,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        1,
        3,
        2,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        1,
        2,
        0,
        3,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        1,
        3,
        0,
        2,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        2,
        3,
        0,
        1,
    },
    [4]u8{
        2,
        3,
        1,
        0,
    },
    [4]u8{
        1,
        0,
        2,
        3,
    },
    [4]u8{
        1,
        0,
        3,
        2,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        2,
        0,
        3,
        1,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        2,
        1,
        3,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        2,
        0,
        1,
        3,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        3,
        0,
        1,
        2,
    },
    [4]u8{
        3,
        0,
        2,
        1,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        3,
        1,
        2,
        0,
    },
    [4]u8{
        2,
        1,
        0,
        3,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        3,
        1,
        0,
        2,
    },
    [4]u8{
        0,
        0,
        0,
        0,
    },
    [4]u8{
        3,
        2,
        0,
        1,
    },
    [4]u8{
        3,
        2,
        1,
        0,
    },
};
pub const __INTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `LL`"); // (no file):79:9
pub const __UINTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `ULL`"); // (no file):85:9
pub const __FLT16_DENORM_MIN__ = @compileError("unable to translate C expr: unexpected token 'IntegerLiteral'"); // (no file):108:9
pub const __FLT16_EPSILON__ = @compileError("unable to translate C expr: unexpected token 'IntegerLiteral'"); // (no file):112:9
pub const __FLT16_MAX__ = @compileError("unable to translate C expr: unexpected token 'IntegerLiteral'"); // (no file):118:9
pub const __FLT16_MIN__ = @compileError("unable to translate C expr: unexpected token 'IntegerLiteral'"); // (no file):121:9
pub const __INT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `LL`"); // (no file):183:9
pub const __UINT32_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `U`"); // (no file):205:9
pub const __UINT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `ULL`"); // (no file):213:9
pub const __seg_gs = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):341:9
pub const __seg_fs = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):342:9
pub const __declspec = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):401:9
pub const _cdecl = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):402:9
pub const __cdecl = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):403:9
pub const _stdcall = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):404:9
pub const __stdcall = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):405:9
pub const _fastcall = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):406:9
pub const __fastcall = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):407:9
pub const _thiscall = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):408:9
pub const __thiscall = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):409:9
pub const _pascal = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):410:9
pub const __pascal = @compileError("unable to translate macro: undefined identifier `__attribute__`"); // (no file):411:9
pub const __llvm__ = @as(c_int, 1);
pub const __clang__ = @as(c_int, 1);
pub const __clang_major__ = @as(c_int, 15);
pub const __clang_minor__ = @as(c_int, 0);
pub const __clang_patchlevel__ = @as(c_int, 3);
pub const __clang_version__ = "15.0.3 (https://github.com/ziglang/zig-bootstrap.git 340964d62c44e72d69c322bb9c85193dea55480f)";
pub const __GNUC__ = @as(c_int, 4);
pub const __GNUC_MINOR__ = @as(c_int, 2);
pub const __GNUC_PATCHLEVEL__ = @as(c_int, 1);
pub const __GXX_ABI_VERSION = @as(c_int, 1002);
pub const __ATOMIC_RELAXED = @as(c_int, 0);
pub const __ATOMIC_CONSUME = @as(c_int, 1);
pub const __ATOMIC_ACQUIRE = @as(c_int, 2);
pub const __ATOMIC_RELEASE = @as(c_int, 3);
pub const __ATOMIC_ACQ_REL = @as(c_int, 4);
pub const __ATOMIC_SEQ_CST = @as(c_int, 5);
pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = @as(c_int, 0);
pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = @as(c_int, 1);
pub const __OPENCL_MEMORY_SCOPE_DEVICE = @as(c_int, 2);
pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = @as(c_int, 3);
pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = @as(c_int, 4);
pub const __PRAGMA_REDEFINE_EXTNAME = @as(c_int, 1);
pub const __VERSION__ = "Clang 15.0.3 (https://github.com/ziglang/zig-bootstrap.git 340964d62c44e72d69c322bb9c85193dea55480f)";
pub const __OBJC_BOOL_IS_BOOL = @as(c_int, 0);
pub const __CONSTANT_CFSTRINGS__ = @as(c_int, 1);
pub const __SEH__ = @as(c_int, 1);
pub const __clang_literal_encoding__ = "UTF-8";
pub const __clang_wide_literal_encoding__ = "UTF-16";
pub const __ORDER_LITTLE_ENDIAN__ = @as(c_int, 1234);
pub const __ORDER_BIG_ENDIAN__ = @as(c_int, 4321);
pub const __ORDER_PDP_ENDIAN__ = @as(c_int, 3412);
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __LITTLE_ENDIAN__ = @as(c_int, 1);
pub const __CHAR_BIT__ = @as(c_int, 8);
pub const __BOOL_WIDTH__ = @as(c_int, 8);
pub const __SHRT_WIDTH__ = @as(c_int, 16);
pub const __INT_WIDTH__ = @as(c_int, 32);
pub const __LONG_WIDTH__ = @as(c_int, 32);
pub const __LLONG_WIDTH__ = @as(c_int, 64);
pub const __BITINT_MAXWIDTH__ = @as(c_int, 128);
pub const __SCHAR_MAX__ = @as(c_int, 127);
pub const __SHRT_MAX__ = @as(c_int, 32767);
pub const __INT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __LONG_MAX__ = @as(c_long, 2147483647);
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __WCHAR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __WCHAR_WIDTH__ = @as(c_int, 16);
pub const __WINT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __WINT_WIDTH__ = @as(c_int, 16);
pub const __INTMAX_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INTMAX_WIDTH__ = @as(c_int, 64);
pub const __SIZE_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __SIZE_WIDTH__ = @as(c_int, 64);
pub const __UINTMAX_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINTMAX_WIDTH__ = @as(c_int, 64);
pub const __PTRDIFF_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __PTRDIFF_WIDTH__ = @as(c_int, 64);
pub const __INTPTR_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INTPTR_WIDTH__ = @as(c_int, 64);
pub const __UINTPTR_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINTPTR_WIDTH__ = @as(c_int, 64);
pub const __SIZEOF_DOUBLE__ = @as(c_int, 8);
pub const __SIZEOF_FLOAT__ = @as(c_int, 4);
pub const __SIZEOF_INT__ = @as(c_int, 4);
pub const __SIZEOF_LONG__ = @as(c_int, 4);
pub const __SIZEOF_LONG_DOUBLE__ = @as(c_int, 16);
pub const __SIZEOF_LONG_LONG__ = @as(c_int, 8);
pub const __SIZEOF_POINTER__ = @as(c_int, 8);
pub const __SIZEOF_SHORT__ = @as(c_int, 2);
pub const __SIZEOF_PTRDIFF_T__ = @as(c_int, 8);
pub const __SIZEOF_SIZE_T__ = @as(c_int, 8);
pub const __SIZEOF_WCHAR_T__ = @as(c_int, 2);
pub const __SIZEOF_WINT_T__ = @as(c_int, 2);
pub const __SIZEOF_INT128__ = @as(c_int, 16);
pub const __INTMAX_TYPE__ = c_longlong;
pub const __INTMAX_FMTd__ = "lld";
pub const __INTMAX_FMTi__ = "lli";
pub const __UINTMAX_TYPE__ = c_ulonglong;
pub const __UINTMAX_FMTo__ = "llo";
pub const __UINTMAX_FMTu__ = "llu";
pub const __UINTMAX_FMTx__ = "llx";
pub const __UINTMAX_FMTX__ = "llX";
pub const __PTRDIFF_TYPE__ = c_longlong;
pub const __PTRDIFF_FMTd__ = "lld";
pub const __PTRDIFF_FMTi__ = "lli";
pub const __INTPTR_TYPE__ = c_longlong;
pub const __INTPTR_FMTd__ = "lld";
pub const __INTPTR_FMTi__ = "lli";
pub const __SIZE_TYPE__ = c_ulonglong;
pub const __SIZE_FMTo__ = "llo";
pub const __SIZE_FMTu__ = "llu";
pub const __SIZE_FMTx__ = "llx";
pub const __SIZE_FMTX__ = "llX";
pub const __WCHAR_TYPE__ = c_ushort;
pub const __WINT_TYPE__ = c_ushort;
pub const __SIG_ATOMIC_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __SIG_ATOMIC_WIDTH__ = @as(c_int, 32);
pub const __CHAR16_TYPE__ = c_ushort;
pub const __CHAR32_TYPE__ = c_uint;
pub const __UINTPTR_TYPE__ = c_ulonglong;
pub const __UINTPTR_FMTo__ = "llo";
pub const __UINTPTR_FMTu__ = "llu";
pub const __UINTPTR_FMTx__ = "llx";
pub const __UINTPTR_FMTX__ = "llX";
pub const __FLT16_HAS_DENORM__ = @as(c_int, 1);
pub const __FLT16_DIG__ = @as(c_int, 3);
pub const __FLT16_DECIMAL_DIG__ = @as(c_int, 5);
pub const __FLT16_HAS_INFINITY__ = @as(c_int, 1);
pub const __FLT16_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __FLT16_MANT_DIG__ = @as(c_int, 11);
pub const __FLT16_MAX_10_EXP__ = @as(c_int, 4);
pub const __FLT16_MAX_EXP__ = @as(c_int, 16);
pub const __FLT16_MIN_10_EXP__ = -@as(c_int, 4);
pub const __FLT16_MIN_EXP__ = -@as(c_int, 13);
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __FLT_HAS_DENORM__ = @as(c_int, 1);
pub const __FLT_DIG__ = @as(c_int, 6);
pub const __FLT_DECIMAL_DIG__ = @as(c_int, 9);
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __FLT_HAS_INFINITY__ = @as(c_int, 1);
pub const __FLT_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __FLT_MANT_DIG__ = @as(c_int, 24);
pub const __FLT_MAX_10_EXP__ = @as(c_int, 38);
pub const __FLT_MAX_EXP__ = @as(c_int, 128);
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_MIN_10_EXP__ = -@as(c_int, 37);
pub const __FLT_MIN_EXP__ = -@as(c_int, 125);
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __DBL_DENORM_MIN__ = @as(f64, 4.9406564584124654e-324);
pub const __DBL_HAS_DENORM__ = @as(c_int, 1);
pub const __DBL_DIG__ = @as(c_int, 15);
pub const __DBL_DECIMAL_DIG__ = @as(c_int, 17);
pub const __DBL_EPSILON__ = @as(f64, 2.2204460492503131e-16);
pub const __DBL_HAS_INFINITY__ = @as(c_int, 1);
pub const __DBL_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __DBL_MANT_DIG__ = @as(c_int, 53);
pub const __DBL_MAX_10_EXP__ = @as(c_int, 308);
pub const __DBL_MAX_EXP__ = @as(c_int, 1024);
pub const __DBL_MAX__ = @as(f64, 1.7976931348623157e+308);
pub const __DBL_MIN_10_EXP__ = -@as(c_int, 307);
pub const __DBL_MIN_EXP__ = -@as(c_int, 1021);
pub const __DBL_MIN__ = @as(f64, 2.2250738585072014e-308);
pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 3.64519953188247460253e-4951);
pub const __LDBL_HAS_DENORM__ = @as(c_int, 1);
pub const __LDBL_DIG__ = @as(c_int, 18);
pub const __LDBL_DECIMAL_DIG__ = @as(c_int, 21);
pub const __LDBL_EPSILON__ = @as(c_longdouble, 1.08420217248550443401e-19);
pub const __LDBL_HAS_INFINITY__ = @as(c_int, 1);
pub const __LDBL_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __LDBL_MANT_DIG__ = @as(c_int, 64);
pub const __LDBL_MAX_10_EXP__ = @as(c_int, 4932);
pub const __LDBL_MAX_EXP__ = @as(c_int, 16384);
pub const __LDBL_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
pub const __LDBL_MIN_10_EXP__ = -@as(c_int, 4931);
pub const __LDBL_MIN_EXP__ = -@as(c_int, 16381);
pub const __LDBL_MIN__ = @as(c_longdouble, 3.36210314311209350626e-4932);
pub const __POINTER_WIDTH__ = @as(c_int, 64);
pub const __BIGGEST_ALIGNMENT__ = @as(c_int, 16);
pub const __WCHAR_UNSIGNED__ = @as(c_int, 1);
pub const __WINT_UNSIGNED__ = @as(c_int, 1);
pub const __INT8_TYPE__ = i8;
pub const __INT8_FMTd__ = "hhd";
pub const __INT8_FMTi__ = "hhi";
pub const __INT8_C_SUFFIX__ = "";
pub const __INT16_TYPE__ = c_short;
pub const __INT16_FMTd__ = "hd";
pub const __INT16_FMTi__ = "hi";
pub const __INT16_C_SUFFIX__ = "";
pub const __INT32_TYPE__ = c_int;
pub const __INT32_FMTd__ = "d";
pub const __INT32_FMTi__ = "i";
pub const __INT32_C_SUFFIX__ = "";
pub const __INT64_TYPE__ = c_longlong;
pub const __INT64_FMTd__ = "lld";
pub const __INT64_FMTi__ = "lli";
pub const __UINT8_TYPE__ = u8;
pub const __UINT8_FMTo__ = "hho";
pub const __UINT8_FMTu__ = "hhu";
pub const __UINT8_FMTx__ = "hhx";
pub const __UINT8_FMTX__ = "hhX";
pub const __UINT8_C_SUFFIX__ = "";
pub const __UINT8_MAX__ = @as(c_int, 255);
pub const __INT8_MAX__ = @as(c_int, 127);
pub const __UINT16_TYPE__ = c_ushort;
pub const __UINT16_FMTo__ = "ho";
pub const __UINT16_FMTu__ = "hu";
pub const __UINT16_FMTx__ = "hx";
pub const __UINT16_FMTX__ = "hX";
pub const __UINT16_C_SUFFIX__ = "";
pub const __UINT16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __INT16_MAX__ = @as(c_int, 32767);
pub const __UINT32_TYPE__ = c_uint;
pub const __UINT32_FMTo__ = "o";
pub const __UINT32_FMTu__ = "u";
pub const __UINT32_FMTx__ = "x";
pub const __UINT32_FMTX__ = "X";
pub const __UINT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __INT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __UINT64_TYPE__ = c_ulonglong;
pub const __UINT64_FMTo__ = "llo";
pub const __UINT64_FMTu__ = "llu";
pub const __UINT64_FMTx__ = "llx";
pub const __UINT64_FMTX__ = "llX";
pub const __UINT64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __INT64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_LEAST8_TYPE__ = i8;
pub const __INT_LEAST8_MAX__ = @as(c_int, 127);
pub const __INT_LEAST8_WIDTH__ = @as(c_int, 8);
pub const __INT_LEAST8_FMTd__ = "hhd";
pub const __INT_LEAST8_FMTi__ = "hhi";
pub const __UINT_LEAST8_TYPE__ = u8;
pub const __UINT_LEAST8_MAX__ = @as(c_int, 255);
pub const __UINT_LEAST8_FMTo__ = "hho";
pub const __UINT_LEAST8_FMTu__ = "hhu";
pub const __UINT_LEAST8_FMTx__ = "hhx";
pub const __UINT_LEAST8_FMTX__ = "hhX";
pub const __INT_LEAST16_TYPE__ = c_short;
pub const __INT_LEAST16_MAX__ = @as(c_int, 32767);
pub const __INT_LEAST16_WIDTH__ = @as(c_int, 16);
pub const __INT_LEAST16_FMTd__ = "hd";
pub const __INT_LEAST16_FMTi__ = "hi";
pub const __UINT_LEAST16_TYPE__ = c_ushort;
pub const __UINT_LEAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __UINT_LEAST16_FMTo__ = "ho";
pub const __UINT_LEAST16_FMTu__ = "hu";
pub const __UINT_LEAST16_FMTx__ = "hx";
pub const __UINT_LEAST16_FMTX__ = "hX";
pub const __INT_LEAST32_TYPE__ = c_int;
pub const __INT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_LEAST32_WIDTH__ = @as(c_int, 32);
pub const __INT_LEAST32_FMTd__ = "d";
pub const __INT_LEAST32_FMTi__ = "i";
pub const __UINT_LEAST32_TYPE__ = c_uint;
pub const __UINT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __UINT_LEAST32_FMTo__ = "o";
pub const __UINT_LEAST32_FMTu__ = "u";
pub const __UINT_LEAST32_FMTx__ = "x";
pub const __UINT_LEAST32_FMTX__ = "X";
pub const __INT_LEAST64_TYPE__ = c_longlong;
pub const __INT_LEAST64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_LEAST64_WIDTH__ = @as(c_int, 64);
pub const __INT_LEAST64_FMTd__ = "lld";
pub const __INT_LEAST64_FMTi__ = "lli";
pub const __UINT_LEAST64_TYPE__ = c_ulonglong;
pub const __UINT_LEAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINT_LEAST64_FMTo__ = "llo";
pub const __UINT_LEAST64_FMTu__ = "llu";
pub const __UINT_LEAST64_FMTx__ = "llx";
pub const __UINT_LEAST64_FMTX__ = "llX";
pub const __INT_FAST8_TYPE__ = i8;
pub const __INT_FAST8_MAX__ = @as(c_int, 127);
pub const __INT_FAST8_WIDTH__ = @as(c_int, 8);
pub const __INT_FAST8_FMTd__ = "hhd";
pub const __INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST8_TYPE__ = u8;
pub const __UINT_FAST8_MAX__ = @as(c_int, 255);
pub const __UINT_FAST8_FMTo__ = "hho";
pub const __UINT_FAST8_FMTu__ = "hhu";
pub const __UINT_FAST8_FMTx__ = "hhx";
pub const __UINT_FAST8_FMTX__ = "hhX";
pub const __INT_FAST16_TYPE__ = c_short;
pub const __INT_FAST16_MAX__ = @as(c_int, 32767);
pub const __INT_FAST16_WIDTH__ = @as(c_int, 16);
pub const __INT_FAST16_FMTd__ = "hd";
pub const __INT_FAST16_FMTi__ = "hi";
pub const __UINT_FAST16_TYPE__ = c_ushort;
pub const __UINT_FAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __UINT_FAST16_FMTo__ = "ho";
pub const __UINT_FAST16_FMTu__ = "hu";
pub const __UINT_FAST16_FMTx__ = "hx";
pub const __UINT_FAST16_FMTX__ = "hX";
pub const __INT_FAST32_TYPE__ = c_int;
pub const __INT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_FAST32_WIDTH__ = @as(c_int, 32);
pub const __INT_FAST32_FMTd__ = "d";
pub const __INT_FAST32_FMTi__ = "i";
pub const __UINT_FAST32_TYPE__ = c_uint;
pub const __UINT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __UINT_FAST32_FMTo__ = "o";
pub const __UINT_FAST32_FMTu__ = "u";
pub const __UINT_FAST32_FMTx__ = "x";
pub const __UINT_FAST32_FMTX__ = "X";
pub const __INT_FAST64_TYPE__ = c_longlong;
pub const __INT_FAST64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_FAST64_WIDTH__ = @as(c_int, 64);
pub const __INT_FAST64_FMTd__ = "lld";
pub const __INT_FAST64_FMTi__ = "lli";
pub const __UINT_FAST64_TYPE__ = c_ulonglong;
pub const __UINT_FAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINT_FAST64_FMTo__ = "llo";
pub const __UINT_FAST64_FMTu__ = "llu";
pub const __UINT_FAST64_FMTx__ = "llx";
pub const __UINT_FAST64_FMTX__ = "llX";
pub const __USER_LABEL_PREFIX__ = "";
pub const __FINITE_MATH_ONLY__ = @as(c_int, 0);
pub const __GNUC_STDC_INLINE__ = @as(c_int, 1);
pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = @as(c_int, 1);
pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
pub const __NO_INLINE__ = @as(c_int, 1);
pub const __PIC__ = @as(c_int, 2);
pub const __pic__ = @as(c_int, 2);
pub const __FLT_RADIX__ = @as(c_int, 2);
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __GCC_ASM_FLAG_OUTPUTS__ = @as(c_int, 1);
pub const __code_model_small__ = @as(c_int, 1);
pub const __amd64__ = @as(c_int, 1);
pub const __amd64 = @as(c_int, 1);
pub const __x86_64 = @as(c_int, 1);
pub const __x86_64__ = @as(c_int, 1);
pub const __SEG_GS = @as(c_int, 1);
pub const __SEG_FS = @as(c_int, 1);
pub const __k8 = @as(c_int, 1);
pub const __k8__ = @as(c_int, 1);
pub const __tune_k8__ = @as(c_int, 1);
pub const __REGISTER_PREFIX__ = "";
pub const __NO_MATH_INLINES = @as(c_int, 1);
pub const __AES__ = @as(c_int, 1);
pub const __PCLMUL__ = @as(c_int, 1);
pub const __LAHF_SAHF__ = @as(c_int, 1);
pub const __LZCNT__ = @as(c_int, 1);
pub const __RDRND__ = @as(c_int, 1);
pub const __FSGSBASE__ = @as(c_int, 1);
pub const __BMI__ = @as(c_int, 1);
pub const __BMI2__ = @as(c_int, 1);
pub const __POPCNT__ = @as(c_int, 1);
pub const __PRFCHW__ = @as(c_int, 1);
pub const __RDSEED__ = @as(c_int, 1);
pub const __ADX__ = @as(c_int, 1);
pub const __MOVBE__ = @as(c_int, 1);
pub const __FMA__ = @as(c_int, 1);
pub const __F16C__ = @as(c_int, 1);
pub const __FXSR__ = @as(c_int, 1);
pub const __XSAVE__ = @as(c_int, 1);
pub const __XSAVEOPT__ = @as(c_int, 1);
pub const __XSAVEC__ = @as(c_int, 1);
pub const __XSAVES__ = @as(c_int, 1);
pub const __CLFLUSHOPT__ = @as(c_int, 1);
pub const __INVPCID__ = @as(c_int, 1);
pub const __AVX2__ = @as(c_int, 1);
pub const __AVX__ = @as(c_int, 1);
pub const __SSE4_2__ = @as(c_int, 1);
pub const __SSE4_1__ = @as(c_int, 1);
pub const __SSSE3__ = @as(c_int, 1);
pub const __SSE3__ = @as(c_int, 1);
pub const __SSE2__ = @as(c_int, 1);
pub const __SSE2_MATH__ = @as(c_int, 1);
pub const __SSE__ = @as(c_int, 1);
pub const __SSE_MATH__ = @as(c_int, 1);
pub const __MMX__ = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_16 = @as(c_int, 1);
pub const __SIZEOF_FLOAT128__ = @as(c_int, 16);
pub const _WIN32 = @as(c_int, 1);
pub const _WIN64 = @as(c_int, 1);
pub const WIN32 = @as(c_int, 1);
pub const __WIN32 = @as(c_int, 1);
pub const __WIN32__ = @as(c_int, 1);
pub const WINNT = @as(c_int, 1);
pub const __WINNT = @as(c_int, 1);
pub const __WINNT__ = @as(c_int, 1);
pub const WIN64 = @as(c_int, 1);
pub const __WIN64 = @as(c_int, 1);
pub const __WIN64__ = @as(c_int, 1);
pub const __MINGW64__ = @as(c_int, 1);
pub const __MSVCRT__ = @as(c_int, 1);
pub const __MINGW32__ = @as(c_int, 1);
pub const __STDC__ = @as(c_int, 1);
pub const __STDC_HOSTED__ = @as(c_int, 1);
pub const __STDC_VERSION__ = @as(c_long, 201710);
pub const __STDC_UTF_16__ = @as(c_int, 1);
pub const __STDC_UTF_32__ = @as(c_int, 1);
pub const _DEBUG = @as(c_int, 1);
pub inline fn FASTFLOOR(x: anytype) @TypeOf(if (@import("std").zig.c_translation.cast(c_int, x) <= x) @import("std").zig.c_translation.cast(c_int, x) else @import("std").zig.c_translation.cast(c_int, x) - @as(c_int, 1)) {
    return if (@import("std").zig.c_translation.cast(c_int, x) <= x) @import("std").zig.c_translation.cast(c_int, x) else @import("std").zig.c_translation.cast(c_int, x) - @as(c_int, 1);
}
pub const F2 = @as(f64, 0.366025403);
pub const G2 = @as(f64, 0.211324865);
pub const F3 = @as(f64, 0.333333333);
pub const G3 = @as(f64, 0.166666667);
pub const F4 = @as(f64, 0.309016994);
pub const G4 = @as(f64, 0.138196601);
