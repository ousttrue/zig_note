const std = @import("std");
const gl = @import("pkgs/zig-opengl/exports/gl_4v0.zig");
const imgui = @import("pkgs/imgui/src/main.zig");

pub const ImmutableCopy = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    buffer: ?[*:0]const u8,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) !Self {
        var buffer = try allocator.alloc(u8, src.len + 1);
        for (src) |c, i| {
            buffer[i] = c;
        }
        buffer[src.len] = 0;
        var str = ImmutableCopy{
            .allocator = allocator,
            .buffer = @ptrCast([*:0]u8, buffer),
        };
        return str;
    }
};

const DockDrawCallback = fn (p_open: *bool, data: ?*anyopaque) void;

pub const Dock = struct {
    const Self = @This();

    name: ImmutableCopy,
    drawable: *const DockDrawCallback,
    data: ?*anyopaque = null,
    p_open: bool = true,

    pub fn draw(self: *Self) void {
        self.drawable.*(&self.p_open, self.data);
    }
};

fn show_demo(p_open: *bool, _: ?*anyopaque) void {
    imgui.ShowDemoWindow(.{ .p_open = p_open });
}

fn dockspace(name: [*:0]const u8, toolbar_size: f32) i32 {
    var io = imgui.GetIO();
    io.ConfigFlags |= @enumToInt(imgui.ImGuiConfigFlags._DockingEnable);

    const flags = (@enumToInt(imgui.ImGuiWindowFlags._MenuBar) |
        @enumToInt(imgui.ImGuiWindowFlags._NoDocking) |
        @enumToInt(imgui.ImGuiWindowFlags._NoBackground) |
        @enumToInt(imgui.ImGuiWindowFlags._NoTitleBar) |
        @enumToInt(imgui.ImGuiWindowFlags._NoCollapse) |
        @enumToInt(imgui.ImGuiWindowFlags._NoResize) |
        @enumToInt(imgui.ImGuiWindowFlags._NoMove) |
        @enumToInt(imgui.ImGuiWindowFlags._NoBringToFrontOnFocus) |
        @enumToInt(imgui.ImGuiWindowFlags._NoNavFocus));

    const viewport = imgui.GetMainViewport() orelse @panic("GetMainViewport");
    var x = viewport.Pos.x;
    var y = viewport.Pos.y;
    var w = viewport.Size.x;
    var h = viewport.Size.y;
    y += toolbar_size;
    h -= toolbar_size;

    imgui.SetNextWindowPos(.{ .x = x, .y = y }, .{});
    imgui.SetNextWindowSize(.{ .x = w, .y = h }, .{});
    // imgui.set_next_window_viewport(viewport.id)
    imgui.PushStyleVar(@enumToInt(imgui.ImGuiStyleVar._WindowBorderSize), 0.0);
    imgui.PushStyleVar(@enumToInt(imgui.ImGuiStyleVar._WindowRounding), 0.0);

    // When using ImGuiDockNodeFlags_PassthruCentralNode, DockSpace() will render our background and handle the pass-thru hole, so we ask Begin() to not render a background.
    // local window_flags = self.window_flags
    // if bit.band(self.dockspace_flags, ) ~= 0 then
    //     window_flags = bit.bor(window_flags, const.ImGuiWindowFlags_.NoBackground)
    // end

    // Important: note that we proceed even if Begin() returns false (aka window is collapsed).
    // This is because we want to keep our DockSpace() active. If a DockSpace() is inactive,
    // all active windows docked into it will lose their parent and become undocked.
    // We cannot preserve the docking relationship between an active window and an inactive docking, otherwise
    // any change of dockspace/settings would lead to windows being stuck in limbo and never being visible.
    imgui.PushStyleVar_2(@enumToInt(imgui.ImGuiStyleVar._WindowPadding), .{ .x = 0, .y = 0 });
    _ = imgui.Begin(name, .{ .p_open = null, .flags = flags });
    imgui.PopStyleVar(.{});
    imgui.PopStyleVar(.{ .count = 2 });

    // TODO:
    // Save off menu bar height for later.
    // menubar_height = imgui.internal.get_current_window().menu_bar_height()
    const menubar_height = 26;

    // DockSpace
    const dockspace_id = imgui.GetID(name);
    _ = imgui.DockSpace(dockspace_id, .{ .size = .{ .x = 0, .y = 0 }, .flags = @enumToInt(imgui.ImGuiDockNodeFlags._PassthruCentralNode) });

    imgui.End();

    return menubar_height;
}

pub const Renderer = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    is_initialized: bool = false,
    show_demo_window: bool = true,
    show_another_window: bool = false,
    clear_color: imgui.ImVec4 = .{ .x = 0.45, .y = 0.55, .z = 0.60, .w = 1.00 },
    f: f32 = 0.0,
    counter: i32 = 0,

    docks: std.ArrayList(Dock),

    pub fn init(allocator: std.mem.Allocator) !Self {
        var renderer = Renderer{
            .allocator = allocator,
            .docks = std.ArrayList(Dock).init(allocator),
        };

        // 1. Show the big demo window (Most of the sample code is in imgui.ShowDemoWindow()! You can browse its code to learn more about Dear ImGui!).
        // if (self.show_demo_window) {
        //     imgui.ShowDemoWindow(.{ .p_open = &self.show_demo_window });
        // }

        try renderer.docks.append(.{
            .name = try ImmutableCopy.init(allocator, "demo"),
            .drawable = &show_demo,
        });

        return renderer;
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

        _ = dockspace("dockspace", 0);
        for (self.docks.items) |*dock| {
            dock.*.draw();
        }

        // // 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.
        // {
        //     _ = imgui.Begin("Hello, world!", .{}); // Create a window called "Hello, world!" and append into it.

        //     imgui.Text("This is some useful text."); // Display some text (you can use a format strings too)
        //     _ = imgui.Checkbox("Demo Window", &self.show_demo_window); // Edit bools storing our window open/close state
        //     _ = imgui.Checkbox("Another Window", &self.show_another_window);

        //     _ = imgui.SliderFloat("float", &self.f, 0.0, 1.0, .{}); // Edit 1 float using a slider from 0.0f to 1.0f
        //     _ = imgui.ColorEdit3("clear color", &self.clear_color.x, .{}); // Edit 3 floats representing a color

        //     if (imgui.Button("Button", .{})) // Buttons return true when clicked (most widgets return true when edited/activated)
        //         self.counter += 1;
        //     imgui.SameLine(.{});
        //     // imgui.Text("counter = %d", counter);

        //     // imgui.Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0 / imgui.GetIO().Framerate, imgui.GetIO().Framerate);
        //     imgui.End();
        // }

        // // 3. Show another simple window.
        // if (self.show_another_window) {
        //     _ = imgui.Begin("Another Window", .{ .p_open = &self.show_another_window }); // Pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
        //     imgui.Text("Hello from another window!");
        //     if (imgui.Button("Close Me", .{}))
        //         self.show_another_window = false;
        //     imgui.End();
        // }

        imgui.Render();
        gl.viewport(0, 0, width, height);

        // Render here
        gl.clearColor(self.clear_color.x * self.clear_color.w, self.clear_color.y * self.clear_color.w, self.clear_color.z * self.clear_color.w, self.clear_color.w);
        gl.clear(gl.COLOR_BUFFER_BIT);
        imgui.ImGui_ImplOpenGL3_RenderDrawData(imgui.GetDrawData());
    }
};
