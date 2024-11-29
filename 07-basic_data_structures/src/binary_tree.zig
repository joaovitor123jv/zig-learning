const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const p = std.debug.print;

const Node = struct {
    left: ?*Node, // left.value is smaller than self.value
    right: ?*Node, // right.value is bigger or equal self.value
    parent: ?*Node,
    value: u32,

    fn getSmallestNode(self: *Node) *Node {
        if (self.left) |left| {
            return left.getSmallestNode();
        }
        return self;
    }

    fn insert(self: *Node, value: u32, allocator: std.mem.Allocator) !void {
        if (value < self.value) {
            if (self.left) |left| return try left.insert(value, allocator);

            self.left = try allocator.create(Node);
            self.left.?.left = null;
            self.left.?.right = null;
            self.left.?.value = value;
            self.left.?.parent = self;
            return;
        } else if (self.right) |right| {
            return try right.insert(value, allocator);
        }

        self.right = try allocator.create(Node);
        self.right.?.left = null;
        self.right.?.right = null;
        self.right.?.value = value;
        self.right.?.parent = self;
    }

    fn printTree(self: *Node, level: u32) void {
        if (self.parent) |parent| {
            std.debug.print("\tel_{} -> el_{};\n", .{ parent.value, self.value });
        }
        if (self.left) |left| {
            left.printTree(level + 1);
        } else std.debug.print("\tel_{} -> null_l_{}\n", .{ self.value, self.value });

        if (self.right) |right| {
            right.printTree(level + 1);
        } else std.debug.print("\tel_{} -> null_r_{}\n", .{ self.value, self.value });
    }
};

test "can insert node on node" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var parentNode: *Node = try allocator.create(Node);
    defer allocator.destroy(parentNode);
    parentNode.value = 10;
    parentNode.left = null;

    var node: *Node = try allocator.create(Node);
    defer allocator.destroy(node);
    node.left = null;
    node.right = null;
    parentNode.right = node;
    node.parent = parentNode;
    node.value = 10;

    try expectEqual(null, node.left);
    try expectEqual(null, node.right);

    try node.insert(9, allocator);
    defer allocator.destroy(node.left.?);

    try expectEqual(9, node.left.?.value);
    try expectEqual(null, node.right);

    try node.insert(11, allocator);
    defer allocator.destroy(node.right.?);
    try expectEqual(9, node.left.?.value);
    try expectEqual(11, node.right.?.value);
}

test "can get smallest node of node" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var parentNode: *Node = try allocator.create(Node);
    defer allocator.destroy(parentNode);
    parentNode.value = 10;
    parentNode.left = null;

    var node: *Node = try allocator.create(Node);
    defer allocator.destroy(node);
    node.left = null;
    node.right = null;
    parentNode.right = node;
    node.parent = parentNode;
    node.value = 10;

    try node.insert(5, allocator);
    defer allocator.destroy(node.left.?);

    try node.insert(6, allocator);
    defer allocator.destroy(node.left.?.right.?);

    try node.insert(4, allocator);
    defer allocator.destroy(node.left.?.left.?);

    try node.insert(2, allocator);
    defer allocator.destroy(node.left.?.left.?.left.?);

    try node.insert(3, allocator);
    defer allocator.destroy(node.left.?.left.?.left.?.right.?);

    try node.insert(1, allocator);
    defer allocator.destroy(node.left.?.left.?.left.?.left.?);

    const smallestNode = node.getSmallestNode();
    try expectEqual(smallestNode.value, 1);
}

pub const BinaryTree = struct {
    root: ?*Node,
    elements: u32,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) BinaryTree {
        return .{
            .root = null,
            .elements = 0,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *BinaryTree) void {
        while (self.removeSmallest()) |_| {}
    }

    pub fn removeSmallest(self: *BinaryTree) ?u32 {
        if (self.elements == 0) return null;

        const smallestNode = self.root.?.getSmallestNode();
        const smallestValue = smallestNode.value;

        if (smallestNode.parent) |parent| { // smallestNode is always the left child, when is not the root
            if (smallestNode.right) |right| {
                // In this case, shift this child as the parent's new left child
                parent.left = right;
                right.parent = parent;
            } else parent.left = null;
        } else if (smallestNode.right) |right| {
            // If there is more nodes remaining on the right of the root node
            self.root = right;
            right.parent = null;
        }

        self.allocator.destroy(smallestNode);
        self.elements -= 1;
        return smallestValue;
    }

    pub fn insert(self: *BinaryTree, value: u32) !void {
        switch (self.elements) {
            0 => {
                self.root = try self.allocator.create(Node);
                self.root.?.value = value;
                self.root.?.parent = null;
                self.root.?.left = null;
                self.root.?.right = null;
            },
            else => {
                try self.root.?.insert(value, self.allocator);
            },
        }

        self.elements += 1;
    }

    pub fn print(self: *BinaryTree) void {
        switch (self.elements) {
            0 => std.debug.print("Empty BinaryTree\n", .{}),
            else => {
                std.debug.print("digraph {{\n", .{});
                self.root.?.printTree(0);
                std.debug.print("}}\n", .{});
            },
        }
    }
};

test "can init and deinit BinaryTree" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var binaryTree = BinaryTree.init(gpa.allocator());
    defer binaryTree.deinit();

    try expectEqual(0, binaryTree.elements);
    try expectEqual(null, binaryTree.root);
}

test "can insert values in binary tree" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var binaryTree = BinaryTree.init(gpa.allocator());
    defer binaryTree.deinit();

    try binaryTree.insert(10);
    try expectEqual(1, binaryTree.elements);
    try expectEqual(null, binaryTree.root.?.left);
    try expectEqual(null, binaryTree.root.?.right);

    try binaryTree.insert(9);
    try expectEqual(2, binaryTree.elements);
    try expectEqual(null, binaryTree.root.?.left.?.left);
    try expectEqual(null, binaryTree.root.?.left.?.right);
    try expectEqual(null, binaryTree.root.?.right);

    try binaryTree.insert(11);
    try expectEqual(3, binaryTree.elements);
    try expectEqual(null, binaryTree.root.?.left.?.left);
    try expectEqual(null, binaryTree.root.?.left.?.right);
    try expectEqual(null, binaryTree.root.?.right.?.left);
    try expectEqual(null, binaryTree.root.?.right.?.right);
}
