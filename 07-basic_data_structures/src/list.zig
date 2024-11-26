const std = @import("std");
const expectEqual = std.testing.expectEqual;
const expect = std.testing.expect;

const ListError = error{ EmptyList, NoSuchElement, OutOfMemory };

const ListElement = struct {
    value: u32,
    next: ?*ListElement,
    previous: ?*ListElement,
};

pub const List = struct {
    elements: u32,
    allocator: std.mem.Allocator,
    start: ?*ListElement,
    end: ?*ListElement,

    pub fn init(allocator: std.mem.Allocator) List {
        return .{
            .elements = 0,
            .allocator = allocator,
            .start = null,
            .end = null,
        };
    }

    pub fn deinit(self: *List) void {
        while (self.removeEnd()) |_| {}
    }

    pub fn removeEnd(self: *List) ?u32 {
        if (self.elements == 0) return null;

        const element = self.end.?;

        if (self.elements == 1) {
            self.start = null;
            self.end = null;
        } else if (element.previous) |previousElement| {
            previousElement.next = null;
            self.end = previousElement;
        }

        self.elements -= 1;
        const value = element.value;
        self.allocator.destroy(element);
        return value;
    }

    /// Insert element on the end of the list
    pub fn append(self: *List, value: u32) ListError!void {
        const element = self.allocator.create(ListElement) catch return ListError.OutOfMemory;
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

    /// Insert element on the start of the list
    pub fn prepend(self: *List, value: u32) ListError!void {
        const element = self.allocator.create(ListElement) catch return ListError.OutOfMemory;
        element.value = value;

        switch (self.elements) {
            0 => {
                element.previous = null;
                element.next = null;
                self.start = element;
                self.end = element;
            },
            else => {
                const firstElement = self.start.?; // Same as 'self.start orelse unreachable'
                firstElement.previous = element;
                element.next = firstElement;
                self.start = element;
            },
        }

        self.elements += 1;
    }

    pub fn insertAt(self: *List, index: u32, value: u32) ListError!void {
        if (self.elements == index) return self.append(value);
        if (index == 0 or self.elements == 0) return self.prepend(value);
    }

    fn searchFromStart(self: *List, index: u32) ?u32 {
        var currentIndex: u32 = 0;
        var currentElement = self.start;
        while (currentElement.?.next) |nextElement| {
            if (currentIndex >= self.elements) break;
            currentIndex += 1;

            if (index == currentIndex) return nextElement.value;
            currentElement = nextElement;
        }
        return null;
    }

    fn searchFromEnd(self: *List, index: u32) ?u32 {
        var currentIndex: u32 = self.elements - 1;
        var currentElement = self.end;
        while (currentElement.?.previous) |previousElement| {
            if (currentIndex < 0) break;
            currentIndex -= 1;

            if (index == currentIndex) return previousElement.value;
            currentElement = previousElement;
        }
        return null;
    }

    pub fn at(self: *List, index: u32) ?u32 {
        if (self.elements == 0) return null;
        if (self.elements < index) return null;
        if (index == 0) return self.start.?.value;

        const nearEnd = index > (self.elements / 2);
        return if (nearEnd) self.searchFromEnd(index) else self.searchFromStart(index);
    }

    fn printFrom(self: *List, element: *ListElement, index: u32) void {
        std.debug.print("\t - {} => {}\n", .{ index, element.value });
        if (element.next) |nextElement| self.printFrom(nextElement, index + 1);
    }

    pub fn print(self: *List) void {
        switch (self.elements) {
            0 => std.debug.print("Empty list\n", .{}),
            else => {
                std.debug.print("List with {} elements:\n", .{self.elements});
                self.printFrom(self.start.?, 0);
            },
        }
    }
};

test "can init and deinit list" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var list = List.init(gpa.allocator());
    defer list.deinit();

    try expectEqual(0, list.elements);
    try expectEqual(null, list.start);
    try expectEqual(null, list.end);
}

test "can add on the list end" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var list = List.init(gpa.allocator());
    defer list.deinit();

    try list.append(10);
    try expectEqual(1, list.elements);
    try expectEqual(10, list.end.?.value);
    try expectEqual(10, list.start.?.value);

    try list.append(20);
    try expectEqual(2, list.elements);
    try expectEqual(20, list.end.?.value);
    try expectEqual(10, list.start.?.value);

    try list.append(30);
    try expectEqual(3, list.elements);
    try expectEqual(30, list.end.?.value);
    try expectEqual(10, list.start.?.value);
}

test "can add on the list start" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var list = List.init(gpa.allocator());
    defer list.deinit();

    try list.prepend(10);
    try expectEqual(1, list.elements);
    try expectEqual(10, list.end.?.value);
    try expectEqual(10, list.start.?.value);

    try list.prepend(20);
    try expectEqual(2, list.elements);
    try expectEqual(10, list.end.?.value);
    try expectEqual(20, list.start.?.value);

    try list.prepend(30);
    try expectEqual(3, list.elements);
    try expectEqual(10, list.end.?.value);
    try expectEqual(30, list.start.?.value);
}
