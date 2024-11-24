const std = @import("std");
const Stack = @import("stack.zig").Stack;

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

    const result = stack.pop();
    if (result) |number| {
        print("Removed {} from stack\n", .{number});
    } else {
        print("Failed to remove from stack\n", .{});
        unreachable;
    }

    stack.print();
}

test {
    @import("std").testing.refAllDecls(@This());
}
