const root = @import("main");
const w4 = @import("wasm4");

const globals = root.globals;
const utils = root.utils;

const Belt = root.nodes.Belt;
const Direction = root.Direction;
const Item = root.Item;
const Vec2 = root.Vec2;

pub fn renderBelt(pos: Vec2(i32), direction: Direction, has_line: bool, is_wireframe: bool) void {
    if (pos.isWithin(globals.screen_box)) {
        if (!is_wireframe) globals.tilemap.set(pos);
        const screen_pos = utils.worldToScreen(pos);
        Belt.renderOnScreen(screen_pos, pos, direction, is_wireframe, globals.t);
        if (has_line) Belt.renderLine(screen_pos, is_wireframe);
    }
}

pub fn renderItem(item: Item, pos: Vec2(i32), direction_coming_from: Direction, is_blocked: bool) void {
    var screen_pos = utils.worldToScreen(pos)
        .add(.{ .x = 2, .y = 2 });
    if (!is_blocked) {
        screen_pos = screen_pos.add(direction_coming_from.toVec().scale(globals.belt_step));
    }
    w4.draw_colors.* = 0x30;
    item.render(screen_pos.x, screen_pos.y);
    w4.draw_colors.* = 0x40;
    item.render(screen_pos.x, screen_pos.y - 1);
}
