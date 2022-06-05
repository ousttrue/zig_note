const std = @import("std");
const gl = @import("gl");
const imgui = @import("imgui");
const dockspace = @import("dockspace.zig");
const Scene = @import("scene").Scene;
const screen = @import("screen");
const glo = @import("glo");

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

    fbo: glo.FboManager,
    bg: imgui.ImVec4 = .{ .x = 0, .y = 0, .z = 0, .w = 0 },
    tint: imgui.ImVec4 = .{ .x = 1, .y = 1, .z = 1, .w = 1 },
    clearColor: [4]f32 = .{ 0, 0, 0, 1 },
    mouse_event: screen.MouseEvent,
    scene: Scene,

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .fbo = glo.FboManager{},
            .scene = Scene.init(allocator),
            .mouse_event = screen.MouseEvent.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.scene.deinit();
        self.mouse_event.deinit();
    }

    pub fn showFbo(self: *Self, x: f32, y: f32, size: imgui.ImVec2) void {
        _ = self;
        _ = x;
        _ = y;
        _ = size;
        // std.debug.assert(size != imgui.ImVec2{.x=0, .y=0});
        if (self.fbo.clear(@floatToInt(c_int, size.x), @floatToInt(c_int, size.y), self.clearColor)) |texture| {
            defer self.fbo.unbind();
            _ = imgui.ImageButton(texture, size, .{ .uv0 = .{ .x = 0, .y = 1 }, .uv1 = .{ .x = 1, .y = 0 }, .frame_padding = 0, .bg_col = self.bg, .tint_col = self.tint });
            const io = imgui.GetIO();
            const mouse_input = screen.MouseInput{ .x = @floatToInt(i32, io.MousePos.x - x), .y = @floatToInt(i32, io.MousePos.y - y), .width = @floatToInt(i32, size.x), .height = @floatToInt(i32, size.y), .left_down = io.MouseDown[0], .right_down = io.MouseDown[1], .middle_down = io.MouseDown[2], .is_active = imgui.IsItemActive(), .is_hover = imgui.IsItemHovered(.{}), .wheel = @floatToInt(i32, io.MouseWheel) };
            self.mouse_event.process(mouse_input);

            // if (mouseInput.is_active) {
            //     imgui.GetForegroundDrawList().?.AddLine(io.MouseClickedPos[0], io.MousePos, imgui.GetColorU32(@enumToInt(imgui.ImGuiCol._Button), .{}), .{ .thickness = 4.0 }); // Draw a line between the button and the mouse cursor
            //     self.clearColor[0] = @intToFloat(f32, mouseInput.x) / @intToFloat(f32, mouseInput.width);
            //     self.clearColor[1] = @intToFloat(f32, mouseInput.y) / @intToFloat(f32, mouseInput.height);
            //     self.tint.x = 1.0;
            // } else if (mouseInput.is_hover) {
            //     self.tint.z = 1.0;
            // } else {
            //     self.tint.z = 0.5;
            // }

            self.scene.render(mouse_input);
        }
    }

    pub fn show(self: *Self) void {
        imgui.PushStyleVar_2(@enumToInt(imgui.ImGuiStyleVar._WindowPadding), .{ .x = 0, .y = 0 });
        if (imgui.Begin("render target", .{ .p_open = &self.is_open, .flags = (@enumToInt(imgui.ImGuiWindowFlags._NoScrollbar) | @enumToInt(imgui.ImGuiWindowFlags._NoScrollWithMouse)) })) {
            _ = imgui.InputFloat3("shift", &self.scene.camera.view.shift[0], .{});
            var pos = imgui.GetWindowPos();
            // pos.y += imgui.GetFrameHeight();
            pos.y = 20;
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
    is_initialized: bool,

    demo: DemoDock = .{},
    another: AnotherDock = .{},
    hello: HelloDock = .{},
    fbo: FboDock = .{},

    docks: std.ArrayList(dockspace.Dock),

    pub fn init(allocator: std.mem.Allocator) !*Self {
        var renderer = try allocator.create(Renderer);
        renderer.allocator = allocator;
        renderer.is_initialized = false;
        renderer.another = .{};
        renderer.demo = .{};
        renderer.hello = .{
            .show_another_window = &renderer.another.is_open,
            .show_demo_window = &renderer.demo.is_open,
        };
        renderer.fbo = FboDock.init(allocator);

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
            const font = fonts.AddFontFromFileTTF("c:\\Windows\\Fonts\\msgothic.ttc", 18.0, .{ .font_cfg = null, .glyph_ranges = fonts.GetGlyphRangesJapanese() });
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
