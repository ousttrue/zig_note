const std = @import("std");
const Pkg = std.Build.Module;
const FileSource = std.build.FileSource;
const LibExeObjStep = std.Build.Step.Compile;

pub fn addTo(allocator: std.mem.Allocator, b: *std.Build, exe: *LibExeObjStep, relativePath: []const u8) *Pkg {
    // exe.addPackage(Pkg{
    //     .name = "scene",
    //     .source = FileSource{ .path = std.fmt.allocPrint(allocator, "{s}{s}", .{ relativePath, "/src/main.zig" }) catch @panic("allocPrint") },
    //     .dependencies = dependencies,
    // });
    const pkg = b.createModule(.{
        .root_source_file = .{ .path = std.fmt.allocPrint(allocator, "{s}{s}", .{ relativePath, "/src/main.zig" }) catch @panic("allocPrint") },
    });
    exe.root_module.addImport("scene", pkg);
    return pkg;
}
