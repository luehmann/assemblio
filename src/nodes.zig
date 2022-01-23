const std = @import("std");

const BoundingBox = @import("bounding_box.zig").BoundingBox;
const Item = @import("item.zig").Item;
const Direction = @import("direction.zig").Direction;
const Vec2 = @import("vec.zig").Vec2;
const utils = @import("utils.zig");
const w4 = @import("wasm4.zig");
const globals = @import("globals.zig");
const Belt = @import("nodes/Belt.zig");
const Miner = @import("nodes/Miner.zig");
const Hub = @import("nodes/Hub.zig");
const Cutter = @import("nodes/Cutter.zig");
const Rotator = @import("nodes/Rotator.zig");
const Merger = @import("nodes/Merger.zig");
const Writer = @import("Writer.zig");
const Reader = @import("Reader.zig");

pub const NodeType = enum {
    belt,
    miner,
    cutter,
    merger,
    rotator,
    hub,

    pub fn deserialize(self: NodeType, direction: Direction, reader: *Reader) Node {
        return switch (self) {
            .belt => .{ .belt = Belt.deserialize(direction, reader) },
            .miner => .{ .miner = Miner.deserialize(direction, reader) },
            .cutter => .{ .cutter = Cutter.deserialize(direction, reader) },
            .merger => .{ .merger = Merger.deserialize(direction, reader) },
            .rotator => .{ .rotator = Rotator.deserialize(direction, reader) },
            .hub => .{ .hub = Hub.deserialize(reader) },
        };
    }
};

pub const Node = union(NodeType) {
    belt: Belt,
    miner: Miner,
    cutter: Cutter,
    merger: Merger,
    rotator: Rotator,
    hub: Hub,

    pub fn boundingBox(self: Node) BoundingBox(i32) {
        return switch (self) {
            .belt => |belt| belt.boundingBox(),
            .miner => |miner| miner.boundingBox(),
            .cutter => |cutter| cutter.boundingBox(),
            .merger => |merger| merger.boundingBox(),
            .rotator => |rotator| rotator.boundingBox(),
            .hub => |hub| hub.boundingBox(),
        };
    }

    pub fn renderBelts(self: Node, is_wireframe: bool) void {
        switch (self) {
            .belt => |belt| belt.renderBelts(is_wireframe),
            .miner => |miner| miner.renderBelts(is_wireframe),
            .cutter => |cutter| cutter.renderBelts(is_wireframe),
            .merger => |merger| merger.renderBelts(is_wireframe),
            .rotator => |rotator| rotator.renderBelts(is_wireframe),
            .hub => |hub| hub.renderBelts(is_wireframe),
        }
    }

    pub fn renderItems(self: Node) void {
        w4.draw_colors.* = 0x30;
        switch (self) {
            .belt => |belt| belt.renderItems(),
            .miner => {},
            .cutter => |cutter| cutter.renderItems(),
            .merger => |merger| merger.renderItems(),
            .rotator => |rotator| rotator.renderItems(),
            .hub => |hub| hub.renderItems(),
        }
    }

    pub fn renderStructure(self: Node, is_wireframe: bool) void {
        switch (self) {
            .miner => |miner| miner.renderStructure(is_wireframe),
            .cutter => |cutter| cutter.renderStructure(is_wireframe),
            .merger => |merger| merger.renderStructure(is_wireframe),
            .rotator => |rotator| rotator.renderStructure(is_wireframe),
            .hub => |hub| hub.renderStructure(is_wireframe),
            else => {},
        }
    }

    pub fn advance(self: *Node, id: u8) void {
        switch (self.*) {
            .belt => self.belt.advance(id),
            .miner => {},
            .cutter => self.cutter.advance(id),
            .merger => self.merger.advance(id),
            .rotator => self.rotator.advance(id),
            .hub => self.hub.advance(id),
        }
    }

    /// Note: Only defined for nodes with dropOffPointCount > 0
    pub fn dropOffPoint(self: Node, output_index: u8) Vec2(i32) {
        return switch (self) {
            .belt => |belt| belt.dropOffPoint(),
            .miner => |miner| miner.dropOffPoint(),
            .cutter => |cutter| cutter.dropOffPoint(output_index),
            .merger => |merger| merger.dropOffPoint(),
            .rotator => |rotator| rotator.dropOffPoint(),
            .hub => undefined,
        };
    }

    pub fn dropOffPointCount(self: Node) u8 {
        return switch (self) {
            .hub => 0,
            .belt, .miner, .merger, .rotator => 1,
            .cutter => 2,
        };
    }

    pub fn outputItem(self: Node, output_index: u8) Item {
        return switch (self) {
            .belt => |belt| belt.outputItem(),
            .miner => |miner| miner.outputItem(),
            .cutter => |cutter| cutter.outputItem(output_index),
            .merger => |merger| merger.outputItem(),
            .rotator => |rotator| rotator.outputItem(),
            .hub => undefined,
        };
    }

    /// Note: Only defined for nodes with output
    pub fn takeItem(self: *Node, output_index: u8) void {
        return switch (self.*) {
            .belt => self.belt.takeItem(),
            .miner => {},
            .cutter => self.cutter.takeItem(output_index),
            .merger => self.merger.takeItem(),
            .rotator => self.rotator.takeItem(),
            .hub => unreachable,
        };
    }

    /// Note: Only defined for nodes with output
    pub fn direction(self: Node) Direction {
        return switch (self) {
            .belt => self.belt.direction,
            .miner => self.miner.direction,
            .cutter => self.cutter.direction,
            .merger => self.merger.direction,
            .rotator => self.rotator.direction,
            .hub => unreachable,
        };
    }

    pub fn canConnect(self: Node, pos: Vec2(i32), direction_from: Direction) bool {
        return switch (self) {
            .belt => |belt| belt.canConnect(direction_from),
            .miner => false,
            .cutter => |cutter| cutter.canConnect(pos, direction_from),
            .merger => |merger| merger.canConnect(pos, direction_from),
            .rotator => |rotator| rotator.canConnect(pos, direction_from),
            .hub => |hub| hub.canConnect(pos),
        };
    }

    pub fn serialize(self: Node, writer: *Writer) void {
        return switch (self) {
            .belt => |belt| belt.serialize(writer),
            .miner => |miner| miner.serialize(writer),
            .cutter => |cutter| cutter.serialize(writer),
            .merger => |merger| merger.serialize(writer),
            .rotator => |rotator| rotator.serialize(writer),
            .hub => |hub| hub.serialize(writer),
        };
    }
};
