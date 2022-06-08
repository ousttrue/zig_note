const std = @import("std");
const la = @import("./linear_algebra.zig");

pub const Ray = struct {
    origin: la.Vec3,
    dir: la.Vec3,
};

pub const Triangle = struct {
    const Self = @This();

    v0: la.Vec3,
    v1: la.Vec3,
    v2: la.Vec3,

    pub fn intersect(self: Self, ray: Ray) ?f32 {
        _ = self;
        _ = ray;
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
