const std = @import("std");
const w4 = @import("wasm4.zig");
const utils = @import("utils.zig");
const globals = @import("globals.zig");
const Vec2 = @import("vec.zig").Vec2;
const Item = @import("item.zig").Item;
const Direction = @import("direction.zig").Direction;
const font = @import("font.zig");
const Belt = @import("nodes/Belt.zig");
const Miner = @import("nodes/Miner.zig");
const Rotator = @import("nodes/Rotator.zig");
const Cutter = @import("nodes/Cutter.zig");
const Merger = @import("nodes/Merger.zig");
const levels = @import("levels.zig");
const BoundingBox = @import("bounding_box.zig").BoundingBox;

pub var active_slot: i8 = 0;
const slot_levels = [7]u8{ 0, 255, 0, 1, 6, 2, 0 };

var animation_t: u32 = 0;

pub fn changeSlot(direction: i8) void {
    animation_t = 0;
    active_slot += direction;
    active_slot = @mod(active_slot, 7);
    while (isSlotLocked(@intCast(usize, active_slot))) : (active_slot += direction) {}
}

fn isSlotLocked(slot: usize) bool {
    return levels.level < slot_levels[slot];
}

pub fn toolName(slot: i8) []const u8 {
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

pub fn renderInventory() void {
    const mouse_pos = Vec2(i32){ .x = w4.mouse_x.*, .y = w4.mouse_y.* };

    var hover_slot: ?i8 = null;
    const arr: [7]u8 = undefined;
    for (arr) |_, i| {
        if (isSlotLocked(i)) continue;
        const bounding_box = slotBoundingBox(@intCast(i32, i));
        if (mouse_pos.isWithin(bounding_box)) {
            hover_slot = @intCast(i8, i);
            if (w4.mouse_buttons.mouse_left) active_slot = @intCast(i8, i);
            break;
        }
    }

    const selected_slot = hover_slot orelse active_slot;

    w4.draw_colors.* = 0x1;
    w4.rect(0, 15 * 8, 160, 5 * 8);
    w4.draw_colors.* = 0x3;
    w4.line(0, 15 * 8 + 1, 159, 15 * 8 + 1);

    w4.draw_colors.* = 0x30;
    font.text("INVENTORY", 3, 15 * 8 + 6);
    var tool_name = toolName(selected_slot);
    const is_full = globals.nodes.len == 256;
    if (is_full) {
        // w4.draw_colors.* = 0x40;
        tool_name = "NO BUILDINGS LEFT";
    }
    font.text(tool_name, 160 / 2 - @intCast(i32, tool_name.len * 4 / 2), 15 * 8 + 6);
    const current_budget = std.fmt.bufPrint(&globals.buffer, "{}/{}", .{ 256 - globals.nodes.len, 256 }) catch unreachable;
    font.text(current_budget, 158 - 4 * @intCast(i32, current_budget.len), 15 * 8 + 6);

    for (arr) |_, i| {
        const pos = Vec2(i32){
            .x = 6 + 22 * @intCast(i32, i),
            .y = 135,
        };
        if (isSlotLocked(i)) {
            w4.draw_colors.* = 0x20;
            w4.blit(&lock_texture, pos.x, pos.y + 5, 16, 12, 0);
        } else {
            const is_active = selected_slot == i and !is_full;
            switch (i) {
                0 => renderBeltSlot(pos, is_active),
                2 => renderMineSlot(pos, is_active),
                3 => renderCutterSlot(pos, is_active),
                4 => renderMergerSlot(pos, is_active),
                5 => renderRotatorSlot(pos, is_active),
                6 => renderHubSlot(pos, is_active),
                else => {},
            }
        }
    }
    if (!is_full) {
        w4.draw_colors.* = 0x20;
        renderSlotSelection(active_slot);
        w4.draw_colors.* = 0x40;
        renderSlotSelection(selected_slot);
    }

    animation_t += 1;
}

fn renderBeltSlot(pos: Vec2(i32), is_active: bool) void {
    const idle_t = 6 * 4;
    const t = if (is_active) animation_t + idle_t else idle_t;
    renderBelt(pos.add(.{ .x = 0, .y = 7 }), .{ .x = 0, .y = 0 }, .east, t, true);
    renderBelt(pos.add(.{ .x = 8, .y = 7 }), .{ .x = 1, .y = 0 }, .east, t, true);
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

const lock_texture = [24]u8{
    0b00000011,
    0b11000000,
    0b00000111,
    0b11100000,
    0b00000110,
    0b01100000,
    0b00000110,
    0b01100000,
    0b00011111,
    0b11111000,
    0b00011111,
    0b11111000,
    0b00011111,
    0b11111000,
    0b00011111,
    0b11111000,
    0b00011111,
    0b11111000,
    0b00011111,
    0b11111000,
    0b00011111,
    0b11111000,
    0b00011111,
    0b11111000,
};

fn renderSlotSelection(slot: i32) void {
    std.debug.assert(0 <= slot and slot <= 6);
    const pos = Vec2(i32){
        .x = 3 + 22 * slot,
        .y = 135,
    };
    w4.blit(&selection_texture, pos.x + 14, pos.y, 8, 8, 0);
    w4.blit(&selection_texture, pos.x, pos.y, 8, 8, w4.BLIT_FLIP_X);
    w4.blit(&selection_texture, pos.x, pos.y + 14, 8, 8, w4.BLIT_FLIP_X | w4.BLIT_FLIP_Y);
    w4.blit(&selection_texture, pos.x + 14, pos.y + 14, 8, 8, w4.BLIT_FLIP_Y);
}

fn slotBoundingBox(slot: i32) BoundingBox(i32) {
    std.debug.assert(0 <= slot and slot <= 6);
    const pos = Vec2(i32){
        .x = 3 + 22 * slot,
        .y = 135,
    };
    return BoundingBox(i32){
        .min = pos,
        .max = pos.add(.{ .x = 21, .y = 21 }),
    };
}
