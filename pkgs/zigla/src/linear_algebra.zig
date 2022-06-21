// zig linear algebra
const std = @import("std");
const Vector = std.meta.Vector;

//
// R | 0
// --+--
// T | 1
//

pub fn nearlyEqual(comptime epsilon: anytype, comptime n: usize, lhs: [n]@TypeOf(epsilon), rhs: [n]@TypeOf(epsilon)) bool {
    for (lhs) |l, i| {
        const delta = std.math.fabs(l - rhs[i]);
        if (delta > epsilon) {
            std.debug.print("\n", .{});
            std.debug.print("lhs: {any}\n", .{lhs});
            std.debug.print("rhs: {any}\n", .{rhs});
            std.debug.print("{}: {}, {} => {}\n", .{ i, l, rhs[i], delta });
            return false;
        }
    }
    return true;
}

pub fn vdot4(lhs: Vector(4, f32), rhs: Vector(4, f32)) f32 {
    return @reduce(.Add, lhs * rhs);
}
pub fn vdot3(lhs: Vector(3, f32), rhs: Vector(3, f32)) f32 {
    return @reduce(.Add, lhs * rhs);
}

fn sign(x: f32) f32 {
    return if (x >= 0.0) 1.0 else -1.0;
}
fn norm(a: f32, b: f32, c: f32, d: f32) f32 {
    return std.math.sqrt(a * a + b * b + c * c + d * d);
}

pub const Vec2 = struct {
    const Self = @This();
    x: f32,
    y: f32,
    pub fn init(x: f32, y: f32) Self {
        return .{ .x = x, .y = y };
    }
    pub fn inversed(self: Self) Self {
        return .{ .x = -self.x, .y = -self.y };
    }
    pub fn dot(self: Self, rhs: Self) f32 {
        return self.x * rhs.x + self.y * rhs.y;
    }
    pub fn sub(self: Self, rhs: Self) Vec2 {
        return .{ .x = self.x - rhs.x, .y = self.y - rhs.y };
    }
    pub fn normalize(self: *Self) void {
        const sqnorm = self.dot(self.*);
        const factor = 1.0 / std.math.sqrt(sqnorm);
        self.x *= factor;
        self.y *= factor;
    }
    pub fn normalized(self: Self) Self {
        var copy = self;
        copy.normalize();
        return copy;
    }
};

pub const Vec3 = struct {
    const Self = @This();
    x: f32,
    y: f32,
    z: f32,
    pub fn init(x: f32, y: f32, z: f32) Self {
        return .{ .x = x, .y = y, .z = z };
    }
    pub fn scalar(n: f32) Self {
        return .{ .x = n, .y = n, .z = n };
    }
    pub fn vec2(v: Vec2, z: f32) Vec3 {
        return .{ .x = v.x, .y = v.y, .z = z };
    }
    pub fn array(self: *Self) [3]f32 {
        return (@ptrCast([*]f32, &self.x))[0..3].*;
    }
    pub fn toVec2(self: Self) Vec2 {
        return .{ .x = self.x, .y = self.y };
    }
    pub fn const_array(self: *const Self) [3]f32 {
        return (@ptrCast([*]const f32, &self.x))[0..3].*;
    }
    pub fn inversed(self: Self) Self {
        return .{ .x = -self.x, .y = -self.y, .z = -self.z };
    }
    pub fn dot(self: Self, rhs: Self) f32 {
        return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z;
    }
    pub fn mul(self: Self, n: f32) Vec3 {
        return .{ .x = self.x * n, .y = self.y * n, .z = self.z * n };
    }
    pub fn add(self: Self, rhs: Self) Vec3 {
        return .{ .x = self.x + rhs.x, .y = self.y + rhs.y, .z = self.z + rhs.z };
    }
    pub fn sub(self: Self, rhs: Self) Vec3 {
        return .{ .x = self.x - rhs.x, .y = self.y - rhs.y, .z = self.z - rhs.z };
    }

    pub fn cross(self: Self, rhs: Vec3) Vec3 {
        return .{
            .x = self.y * rhs.z - self.z * rhs.y,
            .y = self.z * rhs.x - self.x * rhs.z,
            .z = self.x * rhs.y - self.y * rhs.x,
        };
    }
    pub fn normalize(self: *Self) void {
        const sqnorm = self.dot(self.*);
        const len = std.math.sqrt(sqnorm);
        const factor = 1.0 / len;
        self.x *= factor;
        self.y *= factor;
        self.z *= factor;
    }
    pub fn normalized(self: Self) Self {
        var copy = self;
        copy.normalize();
        return copy;
    }
};

pub const Vec4 = struct {
    const Self = @This();
    x: f32,
    y: f32,
    z: f32,
    w: f32,
    pub fn init(x: f32, y: f32, z: f32, w: f32) Self {
        return .{ .x = x, .y = y, .z = z, .w = w };
    }
    pub fn vec3(v: Vec3, w: f32) Vec4 {
        return .{ .x = v.x, .y = v.y, .z = v.z, .w = w };
    }
    pub fn toVec3(self: Self) Vec3 {
        return .{ .x = self.x, .y = self.y, .z = self.z };
    }
    pub fn dot(self: Self, rhs: Vec4) f32 {
        return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z + self.w * rhs.w;
    }
    pub fn normalize(self: *Self) void {
        const sqnorm = self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w;
        const factor = 1 / std.math.sqrt(sqnorm);
        self.x *= factor;
        self.y *= factor;
        self.z *= factor;
        self.w *= factor;
    }
    pub fn normalized(self: Self) Self {
        var copy = self;
        copy.normalize();
        return copy;
    }
    pub fn mul(self: Self, rhs: Mat4) Self {
        return Self.init(
            self.dot(rhs.col0()),
            self.dot(rhs.col0()),
            self.dot(rhs.col0()),
            self.dot(rhs.col0()),
        );
    }
};

pub const Quaternion = struct {
    const Self = @This();
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,
    w: f32 = 1,

    pub fn angleAxis(angle: f32, axis: Vec3) Self {
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

    pub fn normalize(self: *Self) void {
        const sqnorm = self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w;
        const factor = 1 / std.math.sqrt(sqnorm);
        self.x *= factor;
        self.y *= factor;
        self.z *= factor;
        self.w *= factor;
    }

    pub fn normalized(self: Self) Self {
        var copy = self;
        copy.normalize();
        return copy;
    }

    pub fn inversed(self: Self) Self {
        return .{ .x = -self.x, .y = -self.y, .z = -self.z, .w = self.w };
    }

    pub fn rotate(self: Self, v: Vec3) Vec3 {
        return Mat3.rotate(self).apply(v);
    }

    pub fn mul(self: Self, rhs: Self) Self {
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

pub const Mat3 = struct {
    const Self = @This();

    _0: Vec3 = Vec3.init(1, 0, 0),
    _1: Vec3 = Vec3.init(0, 1, 0),
    _2: Vec3 = Vec3.init(0, 0, 1),

    pub fn init(_00: f32, _01: f32, _02: f32, _10: f32, _11: f32, _12: f32, _20: f32, _21: f32, _22: f32) Self {
        return .{
            ._0 = Vec3.init(_00, _01, _02),
            ._1 = Vec3.init(_10, _11, _12),
            ._2 = Vec3.init(_20, _21, _22),
        };
    }

    pub fn rows(_0: Vec3, _1: Vec3, _2: Vec3) Self {
        return .{ ._0 = _0, ._1 = _1, ._2 = _2 };
    }

    pub fn angleAxis(angle: f32, a: Vec3) Self {
        const c = std.math.cos(angle);
        const s = std.math.sin(angle);
        const _00 = c + a.x * a.x * (1 - c);
        const _10 = a.x * a.y * (1 - c) - a.z * s;
        const _20 = a.x * a.z * (1 - c) + a.y * s;
        const _01 = a.x * a.y * (1 - c) + a.z * s;
        const _11 = c + a.y * a.y * (1 - c);
        const _21 = a.y * a.z * (1 - c) - a.x * s;
        const _02 = a.x * a.z * (1 - c) - a.y * s;
        const _12 = a.y * a.z * (1 - c) + a.x * s;
        const _22 = c + a.z * a.z * (1 - c);
        return Self.rows(
            Vec3.init(_00, _01, _02),
            Vec3.init(_10, _11, _12),
            Vec3.init(_20, _21, _22),
        );
    }

    pub fn rotate(q: Quaternion) Self {
        const _00 = 1 - 2 * q.y * q.y - 2 * q.z * q.z;
        const _10 = 2 * q.x * q.y - 2 * q.w * q.z;
        const _20 = 2 * q.z * q.x + 2 * q.w * q.y;
        const _01 = 2 * q.x * q.y + 2 * q.w * q.z;
        const _11 = 1 - 2 * q.z * q.z - 2 * q.x * q.x;
        const _21 = 2 * q.y * q.z - 2 * q.w * q.x;
        const _02 = 2 * q.z * q.x - 2 * q.w * q.y;
        const _12 = 2 * q.y * q.z + 2 * q.w * q.x;
        const _22 = 1 - 2 * q.x * q.x - 2 * q.y * q.y;
        return Self.rows(
            Vec3.init(_00, _01, _02),
            Vec3.init(_10, _11, _12),
            Vec3.init(_20, _21, _22),
        );
    }

    pub fn getRow(self: Self, comptime row: usize) Vec3 {
        return switch (row) {
            0 => self._0,
            1 => self._1,
            2 => self._2,
            else => unreachable,
        };
    }

    /// http://www.info.hiroshima-cu.ac.jp/~miyazaki/knowledge/tech0052.html
    pub fn toQuaternion(self: Self) Quaternion {
        const _00 = self._0.x;
        const _01 = self._0.y;
        const _02 = self._0.z;
        const _10 = self._1.x;
        const _11 = self._1.y;
        const _12 = self._1.z;
        const _20 = self._2.x;
        const _21 = self._2.y;
        const _22 = self._2.z;

        var q0 = (_00 + _11 + _22 + 1.0) / 4.0;
        var q1 = (_00 - _11 - _22 + 1.0) / 4.0;
        var q2 = (-_00 + _11 - _22 + 1.0) / 4.0;
        var q3 = (-_00 - _11 + _22 + 1.0) / 4.0;
        if (q0 < 0.0) q0 = 0.0;
        if (q1 < 0.0) q1 = 0.0;
        if (q2 < 0.0) q2 = 0.0;
        if (q3 < 0.0) q3 = 0.0;
        q0 = std.math.sqrt(q0);
        q1 = std.math.sqrt(q1);
        q2 = std.math.sqrt(q2);
        q3 = std.math.sqrt(q3);
        if (q0 >= q1 and q0 >= q2 and q0 >= q3) {
            // q0 *= 1.0;
            q1 *= sign(_12 - _21);
            q2 *= sign(_20 - _02);
            q3 *= sign(_01 - _10);
        } else if (q1 >= q0 and q1 >= q2 and q1 >= q3) {
            q0 *= sign(_12 - _21);
            // q1 *= 1.0;
            q2 *= sign(_01 + _10);
            q3 *= sign(_20 + _02);
        } else if (q2 >= q0 and q2 >= q1 and q2 >= q3) {
            q0 *= sign(_20 - _02);
            q1 *= sign(_01 + _10);
            // q2 *= 1.0;
            q3 *= sign(_12 + _21);
        } else if (q3 >= q0 and q3 >= q1 and q3 >= q2) {
            q0 *= sign(_01 - _10);
            q1 *= sign(_02 + _20);
            q2 *= sign(_12 + _21);
            q3 *= 1.0;
        } else {
            unreachable;
        }
        const r = 1.0 / norm(q0, q1, q2, q3);
        q0 *= r;
        q1 *= r;
        q2 *= r;
        q3 *= r;
        return Quaternion{ .x = q1, .y = q2, .z = q3, .w = q0 };
    }

    pub fn array(self: *Self) [9]f32 {
        return @ptrCast([*]f32, &self._0.x)[0..9].*;
    }
    pub fn col0(self: Self) Vec3 {
        return Vec3.init(self._0.x, self._1.x, self._2.x);
    }
    pub fn col1(self: Self) Vec3 {
        return Vec3.init(self._0.y, self._1.y, self._2.y);
    }
    pub fn col2(self: Self) Vec3 {
        return Vec3.init(self._0.z, self._1.z, self._2.z);
    }

    pub fn transposed(self: *Self) Self {
        return Mat3.rows(
            self.col0(),
            self.col1(),
            self.col2(),
        );
    }

    pub fn det(self: Self) f32 {
        return (self._0.x * self._1.y * self._2.z + self._0.y * self._1.z * self._2.x + self._0.z * self._1.x + self._2.y) - (self._0.x * self._1.z * self._2.y + self._0.y * self._1.x * self._2.z + self._0.z * self._1.y * self._2.x);
    }

    pub fn normalized(self: Self) Self {
        var copy = self;
        copy.normalize();
        return copy;
    }

    pub fn normalize(self: *Self) void {
        const d = self.det();
        const f = 1.0 / d;
        self._0.x *= f;
        self._0.y *= f;
        self._0.z *= f;
        self._1.x *= f;
        self._1.y *= f;
        self._1.z *= f;
        self._2.x *= f;
        self._2.y *= f;
        self._2.z *= f;
    }

    pub fn mul(self: Self, rhs: Self) Self {
        return Self.rows(
            Vec3.init(self._0.dot(rhs.col0()), self._0.dot(rhs.col1()), self._0.dot(rhs.col2())),
            Vec3.init(self._1.dot(rhs.col0()), self._1.dot(rhs.col1()), self._1.dot(rhs.col2())),
            Vec3.init(self._2.dot(rhs.col0()), self._2.dot(rhs.col1()), self._2.dot(rhs.col2())),
        );
    }

    ///          [m00, m01, m02]
    /// [x, y, z][m10, m11, m12] => [x', y', z']
    ///          [m20, m21, m22]
    pub fn apply(self: Self, v: Vec3) Vec3 {
        return Vec3.init(
            v.dot(self.col0()),
            v.dot(self.col1()),
            v.dot(self.col2()),
        );
    }
};

pub const Mat4 = struct {
    const Self = @This();

    // rows
    _0: Vec4 = Vec4.init(1, 0, 0, 0),
    _1: Vec4 = Vec4.init(0, 1, 0, 0),
    _2: Vec4 = Vec4.init(0, 0, 1, 0),
    _3: Vec4 = Vec4.init(0, 0, 0, 1),

    pub fn init(_00: f32, _01: f32, _02: f32, _03: f32, _10: f32, _11: f32, _12: f32, _13: f32, _20: f32, _21: f32, _22: f32, _23: f32, _30: f32, _31: f32, _32: f32, _33: f32) Mat4 {
        return .{
            ._0 = Vec4.init(_00, _01, _02, _03),
            ._1 = Vec4.init(_10, _11, _12, _13),
            ._2 = Vec4.init(_20, _21, _22, _23),
            ._3 = Vec4.init(_30, _31, _32, _33),
        };
    }

    pub fn rows(_0: Vec4, _1: Vec4, _2: Vec4, _3: Vec4) Mat4 {
        return .{
            ._0 = _0,
            ._1 = _1,
            ._2 = _2,
            ._3 = _3,
        };
    }

    pub fn getRow(self: Self, comptime row: usize) Vec4 {
        return switch (row) {
            0 => self._0,
            1 => self._1,
            2 => self._2,
            3 => self._3,
            else => unreachable,
        };
    }

    pub fn toMat3(self: Self) Mat3 {
        return Mat3.rows(
            self._0.toVec3(),
            self._1.toVec3(),
            self._2.toVec3(),
        );
    }

    pub fn frustum(b: f32, t: f32, l: f32, r: f32, n: f32, f: f32) Self {
        // set OpenGL perspective projection matrix
        return Self.rows(
            Vec4.init(2 * n / (r - l), 0, 0, 0),
            Vec4.init(0, 2 * n / (t - b), 0, 0),
            Vec4.init((r + l) / (r - l), (t + b) / (t - b), -(f + n) / (f - n), -1),
            Vec4.init(0, 0, -2 * f * n / (f - n), 0),
        );
    }

    pub fn perspective(fov: f32, aspect: f32, n: f32, f: f32) Self {
        const scale = std.math.tan(fov / 2) * n;
        const r = aspect * scale;
        const l = -r;
        const t = scale;
        const b = -t;
        return frustum(b, t, l, r, n, f);
    }

    pub fn translate(t: Vec3) Self {
        return Self.rows(
            Vec4.init(1, 0, 0, 0),
            Vec4.init(0, 1, 0, 0),
            Vec4.init(0, 0, 1, 0),
            Vec4.vec3(t, 1),
        );
    }

    pub fn mat3(m: Mat3) Mat4 {
        return Self.rows(
            Vec4.vec3(m._0, 0),
            Vec4.vec3(m._1, 0),
            Vec4.vec3(m._2, 0),
            Vec4.init(0, 0, 0, 1),
        );
    }

    pub fn rotate(q: Quaternion) Mat4 {
        return Self.mat3(Mat3.rotate(q));
    }

    pub fn col0(self: Self) Vec4 {
        return Vec4.init(self._0.x, self._1.x, self._2.x, self._3.x);
    }
    pub fn col1(self: Self) Vec4 {
        return Vec4.init(self._0.y, self._1.y, self._2.y, self._3.y);
    }
    pub fn col2(self: Self) Vec4 {
        return Vec4.init(self._0.z, self._1.z, self._2.z, self._3.z);
    }
    pub fn col3(self: Self) Vec4 {
        return Vec4.init(self._0.w, self._1.w, self._2.w, self._3.w);
    }

    ///             [m00, m01, m02, m03]
    ///             [m10, m11, m12, m13]
    /// [x, y, z, w][m20, m21, m22, m23]
    ///             [m30, m31, m32, m33]
    pub fn apply(self: Self, v: Vec4) Vec4 {
        return Vec4.init(
            v.dot(self.col0()),
            v.dot(self.col1()),
            v.dot(self.col2()),
            v.dot(self.col3()),
        );
    }

    pub fn applyVec3(self: Self, v: Vec3, w: f32) Vec3 {
        const v4 = Vec4.vec3(v, w).mul(self);
        return v4.toVec3();
    }

    pub fn mul(self: Self, rhs: Self) Self {
        return Self.rows(
            Vec4.init(
                self._0.dot(rhs.col0()),
                self._0.dot(rhs.col1()),
                self._0.dot(rhs.col2()),
                self._0.dot(rhs.col3()),
            ),
            Vec4.init(
                self._1.dot(rhs.col0()),
                self._1.dot(rhs.col1()),
                self._1.dot(rhs.col2()),
                self._1.dot(rhs.col3()),
            ),
            Vec4.init(
                self._2.dot(rhs.col0()),
                self._2.dot(rhs.col1()),
                self._2.dot(rhs.col2()),
                self._2.dot(rhs.col3()),
            ),
            Vec4.init(
                self._3.dot(rhs.col0()),
                self._3.dot(rhs.col1()),
                self._3.dot(rhs.col2()),
                self._3.dot(rhs.col3()),
            ),
        );
    }
};

pub fn @"+"(lhs: anytype, rhs: @TypeOf(lhs)) @TypeOf(lhs) {
    return lhs.add(rhs);
}
pub fn @"-"(lhs: anytype, rhs: @TypeOf(lhs)) @TypeOf(lhs) {
    return lhs.sub(rhs);
}
pub fn @"*"(lhs: anytype, rhs: @TypeOf(lhs)) @TypeOf(lhs) {
    return lhs.mul(rhs);
}

fn Child(comptime t: type) type {
    return switch (@typeInfo(t)) {
        .Array => |a| a.child,
        .Pointer => |p| p.child,
        else => @compileError("not implemented"),
    };
}

test "vdot" {
    const v1234: [4]f32 = .{ 1, 2, 3, 4 };
    try std.testing.expectEqual(@as(f32, 30.0), vdot4(v1234, v1234));
    const v123 = [_]f32{ 1, 2, 3 };
    try std.testing.expectEqual(@as(f32, 14.0), vdot3(v123, v123));
}

test "Vec3" {
    const v1 = Vec3.init(1, 2, 3);
    try std.testing.expectEqual(@as(f32, 14.0), v1.dot(v1));
    try std.testing.expectEqual(Vec3.init(2, 4, 6), v1.mul(2.0));
    try std.testing.expectEqual(Vec3.init(2, 4, 6), @"+"(v1, v1));
    try std.testing.expectEqual(Vec3.init(0, 0, 1), Vec3.init(1, 0, 0).cross(Vec3.init(0, 1, 0)));
    try std.testing.expectEqual(Vec3.init(1, 0, 0), Vec3.init(2, 0, 0).normalized());
}

test "Quaternion" {
    const q = Quaternion{};
    try std.testing.expectEqual(q, q.mul(q));

    const m = Mat3.rotate(q);
    const qq = m.toQuaternion();
    try std.testing.expectEqual(q, qq);
    try std.testing.expectEqual(Quaternion{ .x = 0, .y = 0, .z = 0, .w = 1 }, qq);
}

test "Mat3" {
    const m = Mat3{};
    try std.testing.expectEqual(@as(f32, 1.0), m.det());
    var axis = Vec3.init(1, 2, 3);
    axis.normalize();
    const angle = std.math.pi * 25.0 / 180.0;
    const q = Quaternion.angleAxis(angle, axis);
    try std.testing.expect(nearlyEqual(@as(f32, 1e-5), 9, Mat3.rotate(q).array(), Mat3.angleAxis(angle, axis).array()));
}
