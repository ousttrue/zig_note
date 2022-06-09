pub const ShapeState = enum(u32) {
    NONE = 0x00,
    HOVER = 0x01,
    SELECT = 0x02,
    DRAG = 0x04,
    HIDE = 0x08,
};



pub const Shape = struct {

    // def __init__(self, matrix: glm.mat4) -> None:
    //     self.matrix = EventProperty(matrix)
    //     self.state = EventProperty(ShapeState.NONE)
    //     self.index = -1

    pub fn addState(self: *Self, state: ShapeState) void {
        self.state.set(self.state.value | state);
    }

    // def remove_state(self, state: ShapeState):
    //     self.state.set(self.state.value & ~state)

    // @abc.abstractmethod
    // def get_quads(self) -> Iterable[Tuple[Quad, glm.vec4]]:
    //     raise NotImplementedError()

    // @abc.abstractmethod
    // def get_lines(self) -> Iterable[Tuple[glm.vec3, glm.vec3, glm.vec4]]:
    //     raise NotImplementedError()

    // def intersect(self, ray: Ray) -> Optional[float]:
    //     if self.state.value & ShapeState.HIDE:
    //         return

    //     to_local = glm.inverse(self.matrix.value)
    //     local_ray = Ray((to_local * glm.vec4(ray.origin, 1)).xyz,
    //                     (to_local * glm.vec4(ray.dir, 0)).xyz)
    //     hits = [quad.intersect(local_ray) for quad, color in self.get_quads()]
    //     hits = [hit for hit in hits if hit]
    //     if not hits:
    //         return None
    //     hits.sort()
    //     return hits[0]
};
