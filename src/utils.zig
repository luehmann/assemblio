const std = @import("std");
const w4 = @import("wasm4.zig");
const globals = @import("globals.zig");
const Vec2 = @import("vec.zig").Vec2;
const BoundingBox = @import("bounding_box.zig").BoundingBox;
const Direction = @import("direction.zig").Direction;
const Connection = @import("Connection.zig");
const levels = @import("levels.zig");

const minInt = std.math.minInt;
const maxInt = std.math.maxInt;

const selection_texture = [1]u8{0b11010000};
pub fn renderSelection(bounding_box: BoundingBox(i32)) void {
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

pub fn getSelectedNodeId(mouse_pos_world: Vec2(i32)) ?u8 {
    for (globals.on_screen_nodes.toSlice()) |id| {
        const box = globals.nodes.get(id).boundingBox();
        if (mouse_pos_world.isWithin(box)) {
            return @bitCast(u8, id);
        }
    }
    return null;
}

pub fn getSelection(mouse_pos_world: Vec2(i32)) ?BoundingBox(i32) {
    for (globals.on_screen_nodes.toSlice()) |id| {
        const box = globals.nodes.get(id).boundingBox();
        if (mouse_pos_world.isWithin(box)) {
            return box;
        }
    }
    return null;
}

pub fn recalculateConnectionsAndDeadEnds() void {
    globals.dead_ends.reset();
    globals.connections.reset();
    for (globals.nodes.toSlice()) |node, from| {
        var i: u8 = 0;
        const drop_off_point_count = node.dropOffPointCount();
        var targets_found: u8 = 0;
        drop_off_point_loop: while (i < drop_off_point_count) : (i += 1) {
            const drop_off_point = node.dropOffPoint(i);
            for (globals.nodes.toSlice()) |potential_target_node, to| {
                if (!drop_off_point.isWithin(potential_target_node.boundingBox())) continue;
                if (!potential_target_node.canConnect(drop_off_point, node.direction())) continue;
                if (isLoop(@intCast(u8, from), @intCast(u8, to))) continue;

                globals.connections.add(.{
                    .from = @intCast(u8, from),
                    .output_index = i,
                    .to = @intCast(u8, to),
                });
                targets_found += 1;
                continue :drop_off_point_loop;
            }
        }
        const dead_end_count = std.math.max(drop_off_point_count, 1);
        if (targets_found < dead_end_count) {
            var j: usize = 0;
            while (j < dead_end_count - targets_found) : (j += 1) {
                globals.dead_ends.add(@intCast(u8, from));
            }
        }
    }
    // w4.trace(std.fmt.bufPrint(&globals.buffer, "{any} {any}", .{ globals.connections.toSlice(), globals.dead_ends.toSlice() }) catch unreachable);
}

fn isLoop(current: u8, to: u8) bool {
    for (globals.connections.toSlice()) |connection| {
        if (connection.from == to) {
            if (current == connection.to) return true;
            if (isLoop(current, connection.to)) {
                return true;
            }
        }
    }
    return false;
}

pub fn getDragDirection(start_pos_word_precise: Vec2(i32), mouse_pos: Vec2(i32)) Direction {
    const center = start_pos_word_precise.addX(-1).subtract(globals.camera_pos);
    var offset = mouse_pos.subtract(center);
    const abs_offset_x = std.math.absInt(offset.x) catch unreachable;
    const abs_offset_y = std.math.absInt(offset.y) catch unreachable;
    if (abs_offset_x <= offset.y) {
        return .south;
    } else if (abs_offset_y < offset.x) {
        return .east;
    } else if (offset.x < -abs_offset_y) {
        return .west;
    } else if (offset.y <= -abs_offset_x) {
        return .north;
    }
    unreachable;
}
