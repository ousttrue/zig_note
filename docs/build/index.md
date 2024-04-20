# build

## minimum

```zig title="0.12.0"
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zig-hello",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // install to zig-out/bin/ when build
    b.installArtifact(exe);
}
```

```zig title="0.11.0?"
const std = @import("std");

// minimum
pub fn build(b: *std.build.Builder) void {
    const exe = b.addExecutable("hello", "src/main.zig");

    const target = b.standardTargetOptions(.{});
    exe.setTarget(target);

    const mode = b.standardReleaseOptions();
    exe.setBuildMode(mode);

    exe.install();
}
```

- https://ziglang.org/documentation/0.9.1/std/#std;build.Builder.addExecutable
- https://ziglang.org/documentation/0.9.1/std/#std;build.LibExeObjStep

CMake ぽい？ `addexecutable` でビルドターゲットを定義するという感じか。

```
$ zig build
```

build to `zig-out/bin/hello.exe`

## packages

Pkg でエントリーポイントの依存を接続できる。

https://github.com/ziglang/zig/wiki/FAQ#zig-build

```zig
    const pkg_common = std.build.Pkg{
        .name = "common",
        .path = .{ .path = "libs/common/common.zig" },
        .dependencies = &[_]std.build.Pkg{
            std.build.Pkg{
                .name = "win32",
                .path = .{ .path = "libs/win32/win32.zig" },
                .dependencies = null,
            },
            // Pkg{
            //     .name = "build_options",
            //     .path = exe_options.getSource(),
            //     .dependencies = null,
            // },
        },
    };
    exe.addPackage(pkg_common);
```

## package manaager

Pkg で `build.zig` でやっていることを引き継ぐことができない問題の解決。

```zig
// 例
exe.addIncludePath("libepoxy_build/include");
```
