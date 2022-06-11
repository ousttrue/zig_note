const std = @import("std");
const zigla = @import("zigla");
const quad_shape = zigla.quad_shape;
const scene = @import("scene");
const glo = @import("glo");
const gl = @import("gl");
const @"-" = zigla.@"-";

const VS = @embedFile("gizmo.vs");
const FS = @embedFile("gizmo.fs");

const white = zigla.Vec4.init(1, 1, 1, 1);

pub const Vertex = struct {
    position: zigla.Vec3,
    joint: f32,
    color: zigla.Vec4,
    normal: zigla.Vec3,
    state: f32 = 0,
};

const Material = struct {
    const Self = @This();

    shader: glo.Shader,

    uVP: glo.UniformLocation,
    uBoneMatrices: glo.UniformLocation,

    pub fn init(shader: glo.Shader) Self {
        const uVP = glo.UniformLocation.init(shader.handle, "uVP");
        const uBoneMatrices = glo.UniformLocation.init(shader.handle, "uBoneMatrices");
        var self = Self{
            .shader = shader,
            .uVP = uVP,
            .uBoneMatrices = uBoneMatrices,
        };
        return self;
    }

    pub fn deinit(self: *Self) void {
        self.shader.deinit();
    }
};

pub const GizmoVertexBuffer = struct {
    const Self = @This();

    allocator: std.mem.Allocator,

    vertex_count: u16 = 0,
    vertices: [65535]Vertex = undefined,
    index_count: u32 = 0,
    indices: [65535]u16 = undefined,
    bone_vertex_map: std.AutoHashMap(u32, std.ArrayList(usize)),
    skin: [200]zigla.Mat4 = undefined,

    vao: ?glo.Vao = null,
    material: ?Material = null,

    pub fn init(allocator: std.mem.Allocator) Self {
        var self = Self{
            .allocator = allocator,
            .bone_vertex_map = std.AutoHashMap(u32, std.ArrayList(usize)).init(allocator),
        };

        self.skin[0] = .{};

        return self;
    }

    pub fn deinit(self: *Self) void {
        self.material.deinit();
        self.bone_vertex_map.deinit();
    }

    pub fn addVertex(self: *Self, joint: u32, position: zigla.Vec3, normal: zigla.Vec3, color: zigla.Vec4) u16 {
        const i = self.vertex_count;
        self.vertex_count += 1;
        self.vertices[i] = Vertex{
            .position = position,
            .joint = @intToFloat(f32, joint),
            .color = color,
            .normal = normal,
        };

        var entry = self.bone_vertex_map.getOrPut(joint) catch @panic("getOrPut");
        if (!entry.found_existing) {
            // entry.value_ptr = self.allocator.create(std.ArrayList(usize)) catch @panic("create");
            entry.value_ptr.* = std.ArrayList(usize).init(self.allocator);
        }
        entry.value_ptr.append(i) catch @panic("append");

        return i;
    }

    /// ccw
    pub fn addTriangle(self: *Self, joint: u32, t: zigla.ray_intersection.Triangle, color: zigla.Vec4) void {
        const v01 = @"-"(t.v1, t.v0);
        const v02 = @"-"(t.v2, t.v0);
        const n = v01.cross(v02).normalized();
        const index0 = self.addVertex(joint, t.v0, n, color);
        const index1 = self.addVertex(joint, t.v1, n, color);
        const index2 = self.addVertex(joint, t.v2, n, color);
        self.indices[self.index_count] = index0;
        self.index_count += 1;
        self.indices[self.index_count] = index1;
        self.index_count += 1;
        self.indices[self.index_count] = index2;
        self.index_count += 1;
    }

    pub fn addQuad(self: *Self, joint: u32, quad: quad_shape.Quad, color: zigla.Vec4) void {
        self.addTriangle(joint, quad.t0, color);
        self.addTriangle(joint, quad.t1, color);
    }

    pub fn addShape(self: *Self, joint: u32, shape: quad_shape.Shape) void {
        for (shape.quads) |quad| {
            self.addQuad(joint, quad, white);
        }
    }

    pub fn render(self: *Self, camera: scene.Camera) void {
        _ = camera;
        if (self.material == null) {
            var shader = glo.Shader.load(self.allocator, VS, FS) catch {
                @panic(glo.getErrorMessage());
            };
            self.material = Material.init(shader);

            // vao
            const vertex_layout = shader.createVertexLayout(self.allocator);
            _ = vertex_layout;
            var vbo = glo.Vbo.init();
            vbo.setVertices(self.vertices, true);
            var ibo = glo.Ibo.init();
            ibo.setIndices(self.indices, true);
            self.vao = glo.Vao.init(vbo, vertex_layout, ibo);
        } else {
            //         assert self.triangle_vao
            //         self.triangle_vao.vbo.update(self.vertices)
            //         assert self.triangle_vao.ibo
            //         self.triangle_vao.ibo.update(self.indices)
            //         assert self.line_vao
            //         self.line_vao.vbo.update(self.line_vertices)
        }

        if (self.material) |material| {
            material.shader.use();
            defer material.shader.unuse();

            // update uniforms
            const m = camera.getMatrix();
            material.uVP.setMat4(&m._0.x, .{});

            material.uBoneMatrices.setMat4(&self.skin[0]._0.x, .{});

            gl.enable(gl.DEPTH_TEST);
            gl.enable(gl.CULL_FACE);

            if (self.vao) |vao| {
                vao.draw(self.index_count, .{});
            }
        }
    }
};
