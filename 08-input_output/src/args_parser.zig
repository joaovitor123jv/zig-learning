const std = @import("std");
const StringHashMap = std.hash_map.StringHashMap;

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

pub const ArgOption = struct {
    option: []const u8,
    description: []const u8,
    rules: []const u8,
    value: ?[]u8,

    fn build(option: []const u8, description: []const u8, rules: []const u8) ArgOption {
        return ArgOption{
            .option = option,
            .description = description,
            .rules = rules,
            .value = null,
        };
    }

    fn setValue(self: ArgOption, value: []u8) void {
        self.value = value;
    }

    fn hasValue(self: ArgOption) bool {
        return self.value != null;
    }

    fn matches(self: ArgOption, option: []const u8) bool {
        return std.mem.eql(u8, self.option, option);
    }
};

test "Can build ArgOption" {
    const key = "--input";
    const description = "Set the input file";
    const rules = "File must be a JSON, CSV or YAML.";
    const arg_option = ArgOption.build(key, description, rules);

    try expectEqual(key, arg_option.option);
    try expectEqual(description, arg_option.description);
    try expectEqual(rules, arg_option.rules);
    try expectEqual(null, arg_option.value);
}

test "Can define and change value in ArgOption" {
    const input_file_1 = "input.csv";
    const input_file_2 = "input.json";
    const arg_option = ArgOption.build("--input", "Set the input file", "File must be a JSON, CSV or YAML");

    try expectEqual(null, arg_option);

    arg_option.setValue(input_file_1);
    try expectEqual(input_file_1, arg_option.value.?);

    arg_option.setValue(input_file_2);
    try expectEqual(input_file_2, arg_option.value.?);
}

test "Can check if value is defined on ArgOption" {
    const input = "input.csv";
    const arg_option = ArgOption.build("--input", "Set the input file", "File must be a JSON, CSV or YAML");
    try expectEqual(null, arg_option);

    try expectEqual(false, arg_option.hasValue());
    arg_option.setValue(input);
    try expectEqual(true, arg_option.hasValue());
}

const ArgsParserState = enum { waiting_next_op, defining_option_value };

pub const ArgsParser = struct {
    allocator: std.mem.Allocator,
    arg_options: std.ArrayList(ArgOption),
    state: ArgsParserState,
    current_arg: ?ArgOption,

    pub fn init(allocator: std.mem.Allocator) ArgsParser {
        return ArgsParser{
            .state = ArgsParserState.waiting_next_op,
            .arg_options = std.ArrayList([]const ArgOption).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn addOption(self: ArgsParser, option: []const u8, description: []const u8, rules: []const u8) std.mem.Allocator.Error!void {
        const arg_option = ArgOption.build(option, description, rules);
        return self.arg_options.append(arg_option);
    }

    fn processArg(self: ArgsParser, argument: []const u8) void {
        switch (self.state) {
            ArgsParserState.waiting_next_op => {
                for (self.arg_options.items) |arg_option| {
                    if (arg_option.matches(argument)) {
                        self.current_arg = arg_option;
                        self.state = ArgsParserState.defining_option_value;
                        break;
                    }
                }
            },
            ArgsParserState.defining_option_value => {
                if (self.current_arg) |arg| {
                    arg.setValue(argument);
                } else {
                    std.debug.panic("Failed to define value for current_arg == null.", .{});
                }
            },
        }
    }

    fn genResult(self: ArgsParser) std.mem.Allocator.Error!StringHashMap([]const u8) {
        var result = StringHashMap([]const u8).init(self.allocator);

        for (self.arg_options.items) |arg_option| {
            if (arg_option.value) |readable_value| {
                // If key is duplicated, the put fails
                try result.put(arg_option.option, readable_value);
            } else {
                std.debug.panic("Failed to set value for option {s}. Value is null.", .{arg_option.option});
            }
        }

        return result;
    }
};
