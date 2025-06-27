const std = @import("std");
const os = @import("builtin").os;
const DataFile = @import("data_file.zig").DataFile;

const MAX_STR_RESPONSE = 120;

fn showHelp(stdout: std.fs.File) !void {
    const writer = stdout.writer();

    try writer.writeAll("Usage: converter input-filename.[json|csv] output-filename.[json|csv]\n");
    try writer.writeAll("Example:\n");
    try writer.writeAll("\t- converter input.csv output.json\n");
    try writer.writeAll("\n\n");

    std.process.exit(0);
}

pub fn main() !void {
    const stdout = std.io.getStdOut();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    _ = args.skip(); // Ignores the first command (the file name for the binary of this software)

    const inputPath: []const u8 = args.next() orelse "";
    const outputPath: []const u8 = args.next() orelse "";

    if (inputPath.len == 0 or outputPath.len == 0) {
        std.debug.print("Failed to parse file. Input or output files not defined.\n", .{});
        try showHelp(stdout);
    }

    const inputFile = DataFile.init(allocator, inputPath);
    const outputFile = DataFile.init(allocator, outputPath);

    std.debug.print("- Input file:\n", .{});
    inputFile.print();
    std.debug.print("- Output file:\n", .{});
    outputFile.print();
}

test {
    std.testing.refAllDecls(@This());
}
