const std = @import("std");
const zigla = @import("zigla");
const quad_shape = zigla.quad_shape;
const scene = @import("scene");
const glo = @import("glo");
const @"-" = zigla.@"-";

const VS = @embedFile("gizmo.vs");
const FS = @embedFile("gizmo.fs");

const white = zigla.Vec4(1, 1, 1, 1);

pub const Vertex = struct {
    position: zigla.Vec3,
    bone: f32,
    color: zigla.Vec4,
    normal: zigla.Vec3,
    state: f32 = 0,
};

pub const GizmoVertexBuffer = struct {
    const Self = @This();

    allocator: std.mem.Allocator,

    vertex_count: u16 = 0,
    vertices: [65535]Vertex = undefined,
    index_count: u32 = 0,
    indices: [65535]u16 = undefined,
    bone_vertex_map: std.AutoHashMap(i32, std.ArrayList(usize)),
    skin: [200]zigla.Mat4 = undefined,

    shader: ?glo.Shader = null,

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .allocator = allocator,
            .bone_vertex_map = std.AutoHashMap(i32, std.ArrayList(usize)).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.bone_vertex_map.deinit();
    }

    pub fn addVertex(self: *Vertex, bone: i32, position: zigla.Vec3, normal: zigla.Vec3, color: zigla.Vec4) u16 {
        const i = self.vertex_count;
        self.vertex_count += 1;
        self.vertices[i] = Vertex{
            .position = position,
            .bone = bone,
            .color = color,
            .normal = normal,
        };

        var entry = self.bone_vertex_map.getOrPut(bone) catch @panic("getOrPut");
        if (!entry.found_existing) {
            entry.value_ptr = self.allocator.create(std.ArrayList(usize)) catch @panic("create");
            entry.value_ptr.* = std.ArrayList(usize).init(self.allocator);
        }
        entry.value_ptr.*.append(i) catch @panic("append");

        return i;
    }

    /// ccw
    pub fn addTriangle(self: *Self, bone: i32, t: zigla.ray_intersection.Triangle, color: zigla.Vec4) void {
        const v01 = @"-"(t.v1, t.v0);
        const v02 = @"-"(t.v2, t.v0);
        const n = v01.cross(v02).normalized();
        const index0 = self.addVertex(bone, t.v0, n, color);
        const index1 = self.addVertex(bone, t.v1, n, color);
        const index2 = self.addVertex(bone, t.v2, n, color);
        self.indices[self.index_count] = index0;
        self.index_count += 1;
        self.indices[self.index_count] = index1;
        self.index_count += 1;
        self.indices[self.index_count] = index2;
        self.index_count += 1;
    }

    pub fn addQuad(self: *Self, bone: i32, quad: quad_shape.Quad, color: zigla.Vec4) void {
        self.addTriangle(bone, quad.t0, color);
        self.addTriangle(bone, quad.t1, color);
    }

    pub fn addShape(self: *Self, bone: i32, shape: quad_shape.Shape) void {
        for (shape.quads) |quad| {
            self.addQuad(bone, quad, white);
        }
    }

    pub fn render(self: Self, camera: scene.Camera) void {
        _ = camera;
        if (self.shader == null) {
            var error_buffer = [1024]u8;
            var shader = glo.Shader.init(self.allocator);
            if (shader.load(error_buffer, VS, FS)) |message| {
                std.log.err("{s}", message);
                @panic("Shader.load");
            }
            self.shader = shader;

            //         # uVP
            //         vp = glo.UniformLocation.create(self.shader.program, "uVP")

            //         def set_vp():
            //             vp.set_mat4(glm.value_ptr(self.view_projection))
            //         self.props.append(set_vp)

            //         # uBoneMatrices
            //         skin = glo.UniformLocation.create(
            //             self.shader.program, "uBoneMatrices")

            //         def set_skin():
            //             skin.set_mat4(self.skin.ptr, count=len(self.skin))
            //         self.props.append(set_skin)

            //         # vao
            //         vertex_layout = glo.VertexLayout.create_list(self.shader.program)
            //         vbo = glo.Vbo()
            //         vbo.set_vertices(self.vertices, is_dynamic=True)
            //         ibo = glo.Ibo()
            //         ibo.set_indices(self.indices, is_dynamic=True)
            //         self.triangle_vao = glo.Vao(
            //             vbo, vertex_layout, ibo)

            //         line_vbo = glo.Vbo()
            //         line_vbo.set_vertices(self.line_vertices, is_dynamic=True)
            //         self.line_vao = glo.Vao(
            //             line_vbo, vertex_layout)
        } else {
            //         assert self.triangle_vao
            //         self.triangle_vao.vbo.update(self.vertices)
            //         assert self.triangle_vao.ibo
            //         self.triangle_vao.ibo.update(self.indices)
            //         assert self.line_vao
            //         self.line_vao.vbo.update(self.line_vertices)
        }

        //     self.view_projection = camera.projection.matrix * camera.view.matrix

        //     assert self.triangle_vao

        //     with self.shader:
        //         for prop in self.props:
        //             prop()
        //         GL.glEnable(GL.GL_DEPTH_TEST)
        //         GL.glEnable(GL.GL_CULL_FACE)
        //         self.triangle_vao.draw(
        //             self.index_count, topology=GL.GL_TRIANGLES)
        //         self.line_vao.draw(
        //             self.line_count, topology=GL.GL_LINES)
    }
};
