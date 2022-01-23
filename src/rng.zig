const Item = @import("item.zig").Item;
const globals = @import("globals.zig");

pub var x: u8 = 0; // seeded by mouse x at unlock
pub var y: u8 = 0; // seeded by mouse y at unlock
pub var z: u8 = 0; // seeded by building count at unlock
pub var a: u8 = 0; // seeded by t at unlock

pub fn setSeed() void {
    x = @intCast(u8, globals.connections.len & 0xff);
    y = @intCast(u8, globals.dead_ends.len & 0xff);
    z = @intCast(u8, globals.nodes.len);
    a = @intCast(u8, globals.t & 0xff);
}

fn randomByte() u8 {
    const t = x ^ (x << 4);
    x = y;
    y = z;
    z = a;
    a = z ^ t ^ (z >> 1) ^ (t << 1);
    return a;
}

pub fn randomItem() Item {
    var item = Item.empty;
    while (item.eql(Item.empty)) {
        item = @bitCast(Item, randomByte());
    }
    return item;
}

pub fn getRandomRate() u8 {
    var res: u8 = 255;
    const min = 2;
    const max = 10;
    while (res > max or res < min) {
        res = randomByte();
    }
    return res;
}
