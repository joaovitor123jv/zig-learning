const std = @import("std");
const expectEqual = std.testing.expectEqual;
const expect = std.testing.expect;

const QueueElement = struct {
    value: u32,
    previous: ?*QueueElement,
    next: ?*QueueElement,
};

pub const Queue = struct {
    elements: u32,
    start: ?*QueueElement,
    end: ?*QueueElement,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Queue {
        return Queue{ .elements = 0, .start = null, .end = null, .allocator = allocator };
    }

    pub fn deinit(self: *Queue) void {
        while (self.dequeue()) |_| {}
    }

    pub fn enqueue(self: *Queue, value: u32) !void {
        const element = try self.allocator.create(QueueElement);
        element.value = value;
        element.next = null; // Always added on the end of the queue

        switch (self.elements) {
            0 => {
                element.previous = null;
                self.start = element;
                self.end = element;
            },
            else => {
                const lastElement = self.end.?; // Same as 'self.start orelse unreachable'
                lastElement.next = element;
                element.previous = lastElement;
                self.end = element;
            },
        }

        self.elements += 1;
    }

    pub fn dequeue(self: *Queue) ?u32 {
        return switch (self.elements) {
            0 => null,
            else => {
                const firstElement: *QueueElement = self.start.?; // same as self.start orelse unreachable;

                if (firstElement.next) |nextElement| {
                    nextElement.previous = null;
                }

                const value = firstElement.value;
                self.start = firstElement.next;
                self.allocator.destroy(firstElement);
                self.elements -= 1;
                return value;
            },
        };
    }

    fn printElementsFrom(self: *Queue, element: *QueueElement) void {
        std.debug.print("\t - {}\n", .{element.value});
        if (element.next) |nextElement| self.printElementsFrom(nextElement);
    }

    pub fn print(self: *Queue) void {
        switch (self.elements) {
            0 => std.debug.print("Empty queue.", .{}),
            else => {
                std.debug.print("Queue with {} elements:\n", .{self.elements});
                self.printElementsFrom(self.start.?);
            },
        }
    }
};

test "can init and deinit a queue" {
    var queue = Queue.init(std.testing.allocator);
    defer queue.deinit();

    try expectEqual(0, queue.elements);
    try expectEqual(null, queue.start);
    try expectEqual(null, queue.end);
}

test "can enqueue items" {
    var queue = Queue.init(std.testing.allocator);
    defer queue.deinit();

    try queue.enqueue(10);
    try expectEqual(1, queue.elements);
    try expectEqual(10, queue.start.?.value);
    try expectEqual(10, queue.end.?.value);
    try expectEqual(queue.start, queue.end);

    try queue.enqueue(11);
    try expectEqual(2, queue.elements);
    try expectEqual(10, queue.start.?.value);
    try expectEqual(11, queue.end.?.value);

    try queue.enqueue(12);
    try expectEqual(3, queue.elements);
    try expectEqual(10, queue.start.?.value);
    try expectEqual(12, queue.end.?.value);
}

test "can dequeue items" {
    var queue = Queue.init(std.testing.allocator);
    defer queue.deinit();

    try queue.enqueue(10);
    try queue.enqueue(11);
    try queue.enqueue(12);

    var result = queue.dequeue();
    try expectEqual(10, result.?);
    try expectEqual(2, queue.elements);

    result = queue.dequeue();
    try expectEqual(11, result.?);
    try expectEqual(1, queue.elements);

    result = queue.dequeue();
    try expectEqual(12, result.?);
    try expectEqual(0, queue.elements);

    result = queue.dequeue();
    try expectEqual(null, result);
}
