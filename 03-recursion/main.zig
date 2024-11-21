const exit = @import("std").process.exit;
const time = @import("std").time;
const print = @import("std").debug.print;
const expectEqual = @import("std").testing.expectEqual;

fn fibonacci(number: u128) u128 {
    if ((number == 1) or (number == 0)) return 1;
    return number + fibonacci(number - 1);
}

test "fib 0" {
    try expectEqual(fibonacci(0), 1);
}

test "fib 1" {
    try expectEqual(fibonacci(1), 1);
}

test "fib 2" {
    try expectEqual(fibonacci(2), 3);
}

pub fn main() void {
    const testStart = time.timestamp();
    print("Hello!\n", .{});
    const result = fibonacci(100000);
    const now = time.timestamp();

    // I don't know yet how to measure performance using zig
    print("Difference: {}\n", .{now - testStart});
    print("Result: {}\n", .{result});
}
