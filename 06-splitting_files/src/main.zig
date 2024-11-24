const std = @import("std");
const print = std.debug.print;

const file_a = @import("file_a.zig");
const file_b = @import("directory/file_b.zig");

pub fn main() void {
    file_a.public_function();
    file_b.public_function("This is a test");
}
