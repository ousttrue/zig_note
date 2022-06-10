const std = @import("std");
const la = @import("./linear_algebra.zig");
const rigidbody = @import("./rigidbody_transformation.zig");
const ray_intersection = @import("./ray_intersection.zig");
const Ray = ray_intersection.Ray;
const Triangle = ray_intersection.Triangle;

pub const Quad = struct {
    const Self = @This();

    t0: Triangle,
    t1: Triangle,

    pub fn from_points(v0: la.Vec3, v1: la.Vec3, v2: la.Vec3, v3: la.Vec3) Self {
        return Self{
            .t0 = Triangle{ .v0 = v0, .v1 = v1, .v2 = v2 },
            .t1 = Triangle{ .v0 = v2, .v1 = v3, .v2 = v0 },
        };
    }

    pub fn intersect(self: Self, ray: Ray) ?f32 {
        if (self.t0.intersect(ray)) |h0| {
            if (self.t1.intersect(ray)) |h1| {
                return if (h0 < h1) h0 else h1;
            } else {
                return h0;
            }
        } else {
            return self.t1.intersect(ray);
        }
    }
};

pub const ShapeState = enum(u32) {
    NONE = 0x00,
    HOVER = 0x01,
    SELECT = 0x02,
    DRAG = 0x04,
    HIDE = 0x08,
};

pub const Shape = struct {
    const Self = @This();

    transformation: rigidbody.RigidBodyTransformation = .{},
    s: la.Vec3 = la.Vec3.scalar(1),
    state: ShapeState = .NONE,
    allocator: std.mem.Allocator,
    quads: []const Quad,

    pub fn init(allocator: std.mem.Allocator, quads: []const Quad) Self {
        return .{
            .allocator = allocator,
            .quads = allocator.dupe(Quad, quads) catch @panic("dupe"),
        };
    }

    pub fn deinit(self: *const Self) void {
        self.allocator.free(self.quads);
    }

    pub fn addState(self: *Self, state: ShapeState) void {
        self.state |= state;
    }

    pub fn removeState(self: *Self, state: ShapeState) void {
        self.state &= ~state;
    }

    pub fn localRay(self: Self, ray: Ray) Ray {
        const to_local = self.transformation.inverse();
        return Ray{
            .origin = to_local.transform(ray.origin),
            .dir = to_local.rotation.rotate(ray.dir),
        };
    }

    pub fn intersect(self: Self, ray: Ray) ?f32 {
        if ((@enumToInt(self.state) & @enumToInt(ShapeState.HIDE)) != 0) {
            return null;
        }

        const local_ray = self.localRay(ray);

        var closest: ?f32 = null;
        for (self.quads) |quad| {
            if (quad.intersect(local_ray)) |hit| {
                closest = if (closest) |closest_hit|
                    if (hit < closest_hit) hit else closest_hit
                else
                    hit;
            }
        }
        return closest;
    }
};

/// height
/// A
///     4 7
/// 0 3+-+    depth
/// +-+| |   /
/// | |+-+  /
/// +-+5 6 /
/// 1 2   /
/// --------> width
pub fn createCube(allocator: std.mem.Allocator, width: f32, height: f32, depth: f32) Shape {
    const x = width / 2;
    const y = height / 2;
    const z = depth / 2;
    const v0 = la.Vec3.init(-x, y, z);
    const v1 = la.Vec3.init(-x, -y, z);
    const v2 = la.Vec3.init(x, -y, z);
    const v3 = la.Vec3.init(x, y, z);
    const v4 = la.Vec3.init(-x, y, -z);
    const v5 = la.Vec3.init(-x, -y, -z);
    const v6 = la.Vec3.init(x, -y, -z);
    const v7 = la.Vec3.init(x, y, -z);
    return Shape.init(allocator, &.{
        Quad.from_points(v0, v1, v2, v3),
        Quad.from_points(v3, v2, v6, v7),
        Quad.from_points(v7, v6, v5, v4),
        Quad.from_points(v4, v5, v1, v0),
        Quad.from_points(v4, v0, v3, v7),
        Quad.from_points(v1, v5, v6, v2),
    });
}
