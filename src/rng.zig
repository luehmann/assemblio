const root = @import("main");

const globals = root.globals;

const Item = root.Item;
const Network = root.Network;
const Reader = root.Reader;
const Writer = root.Writer;

pub var x: u8 = 0; // seeded by mouse x at unlock
pub var y: u8 = 0; // seeded by mouse y at unlock
pub var z: u8 = 0; // seeded by building count at unlock
pub var a: u8 = 0; // seeded by t at unlock

pub fn setSeed(network: *const Network) void {
    x = @intCast(u8, network.connections.len & 0xff);
    y = @intCast(u8, network.dead_ends.len & 0xff);
    z = @intCast(u8, network.nodes.len);
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
    return (randomByte() & 0b111) + 2;
}

pub fn serialize(writer: *Writer) void {
    writer.write(x);
    writer.write(y);
    writer.write(z);
    writer.write(a);
}

pub fn deserialize(reader: *Reader) void {
    x = reader.read(u8);
    y = reader.read(u8);
    z = reader.read(u8);
    a = reader.read(u8);
}
