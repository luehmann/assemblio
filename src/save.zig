const globals = @import("globals.zig");
const utils = @import("utils.zig");
const w4 = @import("wasm4.zig");
const levels = @import("levels.zig");
const rng = @import("rng.zig");
const NodeType = @import("nodes.zig").NodeType;
const Direction = @import("direction.zig").Direction;
const std = @import("std");
const Writer = @import("Writer.zig");
const Reader = @import("Reader.zig");
const Item = @import("item.zig").Item;

pub fn deserialize() void {
    _ = w4.diskr(@ptrCast([*]u8, &globals.buffer), globals.buffer.len);
    var reader = Reader{};
    levels.level = reader.readByte();
    if (levels.level == levels.levels.len) {
        rng.x = reader.readByte();
        rng.y = reader.readByte();
        rng.z = reader.readByte();
        rng.a = reader.readByte();
        const item = @bitCast(Item, reader.readByte());
        const rate = reader.readByte();
        levels.current_level = .{
            .item = item,
            .amount = rate,
            .border_size = 0,
        };
    } else {
        levels.current_level = levels.levels[levels.level];
    }

    for (entries) |entry| {
        var count = reader.readByte();
        while (count > 0) : (count -= 1) {
            const node = entry.node_type.deserialize(entry.direction, &reader);
            globals.nodes.add(node);
        }
    }

    utils.recalculateConnectionsAndDeadEnds();
}

pub fn serialize() void {
    var writer = Writer{};
    writer.writeByte(levels.level);
    if (levels.level == levels.levels.len) {
        writer.writeByte(rng.x);
        writer.writeByte(rng.y);
        writer.writeByte(rng.z);
        writer.writeByte(rng.a);
        writer.writeByte(@bitCast(u8, levels.current_level.item));
        writer.writeByte(@intCast(u8, levels.current_level.amount));
    }

    for (entries) |entry| {
        entry.serialize(&writer);
    }
    _ = w4.diskw(@ptrCast([*]u8, &globals.buffer), writer.index);
}

const Entry = struct {
    node_type: NodeType,
    direction: Direction,

    fn serialize(self: Entry, writer: *Writer) void {
        const count = writer.writeByteLater();
        count.* = 0;
        for (globals.nodes.toSlice()) |node| {
            if (node == self.node_type) {
                if (self.node_type == .hub or node.direction() == self.direction) {
                    count.* += 1;
                    node.serialize(writer);
                }
            }
        }
    }

    fn deserialize(self: Entry) void {
        _ = self;
    }
};

const entries = [_]Entry{ .{
    .node_type = .belt,
    .direction = .north,
}, .{
    .node_type = .belt,
    .direction = .east,
}, .{
    .node_type = .belt,
    .direction = .south,
}, .{
    .node_type = .belt,
    .direction = .west,
}, .{
    .node_type = .miner,
    .direction = .north,
}, .{
    .node_type = .miner,
    .direction = .east,
}, .{
    .node_type = .miner,
    .direction = .south,
}, .{
    .node_type = .miner,
    .direction = .west,
}, .{
    .node_type = .cutter,
    .direction = .north,
}, .{
    .node_type = .cutter,
    .direction = .east,
}, .{
    .node_type = .cutter,
    .direction = .south,
}, .{
    .node_type = .cutter,
    .direction = .west,
}, .{
    .node_type = .merger,
    .direction = .north,
}, .{
    .node_type = .merger,
    .direction = .east,
}, .{
    .node_type = .merger,
    .direction = .south,
}, .{
    .node_type = .merger,
    .direction = .west,
}, .{
    .node_type = .rotator,
    .direction = .north,
}, .{
    .node_type = .rotator,
    .direction = .east,
}, .{
    .node_type = .rotator,
    .direction = .south,
}, .{
    .node_type = .rotator,
    .direction = .west,
}, .{
    .node_type = .hub,
    .direction = .north,
} };
