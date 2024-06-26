const std = @import("std");
const imgui = @import("imgui");
const nanovg = @import("nanovg");
const glo = @import("glo");
const screen = @import("screen");
const scene = @import("scene");
const Scene = scene.Scene;
const NanoVgRenderer = @import("./nanovg_renderer.zig").NanoVgRenderer;
const gizmo_vertexbuffer = @import("./gizmo_vertexbuffer.zig");
const gizmo_mouse_handler = @import("./gizmo_mouse_handler.zig");
const zigla = @import("zigla");

const FLT_MAX: f32 = 3.402823466e+38;

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

pub const MouseHandler = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    camera: *zigla.Camera,
    mouse_event: *screen.MouseEvent,
    left_button_handler: gizmo_mouse_handler.GizmoDragHandler,
    right_button_handler: screen.ArcBall,
    middle_button_handler: screen.ScreenShift,
    nvg: NanoVgRenderer,

    pub fn new(allocator: std.mem.Allocator, camera: *zigla.Camera, gizmo: *gizmo_vertexbuffer.GizmoVertexBuffer) *Self {
        var mouse_event = screen.MouseEvent.new(allocator);
        var self = allocator.create(Self) catch @panic("create");

        self.allocator = allocator;
        self.camera = camera;
        self.mouse_event = mouse_event;
        self.left_button_handler = gizmo_mouse_handler.GizmoDragHandler.init(gizmo, camera);
        self.right_button_handler = screen.ArcBall.init(&self.camera.view, &self.camera.projection);
        self.middle_button_handler = screen.ScreenShift.init(&self.camera.view, &self.camera.projection);
        self.nvg = NanoVgRenderer.init(allocator, null, null);

        mouse_event.left_button.bind(.{
            .begin = screen.mouse_event.BeginEndCallback.create(&self.left_button_handler, "begin"),
            .drag = screen.mouse_event.DragCallback.create(&self.left_button_handler, "drag"),
            .end = screen.mouse_event.BeginEndCallback.create(&self.left_button_handler, "end"),
        });
        mouse_event.right_button.bind(.{
            .begin = screen.mouse_event.BeginEndCallback.create(&self.right_button_handler, "begin"),
            .drag = screen.mouse_event.DragCallback.create(&self.right_button_handler, "drag"),
            .end = screen.mouse_event.BeginEndCallback.create(&self.right_button_handler, "end"),
        });
        mouse_event.middle_button.bind(.{
            .begin = screen.mouse_event.BeginEndCallback.create(&self.middle_button_handler, "begin"),
            .drag = screen.mouse_event.DragCallback.create(&self.middle_button_handler, "drag"),
            .end = screen.mouse_event.BeginEndCallback.create(&self.middle_button_handler, "end"),
        });
        mouse_event.wheel.append(screen.mouse_event.WheelCallback.create(&self.middle_button_handler, "wheel")) catch @panic("append");

        return self;
    }

    pub fn delete(self: *Self) void {
        self.nvg.deinit();
        self.mouse_event.delete();
        self.allocator.destroy(self);
    }

    pub fn process(self: *Self, mouse_input: screen.MouseInput, debug_draw: bool) *zigla.Camera {
        self.mouse_event.process(mouse_input);
        self.camera.projection.resize(mouse_input.width, mouse_input.height);

        if (debug_draw) {
            self.debugDraw(mouse_input);
        }

        return self.camera;
    }

    pub fn debugDraw(self: *Self, mouse_input: screen.MouseInput) void {
        if (self.nvg.begin(@floatFromInt(mouse_input.width), @floatFromInt(mouse_input.height))) |vg| {
            defer self.nvg.end();
            if (self.mouse_event.left_button.active) |start| {
                draw_line(vg, @floatFromInt(start.x), @as(f32, @floatFromInt(start.y)), @as(f32, @floatFromInt(mouse_input.x)), @as(f32, @floatFromInt(mouse_input.y)), 255, 0, 0);
            }
            if (self.mouse_event.right_button.active) |start| {
                draw_line(vg, @floatFromInt(start.x), @as(f32, @floatFromInt(start.y)), @as(f32, @floatFromInt(mouse_input.x)), @as(f32, @floatFromInt(mouse_input.y)), 0, 255, 0);
            }
            if (self.mouse_event.middle_button.active) |start| {
                draw_line(vg, @floatFromInt(start.x), @as(f32, @floatFromInt(start.y)), @as(f32, @floatFromInt(mouse_input.x)), @as(f32, @floatFromInt(mouse_input.y)), 0, 0, 255);
            }
        }
    }
};

pub const FboDock = struct {
    const Self = @This();

    fbo: glo.FboManager,
    bg: imgui.ImVec4 = .{ .x = 0, .y = 0, .z = 0, .w = 0 },
    tint: imgui.ImVec4 = .{ .x = 1, .y = 1, .z = 1, .w = 1 },
    allocator: std.mem.Allocator,

    scene: *Scene,
    gizmo: *gizmo_vertexbuffer.GizmoVertexBuffer,
    clear_color: *const [4]f32,
    mouse_handler: *MouseHandler = undefined,

    pub fn init(allocator: std.mem.Allocator, camera: *zigla.Camera, clear_color: *const [4]f32) Self {
        var self = Self{
            .fbo = glo.FboManager{},
            .allocator = allocator,
            .scene = Scene.new(allocator),
            .gizmo = gizmo_vertexbuffer.GizmoVertexBuffer.new(allocator),
            .clear_color = clear_color,
        };
        self.mouse_handler = MouseHandler.new(allocator, camera, self.gizmo);

        // select gizmos
        var i: i32 = -2;
        while (i < 3) : (i += 1) {
            var j: i32 = -2;
            while (j < 3) : (j += 1) {
                const quads = zigla.quad_shape.createCube(0.5, 0.5, 0.5);
                const shape = self.gizmo.createShape(&quads, zigla.colors.white, null);
                shape.setPosition(zigla.Vec3.values(
                    @floatFromInt(i),
                    @floatFromInt(j),
                    0,
                ));
            }
        }

        // drag gizmios
        {
            _ = self.gizmo.createShape(&zigla.quad_shape.createXRing(20, 0.4, 0.6, 0.04), zigla.colors.red, &zigla.quad_shape.RingDragFactory(0).createRingDragContext);
            _ = self.gizmo.createShape(&zigla.quad_shape.createYRing(20, 0.4, 0.6, 0.04), zigla.colors.green, &zigla.quad_shape.RingDragFactory(1).createRingDragContext);
            _ = self.gizmo.createShape(&zigla.quad_shape.createZRing(20, 0.4, 0.6, 0.04), zigla.colors.blue, &zigla.quad_shape.RingDragFactory(2).createRingDragContext);
        }
        {
            _ = self.gizmo.createShape(&zigla.quad_shape.createXRoll(20, 0.6, 0.04), zigla.colors.red, &zigla.quad_shape.RollDragFactory(0).createRingDragContext);
            _ = self.gizmo.createShape(&zigla.quad_shape.createYRoll(20, 0.6, 0.04), zigla.colors.green, &zigla.quad_shape.RollDragFactory(1).createRingDragContext);
            _ = self.gizmo.createShape(&zigla.quad_shape.createZRoll(20, 0.6, 0.04), zigla.colors.blue, &zigla.quad_shape.RollDragFactory(2).createRingDragContext);
        }

        self.gizmo.hideDraggable();

        return self;
    }

    pub fn deinit(self: *Self) void {
        self.mouse_handler.delete();
        self.gizmo_mouse_handler.delete();
        self.gizmo.delete();
        self.scene.delete();
    }

    pub fn showFbo(self: *Self, x: f32, y: f32, size: imgui.ImVec2) void {
        // std.debug.assert(size != imgui.ImVec2{.x=0, .y=0});
        if (self.fbo.clear(@as(c_int, @intFromFloat(size.x)), @as(c_int, @intFromFloat(size.y)), self.clear_color)) |texture| {
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

            // disable mouse
            // ImVec2(-FLT_MAX,-FLT_MAX)
            if (io.MousePos.x == -FLT_MAX or io.MousePos.y == -FLT_MAX) {
                // skip
            } else {
                const mouse_input = screen.MouseInput{
                    .x = @as(i32, @intFromFloat(io.MousePos.x - x)),
                    .y = @as(i32, @intFromFloat(io.MousePos.y - y)),
                    .width = @as(i32, @intFromFloat(size.x)),
                    .height = @as(i32, @intFromFloat(size.y)),
                    .left_down = io.MouseDown[0],
                    .right_down = io.MouseDown[1],
                    .middle_down = io.MouseDown[2],
                    .is_active = imgui.IsItemActive(),
                    .is_hover = imgui.IsItemHovered(.{}),
                    .wheel = @as(i32, @intFromFloat(io.MouseWheel)),
                };
                // std.debug.print("{}\n", .{mouse_input});
                const camera = self.mouse_handler.process(mouse_input, true);

                self.gizmo.render(camera, mouse_input.x, mouse_input.y);
                self.scene.render(camera);
            }
        }
    }

    pub fn show(self: *Self, p_open: *bool) void {
        if (!p_open.*) {
            return;
        }

        imgui.PushStyleVar_2(@intFromEnum(imgui.ImGuiStyleVar._WindowPadding), .{ .x = 0, .y = 0 });
        if (imgui.Begin("render target", .{ .p_open = p_open, .flags = (@intFromEnum(imgui.ImGuiWindowFlags._NoScrollbar) | @intFromEnum(imgui.ImGuiWindowFlags._NoScrollWithMouse)) })) {
            var pos = imgui.GetWindowPos();
            // _ = imgui.InputFloat3("shift", &self.scene.camera.view.shift[0], .{});
            // _ = imgui.InputFloat4("rotation", &self.scene.camera.view.rotation.x, .{});
            // pos.y = 40;
            pos.y += imgui.GetFrameHeight();
            const size = imgui.GetContentRegionAvail();
            self.showFbo(pos.x, pos.y, size);
        }
        imgui.End();
        imgui.PopStyleVar(.{});
    }
};

const init_color = [_]f32{ 0.2, 0.2, 0.2, 1 };

pub const CameraDock = struct {
    const Self = @This();

    camera: zigla.Camera = .{},
    clear_color: [4]f32 = init_color,
    mult_color: [4]f32 = init_color,

    pub fn show(self: *Self, p_open: *bool) void {
        if (!p_open.*) {
            return;
        }

        if (imgui.Begin("camera", .{ .p_open = p_open })) {
            if (imgui.ColorPicker4("clear_color", &self.clear_color[0], .{})) {
                self.mult_color[0] = self.clear_color[0] * self.clear_color[3];
                self.mult_color[1] = self.clear_color[1] * self.clear_color[3];
                self.mult_color[2] = self.clear_color[2] * self.clear_color[3];
                self.mult_color[3] = self.clear_color[3];
            }

            imgui.SetNextItemOpen(true, .{ .cond = @intFromEnum(imgui.ImGuiCond._FirstUseEver) });
            if (imgui.CollapsingHeader("projection", .{})) {
                _ = imgui.InputInt("width", @as(*i32, @ptrCast(&self.camera.projection.width)), .{});
                _ = imgui.InputInt("height", @as(*i32, @ptrCast(&self.camera.projection.height)), .{});
                _ = imgui.InputFloat("fovy", &self.camera.projection.fovy, .{});
                _ = imgui.InputFloat("near", &self.camera.projection.near, .{});
                _ = imgui.InputFloat("far", &self.camera.projection.far, .{});
            }

            imgui.SetNextItemOpen(true, .{ .cond = @intFromEnum(imgui.ImGuiCond._FirstUseEver) });
            if (imgui.CollapsingHeader("view", .{})) {
                _ = imgui.InputFloat3("shift", &self.camera.view.shift.x, .{});
                // _ = imgui.InputFloat4("rotation", &self.camera.view.rotation.x, .{});
            }
        }
        imgui.End();
    }
};
