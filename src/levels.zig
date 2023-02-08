const root = @import("main");

const rng = root.rng;
const globals = root.globals;

const Item = root.Item;
const Network = root.Network;
const Reader = root.Reader;
const Writer = root.Writer;

pub var level: u8 = undefined;
pub var current_level: Level = undefined;

pub const Level = struct {
    item: Item,
    amount: u16,
    border_size: i8,

    pub fn serialize(self: Level, writer: *Writer) void {
        writer.write(self.item);
        writer.write(@intCast(u8, self.amount));
    }

    pub fn deserialize(reader: *Reader) Level {
        const item = reader.read(Item);
        const rate = reader.read(u8);
        return .{
            .item = item,
            .amount = rate,
            .border_size = 0,
        };
    }
};

pub fn nextLevel(network: *const Network) void {
    globals.active_count = 0;
    if (level < levels.len) {
        level += 1;
        if (level == levels.len) {
            rng.setSeed(network);
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
        .item = Item.new("RRRR"),
        .amount = 100,
        .border_size = 30 * 4,
    },
    .{
        .item = Item.new("RR--"),
        .amount = 50,
        .border_size = 29 * 4,
    },
    .{
        .item = Item.new("-RR-"),
        .amount = 200,
        .border_size = 28 * 4,
    },
    .{
        .item = Item.new("-R--"),
        .amount = 400,
        .border_size = 28 * 4,
    },
    .{
        .item = Item.new("SSSS"),
        .amount = 100,
        .border_size = 27 * 4,
    },
    .{
        .item = Item.new("SS--"),
        .amount = 200,
        .border_size = 27 * 4,
    },
    .{
        .item = Item.new("SSRR"),
        .amount = 100,
        .border_size = 27 * 4,
    },
    .{
        .item = Item.new("CCCC"),
        .amount = 100,
        .border_size = 26 * 4,
    },
    .{
        .item = Item.new("C-C-"),
        .amount = 100,
        .border_size = 24 * 4,
    },
    .{
        .item = Item.new("-SC-"),
        .amount = 200,
        .border_size = 22 * 4,
    },
    .{
        .item = Item.new("CRCR"),
        .amount = 500,
        .border_size = 22 * 4,
    },
};
