const time = @import("std").time;
const print = @import("std").debug.print;
const expectEqual = @import("std").testing.expectEqual;

fn fibonacci(number: u128) u128 {
    if (number == 0) return 0;
    if (number == 1) return 1;
    return fibonacci(number - 1) + fibonacci(number - 2);
}

test "fib 0" {
    try expectEqual(fibonacci(0), 0);
}

test "fib 1" {
    try expectEqual(fibonacci(1), @as(u128, 1));
}

test "fib 2" {
    try expectEqual(fibonacci(2), @as(u128, 1));
}

test "fib 3" {
    try expectEqual(fibonacci(3), @as(u128, 2));
}

test "fib 4" {
    try expectEqual(fibonacci(4), @as(u128, 3));
}

test "fib 5" {
    try expectEqual(fibonacci(5), @as(u128, 5));
}

pub fn main() void {
    print("Showing from fibonacci (recursive) from 0 to 42", .{});

    for (0..43) |number| {
        print("fibonacci({}) => ", .{number});
        const result = fibonacci(number);
        print("{}\n", .{result});
    }
}
