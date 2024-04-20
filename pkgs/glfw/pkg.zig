const std = @import("std");
const Pkg = std.build.Pkg;
const FileSource = std.build.FileSource;
const LibExeObjStep = std.Build.Step.Compile;

fn concat(allocator: std.mem.Allocator, lhs: []const u8, rhs: []const u8) []const u8 {
    if (allocator.alloc(u8, lhs.len + rhs.len)) |buf| {
        for (lhs, 0..) |c, i| {
            buf[i] = c;
        }
        for (rhs, 0..) |c, i| {
            buf[i + lhs.len] = c;
        }
        return buf;
    } else |_| {
        @panic("alloc");
    }
}

pub fn addTo(allocator: std.mem.Allocator, exe: *LibExeObjStep, relativePath: []const u8) void {
    // pkgs/glfw/pkgs/glfw/src/CMakeLists.txt
    exe.addModule(Pkg{
        .name = "glfw",
        .source = FileSource{ .path = concat(allocator, relativePath, "/src/main.zig") },
    });
    exe.defineCMacro("_GLFW_WIN32", "1");
    exe.defineCMacro("UNICODE", "1");
    exe.defineCMacro("_UNICODE", "1");
    exe.addIncludeDir(concat(allocator, relativePath, "/pkgs/glfw/include"));
    // exe.addIncludeDir(concat(relativePath, "/pkgs/glfw/src"));
    exe.addCSourceFiles(&.{
        concat(allocator, relativePath, "/pkgs/glfw/src/context.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/init.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/input.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/monitor.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/platform.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/vulkan.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/window.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/egl_context.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/osmesa_context.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/null_init.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/null_monitor.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/null_window.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/null_joystick.c"),
    }, &.{});
    exe.addCSourceFiles(&.{
        concat(allocator, relativePath, "/pkgs/glfw/src/win32_module.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/win32_time.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/win32_thread.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/win32_init.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/win32_joystick.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/win32_monitor.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/win32_window.c"),
        concat(allocator, relativePath, "/pkgs/glfw/src/wgl_context.c"),
    }, &.{});
    exe.linkSystemLibrary("gdi32");
}
