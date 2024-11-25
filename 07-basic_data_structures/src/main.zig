const std = @import("std");
const Stack = @import("stack.zig").Stack;
const Queue = @import("queue.zig").Queue;

const print = std.debug.print;

pub fn main() !void {
    // Zig let you CHOOSE the default allocator.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // I have read it is a good practice to let users define which allocator
    // they want to use in the created libs.
    var stack = Stack.init(allocator);
    stack.deinit();

    try stack.push(10);
    try stack.push(20);
    try stack.push(20);
    try stack.push(30);
    stack.print();

    const valueFromStack = stack.pop().?;
    print("Removed {} from stack\n", .{valueFromStack});

    stack.print();

    print("\n\n", .{});
    var queue = Queue.init(allocator);
    defer queue.deinit();

    try queue.enqueue(10);
    try queue.enqueue(20);
    try queue.enqueue(30);
    queue.print();

    const valueFromQueue = queue.dequeue().?;
    print("Removed {} from queue\n", .{valueFromQueue});

    queue.print();
}

test {
    @import("std").testing.refAllDecls(@This());
}
