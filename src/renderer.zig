const std = @import("std");
const gl = @import("gl");
const imgui = @import("imgui");
const dockspace = @import("dockspace.zig");
const docks = @import("./docks.zig");
const scene_dock = @import("./scene_dock.zig");

pub const Renderer = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    is_initialized: bool,

    metrics: docks.MetricsDock,
    camera: scene_dock.CameraDock,
    fbo: scene_dock.FboDock,
    node_editor: docks.NodeEditorDock,

    docks: std.ArrayList(dockspace.Dock),

    fn init(self: *Self, allocator: std.mem.Allocator) !void {
        self.allocator = allocator;
        self.is_initialized = false;
        self.metrics = .{};
        self.camera = .{};
        self.camera.camera.projection.far = 1000;
        self.node_editor = .{};
        self.fbo = scene_dock.FboDock.init(allocator, &self.camera.camera, &self.camera.mult_color);
        self.docks = std.ArrayList(dockspace.Dock).init(allocator);
        try self.docks.append(dockspace.Dock.create(&self.metrics, "metrics"));
        try self.docks.append(dockspace.Dock.create(&self.fbo, "fbo"));
        try self.docks.append(dockspace.Dock.create(&self.camera, "camera"));
        try self.docks.append(dockspace.Dock.create(&self.node_editor, "node editor"));
    }

    pub fn new(allocator: std.mem.Allocator) !*Self {
        var self = try allocator.create(Renderer);
        try self.init(allocator);
        return self;
    }

    pub fn delete(self: *Self) void {
        self.docks.deinit();
        self.allocator.destroy(self);
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

        // menu
        if (imgui.BeginMainMenuBar()) {
            if (imgui.BeginMenu("File", .{ .enabled = true })) {
                imgui.EndMenu();
            }

            if (imgui.BeginMenu("Views", .{ .enabled = true })) {
                for (self.docks.items) |*dock| {
                    _ = imgui.MenuItem_2(dock.name, "", &dock.is_open, .{});
                }
                imgui.EndMenu();
            }

            imgui.EndMainMenuBar();
        }

        // views
        for (self.docks.items) |*dock| {
            dock.*.show();
        }

        imgui.Render();
        gl.viewport(0, 0, width, height);

        // Render here
        // gl.clearColor(self.hello.clear_color.x * self.hello.clear_color.w, self.hello.clear_color.y * self.hello.clear_color.w, self.hello.clear_color.z * self.hello.clear_color.w, self.hello.clear_color.w);
        gl.clear(gl.COLOR_BUFFER_BIT);
        imgui.ImGui_ImplOpenGL3_RenderDrawData(imgui.GetDrawData());
    }
};
