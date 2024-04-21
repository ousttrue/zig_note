const std = @import("std");
const Pkg = std.Build.Module;
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

pub fn addTo(allocator: std.mem.Allocator, b: *std.Build, exe: *LibExeObjStep, relativePath: []const u8) *Pkg {
    // const pkg = Pkg{
    //     .name = "imnodes",
    //     .source = FileSource{ .path = std.fmt.allocPrint(allocator, "{s}{s}", .{ relativePath, "/src/main.zig" }) catch @panic("allocPrint") },
    //     .dependencies = dependencies,
    // };
    exe.addCSourceFiles(.{ .files = &.{
        concat(allocator, relativePath, "/pkgs/imnodes/imnodes.cpp"),
    }, .flags = &.{} });
    const pkg = b.createModule(.{
        .root_source_file = .{ .path = std.fmt.allocPrint(allocator, "{s}{s}", .{ relativePath, "/src/main.zig" }) catch @panic("allocPrint") },
    });
    exe.root_module.addImport("imnodes", pkg);
    return pkg;
}
