const std = @import("std");
const root = @import("main");

const globals = root.globals;

const Vec2 = root.Vec2;
const Rect = root.Rect;
const NodeId = root.NodeId;
const Item = root.Item;
const Network = root.Network;

pos: Vec2(i8),

const Self = @This();

pub fn boundingBox(self: Self) Rect(i32) {
    return Rect(i32).fromPoint(self.pos.as(i32));
}

pub fn advance(_: *Self, network: *Network, node_id: NodeId, advance_queue: *Network.AdvanceQueue) void {
    for (network.connections) |connection| {
        if (connection.to != node_id) continue;
        const node = &network.nodes[connection.from];

        const output_item = node.outputItem(connection.output_index);
        if (!output_item.eql(Item.empty)) {
            node.takeItem(connection.output_index);
        }

        advance_queue.append(connection.from);
    }
}
