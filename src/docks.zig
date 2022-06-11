const std = @import("std");
const imgui = @import("imgui");
const nanovg = @import("nanovg");
const glo = @import("glo");
const screen = @import("screen");
const scene = @import("scene");
const Scene = scene.Scene;
const NanoVgRenderer = @import("./nanovg_renderer.zig").NanoVgRenderer;
const gizmo_vertexbuffer = @import("./gizmo_vertexbuffer.zig");
const zigla = @import("zigla");

pub const DemoDock = struct {
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

pub const MetricsDock = struct {
    const Self = @This();
    name: [*:0]const u8 = "metrics",
    is_open: bool = true,

    pub fn show(self: *Self) void {
        if (!self.is_open) {
            return;
        }
        imgui.ShowMetricsWindow(.{ .p_open = &self.is_open });
    }
};

pub const HelloDock = struct {
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

pub const AnotherDock = struct {
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

fn draw_line(vg: *nanovg.NVGcontext, sx: f32, sy: f32, ex: f32, ey: f32, r: u8, g: u8, b: u8) void {
    nanovg.nvgSave(vg);
    nanovg.nvgStrokeWidth(vg, 1.0);
    nanovg.nvgStrokeColor(vg, nanovg.nvgRGBA(r, g, b, 255));
    nanovg.nvgFillColor(vg, nanovg.nvgRGBA(r, g, b, 255));

    nanovg.nvgBeginPath(vg);
    nanovg.nvgMoveTo(vg, sx, sy);
    nanovg.nvgLineTo(vg, ex, ey);
    nanovg.nvgStroke(vg);

    nanovg.nvgBeginPath(vg);
    nanovg.nvgCircle(vg, sx, sy, 4);
    nanovg.nvgFill(vg);

    nanovg.nvgBeginPath(vg);
    nanovg.nvgCircle(vg, ex, ey, 4);
    nanovg.nvgFill(vg);

    nanovg.nvgRestore(vg);
}

pub const FboDock = struct {
    const Self = @This();
    name: [*:0]const u8 = "fbo",
    is_open: bool = false,

    fbo: glo.FboManager,
    bg: imgui.ImVec4 = .{ .x = 0, .y = 0, .z = 0, .w = 0 },
    tint: imgui.ImVec4 = .{ .x = 1, .y = 1, .z = 1, .w = 1 },
    clearColor: [4]f32 = .{ 0, 0, 0, 1 },
    allocator: std.mem.Allocator,
    mouse_event: *screen.MouseEvent,
    scene: *Scene,
    nvg: NanoVgRenderer,

    gizmo: gizmo_vertexbuffer.GizmoVertexBuffer,

    pub fn init(allocator: std.mem.Allocator) Self {
        var mouse_event = screen.MouseEvent.new(allocator);
        var self = Self{
            .fbo = glo.FboManager{},
            .allocator = allocator,
            .mouse_event = mouse_event,
            .scene = Scene.new(allocator, mouse_event),
            .nvg = NanoVgRenderer.init(allocator, null, null),
            .gizmo = gizmo_vertexbuffer.GizmoVertexBuffer.init(allocator),
        };

        // gizmo shapes
        // self.cubes: List[Shape] = []
        var joint: u32 = 0;
        var i: i32 = -2;
        while (i < 3) : (i += 1) {
            var j: i32 = -2;
            while (j < 3) : (j += 1) {
                var cube = zigla.quad_shape.createCube(allocator, 0.5, 0.5, 0.5);
                // cube.position(i, j, 0);
                self.gizmo.addShape(joint, cube);
                joint += 1;
                // self.cubes.append(cube)
            }
        }

        return self;
    }

    pub fn deinit(self: *Self) void {
        self.nvg.deinit();
        self.scene.delete();
        self.mouse_event.delete();
    }

    pub fn showFbo(self: *Self, x: f32, y: f32, size: imgui.ImVec2) void {
        // std.debug.assert(size != imgui.ImVec2{.x=0, .y=0});
        if (self.fbo.clear(@floatToInt(c_int, size.x), @floatToInt(c_int, size.y), self.clearColor)) |texture| {
            defer self.fbo.unbind();
            _ = imgui.ImageButton(texture, size, .{
                .uv0 = .{ .x = 0, .y = 1 },
                .uv1 = .{ .x = 1, .y = 0 },
                .frame_padding = 0,
                .bg_col = self.bg,
                .tint_col = self.tint,
            });

            // active right & middle
            imgui.Custom_ButtonBehaviorMiddleRight();

            const io = imgui.GetIO();
            const mouse_input = screen.MouseInput{
                .x = @floatToInt(i32, io.MousePos.x - x),
                .y = @floatToInt(i32, io.MousePos.y - y),
                .width = @floatToInt(u32, size.x),
                .height = @floatToInt(u32, size.y),
                .left_down = io.MouseDown[0],
                .right_down = io.MouseDown[1],
                .middle_down = io.MouseDown[2],
                .is_active = imgui.IsItemActive(),
                .is_hover = imgui.IsItemHovered(.{}),
                .wheel = @floatToInt(i32, io.MouseWheel),
            };
            // std.debug.print("{}\n", .{mouse_input});
            self.mouse_event.process(mouse_input);

            // self.scene.render(mouse_input);
            self.scene.camera.projection.resize(mouse_input.width, mouse_input.height);
            self.gizmo.render(self.scene.camera);

            self.debugDraw(mouse_input);
        }
    }

    pub fn show(self: *Self) void {
        imgui.PushStyleVar_2(@enumToInt(imgui.ImGuiStyleVar._WindowPadding), .{ .x = 0, .y = 0 });
        if (imgui.Begin("render target", .{ .p_open = &self.is_open, .flags = (@enumToInt(imgui.ImGuiWindowFlags._NoScrollbar) | @enumToInt(imgui.ImGuiWindowFlags._NoScrollWithMouse)) })) {
            var pos = imgui.GetWindowPos();
            // _ = imgui.InputFloat3("shift", &self.scene.camera.view.shift[0], .{});
            // _ = imgui.InputFloat4("rotation", &self.scene.camera.view.rotation.x, .{});
            // pos.y = 40;
            pos.y += imgui.GetFrameHeight();
            var size = imgui.GetContentRegionAvail();
            self.showFbo(pos.x, pos.y, size);
        }
        imgui.End();
        imgui.PopStyleVar(.{});
    }

    pub fn debugDraw(self: *Self, mouse_input: screen.MouseInput) void {
        if (self.nvg.begin(@intToFloat(f32, mouse_input.width), @intToFloat(f32, mouse_input.height))) |vg| {
            defer self.nvg.end();
            if (self.mouse_event.left_button.active) |start| {
                draw_line(vg, @intToFloat(f32, start.x), @intToFloat(f32, start.y), @intToFloat(f32, mouse_input.x), @intToFloat(f32, mouse_input.y), 255, 0, 0);
            }
            if (self.mouse_event.right_button.active) |start| {
                draw_line(vg, @intToFloat(f32, start.x), @intToFloat(f32, start.y), @intToFloat(f32, mouse_input.x), @intToFloat(f32, mouse_input.y), 0, 255, 0);
            }
            if (self.mouse_event.middle_button.active) |start| {
                draw_line(vg, @intToFloat(f32, start.x), @intToFloat(f32, start.y), @intToFloat(f32, mouse_input.x), @intToFloat(f32, mouse_input.y), 0, 0, 255);
            }
        }
    }
};

pub const CameraDock = struct {
    const Self = @This();
    name: [*:0]const u8 = "camera",
    is_open: bool = true,

    camera: *scene.Camera,

    pub fn init(camea: *scene.Camera) Self {
        return Self{
            .camera = camea,
        };
    }

    pub fn show(self: *Self) void {
        if (!self.is_open) {
            return;
        }

        if (imgui.Begin("camera", .{ .p_open = &self.is_open })) {
            _ = imgui.InputFloat3("shift", &self.camera.view.shift.x, .{});
        }
        imgui.End();
    }
};
