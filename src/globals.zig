const Node = @import("nodes.zig").Node;
const Vec2 = @import("vec.zig").Vec2;
const constants = @import("constants.zig");
const Connection = @import("Connection.zig");
const List = @import("list.zig").List;
const BoundingBox = @import("bounding_box.zig").BoundingBox;
const Tilemap = @import("Tilemap.zig");

pub const NodeId = u8;

pub var nodes = List(Node, constants.max_node_count){};
pub var ghost_node: ?Node = null;

pub var on_screen_nodes = List(NodeId, constants.max_node_count){};

pub var tilemap: Tilemap = undefined;

pub var screen_box: BoundingBox(i32) = undefined;

pub var camera_pos = Vec2(i32){ .x = -80, .y = -80 };

pub var t: u32 = 0;
pub var belt_step: i32 = 7;

pub var connections = List(Connection, constants.max_node_count * 2){};
pub var dead_ends = List(NodeId, constants.max_node_count * 2){};

pub var buffer: [1024]u8 = undefined;

pub var alternating_sides_flag = false;

pub var active_count: u16 = 0;
pub var rate: ?u16 = null;
pub var ticks_since_counting: u8 = 0;
