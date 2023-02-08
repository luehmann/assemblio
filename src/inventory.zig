const std = @import("std");
const root = @import("main");
const w4 = @import("wasm4");

const font = root.font;
const globals = root.globals;
const levels = root.levels;
const nodes = root.nodes;
const utils = root.utils;

const Direction = root.Direction;
const Item = root.Item;
const Rect = root.Rect;
const Vec2 = root.Vec2;
const Network = root.Network;

const Belt = nodes.Belt;
const Tunnel = nodes.Tunnel;
const Miner = nodes.Miner;
const Merger = nodes.Merger;
const Cutter = nodes.Cutter;
const Rotator = nodes.Rotator;
const NodeType = nodes.NodeType;

const fmt = utils.fmt;

const slot_levels: [7]u8 = if (root.cheats_enabled) std.mem.zeroes([7]u8) else [7]u8{ 0, 6, 0, 1, 6, 2, 0 };

var active_slot: i32 = 0;
var animation_t: u32 = 0;

pub fn activeNodeType() NodeType {
    return @intToEnum(NodeType, active_slot);
}

pub fn changeSlot(direction: i8) void {
    animation_t = 0;
    active_slot += direction;
    active_slot = @mod(active_slot, 7);
    while (isSlotLocked(@intCast(usize, active_slot))) active_slot += direction;
}

pub fn renderInventory(network: *const Network, inventory_open: i32) void {
    const inventory_y = w4.canvas_size - inventory_open;
    const mouse_pos = Vec2(i32){ .x = w4.mouse_x.*, .y = w4.mouse_y.* };

    var hover_slot: ?i8 = null;
    for (slot_levels) |_, i| {
        if (isSlotLocked(i)) continue;
        const bounding_box = slotRect(@intCast(i32, i));
        if (mouse_pos.isWithin(bounding_box)) {
            hover_slot = @intCast(i8, i);
            if (w4.mouse_buttons.mouse_left) {
                globals.is_inventory_open = false;
                active_slot = @intCast(i8, i);
            }
            break;
        }
    }

    const selected_slot = hover_slot orelse active_slot;

    w4.draw_colors.* = 0x1;
    w4.rect(0, inventory_y, w4.canvas_size, 5 * 8);
    w4.draw_colors.* = 0x3;
    w4.hline(0, inventory_y + 1, w4.canvas_size);

    w4.draw_colors.* = 0x30;
    font.renderTextAligned("INVENTORY", 3, inventory_y + 6, .left);

    var tool_name = toolName(selected_slot);
    // max_storage - bytes_reserved
    const max_budget = 1024 - 30; // TODO: move to constants
    const budged_used = calculateBudget(network);
    const is_full = budged_used == max_budget;
    if (is_full) {
        // w4.draw_colors.* = 0x40;
        tool_name = "NO BUILDINGS LEFT";
    }
    font.renderTextAligned(tool_name, 160 / 2, inventory_y + 6, .center);
    const current_budget = fmt("{}/{}", .{ max_budget - budged_used, max_budget });
    font.renderTextAligned(current_budget, 158, inventory_y + 6, .right);

    for (slot_levels) |_, i| {
        const pos = Vec2(i32){
            .x = 6 + 22 * @intCast(i32, i),
            .y = inventory_y + 15,
        };
        if (isSlotLocked(i)) {
            renderLock(pos);
        } else {
            const is_active = selected_slot == i and !is_full;
            switch (i) {
                0 => renderBeltSlot(pos, is_active),
                1 => renderTunnelSlot(pos, is_active),
                2 => renderMineSlot(pos, is_active),
                3 => renderCutterSlot(pos, is_active),
                4 => renderMergerSlot(pos, is_active),
                5 => renderRotatorSlot(pos, is_active),
                6 => renderHubSlot(pos, is_active),
                else => {},
            }
            if (is_active) renderSideOverlays(pos);
        }
    }
    if (!is_full) {
        w4.draw_colors.* = 0x20;
        renderSlotSelection(active_slot, inventory_y);
        w4.draw_colors.* = 0x40;
        renderSlotSelection(selected_slot, inventory_y);
    }

    animation_t += 1;
}

fn isSlotLocked(slot: usize) bool {
    return levels.level < slot_levels[slot];
}

fn calculateBudget(network: *const Network) u32 {
    var accumulator: u32 = 0;
    for (network.nodes) |node| {
        accumulator += node.cost();
    }
    return accumulator;
}

pub fn toolName(slot: i32) []const u8 {
    return switch (slot) {
        0 => "BELT",
        1 => "TUNNEL",
        2 => "MINER",
        3 => "CUTTER",
        4 => "MERGER",
        5 => "ROTATOR",
        6 => "HUB",
        else => unreachable,
    };
}

fn renderBeltSlot(pos: Vec2(i32), is_active: bool) void {
    const idle_t = 6 * 4;
    const t = if (is_active) animation_t + idle_t else idle_t;
    renderBelt(pos.add(.{ .x = 0, .y = 7 }), .{ .x = 0, .y = 0 }, .east, t, true);
    renderBelt(pos.add(.{ .x = 8, .y = 7 }), .{ .x = 1, .y = 0 }, .east, t, true);
    if (is_active) {
        const belt_step = 23 - @intCast(i32, (t / 6) % 24);
        renderItem(Item.circle, pos.add(.{ .x = 16, .y = 7 }), .west, belt_step);
    }
}

fn renderTunnelSlot(pos: Vec2(i32), is_active: bool) void {
    const idle_t = 6 * 4;
    const t = if (is_active) animation_t + idle_t else idle_t;
    renderBelt(pos.add(.{ .x = 4, .y = 3 }), .{ .x = 0, .y = 0 }, .north, t, false);
    renderBelt(pos.add(.{ .x = 4, .y = 11 }), .{ .x = 0, .y = 1 }, .north, t, true);
    Tunnel.renderOnScreen(pos.add(.{ .x = 4, .y = 3 }), .north, .entrance, false);
}

fn renderMineSlot(pos: Vec2(i32), is_active: bool) void {
    const idle_t = 12;
    const t = if (is_active) animation_t + idle_t else idle_t;
    renderBelt(pos.add(.{ .x = 4, .y = 3 }), .{ .x = 0, .y = 0 }, .south, t, false);
    renderBelt(pos.add(.{ .x = 4, .y = 11 }), .{ .x = 0, .y = 1 }, .south, t, true);
    Miner.renderOnScreen(pos.add(.{ .x = 4, .y = 3 }), Item.ring, true, false, t);
}

fn renderCutterSlot(pos: Vec2(i32), is_active: bool) void {
    const idle_t = 6 * 4;
    const t = if (is_active) animation_t + idle_t else idle_t;
    renderBelt(pos.add(.{ .x = 0, .y = 3 }), .{ .x = 0, .y = 0 }, .east, t, true);
    renderBelt(pos.add(.{ .x = 8, .y = 3 }), .{ .x = 1, .y = 0 }, .east, t, false);
    renderBelt(pos.add(.{ .x = 8, .y = 11 }), .{ .x = 1, .y = 1 }, .east, t, true);
    Cutter.renderOnScreen(pos.add(.{ .x = 4, .y = 3 }), .east, false, t);
}

pub fn renderMergerSlot(pos: Vec2(i32), is_active: bool) void {
    const idle_t = 6 * 4;
    const t = if (is_active) animation_t + idle_t else idle_t;
    renderBelt(pos.add(.{ .x = 0, .y = 3 }), .{ .x = 0, .y = 0 }, .east, t, false);
    renderBelt(pos.add(.{ .x = 0, .y = 11 }), .{ .x = 0, .y = 1 }, .east, t, true);
    renderBelt(pos.add(.{ .x = 8, .y = 3 }), .{ .x = 1, .y = 0 }, .east, t, true);
    Merger.renderOnScreen(pos.add(.{ .x = 4, .y = 3 }), .east, false, t);
}

pub fn renderRotatorSlot(pos: Vec2(i32), is_active: bool) void {
    const idle_t = 6 * 4;
    const t = if (is_active) animation_t + idle_t else idle_t;
    renderBelt(pos.add(.{ .x = 0, .y = 7 }), .{ .x = 0, .y = 0 }, .east, t, true);
    renderBelt(pos.add(.{ .x = 8, .y = 7 }), .{ .x = 1, .y = 0 }, .east, t, true);
    Rotator.renderOnScreen(pos.add(.{ .x = 4, .y = 7 }), .east, false);
}

fn renderHubSlot(pos: Vec2(i32), is_active: bool) void {
    const idle_t = 6 * 4;
    const t = if (is_active) animation_t + idle_t else idle_t;
    renderBelt(pos.add(.{ .x = 0, .y = 3 }), .{ .x = 0, .y = 0 }, .east, t, true);
    renderBelt(pos.add(.{ .x = 8, .y = 11 }), .{ .x = 1, .y = 1 }, .north, t, true);
    w4.draw_colors.* = 0x130;
    w4.blit(&hubicon, pos.x, pos.y, hubicon_width, hubicon_height, 1);
}

const hubicon_width = 16;
const hubicon_height = 15;
const hubicon_flags = 1; // BLIT_2BPP
const hubicon = [60]u8{ 0x00, 0x55, 0x55, 0x55, 0x00, 0x6a, 0xaa, 0xa9, 0x00, 0x6a, 0xaa, 0xa9, 0x00, 0x6a, 0xaa, 0xa9, 0x00, 0x6a, 0xaa, 0xa9, 0x00, 0x6a, 0xaa, 0xa9, 0x00, 0x6a, 0xaa, 0xa9, 0x00, 0x6a, 0xaa, 0xa9, 0x00, 0x55, 0xaa, 0xa9, 0x00, 0x69, 0xaa, 0xa9, 0x00, 0x69, 0xaa, 0xa9, 0x00, 0x69, 0x55, 0x55, 0x00, 0x01, 0x40, 0x01, 0x00, 0x01, 0x40, 0x01, 0x00, 0x01, 0x40, 0x01 };

fn renderBelt(screen_pos: Vec2(i32), world_pos: Vec2(i32), direction: Direction, t: u32, is_end: bool) void {
    Belt.renderOnScreen(screen_pos, world_pos, direction, false, t);
    if (is_end) Belt.renderLine(screen_pos, false);
}

fn renderItem(item: Item, pos: Vec2(i32), direction: Direction, belt_step: i32) void {
    var screen_pos = pos.add(.{ .x = 2, .y = 2 }).add(direction.toVec().scale(belt_step));

    w4.draw_colors.* = 0x30;
    item.render(screen_pos.x, screen_pos.y);
    w4.draw_colors.* = 0x40;
    item.render(screen_pos.x, screen_pos.y - 1);
}

fn renderSideOverlays(pos: Vec2(i32)) void {
    w4.draw_colors.* = 0x1;
    w4.rect(pos.x - 6, pos.y, 6, 24);
    w4.rect(pos.x + 16, pos.y, 6, 24);
}

const selection_texture = [8]u8{
    0b00011111,
    0b00011111,
    0b00000011,
    0b00000011,
    0b00000011,
    0b00000000,
    0b00000000,
    0b00000000,
};

const lock_shackle_texture = [6]u8{
    0b11000011,
    0b10000001,
    0b10011001,
    0b10011001,
    0b11111001,
    0b11111001,
};

fn renderLock(pos: Vec2(i32)) void {
    w4.draw_colors.* = 0x2;
    w4.blit(&lock_shackle_texture, pos.x + 4, pos.y + 5, 8, 6, 0);
    w4.rect(pos.x + 3, pos.y + 9, 10, 8);
}

fn renderSlotSelection(slot: i32, inventory_y: i32) void {
    std.debug.assert(0 <= slot and slot <= 6);
    const pos = Vec2(i32){
        .x = 3 + 22 * slot,
        .y = inventory_y + 15,
    };
    w4.blit(&selection_texture, pos.x + 14, pos.y, 8, 8, 0);
    w4.blit(&selection_texture, pos.x, pos.y, 8, 8, w4.BLIT_FLIP_X);
    w4.blit(&selection_texture, pos.x, pos.y + 14, 8, 8, w4.BLIT_FLIP_X | w4.BLIT_FLIP_Y);
    w4.blit(&selection_texture, pos.x + 14, pos.y + 14, 8, 8, w4.BLIT_FLIP_Y);
}

fn slotRect(slot: i32) Rect(i32) {
    std.debug.assert(0 <= slot and slot <= 6);
    const pos = Vec2(i32){
        .x = 3 + 22 * slot,
        .y = 135,
    };
    return Rect(i32){
        .min = pos,
        .max = pos.add(.{ .x = 21, .y = 21 }),
    };
}
