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
JSON file. This is not intended to be a real-life tool that will solve
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

During the implementation, the insights process became a bit hard, and I was
procrastinating to continue my study journey. So I started creating the project
by organizing small steps that showed progress.

## A versioning issue

I started this project using zig version 0.11.0, but I was away from the 
project for about 5 months, and new versions of zig compiler were launched.
This broke the project for a random error: "expected enum literal", pointing 
to the build.zig.zon file, on the `.name` definition.

After searching the web I found that on zig 0.14.0 it changed the way package 
names were defined, so I needed to fix every project I built uzing the 
build.zig files.

Here is the link were I found it: https://ziggit.dev/t/migrating-my-build-zig-zon-to-0-14-0-needs-the-name-to-be-an-enum-literal/8963/2

This is how the error looked:
```
➜  08-input_output git:(main) zig build run
/{redacted}zig-learning/08-input_output/build.zig.zon:9:13: error: expected enum literal
    .name = "08-input_output",
```

After fixing the package name error, I stepped in another weird error:
```
➜  08-input_output git:(main) zig build run
/{redacted}/zig-learning/08-input_output/build.zig.zon:1:2: error: missing top-level 'fingerprint' field; suggested value: 0x6121d313e3627142
.{
 ^
```

And yeah, you guessed it, same thing, another thing related to the new build 
system. I found and read these links and understood what changed:
- https://ziggit.dev/t/fingerprint-help/8849
- https://github.com/ziglang/zig/pull/22994
- https://ziglang.org/download/0.14.0/release-notes.html
- https://github.com/ziglang/zig/issues/19419
- https://github.com/Homebrew/homebrew-core/issues/134298

Then... yeah, another build error.

I've updated the build.zig to match the new
project name on build.zig.zon, added the new 'fingerprint' field with the
calculated value, but then I've stepped in an unexpected error. No, really, here
is the full log:
```
➜  08-input_output git:(main) ✗ zig build run
error: Unexpected
➜  08-input_output git:(main) ✗ 
```

After a lot of issues, I've created a project from zero following the
tutorials, and I got issues anyway. This proved me it was the zig version that
got some problems, so I've uninstalled zig compiler and decided to wait for a
fix (as I have not enough knowledge to fix it).

After a month or so, I've checked the zig version and it was 0.14.1. I've tried
executed the project, and it magically worked!

Now I can resume my learning journey on zig!

# How implemented it (the baby steps)

1. Build generic helper functions and test it!
  - [ ] Implement and test a `createFile` function
  - [ ] Implement and test a `ensureFileExists` function
  - [ ] Implement and test a `readFile` function
  - [ ] Implement and test a `FileFormat` enum
    - [ ] FileFormat has a `fromStr` function
    - [ ] FileFormat has a `toString` function
    - [ ] FileFormat has a `known` function
  - [ ] Implement a `showHelp` function
2. Modify the code to read the first and second args, and print to stdout
  - [ ] The software can be executed with: `zig build run -- inputFile outputFile`
3. Modify the code to copy the contents of inputFile on outputFile
  - [ ] The software copies the content from `inputFile` to `outputFile`
4. Implement a basic CSV parser
  - [ ] Implement a toString function for JSON parser
  - [ ] Implement a basic row parser:
    - Accepts only `,` as separator
    - Reads only ascii files
    - Only `a-z` `A-Z` `0-9` allowed for column data
    - Outputs a list of strings (each column)
  - [ ] Add support for more complex rows
    - Allows `,` as text of the column
    - Allows `\n` as text of the column
    - To allow special characters like `,` or `\n`, data with special chars must
      be escaped with `""`
    - To insert `"`, the column name should be escaped as `\"`
  - [ ] Add support to allow naming columns (header on 1st line, only)
  - [ ] Add support for reading CSV files to memory
  - [ ] Add support for saving the CSV in memory to file
5. Implement a basic JSON parser
  - [ ] Implement a toString function for JSON parser
  - [ ] Implement a basic list parser (everything is a string)
  - [ ] Implement a basic "object" parser (every key is a string, every value
    is a string)
  - [ ] Add support for reading JSON files to memory
  - [ ] Add support for saving the JSON in memory to a file
6. Implement a "wizard"
  - [ ] Fixed questions, mandatory responses
  - [ ] Fixed questions, optional responses (default values)
  - [ ] Custom questions (i18n), optional responses (default values)

