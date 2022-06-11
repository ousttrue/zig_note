const std = @import("std");
const gl = @import("gl");
const imgui = @import("imgui");
const dockspace = @import("dockspace.zig");
const docks = @import("./docks.zig");

pub const Renderer = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    is_initialized: bool,

    demo: docks.DemoDock = .{},
    metrics: docks.MetricsDock = .{},
    another: docks.AnotherDock = .{},
    hello: docks.HelloDock = .{},
    fbo: docks.FboDock = .{},
    camera: docks.CameraDock,

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
        renderer.fbo = docks.FboDock.init(allocator);
        renderer.camera = docks.CameraDock.init(&renderer.fbo.scene.camera);

        renderer.docks = std.ArrayList(dockspace.Dock).init(allocator);
        try renderer.docks.append(dockspace.Dock.create(&renderer.metrics));
        try renderer.docks.append(dockspace.Dock.create(&renderer.fbo));
        try renderer.docks.append(dockspace.Dock.create(&renderer.camera));

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

        _ = dockspace.dockspace("dockspace", 0);
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
