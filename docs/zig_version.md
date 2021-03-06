# zig version

## 0.10.0 (master)

### std.ChildProcess.init

* <https://github.com/ziglang/zig/commit/a0a2ce92ca129d28e22c63f7bace1672c43776b5>

```zig
const proc = try std.ChildProcess.init(argv, gpa);
// ๐
var proc = std.ChildProcess.init(argv, gpa);
```

### Pkg.path

FileSource ใซๅๅคๆดใ

```zig
pub const glfw = Pkg{
    .name = "glfw",
    .path = FileSource{
        .path = ".gyro\\mach-glfw-hexops-github.com-dae779de\\pkg\\src\\main.zig",
    },
};
```

## 0.9.1 (20220214)

* <https://ziglang.org/download/0.9.1/release-notes.html>

## 0.9.0

* <https://ziglang.org/download/0.9.0/release-notes.html>

* [c_void renamed to anyopaque](https://ziglang.org/download/0.9.0/release-notes.html#c_void-renamed-to-anyopaque)

### `use of undeclared identifier`

* [usingnamespace No Longer Affects Identifier Lookup](https://ziglang.org/download/0.9.0/release-notes.html#usingnamespace-No-Longer-Affects-Identifier-Lookup)

<https://ziglang.org/download/0.9.0/release-notes.html#usingnamespace-No-Longer-Affects-Identifier-Lookup>

ไพ

```zig
const std = @import("std");
usingnamespace std.os.windows.user32;

pub fn main() anyerror!void {
    const wndclass = WNDCLASSEXA // <- use of undeclared identifier
```

๐ symbol import ใซ้ ผใใชใ

```zig
const std = @import("std");
const user32 = std.os.windows.user32;

pub fn main() anyerror!void {
    const wndclass = user32.WNDCLASSEXA
```

### Unused-Locals

* <https://ziglang.org/download/0.9.0/release-notes.html#Compile-Errors-for-Unused-Locals>


```zig
const a = 0;
// ใจใใใใ
_ = a;
```

## 0.8.0

* <https://ziglang.org/download/0.8.0/release-notes.html>

* [No More Extern or Packed Enums](https://ziglang.org/download/0.8.0/release-notes.html#No-More-Extern-or-Packed-Enums)

### builtin

* <https://ziglang.org/download/0.8.0/release-notes.html#importbuiltin-no-longer-re-exports-stdbuiltin>

`container 'std.builtin' has no member called 'os'`

OSๅคๅฎใใงใใชใ

```
std.Target.current.os.tag == .macos
```

```
const builtin = @import("builtin");
const separator = if (builtin.os.tag == builtin.Os.windows) '\\' else '/';
```

## 0.7.0

* <https://ziglang.org/download/0.7.0/release-notes.html>


### comptime var to anytype

<https://github.com/ziglang/zig/issues/4820>

`expected type expression, found 'var'`

```
comptime name: var
```

ๅๆจ่ซใฎๆๆณ๏ผ

<https://ziglang.org/documentation/master/#Function-Parameter-Type-Inference>

```
comptime name: anytype
```

## 0.6.0

* <https://ziglang.org/download/0.6.0/release-notes.html>

* [Remove Array-to-Reference Type Coercion](https://ziglang.org/download/0.6.0/release-notes.html#Remove-Array-to-Reference-Type-Coercion)

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
