const std = @import("std");
const glfw = @import("pkgs/glfw/pkg.zig");
const imgui = @import("pkgs/imgui/pkg.zig");
const glo = @import("pkgs/glo/pkg.zig");
const screen = @import("pkgs/screen/pkg.zig");
const scene = @import("pkgs/scene/pkg.zig");
const zigla = @import("pkgs/zigla/pkg.zig");
const nanovg = @import("pkgs/nanovg/pkg.zig");
const imnodes = @import("pkgs/imnodes/pkg.zig");
//
// const gl = std.build.Pkg{
//     .name = "gl",
//     .source = std.build.FileSource{ .path = "pkgs/zig-opengl/exports/gl_4v0.zig" },
// };

pub fn build(b: *std.Build) void {
    const gl = b.createModule(.{
        .root_source_file = .{ .path = "pkgs/zig-opengl/my_binding.zig" },
    });

    const allocator = std.heap.page_allocator;
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "zig_note",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // install to zig-out/bin/ when build
    b.installArtifact(exe);

    exe.linkLibC();
    exe.linkLibCpp();
    const ziglaPkg = zigla.addTo(allocator, b, exe, "pkgs/zigla");
    glfw.addTo(allocator, b, exe, "pkgs/glfw");
    nanovg.addTo(allocator, b, exe, "pkgs/nanovg");
    imgui.addTo(allocator, b, exe, "pkgs/imgui");
    const gloPkg = glo.addTo(allocator, b, exe, "pkgs/glo");
    gloPkg.addImport("gl", gl);
    const screenPkg = screen.addTo(allocator, b, exe, "pkgs/screen");
    _ = screenPkg;
    const scenePkg = scene.addTo(allocator, b, exe, "pkgs/scene");
    scenePkg.addImport("zigla", ziglaPkg);
    scenePkg.addImport("glo", gloPkg);

    exe.root_module.addImport("gl", gl);
    _ = imnodes.addTo(allocator, b, exe, "pkgs/imnodes");

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // const exe_tests = b.addTest("src/main.zig");
    // exe_tests.setTarget(target);
    // // exe_tests.setBuildMode(mode);
    //
    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&exe_tests.step);
}
