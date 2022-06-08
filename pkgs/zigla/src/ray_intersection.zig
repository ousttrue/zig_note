const std = @import("std");
const la = @import("./linear_algebra.zig");
const @"-" = la.@"-";

pub const Ray = struct {
    const Self = @This();

    origin: la.Vec3,
    dir: la.Vec3,

    pub fn position(self: Self, t: f32) la.Vec3 {
        return @"+"(origin, dir.mul(t));
    }
};

fn insinde2Dimension(v0, v1, v2, p)
{
    const e = v1 - v0;
    const f=  v2 - v0;
    const g = p - v0;
    const n = {-e.y, e.x};
    return n.dot(f) * n.dot(g) > 0;
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
        } else {
            const lq = l.dot(la.Vec4.vec3(ray.origin, 1));
            const t = -lq / lv;
            const p = ray.position(t);

            if(p.x>p.y){
                if(p.x>p.z)
                {
                    // x
                }
                else{
                    // z
                }
            }
            else{
                if(p.y>p.z)
                {
                    // y
                }
                else{
                    // z
                }
            }

            if (!isinside(v0, v1, v2, p)) return null;
            if (!isinside(v1, v2, v0, p)) return null;
            if (!isinside(v2, v0, v1, p)) return null;

            return t;
        }
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
