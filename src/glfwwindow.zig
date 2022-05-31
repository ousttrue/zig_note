const std = @import("std");
const glfw = @import("glfw");
const Store = @import("./store.zig").Store;

fn glfw_error_callback(code: c_int, description: ?[*:0]const u8) callconv(.C) void {
    std.debug.print("Glfw Error {}: {s}", .{ code, description });
}

const STORE_KEY = "glfw";

pub const Size = struct{width: c_int, height: c_int};

pub const Ini = struct
{
    width: i32 = 1920,
    height: i32 = 1080,
    full: bool = false,
};

pub const GlfwWindow = struct
{
    const Self = @This();

    allocator: std.mem.Allocator,
    store: *Store,
    handle: *glfw.GLFWwindow,

    pub fn init(allocator: std.mem.Allocator, store: *Store, title: [*:0]const u8) Self
    {
        // Initialize the library
        _ = glfw.glfwSetErrorCallback(&glfw_error_callback);

        if (glfw.glfwInit() == 0){
            @panic("glfwInit");
        }

        var ini = Ini{};
        if(store.get(STORE_KEY))|buffer|
        {
            var stream = std.json.TokenStream.init(buffer);
            if(std.json.parse(Ini, &stream, .{}))|loaded|
            {
                ini = loaded;
            }
            else|_|{}
        }

        // 1920, 1080, "zig"        
        // Create a windowed mode window and its OpenGL context
        const window = glfw.glfwCreateWindow(ini.width, ini.height, title, null, null) orelse @panic("glfwCreateWindow");

        // Make the window's context current
        glfw.glfwMakeContextCurrent(window);
        glfw.glfwSwapInterval(1); // Enable vsync

        return .{
            .allocator = allocator,
            .store = store,
            .handle = window,
        };
    }

    pub fn deinit(self: *const Self) !void
    { 
        var ini: Ini = undefined;
        glfw.glfwGetFramebufferSize(self.handle, &ini.width, &ini.height);

        var buffer = std.ArrayList(u8).init(self.allocator);
        try std.json.stringify(ini, .{}, buffer.writer());

        try self.store.push(STORE_KEY, buffer.items);
        glfw.glfwDestroyWindow(self.handle);
        glfw.glfwTerminate();
    }

    pub fn nextFrame(self: *const Self) ?Size
    {
        if(glfw.glfwWindowShouldClose(self.handle) != 0) {
            return null;
        }

        // Swap front and back buffers
        glfw.glfwSwapBuffers(self.handle);

        // Poll for and process events
        glfw.glfwPollEvents();

        var size: Size = undefined;
        glfw.glfwGetFramebufferSize(self.handle, &size.width, &size.height);
        return size;
    }
};
