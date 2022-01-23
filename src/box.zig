//! small utils to draw all the box parts individually 
//! colors have to be set at the call site

const Vec2 = @import("vec.zig").Vec2;
const w4 = @import("wasm4.zig");

const box_wide_top_texture = [_]u8{
    0xff, 0xff,
    0x80, 0x01,
    0x80, 0x01,
    0x80, 0x01,
    0x80, 0x01,
    0x80, 0x01,
    0x80, 0x01,
    0xff, 0xff,
};

const box_tall_top_texture = [_]u8{
    0xff,
    0x81,
    0x81,
    0x81,
    0x81,
    0x81,
    0x81,
    0x81,
    0x81,
    0x81,
    0x81,
    0x81,
    0x81,
    0x81,
    0x81,
    0xff,
};

const box_top_texture = [_]u8{
    0xff,
    0x81,
    0x81,
    0x81,
    0x81,
    0x81,
    0x81,
    0xff,
};

pub fn renderFront(screen_pos: Vec2(i32)) void {
    w4.blitSub(&box_top_texture, screen_pos.x, screen_pos.y, 8, 3, 0, 1, 8, 0);
}

pub fn renderFrontLeft(screen_pos: Vec2(i32)) void {
    w4.blitSub(&box_wide_top_texture, screen_pos.x, screen_pos.y, 8, 3, 0, 1, 16, 0);
}
pub fn renderFrontRight(screen_pos: Vec2(i32)) void {
    w4.blitSub(&box_wide_top_texture, screen_pos.x, screen_pos.y, 8, 3, 8, 1, 16, 0);
}

pub fn renderTop(screen_pos: Vec2(i32)) void {
    w4.blit(&box_top_texture, screen_pos.x, screen_pos.y, 8, 8, 0);
}

pub fn renderTopWide(screen_pos: Vec2(i32)) void {
    w4.blit(&box_wide_top_texture, screen_pos.x, screen_pos.y, 16, 8, 0);
}

pub fn renderTopTall(screen_pos: Vec2(i32)) void {
    w4.blit(&box_tall_top_texture, screen_pos.x, screen_pos.y, 8, 16, 0);
}
