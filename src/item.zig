const w4 = @import("wasm4.zig");
const std = @import("std");

pub const Shard = enum(u2) {
    air,
    square,
    ring,
    circle,
};

pub const Item = packed struct {
    top_right: Shard = .air,
    bottom_right: Shard = .air,
    bottom_left: Shard = .air,
    top_left: Shard = .air,

    pub fn rotateClockwise(self: Item) Item {
        return .{
            .top_right = self.top_left,
            .bottom_right = self.top_right,
            .bottom_left = self.bottom_right,
            .top_left = self.bottom_left,
        };
    }

    pub fn render(self: Item, x: i32, y: i32) void {
        w4.blitSub(&texture_data, x + 2, y, 2, 2, @as(u32, @enumToInt(self.top_right)) * 2, 0, 8, 0);
        w4.blitSub(&texture_data, x + 2, y + 2, 2, 2, @as(u32, @enumToInt(self.bottom_right)) * 2, 0, 8, w4.BLIT_FLIP_Y);
        w4.blitSub(&texture_data, x, y + 2, 2, 2, @as(u32, @enumToInt(self.bottom_left)) * 2, 0, 8, w4.BLIT_FLIP_X | w4.BLIT_FLIP_Y);
        w4.blitSub(&texture_data, x, y, 2, 2, @as(u32, @enumToInt(self.top_left)) * 2, 0, 8, w4.BLIT_FLIP_X);
    }

    pub fn renderBig(self: Item, x: i32, y: i32) void {
        w4.blitSub(&texture_data_big, x + 4, y, 4, 4, @as(u32, @enumToInt(self.top_right)) * 4, 0, 16, 0);
        w4.blitSub(&texture_data_big, x + 4, y + 4, 4, 4, @as(u32, @enumToInt(self.bottom_right)) * 4, 0, 16, w4.BLIT_FLIP_Y);
        w4.blitSub(&texture_data_big, x, y + 4, 4, 4, @as(u32, @enumToInt(self.bottom_left)) * 4, 0, 16, w4.BLIT_FLIP_X | w4.BLIT_FLIP_Y);
        w4.blitSub(&texture_data_big, x, y, 4, 4, @as(u32, @enumToInt(self.top_left)) * 4, 0, 16, w4.BLIT_FLIP_X);
    }

    pub const empty = Item{};
    pub const ring = baseItem(.ring);
    pub const circle = baseItem(.circle);
    pub const square = baseItem(.square);

    fn baseItem(shard: Shard) Item {
        return Item{
            .top_right = shard,
            .bottom_right = shard,
            .bottom_left = shard,
            .top_left = shard,
        };
    }

    pub fn eql(a: Item, b: Item) bool {
        return @bitCast(u8, a) == @bitCast(u8, b);
    }

    pub fn leftHalf(self: Item) Item {
        return @bitCast(Item, @bitCast(u8, self) & 0xf0);
    }
    pub fn rightHalf(self: Item) Item {
        return @bitCast(Item, @bitCast(u8, self) & 0x0f);
    }

    pub fn isValidLeftHalf(self: Item) bool {
        const left_half = @bitCast(u8, self) & 0xf0;
        const right_half = @bitCast(u8, self) & 0x0f;
        return left_half != 0 and right_half == 0;
    }

    pub fn isValidRightHalf(self: Item) bool {
        const left_half = @bitCast(u8, self) & 0xf0;
        const right_half = @bitCast(u8, self) & 0x0f;
        return left_half == 0 and right_half != 0;
    }

    pub fn merge(left: Item, right: Item) Item {
        std.debug.assert(left.isValidLeftHalf());
        std.debug.assert(right.isValidRightHalf());
        return @bitCast(Item, @bitCast(u8, left) | @bitCast(u8, right));
    }
};

const texture_data = [2]u8{
    0b00111110,
    0b00110111,
};

const texture_data_big = [_]u8{
    0b00001111, 0b11111100,
    0b00001111, 0b11111100,
    0b00001111, 0b00111111,
    0b00001111, 0b00111111,
};
