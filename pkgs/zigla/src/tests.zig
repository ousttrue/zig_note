const std = @import("std");
const la = @import("./linear_algebra.zig");
const rigidbody = @import("./rigidbody_transformation.zig");
pub const @"*" = la.@"*";
pub const @"+" = la.@"+";
pub const Vec2 = la.Vec2;
pub const Vec3 = la.Vec3;
pub const Vec4 = la.Vec4;
pub const Quaternion = la.Quaternion;
pub const Mat3 = la.Mat3;
pub const Mat4 = la.Mat4;
const ray_intersection = @import("./ray_intersection.zig");
pub const Ray = ray_intersection.Ray;
pub const Triangle = ray_intersection.Triangle;
pub const quad_shape = @import("./quad_shape.zig");
pub const camera = @import("./camera.zig");

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
}

test "ray not hit" {
    const ray = Ray{
        .origin = Vec3.init(10, 0, -1),
        .dir = Vec3.init(0, 0, 1),
    };
    const p0 = ray.position(3);
    try std.testing.expectEqual(Vec3.init(10, 0, 2), p0);

    const tri = Triangle{
        .v0 = Vec3.init(-1, -1, 0),
        .v1 = Vec3.init(1, -1, 0),
        .v2 = Vec3.init(0, 1, 0),
    };
    const l = tri.getPlain();
    const t = l.intersect(ray).?;
    try std.testing.expectEqual(@as(f32, 1), t);
    const p = ray.position(t);
    try std.testing.expectEqual(Vec3.init(10, 0, 0), p);
    const p2d = ray_intersection.dropMaxAxis(l.n, [_]la.Vec3{ p, tri.v0, tri.v1, tri.v2 });
    try std.testing.expectEqual(Vec2.init(10, 0), p2d[0]);
    try std.testing.expectEqual(Vec2.init(-1, -1), p2d[1]);
    try std.testing.expectEqual(Vec2.init(1, -1), p2d[2]);
    try std.testing.expectEqual(Vec2.init(0, 1), p2d[3]);
    try std.testing.expect(tri.intersect(ray) == null);
}

test "ray negative" {
    const t = Triangle{
        .v0 = Vec3.init(-1, -1, 0),
        .v1 = Vec3.init(1, -1, 0),
        .v2 = Vec3.init(0, 1, 0),
    };
    const l = t.getPlain();
    const ray = Ray{
        .origin = Vec3.init(0, 0, 1),
        .dir = Vec3.init(0, 0, -1),
    };

    try std.testing.expectEqual(@as(f32, 1.0), l.intersect(ray).?);
    try std.testing.expectEqual(@as(f32, 1.0), t.intersect(ray).?);
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
    const quads = quad_shape.createCube(allocator, 2, 4, 6);
    defer allocator.free(quads);
    var m = Mat4{};
    var s: [1]f32 = .{0};
    var state = quad_shape.StateReference{
        .state = &s,
        .count = 1,
        .stride = 0,
    };
    const cube = quad_shape.Shape.init(quads, &m, state);

    const ray = Ray{
        .origin = Vec3.init(0, 0, 5),
        .dir = Vec3.init(0, 0, -1),
    };

    const localRay = cube.localRay(ray);
    try std.testing.expectEqual(Vec3.init(0, 0, 5), localRay.origin);
    try std.testing.expectEqual(Vec3.init(0, 0, -1), localRay.dir);

    const q0 = quad_shape.Quad.from_points(Vec3.init(-1, 2, 3), Vec3.init(-1, -2, 3), Vec3.init(1, -2, 3), Vec3.init(1, 2, 3));
    try std.testing.expectEqual(q0, cube.quads[0]);
    try std.testing.expectEqual(@as(f32, 2.0), q0.t0.getPlain().intersect(ray).?);

    try std.testing.expectEqual(@as(f32, 2.0), cube.quads[0].intersect(ray).?);

    const t = cube.intersect(ray);
    try std.testing.expectEqual(@as(f32, 2.0), t.?);
}

test "Camera" {
    var c = camera.Camera{};
    c.projection.resize(2, 2);

    const m = c.view.getTransformMatrix();
    try std.testing.expectEqual(Vec4.init(0, 0, 5, 1), m._3);

    const ray = c.getRay(1, 1);
    try std.testing.expectEqual(Vec3.init(0, 0, 5), ray.origin);
    try std.testing.expectEqual(Vec3.init(0, 0, -1), ray.dir);


    const allocator = std.testing.allocator;
    const quads = quad_shape.createCube(allocator, 2, 4, 6);
    defer allocator.free(quads);
    var mat = Mat4{};
    var s: [1]f32 = .{0};
    var state = quad_shape.StateReference{
        .state = &s,
        .count = 1,
        .stride = 0,
    };
    const cube = quad_shape.Shape.init(quads, &mat, state);

    const localRay = cube.localRay(ray);
    try std.testing.expectEqual(Vec3.init(0, 0, 5), localRay.origin);
    try std.testing.expectEqual(Vec3.init(0, 0, -1), localRay.dir);
}
