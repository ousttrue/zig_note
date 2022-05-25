const std = @import("std");
const glfw = @import("glfw");

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

    // Loop until the user closes the window
    while (glfw.glfwWindowShouldClose(window) == 0) {
        // Render here
        // glClear(GL_COLOR_BUFFER_BIT);

        // Swap front and back buffers
        glfw.glfwSwapBuffers(window);

        // Poll for and process events
        glfw.glfwPollEvents();
    }
}
