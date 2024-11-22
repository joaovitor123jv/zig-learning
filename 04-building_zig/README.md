# Building Zig

Yeah, you must be thinking "what happen with the pattern we were seing until now?".

Well, I chose to modify this README a bit, because I am studying right now the
build system of zig. And since the first step was always "How to execute" and we
will learn exactly this... makes no sense to keep the pattern here.

As I said, zig comes with a build system built-in, and the official ziglang.org
docs teach how to build a build.zig from scratch, BUT... when investigating the
`zig` command, I found a misterious `zig init` option.

This `zig init` performs the whole setup (as expected, ngl), and create a basic
"Hello World" project. And then I was sent into a wormhole, because the "Hello
World", is in reality a "All your codebase are belong to us.". Of course I must
understand what was happening there, so I went on searching, reddits, X posts,
random blogs on the web, and 80's games screen captures, until I found useless
(but cool) information about the Zig programming language. Good luck on
searching for it, it's cool.

Well, returning to the learning objective of this repository... I just made a
`zig init`, then modified a bit some files to have the content from the
03-recursion step, and tested.

To run the application using the build system: `zig build run`
To test the application using the build system: `zig build test`
To build the application using the build system: `zig build`

# Important concepts

The main build script is located the `build.zig`, and `build.zig.zon` seems to
be some kind of metadata, and not something like a `package-lock.json`, that was
what I was expecting.

Executing `zig init` created some settings I will not use right now, including
setup of libraries. So I just removed them to keep things simpler now.

The creted `zig build test` helper does not show the "X tests passed" when
testing executed successfully, but if you break some test, they will pop-out and
show there was an error in testing.
