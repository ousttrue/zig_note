const std = @import("std");
const glfw = @import("glfw");
const gl = @import("gl");

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

    // Make the window's context current
    glfw.glfwMakeContextCurrent(window);

    // Load the OpenGL function pointers
    try gl.load(window, getProc);

    // Print information about the selected OpenGL context:
    std.log.info("OpenGL Version:  {s}", .{std.mem.span(gl.getString(gl.VERSION))});
    std.log.info("OpenGL Vendor:   {s}", .{std.mem.span(gl.getString(gl.VENDOR))});
    std.log.info("OpenGL Renderer: {s}", .{std.mem.span(gl.getString(gl.RENDERER))});

    // Loop until the user closes the window
    while (glfw.glfwWindowShouldClose(window) == 0) {
        // Render here
        gl.clearColor(1, 0, 1, 1);
        gl.clear(gl.COLOR_BUFFER_BIT);

        // Swap front and back buffers
        glfw.glfwSwapBuffers(window);

        // Poll for and process events
        glfw.glfwPollEvents();
    }
}
