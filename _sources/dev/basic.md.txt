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

* <https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools>
* <https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb>

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
        "editor.defaultFormatter": "tiehuis.zig"
    },
    "zig.buildOnSave": true,
```

## zig
### main.zig

```zig
const std = @import("std");

pub fn main() anyerror!void {
    std.log.info("All your codebase are belong to us.", .{});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
```

### @import

[builtin function](https://ziglang.org/documentation/0.9.0/#Builtin-Functions) に `@` がついている。

* <https://zig.news/mattnite/import-and-packages-23mb>


### `.{}`

```zig
    std.log.info("All your codebase are belong to us.", .{});
```

`.{}` の意味？

`anonymous struct` ?

<https://ziglearn.org/chapter-1/#anonymous-structs>

```zig
        /// Log an info message. This log level is intended to be used for
        /// general messages about the state of the program.
        pub fn info(
            comptime format: []const u8,
            args: anytype,
        ) void {
            log(.info, scope, format, args);
        }
```

デフォルト値というか空値を導入するイディオムぽい。

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
