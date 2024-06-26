# breaking changes

## 0.12.0

### target 回り

`root_module.resolved_target` !

```zig
-    const target = step.target;
-    if (target.isWindows()) {

+    const target = step.root_module.resolved_target.?;
+    if (target.result.os.tag == .windows) {
```

### addPackage => addModule => addImport

- https://github.com/ziglang/zig/issues/14278

👇

- https://ziggit.dev/t/what-happened-to-addmodule/2908

### std.build.LibExeObjStep => std.Build.Step.Compile;

- https://github.com/ziglang/zig/pull/14498

### extra capture in for loop

- https://github.com/dmgk/zig-uuid/issues/2

### zig init-exe は zig init に

なった。

### exe.addModule の変更

- [Upcoming zig 0.12 changes of writing `build.zig`](https://zig.news/liyu1981/upcoming-zig-012-changes-of-writing-buildzig-1hb7)

## 0.11.0

### json.TokenStream

- https://ziglang.org/download/0.11.0/release-notes.html#JSON

## 0.10.0

### std.ChildProcess.init

- https://github.com/ziglang/zig/commit/a0a2ce92ca129d28e22c63f7bace1672c43776b5

```zig
const proc = try std.ChildProcess.init(argv, gpa);
// 👇
var proc = std.ChildProcess.init(argv, gpa);
```

### Pkg.path

FileSource に型変更。

```zig
pub const glfw = Pkg{
    .name = "glfw",
    .path = FileSource{
        .path = ".gyro\\mach-glfw-hexops-github.com-dae779de\\pkg\\src\\main.zig",
    },
};
```

## 0.9.1 (20220214)

- https://ziglang.org/download/0.9.1/release-notes.html

## 0.9.0

- https://ziglang.org/download/0.9.0/release-notes.html

- [c_void renamed to anyopaque](https://ziglang.org/download/0.9.0/release-notes.html#c_void-renamed-to-anyopaque)

### `use of undeclared identifier`

- [usingnamespace No Longer Affects Identifier Lookup](https://ziglang.org/download/0.9.0/release-notes.html#usingnamespace-No-Longer-Affects-Identifier-Lookup)

https://ziglang.org/download/0.9.0/release-notes.html#usingnamespace-No-Longer-Affects-Identifier-Lookup

例

```zig
const std = @import("std");
usingnamespace std.os.windows.user32;

pub fn main() anyerror!void {
    const wndclass = WNDCLASSEXA // <- use of undeclared identifier
```

👇 symbol import に頼らない

```zig
const std = @import("std");
const user32 = std.os.windows.user32;

pub fn main() anyerror!void {
    const wndclass = user32.WNDCLASSEXA
```

### Unused-Locals

- https://ziglang.org/download/0.9.0/release-notes.html#Compile-Errors-for-Unused-Locals

```zig
const a = 0;
// とりあえず
_ = a;
```

## 0.8.0

- https://ziglang.org/download/0.8.0/release-notes.html

- [No More Extern or Packed Enums](https://ziglang.org/download/0.8.0/release-notes.html#No-More-Extern-or-Packed-Enums)

### builtin

- https://ziglang.org/download/0.8.0/release-notes.html#importbuiltin-no-longer-re-exports-stdbuiltin

`container 'std.builtin' has no member called 'os'`

OS判定ができない

```
std.Target.current.os.tag == .macos
```

```
const builtin = @import("builtin");
const separator = if (builtin.os.tag == builtin.Os.windows) '\\' else '/';
```

## 0.7.0

- https://ziglang.org/download/0.7.0/release-notes.html

### comptime var to anytype

https://github.com/ziglang/zig/issues/4820

`expected type expression, found 'var'`

```
comptime name: var
```

型推論の文法？

https://ziglang.org/documentation/master/#Function-Parameter-Type-Inference

```
comptime name: anytype
```

## 0.6.0

- https://ziglang.org/download/0.6.0/release-notes.html

- [Remove Array-to-Reference Type Coercion](https://ziglang.org/download/0.6.0/release-notes.html#Remove-Array-to-Reference-Type-Coercion)

## Trouble

### `libc headers not available; compilation does not link against libc`

`biuld.zig`

```zig
exe.linkLibC();
```

### `error: AccessDenied`

```zig
exe.linkSystemLibrary("c");
exe.linkSystemLibrary("c++");
```
