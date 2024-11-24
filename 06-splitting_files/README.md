# How to execute?

1. Install the zig compiler (on mac it is as simple as: `brew install zig`)
2. Go to this directory
3. Build and run the code with: `zig build run`
4. To execute the tests: `zig build test`

# What is expected to happen?

On this step of my learning curve, I was trying to figure out how would I import
functions from other files on the zig programming language. I have not found how
to do it explicitly, then I tried to see how it was done on the source code of
zig's compiler.

It is as simple as the first hello world teach us, using the @import(string)
syntax, but we need to add a `.zig` on the end of it. Also, the compiler will
import just the "public" things, so be sure to add a `pub` before their
declaration.

The tests should all pass with no output. If they fail, the zig compiler emits
some information on what happened.

The expected output of this is:
```
Hi, I am the public function from fila_a.zig
And I am the private function from the file_a.zig
I am the public function from directory/file_b.zig: This is a test
```
