const std = @import("std");
const gl = @import("pkgs/zig-opengl/exports/gl_4v0.zig");
const imgui = @import("pkgs/imgui/src/main.zig");
const dockspace = @import("src/dockspace.zig");

// pub const ImmutableCopy = struct {
//     const Self = @This();

//     allocator: std.mem.Allocator,
//     buffer: ?[*:0]const u8,

//     pub fn init(allocator: std.mem.Allocator, src: []const u8) !Self {
//         var buffer = try allocator.alloc(u8, src.len + 1);
//         for (src) |c, i| {
//             buffer[i] = c;
//         }
//         buffer[src.len] = 0;
//         var str = ImmutableCopy{
//             .allocator = allocator,
//             .buffer = @ptrCast([*:0]u8, buffer),
//         };
//         return str;
//     }

//     pub fn deinit(self: *Self) void {
//         self.allocator.free(self.buffer);
//     }
// };


fn show_demo(p_open: ?*bool, _: ?*anyopaque) void {
    imgui.ShowDemoWindow(.{ .p_open = p_open });
}

const Hello = struct {
    const Self = @This();

    const ptr_info = @typeInfo(@This());
    show_demo_window: bool = true,
    show_another_window: bool = false,
    clear_color: imgui.ImVec4 = .{ .x = 0.45, .y = 0.55, .z = 0.60, .w = 1.00 },
    f: f32 = 0.0,
    counter: i32 = 0,

    fn show(self: *Self, p_open: *bool) void {
        // 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.
        if (imgui.Begin("Hello, world!", .{ .p_open = p_open })) { // Create a window called "Hello, world!" and append into it.
            imgui.Text("This is some useful text."); // Display some text (you can use a format strings too)

            _ = imgui.Checkbox("Demo Window", &self.show_demo_window); // Edit bools storing our window open/close state
            _ = imgui.Checkbox("Another Window", &self.show_another_window);

            _ = imgui.SliderFloat("float", &self.f, 0.0, 1.0, .{}); // Edit 1 float using a slider from 0.0f to 1.0f
            _ = imgui.ColorEdit3("clear color", &self.clear_color.x, .{}); // Edit 3 floats representing a color

            if (imgui.Button("Button", .{})) // Buttons return true when clicked (most widgets return true when edited/activated)
                self.counter += 1;
            imgui.SameLine(.{});
            // imgui.Text("counter = %d", counter);
            // imgui.Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0 / imgui.GetIO().Framerate, imgui.GetIO().Framerate);
        }
        imgui.End();
    }
};
fn show_hello(_p_open: ?*bool, data: ?*anyopaque) void {
    if (_p_open) |p_open| {
        if (!p_open.*) {
            return;
        }
        var p = @ptrCast(?*Hello, @alignCast(4, data));
        if (p) |ptr| {
            ptr.show(p_open);
        }
    }
}

// const Count = struct {
//     const Self = @This();

//     fn show(_: *Self) void {
//         // 3. Show another simple window.
//         {
//             _ = imgui.Begin("Another Window", .{}); // Pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
//             // imgui.Text("Hello from another window!");
//             // if (imgui.Button("Close Me", .{}))
//             //     self.show_another_window = false;
//             imgui.End();
//         }
//     }
// };
// fn show_count(_p_open: ?*bool, _: ?*anyopaque) void {
//     if (_p_open) |p_open| {
//         if (!p_open.*) {
//             return;
//         }
//     }
//     // var p = @ptrCast(?*Count, @alignCast(4, data));
//     // if (p) |ptr| {
//     //     ptr.show(_p_open);
//     // }
// }


pub const Renderer = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    is_initialized: bool,
    hello: Hello,
    docks: std.ArrayList(dockspace.Dock),

    pub fn init(allocator: std.mem.Allocator) !*Self {
        var renderer = try allocator.create(Renderer);
        renderer.allocator = allocator;
        renderer.is_initialized = false;
        renderer.hello = .{};
        renderer.docks = std.ArrayList(dockspace.Dock).init(allocator);

        try renderer.docks.append(.{
            .name = "demo",
            .drawable = &show_demo,
        });

        try renderer.docks.append(.{
            .name = "hello",
            .drawable = &show_hello,
            .data = &renderer.hello,
        });

        // try renderer.docks.append(.{
        //     .name = try ImmutableCopy.init(allocator, "count"),
        //     .drawable = &show_count,
        //     .data = &renderer.count,
        // });

        return renderer;
    }

    pub fn deinit(self: *Self) void {
        self.docks.deinit();
    }

    fn initialize(self: *Self) void {
        if (self.is_initialized) {
            return;
        }
        self.is_initialized = true;

        const io = imgui.GetIO();

        // Load Fonts
        // - If no fonts are loaded, dear imgui will use the default font. You can also load multiple fonts and use imgui.PushFont()/PopFont() to select them.
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
    }

    pub fn render(self: *Renderer, width: i32, height: i32) void {
        self.initialize();

        // Start the Dear ImGui frame
        _ = imgui.ImGui_ImplOpenGL3_NewFrame();
        imgui.ImGui_ImplGlfw_NewFrame();
        imgui.NewFrame();

        _ = dockspace.DockSpace("dockspace", 0);
        for (self.docks.items) |*dock| {
            dock.*.draw();
        }

        imgui.Render();
        gl.viewport(0, 0, width, height);

        // Render here
        gl.clearColor(self.hello.clear_color.x * self.hello.clear_color.w, self.hello.clear_color.y * self.hello.clear_color.w, self.hello.clear_color.z * self.hello.clear_color.w, self.hello.clear_color.w);
        gl.clear(gl.COLOR_BUFFER_BIT);
        imgui.ImGui_ImplOpenGL3_RenderDrawData(imgui.GetDrawData());
    }
};
