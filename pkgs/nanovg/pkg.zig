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

pub fn addTo(allocator: std.mem.Allocator, b: *std.Build, exe: *LibExeObjStep, relativePath: []const u8) void {
    // pkgs/glfw/pkgs/glfw/src/CMakeLists.txt
    // exe.addPackage(Pkg{
    //     .name = "nanovg",
    //     .source = FileSource{ .path = concat(allocator, relativePath, "/src/main.zig") },
    // });
    exe.root_module.addImport("nanovg", b.createModule(.{
        .root_source_file = .{
            .path = concat(allocator, relativePath, "/src/main.zig"),
        },
    }));
    // exe.defineCMacro("_GLFW_WIN32", "1");
    // exe.defineCMacro("UNICODE", "1");
    // exe.defineCMacro("_UNICODE", "1");
    // exe.addIncludeDir(concat(relativePath, "/pkgs/glfw/include"));
    // // exe.addIncludeDir(concat(relativePath, "/pkgs/glfw/src"));
    exe.addCSourceFiles(.{
        .files = &.{
            concat(allocator, relativePath, "/pkgs/picovg/src/nanovg.cpp"),
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
        },
        .flags = &.{},
    });
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
