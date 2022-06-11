const std = @import("std");
const la = @import("./linear_algebra.zig");
const ray_intersection = @import("./ray_intersection.zig");
const @"*" = la.@"*";

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

    pub fn getAspectRatio(self: Self) f32 {
        return @intToFloat(f32, self.width) / @intToFloat(f32, self.height);
    }

    pub fn getMatrix(self: *const Self) la.Mat4 {
        return la.Mat4.perspective(self.fovy, self.getAspectRatio(), self.near, self.far);
    }
};

pub const View = struct {
    const Self = @This();

    rotation: la.Quaternion = .{},
    shift: la.Vec3 = la.Vec3.init(0, 0, -5),

    pub fn getViewMatrix(self: Self) la.Mat4 {
        const r = la.Mat4.rotate(self.rotation);
        const t = la.Mat4.translate(self.shift);
        return @"*"(t, r);
    }

    pub fn getTransformMatrix(self: Self) la.Mat4 {
        const inverse = self.rotation.inverse();
        const r = la.Mat4.rotate(inverse);
        const t = la.Mat4.translate(self.shift.inverse());
        return @"*"(r, t);
    }
};

pub const Camera = struct {
    const Self = @This();

    projection: Projection = .{},
    view: View = .{},

    pub fn getViewProjectionMatrix(self: *const Self) la.Mat4 {
        const p = self.projection.getMatrix();
        const v = self.view.getViewMatrix();
        return p.mul(v);
    }

    pub fn getRay(self: Self, x: i32, y: i32) ray_intersection.Ray {
        return ray_intersection.Ray.createFromScreen(
            @intToFloat(f32, x),
            @intToFloat(f32, y),
            @intToFloat(f32, self.projection.width),
            @intToFloat(f32, self.projection.height),
            self.view.getTransformMatrix(),
            self.projection.fovy,
            self.projection.getAspectRatio(),
        );
    }
};

test {
    std.testing.expectEqual(14, la.Vec3.init(1, 2, 3).dot(la.Vec3.init(1, 2, 3)));
    std.testing.expectEqual(la.Vec3.init(0, 0, 1), (la.Vec3.init(1, 0, 0).cross(la.Vec3.init(0, 1, 0))));
}
