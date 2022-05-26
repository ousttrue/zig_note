const std = @import("std");
const glfw = @import("glfw");
const gl = @import("gl");
const imgui = @import("pkgs/imgui/src/main.zig");

fn getProc(_: ?*glfw.GLFWwindow, name: [:0]const u8) ?*anyopaque {
    return glfw.glfwGetProcAddress(@ptrCast([*]const u8, name));
}

pub fn main() anyerror!void {
    // https://www.glfw.org/documentation.html

    // Initialize the library
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
    const io = imgui.GetIO() orelse @panic("GetIO");

    // Setup Dear ImGui style
    imgui.StyleColorsDark(.{});

    // Setup Platform/Renderer backends
    _ = imgui.ImGui_ImplGlfw_InitForOpenGL(@ptrCast(*imgui.GLFWwindow, window), true);
    const glsl_version = "#version 130";
    defer imgui.ImGui_ImplGlfw_Shutdown();
    _ = imgui.ImGui_ImplOpenGL3_Init(.{ .glsl_version = glsl_version });
    defer imgui.ImGui_ImplOpenGL3_Shutdown();

    // Load Fonts
    // - If no fonts are loaded, dear imgui will use the default font. You can also load multiple fonts and use ImGui::PushFont()/PopFont() to select them.
    // - AddFontFromFileTTF() will return the ImFont* so you can store it if you need to select the font among multiple.
    // - If the file cannot be loaded, the function will return NULL. Please handle those errors in your application (e.g. use an assertion, or display an error and quit).
    // - The fonts will be rasterized at a given size (w/ oversampling) and stored into a texture when calling ImFontAtlas::Build()/GetTexDataAsXXXX(), which ImGui_ImplXXXX_NewFrame below will call.
    // - Read 'docs/FONTS.md' for more instructions and details.
    // - Remember that in C/C++ if you want to include a backslash \ in a string literal you need to write a double backslash \\ !
    //io.Fonts->AddFontDefault();
    //io.Fonts->AddFontFromFileTTF("../../misc/fonts/Roboto-Medium.ttf", 16.0f);
    //io.Fonts->AddFontFromFileTTF("../../misc/fonts/Cousine-Regular.ttf", 15.0f);
    //io.Fonts->AddFontFromFileTTF("../../misc/fonts/DroidSans.ttf", 16.0f);
    //io.Fonts->AddFontFromFileTTF("../../misc/fonts/ProggyTiny.ttf", 10.0f);
    if (io.Fonts) |fonts| {
        const font = fonts.AddFontFromFileTTF("c:\\Windows\\Fonts\\msgothic.ttc", 18.0, null, fonts.GetGlyphRangesJapanese());
        std.debug.assert(font != null);
    }

    // Our state
    var show_demo_window = true;
    // bool show_another_window = false;
    var clear_color: imgui.ImVec4 = .{ .x = 0.45, .y = 0.55, .z = 0.60, .w = 1.00 };

    // Loop until the user closes the window
    while (glfw.glfwWindowShouldClose(window) == 0) {
        // Poll for and process events
        glfw.glfwPollEvents();

        // Start the Dear ImGui frame
        _ = imgui.ImGui_ImplOpenGL3_NewFrame();
        imgui.ImGui_ImplGlfw_NewFrame();
        imgui.NewFrame();

        // 1. Show the big demo window (Most of the sample code is in imgui.ShowDemoWindow()! You can browse its code to learn more about Dear ImGui!).
        if (show_demo_window) {
            imgui.ShowDemoWindow(.{ .p_open = &show_demo_window });
        }

        imgui.Render();
        var display_w: c_int = undefined;
        var display_h: c_int = undefined;
        glfw.glfwGetFramebufferSize(window, &display_w, &display_h);
        gl.viewport(0, 0, display_w, display_h);

        // Render here
        gl.clearColor(clear_color.x * clear_color.w, clear_color.y * clear_color.w, clear_color.z * clear_color.w, clear_color.w);
        gl.clear(gl.COLOR_BUFFER_BIT);
        imgui.ImGui_ImplOpenGL3_RenderDrawData(imgui.GetDrawData());

        // Swap front and back buffers
        glfw.glfwSwapBuffers(window);
    }
}
