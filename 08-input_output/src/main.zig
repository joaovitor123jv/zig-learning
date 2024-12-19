const std = @import("std");
const os = @import("builtin").os;

const ArgsParser = @import("args_parser.zig").ArgsParser;
const Behavior = @import("behavior.zig").Behavior;

// If stdout and stdin are declared as global constants, this will not compile on windows OS.
// const stdout = std.io.getStdOut();
// const stdin = std.io.getStdIn();

const MAX_STR_RESPONSE = 120;

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

fn askForStrResponse(allocator: std.mem.Allocator, question: []const u8) ![]u8 {
    const stdout = std.io.getStdOut();
    const stdin = std.io.getStdIn();

    try stdout.writeAll(question);
    try stdout.writeAll("\n-> ");

    var result = try stdin.reader().readUntilDelimiterAlloc(allocator, '\n', MAX_STR_RESPONSE);

    // Removes \r if running on windows
    if (os.tag == .windows) {
        // TODO: This is showing problems when compiling for windows.
        result = std.mem.trimRight(u8, result, '\r');
    }

    return result;
}

fn showHelp(stdout: std.fs.File) !void {
    const writer = stdout.writer();

    try writer.writeAll("Usage: converter [--input|-i] input-filename.[json|yml|yaml|csv] [--output|-o] output-filename.[json|yml|yaml|csv]");
    try writer.writeAll("Examples:\n");
    try writer.writeAll("\t- converter -i input.csv -o output.json");
    try writer.writeAll("\t- converter --input a_large_file.csv --ouput an_even_larger_file.yml");
    try writer.writeAll("\n\n");

    std.debug.panic("Aborting execution.", .{});
}

fn copyStrAsMutable(allocator: std.mem.Allocator, source: []const u8) ![]u8 {
    const copiedString = try allocator.alloc(u8, source.len);

    std.mem.copyForwards(u8, copiedString, source);
    return copiedString;
}

fn parseArgs(allocator: std.mem.Allocator, stdout: std.fs.File) !*Behavior {
    var args = std.process.args();
    var argsParsed: u8 = 0;
    _ = args.skip(); // Ignores the first command (the file name for the binary of this software)

    var behavior: *Behavior = try Behavior.init(allocator);

    var settingInputFile = false;
    var settingOutputFile = false;

    while (args.next()) |result| {
        argsParsed += 1;
        std.debug.print("Result = {s}\n", .{result});

        if (settingOutputFile) {
            try behavior.setOutput(allocator, result);
            settingOutputFile = false;
            continue;
        }

        if (settingInputFile) {
            try behavior.setInput(allocator, result);
            settingInputFile = false;
            continue;
        }

        if (std.mem.eql(u8, result, "--output") or std.mem.eql(u8, result, "-o")) {
            settingOutputFile = true;
            continue;
        }

        if (std.mem.eql(u8, result, "--input") or std.mem.eql(u8, result, "-i")) {
            settingInputFile = true;
            continue;
        }

        try showHelp(stdout);
    }

    if (settingInputFile or settingOutputFile) {
        std.debug.panic("Failed to parse args: Found undefined input or output file.\n", .{});
    }

    if (behavior.outputFormat.known() and behavior.inputFormat.known()) {
        behavior.configuredByCli = true;
    }

    return behavior;
}

pub fn main() !void {
    const stdout = std.io.getStdOut();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const behavior = try parseArgs(allocator, stdout);
    defer behavior.deinit();

    if (behavior.configuredByCli) {
        std.debug.print("Configured by cli\n", .{});
        try behavior.print(stdout);
    } else {
        const result = try askForStrResponse(allocator, "What file do you want to create? ");

        try stdout.writer().print("You are creating a file named: {s}\n", .{result});

        try createFile(gpa.allocator(), result);
    }
}
