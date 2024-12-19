const std = @import("std");

pub const FileFormat = enum {
    Json,
    Csv,
    Yaml,
    Unknown,

    pub fn fromStr(str: []u8) FileFormat {
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
