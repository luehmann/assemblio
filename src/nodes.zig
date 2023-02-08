const std = @import("std");
const root = @import("main");
const w4 = @import("wasm4");

const globals = root.globals;
const utils = root.utils;

const Direction = root.Direction;
const Item = root.Item;
const OnScreenNodes = root.OnScreenNodes;
const Reader = root.Reader;
const Rect = root.Rect;
const Vec2 = root.Vec2;
const Writer = root.Writer;
const Network = root.Network;

pub const Belt = @import("nodes/Belt.zig");
pub const Tunnel = @import("nodes/Tunnel.zig");
pub const Miner = @import("nodes/Miner.zig");
pub const Merger = @import("nodes/Merger.zig");
pub const Cutter = @import("nodes/Cutter.zig");
pub const Rotator = @import("nodes/Rotator.zig");
pub const Hub = @import("nodes/Hub.zig");
pub const Trash = @import("nodes/Trash.zig");

const NodeId = root.Network.NodeId;

pub const NodeType = enum {
    belt,
    tunnel,
    miner,
    cutter,
    merger,
    rotator,
    hub,
    trash,

    pub fn deserialize(self: NodeType, direction: Direction, reader: *Reader) Node {
        return switch (self) {
            .belt => .{ .belt = Belt.deserialize(direction, reader) },
            .tunnel => .{ .tunnel = Tunnel.deserialize(direction, reader) },
            .miner => .{ .miner = Miner.deserialize(direction, reader) },
            .cutter => .{ .cutter = Cutter.deserialize(direction, reader) },
            .merger => .{ .merger = Merger.deserialize(direction, reader) },
            .rotator => .{ .rotator = Rotator.deserialize(direction, reader) },
            .hub => .{ .hub = Hub.deserialize(reader) },
            .trash => unreachable,
        };
    }
};

comptime {
    if (false) {
        @compileLog("Belt", @sizeOf(Belt));
        @compileLog("Tunnel", @sizeOf(Tunnel));
        @compileLog("Miner", @sizeOf(Miner));
        @compileLog("Cutter", @sizeOf(Cutter));
        @compileLog("Merger", @sizeOf(Merger));
        @compileLog("Rotator", @sizeOf(Rotator));
        @compileLog("Hub", @sizeOf(Hub));
        @compileLog("Node", @sizeOf(Node));
    }
}

pub const Node = union(NodeType) {
    belt: Belt,
    tunnel: Tunnel,
    miner: Miner,
    cutter: Cutter,
    merger: Merger,
    rotator: Rotator,
    hub: Hub,
    trash: Trash,

    pub fn boundingBox(self: *const Node) Rect(i32) {
        return switch (self.*) {
            .belt => self.belt.boundingBox(),
            .tunnel => self.tunnel.boundingBox(), // TODO: this is not correct
            .miner => self.miner.boundingBox(),
            .cutter => self.cutter.boundingBox(),
            .merger => self.merger.boundingBox(),
            .rotator => self.rotator.boundingBox(),
            .hub => self.hub.boundingBox(),
            .trash => self.trash.boundingBox(),
        };
    }

    pub fn intersects(self: *const Node, rect: Rect(i32)) bool {
        return switch (self.*) {
            .tunnel => self.tunnel.intersects(rect),
            else => self.boundingBox().intersects(rect),
        };
    }

    /// Returns the intersected bounding box of the node
    /// Note: This does not return the area of the intersection
    pub fn getIntersection(self: *const Node, bounding_box: Rect(i32)) ?Rect(i32) {
        return switch (self.*) {
            .tunnel => self.tunnel.getIntersection(bounding_box),
            else => if (self.boundingBox().intersects(bounding_box)) self.boundingBox() else null,
        };
    }

    pub fn checkOnScreen(self: *const Node, on_screen_nodes: *OnScreenNodes, screen_box: Rect(i32), node_id: NodeId) void {
        switch (self.*) {
            .tunnel => self.tunnel.checkOnScreen(on_screen_nodes, screen_box, node_id),
            else => {
                const bounding_box = self.boundingBox();
                if (screen_box.intersects(bounding_box)) {
                    on_screen_nodes.addToBucket(bounding_box.min.y, node_id);
                }
            },
        }
    }

    pub fn renderBelts(self: *const Node, is_wireframe: bool) void {
        switch (self.*) {
            .belt => self.belt.renderBelts(is_wireframe),
            .tunnel => self.tunnel.renderBelts(is_wireframe),
            .miner => self.miner.renderBelts(is_wireframe),
            .cutter => self.cutter.renderBelts(is_wireframe),
            .merger => self.merger.renderBelts(is_wireframe),
            .rotator => self.rotator.renderBelts(is_wireframe),
            .hub => self.hub.renderBelts(is_wireframe),
            .trash => {},
        }
    }

    pub fn renderItems(self: *const Node) void {
        w4.draw_colors.* = 0x30;
        switch (self.*) {
            .belt => self.belt.renderItems(),
            .tunnel => self.tunnel.renderItems(),
            .miner => {},
            .cutter => self.cutter.renderItems(),
            .merger => self.merger.renderItems(),
            .rotator => self.rotator.renderItems(),
            .hub => self.hub.renderItems(),
            .trash => {},
        }
    }

    pub fn renderStructure(self: *const Node, is_wireframe: bool, is_exit: bool) void {
        switch (self.*) {
            .miner => self.miner.renderStructure(is_wireframe),
            .tunnel => self.tunnel.renderStructure(is_wireframe, is_exit),
            .cutter => self.cutter.renderStructure(is_wireframe),
            .merger => self.merger.renderStructure(is_wireframe),
            .rotator => self.rotator.renderStructure(is_wireframe),
            .hub => self.hub.renderStructure(is_wireframe),
            else => {},
        }
    }

    pub fn advance(self: *Node, network: *Network, id: NodeId, advance_queue: *Network.AdvanceQueue) void {
        switch (self.*) {
            .miner => {},
            inline else => |*node| node.advance(network, id, advance_queue),
        }
    }

    /// Note: Only defined for nodes with dropOffPointCount > 0
    pub fn dropOffPoint(self: *const Node, output_index: u8) Vec2(i32) {
        return switch (self.*) {
            .belt => self.belt.dropOffPoint(),
            .tunnel => self.tunnel.dropOffPoint(),
            .miner => self.miner.dropOffPoint(),
            .cutter => self.cutter.dropOffPoint(output_index),
            .merger => self.merger.dropOffPoint(),
            .rotator => self.rotator.dropOffPoint(),
            .hub, .trash => unreachable,
        };
    }

    pub fn dropOffPointCount(self: Node) u8 {
        return switch (self) {
            .hub, .trash => 0,
            .belt, .tunnel, .miner, .merger, .rotator => 1,
            .cutter => 2,
        };
    }

    pub fn outputItem(self: *const Node, output_index: u8) Item {
        return switch (self.*) {
            .belt => self.belt.outputItem(),
            .tunnel => self.tunnel.outputItem(),
            .miner => self.miner.outputItem(),
            .cutter => self.cutter.outputItem(output_index),
            .merger => self.merger.outputItem(),
            .rotator => self.rotator.outputItem(),
            .hub, .trash => unreachable,
        };
    }

    /// Note: Only defined for nodes with output
    pub fn takeItem(self: *Node, output_index: u8) void {
        return switch (self.*) {
            .belt => self.belt.takeItem(),
            .tunnel => self.tunnel.takeItem(),
            .miner => {},
            .cutter => self.cutter.takeItem(output_index),
            .merger => self.merger.takeItem(),
            .rotator => self.rotator.takeItem(),
            .hub, .trash => unreachable,
        };
    }

    /// Note: Only defined for nodes with output
    pub fn direction(self: Node) Direction {
        return switch (self) {
            .belt => self.belt.direction,
            .tunnel => self.tunnel.direction,
            .miner => self.miner.direction,
            .cutter => self.cutter.direction,
            .merger => self.merger.direction,
            .rotator => self.rotator.direction,
            .hub, .trash => unreachable,
        };
    }

    pub fn canConnect(self: *const Node, pos: Vec2(i32), direction_from: Direction) bool {
        return switch (self.*) {
            .belt => self.belt.canConnect(direction_from),
            .tunnel => self.tunnel.canConnect(pos, direction_from),
            .miner => false,
            .cutter => self.cutter.canConnect(pos, direction_from),
            .merger => self.merger.canConnect(pos, direction_from),
            .rotator => self.rotator.canConnect(pos, direction_from),
            .hub => self.hub.canConnect(pos),
            .trash => true,
        };
    }

    pub fn rotate(self: *Node) ?Direction {
        return switch (self.*) {
            .hub, .trash => null,
            inline .belt, .tunnel, .miner, .cutter, .merger, .rotator => |*node| node.rotate(),
        };
    }

    pub fn renderSelection(self: *const Node) void {
        switch (self.*) {
            .tunnel => self.tunnel.renderSelection(),
            else => utils.renderSelection(self.boundingBox()),
        }
    }

    pub fn renderInputsAndOutputs(self: *const Node, network: *const Network) void {
        switch (self.*) {
            .belt => {},
            .tunnel => self.tunnel.renderInputsAndOutputs(network),
            .miner => self.miner.renderInputsAndOutputs(network),
            .cutter => self.cutter.renderInputsAndOutputs(network),
            .merger => self.merger.renderInputsAndOutputs(network),
            .rotator => self.rotator.renderInputsAndOutputs(network),
            .hub => self.hub.renderInputsAndOutputs(network),
            .trash => {},
        }
    }

    pub fn isElevated(self: Node) bool {
        return switch (self) {
            .belt, .hub => false,
            else => true,
        };
    }

    pub fn serialize(self: *const Node, writer: *Writer) void {
        return switch (self.*) {
            .belt => self.belt.serialize(writer),
            .tunnel => self.tunnel.serialize(writer),
            .miner => self.miner.serialize(writer),
            .cutter => self.cutter.serialize(writer),
            .merger => self.merger.serialize(writer),
            .rotator => self.rotator.serialize(writer),
            .hub => self.hub.serialize(writer),
            .trash => unreachable,
        };
    }

    pub fn cost(self: Node) u32 {
        return switch (self) {
            .miner,
            .cutter,
            .merger,
            .hub,
            => 2,
            .belt,
            .tunnel,
            .rotator,
            => 3,
            .trash => unreachable,
        };
    }

    pub fn placeOnMouseDown(self: Node) bool {
        return switch (self) {
            .belt, .tunnel, .rotator => false,
            else => true,
        };
    }
};
