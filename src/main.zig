const w4 = @import("wasm4.zig");
const std = @import("std");
const Vec2 = @import("vec.zig").Vec2;
const utils = @import("utils.zig");
const globals = @import("globals.zig");
const BoundingBox = @import("bounding_box.zig").BoundingBox;
const Item = @import("item.zig").Item;
const inventory = @import("inventory.zig");
const Direction = @import("direction.zig").Direction;
const Node = @import("nodes.zig").Node;
const NodeType = @import("nodes.zig").NodeType;
const Hub = @import("nodes/Hub.zig");
const Tilemap = @import("Tilemap.zig");
const resources = @import("resources.zig");
const Belt = @import("nodes/Belt.zig");
const Cutter = @import("nodes/Cutter.zig");
const Merger = @import("nodes/Merger.zig");
const save = @import("save.zig");
const levels = @import("levels.zig");

const minInt = std.math.minInt;
const maxInt = std.math.maxInt;

var previous_gamepad = @bitCast(w4.Gamepad, @as(u8, 0));
var previous_mouse_buttons = @bitCast(w4.MouseButtons, @as(u8, 0));
var previous_mouse_pos: Vec2(i32) = undefined;
var start_mouse_world_precise: ?Vec2(i32) = null;
var deleting_type: ?NodeType = null; // TODO: turn into slot enum
var is_wireframe: bool = undefined;
var is_moving = false;

const is_debug_placing = false;

export fn start() void {
    w4.palette.* = .{
        0xeeeeee,
        0x98abab,
        0x3b343b,
        0xf59200,
    };

    save.deserialize();
}

export fn update() void {
    is_moving = false;
    var is_inventory_open = false;

    // handle input

    const buttons_diff = @bitCast(u8, w4.gamepad1.*) ^ @bitCast(u8, previous_gamepad);
    const buttons_pressed = @bitCast(w4.Gamepad, buttons_diff & @bitCast(u8, w4.gamepad1.*));
    const buttons_released = @bitCast(w4.Gamepad, buttons_diff & @bitCast(u8, previous_gamepad));

    _ = buttons_released;

    const mouse_buttons_diff = @bitCast(u8, w4.mouse_buttons.*) ^ @bitCast(u8, previous_mouse_buttons);
    const mouse_buttons_pressed = @bitCast(w4.MouseButtons, mouse_buttons_diff & @bitCast(u8, w4.mouse_buttons.*));
    const mouse_buttons_released = @bitCast(w4.MouseButtons, mouse_buttons_diff & @bitCast(u8, previous_mouse_buttons));

    const mouse_pos = Vec2(i32){
        .x = @intCast(i32, std.math.clamp(w4.mouse_x.*, 0, 159)),
        .y = @intCast(i32, std.math.clamp(w4.mouse_y.*, 0, 159)),
    };
    const mouse_pos_world = utils.screenToWorld(mouse_pos);

    is_inventory_open = w4.gamepad1.button_2;
    const is_mouse_over_inventory = is_inventory_open and mouse_pos.y > 15 * 8;

    if (w4.mouse_buttons.mouse_middle and !mouse_buttons_pressed.mouse_middle) {
        globals.camera_pos = globals.camera_pos.add(
            previous_mouse_pos.subtract(mouse_pos).scale(8),
        );
        is_moving = true;
    }

    if (is_inventory_open) {
        if (buttons_pressed.button_left) inventory.changeSlot(-1);
        if (buttons_pressed.button_right) inventory.changeSlot(1);
    } else {
        if (w4.gamepad1.*.button_left) {
            globals.camera_pos.x -= 2;
            is_moving = true;
        }
        if (w4.gamepad1.*.button_right) {
            globals.camera_pos.x += 2;
            is_moving = true;
        }
        if (w4.gamepad1.*.button_up) {
            globals.camera_pos.y -= 2;
            is_moving = true;
        }
        if (w4.gamepad1.*.button_down) {
            globals.camera_pos.y += 2;
            is_moving = true;
        }
    }
    clampCamPos(&globals.camera_pos.x);
    clampCamPos(&globals.camera_pos.y);

    previous_gamepad = w4.gamepad1.*;
    previous_mouse_pos = mouse_pos;
    previous_mouse_buttons = w4.mouse_buttons.*;

    const top_left = Vec2(i32){
        .x = 8 - (globals.camera_pos.x & 7) - 8,
        .y = 8 - (globals.camera_pos.y & 7) - 8,
    };
    const top_left_world = top_left.add(globals.camera_pos).divFloor(8);

    globals.screen_box = BoundingBox(i32){
        .min = top_left_world,
        .max = top_left_world.add(.{ .x = 20, .y = 20 }),
    };

    calculateOnScreenNodes();

    const selection = utils.getSelection(mouse_pos_world);
    const selected_node_id = utils.getSelectedNodeId(mouse_pos_world);

    if (!is_mouse_over_inventory and w4.mouse_buttons.mouse_right) if (selected_node_id) |id| {
        const node = globals.nodes.get(id);
        if (deleting_type == null or node == deleting_type.?) {
            globals.nodes.removeAt(id);
            utils.recalculateConnectionsAndDeadEnds();
            save.serialize();
            deleting_type = node;
        }
    };
    if (mouse_buttons_released.mouse_right) {
        if (is_debug_placing) w4.trace(std.fmt.bufPrint(&globals.buffer, ".{s} .x = {}, .y = {}{s},", .{ "{", mouse_pos_world.x, mouse_pos_world.y, "}" }) catch unreachable);
        deleting_type = null;
    }

    const is_mouse_within_bounds = !utils.isOutOfBounds(mouse_pos);
    const is_full = globals.nodes.len == 256;
    if (mouse_buttons_pressed.mouse_left and selection == null and !is_mouse_over_inventory and is_mouse_within_bounds and !is_full) {
        start_mouse_world_precise = mouse_pos.add(globals.camera_pos);
    }

    is_wireframe = true;
    if (w4.mouse_buttons.mouse_left) {
        if (start_mouse_world_precise) |start_pos_precise| {
            const direction = utils.getDragDirection(start_pos_precise, mouse_pos);
            const start_pos = start_pos_precise.divFloor(8);
            const offset = start_pos.subtract(mouse_pos_world);
            var len: u8 = @intCast(u8, std.math.max(std.math.absCast(offset.x), std.math.absCast(offset.y)));

            len = switch (direction) {
                .north => std.math.min(len, @intCast(u8, start_pos.y - std.math.minInt(i8) - levels.current_level.border_size)),
                .east => std.math.min(len, @intCast(u8, std.math.maxInt(i8) - levels.current_level.border_size - start_pos.x)),
                .south => std.math.min(len, @intCast(u8, std.math.maxInt(i8) - levels.current_level.border_size - start_pos.y)),
                .west => std.math.min(len, @intCast(u8, start_pos.x - std.math.minInt(i8) - levels.current_level.border_size)),
            };
            len = std.math.max(1, len);
            globals.ghost_node = getGhostNode(start_pos, mouse_pos_world, direction, len);
            is_wireframe = false;
        }
    } else if (mouse_buttons_released.mouse_left) {
        start_mouse_world_precise = null;
        if (globals.ghost_node) |node| {
            globals.nodes.add(node);
            globals.ghost_node = null;

            utils.recalculateConnectionsAndDeadEnds();
            save.serialize();
            calculateOnScreenNodes();
        }
    } else if (selection == null and !is_mouse_over_inventory and is_mouse_within_bounds and !is_full) {
        globals.ghost_node = getGhostNode(mouse_pos_world, mouse_pos_world, .east, 1);
    } else {
        globals.ghost_node = null;
    }

    resources.render();

    renderAllBelts();

    renderAllItems();

    {
        // render border rect
        var x1 = @intCast(i32, minInt(i8) + levels.current_level.border_size) * 8 - @intCast(i32, globals.camera_pos.x) - 1;
        var y1 = @intCast(i32, minInt(i8) + levels.current_level.border_size) * 8 - @intCast(i32, globals.camera_pos.y) - 1;
        var x2 = @intCast(i32, maxInt(i8) - levels.current_level.border_size) * 8 - @intCast(i32, globals.camera_pos.x) + 8;
        var y2 = @intCast(i32, maxInt(i8) - levels.current_level.border_size) * 8 - @intCast(i32, globals.camera_pos.y) + 8;
        w4.draw_colors.* = 0x4;
        w4.line(x1, y1, x2, y1);
        w4.line(x2, y1, x2, y2);
        w4.line(x2, y2, x1, y2);
        w4.line(x1, y2, x1, y1);
    }

    renderAllStructures();
    if (is_debug_placing) {
        const border_sizes = [_]i8{ 4 * 30, 4 * 29, 4 * 28, 4 * 27, 4 * 26, 4 * 25 };
        for (border_sizes) |border_size| {
            // render border rect
            var x1 = @intCast(i32, minInt(i8) + border_size) * 8 - @intCast(i32, globals.camera_pos.x) - 1;
            var y1 = @intCast(i32, minInt(i8) + border_size) * 8 - @intCast(i32, globals.camera_pos.y) - 1;
            var x2 = @intCast(i32, maxInt(i8) - border_size) * 8 - @intCast(i32, globals.camera_pos.x) + 8;
            var y2 = @intCast(i32, maxInt(i8) - border_size) * 8 - @intCast(i32, globals.camera_pos.y) + 8;
            w4.draw_colors.* = 0x4;
            w4.line(x1, y1, x2, y1);
            w4.line(x2, y1, x2, y2);
            w4.line(x2, y2, x1, y2);
            w4.line(x1, y2, x1, y1);
        }
    }

    if (globals.ghost_node == null) {
        if (selection) |sel| {
            utils.renderSelection(sel);
        }
    }

    if (is_inventory_open) {
        inventory.renderInventory();
    }
    if (is_debug_placing) if (buttons_pressed.button_1) levels.nextLevel();

    globals.t += 1;
    const new_step: i32 = 7 - @intCast(i32, (globals.t / 6) % 8);
    if (new_step != globals.belt_step and new_step == 7) {
        advance();
    }
    globals.belt_step = new_step;
}

fn advance() void {
    for (globals.dead_ends.toSlice()) |id| {
        globals.nodes.items[id].advance(id);
    }
    globals.alternating_sides_flag = !globals.alternating_sides_flag;
    globals.ticks_since_counting += 1;
    if (globals.ticks_since_counting == 1) {
        globals.ticks_since_counting = 0;
        if (levels.level == levels.levels.len) {
            globals.rate = @floatToInt(u16, @floor(@intToFloat(f64, globals.active_count) / 0.8));
            globals.active_count = 0;
        }
    }
}

fn calculateOnScreenNodes() void {
    globals.on_screen_nodes.reset();

    for (globals.nodes.toSlice()) |node, id| {
        if (!globals.screen_box.intersects(node.boundingBox())) continue;
        globals.on_screen_nodes.add(@intCast(u8, id));
    }
}

pub fn sortOnScreenNodes() void {
    const impl = struct {
        fn sortFn(context: void, id_a: u8, id_b: u8) bool {
            _ = context;
            const a = globals.nodes.items[id_a].boundingBox().max.y;
            const b = globals.nodes.items[id_b].boundingBox().max.y;
            return a < b;
        }
    };
    std.sort.sort(u8, globals.on_screen_nodes.toSlice(), {}, impl.sortFn);
}

fn renderAllBelts() void {
    globals.tilemap.reset();
    for (globals.on_screen_nodes.toSlice()) |id| {
        globals.nodes.get(id).renderBelts(false);
    }
    if (!is_wireframe or !is_moving) if (globals.ghost_node) |node| node.renderBelts(is_wireframe);
    renderBeltLines();
}

fn renderBeltLines() void {
    const top_left = Vec2(i32){
        .x = 8 - (globals.camera_pos.x & 7) - 8,
        .y = 8 - (globals.camera_pos.y & 7) - 8,
    };
    var x: u8 = 0;
    while (x < Tilemap.width) : (x += 1) {
        var y: u8 = 0;
        while (y < Tilemap.height) : (y += 1) {
            const pos = top_left.add(.{
                .x = @intCast(i32, x) * 8,
                .y = @intCast(i32, y) * 8,
            });
            if (utils.isOutOfBounds(pos)) {
                w4.draw_colors.* = 0x40;
                w4.blit(&out_of_bounds_texture, pos.x, pos.y, 8, 8, 0);
            } else if (globals.tilemap.get(x, y) and isBelowEmpty(x, y)) {
                Belt.renderLine(pos, false);
            }
        }
    }
}

const out_of_bounds_texture = [8]u8{
    0b00000011,
    0b00000110,
    0b00001100,
    0b00011000,
    0b00110000,
    0b01100000,
    0b11000000,
    0b10000001,
};

fn isBelowEmpty(x: u32, y: u32) bool {
    if (y >= 20) return false;
    return !globals.tilemap.get(x, y + 1);
}

fn renderAllItems() void {
    for (globals.on_screen_nodes.toSlice()) |id| {
        globals.nodes.get(id).renderItems();
    }
}
fn renderAllStructures() void {
    sortOnScreenNodes();
    var has_to_render_ghost_node = globals.ghost_node != null;
    if (is_wireframe and is_moving) has_to_render_ghost_node = false;
    for (globals.on_screen_nodes.toSlice()) |id| {
        const node = globals.nodes.get(id);
        if (has_to_render_ghost_node) {
            if (node.boundingBox().max.y >= globals.ghost_node.?.boundingBox().max.y) {
                globals.ghost_node.?.renderStructure(is_wireframe);
                has_to_render_ghost_node = false;
            }
        }
        node.renderStructure(false);
    }
    if (has_to_render_ghost_node) {
        globals.ghost_node.?.renderStructure(is_wireframe);
    }
}

fn getGhostNode(start_pos: Vec2(i32), current_pos: Vec2(i32), direction: Direction, len: u8) ?Node {
    return switch (inventory.active_slot) {
        0 => getGhostNodeBelt(start_pos, direction, len),
        2 => getGostNodeMiner(start_pos, direction),
        3 => getGhostNodeCutter(start_pos, direction),
        4 => getGhostNodeMerger(start_pos, direction),
        5 => getGhostNodeRotator(start_pos, direction, len),
        6 => getGhostNodeHub(current_pos),
        else => unreachable,
    };
}

fn getGhostNodeBelt(start_pos: Vec2(i32), direction: Direction, len: u8) ?Node {
    const bounding_box = BoundingBox(i32).fromPoints(start_pos, start_pos.add(direction.toVec().scale(len - 1)));
    const a = BoundingBox(i32).fromPoint(start_pos);
    var min_len = len;
    for (globals.on_screen_nodes.toSlice()) |id| {
        const node = globals.nodes.get(id);
        const b = node.boundingBox();
        if (bounding_box.intersects(b)) {
            const dist_vec = a.distance(b);
            const dist = std.math.absCast(if (direction.isHorizontal()) dist_vec.x else dist_vec.y);
            min_len = std.math.min(min_len, dist);
        }
    }

    return Node{ .belt = .{
        .pos = start_pos.intCast(i8),
        .len = min_len - 1,
        .direction = direction,
    } };
}

fn getGostNodeMiner(pos: Vec2(i32), direction: Direction) ?Node {
    const item = resources.getItemAt(pos);
    if (item.eql(Item.empty)) return null;
    return Node{
        .miner = .{
            .pos = pos.intCast(i8),
            .direction = direction,
            .item = item,
        },
    };
}

fn getGhostNodeRotator(start_pos: Vec2(i32), direction: Direction, len: u8) ?Node {
    const bounding_box = BoundingBox(i32).fromPoints(start_pos, start_pos.add(direction.toVec().scale(len - 1)));
    const a = BoundingBox(i32).fromPoint(start_pos);
    var min_len = std.math.min(len, 3);
    for (globals.on_screen_nodes.toSlice()) |id| {
        const node = globals.nodes.get(id);
        const b = node.boundingBox();
        if (bounding_box.intersects(b)) {
            const dist_vec = a.distance(b);
            const dist = std.math.absCast(if (direction.isHorizontal()) dist_vec.x else dist_vec.y);
            min_len = std.math.min(min_len, dist);
        }
    }

    return Node{ .rotator = .{
        .pos = start_pos.intCast(i8),
        .len = min_len - 1,
        .direction = direction,
    } };
}

fn getGhostNodeHub(start_pos: Vec2(i32)) ?Node {
    const hub = Hub{
        .pos = start_pos.add(.{ .x = -2, .y = -2 }).intCast(i8),
    };
    const bounding_box = hub.boundingBox();
    if (utils.isOutOfBounds(utils.worldToScreen(bounding_box.min))) return null;
    if (utils.isOutOfBounds(utils.worldToScreen(bounding_box.max))) return null;
    for (globals.nodes.toSlice()) |node| {
        if (bounding_box.intersects(node.boundingBox())) return null;
    }
    return Node{ .hub = hub };
}

fn getGhostNodeCutter(start_pos: Vec2(i32), direction: Direction) ?Node {
    const cutter = Cutter{
        .pos = start_pos.intCast(i8),
        .direction = direction,
    };
    const bounding_box = cutter.boundingBox();
    if (utils.isOutOfBounds(utils.worldToScreen(bounding_box.min))) return null;
    if (utils.isOutOfBounds(utils.worldToScreen(bounding_box.max))) return null;
    for (globals.nodes.toSlice()) |node| {
        if (bounding_box.intersects(node.boundingBox())) return null;
    }
    return Node{ .cutter = cutter };
}

fn getGhostNodeMerger(start_pos: Vec2(i32), direction: Direction) ?Node {
    const merger = Merger{
        .pos = start_pos.intCast(i8),
        .direction = direction,
    };
    const bounding_box = merger.boundingBox();
    if (utils.isOutOfBounds(utils.worldToScreen(bounding_box.min))) return null;
    if (utils.isOutOfBounds(utils.worldToScreen(bounding_box.max))) return null;
    for (globals.nodes.toSlice()) |node| {
        if (bounding_box.intersects(node.boundingBox())) return null;
    }
    // TODO: collision detection
    return Node{ .merger = merger };
}

fn clampCamPos(cord: *i32) void {
    cord.* = std.math.clamp(
        cord.*,
        (minInt(i8) + @as(i32, levels.current_level.border_size) - 4) * 8,
        (maxInt(i8) - @as(i32, levels.current_level.border_size) - 11 - 4) * 8,
    );
}
