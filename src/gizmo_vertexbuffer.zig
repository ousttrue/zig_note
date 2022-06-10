const std = @import("std");
const zigla = @import("zigla");
const quad = zigla.quad;
const @"-" = zigla.@"-";

// from typing import Optional, Dict, List
// import logging
// import ctypes
// import glm
// from pydear import glo
// from pydear.scene.camera import Camera
// from .shader_vertex import Vertex, SHADER
// from .primitive import Triangle, Quad
// from .shapes.shape import Shape
// from OpenGL import GL

// LOGGER = logging.getLogger(__name__)

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

    line_vertices: [65535]Vertex = undefined,
    line_count: u16 = 0,
    bone_line_map: std.AutoHashMap(i32, std.ArrayList(usize)),

    skin: [200]zigla.Mat4 = undefined,

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .allocator = allocator,
            .bone_vertex_map = std.AutoHashMap(i32, std.ArrayList(usize)).init(allocator),
            .bone_line_map = std.AutoHashMap(i32, std.ArrayList(usize)).init(allocator),
        };
    }

    // def __init__(self) -> None:
    //     self.shader: Optional[glo.Shader] = None
    //     self.props = []
    //     self.view_projection = glm.mat4()
    //     self.triangle_vao: Optional[glo.Vao] = None

    pub fn deinit(self: *Self) void {
        self.bone_vertex_map.deinit();
    }

    pub fn addLineVertex(self: *Self, bone: i32, position: zigla.Vec3, color: zigla.Vec4) u16 {
        const i = self.line_count;
        self.line_count += 1;
        self.line_vertices[i] = Vertex{
            .position = position,
            .bone = bone,
            .color = color,
            .normal = zigla.Vec3.init(1, 1, 1),
        };

        var entry = self.bone_line_map.getOrPut(bone) catch @panic("getOrPut");
        if (!entry.found_existing) {
            entry.value_ptr = self.allocator.create(std.ArrayList(usize)) catch @panic("create");
            entry.value_ptr.* = std.ArrayList(usize).init(self.allocator);
        }
        entry.value_ptr.*.append(i) catch @panic("append");
        return i;
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

    pub fn addQuad(self: *Self, bone: i32, quad: zigla.ray_intersection.Quad, color: zigla.Vec4) void {
        self.addTriangle(bone, quad.t0, color);
        self.addTriangle(bone, quad.t1, color);
    }

    // pub fn addLine(self: *Self, bone: i32, v0: zigla.Vec3, v1: zigla.Vec3, color: zigla.Vec4) void {
    //     _ = self.add_line_vertex(bone, v0, color);
    //     _ = self.add_line_vertex(bone, v1, color);
    // }

    pub fn addShape(self: *Self, bone: i32, shape: zigla.quad.Shape) void
    {
        for(shape.quads)|quad|{
            self.addQuad(bone, quad, white);
        }

        // def on_matrix(m):
        //     self.skin[bone] = m
        // shape.matrix += on_matrix
        // self.skin[bone] = shape.matrix.value
        // # bind state
        // def on_state(state):
        //     indices = self.bone_vertex_map[shape.index]
        //     for i in indices:
        //         v = self.vertices[i]
        //         v.state = state.value
        // shape.state += on_state
    }

    // def render(self, camera: Camera):
    //     if not self.shader:
    //         # shader
    //         shader_or_error = glo.Shader.load_from_pkg("pydear", SHADER)
    //         if not isinstance(shader_or_error, glo.Shader):
    //             LOGGER.error(shader_or_error)
    //             raise Exception()
    //         self.shader = shader_or_error

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
    //     else:
    //         assert self.triangle_vao
    //         self.triangle_vao.vbo.update(self.vertices)
    //         assert self.triangle_vao.ibo
    //         self.triangle_vao.ibo.update(self.indices)
    //         assert self.line_vao
    //         self.line_vao.vbo.update(self.line_vertices)

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
};
