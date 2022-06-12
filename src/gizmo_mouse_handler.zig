const std = @import("std");
const zigla = @import("zigla");
const screen = @import("screen");
const GizmoVertexBuffer = @import("./gizmo_vertexbuffer.zig").GizmoVertexBuffer;

pub const GizmoDragHandler = struct {
    const Self = @This();

    gizmo: *GizmoVertexBuffer,
    selected: ?*zigla.Shape = null,

    pub fn init(gizmo: *GizmoVertexBuffer) Self {
        return .{
            .gizmo = gizmo,
        };
    }

    pub fn begin(self: *Self, mouse_input: screen.MouseInput) void {
        _ = mouse_input;
        self.select(self.gizmo.hit.shape);
    }

    pub fn drag(self: *Self, mouse_input: screen.MouseInput, dx: i32, dy: i32) void {
        _ = self;
        _ = mouse_input;
        _ = dx;
        _ = dy;
    }

    pub fn end(self: *Self, mouse_input: screen.MouseInput) void {
        _ = self;
        _ = mouse_input;
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
        }
    }
};
