const std = @import("std");
const os = @import("builtin").os;
const DataFile = @import("data_file.zig").DataFile;

// const args_parser = @import("args_parser.zig");
// const Behavior = @import("behavior.zig").Behavior;

// If stdout and stdin are declared as global constants, this will not compile on windows OS.
// const stdout = std.io.getStdOut();
// const stdin = std.io.getStdIn();

const MAX_STR_RESPONSE = 120;

// fn askForStrResponse(allocator: std.mem.Allocator, question: []const u8) ![]const u8 {
//     const stdout = std.io.getStdOut();
//     const stdin = std.io.getStdIn();

//     try stdout.writeAll(question);
//     try stdout.writeAll("\n-> ");

//     var result: []const u8 = try stdin
//         .reader()
//         .readUntilDelimiterAlloc(allocator, '\n', MAX_STR_RESPONSE);

//     // Removes \r if running on windows
//     if (os.tag == .windows) {
//         result = std.mem.trimRight(u8, result, "\r");
//     }

//     return result;
// }

fn showHelp(stdout: std.fs.File) !void {
    const writer = stdout.writer();

    try writer.writeAll("Usage: converter input-filename.[json|csv] output-filename.[json|csv]\n");
    try writer.writeAll("Example:\n");
    try writer.writeAll("\t- converter input.csv output.json\n");
    try writer.writeAll("\n\n");

    std.process.exit(0);
}

// fn copyStrAsMutable(allocator: std.mem.Allocator, source: []const u8) ![]u8 {
//     const copiedString = try allocator.alloc(u8, source.len);

//     std.mem.copyForwards(u8, copiedString, source);
//     return copiedString;
// }

// fn parseArgs(allocator: std.mem.Allocator, stdout: std.fs.File) !*Behavior {
//     var args = try std.process.argsWithAllocator(allocator);
//     var argsParsed: u8 = 0;
//     _ = args.skip(); // Ignores the first command (the file name for the binary of this software)

//     var behavior: *Behavior = try Behavior.init(allocator);

//     var settingInputFile = false;
//     var settingOutputFile = false;

//     while (args.next()) |result| {
//         argsParsed += 1;
//         std.debug.print("Result = {s}\n", .{result});

//         if (settingOutputFile) {
//             try behavior.setOutput(allocator, result);
//             settingOutputFile = false;
//             continue;
//         }

//         if (settingInputFile) {
//             try behavior.setInput(allocator, result);
//             settingInputFile = false;
//             continue;
//         }

//         if (std.mem.eql(u8, result, "--output") or std.mem.eql(u8, result, "-o")) {
//             settingOutputFile = true;
//             continue;
//         }

//         if (std.mem.eql(u8, result, "--input") or std.mem.eql(u8, result, "-i")) {
//             settingInputFile = true;
//             continue;
//         }

//         try showHelp(stdout);
//     }

//     if (settingInputFile or settingOutputFile) {
//         std.debug.panic("Failed to parse args: Found undefined input or output file.\n", .{});
//     }

//     if (behavior.outputFormat.known() and behavior.inputFormat.known()) {
//         behavior.configuredByCli = true;
//     }

//     return behavior;
// }

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

    // const behavior = try parseArgs(allocator, stdout);
    // defer behavior.deinit();

    // if (behavior.configuredByCli) {
    //     std.debug.print("Configured by cli\n", .{});
    //     try behavior.print(stdout);
    // } else {
    //     const outputFileName = try askForStrResponse(allocator, "What file do you want to create? ");
    //     try stdout.writer().print("You are creating a file named: {s}\n", .{outputFileName});

    //     const inputFileName = try askForStrResponse(allocator, "What is your input file? ");
    //     try stdout.writer().print("The source of your data will be: {s}\n", .{inputFileName});

    //     try createFile(gpa.allocator(), outputFileName);
    // }
}

test {
    std.testing.refAllDecls(@This());
}
