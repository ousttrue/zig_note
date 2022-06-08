// zig linear algebra
const std = @import("std");
const Vector = std.meta.Vector;

//
// R | T
// --+--
// 0 | 1
//

const typeinfo: std.builtin.TypeInfo = undefined;

fn nearlyEqual(comptime epsilon: anytype, comptime n: usize, lhs: [n]@TypeOf(epsilon), rhs: [n]@TypeOf(epsilon)) bool {
    for (lhs) |l, i| {
        if (std.math.fabs(l - rhs[i]) > epsilon) {
            std.debug.print("\n", .{});
            std.debug.print("{any}\n", .{lhs});
            std.debug.print("{any}\n", .{rhs});
            std.debug.print("{}: {}, {}\n", .{ i, l, rhs[i] });
            return false;
        }
    }
    return true;
}

fn Child(comptime t: type) type {
    return switch (@typeInfo(t)) {
        .Array => |a| a.child,
        .Pointer => |p| p.child,
        else => @compileError("not implemented"),
    };
}

fn vdot4(lhs: Vector(4, f32), rhs: Vector(4, f32)) f32 {
    return @reduce(.Add, lhs * rhs);
}
// pub fn dot4(lhs: anytype, rhs: @TypeOf(lhs)) Child(@TypeOf(lhs)) {
//     // return lhs[0] * rhs[0] + lhs[1] * rhs[1] + lhs[2] * rhs[2] + lhs[3] * rhs[3];
//     return vdot4(lhs[0..4].*, rhs[0..4].*);
// }
fn vdot3(lhs: Vector(3, f32), rhs: Vector(3, f32)) f32 {
    return @reduce(.Add, lhs * rhs);
}

test "vdot" {
    const v1234: [4]f32 = .{ 1, 2, 3, 4 };
    try std.testing.expectEqual(@as(f32, 30.0), vdot4(v1234, v1234));
    const v123 = [_]f32{ 1, 2, 3 };
    try std.testing.expectEqual(@as(f32, 14.0), vdot3(v123, v123));
}

pub const Vec3 = struct {
    const Self = @This();
    x: f32,
    y: f32,
    z: f32,
    pub fn init(x: f32, y: f32, z: f32) Self {
        return .{ .x = x, .y = y, .z = z };
    }
    pub fn dot(self: Self, rhs: Vec3) f32 {
        return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z;
    }
    pub fn mul(self: Self, scalar: f32) Vec3 {
        return .{ .x = self.x * scalar, .y = self.y * scalar, .z = self.z * scalar };
    }
    pub fn add(self: Self, rhs: Vec3) Vec3 {
        return .{ .x = self.x + rhs.x, .y = self.y + rhs.y, .z = self.z + rhs.z };
    }

    pub fn cross(self: Self, rhs: Vec3) Vec3 {
        return .{
            .x = self.y * rhs.z - self.z * rhs.y,
            .y = self.z * rhs.x - self.x * rhs.z,
            .z = self.x * rhs.y - self.y * rhs.x,
        };
    }
    pub fn normalize(self: Self) Self {
        const sqnorm = self.dot(self);
        const len = std.math.sqrt(sqnorm);
        const factor = 1.0 / len;
        return .{ .x = self.x * factor, .y = self.y * factor, .z = self.z * factor };
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
    pub fn dot(self: Self, rhs: Vec4) f32 {
        return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z + self.w * rhs.w;
    }
};

test "Vec3" {
    const v1 = Vec3.init(1, 2, 3);
    try std.testing.expectEqual(@as(f32, 14.0), v1.dot(v1));
    try std.testing.expectEqual(Vec3.init(2, 4, 6), v1.mul(2.0));
    try std.testing.expectEqual(Vec3.init(2, 4, 6), @"+"(v1, v1));
    try std.testing.expectEqual(Vec3.init(0, 0, 1), Vec3.init(1, 0, 0).cross(Vec3.init(0, 1, 0)));
    try std.testing.expectEqual(Vec3.init(1, 0, 0), Vec3.init(2, 0, 0).normalize());
}

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
        const norm = std.math.sqrt(sqnorm);
        const factor = 1 / norm;
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

test "Quaternion" {
    const q = Quaternion{};

    try std.testing.expectEqual(q, q.mul(q));
}

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
        return Self.rows(
            Vec3.init(c + a.x * a.x * (1 - c), a.x * a.y * (1 - c) - a.z * s, a.x * a.z * (1 - c) + a.y * s),
            Vec3.init(a.x * a.y * (1 - c) + a.z * s, c + a.y * a.y * (1 - c), a.y * a.z * (1 - c) - a.x * s),
            Vec3.init(a.x * a.z * (1 - c) - a.y * s, a.y * a.z * (1 - c) + a.x * s, c + a.z * a.z * (1 - c)),
        );
    }

    pub fn rotate(q: Quaternion) Mat3 {
        return Self.rows(
            Vec3.init(1 - 2 * q.y * q.y - 2 * q.z * q.z, 2 * q.x * q.y - 2 * q.w * q.z, 2 * q.z * q.x + 2 * q.w * q.y),
            Vec3.init(2 * q.x * q.y + 2 * q.w * q.z, 1 - 2 * q.z * q.z - 2 * q.x * q.x, 2 * q.y * q.z - 2 * q.w * q.x),
            Vec3.init(2 * q.z * q.x - 2 * q.w * q.y, 2 * q.y * q.z + 2 * q.w * q.x, 1 - 2 * q.x * q.x - 2 * q.y * q.y),
        );
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
};

test "Mat3" {
    const m = Mat3{};
    try std.testing.expectEqual(@as(f32, 1.0), m.det());
    const axis = Vec3.init(1, 2, 3).normalize();
    const angle = std.math.pi * 25.0 / 180.0;
    const q = Quaternion.angleAxis(angle, axis);
    try std.testing.expect(nearlyEqual(@as(f32, 1e-5), 9, Mat3.rotate(q).array(), Mat3.angleAxis(angle, axis).array()));
}

pub const Mat4 = struct {
    const Self = @This();

    // rows
    _0: Vec4 = .{ 1, 0, 0, 0 },
    _1: Vec4 = .{ 0, 1, 0, 0 },
    _2: Vec4 = .{ 0, 0, 1, 0 },
    _3: Vec4 = .{ 0, 0, 0, 1 },

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

    pub fn frustum(b: f32, t: f32, l: f32, r: f32, n: f32, f: f32) Self {
        // set OpenGL perspective projection matrix
        return Self.rows(
            Vec4.init(2 * n / (r - l), 0, (r + l) / (r - l), 0),
            Vec4.init(0, 2 * n / (t - b), (t + b) / (t - b), 0),
            Vec4.init(0, 0, -(f + n) / (f - n), -2 * f * n / (f - n)),
            Vec4.init(0, 0, -1, 0),
        );
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
        return Self.rows(
            Vec4.init(1, 0, 0, x),
            Vec4.init(0, 1, 0, y),
            Vec4.init(0, 0, 1, z),
            Vec4.init(0, 0, 0, 1),
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

test "Mat4" {}

pub fn @"+"(lhs: anytype, rhs: @TypeOf(lhs)) @TypeOf(lhs) {
    return lhs.add(rhs);
}
pub fn @"-"(lhs: anytype, rhs: @TypeOf(lhs)) @TypeOf(lhs) {
    return lhs.add(rhs.negative());
}
pub fn @"*"(lhs: anytype, rhs: @TypeOf(lhs)) @TypeOf(lhs) {
    return lhs.mul(rhs);
}
