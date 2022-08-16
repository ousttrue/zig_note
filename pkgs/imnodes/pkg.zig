const std = @import("std");
const Pkg = std.build.Pkg;
const FileSource = std.build.FileSource;
const LibExeObjStep = std.build.LibExeObjStep;

fn concat(allocator: std.mem.Allocator, lhs: []const u8, rhs: []const u8) []const u8 {
    if (allocator.alloc(u8, lhs.len + rhs.len)) |buf| {
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

pub fn addTo(allocator: std.mem.Allocator, exe: *LibExeObjStep, relativePath: []const u8, dependencies: ?[]const Pkg) Pkg {
    const pkg = Pkg{
        .name = "imnodes",
        .source = FileSource{ .path = std.fmt.allocPrint(allocator, "{s}{s}", .{ relativePath, "/src/main.zig" }) catch @panic("allocPrint") },
        .dependencies = dependencies,
    };
    exe.addCSourceFiles(&.{
        concat(allocator, relativePath, "/pkgs/imnodes/imnodes.cpp"),
    }, &.{});

    exe.addPackage(pkg);
    return pkg;
}
