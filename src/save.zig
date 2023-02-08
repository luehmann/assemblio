const std = @import("std");
const root = @import("main");
const w4 = @import("wasm4");

const globals = root.globals;
const levels = root.levels;
const rng = root.rng;
const utils = root.utils;

const Direction = root.Direction;
const Item = root.Item;
const NodeType = root.nodes.NodeType;
const Reader = root.Reader;
const Writer = root.Writer;
const NodeId = root.NodeId;
const Network = root.Network;
const Level = root.Level;
const Node = root.nodes.Node;

pub fn deserialize(network: *Network) void {
    _ = w4.diskr(&globals.buffer, globals.buffer.len);
    var reader = Reader{};
    levels.level = reader.read(u8);
    if (levels.level == levels.levels.len) {
        rng.deserialize(&reader);
        levels.current_level = Level.deserialize(&reader);
    } else {
        levels.current_level = levels.levels[levels.level];
    }

    for (entries) |entry| {
        var count = reader.read(NodeId);
        while (count > 0) : (count -= 1) {
            const node = entry.deserialize(&reader);
            network.addNode(node);
        }
    }

    network.calculateConnections();
}

pub fn serialize(network: *const Network) void {
    var writer = Writer{};
    writer.write(levels.level);
    if (levels.level == levels.levels.len) {
        rng.serialize(&writer);
        levels.current_level.serialize(&writer);
    }

    for (entries) |entry| {
        entry.serialize(&writer, network.nodes);
    }
    const bytes_written = w4.diskw(&globals.buffer, writer.index);
    std.debug.assert(bytes_written == writer.index);
}

const Entry = struct {
    node_type: NodeType,
    direction: Direction,

    fn serialize(self: Entry, writer: *Writer, nodes: []const Node) void {
        const count = writer.reserve(NodeId);
        count.* = 0;
        for (nodes) |node| {
            if (node == self.node_type) {
                if (self.node_type == .hub or node.direction() == self.direction) {
                    count.* += 1;
                    node.serialize(writer);
                }
            }
        }
    }

    fn deserialize(self: Entry, reader: *Reader) Node {
        return self.node_type.deserialize(self.direction, reader);
    }
};

const entries = [_]Entry{
    .{
        .node_type = .belt,
        .direction = .north,
    },
    .{
        .node_type = .belt,
        .direction = .east,
    },
    .{
        .node_type = .belt,
        .direction = .south,
    },
    .{
        .node_type = .belt,
        .direction = .west,
    },
    .{
        .node_type = .tunnel,
        .direction = .north,
    },
    .{
        .node_type = .tunnel,
        .direction = .east,
    },
    .{
        .node_type = .tunnel,
        .direction = .south,
    },
    .{
        .node_type = .tunnel,
        .direction = .west,
    },
    .{
        .node_type = .miner,
        .direction = .north,
    },
    .{
        .node_type = .miner,
        .direction = .east,
    },
    .{
        .node_type = .miner,
        .direction = .south,
    },
    .{
        .node_type = .miner,
        .direction = .west,
    },
    .{
        .node_type = .cutter,
        .direction = .north,
    },
    .{
        .node_type = .cutter,
        .direction = .east,
    },
    .{
        .node_type = .cutter,
        .direction = .south,
    },
    .{
        .node_type = .cutter,
        .direction = .west,
    },
    .{
        .node_type = .merger,
        .direction = .north,
    },
    .{
        .node_type = .merger,
        .direction = .east,
    },
    .{
        .node_type = .merger,
        .direction = .south,
    },
    .{
        .node_type = .merger,
        .direction = .west,
    },
    .{
        .node_type = .rotator,
        .direction = .north,
    },
    .{
        .node_type = .rotator,
        .direction = .east,
    },
    .{
        .node_type = .rotator,
        .direction = .south,
    },
    .{
        .node_type = .rotator,
        .direction = .west,
    },
    .{
        .node_type = .hub,
        .direction = .north,
    },
};
