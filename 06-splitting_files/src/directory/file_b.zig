const print = @import("std").debug.print;

pub fn public_function(param: []const u8) void {
    print("I am the public function from directory/file_b.zig: {s}\n", .{param});
}
