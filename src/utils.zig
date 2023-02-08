const std = @import("std");
const root = @import("main");
const w4 = @import("wasm4");

const globals = root.globals;
const levels = root.levels;

const Direction = root.Direction;
const NodeId = root.NodeId;
const Vec2 = root.Vec2;
const Network = root.Network;
const Rect = root.Rect;

const minInt = std.math.minInt;
const maxInt = std.math.maxInt;

const selection_texture = [1]u8{0b11010000};
pub fn renderSelection(bounding_box: Rect(i32)) void {
    w4.draw_colors.* = 0x40;
    const min = worldToScreen(bounding_box.min).add(.{ .x = -1, .y = -1 });
    const max = worldToScreen(bounding_box.max).add(.{ .x = 7, .y = 7 });
    w4.blit(&selection_texture, min.x, min.y, 2, 2, w4.BLIT_FLIP_X);
    w4.blit(&selection_texture, max.x, min.y, 2, 2, 0);
    w4.blit(&selection_texture, max.x, max.y, 2, 2, w4.BLIT_FLIP_Y);
    w4.blit(&selection_texture, min.x, max.y, 2, 2, w4.BLIT_FLIP_Y | w4.BLIT_FLIP_X);
}

pub fn worldToScreen(world_pos: Vec2(i32)) Vec2(i32) {
    return world_pos.scale(8).subtract(globals.camera_pos);
}

pub fn screenToWorld(screen_pos: Vec2(i32)) Vec2(i32) {
    return screen_pos.add(globals.camera_pos).divFloor(8);
}

pub fn isOutOfBounds(screen_pos: Vec2(i32)) bool {
    const world_pos = screenToWorld(screen_pos); // TODO: calc this at the callsite
    return minInt(i8) + levels.current_level.border_size > world_pos.x or world_pos.x > maxInt(i8) - levels.current_level.border_size or minInt(i8) + levels.current_level.border_size > world_pos.y or world_pos.y > maxInt(i8) - levels.current_level.border_size;
}

pub fn getSelectedNodeId(network: *const Network, node_ids: []const NodeId, mouse_pos_world: Vec2(i32)) ?NodeId {
    for (node_ids) |id| {
        if (Network.getFlag(id)) continue;
        const node = network.nodes[id];

        if (node.intersects(Rect(i32).fromPoint(mouse_pos_world))) {
            return id;
        }
    }
    return null;
}

const input_output_texture = [10]u8{
    0b00000000,
    0b00000000,
    0b00000000,
    0b00011000,
    0b00111100,
    0b00100100,
    0b00000000,
    0b00000000,
    0b00000000,
    0b00000000,
};

pub fn renderInput(network: *const Network, pos: Vec2(i32), direction: Direction, has_offset: bool) void {
    var screen_pos = worldToScreen(pos);
    if (isElevated(network, pos)) {
        screen_pos = screen_pos.add(.{ .y = -3 });
    } else if (has_offset) {
        screen_pos = screen_pos.add(.{ .y = -2 });
    }
    w4.draw_colors.* = 0x40;
    w4.blit(input_output_texture[1..], screen_pos.x, screen_pos.y, 8, 8, direction.blitFlags());
}

pub fn renderOutput(network: *const Network, pos: Vec2(i32), direction: Direction, has_offset: bool) void {
    var screen_pos = worldToScreen(pos);
    if (isElevated(network, pos)) {
        screen_pos = screen_pos.add(.{ .y = -3 });
    } else if (has_offset) {
        screen_pos = screen_pos.add(.{ .y = -2 });
    }
    w4.draw_colors.* = 0x40;
    w4.blit(&input_output_texture, screen_pos.x, screen_pos.y, 8, 8, direction.blitFlags() | w4.BLIT_FLIP_X);
}

fn isElevated(network: *const Network, pos: Vec2(i32)) bool {
    return for (network.nodes) |node| {
        if (node.intersects(Rect(i32).fromPoint(pos))) {
            break node.isElevated();
        }
    } else false;
}

pub fn interpolate(
    input: f32,
    input_start: f32,
    input_end: f32,
    output_start: f32,
    output_end: f32,
) f32 {
    const percent = input / input_end - input_start;
    const result = output_start + percent * (output_end - output_start);
    return std.math.clamp(result, output_start, output_end);
}

test "interpolate" {
    try std.testing.expectEqual(@as(f32, 10.0), interpolate(20.0, 0.0, 40.0, 5.0, 15.0));
    try std.testing.expectEqual(@as(f32, 5.0), interpolate(-20.0, 0.0, 40.0, 5.0, 15.0));
    try std.testing.expectEqual(@as(f32, 15.0), interpolate(80.0, 0.0, 40.0, 5.0, 15.0));
}

pub fn fmt(comptime fmt_str: []const u8, args: anytype) []const u8 {
    return std.fmt.bufPrint(&globals.buffer, fmt_str, args) catch unreachable;
}

pub fn isWithinCircle(world_pos: Vec2(i32), radius: i32) bool {
    const origin = Vec2(i32){ .x = -1, .y = -1 };
    const distance_to_origin_squared = world_pos.scale(2).subtract(origin).magnitudeSquared();
    const scaled_radius = radius * 2;
    return distance_to_origin_squared < scaled_radius * scaled_radius;
}
