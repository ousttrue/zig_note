const std = @import("std");
const GlfwWindow = @import("./glfwwindow.zig").GlfwWindow;
const glfw = @import("glfw");
const gl = @import("gl");
const imgui = @import("imgui");
const Renderer = @import("renderer.zig").Renderer;
const Store = @import("./store.zig").Store;

fn getProc(_: ?*glfw.GLFWwindow, name: [:0]const u8) ?*const anyopaque {
    return glfw.glfwGetProcAddress(@ptrCast([*:0]const u8, name));
}

pub fn main() anyerror!void {
    var allocator = std.heap.page_allocator;

    var store = try Store.init(allocator, "app.ini");
    defer store.save() catch {};

    //
    // create window
    //
    const window = GlfwWindow.init(allocator, &store, "zig imgui");
    defer window.deinit() catch {};

    //
    // Load the OpenGL function pointers
    //
    try gl.load(window.handle, getProc);
    std.log.info("OpenGL Version:  {s}", .{std.mem.span(gl.getString(gl.VERSION))});
    std.log.info("OpenGL Vendor:   {s}", .{std.mem.span(gl.getString(gl.VENDOR))});
    std.log.info("OpenGL Renderer: {s}", .{std.mem.span(gl.getString(gl.RENDERER))});

    //
    // init imgui
    //
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

    //
    // Setup Platform/Renderer backends
    //
    _ = imgui.ImGui_ImplGlfw_InitForOpenGL(@ptrCast(*imgui.GLFWwindow, window.handle), true);
    defer imgui.ImGui_ImplGlfw_Shutdown();
    const glsl_version = "#version 130";
    _ = imgui.ImGui_ImplOpenGL3_Init(.{ .glsl_version = glsl_version });
    defer imgui.ImGui_ImplOpenGL3_Shutdown();

    var renderer = try Renderer.init(std.testing.allocator);
    defer renderer.deinit();

    if (std.os.argv.len > 1) {
        const arg1 = try std.fmt.allocPrint(allocator, "{s}", .{std.os.argv[1]});
        renderer.fbo.scene.load(arg1);
    }

    //
    // Loop until the user closes the window
    //
    while (window.nextFrame()) |size| {
        renderer.render(size.width, size.height);

        // Update and Render additional Platform Windows
        // (Platform functions may change the current OpenGL context, so we save/restore it to make it easier to paste this code elsewhere.
        //  For this specific demo app we could also call glfwMakeContextCurrent(window) directly)
        if ((io.ConfigFlags & @enumToInt(imgui.ImGuiConfigFlags._ViewportsEnable)) != 0) {
            const backup_current_context = glfw.glfwGetCurrentContext();
            imgui.UpdatePlatformWindows();
            imgui.RenderPlatformWindowsDefault(.{});
            glfw.glfwMakeContextCurrent(backup_current_context);
        }
    }
    store.clear();

    std.debug.print("exit\n", .{});
}
