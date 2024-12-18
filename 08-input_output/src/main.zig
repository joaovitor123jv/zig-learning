const std = @import("std");
const os = @import("builtin").os;

// If stdout and stdin are declared as global constants, this will not compile on windows OS.
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

    fn print(self: Behavior, stdout: std.fs.File) !void {
        var writer = stdout.writer();

        try writer.writeAll("Behavior {\n");
        try writer.print("\tinput: {s}\n", .{self.input});
        try writer.print("\toutput: {s}\n", .{self.output});
        try writer.print("\tinputFormat: {}\n", .{self.inputFormat});
        try writer.print("\toutputFormat: {}\n", .{self.outputFormat});
        try writer.print("\tconfiguredByCli: {}\n", .{self.configuredByCli});

        try writer.writeAll("}\n");
    }
};

fn abortWith(errorDescription: []const u8) noreturn {
    const stderr = std.io.getStdErr();
    stderr.writer().writeAll(errorDescription) catch std.process.exit(2);
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

fn showHelp(stdout: std.fs.File) !void {
    const writer = stdout.writer();

    try writer.writeAll("Usage: converter [--input|-i] input-filename.[json|yml|yaml|csv] [--output|-o] output-filename.[json|yml|yaml|csv]");
    try writer.writeAll("Examples:\n");
    try writer.writeAll("\t- converter -i input.csv -o output.json");
    try writer.writeAll("\t- converter --input a_large_file.csv --ouput an_even_larger_file.yml");
    try writer.writeAll("\n\n");

    abortWith("Aborting execution.");
}

fn copyStrAsMutable(allocator: std.mem.Allocator, source: []const u8) ![]u8 {
    const copiedString = try allocator.alloc(u8, source.len);

    std.mem.copyForwards(u8, copiedString, source);
    return copiedString;
}

fn parseArgs(allocator: std.mem.Allocator, stdout: std.fs.File) !Behavior {
    var args = std.process.args();
    var argsParsed: u8 = 0;
    _ = args.skip(); // Ignores the first command (the file name for the binary of this software)

    var settingInputFile = false;
    var settingOutputFile = false;

    var outputFile: ?[]u8 = null;
    var inputFile: ?[]u8 = null;

    var inputFileFormat = FileFormat.Unknown;
    var outputFileFormat = FileFormat.Unknown;

    while (args.next()) |result| {
        argsParsed += 1;
        std.debug.print("Result = {s}\n", .{result});

        if (settingOutputFile) {
            // This seems not ok... Something tells me I need to throw these allocs under Behavior struct
            // Also, would be easier just to defer a deinit function of Behavior instead os freeing memory
            // allocated randomly by other functions... Still thinking over it
            outputFile = try allocator.alloc(u8, result.len);
            const outputF = outputFile.?;
            std.mem.copyForwards(u8, outputF, result);

            if (std.mem.endsWith(u8, outputF, ".csv")) {
                outputFileFormat = FileFormat.Csv;
            } else if (std.mem.endsWith(u8, outputF, ".json")) {
                outputFileFormat = FileFormat.Json;
            } else if (std.mem.endsWith(u8, outputF, ".yml") or std.mem.endsWith(u8, outputF, ".yaml")) {
                outputFileFormat = FileFormat.Yaml;
            } else {
                abortWith("Failed to define file type. File should be: JSON, CSV or YAML");
            }

            settingOutputFile = false;
            continue;
        }

        if (settingInputFile) {
            inputFile = try allocator.alloc(u8, result.len);
            const inputF = inputFile.?;
            std.mem.copyForwards(u8, inputF, result);

            if (std.mem.endsWith(u8, inputF, ".csv")) {
                inputFileFormat = FileFormat.Csv;
            } else if (std.mem.endsWith(u8, inputF, ".json")) {
                inputFileFormat = FileFormat.Json;
            } else if (std.mem.endsWith(u8, inputF, ".yml") or std.mem.endsWith(u8, inputF, ".yaml")) {
                inputFileFormat = FileFormat.Yaml;
            } else {
                abortWith("Failed to define file type. File should be: JSON, CSV or YAML");
            }

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
        abortWith("Failed to parse args: Found undefined input or output file.\n");
    }

    if (inputFile == null) {
        inputFile = try copyStrAsMutable(allocator, "input.csv");
        inputFileFormat = FileFormat.Csv;
    }

    if (outputFile == null) {
        outputFile = try copyStrAsMutable(allocator, "output.json");
        outputFileFormat = FileFormat.Json;
    }

    if (inputFileFormat == FileFormat.Unknown or outputFileFormat == FileFormat.Unknown) {
        unreachable;
    }

    return Behavior{
        .output = outputFile.?,
        .input = inputFile.?,
        .inputFormat = inputFileFormat,
        .outputFormat = outputFileFormat,
        .configuredByCli = (argsParsed > 0) and inputFileFormat != FileFormat.Unknown and outputFileFormat != FileFormat.Unknown,
    };
}

pub fn main() !void {
    const stdout = std.io.getStdOut();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const behavior = try parseArgs(allocator, stdout);

    if (behavior.configuredByCli) {
        std.debug.print("Configured by cli\n", .{});
        try behavior.print(stdout);
    } else {
        const result = try askForStrResponse(allocator, "What file do you want to create? ");

        try stdout.writer().print("You are creating a file named: {s}\n", .{result});

        try createFile(gpa.allocator(), result);
    }
}
