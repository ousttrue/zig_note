# example_win32_directx11 の移植

<https://github.com/ocornut/imgui/tree/master/examples/example_win32_directx11>

最初の一歩として上記のコードを zig 化してみよう。

## CreateWindow

```zig
const std = @import("std");
const windows = std.os.windows;
const user32 = windows.user32;

fn wndProc(hWnd: windows.HWND, msg: windows.UINT, wParam: windows.WPARAM, lParam: windows.LPARAM) callconv(windows.WINAPI) windows.LRESULT {
    switch (msg) {
        user32.WM_DESTROY => {
            user32.PostQuitMessage(0);
            return 0;
        },
        else => {
            return user32.DefWindowProcA(hWnd, msg, wParam, lParam);
        },
    }
}
```

```zig
pub fn main() anyerror!void {

    const hInstance = kernel32.GetModuleHandleW(null) orelse return error.Fail;
    const wc = user32.WNDCLASSEXA{
        .hInstance = @ptrCast(windows.HINSTANCE, hInstance),
        .style = user32.CS_CLASSDC,
        .lpfnWndProc = wndProc,
        .hIcon = null,
        .hCursor = null,
        .hbrBackground = null,
        .lpszMenuName = null,
        .lpszClassName = "ImGui Example",
        .hIconSm = null,
    };
    try std.testing.expect(user32.RegisterClassExA(&wc) != 0);

    const hwnd = user32.CreateWindowExA(0, wc.lpszClassName, "Dear ImGui DirectX11 Example", user32.WS_OVERLAPPEDWINDOW, 100, 100, 1280, 800, null, null, wc.hInstance, null) orelse return error.Fail;
    _ = hwnd;

    // Show the window
    _ = user32.ShowWindow(hwnd, user32.SW_SHOWDEFAULT);
    _ = user32.UpdateWindow(hwnd);

    // Main loop
    var done = false;
    while (!done) {
        // Poll and handle messages (inputs, window resize, etc.)
        // You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
        // - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application.
        // - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application.
        // Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
        var msg: user32.MSG = undefined;
        while (user32.PeekMessageA(&msg, null, 0, 0, user32.PM_REMOVE) != 0) {
            _ = user32.TranslateMessage(&msg);
            _ = user32.DispatchMessageA(&msg);
            if (msg.message == user32.WM_QUIT) {
                done = true;
            }
        }
        if (done)
            break;
    }
}
```

## ImGui 合体

先人の手法を眺める・・・

* <https://github.com/SpexGuy/Zig-ImGui/blob/master/zig/imgui.zig>

`extern` を生成している？

* <https://github.com/michal-z/zig-gamedev/blob/main/libs/common/c.zig>

`cImport` でヘッダーを直接読み込んでいる？
`cImport` やってみよう。

### cImport

`c.zig`

```zig
pub usingnamespace @cImport({
    @cDefine("CIMGUI_DEFINE_ENUMS_AND_STRUCTS", "");
    @cDefine("CIMGUI_NO_EXPORT", "");
    @cInclude("cimgui.h");
});
```

`cimgui.h` が見えるようにする。 `build.zig`

```zig
    // c.zig
    exe.addIncludeDir("libs");
    exe.addIncludeDir("libs/cimgui");
    exe.linkLibC();
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("c++");
    exe.addCSourceFile("libs/imgui/imgui.cpp", &[_][]const u8{""});
    exe.addCSourceFile("libs/imgui/imgui_widgets.cpp", &[_][]const u8{""});
    exe.addCSourceFile("libs/imgui/imgui_tables.cpp", &[_][]const u8{""});
    exe.addCSourceFile("libs/imgui/imgui_draw.cpp", &[_][]const u8{""});
    exe.addCSourceFile("libs/imgui/imgui_demo.cpp", &[_][]const u8{""});
    exe.addCSourceFile("libs/cimgui/cimgui.cpp", &[_][]const u8{""});
```

`d3d11` にしようと思っていたのだけど `sokol` いってみよう。
