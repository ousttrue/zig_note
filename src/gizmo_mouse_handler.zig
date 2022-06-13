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

    pub fn begin(self: *Self, mouse_input: screen.MouseInput) void {
        _ = mouse_input;

        const hit = self.gizmo.hit;
        if (hit.shape) |shape| {
            if (self.selected) |selected| {
                if (shape.drag_factory) |factory| {
                    std.log.debug("begin", .{});
                    self.context = factory.*(hit.cursor_pos, shape, selected, self.camera);
                    return;
                }
            }
        }

        self.select(self.gizmo.hit.shape);
    }

    pub fn drag(self: *Self, mouse_input: screen.MouseInput, dx: i32, dy: i32) void {
        _ = mouse_input;
        _ = dx;
        _ = dy;

        if (self.context) |*context| {
            std.log.debug("drag", .{});
            const m = context.drag(mouse_input.x, mouse_input.y);
            self.gizmo.updateContext(context, m);
        }
    }

    pub fn end(self: *Self, _: screen.MouseInput) void {
        if (self.context) |*context| {
            std.log.debug("end", .{});
            context.deinit();
            self.context = null;
        }
    }

    pub fn select(self: *Self, shape: ?*zigla.Shape) void {
        if (shape == self.selected) {
            return;
        }
        std.log.debug("select", .{});
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
