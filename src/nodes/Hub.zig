const std = @import("std");
const root = @import("main");
const w4 = @import("wasm4");

const font = root.font;
const globals = root.globals;
const levels = root.levels;
const save = root.save;
const shared = @import("shared.zig");
const utils = root.utils;

const Direction = root.Direction;
const Item = root.Item;
const Reader = root.Reader;
const Rect = root.Rect;
const Shard = root.Shard;
const Vec2 = root.Vec2;
const Writer = root.Writer;
const Network = root.Network;

const NodeId = root.Network.NodeId;
const fmt = utils.fmt;

pos: Vec2(i8),
inputs: [12][2]Item = std.mem.zeroes([12][2]Item),

const Self = @This();

pub fn advance(self: *Self, network: *Network, id: NodeId, advance_queue: *Network.AdvanceQueue) void {
    for (self.inputs) |*input| {
        if (input[1].eql(levels.current_level.item)) {
            globals.active_count += 1;
        }
        checkActiveCount(network);
        input[1] = input[0];
        input[0] = Item.empty;
    }
    for (network.connections) |connection| {
        if (connection.to != id) continue;
        const node = &network.nodes[connection.from];
        const drop_off_point = node.dropOffPoint(connection.output_index);

        const input_index = self.getInputIndex(drop_off_point);
        const output_item = node.outputItem(connection.output_index);
        if (!output_item.eql(Item.empty)) {
            node.takeItem(connection.output_index);
            self.inputs[input_index][0] = output_item;
        }

        advance_queue.append(connection.from);
    }
}

fn getInputIndex(self: Self, drop_off_point: Vec2(i32)) usize {
    if (self.pos.y == drop_off_point.y) return @intCast(usize, drop_off_point.x - self.pos.x - 1);
    if (self.pos.x + 4 == drop_off_point.x) return @intCast(usize, drop_off_point.y - self.pos.y + 2);
    if (self.pos.y + 4 == drop_off_point.y) return @intCast(usize, drop_off_point.x - self.pos.x + 5);
    if (self.pos.x == drop_off_point.x) return @intCast(usize, drop_off_point.y - self.pos.y + 8);
    unreachable;
}

pub fn boundingBox(self: *const Self) Rect(i32) {
    return Rect(i32).fromPoints(
        self.pos.as(i32),
        self.pos.as(i32).add(.{ .x = 4, .y = 4 }),
    );
}

const Iterator = struct {
    pos: Vec2(i32),
    i: u8 = 0,

    const Tile = struct {
        pos: Vec2(i32),
        direction: Direction,
    };
    pub fn next(self: *Iterator) ?Tile {
        defer self.i += 1;
        return switch (self.i) {
            0...2 => Tile{ .pos = self.pos.add(.{ .x = self.i + 1 }), .direction = .south },
            3...5 => Tile{ .pos = self.pos.add(.{ .x = 4, .y = self.i - 2 }), .direction = .west },
            6...8 => Tile{ .pos = self.pos.add(.{ .x = self.i - 5, .y = 4 }), .direction = .north },
            9...11 => Tile{ .pos = self.pos.add(.{ .y = self.i - 8 }), .direction = .east },
            else => null,
        };
    }
};

fn iterateBelts(self: Self) Iterator {
    return Iterator{ .pos = self.pos.as(i32) };
}

pub fn renderBelts(self: *const Self, is_wireframe: bool) void {
    var belts = self.iterateBelts();
    while (belts.next()) |belt| {
        const has_line = is_wireframe and belt.pos.y > self.pos.y + 2;
        shared.renderBelt(belt.pos, belt.direction, has_line, is_wireframe);
    }
}

pub fn canConnect(self: *const Self, position: Vec2(i32)) bool {
    if (self.pos.x == position.x and self.pos.y == position.y) return false;
    if (self.pos.x + 4 == position.x and self.pos.y == position.y) return false;
    if (self.pos.x + 4 == position.x and self.pos.y + 4 == position.y) return false;
    if (self.pos.x == position.x and self.pos.y + 4 == position.y) return false;
    return true;
}

pub fn renderItems(self: *const Self) void {
    var iterator = self.iterateBelts();
    while (iterator.next()) |belt| {
        const input = self.inputs[iterator.i - 1];
        const direction_coming_from = belt.direction.opposite();
        shared.renderItem(input[0], belt.pos, direction_coming_from, false);
        shared.renderItem(input[1], belt.pos.add(belt.direction.toVec()), direction_coming_from, false);
    }
}

pub fn renderStructure(self: *const Self, is_wireframe: bool) void {
    const pos = utils.worldToScreen(self.pos.as(i32)).add(.{ .x = 4, .y = 1 });
    const is_random = levels.level == levels.levels.len;
    w4.draw_colors.* = if (is_wireframe) 0x1140 else 0x4130;
    w4.blit(&hub_texture, pos.x, pos.y, hub_texture_width, hub_texture_height, 1);
    const level_str = if (is_random) "++" else fmt("{:0>2}", .{levels.level + 1});
    w4.draw_colors.* = 0x10;
    font.renderText(level_str, pos.x + 8, pos.y + 2);
    var current: []const u8 = "N/A";
    if (is_random) {
        if (globals.rate) |rate| {
            current = fmt("{}/S", .{rate});
        }
    } else {
        current = fmt("{}", .{globals.active_count});
    }
    w4.draw_colors.* = if (is_wireframe) 0x0 else 0x30;
    font.renderText(current, pos.x + 14, pos.y + 11);

    var required = if (is_random)
        fmt("{}/S", .{levels.current_level.amount})
    else
        fmt("/{}", .{levels.current_level.amount});

    w4.draw_colors.* = if (is_wireframe) 0x0 else 0x20;
    font.renderText(required, pos.x + 14, pos.y + 18);

    const item_pos = pos.add(.{ .x = 3, .y = 13 });

    var item = levels.current_level.item;
    var hovered_shard: Shard = .air;
    if (item.top_right != .air and globals.mouse_pos.isWithin(.{
        .min = item_pos.add(.{ .x = 4, .y = 0 }),
        .max = item_pos.add(.{ .x = 7, .y = 3 }),
    })) {
        hovered_shard = item.top_right;
        item = .{ .top_right = item.top_right };
    } else if (item.bottom_right != .air and globals.mouse_pos.isWithin(.{
        .min = item_pos.add(.{ .x = 4, .y = 4 }),
        .max = item_pos.add(.{ .x = 7, .y = 7 }),
    })) {
        hovered_shard = item.bottom_right;
        item = .{ .bottom_right = item.bottom_right };
    } else if (item.bottom_left != .air and globals.mouse_pos.isWithin(.{
        .min = item_pos.add(.{ .x = 0, .y = 4 }),
        .max = item_pos.add(.{ .x = 3, .y = 7 }),
    })) {
        hovered_shard = item.bottom_left;
        item = .{ .bottom_left = item.bottom_left };
    } else if (item.top_left != .air and globals.mouse_pos.isWithin(.{
        .min = item_pos.add(.{ .x = 0, .y = 0 }),
        .max = item_pos.add(.{ .x = 3, .y = 3 }),
    })) {
        hovered_shard = item.top_left;
        item = .{ .top_left = item.top_left };
    }

    if (hovered_shard != .air) {
        const hovered_item = Item.baseItem(hovered_shard);
        w4.draw_colors.* = 0x20;
        hovered_item.renderBig(item_pos.add(.{ .y = 2 }));
        // w4.draw_colors.* = 0x20;
        // hovered_item.renderBig(item_pos);
    }

    w4.draw_colors.* = if (is_wireframe) 0x0 else 0x30;
    item.renderBig(item_pos.add(.{ .y = 2 }));
    w4.draw_colors.* = if (is_wireframe) 0x0 else 0x40;
    item.renderBig(item_pos);
}

pub fn renderInputsAndOutputs(self: *const Self, network: *const Network) void {
    var belts = self.iterateBelts();
    while (belts.next()) |belt| {
        utils.renderInput(network, belt.pos.subtract(belt.direction.toVec()), belt.direction, false);
    }
}

const hub_texture_width = 32;
const hub_texture_height = 35;
const hub_texture = [280]u8{ 0x01, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x40, 0x01, 0xaf, 0xff, 0xff, 0xea, 0xaa, 0xaa, 0x40, 0x01, 0xaf, 0xff, 0xff, 0xea, 0xaa, 0xaa, 0x40, 0x55, 0xaf, 0xff, 0xff, 0xea, 0xaa, 0xaa, 0x55, 0x6a, 0xaf, 0xff, 0xff, 0xea, 0xaa, 0xaa, 0xa9, 0x6a, 0xaf, 0xff, 0xff, 0xea, 0xaa, 0xaa, 0xa9, 0x6a, 0xaf, 0xff, 0xff, 0xea, 0xaa, 0xaa, 0xa9, 0x6a, 0xaf, 0xff, 0xff, 0xea, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x55, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0x55, 0x69, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0x69, 0x69, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0x69, 0x69, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x69, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40 };

fn checkActiveCount(network: *const Network) void {
    const is_random = levels.level == levels.levels.len;
    var is_completed = if (is_random) (globals.rate orelse 0) >= levels.current_level.amount else globals.active_count >= levels.current_level.amount;
    if (is_completed) {
        levels.nextLevel(network);
        save.serialize(network);
    }
}

pub fn serialize(self: *const Self, writer: *Writer) void {
    writer.write(self.pos.x);
    writer.write(self.pos.y);
}

pub fn deserialize(reader: *Reader) Self {
    return .{
        .pos = .{
            .x = reader.read(i8),
            .y = reader.read(i8),
        },
    };
}
