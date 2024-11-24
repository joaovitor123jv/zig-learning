# How to execute?

1. Install the zig compiler (on mac it is as simple as: `brew install zig`)
2. Go to this directory
3. Build and run the code with: `zig build run`
4. To execute the tests: `zig build test`

# What is expected to happen?

On this step of my learning curve, I was trying to figure out how pointers would
work on the zig programming language, so I implemented a `swap` function that
just swap the arg 1 and 2 sent to the function.

The tests should all pass with no output. If they fail, the zig compiler emits
some information on what happened.

The expected output of this is:
```
A = 1. B = 2
Performing swap
A = 2. B = 1
```
