const root = @import("main");

const constants = root.constants;

const Network = root.Network;
const Rect = root.Rect;
const Tilemap = root.Tilemap;
const Vec2 = root.Vec2;

const Node = root.nodes.Node;

pub var tilemap: Tilemap = undefined;

pub var mouse_pos: Vec2(i32) = undefined;

pub var screen_box: Rect(i32) = undefined;

pub var camera_pos = Vec2(i32){ .x = -80, .y = -80 };

pub var t: u32 = 0;
pub var belt_step: i32 = 7;

pub var buffer: [1024]u8 = undefined;
pub var is_inventory_open = false;

pub var active_count: u16 = 0;
pub var rate: ?u16 = null;
