const std = @import("std");
const la = @import("./linear_algebra.zig");
const rigidbody = @import("./rigidbody_transformation.zig");
const ray_intersection = @import("./ray_intersection.zig");
const Ray = ray_intersection.Ray;
const Triangle = ray_intersection.Triangle;
const @"+" = la.@"+";
const @"*" = la.@"*";

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

    pub fn transform(self: Self, m: la.Mat4) Self {
        return Self{
            .t0 = self.t0.transform(m),
            .t1 = self.t1.transform(m),
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
    _,
};

pub const StateReference = struct {
    const Self = @This();

    state: [*]f32,
    stride: u32,
    count: u32,

    pub fn setState(self: *Self, fstate: ShapeState) void {
        const new_state = @intToFloat(f32, @enumToInt(fstate));
        var i: i32 = 0;
        var p = self.state;
        while (i < self.count) : ({
            i += 1;
            p += self.stride;
        }) {
            p.* = new_state;
        }
    }

    pub fn addState(self: *Self, state: ShapeState) void {
        const value = @floatToInt(u32, self.state[0]) | @enumToInt(state);
        const new_state = @intToEnum(ShapeState, value);
        self.setState(new_state);
    }

    pub fn removeState(self: *Self, state: ShapeState) void {
        const new_state = @intToEnum(ShapeState, @floatToInt(u32, self.state[0]) & ~@enumToInt(state));
        self.setState(new_state);
    }

    pub fn hasState(self: Self, state: ShapeState) bool {
        return (@floatToInt(u32, self.state[0]) & @enumToInt(state)) != 0;
    }
};

pub const Shape = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    quads: []const Quad,
    matrix: *la.Mat4,
    state: StateReference,

    pub fn init(allocator: std.mem.Allocator, quads: []const Quad, pMatrix: *la.Mat4, state: StateReference) Self {
        var self = Self{
            .allocator = allocator,
            .quads = allocator.dupe(Quad, quads) catch @panic("dupe"),
            .matrix = pMatrix,
            .state = state,
        };
        return self;
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.quads);
    }

    pub fn setPosition(self: *Self, p: la.Vec3) void {
        self.matrix._3 = la.Vec4.vec3(p, 1);
    }

    pub fn localRay(self: Self, ray: Ray) Ray {
        var rb = rigidbody.RigidBodyTransformation.mat4(self.matrix.*);
        rb = rb.inversed();
        return Ray{
            .origin = rb.transform(ray.origin),
            .dir = rb.rotation.rotate(ray.dir),
        };
    }

    pub fn intersect(self: *const Self, ray: Ray) ?f32 {
        if (self.state.hasState(ShapeState.HIDE)) {
            return null;
        }

        var closest: ?f32 = null;

        const local_ray = self.localRay(ray);
        for (self.quads) |quad| {
            if (quad.intersect(local_ray)) |hit| {
                closest = if (closest) |closest_hit|
                    if (hit < closest_hit) hit else closest_hit
                else
                    hit;
            }
        }
        // for (self.quads) |quad_origin| {
        //     const quad = quad_origin.transform(self.matrix.*);
        //     if (quad.intersect(ray)) |hit| {
        //         closest = if (closest) |closest_hit|
        //             if (hit < closest_hit) hit else closest_hit
        //         else
        //             hit;
        //     }
        // }

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
pub fn createCube(width: f32, height: f32, depth: f32) [6]Quad {
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
    return .{
        Quad.from_points(v0, v1, v2, v3),
        Quad.from_points(v3, v2, v6, v7),
        Quad.from_points(v7, v6, v5, v4),
        Quad.from_points(v4, v5, v1, v0),
        Quad.from_points(v4, v0, v3, v7),
        Quad.from_points(v1, v5, v6, v2),
    };
}

test "Shape" {
    const allocator = std.testing.allocator;
    const quads = createCube(allocator, 2, 4, 6);
    defer allocator.free(quads);
    var m = la.Mat4{};
    var s: [1]f32 = .{0};
    var state = StateReference{
        .state = &s,
        .count = 1,
        .stride = 0,
    };
    const cube = Shape.init(quads, &m, state);

    const ray = Ray{
        .origin = la.Vec3.init(0, 0, 5),
        .dir = la.Vec3.init(0, 0, -1),
    };

    const localRay = cube.localRay(ray);
    try std.testing.expectEqual(la.Vec3.init(0, 0, 5), localRay.origin);
    try std.testing.expectEqual(la.Vec3.init(0, 0, -1), localRay.dir);

    const t = cube.intersect(ray);
    try std.testing.expectEqual(@as(f32, 2.0), t.?);
}
