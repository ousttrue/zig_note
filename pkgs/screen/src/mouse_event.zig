const std = @import("std");
const MouseInput = @import("./mouse_input.zig").MouseInput;

const BeginEndCallback = fn (mouse_input: MouseInput) void;
const DragCallback = fn (mouse_input: MouseInput, dx: i32, dy: i32) void;
const WheelCallback = fn (wheel: i32) void;

pub const MouseButtonEvent = struct {
    const Self = @This();

    active: ?MouseInput = null,
    pressed: std.ArrayList(BeginEndCallback),
    drag: std.ArrayList(DragCallback),
    released: std.ArrayList(BeginEndCallback),

    pub fn init(allocator: std.mem.Allocator) MouseButtonEvent {
        return .{
            .pressed = std.ArrayList(BeginEndCallback).init(allocator),
            .drag = std.ArrayList(DragCallback).init(allocator),
            .released = std.ArrayList(BeginEndCallback).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.pressed.deinit();
        self.drag.deinit();
        self.released.deinit();
    }

    pub fn process(self: *Self, current: MouseInput, current_down: bool, last_down: bool, dx: i32, dy: i32) void {
        if (current.is_hover) {
            if (current_down and !last_down) {
                self.active = current;
                for (self.pressed.items) |callback| {
                    callback(current);
                }
            }
        }

        if (current.is_active and current_down) {
            for (self.drag.items) |callback| {
                callback(current, dx, dy);
            }
        }

        if (self.active != null and !current_down) {
            for (self.released.items) |callback| {
                callback(current);
            }
            self.active = null;
        }
    }
};

pub const MouseEvent = struct {
    const Self = @This();

    last_input: ?MouseInput = null,
    left_button: MouseButtonEvent,
    right_button: MouseButtonEvent,
    middle_button: MouseButtonEvent,
    wheel: std.ArrayList(WheelCallback),

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .left_button = MouseButtonEvent.init(allocator),
            .middle_button = MouseButtonEvent.init(allocator),
            .right_button = MouseButtonEvent.init(allocator),
            .wheel = std.ArrayList(WheelCallback).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.left_button.deinit();
        self.right_button.deinit();
        self.wheel.deinit();
    }

    pub fn process(self: *Self, current: MouseInput) void {
        const dx = if (self.last_input) |last_input| current.x - last_input.x else 0;
        const dy = if (self.last_input) |last_input| current.y - last_input.y else 0;
        self.left_button.process(current, current.left_down, if (self.last_input) |last_input| last_input.left_down else false, dx, dy);
        self.middle_button.process(current, current.right_down, if (self.last_input) |last_input| last_input.middle_down else false, dx, dy);
        self.right_button.process(current, current.middle_down, if (self.last_input) |last_input| last_input.right_down else false, dx, dy);
        if (current.is_active or current.is_hover) {
            if (current.wheel != 0) {
                for (self.wheel.items) |callback| {
                    callback(current.wheel);
                }
            }
        }
        self.last_input = current;
    }
};

// def bind_left_drag(self, drag_handler: DragInterface):
//     self.left_pressed.append(drag_handler.begin)
//     self.left_drag.append(drag_handler.drag)
//     self.left_released.append(drag_handler.end)

// def bind_right_drag(self, drag_handler: DragInterface):
//     self.right_pressed.append(drag_handler.begin)
//     self.right_drag.append(drag_handler.drag)
//     self.right_released.append(drag_handler.end)

// def bind_middle_drag(self, drag_handler: DragInterface):
//     self.middle_pressed.append(drag_handler.begin)
//     self.middle_drag.append(drag_handler.drag)
//     self.middle_released.append(drag_handler.end)

// def debug_draw(self):
//     mouse_input = self.last_input
//     if not mouse_input:
//         return
//     if not self.nvg:
//         from pydear.utils.nanovg_renderer import NanoVgRenderer
//         self.nvg = NanoVgRenderer()

//     def draw_line(vg, sx, sy, ex, ey, r, g, b):
//         nanovg.nvgSave(vg)
//         nanovg.nvgStrokeWidth(vg, 1.0)
//         nanovg.nvgStrokeColor(vg, nanovg.nvgRGBA(r, g, b, 255))
//         nanovg.nvgFillColor(vg, nanovg.nvgRGBA(r, g, b, 255))

//         nanovg.nvgBeginPath(vg)
//         nanovg.nvgMoveTo(vg, sx, sy)
//         nanovg.nvgLineTo(vg, ex, ey)
//         nanovg.nvgStroke(vg)

//         nanovg.nvgBeginPath(vg)
//         nanovg.nvgCircle(vg, sx, sy, 4)
//         nanovg.nvgFill(vg)

//         nanovg.nvgBeginPath(vg)
//         nanovg.nvgCircle(vg, ex, ey, 4)
//         nanovg.nvgFill(vg)

//         nanovg.nvgRestore(vg)

//     with self.nvg.render(mouse_input.width, mouse_input.height) as vg:
//         from pydear import nanovg
//         match self.left_active:
//             case (x, y):
//                 draw_line(vg, x, y, mouse_input.x, mouse_input.y, 255, 0, 0)
//         match self.middle_active:
//             case (x, y):
//                 draw_line(vg, x, y, mouse_input.x, mouse_input.y, 0, 255, 0)
//         match self.right_active:
//             case (x, y):
//                 draw_line(vg, x, y, mouse_input.x, mouse_input.y, 0, 0, 255)
