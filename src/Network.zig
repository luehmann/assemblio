const std = @import("std");
const root = @import("main");

const globals = root.globals;
const levels = root.levels;

const List = root.List;
const Node = root.nodes.Node;

pub const NodeId = u16;
pub const Connection = struct {
    from: NodeId,
    to: NodeId,
    output_index: u8,
};
pub const max_node_count = 500;

pub const AdvanceQueue = List(NodeId, max_node_count);

nodes: []Node,
connections: []Connection,
dead_ends: []NodeId,
alternating_sides_flag: bool = false,

const Network = @This();

pub fn calculateConnections(self: *Network) void {
    self.dead_ends.len = 0;
    self.connections.len = 0;
    for (self.nodes) |node, from| {
        var i: u8 = 0;
        const drop_off_point_count = node.dropOffPointCount();
        var targets_found: u8 = 0;
        drop_off_point_loop: while (i < drop_off_point_count) : (i += 1) {
            const drop_off_point = node.dropOffPoint(i);
            for (self.nodes) |potential_target_node, to| {
                if (!drop_off_point.isWithin(potential_target_node.boundingBox())) continue;
                if (!potential_target_node.canConnect(drop_off_point, node.direction())) continue;
                if (self.isLoop(@intCast(NodeId, from), @intCast(NodeId, to))) continue;

                self.addConnection(.{
                    .from = @intCast(NodeId, from),
                    .output_index = i,
                    .to = @intCast(NodeId, to),
                });
                targets_found += 1;
                continue :drop_off_point_loop;
            }
        }
        const dead_end_count = std.math.max(drop_off_point_count, 1);
        if (targets_found < dead_end_count) {
            var j: usize = 0;
            while (j < dead_end_count - targets_found) : (j += 1) {
                self.addDeadEnd(@intCast(NodeId, from));
            }
        }
    }
    // w4.trace(std.fmt.bufPrint(&globals.buffer, "{any} {any}", .{ globals.connections.toSlice(), globals.dead_ends.toSlice() }) catch unreachable);
}

test "calculateConnections" {
    const test_nodes = [_]Node{
        .{ .miner = .{ .pos = .{ .x = 0, .y = 0 }, .direction = .east, .item = .{} } },
        .{ .belt = .{ .pos = .{ .x = 1, .y = 0 }, .len = 5, .direction = .east } },
        .{ .hub = .{ .pos = .{ .x = 5, .y = 6 } } },
        .{ .belt = .{ .pos = .{ .x = 7, .y = 0 }, .len = 5, .direction = .south } },
    };
    var network_buffer: NetworkBuffer(test_nodes.len) = .{};
    var network: Network = network_buffer.getNetwork();
    network.addNodes(&test_nodes);
    network.calculateConnections();

    const expected_connections = [_]Connection{
        .{ .from = 0, .to = 1, .output_index = 0 },
        .{ .from = 1, .to = 3, .output_index = 0 },
        .{ .from = 3, .to = 2, .output_index = 0 },
    };
    const expected_dead_ends = [_]NodeId{
        2,
    };

    try std.testing.expectEqualSlices(Connection, &expected_connections, network.connections);
    try std.testing.expectEqualSlices(NodeId, &expected_dead_ends, network.dead_ends);
}

fn addConnection(self: *Network, connection: Connection) void {
    self.connections.ptr[self.connections.len] = connection;
    self.connections.len += 1;
}
fn addDeadEnd(self: *Network, node_id: NodeId) void {
    self.dead_ends.ptr[self.dead_ends.len] = node_id;
    self.dead_ends.len += 1;
}
fn addNodes(self: *Network, nodes: []const Node) void {
    // TODO: use memcopy
    for (nodes) |node| {
        self.addNode(node);
    }
}

pub fn addNode(self: *Network, node: Node) void {
    self.nodes.ptr[self.nodes.len] = node;
    self.nodes.len += 1;
}

pub fn removeNode(self: *Network, node_id: NodeId) void {
    self.nodes[node_id] = self.nodes[self.nodes.len - 1];
    self.nodes.len -= 1;
}

fn isLoop(self: *Network, current: NodeId, to: NodeId) bool {
    for (self.connections) |connection| {
        if (connection.from == to) {
            if (current == connection.to) return true;
            if (self.isLoop(current, connection.to)) {
                return true;
            }
        }
    }
    return false;
}

pub fn advance(self: *Network) void {
    var advance_queue = AdvanceQueue{};
    advance_queue.appendSlice(self.dead_ends);
    while (advance_queue.pop()) |node_id| {
        self.nodes[node_id].advance(self, node_id, &advance_queue);
    }
    self.alternating_sides_flag = !self.alternating_sides_flag;
    if (levels.level == levels.levels.len) {
        const items_collected = @intToFloat(f64, globals.active_count);
        const seconds_per_tick = 0.8;
        const rate = items_collected / seconds_per_tick;

        globals.rate = @floatToInt(u16, @floor(rate));
        globals.active_count = 0;
    }
}

pub fn getFlag(node_id: NodeId) bool {
    return node_id >> 15 == 1;
}

pub fn NetworkBuffer(comptime node_count: comptime_int) type {
    return struct {
        nodes: [node_count]Node = undefined,
        connections: [node_count * 2]Connection = undefined,
        dead_ends: [node_count * 2]NodeId = undefined,

        const Self = @This();

        pub fn getNetwork(self: *Self) Network {
            return .{
                .nodes = self.nodes[0..0],
                .connections = self.connections[0..0],
                .dead_ends = self.dead_ends[0..0],
            };
        }
    };
}
