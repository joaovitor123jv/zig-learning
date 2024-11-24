const std = @import("std");
const maxInt = std.math.maxInt;
const expectEqual = std.testing.expectEqual;
const expect = std.testing.expect;

const StackElement = struct {
    value: u32,
    next: ?*StackElement,
};

pub const Stack = struct {
    elements: u32,
    allocator: std.mem.Allocator,
    stackTop: ?*StackElement,

    pub fn init(allocator: std.mem.Allocator) Stack {
        return .{ .elements = 0, .allocator = allocator, .stackTop = null };
    }

    pub fn deinit(self: *Stack) void {
        while (self.pop()) |_| {}
    }

    pub fn push(self: *Stack, value: u32) !void {
        if (self.elements == maxInt(u32)) return error.StackLimitReached;

        const element: *StackElement = try self.allocator.create(StackElement);
        element.value = value;
        element.next = self.stackTop;
        self.elements += 1;
        self.stackTop = element;
    }

    pub fn pop(self: *Stack) ?u32 {
        return switch (self.elements) {
            0 => null,
            1 => {
                if (self.stackTop) |stackTop| {
                    self.elements = 0;
                    const value = stackTop.value;
                    self.allocator.destroy(stackTop);
                    return value;
                }
                unreachable;
            },
            else => {
                if (self.stackTop) |top| {
                    if (top.next) |next| {
                        self.elements -= 1;
                        const value = top.value;
                        self.stackTop = next;
                        self.allocator.destroy(top);
                        return value;
                    }
                }
                unreachable;
            },
        };
    }

    fn printElements(self: Stack, baseElement: *StackElement) void {
        std.debug.print("\t{}\n", .{baseElement.value});
        if (baseElement.next) |nextElement| self.printElements(nextElement);
    }

    pub fn print(self: Stack) void {
        if (self.elements == 0) {
            std.debug.print("Empty stack.\n", .{});
            return;
        }

        std.debug.print("Stack with {} elements:\n", .{self.elements});
        if (self.stackTop) |top| {
            self.printElements(top);
        }
    }
};

test "can init stack" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var stack = Stack.init(allocator);
    defer stack.deinit();

    try expectEqual(stack.elements, @as(u32, 0));
    try expectEqual(stack.stackTop, null);
}

test "push to stack" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var stack = Stack.init(allocator);
    defer stack.deinit();

    try stack.push(10);
    try expectEqual(1, stack.elements);

    if (stack.stackTop) |top| {
        try expectEqual(10, top.value);
    } else try expect(false);

    try stack.push(20);
    try expectEqual(2, stack.elements);

    if (stack.stackTop) |top| {
        try expectEqual(20, top.value);
    } else try expect(false);
}

test "pop from stack" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var stack = Stack.init(allocator);
    defer stack.deinit();

    try stack.push(10);
    try stack.push(12);
    try stack.push(13);

    try expectEqual(13, stack.pop().?);
    try expectEqual(12, stack.pop().?);
    try expectEqual(10, stack.pop().?);
    try expectEqual(null, stack.pop());
}
