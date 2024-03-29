# build zig

LLVM をクロス環境込みで独自ビルドするのがわりと大変。

## LLVM

`zig` コンパイラが LLVM の `static` ビルドとリンクするようになっているので、
`static` ビルドを作る必要がある。

https://github.com/ziglang/zig/wiki/How-to-build-LLVM,-libclang,-and-liblld-from-source#windows

## `vcpkg` 使えるか？

`x64-windows-static`
`atl` 必要

https://github.com/microsoft/vcpkg/issues/7543

```
LINK : fatal error LNK1201: error writing to program database ''; check for insufficient disk space, invalid path,      or insufficient privilege
```

`VCPKG_MAX_CONCURRENCY=4` で再試行。

`i7-10700F 2.9GHZ` で 90分くらいかかった。

## @byteOffsetOf

`@offsetOf`

https://github.com/ziglang/zig/issues/7794


## @OpaqueType

```zig
pub const GLFWwindow = @OpaqueType();

pub const GLFWwindow = opaque {};
```

## enum

```zig
pub const DataType = extern enum {
    S8 = 0,

pub const DataType = enum(int32) {
    S8 = 0,
```

## c_void => `anyopaque`

https://ziglang.org/download/0.9.0/release-notes.html#c_void-renamed-to-anyopaque
