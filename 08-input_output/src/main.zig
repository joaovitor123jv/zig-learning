const std = @import("std");
const os = @import("builtin").os;

fn createFile(allocator: std.mem.Allocator, path: []const u8) !void {
    const file = try std.fs.cwd().createFile(
        path,
        .{ .read = true, .truncate = false },
    );
    defer file.close();

    const message = "Hello File!";

    try file.writeAll(message);

    try file.seekTo(0);
    const bytes_read = try file.reader().readAllAlloc(allocator, message.len);

    std.debug.print("Content written on file: {s}\n", .{bytes_read});
}

pub fn main() !void {
    const max_file_size = 200;
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    try stdout.writeAll("What file do you want to create? ");

    var result = try stdin.reader().readUntilDelimiterAlloc(gpa.allocator(), '\n', max_file_size);
    if (os.tag == .windows) {
        result = std.mem.trimRight(u8, result, '\r'); // Removes \r if running on windows
    }

    try stdout.writer().print("You are creating a file named: {s}\n", .{result});

    try createFile(gpa.allocator(), result);
}
