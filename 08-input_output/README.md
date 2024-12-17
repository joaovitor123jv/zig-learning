# How to execute?

1. Install the zig compiler (on mac it is as simple as: `brew install zig`)
2. Go to this directory
3. Build and run the code with: `zig build run`
4. To execute the tests: `zig build test`

# What is expected to happen?

Until now, we were using the "debug" way of printing to screen. Unlike C, zig's
std.debug.print does not print to stdout, but to stderr, and this is intentional
behavior.

On this step, I will build a command-line tool that converts a CSV file to a
JSON or YAML file. This is not intended to be a real-life tool that will solve
humanity's problem of file conversion, but a tool developed to improve my
learning of the zig programming language.

The rules for this project are:
- Print to stdout only when necessary (no debugs to stdout)
- Should accept CLI args as commands (allowing working with scripts)
- Should provide a "wizard" interface (when operating manually)
- Results should be saved as files
- All content from the CSV file should be included on the result file
- The majority of methods must include unit tests (if not 100% of the methods)

# Main difficulties

I have found unexpected differences between Linux, macOS and Windows on the
behaviour of some constants. For instance, this code works well on Unix
systems, but not on Windows systems:

```zig
const std = @import("std");
const stdout = std.io.getStdOut();

fn main() !void {
    try stdout.writer().print("Hello World!\n");
    return;
}
```

Accordingly to the sources I've read, the stdout file on Unix systems have a
predefined, fixed value, known at compile time. While Windows systems have a
value known only in runtime. This way, to make this code work in both systems,
we need to adapt it to something like the code below:

```zig
const std = @import("std");

fn main() !void {
    const stdout = std.io.getStdOut();
    try stdout.writer().print("Hello World!\n");
    return;
}
```

This is not exclusive for stdout and stdin, as this behaviour can happen in
different, unknown situations.


