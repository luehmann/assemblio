const Vec2 = @import("../vec.zig").Vec2;
const BoundingBox = @import("../bounding_box.zig").BoundingBox;
const font = @import("../font.zig");
const levels = @import("../levels.zig");
const Item = @import("../item.zig").Item;
const std = @import("std");
const globals = @import("../globals.zig");
const utils = @import("../utils.zig");
const w4 = @import("../wasm4.zig");
const Direction = @import("../direction.zig").Direction;
const shared = @import("shared.zig");
const save = @import("../save.zig");
const Writer = @import("../Writer.zig");
const Reader = @import("../Reader.zig");

pos: Vec2(i8),
inputs: [12][2]Item = std.mem.zeroes([12][2]Item),

const Self = @This();

pub fn advance(self: *Self, id: u8) void {
    for (self.inputs) |*input| {
        if (input[1].eql(levels.current_level.item)) {
            globals.active_count += 1;
        }
        checkActiveCount();
        input[1] = input[0];
        input[0] = Item.empty;
    }
    for (globals.connections.toSlice()) |connection| {
        if (connection.to != id) continue;
        const node = &globals.nodes.items[connection.from];
        const drop_off_point = node.dropOffPoint(connection.output_index);

        const input_index = self.getInputIndex(drop_off_point);
        const output_item = node.outputItem(connection.output_index);
        if (!output_item.eql(Item.empty)) {
            node.takeItem(connection.output_index);
            self.inputs[input_index][0] = output_item;
        }

        node.advance(connection.from);
    }
}

fn getInputIndex(self: Self, drop_off_point: Vec2(i32)) usize {
    if (self.pos.y == drop_off_point.y) return @intCast(usize, drop_off_point.x - self.pos.x - 1);
    if (self.pos.x + 4 == drop_off_point.x) return @intCast(usize, drop_off_point.y - self.pos.y + 2);
    if (self.pos.y + 4 == drop_off_point.y) return @intCast(usize, drop_off_point.x - self.pos.x + 5);
    if (self.pos.x == drop_off_point.x) return @intCast(usize, drop_off_point.y - self.pos.y + 8);
    unreachable;
}

pub fn boundingBox(self: Self) BoundingBox(i32) {
    return BoundingBox(i32).fromPoints(
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
            0...2 => Tile{ .pos = self.pos.addX(self.i + 1), .direction = .south },
            3...5 => Tile{ .pos = self.pos.addX(4).addY(self.i - 2), .direction = .west },
            6...8 => Tile{ .pos = self.pos.addX(self.i - 5).addY(4), .direction = .north },
            9...11 => Tile{ .pos = self.pos.addY(self.i - 8), .direction = .east },
            else => null,
        };
    }
};

fn iterateBelts(self: Self) Iterator {
    return Iterator{ .pos = self.pos.as(i32) };
}

pub fn renderBelts(self: Self, is_wireframe: bool) void {
    var belts = self.iterateBelts();
    while (belts.next()) |belt| {
        const has_line = is_wireframe and belt.pos.y > self.pos.y + 2;
        shared.renderBelt(belt.pos, belt.direction, has_line, is_wireframe);
    }
}

pub fn canConnect(self: Self, position: Vec2(i32)) bool {
    if (self.pos.x == position.x and self.pos.y == position.y) return false;
    if (self.pos.x + 4 == position.x and self.pos.y == position.y) return false;
    if (self.pos.x + 4 == position.x and self.pos.y + 4 == position.y) return false;
    if (self.pos.x == position.x and self.pos.y + 4 == position.y) return false;
    return true;
}

pub fn renderItems(self: Self) void {
    var iterator = self.iterateBelts();
    while (iterator.next()) |belt| {
        const input = self.inputs[iterator.i - 1];
        const direction_coming_from = belt.direction.opposite();
        shared.renderItem(input[0], belt.pos, direction_coming_from, false);
        shared.renderItem(input[1], belt.pos.add(belt.direction.toVec()), direction_coming_from, false);
    }
}

pub fn renderStructure(self: Self, is_wireframe: bool) void {
    const pos = utils.worldToScreen(self.pos.as(i32)).add(.{ .x = 4, .y = 1 });
    const is_random = levels.level == levels.levels.len;
    w4.draw_colors.* = if (is_wireframe) 0x1140 else 0x4130;
    w4.blit(&hub_texture, pos.x, pos.y, hub_texture_width, hub_texture_height, 1);
    const level_str = if (is_random) "++" else std.fmt.bufPrint(&globals.buffer, "{:0>2}", .{levels.level + 1}) catch unreachable;
    w4.draw_colors.* = 0x10;
    font.text(level_str, pos.x + 8, pos.y + 2);
    var current: []const u8 = "N/A";
    if (is_random) {
        if (globals.rate) |rate| {
            current = fmt("{}/S", .{rate});
        }
    } else {
        current = fmt("{}", .{globals.active_count});
    }
    // const current = std.fmt.bufPrint(&globals.buffer, "{}{s}", .{ globals.active_count, unit }) catch unreachable;
    w4.draw_colors.* = if (is_wireframe) 0x0 else 0x30;
    font.text(current, pos.x + 14, pos.y + 11);

    var required = std.fmt.bufPrint(&globals.buffer, "/{}", .{levels.current_level.amount}) catch unreachable;
    if (is_random) required = std.fmt.bufPrint(&globals.buffer, "{}/S", .{levels.current_level.amount}) catch unreachable;

    w4.draw_colors.* = if (is_wireframe) 0x0 else 0x20;
    font.text(required, pos.x + 14, pos.y + 18);

    w4.draw_colors.* = if (is_wireframe) 0x0 else 0x30;
    levels.current_level.item.renderBig(pos.x + 3, pos.y + 15);
    w4.draw_colors.* = if (is_wireframe) 0x0 else 0x40;
    levels.current_level.item.renderBig(pos.x + 3, pos.y + 13);
}

fn fmt(comptime fmt_str: []const u8, args: anytype) []const u8 {
    return std.fmt.bufPrint(&globals.buffer, fmt_str, args) catch unreachable;
}

const hub_texture_width = 32;
const hub_texture_height = 35;
const hub_texture = [280]u8{ 0x01, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x40, 0x01, 0xaf, 0xff, 0xff, 0xea, 0xaa, 0xaa, 0x40, 0x01, 0xaf, 0xff, 0xff, 0xea, 0xaa, 0xaa, 0x40, 0x55, 0xaf, 0xff, 0xff, 0xea, 0xaa, 0xaa, 0x55, 0x6a, 0xaf, 0xff, 0xff, 0xea, 0xaa, 0xaa, 0xa9, 0x6a, 0xaf, 0xff, 0xff, 0xea, 0xaa, 0xaa, 0xa9, 0x6a, 0xaf, 0xff, 0xff, 0xea, 0xaa, 0xaa, 0xa9, 0x6a, 0xaf, 0xff, 0xff, 0xea, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x6a, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xa9, 0x55, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0x55, 0x69, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0x69, 0x69, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0x69, 0x69, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x69, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40, 0x01, 0x40 };

fn checkActiveCount() void {
    const is_random = levels.level == levels.levels.len;
    var is_completed = if (is_random) (globals.rate orelse 0) >= levels.current_level.amount else globals.active_count >= levels.current_level.amount;
    if (is_completed) {
        levels.nextLevel();
        save.serialize();
    }
}

pub fn serialize(self: Self, writer: *Writer) void {
    writer.writeByte(@bitCast(u8, self.pos.x));
    writer.writeByte(@bitCast(u8, self.pos.y));
}

pub fn deserialize(reader: *Reader) Self {
    return .{
        .pos = .{
            .x = @bitCast(i8, reader.readByte()),
            .y = @bitCast(i8, reader.readByte()),
        },
    };
}
