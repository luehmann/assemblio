const Item = @import("item.zig").Item;
const rng = @import("rng.zig");
const globals = @import("globals.zig");

pub var level: u8 = undefined;
pub var current_level: Level = undefined;

pub const Level = struct {
    item: Item,
    amount: u16,
    border_size: i8,
};

pub fn nextLevel() void {
    globals.active_count = 0;
    globals.ticks_since_counting = 0;
    if (level < levels.len) {
        level += 1;
        if (level == levels.len) {
            rng.setSeed();
            current_level = getRandomLevel();
        } else {
            current_level = levels[level];
        }
    } else {
        current_level = getRandomLevel();
        globals.rate = null;
    }
}

fn getRandomLevel() Level {
    return Level{
        .item = rng.randomItem(),
        .amount = rng.getRandomRate(),
        .border_size = 0,
    };
}

pub const levels = [_]Level{
    .{
        .item = Item.ring,
        .amount = 100,
        .border_size = 30 * 4,
    },
    .{
        .item = Item{ .top_right = .ring, .bottom_right = .ring },
        .amount = 50,
        .border_size = 29 * 4,
    },
    .{
        .item = Item{ .bottom_left = .ring, .bottom_right = .ring },
        .amount = 200,
        .border_size = 28 * 4,
    },
    .{
        .item = Item{ .bottom_right = .ring },
        .amount = 400,
        .border_size = 28 * 4,
    },
    .{
        .item = Item.square,
        .amount = 100,
        .border_size = 27 * 4,
    },
    .{
        .item = Item{ .top_right = .square, .bottom_right = .square },
        .amount = 200,
        .border_size = 27 * 4,
    },
    .{
        .item = Item{ .top_left = .ring, .bottom_left = .ring, .top_right = .square, .bottom_right = .square },
        .amount = 100,
        .border_size = 27 * 4,
    },
    .{
        .item = Item.circle,
        .amount = 100,
        .border_size = 26 * 4,
    },
    .{
        .item = Item{ .bottom_left = .circle, .top_right = .circle },
        .amount = 100,
        .border_size = 24 * 4,
    },
    .{
        .item = Item{ .bottom_left = .circle, .bottom_right = .square },
        .amount = 200,
        .border_size = 22 * 4,
    },
    .{
        .item = Item{ .top_left = .ring, .bottom_left = .circle, .top_right = .circle, .bottom_right = .ring },
        .amount = 500,
        .border_size = 22 * 4,
    },
};
