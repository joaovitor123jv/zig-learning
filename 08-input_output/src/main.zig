const std = @import("std");
const os = @import("builtin").os;
const DataFile = @import("data_file.zig").DataFile;

const MAX_STR_RESPONSE = 120;

fn showHelp(stdout: std.fs.File) !void {
    try stdout.writeAll("Usage: converter input-filename.[json|csv] output-filename.[json|csv]\n");
    try stdout.writeAll("Example:\n");
    try stdout.writeAll("\t- converter input.csv output.json\n");
    try stdout.writeAll("\n\n");

    std.process.exit(0);
}

pub fn main() !u8 {
    const stdout = std.fs.File.stdout();
    const stderr = std.fs.File.stderr();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    _ = args.skip(); // Ignores the first command (the file name for the binary of this software)

    const inputPath: []const u8 = args.next() orelse "";
    const outputPath: []const u8 = args.next() orelse "";

    if (inputPath.len == 0 or outputPath.len == 0) {
        try stderr.writeAll("Failed to parse file. Input or output files not defined.\n");
        try showHelp(stdout);
    }

    const inputFile = DataFile.init(allocator, inputPath);
    const outputFile = DataFile.init(allocator, outputPath);

    std.debug.print("- Input file:\n", .{});
    inputFile.print();
    std.debug.print("- Output file:\n", .{});
    outputFile.print();

    if (!inputFile.existsOnDisk()) {
        try stderr.writeAll("File does not exists on disk or is not readable: \n- ");
        try stderr.writeAll(inputFile.path);
        try stderr.writeAll("\n\n");
        return 1;
    }

    if (outputFile.existsOnDisk()) {
        try stderr.writeAll("File already exists on disk. Will not override: \n- ");
        try stderr.writeAll(outputFile.path);
        try stderr.writeAll("\n\n");
        return 1;
    }

    std.debug.print("Copying files (step 3 of implementation)\n", .{});

    std.debug.print("- Reading contents of {s}\n", .{inputFile.path});
    const inputFileContents = try inputFile.readAll();
    defer allocator.free(inputFileContents);

    std.debug.print("- Writing contents on {s}\n", .{outputFile.path});
    try outputFile.write(inputFileContents);

    std.debug.print("File copied successfully!\n", .{});

    return 0;
}

test {
    std.testing.refAllDecls(@This());
}
