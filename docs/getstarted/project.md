# default の project 構成

## init

```sh title="powershell の例"
> mkdir hello-world
> cd hello-world
> zig init
info: created build.zig
info: created build.zig.zon
info: created src\main.zig
info: created src\root.zig
info: see `zig build --help` for a menu of options
> zig build run
All your codebase are belong to us.
Run `zig build test` to run the tests.
```

### src/main.zig

```zig
const std = @import("std");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
```

### src/root.zig

```zig
const std = @import("std");
const testing = std.testing;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}
```

### build.zig

```zig
const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "zig-hello",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "zig-hello",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
```

### build.zig.zon

```zig
.{
    .name = "zig-hello",
    // This is a [Semantic Version](https://semver.org/).
    // In a future version of Zig it will be used for package deduplication.
    .version = "0.0.0",

    // This field is optional.
    // This is currently advisory only; Zig does not yet do anything
    // with this value.
    //.minimum_zig_version = "0.11.0",

    // This field is optional.
    // Each dependency must either provide a `url` and `hash`, or a `path`.
    // `zig build --fetch` can be used to fetch all dependencies of a package, recursively.
    // Once all dependencies are fetched, `zig build` no longer requires
    // internet connectivity.
    .dependencies = .{
        // See `zig fetch --save <url>` for a command-line interface for adding dependencies.
        //.example = .{
        //    // When updating this field to a new URL, be sure to delete the corresponding
        //    // `hash`, otherwise you are communicating that you expect to find the old hash at
        //    // the new URL.
        //    .url = "https://example.com/foo.tar.gz",
        //
        //    // This is computed from the file contents of the directory of files that is
        //    // obtained after fetching `url` and applying the inclusion rules given by
        //    // `paths`.
        //    //
        //    // This field is the source of truth; packages do not come from a `url`; they
        //    // come from a `hash`. `url` is just one of many possible mirrors for how to
        //    // obtain a package matching this `hash`.
        //    //
        //    // Uses the [multihash](https://multiformats.io/multihash/) format.
        //    .hash = "...",
        //
        //    // When this is provided, the package is found in a directory relative to the
        //    // build root. In this case the package's hash is irrelevant and therefore not
        //    // computed. This field and `url` are mutually exclusive.
        //    .path = "foo",

        //    // When this is set to `true`, a package is declared to be lazily
        //    // fetched. This makes the dependency only get fetched if it is
        //    // actually used.
        //    .lazy = false,
        //},
    },

    // Specifies the set of files and directories that are included in this package.
    // Only files and directories listed here are included in the `hash` that
    // is computed for this package.
    // Paths are relative to the build root. Use the empty string (`""`) to refer to
    // the build root itself.
    // A directory listed here means that all files within, recursively, are included.
    .paths = .{
        // This makes *all* files, recursively, included in this package. It is generally
        // better to explicitly list the files and directories instead, to insure that
        // fetching from tarballs, file system paths, and version control all result
        // in the same contents hash.
        "",
        // For example...
        //"build.zig",
        //"build.zig.zon",
        //"src",
        //"LICENSE",
        //"README.md",
    },
}
```
