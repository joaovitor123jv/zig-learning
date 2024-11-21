// This is the default way to import the standard library.
// It resembles A LOT the 'require(thing)' of nodejs (commonjs)
const std = @import("std");

// The main function must be public, and return void
pub fn main() void {
    // This is the default "print" for debugging things
    std.debug.print("Hello World!\n", .{});
}
