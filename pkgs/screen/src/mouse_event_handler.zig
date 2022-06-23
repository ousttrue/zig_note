const std = @import("std");
const zigla = @import("zigla");
const @"+" = zigla.@"+";
const @"*" = zigla.@"*";
const MouseInput = @import("./mouse_input.zig").MouseInput;

pub fn getArcballVector(mouse_input: MouseInput) zigla.Vec3 {
    // https://en.wikibooks.org/wiki/OpenGL_Programming/Modern_OpenGL_Tutorial_Arcball
    const x = @intToFloat(f32, mouse_input.x) / @intToFloat(f32, mouse_input.width) * 2 - 1.0; // -1 ~ +1
    const y = @intToFloat(f32, mouse_input.y) / @intToFloat(f32, mouse_input.height) * 2 - 1.0; // -1 ~ +1
    var P = zigla.Vec3.values(x, -y, 0);
    const OP_squared = P.x * P.x + P.y * P.y;
    if (OP_squared <= 1) {
        P.z = std.math.sqrt(1 - OP_squared); // Pythagoras
    } else {
        P = P.normalized(); // nearest point
    }
    return P;
}

pub const ArcBall = struct {
    const Self = @This();

    view: *zigla.camera_types.View,
    projection: *zigla.camera_types.Projection,
    rotation: zigla.Rotation,
    tmp_rotation: zigla.Rotation,
    last: ?MouseInput = null,
    va: ?zigla.Vec3 = null,

    pub fn init(view: *zigla.camera_types.View, projection: *zigla.camera_types.Projection) Self {
        return .{
            .rotation = .identity,
            .tmp_rotation = .identity,
            .view = view,
            .projection = projection,
        };
    }

    pub fn update(self: *Self) void {
        // self.view.rotation = self.tmp_rotation.mul(self.rotation).normalize();
        self.view.rotation = @"*"(self.tmp_rotation, self.rotation);
    }

    pub fn begin(self: *Self, mouse_input: MouseInput) void {
        self.rotation = self.view.rotation;
        self.last = mouse_input;
        self.va = getArcballVector(mouse_input);
    }

    pub fn drag(self: *Self, mouse_input: MouseInput, _: i32, _: i32) void {
        if (self.last) |last| {
            if (mouse_input.x != last.x or mouse_input.y != last.y) {
                const va = self.va orelse unreachable;
                const vb = getArcballVector(mouse_input);
                const dot = va.dot(vb);
                const angle = std.math.acos(std.math.min(1.0, dot)) * 2;
                const axis = va.cross(vb);
                // const angleAxis = zigla.AngleAxis.init(angle, axis);
                // std.log.debug("[{d:.2}, {d:.2}, {d:.2}], [{d:.2}, {d:.2}, {d:.2}][{d:.2}, {d:.2}, {d:.2}], {d:.2}, {d:.2}", .{ va.x, va.y, va.z, vb.x, vb.y, vb.z, axis.x, axis.y, axis.z, dot, angle });
                self.tmp_rotation = zigla.Rotation.angleAxis(angle, axis);
                self.update();
            }
        }
        self.last = mouse_input;
    }

    pub fn end(self: *Self, _: MouseInput) void {
        self.rotation = @"*"(self.tmp_rotation, self.rotation);
        self.tmp_rotation = .identity;
        self.update();
    }
};

pub const TurnTable = struct {
    const Self = @This();

    view: *zigla.camera_types.View,
    yaw: f32 = 0.0,
    pitch: f32 = 0.0,

    pub fn init(view: *zigla.camera_types.View) Self {
        var self = Self{
            .view = view,
        };

        self.update();
        return self;
    }

    pub fn update(self: *Self) void {
        const yaw = zigla.Mat3.angleAxis(self.yaw, zigla.Vec3.values(0, 1, 0));
        const pitch = zigla.Mat3.angleAxis(self.pitch, zigla.Vec3.values(1, 0, 0));
        self.view.rotation = @"*"(pitch, yaw);
    }

    pub fn begin(_: *Self, _: MouseInput) void {}

    pub fn drag(self: *Self, _: MouseInput, dx: i32, dy: i32) void {
        self.yaw += @intToFloat(f32, dx) * 0.01;
        self.pitch += @intToFloat(f32, dy) * 0.01;
        self.update();
    }

    pub fn end(_: *Self, _: MouseInput) void {}
};

pub const ScreenShift = struct {
    const Self = @This();

    view: *zigla.camera_types.View,
    projection: *zigla.camera_types.Projection,

    pub fn init(view: *zigla.camera_types.View, projection: *zigla.camera_types.Projection) Self {
        return .{
            .view = view,
            .projection = projection,
        };
    }

    pub fn reset(self: *Self, shift: zigla.Vec3) void {
        self.view.shift = shift;
    }

    pub fn begin(_: *Self, _: MouseInput) void {}

    pub fn drag(self: *Self, _: MouseInput, dx: i32, dy: i32) void {
        const plane_height = std.math.tan(self.projection.fovy * 0.5) * std.math.fabs(self.view.shift.z) * 4;
        self.view.shift.x += @intToFloat(f32, dx) / @intToFloat(f32, self.projection.height) * plane_height;
        self.view.shift.y -= @intToFloat(f32, dy) / @intToFloat(f32, self.projection.height) * plane_height;
    }

    pub fn end(_: *Self, _: MouseInput) void {}

    pub fn wheel(self: *Self, d: i32) void {
        if (d < 0) {
            self.view.shift.z *= 1.1;
        } else if (d > 0) {
            self.view.shift.z *= 0.9;
        }
    }
};
