const std = @import("std");
const Stack = @import("stack.zig").Stack;
const Queue = @import("queue.zig").Queue;
const List = @import("list.zig").List;

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

    var list = List.init(allocator);
    defer list.deinit();
    try list.append(10);
    try list.append(20);
    try list.prepend(50);
    try list.prepend(60);

    list.print(); // Expected: {60,50,10,20}

    const valueFromList = list.removeEnd().?;
    print("Removed {} from list\n", .{valueFromList}); // Expected 20
    list.print(); // Expected: {60,50,10}
}

test {
    @import("std").testing.refAllDecls(@This());
}
