const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const p = std.debug.print;

const Node = struct {
    left: ?*Node, // left.value is smaller than self.value
    right: ?*Node, // right.value is bigger or equal self.value
    parent: ?*Node,
    value: u32,

    fn init(value: u32, allocator: std.mem.Allocator) !*Node {
        var node: *Node = try allocator.create(Node);
        node.parent = null;
        node.left = null;
        node.right = null;
        node.value = value;
        return node;
    }

    fn deinit(self: *Node, allocator: std.mem.Allocator) void {
        if (self.left) |left| left.deinit(allocator);
        if (self.right) |right| right.deinit(allocator);

        if (self.isParentLeftChild()) {
            self.parent.?.left = null;
        } else if (self.isParentRightChild()) {
            self.parent.?.right = null;
        }

        allocator.destroy(self);
    }

    fn isParentLeftChild(self: *Node) bool {
        if (self.parent == null) return false;
        if (self.parent.?.left == null) return false;

        return (self.parent.?.left.? == self);
    }

    fn isParentRightChild(self: *Node) bool {
        if (self.parent == null) return false;
        if (self.parent.?.right == null) return false;

        return (self.parent.?.right.? == self);
    }

    fn getSmallestNode(self: *Node) *Node {
        return if (self.left) |left| left.getSmallestNode() else self;
    }

    fn getBiggestNode(self: *Node) *Node {
        return if (self.right) |right| right.getBiggestNode() else self;
    }

    fn insert(self: *Node, value: u32, allocator: std.mem.Allocator) !void {
        if (value < self.value) {
            if (self.left) |left| return try left.insert(value, allocator);

            self.left = try Node.init(value, allocator);
            self.left.?.parent = self;
            return;
        } else if (self.right) |right| {
            return try right.insert(value, allocator);
        }

        self.right = try Node.init(value, allocator);
        self.right.?.parent = self;
    }

    pub fn searchNode(self: *Node, value: u32) ?*Node {
        if (self.value == value) return self;
        if (value < self.value) {
            if (self.left) |left| return left.searchNode(value);
        }
        if (value > self.value) {
            if (self.right) |right| return right.searchNode(value);
        }
        return null;
    }

    fn printIfAvailable(key: []u8, node: ?*Node) void {
        std.debug.print("\t{}: {}\n", .{ key, if (node) |n| n.value else "null" });
    }

    pub fn print(self: *Node) void {
        std.debug.print("Node {{\n", .{});
        std.debug.print("\tValue: {}\n", .{self.value});
        Node.printIfAvailable("Parent", self.parent);
        Node.printIfAvailable("Left", self.left);
        Node.printIfAvailable("Right", self.right);
        std.debuf.print("}}\n", .{});
    }

    fn printTree(self: *Node, level: u32) void {
        if (self.parent) |parent| {
            std.debug.print("\tel_{} -> el_{};\n", .{ parent.value, self.value });
        }
        if (self.left) |left| {
            left.printTree(level + 1);
        } else std.debug.print("\tel_{} -> null_l_{};\n", .{ self.value, self.value });

        if (self.right) |right| {
            right.printTree(level + 1);
        } else std.debug.print("\tel_{} -> null_r_{};\n", .{ self.value, self.value });
    }
};

test "can init and deinit node" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const node = try Node.init(10, allocator);
    defer node.deinit(allocator);

    try expectEqual(null, node.left);
    try expectEqual(null, node.right);
    try expectEqual(null, node.parent);
    try expectEqual(10, node.value);
}

test "can insert node on node" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var parentNode: *Node = try Node.init(10, allocator);
    defer parentNode.deinit(allocator); // Frees memory of all children

    var node: *Node = try Node.init(10, allocator);
    parentNode.right = node;
    node.parent = parentNode;

    try expectEqual(null, node.left);
    try expectEqual(null, node.right);

    try node.insert(9, allocator);
    try expectEqual(9, node.left.?.value);
    try expectEqual(null, node.right);

    try node.insert(11, allocator);
    try expectEqual(9, node.left.?.value);
    try expectEqual(11, node.right.?.value);
}

test "can search node by value" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var node: *Node = try Node.init(10, allocator);
    defer node.deinit(allocator); // Frees memory of all children

    try node.insert(9, allocator);
    try node.insert(11, allocator);
    try node.insert(18, allocator);
    try node.insert(40, allocator);
    try node.insert(4, allocator);
    try node.insert(1, allocator);
    try node.insert(5, allocator);
    try node.insert(15, allocator);
    try node.insert(3, allocator);

    try expectEqual(null, node.searchNode(2));
    try expectEqual(9, node.searchNode(9).?.*.value);
    try expectEqual(10, node.searchNode(10).?.*.value);
    try expectEqual(4, node.searchNode(4).?.*.value);
}

test "get smallest node of empty node returns self" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var node: *Node = try Node.init(10, allocator);
    defer node.deinit(allocator);

    try expectEqual(node, node.getSmallestNode());
}

test "can get smallest node of node with children" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var parentNode: *Node = try Node.init(10, allocator);
    defer parentNode.deinit(allocator); // Frees memory of all children

    var node: *Node = try Node.init(10, allocator);
    parentNode.right = node;
    node.parent = parentNode;

    try node.insert(5, allocator);
    try node.insert(6, allocator);
    try node.insert(4, allocator);
    try node.insert(2, allocator);
    try node.insert(3, allocator);
    try node.insert(1, allocator);

    const smallestNode = node.getSmallestNode();
    try expectEqual(smallestNode.value, 1);
}

test "get biggest node of empty node returns self" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var node: *Node = try Node.init(10, allocator);
    defer node.deinit(allocator);

    try expectEqual(node, node.getBiggestNode());
}

test "can get biggest node of node with children" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var parentNode: *Node = try Node.init(10, allocator);
    defer parentNode.deinit(allocator);

    var node: *Node = try Node.init(10, allocator);
    parentNode.right = node;
    node.parent = parentNode;

    try node.insert(5, allocator);
    try node.insert(6, allocator);
    try node.insert(4, allocator);
    try node.insert(2, allocator);
    try node.insert(3, allocator);
    try node.insert(1, allocator);

    const biggestNode = node.getBiggestNode();
    try expectEqual(biggestNode.value, 10);
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
        if (self.root) |root| root.deinit(self.allocator);
        self.elements = 0;
    }

    pub fn contains(self: *BinaryTree, value: u32) bool {
        if (self.root == null) return false;
        return self.root.?.searchNode(value) != null;
    }

    pub fn searchNode(self: *BinaryTree, value: u32) ?*Node {
        if (self.root == null) return null;
        return self.root.?.searchNode(value);
    }

    pub fn getSmallest(self: *BinaryTree) ?u32 {
        if (self.elements == 0) return null;
        return self.root.?.getSmallestNode().value;
    }

    pub fn getBiggest(self: *BinaryTree) ?u32 {
        if (self.elements == 0) return null;
        return self.root.?.getBiggestNode().value;
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
            0 => self.root = try Node.init(value, self.allocator),
            else => try self.root.?.insert(value, self.allocator),
        }

        self.elements += 1;
    }

    pub fn printGraph(self: *BinaryTree) void {
        switch (self.elements) {
            0 => {
                std.debug.print("digraph {{\n", .{});
                std.debug.print("}}\n", .{});
            },
            else => {
                std.debug.print("digraph {{\n", .{});
                self.root.?.printTree(0);
                std.debug.print("}}\n", .{});
            },
        }
    }

    pub fn print(self: *BinaryTree) void {
        switch (self.elements) {
            0 => std.debug.print("Empty BinaryTree\n", .{}),
            else => {
                std.debug.print("BinaryTree with {} elements. Generating tree graph:\n", .{self.elements});
                self.printGraph();
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

test "can get biggest number in a binary tree" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var binaryTree = BinaryTree.init(gpa.allocator());
    defer binaryTree.deinit();

    try binaryTree.insert(10);
    try binaryTree.insert(9);
    try binaryTree.insert(11);

    try expectEqual(11, binaryTree.getBiggest().?);
}

test "smallest number in empty binary tree is null" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var binaryTree = BinaryTree.init(gpa.allocator());
    defer binaryTree.deinit();
    try expectEqual(null, binaryTree.getSmallest());
}

test "can get smallest number in a binary tree" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var binaryTree = BinaryTree.init(gpa.allocator());
    defer binaryTree.deinit();

    try binaryTree.insert(10);
    try binaryTree.insert(9);
    try binaryTree.insert(11);

    try expectEqual(11, binaryTree.getBiggest().?);
}

test "biggest number in empty binary tree is null" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var binaryTree = BinaryTree.init(gpa.allocator());
    defer binaryTree.deinit();
    try expectEqual(null, binaryTree.getBiggest());
}

test "can check if tree contains value" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var binaryTree = BinaryTree.init(gpa.allocator());
    defer binaryTree.deinit();

    try expectEqual(false, binaryTree.contains(10));

    try binaryTree.insert(10);
    try binaryTree.insert(9);
    try binaryTree.insert(11);

    try expectEqual(true, binaryTree.contains(10));
    try expectEqual(false, binaryTree.contains(5));
}

test "can search for node in BinaryTree" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var binaryTree = BinaryTree.init(gpa.allocator());
    defer binaryTree.deinit();

    try expectEqual(null, binaryTree.searchNode(10));

    try binaryTree.insert(10);
    try binaryTree.insert(9);
    try binaryTree.insert(11);

    try expectEqual(10, binaryTree.searchNode(10).?.*.value);
    try expectEqual(null, binaryTree.searchNode(5));
}
