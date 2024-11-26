# How to execute?

1. Install the zig compiler (on mac it is as simple as: `brew install zig`)
2. Go to this directory
3. Build and run the code with: `zig build run`
4. To execute the tests: `zig build test`

# What is expected to happen?

On this step of my learning curve, I was trying to implement from scratch some
default data sctructures. They are:
- Stack (First-In Last-Out)
- Queue (First-In First-Out)
- List (double-linked, adding and removing from start/end)
- Binary tree (with binary search)

But there are rules:
- I cannot use default-implemented data structures (like arrays/lists)
- I must manage the allocation and dealocation manually (as we study in C)
- I must add unit tests to all structures

This step is not complete yet, but there are implementations for the following structures:
- Stack
- Queue
- List

# Main difficulties

In order to build the data structures, I needed to study:
- Errors handling in zig
- How to use allocators
- How to use defer and errdefer
- How to run all tests linked to main.zig (including of other files)
- How to handle optional types
- How to use "unreachable" in zig and some shortcuts
