const std = @import("std");
const FileFormat = @import("file_format.zig").FileFormat;

//                  B      KB     MB     GB
const maxFileSize = 1024 * 1024 * 1024 * 4; // 4 GB max file size

pub const DataFile = struct {
    path: []const u8,
    file_format: FileFormat,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, path: []const u8) DataFile {
        return DataFile{
            .path = path,
            .file_format = FileFormat.fromStr(path),
            .allocator = allocator,
        };
    }

    fn existsOnDisk(self: DataFile) bool {
        const StatFileError = std.fs.Dir.StatFileError;

        switch (std.fs.cwd().statFile(self.path)) {
            StatFileError.FileNotFound => {
                std.debug.print("Error: FileNotFound. For '{s}'", .{self.path});
                return false;
            },
            StatFileError.AntivirusInterference => {
                std.debug.print("Your antivirus is blocking access to the file: '{s}'", self.path);
                return true;
            },
            else => {
                return true;
            },
        }
    }

    pub fn create(self: DataFile) !void {
        const file = try std.fs.cwd().createFile(
            self.path,
            .{ .read = true, .truncate = false },
        );
        defer file.close();

        // const message = "Hello File!";

        // try file.writeAll(message);

        // try file.seekTo(0);
        // const bytes_read = try file.reader().readAllAlloc(self.allocator, message.len);

        // std.debug.print("Content written on file: {s}\n", .{bytes_read});
    }

    pub fn write(self: DataFile, content: []u8) !void {
        const file = try std.fs.cwd().openFile(self.path, .{});
        defer file.close();
        try file.writeAll(content);
    }

    pub fn readAll(self: DataFile) ![]u8 {
        const file = try std.fs.cwd().openFile(self.path, .{});
        defer file.close();
        return try file.readToEndAlloc(self.allocator, maxFileSize);
    }

    pub fn print(self: DataFile) void {
        std.debug.print("DataFile: {{\n\tPath: {s}\n\tFile Format: {s}\n}}\n", .{
            self.path,
            self.file_format.toString(),
        });
    }
};
