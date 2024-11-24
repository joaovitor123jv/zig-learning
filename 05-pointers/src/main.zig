const std = @import("std");

const print = std.debug.print;
const expectEqual = std.testing.expectEqual;

// Similar to C of pointer declaration
fn swap(a: *u8, b: *u8) void {
    // To get the value of a pointer (equivalent to *a of C), in zig we do: a.*
    // I think this is pretty cool. Easy to remember as a "the something of 'a'"
    const c: u8 = a.*;
    a.* = b.*;
    b.* = c;
}

// Just to keep testing as a good practice
test "values are swapped" {
    var a: u8 = 10;
    var b: u8 = 11;

    swap(&a, &b);
    try expectEqual(a, @as(u8, 11));
    try expectEqual(b, @as(u8, 10));
}

pub fn main() void {
    var a: u8 = 1;
    var b: u8 = 2;

    print("A = {}. B = {}\n", .{ a, b });
    print("Performing swap\n", .{});
    swap(&a, &b);
    print("A = {}. B = {}\n", .{ a, b });
}
