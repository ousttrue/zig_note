const std = @import("std");
const zigla = @import("zigla");
const screen = @import("screen");
const GizmoVertexBuffer = @import("./gizmo_vertexbuffer.zig").GizmoVertexBuffer;

pub const GizmoDragHandler = struct {
    const Self = @This();

    gizmo: *GizmoVertexBuffer,
    camera: *zigla.Camera,
    selected: ?*zigla.Shape = null,
    context: ?zigla.DragContext = null,

    pub fn init(gizmo: *GizmoVertexBuffer, camera: *zigla.Camera) Self {
        return .{
            .gizmo = gizmo,
            .camera = camera,
        };
    }

    pub fn begin(self: *Self, _: screen.MouseInput) void {
        const hit = self.gizmo.hit;
        if (hit.shape) |shape| {
            if (self.selected) |_| {
                if (shape.drag_factory) |factory| {
                    self.context = factory.*(hit.cursor_pos, shape.matrix.*, self.camera);
                    return;
                }
            }
        }

        self.select(self.gizmo.hit.shape);
    }

    pub fn drag(self: *Self, mouse_input: screen.MouseInput, _: i32, _: i32) void {
        if (self.context) |*context| {
            const m = context.drag(zigla.Vec2.init(@intToFloat(f32, mouse_input.x), @intToFloat(f32, mouse_input.width - mouse_input.y)));
            if (self.selected) |selected| {
                selected.matrix.* = m;
            }
            self.gizmo.updateDraggable(m);
        }
    }

    pub fn end(self: *Self, _: screen.MouseInput) void {
        if (self.context) |_| {
            self.context = null;
        }
    }

    pub fn select(self: *Self, shape: ?*zigla.Shape) void {
        if (shape == self.selected) {
            return;
        }
        // clear
        if (self.selected) |selected| {
            selected.state.removeState(zigla.quad_shape.ShapeState.SELECT);
        }
        // select
        self.selected = shape;
        if (self.selected) |selected| {
            selected.state.addState(zigla.quad_shape.ShapeState.SELECT);
            self.gizmo.updateDraggable(selected.matrix.*);
        } else {
            self.gizmo.hideDraggable();
        }
    }
};
