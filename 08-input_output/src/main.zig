const std = @import("std");
const os = @import("builtin").os;

// This doesn't compile on windows OS. getStdOut and getStdIn must be obtained in runtime
// const stdout = std.io.getStdOut();
// const stdin = std.io.getStdIn();

const MAX_STR_RESPONSE = 120;

const FileFormat = enum { Json, Csv, Yaml, Unknown };

const Behavior = struct {
    input: []u8,
    output: []u8,
    inputFormat: FileFormat,
    outputFormat: FileFormat,
    configuredByCli: bool,
};

fn abortWith(errorDescription: []u8) noreturn {
    const stderr = std.io.getStdErr();
    stderr.writer().print(errorDescription);
    std.process.exit(1);
}

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

fn parseArgs() Behavior {
    var args = std.process.args();
    var argsParsed: u8 = 0;
    _ = args.skip(); // Ignores the first command (the file name for the binary of this software)

    var settingInputFile = false;
    var settingOutputFile = false;

    while (args.next()) |result| {
        argsParsed += 1;
        std.debug.print("Result = {s}\n", .{result});

        if (settingOutputFile) {
            settingInputFile = false;
            continue;
        }

        if (settingOutputFile) {
            settingOutputFile = false;
            continue;
        }

        if (std.mem.eql(u8, result, "--output") or std.mem.eql(u8, result, "-o")) {
            settingOutputFile = true;
        }
    }

    if (settingInputFile or settingOutputFile) {
        abortWith("Failed to parse args: Found undefined input or output file.\n");
    }

    if (argsParsed > 0) {
        return Behavior{ .output = "", .input = "", .inputFormat = FileFormat.Unknown, .outputFormat = FileFormat.Unknown, .configuredByCli = true };
    } else {
        return Behavior{ .output = "", .input = "", .inputFormat = FileFormat.Unknown, .outputFormat = FileFormat.Unknown, .configuredByCli = true };
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const behavior = parseArgs();

    if (behavior.configuredByCli) {
        std.debug.print("Configured by cli", .{});
    } else {
        const result = try askForStrResponse(allocator, "What file do you want to create? ");

        try stdout.writer().print("You are creating a file named: {s}\n", .{result});

        try createFile(gpa.allocator(), result);
    }
}
