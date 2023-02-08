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
slots: [2]Item = std.mem.zeroes([2]Item),
blocked: [2]bool = [2]bool{ false, false },

const Self = @This();

pub fn advance(self: *Self, network: *Network, id: NodeId, advance_queue: *Network.AdvanceQueue) void {
    if (!self.slots[0].eql(Item.empty)) self.blocked[0] = true;
    if (!self.slots[1].eql(Item.empty)) self.blocked[1] = true;
    for (network.connections) |connection| {
        if (connection.to != id) continue;
        const node = &network.nodes[connection.from];
        const drop_off_point = node.dropOffPoint(connection.output_index);
        if (!drop_off_point.isWithin(self.boundingBox())) continue;

        const input_index = self.getInputIndex(drop_off_point);
        if (self.slots[input_index].eql(Item.empty)) {
            const output_item = node.outputItem(connection.output_index);
            const can_take = switch (input_index) {
                0 => output_item.isValidLeftHalf(),
                1 => output_item.isValidRightHalf(),
                else => unreachable,
            };
            if (can_take) {
                node.takeItem(connection.output_index);
                self.slots[input_index] = output_item;
            }
        }

        advance_queue.append(connection.from);
    }
}

fn getInputIndex(self: Self, drop_off_point: Vec2(i32)) usize {
    // TODO: check if this may lead to an overflow of the i8
    return std.math.absCast(
        if (self.direction.isHorizontal()) self.pos.y - drop_off_point.y else self.pos.x - drop_off_point.x,
    );
}

pub fn outputItem(self: *const Self) Item {
    if (self.slots[0].eql(Item.empty)) return Item.empty;
    if (self.slots[1].eql(Item.empty)) return Item.empty;
    return Item.merge(self.slots[0], self.slots[1]);
}

pub fn takeItem(self: *Self) void {
    self.slots[0] = Item.empty;
    self.slots[1] = Item.empty;
    self.blocked[0] = false;
    self.blocked[1] = false;
}

pub fn renderBelts(self: *const Self, is_wireframe: bool) void {
    shared.renderBelt(self.pos.as(i32), self.direction, false, is_wireframe);
    shared.renderBelt(self.otherPos(), self.direction, false, is_wireframe);
}

pub fn renderItems(self: *const Self) void {
    shared.renderItem(self.slots[0], self.pos.as(i32), self.direction.opposite(), self.blocked[0]);
    shared.renderItem(self.slots[1], self.otherPos(), self.direction.opposite(), self.blocked[1]);
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
        if (direction == .south) {
            box.renderFrontLeft(screen_pos.add(.{ .y = 5 }));
        } else {
            w4.draw_colors.* = if (is_wireframe) 0x40 else 0x30;
            box.renderFront(screen_pos.add(.{ .y = 5 }));
        }
        w4.draw_colors.* = if (is_wireframe) 0x40 else 0x30;
        box.renderFront(screen_pos.add(.{ .x = 8, .y = 5 }));
    }
    w4.draw_colors.* = if (is_wireframe) 0x40 else 0x20;
    const blade_tile = if (direction.rotateClockwise().isFacingNegative()) top_pos.add(direction.rotateCounterClockwise().toVec().scale(8)) else top_pos;
    const other_tile = if (direction.rotateCounterClockwise().isFacingNegative()) top_pos.add(direction.rotateClockwise().toVec().scale(8)) else top_pos;
    const blit_flags = switch (direction) {
        .east => 0,
        .south => w4.BLIT_ROTATE | w4.BLIT_FLIP_X | w4.BLIT_FLIP_Y,
        .west => w4.BLIT_FLIP_X | w4.BLIT_FLIP_Y,
        .north => w4.BLIT_ROTATE,
    };
    w4.blit(&main_texture, blade_tile.x, blade_tile.y, 8, 8, blit_flags);
    w4.blit(&other_texture, other_tile.x, other_tile.y, 8, 8, blit_flags);
    const f = std.math.min(6, 7 - ((t + 5) / 6) % 8);
    const texture = @intToPtr([*]u8, @ptrToInt(&piston_frames) + f);
    const translate_vec = if (direction.rotateCounterClockwise().isFacingNegative()) direction.rotateClockwise().toVec().scale(5) else direction.rotateCounterClockwise().toVec().scale(3);
    const piston_postion = top_pos.add(translate_vec);
    w4.blit(texture, piston_postion.x, piston_postion.y, 8, 8, direction.rotateCounterClockwise().blitFlags());
}
const main_texture = [8]u8{
    0b00000000,
    0b00000000,
    0b00111100,
    0b00000000,
    0b00000000,
    0b00000000,
    0b00000000,
    0b00000000,
};
const other_texture = [8]u8{
    0b00000000,
    0b00000000,
    0b00000000,
    0b00000000,
    0b01011000,
    0b01011000,
    0b00000000,
    0b00000000,
};

pub fn renderInputsAndOutputs(self: *const Self, network: *const Network) void {
    utils.renderInput(network, self.inputPosition(0), self.direction, self.direction == .south);
    utils.renderInput(network, self.inputPosition(1), self.direction, self.direction == .south);
    utils.renderOutput(network, self.dropOffPoint(), self.direction, self.direction == .north);
}

fn inputPosition(self: Self, index: u8) Vec2(i32) {
    return self.pos.as(i32).add(self.direction.rotateClockwise().toVec().scale(index).subtract(self.direction.toVec()));
}

pub fn dropOffPoint(self: *const Self) Vec2(i32) {
    return self.pos.as(i32).add(self.direction.toVec());
}

pub fn boundingBox(self: *const Self) Rect(i32) {
    return Rect(i32).fromPoints(
        self.pos.as(i32),
        self.otherPos(),
    );
}

fn otherPos(self: Self) Vec2(i32) {
    return self.pos.as(i32).add(self.direction.rotateClockwise().toVec());
}

pub fn canConnect(self: *const Self, position: Vec2(i32), direction: Direction) bool {
    return (std.meta.eql(position, self.pos.as(i32)) or return std.meta.eql(position, self.otherPos())) and direction == self.direction;
}

pub fn rotate(self: *Self) Direction {
    self.pos = self.pos.add(self.direction.rotateClockwise().toVec().intCast(i8));
    self.direction = self.direction.opposite();
    self.slots = std.mem.zeroes([2]Item);

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

const piston_frames = [_]u8{
    0b00000000,
    0b00000000,
    0b00000000,
    0b00000000,
    0b00000000,
    0b00000000,
    0b00111100,
    0b00011000,
    0b00011000,
    0b00011000,
    0b00011000,
    0b00011000,
    0b00011000,
};
