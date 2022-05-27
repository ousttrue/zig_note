const std = @import("std");
const glfw = @import("pkgs/glfw/src/main.zig");
const gl = @import("pkgs/zig-opengl/exports/gl_4v0.zig");
const imgui = @import("pkgs/imgui/src/main.zig");
const Renderer = @import("renderer.zig").Renderer;

fn getProc(_: ?*glfw.GLFWwindow, name: [:0]const u8) ?*const anyopaque {
    return glfw.glfwGetProcAddress(@ptrCast([*:0]const u8, name));
}

fn glfw_error_callback(code: c_int, description: ?[*:0]const u8) callconv(.C) void {
    std.debug.print("Glfw Error {}: {s}", .{ code, description });
}

pub fn main() anyerror!void {
    // https://www.glfw.org/documentation.html

    // Initialize the library
    _ = glfw.glfwSetErrorCallback(&glfw_error_callback);

    if (glfw.glfwInit() == 0)
        @panic("glfwInit");
    defer glfw.glfwTerminate();

    // Create a windowed mode window and its OpenGL context
    const window = glfw.glfwCreateWindow(640, 480, "Hello World", null, null);
    if (window == null) {
        @panic("glfwCreateWindow");
    }
    defer glfw.glfwDestroyWindow(window);

    // Make the window's context current
    glfw.glfwMakeContextCurrent(window);
    glfw.glfwSwapInterval(1); // Enable vsync

    // Load the OpenGL function pointers
    try gl.load(window, getProc);

    // Print information about the selected OpenGL context:
    std.log.info("OpenGL Version:  {s}", .{std.mem.span(gl.getString(gl.VERSION))});
    std.log.info("OpenGL Vendor:   {s}", .{std.mem.span(gl.getString(gl.VENDOR))});
    std.log.info("OpenGL Renderer: {s}", .{std.mem.span(gl.getString(gl.RENDERER))});

    _ = imgui.CreateContext(.{});
    defer imgui.DestroyContext(.{});

    const io = imgui.GetIO();
    io.ConfigFlags |= @enumToInt(imgui.ImGuiConfigFlags._NavEnableKeyboard); // Enable Keyboard Controls
    //io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;      // Enable Gamepad Controls
    io.ConfigFlags |= @enumToInt(imgui.ImGuiConfigFlags._DockingEnable); // Enable Docking
    io.ConfigFlags |= @enumToInt(imgui.ImGuiConfigFlags._ViewportsEnable); // Enable Multi-Viewport / Platform Windows
    //io.ConfigViewportsNoAutoMerge = true;
    //io.ConfigViewportsNoTaskBarIcon = true;

    // Setup Dear ImGui style
    imgui.StyleColorsDark(.{});

    // When viewports are enabled we tweak WindowRounding/WindowBg so platform windows can look identical to regular ones.
    var style = imgui.GetStyle();
    if ((io.ConfigFlags & @enumToInt(imgui.ImGuiConfigFlags._ViewportsEnable)) != 0) {
        style.WindowRounding = 0.0;
        style.Colors[@enumToInt(imgui.ImGuiCol._WindowBg)].w = 1.0;
    }

    // Setup Platform/Renderer backends
    _ = imgui.ImGui_ImplGlfw_InitForOpenGL(@ptrCast(*imgui.GLFWwindow, window), true);
    defer imgui.ImGui_ImplGlfw_Shutdown();
    const glsl_version = "#version 130";
    _ = imgui.ImGui_ImplOpenGL3_Init(.{ .glsl_version = glsl_version });
    defer imgui.ImGui_ImplOpenGL3_Shutdown();

    var renderer = try Renderer.init(std.testing.allocator);
    defer renderer.deinit();

    // Loop until the user closes the window
    while (glfw.glfwWindowShouldClose(window) == 0) {
        // Poll for and process events
        glfw.glfwPollEvents();

        var display_w: c_int = undefined;
        var display_h: c_int = undefined;
        glfw.glfwGetFramebufferSize(window, &display_w, &display_h);

        renderer.render(display_w, display_h);

        // Update and Render additional Platform Windows
        // (Platform functions may change the current OpenGL context, so we save/restore it to make it easier to paste this code elsewhere.
        //  For this specific demo app we could also call glfwMakeContextCurrent(window) directly)
        if ((io.ConfigFlags & @enumToInt(imgui.ImGuiConfigFlags._ViewportsEnable)) != 0) {
            const backup_current_context = glfw.glfwGetCurrentContext();
            imgui.UpdatePlatformWindows();
            imgui.RenderPlatformWindowsDefault(.{});
            glfw.glfwMakeContextCurrent(backup_current_context);
        }
        // Swap front and back buffers
        glfw.glfwSwapBuffers(window);
    }
}
