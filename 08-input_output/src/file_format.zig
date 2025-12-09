const std = @import("std");

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

inline fn endsWith(haystack: []const u8, needle: []const u8) bool {
    return std.mem.endsWith(u8, haystack, needle);
}

pub const FileFormat = enum {
    Json,
    Csv,
    Yaml,
    Unknown,

    pub fn fromStr(str: []const u8) FileFormat {
        if (endsWith(str, ".csv")) {
            return FileFormat.Csv;
        } else if (endsWith(str, ".json")) {
            return FileFormat.Json;
        } else if (endsWith(str, ".yml") or endsWith(str, ".yaml")) {
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

test "Can get FileFormat from string" {
    try expectEqual(FileFormat.Json, FileFormat.fromStr("path/to/file.json"));
    try expectEqual(FileFormat.Yaml, FileFormat.fromStr("path/to/file.yml"));
    try expectEqual(FileFormat.Yaml, FileFormat.fromStr("path/to/file.yaml"));
    try expectEqual(FileFormat.Csv, FileFormat.fromStr("path/to/file.csv"));
    try expectEqual(FileFormat.Unknown, FileFormat.fromStr("path/to/file.bla"));
    try expectEqual(FileFormat.Unknown, FileFormat.fromStr("path/to/file.json0"));
    try expectEqual(FileFormat.Unknown, FileFormat.fromStr("path/to/file.bson"));
}

test "Can check if FileFormat is known" {
    try expectEqual(false, FileFormat.Unknown.known());
    try expectEqual(true, FileFormat.Json.known());
    try expectEqual(true, FileFormat.Yaml.known());
    try expectEqual(true, FileFormat.Csv.known());
}
