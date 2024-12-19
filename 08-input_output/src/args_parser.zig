const std = @import("std");
const StringHashMap = std.hash_map.StringHashMap;

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
};

const ArgsParserState = enum { WaitingNextOp, DefiningFilePath };

pub const ArgsParser = struct {
    arg_options: std.ArrayList([]const ArgOption),
    state: ArgsParserState,

    pub fn init(allocator: std.mem.Allocator) ArgsParser {
        return ArgsParser{ .state = ArgsParserState.waiting_next_op, .arg_options = std.ArrayList([]const ArgOption).init(allocator) };
    }

    pub fn addOption(self: ArgsParser, option: []const u8, description: []const u8, rules: []const u8) std.mem.Allocator.Error!void {
        const arg_option = ArgOption.build(option, description, rules);
        return self.arg_options.append(arg_option);
    }

    fn processArg(self: ArgsParser, argument: []const u8) void {
        switch (self.state) {
            ArgsParserState.waiting_next_op => {
                {}
            },
            _ => {},
        }
    }
};
