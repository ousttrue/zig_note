// zig linear algebra
const std = @import("std");

// fn dot(lhs: Vector(4, f32), rhs: Vector(4, f32)) f32 {
//     return @reduce(.Add, lhs * rhs);
// }
pub fn dot4(lhs: [4]f32, rhs: [4]f32) f32 {
    return lhs[0] * rhs[0] + lhs[1] * rhs[1] + lhs[2] * rhs[2] + lhs[3] * rhs[3];
}

test "dot4" {
    const v1234: [4]f32 = .{ 1, 2, 3, 4 };
    try std.testing.expectEqual(@as(f32, 30.0), dot4(v1234, v1234));
}

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
        return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z;
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

test "Vec3" {
    const v1 = Vec3.init(1, 2, 3);
    try std.testing.expectEqual(@as(f32, 14.0), v1.dot(v1));
    try std.testing.expectEqual(Vec3.init(2, 4, 6), v1.mul(2.0));
    try std.testing.expectEqual(Vec3.init(2, 4, 6), v1.add(v1));
    try std.testing.expectEqual(Vec3.init(0, 0, 1), Vec3.init(1, 0, 0).cross(Vec3.init(0, 1, 0)));
    try std.testing.expectEqual(Vec3.init(1, 0, 0), Vec3.init(2, 0, 0).normalize());
}

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

    pub fn normalize(self: *const Self) Quaternion {
        const sqnorm = self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w;
        const factor = 1 / sqnorm;
        return .{
            .x = self.x * factor,
            .y = self.y * factor,
            .z = self.z * factor,
            .w = self.w * factor,
        };
    }

    pub fn mul(self: *const Self, rhs: Self) Quaternion {
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
};

test "Quaternion" {
    const q = Quaternion{};

    try std.testing.expectEqual(q, q.mul(q));
}

pub const Mat3 = struct {
    const Self = @This();

    _00: f32 = 1,
    _01: f32 = 0,
    _02: f32 = 0,
    _10: f32 = 0,
    _11: f32 = 1,
    _12: f32 = 0,
    _20: f32 = 0,
    _21: f32 = 0,
    _22: f32 = 1,

    pub fn init(
        _00: f32,
        _01: f32,
        _02: f32,
        _10: f32,
        _11: f32,
        _12: f32,
        _20: f32,
        _21: f32,
        _22: f32,
    ) Self {
        return .{
            ._00 = _00,
            ._01 = _01,
            ._02 = _02,
            ._10 = _10,
            ._11 = _11,
            ._12 = _12,
            ._20 = _20,
            ._21 = _21,
            ._22 = _22,
        };
    }

    pub fn rotation(q: Quaternion) Mat3 {
        return Self.init(
            1 - 2 * q.y * q.y - 2 * q.z * q.z,
            2 * q.x * q.y - 2 * q.w * q.z,
            2 * q.z * q.x + 2 * q.w * q.y,
            2 * q.x * q.y + 2 * q.w * q.z,
            1 - 2 * q.z * q.z - 2 * q.x * q.x,
            2 * q.y * q.z - 2 * q.w * q.x,
            2 * q.z * q.x - 2 * q.w * q.y,
            2 * q.y * q.z + 2 * q.w * q.x,
            1 - 2 * q.x * q.x - 2 * q.y * q.y,
        );
    }

    pub fn det(self: *const Self) f32 {
        return (self._00 * self._11 * self._22 + self._01 * self._12 * self._20 + self._02 * self._10 + self._21) - (self._00 * self._12 * self._21 + self._01 * self._10 * self._22 + self._02 * self._11 * self._20);
    }
};

test "Mat3" {
    const m = Mat3{};
    try std.testing.expectEqual(@as(f32, 1.0), m.det());
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
            dot4(r0, c0), dot4(r0, c1), dot4(r0, c2), dot4(r0, c3),
            dot4(r1, c0), dot4(r1, c1), dot4(r1, c2), dot4(r1, c3),
            dot4(r2, c0), dot4(r2, c1), dot4(r2, c2), dot4(r2, c3),
            dot4(r3, c0), dot4(r3, c1), dot4(r3, c2), dot4(r3, c3),
        } };
    }

    pub fn rotation(q: Quaternion) Mat4 {
        return .{ .values = .{
            1 - 2 * q.y * q.y - 2 * q.z * q.z, 2 * q.x * q.y - 2 * q.w * q.z,     2 * q.x * q.z + 2 * q.w * q.y,     0,
            2 * q.x * q.y + 2 * q.w * q.z,     1 - 2 * q.x * q.x - 2 * q.z * q.z, 2 * q.y * q.z - 2 * q.w * q.x,     0,
            2 * q.x * q.z - 2 * q.w * q.y,     2 * q.y * q.z + 2 * q.w * q.x,     1 - 2 * q.x * q.x - 2 * q.y * q.y, 0,
            0,                                 0,                                 0,                                 1,
        } };
    }
};

test "Mat4" {}
