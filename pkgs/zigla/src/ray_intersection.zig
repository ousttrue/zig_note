const std = @import("std");
const la = @import("./linear_algebra.zig");
const @"-" = la.@"-";
const @"+" = la.@"+";
const @"*" = la.@"*";

pub const Ray = struct {
    const Self = @This();

    origin: la.Vec3,
    dir: la.Vec3,

    pub fn createFromScreen(x: f32, y: f32, w: f32, h: f32, t: la.Vec3, r: la.Mat3, fov_y: f32, aspect: f32) Self {
        const half_fov = fov_y / 2.0;

        const xx = (x / w * 2 - 1);
        const yy = -(y / h * 2 - 1);
        // std.log.debug("({d:.2}, {d:.2}), ({d:.2}, {d:.2}), {d:.2}, {d:.2}", .{ x, y, w, h, xx, yy });

        var dir = @"*"(r, la.Vec3.init(
            xx * std.math.tan(half_fov) * (aspect),
            yy * std.math.tan(half_fov),
            -1,
        ));
        dir.normalize();

        // std.log.debug("({d:.2}, {d:.2}, {d:.2})", .{ dir.x, dir.y, dir.z });
        return .{ .origin = t, .dir = dir };
    }

    pub fn position(self: Self, t: f32) la.Vec3 {
        return @"+"(self.origin, self.dir.mul(t));
    }
};

pub const Plain = struct {
    const Self = @This();
    n: la.Vec3,
    d: f32,

    pub fn triangle(v0: la.Vec3, v1: la.Vec3, v2: la.Vec3) Plain {
        const n = (@"-"(v1, v0)).cross(@"-"(v2, v0)).normalized();
        const d = -n.dot(v0);
        return .{
            .n = n,
            .d = d,
        };
    }

    pub fn intersect(self: Self, ray: Ray) ?f32 {
        const l = la.Vec4.vec3(self.n, self.d);
        const lv = l.dot(la.Vec4.vec3(ray.dir, 0));
        if (std.math.fabs(lv) < 1e-5) {
            // parallel
            return null;
        }

        const lq = l.dot(la.Vec4.vec3(ray.origin, 1));
        const t = -lq / lv;
        return t;
    }
};

fn isFGSameSide(e: la.Vec2, f: la.Vec2, g: la.Vec2) bool {
    const n = la.Vec2.init(-e.y, e.x);
    return n.dot(f) * n.dot(g) >= 0;
}

fn isInside2D(p: la.Vec2, v0: la.Vec2, v1: la.Vec2, v2: la.Vec2) bool {
    // v0 origin
    if (!isFGSameSide(@"-"(v1, v0), @"-"(v2, v0), @"-"(p, v0))) return false;
    // v1 origin
    if (!isFGSameSide(@"-"(v2, v1), @"-"(v0, v1), @"-"(p, v1))) return false;
    // v2 origin
    if (!isFGSameSide(@"-"(v0, v2), @"-"(v1, v2), @"-"(p, v2))) return false;

    return true;
}

pub fn dropMaxAxis(n: la.Vec3, points: anytype) [@typeInfo(@TypeOf(points)).Array.len]la.Vec2 {
    var result: [@typeInfo(@TypeOf(points)).Array.len]la.Vec2 = undefined;
    if (n.x > n.y) {
        if (n.x > n.z) {
            // drop x
            for (points) |p, i| {
                result[i] = la.Vec2.init(p.y, p.z);
            }
        } else {
            // drop z
            for (points) |p, i| {
                result[i] = la.Vec2.init(p.x, p.y);
            }
        }
    } else {
        if (n.y > n.z) {
            // drop y
            for (points) |p, i| {
                result[i] = la.Vec2.init(p.x, p.z);
            }
        } else {
            // drop z
            for (points) |p, i| {
                result[i] = la.Vec2.init(p.x, p.y);
            }
        }
    }
    return result;
}

pub const Triangle = struct {
    const Self = @This();

    v0: la.Vec3,
    v1: la.Vec3,
    v2: la.Vec3,

    pub fn getPlain(self: Self) Plain {
        return Plain.triangle(self.v0, self.v1, self.v2);
    }

    pub fn intersect(self: Self, ray: Ray) ?f32 {
        const l = self.getPlain();
        const t = l.intersect(ray) orelse {
            return null;
        };

        const p = ray.position(t);

        const p2d = dropMaxAxis(l.n, [_]la.Vec3{ p, self.v0, self.v1, self.v2 });
        return if (isInside2D(p2d[0], p2d[1], p2d[2], p2d[3])) t else null;
    }
};
