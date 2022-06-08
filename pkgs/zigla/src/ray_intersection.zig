const std = @import("std");
const la = @import("./linear_algebra.zig");
const @"-" = la.@"-";
const @"+" = la.@"+";

pub const Ray = struct {
    const Self = @This();

    origin: la.Vec3,
    dir: la.Vec3,

    pub fn position(self: Self, t: f32) la.Vec3 {
        return @"+"(self.origin, self.dir.mul(t));
    }
};

fn isFGSameSide(e: la.Vec2, f: la.Vec2, g: la.Vec2) bool {
    const n = la.Vec2.init(-e.y, e.x);
    return n.dot(f) * n.dot(g) > 0;
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

pub const Triangle = struct {
    const Self = @This();

    v0: la.Vec3,
    v1: la.Vec3,
    v2: la.Vec3,

    pub fn intersect(self: Self, ray: Ray) ?f32 {
        const n = (@"-"(self.v1, self.v0)).cross(@"-"(self.v2, self.v0)).normalized();
        const d = -n.dot(self.v0);

        const l = la.Vec4.vec3(n, d);
        const lv = l.dot(la.Vec4.vec3(ray.dir, 0));
        if (lv < 1e-5) {
            // parallel
            return null;
        }

        const lq = l.dot(la.Vec4.vec3(ray.origin, 1));
        const t = -lq / lv;
        const p = ray.position(t);

        if (p.x > p.y) {
            if (p.x > p.z) {
                // drop x
                const v0 = la.Vec2.init(self.v0.y, self.v0.z);
                const v1 = la.Vec2.init(self.v1.y, self.v1.z);
                const v2 = la.Vec2.init(self.v2.y, self.v2.z);
                const pp = la.Vec2.init(p.y, p.z);
                if (isInside2D(pp, v0, v1, v2)) {
                    return t;
                }
            } else {
                // drop z
                const v0 = la.Vec2.init(self.v0.x, self.v0.y);
                const v1 = la.Vec2.init(self.v1.x, self.v1.y);
                const v2 = la.Vec2.init(self.v2.x, self.v2.y);
                const pp = la.Vec2.init(p.x, p.y);
                if (isInside2D(pp, v0, v1, v2)) {
                    return t;
                }
            }
        } else {
            if (p.y > p.z) {
                // drop y
                const v0 = la.Vec2.init(self.v0.x, self.v0.z);
                const v1 = la.Vec2.init(self.v1.x, self.v1.z);
                const v2 = la.Vec2.init(self.v2.x, self.v2.z);
                const pp = la.Vec2.init(p.x, p.z);
                if (isInside2D(pp, v0, v1, v2)) {
                    return t;
                }
            } else {
                // drop z
                const v0 = la.Vec2.init(self.v0.x, self.v0.y);
                const v1 = la.Vec2.init(self.v1.x, self.v1.y);
                const v2 = la.Vec2.init(self.v2.x, self.v2.y);
                const pp = la.Vec2.init(p.x, p.y);
                if (isInside2D(pp, v0, v1, v2)) {
                    return t;
                }
            }
        }

        return null;
    }
};

// class Quad(NamedTuple):
//     t0: Triangle
//     t1: Triangle

//     @staticmethod
//     def from_points(v0: zigla.Vec3, v1: zigla.Vec3, v2: zigla.Vec3, v3: zigla.Vec3) -> 'Quad':
//         return Quad(
//             Triangle(v0, v1, v2),
//             Triangle(v2, v3, v0)
//         )

//     def intersect(self, ray: Ray) -> Optional[float]:
//         h0 = self.t0.intersect(ray)
//         if h0:
//             h1 = self.t1.intersect(ray)
//             if h1:
//                 if h0 < h1:
//                     return h0
//                 else:
//                     return h1
//             else:
//                 return h0
//         else:
//             return self.t1.intersect(ray)
