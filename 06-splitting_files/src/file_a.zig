const print = @import("std").debug.print;

fn private_function() void {
    print("And I am the private function from the file_a.zig\n", .{});
}

pub fn public_function() void {
    print("Hi, I am the public function from fila_a.zig\n", .{});
    private_function();
}
