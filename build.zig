const std = @import("std");
const glfw = @import("pkgs/glfw/pkg.zig");
const imgui = @import("pkgs/imgui/pkg.zig");

const gl = std.build.Pkg{
    .name = "gl",
    .path = std.build.FileSource{ .path = "pkgs/zig-opengl/exports/gl_4v0.zig" },
};

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("zig_note", "main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    exe.linkLibC();
    exe.linkLibCpp();
    glfw.addTo(exe, "pkgs/glfw");
    imgui.addTo(exe, "pkgs/imgui");
    exe.addPackage(gl);

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
