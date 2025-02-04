const std = @import("std");

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

pub const FileFormat = enum {
    Json,
    Csv,
    Yaml,
    Unknown,

    pub fn fromStr(str: []const u8) FileFormat {
        if (std.mem.endsWith(u8, str, ".csv")) {
            return FileFormat.Csv;
        } else if (std.mem.endsWith(u8, str, ".json")) {
            return FileFormat.Json;
        } else if (std.mem.endsWith(u8, str, ".yml") or std.mem.endsWith(u8, str, ".yaml")) {
            return FileFormat.Yaml;
        }

        return FileFormat.Unknown;
    }

    pub fn toString(self: FileFormat) []const u8 {
        return switch (self) {
            FileFormat.Json => "JSON",
            FileFormat.Yaml => "YAML",
            FileFormat.Csv => "CSV",
            FileFormat.Unknown => "UNKNOWN",
        };
    }

    pub fn known(self: FileFormat) bool {
        return self != FileFormat.Unknown;
    }
};

test "Can print FileFormat" {
    try expectEqual("JSON", FileFormat.Json.toString());
    try expectEqual("YAML", FileFormat.Yaml.toString());
    try expectEqual("CSV", FileFormat.Csv.toString());
    try expectEqual("UNKNOWN", FileFormat.Unknown.toString());
}

fn makeCopy(allocator: std.mem.Allocator, src: []const u8) std.mem.Allocator.Error![]u8 {
    const result = try allocator.alloc(u8, src.len);
    @memcpy(result, src);
    return result;
}

test "Can get FileFormat from string" {
    const allocator = std.testing.allocator;

    var testStr = try makeCopy(allocator, "path/to/file.json");
    try expectEqual(FileFormat.Json, FileFormat.fromStr(testStr));
    allocator.free(testStr);

    testStr = try makeCopy(allocator, "path/to/file.yml");
    try expectEqual(FileFormat.Yaml, FileFormat.fromStr(testStr));
    allocator.free(testStr);

    testStr = try makeCopy(allocator, "path/to/file.yaml");
    try expectEqual(FileFormat.Yaml, FileFormat.fromStr(testStr));
    allocator.free(testStr);

    testStr = try makeCopy(allocator, "path/to/file.csv");
    try expectEqual(FileFormat.Csv, FileFormat.fromStr(testStr));
    allocator.free(testStr);

    testStr = try makeCopy(allocator, "path/to/file.bla");
    try expectEqual(FileFormat.Unknown, FileFormat.fromStr(testStr));
    allocator.free(testStr);

    testStr = try makeCopy(allocator, "path/to/file.json0");
    try expectEqual(FileFormat.Unknown, FileFormat.fromStr(testStr));
    allocator.free(testStr);

    testStr = try makeCopy(allocator, "path/to/file.bson");
    try expectEqual(FileFormat.Unknown, FileFormat.fromStr(testStr));
    allocator.free(testStr);
}

test "Can check if FileFormat is known" {
    try expectEqual(false, FileFormat.Unknown.known());
    try expectEqual(true, FileFormat.Json.known());
    try expectEqual(true, FileFormat.Yaml.known());
    try expectEqual(true, FileFormat.Csv.known());
}
