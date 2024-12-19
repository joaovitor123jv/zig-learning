const std = @import("std");
const FileFormat = @import("file_format.zig").FileFormat;

pub const Behavior = struct {
    input: ?[]u8,
    output: ?[]u8,
    inputFormat: FileFormat,
    outputFormat: FileFormat,
    configuredByCli: bool,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !*Behavior {
        var behavior: *Behavior = try allocator.create(Behavior);
        behavior.input = null;
        behavior.output = null;
        behavior.inputFormat = FileFormat.Unknown;
        behavior.outputFormat = FileFormat.Unknown;
        behavior.configuredByCli = false;
        behavior.allocator = allocator;
        return behavior;
    }

    pub fn deinit(self: *Behavior) void {
        if (self.input) |destroyableInput| {
            self.allocator.free(destroyableInput);
            self.input = null;
        }

        if (self.output) |destroyableOutput| {
            self.allocator.free(destroyableOutput);
            self.output = null;
        }

        self.allocator.destroy(self);
    }

    pub fn setInput(self: *Behavior, allocator: std.mem.Allocator, input: []const u8) !void {
        if (input.len <= 0) {
            return;
        }

        if (self.input) |destroyableInput| {
            allocator.free(destroyableInput);
            self.input = null;
        }

        self.input = try allocator.alloc(u8, input.len);
        const writableInput = self.input.?;

        @memcpy(writableInput, input);
        // std.mem.copyForwards(u8, writableInput, input);
        self.inputFormat = FileFormat.fromStr(writableInput);
        if (self.inputFormat == FileFormat.Unknown) {
            std.debug.panic("Failed to define file type. File should be: JSON, CSV or YAML", .{});
        }
    }

    pub fn setOutput(self: *Behavior, allocator: std.mem.Allocator, output: []const u8) !void {
        if (output.len <= 0) {
            return;
        }

        if (self.output) |destroyableOutput| {
            allocator.free(destroyableOutput);
            self.output = null;
        }

        self.output = try allocator.alloc(u8, output.len);

        const writableOutput = self.output.?;
        @memcpy(writableOutput, output);
        // std.mem.copyForwards(u8, writableOutput, output);

        self.outputFormat = FileFormat.fromStr(writableOutput);
        if (self.outputFormat == FileFormat.Unknown) {
            std.debug.panic("Failed to define file type. File should be: JSON, CSV or YAML", .{});
        }
    }

    pub fn print(self: *Behavior, stdout: std.fs.File) !void {
        var writer = stdout.writer();

        try writer.writeAll("Behavior {\n");

        if (self.input) |readableInput| {
            try writer.print("\tinput: {s}\n", .{readableInput});
        } else {
            try writer.writeAll("\tinput: None\n");
        }

        if (self.output) |readableOutput| {
            try writer.print("\toutput: {s}\n", .{readableOutput});
        } else {
            try writer.writeAll("\toutput: None\n");
        }

        try writer.print("\tinputFormat: {s}\n", .{self.inputFormat.toString()});
        try writer.print("\toutputFormat: {s}\n", .{self.outputFormat.toString()});
        try writer.print("\tconfiguredByCli: {}\n", .{self.configuredByCli});

        try writer.writeAll("}\n");
    }
};
