# zon で glfw する

https://machengine.org/pkg/mach-glfw/

やってみる。

## zig の version を調整する。

https://machengine.org/about/zig-version/

- https://machengine.org/about/nominated-zig/#202430-mach-glfw

`2024.3.0-mach` は 以下のように zigup でバージョン指定する。

```sh
> zigup 0.12.0-dev.3180+83e578a18
```

## project

```sh
> mkdir zig_glfw
> cd zig_glfw
zig_glfw> zig init
info: created build.zig
info: created build.zig.zon # 👈 0.12.dev
info: created src\main.zig
info: created src\root.zig # 👈 0.12.dev
```

## zon の dependncies に mach-glfw を追記する

```zon title="build.zig.zon"
.mach_glfw = .{
    .url = "https://pkg.machengine.org/mach-glfw/1a9a03399058fd83f7fbb597f3f8304007ff6a3c.tar.gz",
    .hash = "1220b4d58ec6cf53abfd8d7547d39afb9bffa41822d4d58f52625230466e51cc93bb",
},
```

## build.zig に march_glfw への依存を追加

```zing
    const exe = b.addExecutable(.{
        .name = "zig_glfw",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    const glfw_dep = b.dependency("mach_glfw", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("mach-glfw", glfw_dep.module("mach-glfw"));
```

## src/main.zig で glfw を使う

```zig
const glfw = @import("mach-glfw");
```

