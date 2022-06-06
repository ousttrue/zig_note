// zig linear algebra
const std = @import("std");

// fn dot(lhs: Vector(4, f32), rhs: Vector(4, f32)) f32 {
//     return @reduce(.Add, lhs * rhs);
// }
pub fn dot(lhs: [4]f32, rhs: [4]f32) f32 {
    return lhs[0] * rhs[0] + lhs[1] * rhs[1] + lhs[2] * rhs[2] + lhs[3] * rhs[3];
}

pub const Mat4 = struct {
    const Self = @This();

    values: [16]f32,

    pub fn ptr(self: *const Self) *const f32 {
        return &self.values[0];
    }

    pub fn frustum(b: f32, t: f32, l: f32, r: f32, n: f32, f: f32) Self {
        // set OpenGL perspective projection matrix
        return .{ .values = .{
            2 * n / (r - l),
            0,
            0,
            0,
            0,
            2 * n / (t - b),
            0,
            0,
            (r + l) / (r - l),
            (t + b) / (t - b),
            -(f + n) / (f - n),
            -1,
            0,
            0,
            -2 * f * n / (f - n),
            0,
        } };
    }

    pub fn perspective(fov: f32, aspect: f32, n: f32, f: f32) Self {
        const scale = std.math.tan(fov) * n;
        const r = aspect * scale;
        const l = -r;
        const t = scale;
        const b = -t;
        return frustum(b, t, l, r, n, f);
    }

    pub fn translate(x: f32, y: f32, z: f32) Self {
        return .{ .values = .{
            1, 0, 0, x,
            0, 1, 0, y,
            0, 0, 1, z,
            0, 0, 0, 1,
        } };
    }

    pub fn mul(self: Self, rhs: Self) Self {
        const r0 = self.values[0..4].*;
        const r1 = self.values[4..8].*;
        const r2 = self.values[8..12].*;
        const r3 = self.values[12..16].*;
        const c0 = .{ rhs.values[0], rhs.values[4], rhs.values[8], rhs.values[12] };
        const c1 = .{ rhs.values[1], rhs.values[5], rhs.values[9], rhs.values[13] };
        const c2 = .{ rhs.values[2], rhs.values[6], rhs.values[10], rhs.values[14] };
        const c3 = .{ rhs.values[3], rhs.values[7], rhs.values[11], rhs.values[15] };
        return .{ .values = .{
            dot(r0, c0), dot(r0, c1), dot(r0, c2), dot(r0, c3),
            dot(r1, c0), dot(r1, c1), dot(r1, c2), dot(r1, c3),
            dot(r2, c0), dot(r2, c1), dot(r2, c2), dot(r2, c3),
            dot(r3, c0), dot(r3, c1), dot(r3, c2), dot(r3, c3),
        } };
    }
};

pub const Vec3 = struct {
    const Self = @This();
    x: f32,
    y: f32,
    z: f32,
    pub fn init(x: f32, y: f32, z: f32) Self {
        return .{
            .x = x,
            .y = y,
            .z = z,
        };
    }
    pub fn dot(self: *const Self, rhs: Vec3) f32 {
        return self.x * rhs.x + self.y * rhs.y + self.z + rhs.z;
    }
    pub fn mul(self: *const Self, scalar: f32) Vec3 {
        return .{ .x = self.x * scalar, .y = self.y * scalar, .z = self.z * scalar };
    }
    pub fn add(self: *const Self, rhs: Vec3) Vec3 {
        return .{ .x = self.x + rhs.x, .y = self.y + rhs.y, .z = self.z + rhs.z };
    }

    pub fn cross(self: *const Self, rhs: Vec3) Vec3 {
        return .{
            .x = self.y * rhs.z - self.z * rhs.y,
            .y = self.z * rhs.x - self.x * rhs.z,
            .z = self.x * rhs.y - self.y * rhs.x,
        };
    }
    pub fn normalize(self: *const Self) Self {
        const sqnorm = self.dot(self.*);
        const len = std.math.sqrt(sqnorm);
        const factor = 1.0 / len;
        return .{ .x = self.x * factor, .y = self.y * factor, .z = self.z * factor };
    }
};

pub const Quaternion = struct {
    const Self = @This();
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,
    w: f32 = 1,

    pub fn angleAxis(angle: f32, axis: Vec3) Quaternion {
        const half = angle / 2;
        const c = std.math.cos(half);
        const s = std.math.sin(half);
        return .{
            .x = axis.x * s,
            .y = axis.y * s,
            .z = axis.z * s,
            .w = c,
        };
    }

    pub fn normalize(self: *Self) Quaternion {
        const sqnorm = self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w;
        const factor = 1 / sqnorm;
        return .{
            .x = self.x * factor,
            .y = self.y * factor,
            .z = self.z * factor,
            .w = self.w * factor,
        };
    }

    pub fn mul(self: *Self, rhs: Self) Quaternion {
        const lv = Vec3{ .x = self.x, .y = self.y, .z = self.z };
        const rv = Vec3{ .x = rhs.x, .y = rhs.y, .z = rhs.z };
        const v = lv.mul(rhs.w).add(rv.mul(self.w)).add(lv.cross(rv));
        return .{
            .x = v.x,
            .y = v.y,
            .z = v.z,
            .w = self.w * rhs.w - lv.dot(rv),
        };
    }

    pub fn toMat4(self: *Self) Mat4 {
        return .{ .values = .{
            1 - 2 * self.y * self.y - 2 * self.z * self.z, 2 * self.x * self.y + 2 * self.w * self.z,     2 * self.x * self.z - 2 * self.w * self.y,     0,
            2 * self.x * self.y - 2 * self.w * self.z,     1 - 2 * self.x * self.x - 2 * self.z * self.z, 2 * self.y * self.z + 2 * self.w * self.x,     0,
            2 * self.x * self.z + 2 * self.w * self.y,     2 * self.y * self.z - 2 * self.w * self.x,     1 - 2 * self.x * self.x - 2 * self.y * self.y, 0,
            0,                                             0,                                             0,                                             1,
        } };
    }
};
