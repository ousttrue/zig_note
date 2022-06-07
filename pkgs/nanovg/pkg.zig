const std = @import("std");
const Pkg = std.build.Pkg;
const FileSource = std.build.FileSource;
const LibExeObjStep = std.build.LibExeObjStep;

fn concat(lhs: []const u8, rhs: []const u8) []const u8 {
    if (std.testing.allocator.alloc(u8, lhs.len + rhs.len)) |buf| {
        for (lhs) |c, i| {
            buf[i] = c;
        }
        for (rhs) |c, i| {
            buf[i + lhs.len] = c;
        }
        return buf;
    } else |_| {
        @panic("alloc");
    }
}

pub fn addTo(exe: *LibExeObjStep, relativePath: []const u8) void {
    // pkgs/glfw/pkgs/glfw/src/CMakeLists.txt
    exe.addPackage(Pkg{
        .name = "nanovg",
        .path = FileSource{ .path = concat(relativePath, "/src/main.zig") },
    });
    // exe.defineCMacro("_GLFW_WIN32", "1");
    // exe.defineCMacro("UNICODE", "1");
    // exe.defineCMacro("_UNICODE", "1");
    // exe.addIncludeDir(concat(relativePath, "/pkgs/glfw/include"));
    // // exe.addIncludeDir(concat(relativePath, "/pkgs/glfw/src"));
    // exe.addCSourceFiles(&.{
    //     concat(relativePath, "/pkgs/glfw/src/context.c"),
    //     concat(relativePath, "/pkgs/glfw/src/init.c"),
    //     concat(relativePath, "/pkgs/glfw/src/input.c"),
    //     concat(relativePath, "/pkgs/glfw/src/monitor.c"),
    //     concat(relativePath, "/pkgs/glfw/src/platform.c"),
    //     concat(relativePath, "/pkgs/glfw/src/vulkan.c"),
    //     concat(relativePath, "/pkgs/glfw/src/window.c"),
    //     concat(relativePath, "/pkgs/glfw/src/egl_context.c"),
    //     concat(relativePath, "/pkgs/glfw/src/osmesa_context.c"),
    //     concat(relativePath, "/pkgs/glfw/src/null_init.c"),
    //     concat(relativePath, "/pkgs/glfw/src/null_monitor.c"),
    //     concat(relativePath, "/pkgs/glfw/src/null_window.c"),
    //     concat(relativePath, "/pkgs/glfw/src/null_joystick.c"),
    // }, &.{});
    // exe.addCSourceFiles(&.{
    //     concat(relativePath, "/pkgs/glfw/src/win32_module.c"),
    //     concat(relativePath, "/pkgs/glfw/src/win32_time.c"),
    //     concat(relativePath, "/pkgs/glfw/src/win32_thread.c"),
    //     concat(relativePath, "/pkgs/glfw/src/win32_init.c"),
    //     concat(relativePath, "/pkgs/glfw/src/win32_joystick.c"),
    //     concat(relativePath, "/pkgs/glfw/src/win32_monitor.c"),
    //     concat(relativePath, "/pkgs/glfw/src/win32_window.c"),
    //     concat(relativePath, "/pkgs/glfw/src/wgl_context.c"),
    // }, &.{});
    // exe.linkSystemLibrary("gdi32");
}
