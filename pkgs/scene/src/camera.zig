const std = @import("std");
const zigla = @import("zigla");
const screen = @import("screen");
const @"*" = zigla.@"*";

pub const Projection = struct {
    const Self = @This();

    fovy: f32 = std.math.pi * (30.0 / 180.0),
    near: f32 = 0.1,
    far: f32 = 100.0,
    width: u32 = 1,
    height: u32 = 1,

    pub fn resize(self: *Self, width: u32, height: u32) void {
        self.width = width;
        self.height = height;
    }

    pub fn getMatrix(self: *const Self) zigla.Mat4 {
        // return zlm.Mat4.createPerspective(self.fov, self.aspect, self.near, self.far);
        return zigla.Mat4.perspective(self.fovy, @intToFloat(f32, self.width) / @intToFloat(f32, self.height), self.near, self.far);
    }
};

pub const View = struct {
    const Self = @This();

    rotation: zigla.Quaternion = .{},
    shift: zigla.Vec3 = zigla.Vec3.init(0, 0, -2),

    pub fn getMatrix(self: *const Self) zigla.Mat4 {
        // const yaw = zlm.Mat4.createAngleAxis(zlm.Vec3.new(0, 1, 0), self.yaw);
        // const pitch = zlm.Mat4.createAngleAxis(zlm.Vec3.new(1, 0, 0), self.pitch);
        // const shift = zlm.Mat4.createTranslation(self.shift);
        const r = zigla.Mat4.rotate(self.rotation);
        const t = zigla.Mat4.translate(self.shift);
        return @"*"(t, r);
    }
};

pub const Camera = struct {
    const Self = @This();

    projection: Projection = .{},
    view: View = .{},

    pub fn getMatrix(self: *const Self) zigla.Mat4 {
        const p = self.projection.getMatrix();
        const v = self.view.getMatrix();
        return p.mul(v);
    }
};

test {
    std.testing.expectEqual(14, zigla.Vec3.init(1, 2, 3).dot(zigla.Vec3.init(1, 2, 3)));
    std.testing.expectEqual(zigla.Vec3.init(0, 0, 1), (zigla.Vec3.init(1, 0, 0).cross(zigla.Vec3.init(0, 1, 0))));
}

pub fn getArcballVector(mouse_input: screen.MouseInput) zigla.Vec3 {
    // https://en.wikibooks.org/wiki/OpenGL_Programming/Modern_OpenGL_Tutorial_Arcball
    const x = @intToFloat(f32, mouse_input.x) / @intToFloat(f32, mouse_input.width) * 2 - 1.0; // -1 ~ +1
    const y = @intToFloat(f32, mouse_input.y) / @intToFloat(f32, mouse_input.height) * 2 - 1.0; // -1 ~ +1
    var P = zigla.Vec3.init(x, -y, 0);
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

    view: *View,
    projection: *Projection,
    rotation: zigla.Quaternion,
    tmp_rotation: zigla.Quaternion,
    last: ?screen.MouseInput = null,
    va: ?zigla.Vec3 = null,

    pub fn init(view: *View, projection: *Projection) Self {
        return .{
            .rotation = .{},
            .tmp_rotation = .{},
            .view = view,
            .projection = projection,
        };
    }

    pub fn update(self: *Self) void {
        // self.view.rotation = self.tmp_rotation.mul(self.rotation).normalize();
        self.view.rotation = @"*"(self.tmp_rotation, self.rotation);
        self.view.rotation.normalize();
    }

    pub fn begin(self: *Self, mouse_input: screen.MouseInput) void {
        self.rotation = self.view.rotation;
        self.last = mouse_input;
        self.va = getArcballVector(mouse_input);
    }

    pub fn drag(self: *Self, mouse_input: screen.MouseInput, _: i32, _: i32) void {
        if (self.last) |last| {
            if (mouse_input.x != last.x or mouse_input.y != last.y) {
                const va = self.va orelse unreachable;
                const vb = getArcballVector(mouse_input);
                const dot = va.dot(vb);
                const angle = std.math.acos(std.math.min(1.0, dot)) * 2;
                const axis = va.cross(vb);
                // std.log.debug("[{d:.2}, {d:.2}, {d:.2}], [{d:.2}, {d:.2}, {d:.2}][{d:.2}, {d:.2}, {d:.2}], {d:.2}, {d:.2}", .{ va.x, va.y, va.z, vb.x, vb.y, vb.z, axis.x, axis.y, axis.z, dot, angle });
                self.tmp_rotation = zigla.Quaternion.angleAxis(angle, axis);
                self.update();
            }
        }
        self.last = mouse_input;
    }

    pub fn end(self: *Self, _: screen.MouseInput) void {
        self.rotation = @"*"(self.tmp_rotation, self.rotation);
        self.rotation.normalize();
        self.tmp_rotation = .{};
        self.update();
    }
};

pub const TurnTable = struct {
    const Self = @This();

    view: *View,
    yaw: f32 = 0.0,
    pitch: f32 = 0.0,

    pub fn init(view: *View) Self {
        var self = Self{
            .view = view,
        };

        self.update();
        return self;
    }

    pub fn update(self: *Self) void {
        const yaw = zigla.Mat3.angleAxis(self.yaw, zigla.Vec3.init(0, 1, 0));
        const pitch = zigla.Mat3.angleAxis(self.pitch, zigla.Vec3.init(1, 0, 0));
        self.view.rotation = @"*"(pitch, yaw);
    }

    pub fn begin(_: *Self, _: screen.MouseInput) void {}

    pub fn drag(self: *Self, _: screen.MouseInput, dx: i32, dy: i32) void {
        self.yaw += @intToFloat(f32, dx) * 0.01;
        self.pitch += @intToFloat(f32, dy) * 0.01;
        self.update();
    }

    pub fn end(_: *Self, _: screen.MouseInput) void {}
};

pub const ScreenShift = struct {
    const Self = @This();

    view: *View,
    projection: *Projection,

    pub fn init(view: *View, projection: *Projection) Self {
        return .{
            .view = view,
            .projection = projection,
        };
    }

    pub fn reset(self: *Self, shift: zigla.Vec3) void {
        self.view.shift = shift;
    }

    pub fn begin(_: *Self, _: screen.MouseInput) void {}

    pub fn drag(self: *Self, _: screen.MouseInput, dx: i32, dy: i32) void {
        const plane_height = std.math.tan(self.projection.fovy * 0.5) * std.math.fabs(self.view.shift.z) * 4;
        self.view.shift.x += @intToFloat(f32, dx) / @intToFloat(f32, self.projection.height) * plane_height;
        self.view.shift.y -= @intToFloat(f32, dy) / @intToFloat(f32, self.projection.height) * plane_height;
    }

    pub fn end(_: *Self, _: screen.MouseInput) void {}

    pub fn wheel(self: *Self, d: i32) void {
        if (d < 0) {
            self.view.shift.z *= 1.1;
        } else if (d > 0) {
            self.view.shift.z *= 0.9;
        }
    }
};
