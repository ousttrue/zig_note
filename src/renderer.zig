const std = @import("std");
const gl = @import("gl");
const imgui = @import("imgui");
const dockspace = @import("dockspace.zig");
const Scene = @import("./scene.zig").Scene;
const fbo = @import("./fbo.zig");

const DemoDock = struct {
    const Self = @This();
    name: [*:0]const u8 = "demo",
    is_open: bool = true,

    pub fn show(self: *Self) void {
        if (!self.is_open) {
            return;
        }
        imgui.ShowDemoWindow(.{ .p_open = &self.is_open });
    }
};

const HelloDock = struct {
    const Self = @This();
    name: [*:0]const u8 = "hello",
    is_open: bool = true,
    show_demo_window: *bool,
    show_another_window: *bool,
    clear_color: imgui.ImVec4 = .{ .x = 0.45, .y = 0.55, .z = 0.60, .w = 1.00 },
    f: f32 = 0.0,
    counter: i32 = 0,

    pub fn show(self: *Self) void {
        if (!self.is_open) {
            return;
        }

        // 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.
        if (imgui.Begin("Hello, world!", .{ .p_open = &self.is_open })) { // Create a window called "Hello, world!" and append into it.
            imgui.Text("This is some useful text.", .{}); // Display some text (you can use a format strings too)

            _ = imgui.Checkbox("Demo Window", self.show_demo_window); // Edit bools storing our window open/close state
            _ = imgui.Checkbox("Another Window", self.show_another_window);

            _ = imgui.SliderFloat("float", &self.f, 0.0, 1.0, .{}); // Edit 1 float using a slider from 0.0f to 1.0f
            _ = imgui.ColorEdit3("clear color", &self.clear_color.x, .{}); // Edit 3 floats representing a color

            if (imgui.Button("Button", .{})) // Buttons return true when clicked (most widgets return true when edited/activated)
                self.counter += 1;
            imgui.SameLine(.{});
            imgui.Text("counter = %d", .{self.counter});
            imgui.Text("Application average %.3f ms/frame (%.1f FPS)", .{ 1000.0 / imgui.GetIO().Framerate, imgui.GetIO().Framerate });
        }
        imgui.End();
    }
};

const AnotherDock = struct {
    const Self = @This();
    name: [*:0]const u8 = "another",
    is_open: bool = false,

    pub fn show(self: *Self) void {
        if (!self.is_open) {
            return;
        }
        // 3. Show another simple window.
        if (imgui.Begin("Another Window", .{ .p_open = &self.is_open })) { // Pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
            imgui.Text("Hello from another window!", .{});
            if (imgui.Button("Close Me", .{})) {
                self.is_open = false;
            }
        }
        imgui.End();
    }
};

const FboDock = struct {
    const Self = @This();
    name: [*:0]const u8 = "fbo",
    is_open: bool = false,

    fbo: fbo.FboManager,
    bg: imgui.ImVec4 = .{ .x = 0, .y = 0, .z = 0, .w = 0 },
    tint: imgui.ImVec4 = .{ .x = 1, .y = 1, .z = 1, .w = 1 },
    clearColor: [4]f32 = .{ 1, 1, 1, 1 },

    pub fn showFbo(self: *Self, x: f32, y: f32, size: imgui.ImVec2) void {
        _ = self;
        _ = x;
        _ = y;
        _ = size;
        // std.debug.assert(size != imgui.ImVec2{.x=0, .y=0});
        if (self.fbo.clear(@floatToInt(c_int, size.x), @floatToInt(c_int, size.y), self.clearColor)) |texture| {
            defer self.fbo.unbind();
            _ = texture;
            _ = imgui.ImageButton(texture, size, .{ .uv0 = .{ .x = 0, .y = 1 }, .uv1 = .{ .x = 1, .y = 0 }, .frame_padding = 0, .bg_col = self.bg, .tint_col = self.tint });
        //     //     from pydear import imgui_internal
        //     //     imgui_internal.ButtonBehavior(ImGui.Custom_GetLastItemRect(), ImGui.Custom_GetLastItemId(), None, None,  # type: ignore
        //     //                                   ImGui.ImGuiButtonFlags_.MouseButtonMiddle | ImGui.ImGuiButtonFlags_.MouseButtonRight)

        //     //     io = ImGui.GetIO()

        //     //     mouse_input = MouseInput(
        //     //         (int(io.MousePos.x) - x), (int(io.MousePos.y) - y),
        //     //         w, h,
        //     //         io.MouseDown[0], io.MouseDown[1], io.MouseDown[2],
        //     //         ImGui.IsItemActive(), ImGui.IsItemHovered(), int(io.MouseWheel))
        //     //     self.mouse_event.process(mouse_input)

        //     //     if self.render:
        //     //         self.render(mouse_input)
        //     //     else:
        //     //         self.mouse_event.debug_draw()

        }
    }

    pub fn show(self: *Self) void {
        imgui.PushStyleVar_2(@enumToInt(imgui.ImGuiStyleVar._WindowPadding), .{ .x = 0, .y = 0 });
        if (imgui.Begin("render target", .{ .p_open = &self.is_open, .flags = (@enumToInt(imgui.ImGuiWindowFlags._NoScrollbar) | @enumToInt(imgui.ImGuiWindowFlags._NoScrollWithMouse)) })) {
            var pos = imgui.GetWindowPos();
            pos.y += imgui.GetFrameHeight();
            var size = imgui.GetContentRegionAvail();
            self.showFbo(pos.x, pos.y, size);
        }
        imgui.End();
        imgui.PopStyleVar(.{});
    }
};

pub const Renderer = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    scene: Scene,
    is_initialized: bool,

    demo: DemoDock = .{},
    another: AnotherDock = .{},
    hello: HelloDock = .{},
    fbo: FboDock = .{},

    docks: std.ArrayList(dockspace.Dock),

    pub fn init(allocator: std.mem.Allocator) !*Self {
        var renderer = try allocator.create(Renderer);
        renderer.scene = Scene.init(allocator);
        renderer.allocator = allocator;
        renderer.is_initialized = false;
        renderer.another = .{};
        renderer.demo = .{};
        renderer.hello = .{
            .show_another_window = &renderer.another.is_open,
            .show_demo_window = &renderer.demo.is_open,
        };
        renderer.fbo = FboDock{
            .fbo = fbo.FboManager{},
        };

        renderer.docks = std.ArrayList(dockspace.Dock).init(allocator);
        try renderer.docks.append(dockspace.Dock.create(&renderer.demo));
        try renderer.docks.append(dockspace.Dock.create(&renderer.hello));
        try renderer.docks.append(dockspace.Dock.create(&renderer.another));
        try renderer.docks.append(dockspace.Dock.create(&renderer.fbo));

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

        // Start the Dear imgui frame
        _ = imgui.ImGui_ImplOpenGL3_NewFrame();
        imgui.ImGui_ImplGlfw_NewFrame();
        imgui.NewFrame();

        _ = dockspace.DockSpace("dockspace", 0);
        for (self.docks.items) |*dock| {
            dock.*.show();
        }

        imgui.Render();
        gl.viewport(0, 0, width, height);

        // Render here
        gl.clearColor(self.hello.clear_color.x * self.hello.clear_color.w, self.hello.clear_color.y * self.hello.clear_color.w, self.hello.clear_color.z * self.hello.clear_color.w, self.hello.clear_color.w);
        gl.clear(gl.COLOR_BUFFER_BIT);
        imgui.ImGui_ImplOpenGL3_RenderDrawData(imgui.GetDrawData());
    }
};
