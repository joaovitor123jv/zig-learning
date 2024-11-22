# How to execute?

1. Install the zig compiler (on mac it is as simple as: `brew install zig`)
2. Go to this directory
3. Build and run the code with: `zig run main.zig`
4. To execute the tests: `zig test main.zig`

# What is expected to happen?

The program should execute, and the tests should pass. The expected message on
`zig test main.zig` is 'All 6 tests passed'.

Here we start to do cool things. In this step I write (once more) the classical
fibonacci recursion example, to get a grasp of the language behavior.

Zig seems to be pretty similar to C, so I have implemented the same function in
C, using the same method for comparing the two languages. Please note we are not
measuring performance here, the `zig run main.zig` first builds, then executes,
while the `./a.exe` just runs the already compiled binary.

To execute the C version, build it with `gcc main.c -o a.exe`, then execute
`./a.exe`.
