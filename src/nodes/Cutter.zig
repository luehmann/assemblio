const std = @import("std");
const root = @import("main");
const w4 = @import("wasm4");

const box = root.box;
const globals = root.globals;
const shared = @import("shared.zig");
const utils = root.utils;

const Direction = root.Direction;
const Item = root.Item;
const Reader = root.Reader;
const Rect = root.Rect;
const Vec2 = root.Vec2;
const Writer = root.Writer;
const Network = root.Network;

const NodeId = root.Network.NodeId;

pos: Vec2(i8),
direction: Direction,
input: Item = Item.empty,
is_blocked: bool = false,
was_ticked: bool = false,

const Self = @This();

pub fn advance(self: *Self, network: *Network, id: NodeId, advance_queue: *Network.AdvanceQueue) void {
    if (!self.input.eql(Item.empty)) self.is_blocked = true;
    if (self.was_ticked) {
        for (network.connections) |connection| {
            if (connection.to != id) continue;
            const node = &network.nodes[connection.from];
            const drop_off_point = node.dropOffPoint(connection.output_index);
            if (!drop_off_point.isWithin(self.boundingBox())) continue;

            const output_item = node.outputItem(connection.output_index);
            if (!output_item.eql(Item.empty)) {
                if (self.input.eql(Item.empty)) {
                    node.takeItem(connection.output_index);
                    self.input = output_item;
                }
            }

            advance_queue.append(connection.from);
            break;
        }
    }

    self.was_ticked = !self.was_ticked;
}

pub fn boundingBox(self: *const Self) Rect(i32) {
    return Rect(i32).fromPoints(
        self.pos.as(i32),
        self.otherPos(),
    );
}

pub fn renderBelts(self: *const Self, is_wireframe: bool) void {
    shared.renderBelt(self.pos.as(i32), self.direction, false, is_wireframe);
    shared.renderBelt(self.otherPos(), self.direction, false, is_wireframe);
}

pub fn renderItems(self: *const Self) void {
    if (self.is_blocked or globals.belt_step == 0) {
        shared.renderItem(self.input.leftHalf(), self.pos.as(i32), self.direction.opposite(), true);
        shared.renderItem(self.input.rightHalf(), self.otherPos(), self.direction.opposite(), true);
    } else {
        shared.renderItem(self.input, self.pos.as(i32), self.direction.opposite(), false);
    }
}

pub fn renderStructure(self: *const Self, is_wireframe: bool) void {
    var pos = self.pos.as(i32);
    if (self.direction.rotateClockwise().isFacingNegative()) pos = pos.add(self.direction.rotateClockwise().toVec());
    renderOnScreen(utils.worldToScreen(pos), self.direction, is_wireframe, globals.t);
}

pub fn renderOnScreen(screen_pos: Vec2(i32), direction: Direction, is_wireframe: bool, t: u32) void {
    const top_pos = screen_pos.add(.{ .y = -3 });
    w4.draw_colors.* = if (is_wireframe) 0x41 else 0x31;
    if (direction.isHorizontal()) {
        box.renderFront(screen_pos.add(.{ .y = 13 }));
        box.renderTopTall(top_pos);
    } else {
        box.renderTopWide(top_pos);
        if (direction == .north) {
            box.renderFrontRight(screen_pos.add(.{ .x = 8, .y = 5 }));
        } else {
            w4.draw_colors.* = if (is_wireframe) 0x40 else 0x30;
            box.renderFront(screen_pos.add(.{ .x = 8, .y = 5 }));
        }
        w4.draw_colors.* = if (is_wireframe) 0x40 else 0x30;
        box.renderFront(screen_pos.add(.{ .y = 5 }));
    }
    const blade_tile = if (direction.rotateClockwise().isFacingNegative()) top_pos.add(direction.rotateCounterClockwise().toVec().scale(8)) else top_pos;
    const other_tile = if (direction.rotateCounterClockwise().isFacingNegative()) top_pos.add(direction.rotateClockwise().toVec().scale(8)) else top_pos;
    w4.draw_colors.* = if (is_wireframe) 0x40 else 0x20;
    const blit_flags = if (((t + 7) / 24) % 2 == 0) 0 else w4.BLIT_FLIP_X;
    w4.blit(&blade_texture, blade_tile.x, blade_tile.y, 8, 8, blit_flags);
    w4.blit(&other_texture, other_tile.x, other_tile.y, 8, 8, switch (direction) {
        .east => 0,
        .south => w4.BLIT_ROTATE | w4.BLIT_FLIP_X | w4.BLIT_FLIP_Y,
        .west => w4.BLIT_FLIP_X | w4.BLIT_FLIP_Y,
        .north => w4.BLIT_ROTATE,
    });
}

const other_texture = [8]u8{
    0b00010000,
    0b00010000,
    0b00010000,
    0b00010100,
    0b00011100,
    0b00000100,
    0b00000000,
    0b00000000,
};
const blade_texture = [8]u8{
    0b00000000,
    0b00010000,
    0b00001000,
    0b00010000,
    0b00001000,
    0b00010000,
    0b00001000,
    0b00000000,
};

pub fn renderInputsAndOutputs(self: *const Self, network: *const Network) void {
    utils.renderInput(network, self.inputPosition(), self.direction, self.direction == .south);
    utils.renderOutput(network, self.dropOffPoint(0), self.direction, self.direction == .north);
    utils.renderOutput(network, self.dropOffPoint(1), self.direction, self.direction == .north);
}

fn inputPosition(self: Self) Vec2(i32) {
    return self.pos.as(i32).subtract(self.direction.toVec());
}

pub fn outputItem(self: *const Self, output_index: u8) Item {
    return switch (output_index) {
        0 => self.input.leftHalf(),
        1 => self.input.rightHalf(),
        else => unreachable,
    };
}

pub fn takeItem(self: *Self, output_index: u8) void {
    self.input = switch (output_index) {
        0 => self.input.rightHalf(),
        1 => self.input.leftHalf(),
        else => unreachable,
    };
    if (self.input.eql(Item.empty)) self.is_blocked = false;
}

pub fn dropOffPoint(self: *const Self, output: u8) Vec2(i32) {
    return self.pos.as(i32).add(self.direction.rotateClockwise().toVec().scale(output).add(self.direction.toVec()));
}

pub fn canConnect(self: *const Self, position: Vec2(i32), direction: Direction) bool {
    return std.meta.eql(position, self.pos.as(i32)) and direction == self.direction;
}

fn otherPos(self: Self) Vec2(i32) {
    return self.pos.as(i32).add(self.direction.rotateClockwise().toVec());
}

pub fn rotate(self: *Self) Direction {
    self.pos = self.pos.add(self.direction.rotateClockwise().toVec().intCast(i8));
    self.direction = self.direction.opposite();
    self.input = Item.empty;

    return self.direction;
}

pub fn serialize(self: *const Self, writer: *Writer) void {
    writer.write(self.pos.x);
    writer.write(self.pos.y);
}

pub fn deserialize(direction: Direction, reader: *Reader) Self {
    return .{
        .pos = .{
            .x = reader.read(i8),
            .y = reader.read(i8),
        },
        .direction = direction,
    };
}
