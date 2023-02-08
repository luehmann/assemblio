const std = @import("std");
const root = @import("main");

const globals = root.globals;

const Node = root.nodes.Node;
const NodeId = root.NodeId;
const Rect = root.Rect;

nodes: [21 * 21]NodeId = undefined,
bucket_sizes: [21]u8 = std.mem.zeroes([21]u8),
len: usize = undefined,

const Self = @This();

/// Collects all the on-screen nodes sorted top to buttom
/// Uses 21 buckets for each on-screen row of tiles
/// Removes gap between buckets afterwards
pub fn calculate(self: *Self, nodes: []const Node, screen_box: Rect(i32)) void {
    self.bucket_sizes = std.mem.zeroes([21]u8);

    self.collectNodesToBuckets(nodes, screen_box);

    self.removePadding();
}

/// Asks all nodes to add themselves using `addToBucket` if they are on-screen
fn collectNodesToBuckets(self: *Self, nodes: []const Node, screen_box: Rect(i32)) void {
    for (nodes) |node, id| {
        node.checkOnScreen(self, screen_box, @intCast(NodeId, id));
    }
}

/// Moves all node ids from the buckets into contiguous memory
fn removePadding(self: *Self) void {
    var accumulator: usize = 0;
    for (self.bucket_sizes) |bucket_size, bucket| {
        const id_size = @sizeOf(NodeId);
        const ptr = @ptrCast([*]align(2) u8, &self.nodes);
        // TODO: the first memcopy is redundant
        @memcpy(ptr + accumulator * id_size, ptr + bucket * 21 * id_size, bucket_size * id_size);
        accumulator += bucket_size;
    }
    self.len = accumulator;
}

test "removePadding" {
    var on_screen_nodes: Self = .{};
    on_screen_nodes.bucket_sizes[0] = 3;
    on_screen_nodes.nodes[0] = 1;
    on_screen_nodes.nodes[1] = 2;
    on_screen_nodes.nodes[2] = 3;

    on_screen_nodes.bucket_sizes[1] = 1;
    on_screen_nodes.nodes[21 * 1] = 4;

    on_screen_nodes.bucket_sizes[6] = 2;
    on_screen_nodes.nodes[21 * 6] = 5;
    on_screen_nodes.nodes[21 * 6 + 1] = 6;

    on_screen_nodes.removePadding();

    try std.testing.expectEqualSlices(NodeId, &[6]NodeId{ 1, 2, 3, 4, 5, 6 }, on_screen_nodes.nodes[0..on_screen_nodes.len]);
}

pub fn addToBucket(self: *Self, y_position: i32, node_id: NodeId) void {
    const screen_y = y_position - @divFloor(globals.camera_pos.y, 8); // TODO: consider letting caller pass in screen_box.min.y
    const bucket = @intCast(usize, std.math.max(screen_y, 0));
    self.nodes[bucket * 21 + self.bucket_sizes[bucket]] = node_id;
    std.debug.assert(self.bucket_sizes[bucket] < 200); // TODO: check if 200 is right
    self.bucket_sizes[bucket] += 1;
}

test "addToBucket" {
    globals.camera_pos.y = 0;
    var on_screen_nodes: Self = .{};

    on_screen_nodes.addToBucket(0, 42);
    on_screen_nodes.addToBucket(0, 43);
    try std.testing.expectEqual(@as(usize, 2), on_screen_nodes.bucket_sizes[0]);
    try std.testing.expectEqual(@as(NodeId, 42), on_screen_nodes.nodes[0]);
    try std.testing.expectEqual(@as(NodeId, 43), on_screen_nodes.nodes[1]);

    on_screen_nodes.addToBucket(12, 33);
    try std.testing.expectEqual(@as(usize, 1), on_screen_nodes.bucket_sizes[12]);
    try std.testing.expectEqual(@as(NodeId, 33), on_screen_nodes.nodes[21 * 12]);
}

pub fn toSlice(self: *const Self) []const NodeId {
    return self.nodes[0..self.len];
}

test "toSlice" {
    var on_screen_nodes: Self = .{};
    on_screen_nodes.nodes[0] = 1;
    on_screen_nodes.nodes[1] = 2;
    on_screen_nodes.nodes[2] = 3;
    on_screen_nodes.len = 3;

    try std.testing.expectEqualSlices(NodeId, &[3]NodeId{ 1, 2, 3 }, on_screen_nodes.toSlice());
}
