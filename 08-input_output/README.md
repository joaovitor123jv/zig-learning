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

Here I will register the main difficulties I have found during implementation.
