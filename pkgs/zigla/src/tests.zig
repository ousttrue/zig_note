const std = @import("std");
const la = @import("./linear_algebra.zig");
const rigidbody = @import("./rigidbody_transformation.zig");
pub const @"*" = la.@"*";
pub const @"+" = la.@"+";
pub const Vec3 = la.Vec3;
pub const Vec4 = la.Vec4;
pub const Quaternion = la.Quaternion;
pub const Mat3 = la.Mat3;
pub const Mat4 = la.Mat4;
const ray_intersection = @import("./ray_intersection.zig");
pub const Ray = ray_intersection.Ray;
pub const Triangle = ray_intersection.Triangle;
pub const quad = @import("./quad.zig");

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

test "vdot" {
    const v1234: [4]f32 = .{ 1, 2, 3, 4 };
    try std.testing.expectEqual(@as(f32, 30.0), la.vdot4(v1234, v1234));
    const v123 = [_]f32{ 1, 2, 3 };
    try std.testing.expectEqual(@as(f32, 14.0), la.vdot3(v123, v123));
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

test "Mat4" {}

test "ray triangle" {
    const ray = Ray{
        .origin = Vec3.init(0, 0, -1),
        .dir = Vec3.init(0, 0, 1),
    };

    const t = Triangle{
        .v0 = Vec3.init(-1, -1, 0),
        .v1 = Vec3.init(1, -1, 0),
        .v2 = Vec3.init(0, 1, 0),
    };

    try std.testing.expectEqual(@as(f32, 1.0), t.intersect(ray).?);

    const rayOut = Ray{
        .origin = Vec3.init(10, 0, -1),
        .dir = Vec3.init(0, 0, 1),
    };

    std.testing.log_level = std.log.Level.debug;
    try std.testing.expect(t.intersect(rayOut) == null);
}

test "RigidBody" {
    const q = Quaternion.angleAxis(std.math.pi / 2.0, Vec3.init(1, 0, 0));
    const t = Vec3.init(0, 0, 1);
    const rb = rigidbody.RigidBodyTransformation{ .rotation = q, .translation = t };
    const inv = rb.inverse();
    try std.testing.expect(nearlyEqual(@as(f32, 1e-5), 3, Vec3.init(0, -1, 0).array(), inv.translation.const_array()));
}

test "Shape" {
    const allocator = std.testing.allocator;
    const cube = quad.createCube(allocator, 2, 3, 4);

    const ray = Ray{
        .origin = Vec3.init(0, 0, 5),
        .dir = Vec3.init(0, 0, -1),
    };

    const t = cube.intersect(ray);
    try std.testing.expectEqual(@as(f32, 3.0), t.?);
}
