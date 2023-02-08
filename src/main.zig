const std = @import("std");
const builtin = @import("builtin");
const w4 = @import("wasm4");

pub const box = @import("box.zig");
pub const font = @import("font.zig");
pub const globals = @import("globals.zig");
pub const levels = @import("levels.zig");
pub const nodes = @import("nodes.zig");
pub const noise = @import("noise.zig");
pub const resources = @import("resources.zig");
pub const rng = @import("rng.zig");
pub const save = @import("save.zig");
pub const utils = @import("utils.zig");

const colors = @import("colors.zig");
const inventory = @import("inventory.zig");

pub const Direction = @import("direction.zig").Direction;
pub const Item = @import("item.zig").Item;
pub const Network = @import("Network.zig");
pub const OnScreenNodes = @import("OnScreenNodes.zig");
pub const Reader = @import("Reader.zig");
pub const Rect = @import("rect.zig").Rect;
pub const Shard = @import("item.zig").Shard;
pub const Slots = @import("Slots.zig");
pub const Tilemap = @import("Tilemap.zig");
pub const Vec2 = @import("vec.zig").Vec2;
pub const Writer = @import("Writer.zig");
pub const Level = @import("levels.zig").Level;
pub const List = @import("list.zig").List;
const GhostNode = @import("GhostNode.zig");

pub const NodeId = Network.NodeId;

const Node = nodes.Node;
const NodeType = nodes.NodeType;
const Belt = nodes.Belt;
const Cutter = nodes.Cutter;
const Merger = nodes.Merger;
const Hub = nodes.Hub;

const minInt = std.math.minInt;
const maxInt = std.math.maxInt;

var ghost_node: ?GhostNode = null;
var on_screen_nodes: OnScreenNodes = .{};
var selected_node_id: ?NodeId = undefined;

// Input
var is_moving = false;
var previous_gamepad = @bitCast(w4.Gamepad, @as(u8, 0));
var previous_mouse_buttons = @bitCast(w4.MouseButtons, @as(u8, 0));
var previous_mouse_pos: Vec2(i32) = undefined;
var start_mouse_world: ?Vec2(i32) = null;

var deleting_type: ?NodeType = null;
var active_direction: Direction = .east;
var inventory_y: i8 = 0;

pub const cheats_enabled = false;

var network_buffer = Network.NetworkBuffer(500){};
var game_network = network_buffer.getNetwork();

export fn start() void {
    if (builtin.is_test) return;

    w4.palette.* = .{
        colors.white,
        colors.grey,
        colors.black,
        colors.organge,
    };

    save.deserialize(&game_network);
}

export fn update() void {
    if (builtin.is_test) return;

    const network = &game_network;

    is_moving = false;

    // handle input

    const buttons_diff = @bitCast(u8, w4.gamepad1.*) ^ @bitCast(u8, previous_gamepad);
    const buttons_pressed = @bitCast(w4.Gamepad, buttons_diff & @bitCast(u8, w4.gamepad1.*));
    const buttons_released = @bitCast(w4.Gamepad, buttons_diff & @bitCast(u8, previous_gamepad));

    _ = buttons_released;

    const mouse_buttons_diff = @bitCast(u8, w4.mouse_buttons.*) ^ @bitCast(u8, previous_mouse_buttons);
    const mouse_buttons_pressed = @bitCast(w4.MouseButtons, mouse_buttons_diff & @bitCast(u8, w4.mouse_buttons.*));
    const mouse_buttons_released = @bitCast(w4.MouseButtons, mouse_buttons_diff & @bitCast(u8, previous_mouse_buttons));

    globals.mouse_pos = Vec2(i32){
        .x = @intCast(i32, std.math.clamp(w4.mouse_x.*, 0, 159)),
        .y = @intCast(i32, std.math.clamp(w4.mouse_y.*, 0, 159)),
    };
    const mouse_pos_world = utils.screenToWorld(globals.mouse_pos);

    if (buttons_pressed.button_2) globals.is_inventory_open = !globals.is_inventory_open;
    const is_mouse_over_inventory = globals.is_inventory_open and globals.mouse_pos.y > 15 * 8;

    if (w4.mouse_buttons.mouse_middle and !mouse_buttons_pressed.mouse_middle) {
        globals.camera_pos = globals.camera_pos.add(
            previous_mouse_pos.subtract(globals.mouse_pos).scale(8),
        );
        is_moving = true;
    }

    if (globals.is_inventory_open) {
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
    previous_mouse_pos = globals.mouse_pos;
    previous_mouse_buttons = w4.mouse_buttons.*;

    const top_left = Vec2(i32){
        .x = -(globals.camera_pos.x & 7),
        .y = -(globals.camera_pos.y & 7),
    };
    const top_left_world = top_left.add(globals.camera_pos).divFloor(8);

    globals.screen_box = Rect(i32){
        .min = top_left_world,
        .max = top_left_world.add(.{ .x = 20, .y = 20 }),
    };

    on_screen_nodes.calculate(network.nodes, globals.screen_box);

    selected_node_id = utils.getSelectedNodeId(network, on_screen_nodes.toSlice(), mouse_pos_world);

    if (buttons_pressed.button_1) {
        if (selected_node_id) |node_id| {
            if (network.nodes[node_id].rotate()) |new_rotation| {
                active_direction = new_rotation;
                network.calculateConnections();
                save.serialize(network);
            }
        } else {
            active_direction = active_direction.rotateClockwise();
        }
    }

    if (!is_mouse_over_inventory and w4.mouse_buttons.mouse_right) if (selected_node_id) |id| {
        const node = network.nodes[id];
        if (deleting_type == null or node == deleting_type.?) {
            network.removeNode(id);
            deleting_type = node;
            selected_node_id = null;

            makeChange(network);
        }
    };
    if (mouse_buttons_released.mouse_right) {
        if (cheats_enabled) w4.trace(std.fmt.bufPrint(&globals.buffer, ".{s} .x = {}, .y = {}{s},", .{ "{", mouse_pos_world.x, mouse_pos_world.y, "}" }) catch unreachable);
        deleting_type = null;
    }

    const is_mouse_within_bounds = !utils.isOutOfBounds(globals.mouse_pos);
    const is_full = network.nodes.len == 256;
    if (mouse_buttons_pressed.mouse_left and selected_node_id == null and !is_mouse_over_inventory and is_mouse_within_bounds and !is_full) {
        start_mouse_world = mouse_pos_world;
    }

    if (w4.mouse_buttons.mouse_left) {
        if (start_mouse_world) |start_pos| {
            const offset = start_pos.subtract(mouse_pos_world);
            const len: i32 = switch (active_direction) {
                .north => std.math.min(offset.y, start_pos.y - std.math.minInt(i8) - levels.current_level.border_size),
                .east => std.math.min(-offset.x, std.math.maxInt(i8) - levels.current_level.border_size - start_pos.x),
                .south => std.math.min(-offset.y, std.math.maxInt(i8) - levels.current_level.border_size - start_pos.y),
                .west => std.math.min(offset.x, start_pos.x - std.math.minInt(i8) - levels.current_level.border_size),
            };

            ghost_node = getGhostNode(network, start_pos, mouse_pos_world, active_direction, len);

            if (ghost_node) |ghost| if (ghost.is_legal and ghost.node.placeOnMouseDown() and selected_node_id == null) {
                placeNode(network, ghost.node);
            };
        }
    } else if (mouse_buttons_released.mouse_left) {
        start_mouse_world = null;

        if (ghost_node) |ghost| if (ghost.is_legal and !ghost.node.placeOnMouseDown()) {
            placeNode(network, ghost.node);
        };
    } else if (selected_node_id == null and !w4.mouse_buttons.mouse_right and !is_mouse_over_inventory and is_mouse_within_bounds and !is_full) {
        ghost_node = getGhostNode(network, mouse_pos_world, mouse_pos_world, active_direction, 0);
    } else {
        ghost_node = null;
    }

    resources.render();

    renderAllBelts(network);

    renderAllItems(network);

    renderBorderRect(levels.current_level.border_size);

    renderAllStructures(network);

    if (ghost_node) |ghost| if (!ghost.is_legal) renderIllegalGhost(ghost.node);

    if (cheats_enabled) {
        const border_sizes = [_]i8{ 4 * 30, 4 * 29, 4 * 28, 4 * 27, 4 * 26, 4 * 25 };
        for (border_sizes) |border_size| {
            renderBorderRect(border_size);
        }
    }

    if (ghost_node) |ghost| {
        if (!is_moving) ghost.node.renderInputsAndOutputs(network);
    } else {
        if (selected_node_id) |node_id| {
            const node = network.nodes[node_id];
            node.renderSelection();
            node.renderInputsAndOutputs(network);
        }
    }

    if (globals.is_inventory_open and inventory_y < 32) {
        inventory_y += 10;
    }
    if (!globals.is_inventory_open and inventory_y > 0) {
        inventory_y -= 10;
    }
    if (inventory_y > 0) {
        inventory.renderInventory(network, inventory_y);
    }

    if (cheats_enabled) if (buttons_pressed.button_1) levels.nextLevel(network);

    globals.t += 1;
    const new_step: i32 = 7 - @intCast(i32, (globals.t / 6) % 8);
    if (new_step != globals.belt_step and new_step == 7) {
        network.advance();
    }
    globals.belt_step = new_step;
}

fn renderBorderRect(border_size: i8) void {
    const side_length = (256 - @intCast(u32, border_size) * 2) * 8 + 2;

    const x = @intCast(i32, minInt(i8) + border_size) * 8 - globals.camera_pos.x - 1;
    const y = @intCast(i32, minInt(i8) + border_size) * 8 - globals.camera_pos.y - 1;

    w4.draw_colors.* = 0x10;
    w4.rect(x, y, side_length, side_length);
    w4.draw_colors.* = 0x20;
    w4.rect(x - 1, y - 1, side_length + 2, side_length + 2);
}

fn renderAllBelts(network: *const Network) void {
    globals.tilemap.reset();
    for (on_screen_nodes.toSlice()) |id| {
        if (Network.getFlag(id)) continue;
        network.nodes[id].renderBelts(false);
    }
    if (ghost_node) |ghost| if (ghost.is_legal) ghost.node.renderBelts(false);

    renderBeltLines();
}

fn renderBeltLines() void {
    const top_left = Vec2(i32){
        .x = -(globals.camera_pos.x & 7),
        .y = -(globals.camera_pos.y & 7),
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
                w4.draw_colors.* = 0x20;
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

fn renderAllItems(network: *const Network) void {
    for (on_screen_nodes.toSlice()) |id| {
        if (Network.getFlag(id)) continue;
        network.nodes[id].renderItems();
    }
}
fn renderAllStructures(network: *const Network) void {
    var has_to_render_ghost_node = ghost_node != null and ghost_node.?.is_legal;
    for (on_screen_nodes.toSlice()) |id| {
        const id_mask = ~@as(NodeId, 0b1 << 15);
        const masked_id = id & id_mask;
        const is_exit = Network.getFlag(id);
        const node = network.nodes[masked_id];
        if (has_to_render_ghost_node) {
            if (node.boundingBox().max.y >= ghost_node.?.node.boundingBox().max.y) {
                ghost_node.?.node.renderStructure(false, true);
                ghost_node.?.node.renderStructure(false, false);
                has_to_render_ghost_node = false;
            }
        }
        node.renderStructure(false, is_exit);
    }
    if (has_to_render_ghost_node) {
        ghost_node.?.node.renderStructure(false, true);
        ghost_node.?.node.renderStructure(false, false);
    }
}

fn renderIllegalGhost(node: Node) void {
    node.renderBelts(true);
    node.renderStructure(true, true);
    node.renderStructure(true, false);
}

fn placeNode(network: *Network, node: Node) void {
    network.addNode(node);
    ghost_node = null;

    makeChange(network);

    const mouse_pos_world = utils.screenToWorld(globals.mouse_pos);
    selected_node_id = utils.getSelectedNodeId(network, on_screen_nodes.toSlice(), mouse_pos_world);
}

fn makeChange(network: *Network) void {
    network.calculateConnections();
    save.serialize(network);
    on_screen_nodes.calculate(network.nodes, globals.screen_box);
}

fn getGhostNode(network: *const Network, start_pos: Vec2(i32), current_pos: Vec2(i32), direction: Direction, input_len: i32) ?GhostNode {
    const origin: Vec2(i32) = start_pos;
    const len = @intCast(u8, std.math.max(input_len, 0)); // TODO #156 allow dragging in the opposite direction
    return switch (inventory.activeNodeType()) {
        .belt => getGhostNodeBelt(network, origin, direction, len),
        .tunnel => getGhostNodeTunnel(network, origin, direction, len),
        .miner => getGostNodeMiner(current_pos, direction),
        .cutter => getGhostNodeCutter(network, current_pos, direction),
        .merger => getGhostNodeMerger(network, current_pos, direction),
        .rotator => getGhostNodeRotator(network, origin, direction, len),
        .hub => getGhostNodeHub(network, current_pos),
        else => unreachable,
    };
}

fn getGhostNodeBelt(network: *const Network, start_pos: Vec2(i32), direction: Direction, input_len: u8) ?GhostNode {
    const len = limitNodeLength(network, start_pos, direction, input_len, nodes.Belt.max_length - 1);

    const node = Node{ .belt = .{
        .pos = start_pos.intCast(i8),
        .len = len,
        .direction = direction,
    } };

    return GhostNode{ .node = node, .is_legal = true };
}

fn getGhostNodeTunnel(network: *const Network, start_pos: Vec2(i32), direction: Direction, input_len: u8) ?GhostNode {
    const len = std.math.min(input_len, nodes.Tunnel.max_length - 1);
    const exit = Rect(i32).fromPoint(start_pos.add(direction.toVec().scale(len)));

    const is_legal = len > 0 and for (on_screen_nodes.toSlice()) |id| {
        if (Network.getFlag(id)) continue;
        const node = network.nodes[id];
        if (node.intersects(exit)) break false;
    } else true;
    const node = Node{ .tunnel = .{
        .pos = start_pos.intCast(i8),
        .len = len,
        .direction = direction,
    } };

    return GhostNode{ .node = node, .is_legal = is_legal };
}

fn getGostNodeMiner(pos: Vec2(i32), direction: Direction) ?GhostNode {
    const item = resources.getItemAt(pos);

    const node = Node{ .miner = .{
        .pos = pos.intCast(i8),
        .direction = direction,
        .item = item,
    } };
    const is_legal = !item.eql(Item.empty);

    return GhostNode{ .node = node, .is_legal = is_legal };
}

fn getGhostNodeRotator(network: *const Network, start_pos: Vec2(i32), direction: Direction, input_len: u8) ?GhostNode {
    const len = limitNodeLength(network, start_pos, direction, input_len, nodes.Rotator.max_length - 1);

    const node = Node{ .rotator = .{
        .pos = start_pos.intCast(i8),
        .len = len,
        .direction = direction,
    } };

    return GhostNode{ .node = node, .is_legal = true };
}

fn getGhostNodeHub(network: *const Network, pos: Vec2(i32)) ?GhostNode {
    const border_size = levels.current_level.border_size;
    const min = minInt(i8) + border_size;
    const max = maxInt(i8) - border_size - 4;
    const origin = pos.add(.{ .x = -2, .y = -2 }).clamp(
        .{ .x = min, .y = min },
        .{ .x = max, .y = max },
    );
    const hub = Hub{
        .pos = origin.intCast(i8),
    };
    const bounding_box = hub.boundingBox();
    if (isBoundingBoxOutOfBounds(bounding_box)) return null;

    const node = Node{ .hub = hub };
    const is_legal = intersectsWithNode(network, bounding_box);

    return GhostNode{ .node = node, .is_legal = is_legal };
}

fn getGhostNodeCutter(network: *const Network, start_pos: Vec2(i32), direction: Direction) ?GhostNode {
    const cutter = Cutter{
        .pos = start_pos.intCast(i8),
        .direction = direction,
    };
    const bounding_box = cutter.boundingBox();
    if (isBoundingBoxOutOfBounds(bounding_box)) return null;

    const node = Node{ .cutter = cutter };

    const is_legal = intersectsWithNode(network, bounding_box);

    return GhostNode{ .node = node, .is_legal = is_legal };
}

fn getGhostNodeMerger(network: *const Network, start_pos: Vec2(i32), direction: Direction) ?GhostNode {
    const merger = Merger{
        .pos = start_pos.intCast(i8),
        .direction = direction,
    };
    const bounding_box = merger.boundingBox();
    if (isBoundingBoxOutOfBounds(bounding_box)) return null;

    const node = Node{ .merger = merger };
    const is_legal = intersectsWithNode(network, bounding_box);

    return GhostNode{ .node = node, .is_legal = is_legal };
}

fn intersectsWithNode(network: *const Network, bounding_box: Rect(i32)) bool {
    return for (network.nodes) |node| {
        if (node.intersects(bounding_box)) break false;
    } else true;
}

fn isBoundingBoxOutOfBounds(bounding_box: Rect(i32)) bool {
    return utils.isOutOfBounds(utils.worldToScreen(bounding_box.min)) or utils.isOutOfBounds(utils.worldToScreen(bounding_box.max));
}

/// Limits the length when colliding with a node
fn limitNodeLength(network: *const Network, start_pos: Vec2(i32), direction: Direction, input_len: u8, max_length: u8) u8 {
    var len = std.math.min(input_len, max_length);
    const bounding_box = Rect(i32).fromPoints(start_pos, start_pos.add(direction.toVec().scale(len)));
    const a = Rect(i32).fromPoint(start_pos);
    for (on_screen_nodes.toSlice()) |id| {
        if (Network.getFlag(id)) continue;
        const node = network.nodes[id];
        if (node.getIntersection(bounding_box)) |intersection| {
            const dist_vec = a.distance(intersection);
            const dist = std.math.absCast(if (direction.isHorizontal()) dist_vec.x else dist_vec.y) - 1;
            len = std.math.min(len, dist);
        }
    }
    return len;
}

fn clampCamPos(cord: *i32) void {
    cord.* = std.math.clamp(
        cord.*,
        (minInt(i8) + @as(i32, levels.current_level.border_size) - 4) * 8,
        (maxInt(i8) - @as(i32, levels.current_level.border_size) - 11 - 4) * 8,
    );
}

pub fn panic(msg: []const u8, stack_trace: ?*std.builtin.StackTrace, _: ?usize) noreturn {
    _ = stack_trace;
    if (@import("builtin").mode == .Debug) {
        w4.trace(msg);
    }
    unreachable;
}

test {
    _ = std.testing.refAllDecls(@This());
}
