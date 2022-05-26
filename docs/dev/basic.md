# basic

* <https://zig.news/jarredsumner/setting-up-visual-studio-code-for-writing-zig-kcj>

## project

```
> zig init-exe
```

* build.zig
* src
   * main.zig

```
# .gitignore
zig-cache
zig-out
```

## vscode

### tasks.json(build)

```js
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build",
            "type": "shell",
            "command": "zig build",
            "problemMatcher": [
                "$gcc" // <= gcc これ
            ]
        }
    ]
}
```

### launch.json

* <https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools> pdb debugger for Windows.
* <https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb> for set break point.

```js
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "run",
            "type": "cppvsdbg",
            "request": "launch",
            "program": "${workspaceFolder}/zig-out/bin/hello.exe",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "console": "integratedTerminal"
        }
    ]
}
```

### settings.json

```js
    "zigLanguageClient.path": "C:/zig/zls.exe",
    "[zig]": {
        "editor.defaultFormatter": "AugusteRame.zls-vscode" // こっちの方が Windows でパスの問題が出ない
    },
    "zig.buildOnSave": true,
```

## zig
### main.zig

```zig
const std = @import("std"); // pkg名か zig ファイル名を指定する。

pub fn main() anyerror!void {
    std.log.info("All your codebase are belong to us.", .{}); // .{} は型推論で型名を省略する意味
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
```

### @import

[builtin function](https://ziglang.org/documentation/0.9.0/#Builtin-Functions) に `@` がついている。

* <https://zig.news/mattnite/import-and-packages-23mb>


### `.{}`

`.` で型名の省略。
`{}` でデフォルト値による初期化。struct はデフォルト値を定義できる。

```zig
    std.log.info("All your codebase are belong to us.", .{});
```

### 関数定義

<https://ziglang.org/documentation/master/#Functions>


```zig
fn NAME(params) RETURN_TYPE
{

}
```

### ErrorUnionType

<https://ziglang.org/documentation/master/#Error-Union-Type>


```zig
pub fn parseU64(buf: []const u8, radix: u8) !u64 {
}
```

```zig
// エラーか非エラー
pub fn main() anyerror|void {
}
```

### Null

<https://ziglang.org/documentation/master/#Optionals>

### pointer

*T - single-item pointer to exactly one item.
Supports deref syntax: ptr.*
[*]T - many-item pointer to unknown number of items.
Supports index syntax: ptr[i]
Supports slice syntax: ptr[start..end]
Supports pointer arithmetic: ptr + x, ptr - x
T must have a known size, which means that it cannot be anyopaque or any other opaque type.
*[N]T - pointer to N items, same as single-item pointer to an array.
Supports index syntax: array_ptr[i]
Supports slice syntax: array_ptr[start..end]
Supports len property: array_ptr.len
[]T - pointer to runtime-known number of items.
Supports index syntax: slice[i]
Supports slice syntax: slice[start..end]
Supports len property: slice.len
```zig
var some: i32 = 1;
var p_some: *i32 = &some;
const p_some_const: *const i32 = &some;
```

### array

コンパイル時に要素数が決まっている。`_` で推論できる。

```
// modifiable array
var some_integers: [100]i32 = undefined;

// array literal
const message = [_]u8{ 'h', 'e', 'l', 'l', 'o' };

// anonymous list literal
var array: [4]u8 = .{11, 22, 33, 44};
```

sentinel

```
test "null terminated array" {
    const array = [_:0]u8 {1, 2, 3, 4};

    try expect(@TypeOf(array) == [4:0]u8);
    try expect(array.len == 4);
    try expect(array[4] == 0);
}
```


