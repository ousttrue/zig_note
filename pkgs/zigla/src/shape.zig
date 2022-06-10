const la = @import("./linear_algebra.zig");
const rigidbody = @import("./rigidbody_transformation.zig");
const ray_intersection = @import("./ray_intersection.zig");

pub const ShapeState = enum(u32) {
    NONE = 0x00,
    HOVER = 0x01,
    SELECT = 0x02,
    DRAG = 0x04,
    HIDE = 0x08,
};

pub const Shape = struct {
    transformation: rigidbody.RigidBodyTransformation = .{},
    s: la.Vec3 = la.Vec3.scalar(1),
    state: ShapeState = .NONE,

    pub fn addState(self: *Self, state: ShapeState) void {
        self.state |= state;
    }

    pub fn removeState(self: *Self, state: ShapeState) void {
        self.state &= ~state;
    }

    // def get_quads(self) -> Iterable[Tuple[Quad, glm.vec4]]:
    //     raise NotImplementedError()

    // @abc.abstractmethod
    // def get_lines(self) -> Iterable[Tuple[glm.vec3, glm.vec3, glm.vec4]]:
    //     raise NotImplementedError()

    pub fn intersect(self: Self, ray: Ray) ?f32 {
        if (self.state.value & ShapeState.HIDE) {
            return null;
        }

        const to_local = self.transformation.inverse();
        // local_ray = Ray((to_local * glm.vec4(ray.origin, 1)).xyz,
        //                 (to_local * glm.vec4(ray.dir, 0)).xyz)
        // hits = [quad.intersect(local_ray) for quad, color in self.get_quads()]
        // hits = [hit for hit in hits if hit]
        // if not hits:
        //     return None
        // hits.sort()
        // return hits[0]
        unrechable;
    }
};
