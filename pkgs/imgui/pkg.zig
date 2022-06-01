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

const SOURCES = [_][]const u8{
    "/pkgs/imgui/imgui.cpp",
    "/pkgs/imgui/imgui_draw.cpp",
    "/pkgs/imgui/imgui_widgets.cpp",
    "/pkgs/imgui/imgui_tables.cpp",
    "/pkgs/imgui/imgui_demo.cpp",
    "/pkgs/imgui/backends/imgui_impl_glfw.cpp",
    "/pkgs/imgui/backends/imgui_impl_opengl3.cpp",
    "/src/imvec2_byvalue.cpp",
};

pub fn addTo(exe: *LibExeObjStep, relativePath: []const u8) void {
    exe.addPackage(Pkg{
        .name = "imgui",
        .path = FileSource{ .path = concat(relativePath, "/src/main.zig") },
    });
    // exe.defineCMacro("_GLFW_WIN32", "1");
    // exe.defineCMacro("UNICODE", "1");
    // exe.defineCMacro("_UNICODE", "1");
    exe.addIncludeDir(concat(relativePath, "/pkgs/imgui"));
    // exe.addIncludeDir(concat(relativePath, "/pkgs/glfw/src"));
    for (SOURCES) |src| {
        exe.addCSourceFiles(&.{
            concat(relativePath, src),
        }, &.{});
    }
}
