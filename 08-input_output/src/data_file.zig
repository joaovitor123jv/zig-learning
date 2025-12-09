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

    pub fn existsOnDisk(self: DataFile) bool {
        _ = std.fs.cwd().statFile(self.path) catch return false;
        return true;
    }

    pub fn create(self: DataFile) !void {
        const file = try std.fs.cwd().createFile(
            self.path,
            .{
                .read = true,
                .truncate = false,
            },
        );
        defer file.close();
    }

    pub fn write(self: DataFile, content: []const u8) !void {
        if (!self.existsOnDisk()) try self.create();
        if (!self.existsOnDisk()) unreachable;

        const file = try std.fs.cwd().openFile(self.path, .{
            .mode = .read_write,
        });
        defer file.close();
        try file.writeAll(content);
    }

    pub fn delete(self: DataFile) !void {
        try std.fs.cwd().deleteFile(self.path);
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

test "can check if file exists on disk" {
    const allocator = std.testing.allocator;
    try std.testing.expect(DataFile
        .init(allocator, "test_files/unit_test_file.bin")
        .existsOnDisk());
    try std.testing.expect(!DataFile
        .init(allocator, "test_files/unit_test_file-inexistent.bin")
        .existsOnDisk());
}

test "can read file contents" {
    const allocator = std.testing.allocator;
    const dataFile = DataFile.init(allocator, "test_files/unit_test_file.bin");
    const fileContents = try dataFile.readAll();
    defer allocator.free(fileContents);
    try std.testing.expectEqualStrings("abc", fileContents);
}

test "can create and write file" {
    const allocator = std.testing.allocator;
    const randomInt = std.crypto.random.int(u32);
    const path = try std.fmt.allocPrint(allocator, "test_files/__testing_base_path-{}.csv", .{randomInt});
    defer allocator.free(path);

    const dataFile = DataFile.init(allocator, path);
    try std.testing.expect(!dataFile.existsOnDisk());

    const fileContents: []const u8 = "ab,cd\n1,2\n3,4";
    try dataFile.write(fileContents);
    try std.testing.expect(dataFile.existsOnDisk());

    const readContents = try dataFile.readAll();
    defer allocator.free(readContents);
    try std.testing.expectEqualStrings(fileContents, readContents);
}

test "can delete file" {
    const allocator = std.testing.allocator;
    const randomInt = std.crypto.random.int(u32);
    const path = try std.fmt.allocPrint(allocator, "test_files/__testing_base_path-{}.csv", .{randomInt});
    defer allocator.free(path);

    const dataFile = DataFile.init(allocator, path);
    try std.testing.expect(!dataFile.existsOnDisk());

    const fileContents: []const u8 = "abc";
    try dataFile.write(fileContents);
    try std.testing.expect(dataFile.existsOnDisk());

    try dataFile.delete();
    try std.testing.expect(!dataFile.existsOnDisk());
}
