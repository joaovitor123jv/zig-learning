const std = @import("std");

// Alias to std.debug.print (reduces typing, I like it)
const print = std.debug.print;

// Another alias, I know you got it
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// This is a test that always pass!
test "always succeed" {
    // The expect 'can' fail, so we need to try them
    try expect(true); // Always pass
}

fn my_awesome_sum(a: u32, b: u32) u32 {
    return a + b;
}

test "can sum small things" {
    try expect(@TypeOf(my_awesome_sum(1, 2)) == u32);
    try expectEqual(my_awesome_sum(10, 20), 30);
}

pub fn main() void {
    print("Testing libs included!\n", .{});
}
