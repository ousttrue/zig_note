const std = @import("std");
const zigla = @import("zigla");
const glo = @import("glo");
const gltf = @import("./gltf.zig");
const vs = @embedFile("./mvp.vs");
const fs = @embedFile("./mvp.fs");
const scene_loader = @import("./scene_loader.zig");

pub const Scene = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    shader: ?glo.Shader = null,
    vao: ?glo.Vao = null,
    draw_count: u32 = 0,

    loader: ?scene_loader.Loader = null,
    light: zigla.Vec4 = zigla.Vec4.init(1, 2, 3, 0).normalized(),

    pub fn new(allocator: std.mem.Allocator) *Self {
        var scene = allocator.create(Scene) catch @panic("create");

        scene.* = Scene{
            .allocator = allocator,
        };
        scene.loader = scene_loader.Loader.create(scene_loader.Triangle.new(allocator));

        return scene;
    }

    pub fn delete(self: *Self) void {
        self.allocator.destroy(self);
    }

    pub fn load(self: *Self, path: []const u8) void {
        const data = scene_loader.readsource(self.allocator, path) catch |err| {
            std.debug.print("readsource: {s}", .{@errorName(err)});
            return;
        };
        errdefer self.allocator.free(data);
        std.debug.print("{}bytes\n", .{data.len});

        const glb = gltf.Glb.parse(data) catch |err| {
            std.debug.print("Glb.parse: {s}", .{@errorName(err)});
            return;
        };
        std.debug.print("parse glb\n", .{});

        _ = glb;

        var stream = std.json.TokenStream.init(glb.jsonChunk);
        const options = std.json.ParseOptions{ .allocator = self.allocator, .ignore_unknown_fields = true };
        const parsed = std.json.parse(gltf.Gltf, &stream, options) catch |err| {
            std.debug.print("json.parse: {s}", .{@errorName(err)});
            return;
        };
        defer std.json.parseFree(gltf.Gltf, parsed, options);
        std.debug.print("{} meshes\n", .{parsed.meshes.len});

        const reader = gltf.GtlfBufferReader{
            .buffers = &.{glb.binChunk},
            .bufferViews = parsed.bufferViews,
            .accessors = parsed.accessors,
        };

        blk: for (parsed.meshes) |*mesh, i| {
            std.debug.print("mesh#{}: {} prims\n", .{ i, mesh.primitives.len });

            var vertex_count: usize = 0;
            var index_count: usize = 0;
            for (mesh.primitives) |*prim| {
                vertex_count += parsed.accessors[prim.attributes.POSITION].count;
                index_count += parsed.accessors[prim.indices.?].count;
            }

            var builder = scene_loader.Builder.new(self.allocator);
            builder.vertices.resize(vertex_count) catch unreachable;
            builder.indices.resize(index_count) catch unreachable;
            self.loader = scene_loader.Loader.create(builder);

            var vertex_offset: usize = 0;
            var index_offset: usize = 0;
            for (mesh.primitives) |*prim| {
                // join submeshes
                _ = prim;
                std.debug.print("POSITIONS={}, indices={}\n", .{ prim.indices, prim.attributes.POSITION });

                const indices_accessor = parsed.accessors[prim.indices.?];
                reader.getUIntIndicesFromAccessor(prim.indices.?, builder.indices.items[index_offset .. index_offset + indices_accessor.count], vertex_offset);
                index_offset += indices_accessor.count;

                const position = reader.getTypedFromAccessor(zigla.Vec3, prim.attributes.POSITION);
                const normal = reader.getTypedFromAccessor(zigla.Vec3, prim.attributes.NORMAL.?);
                builder.vertices.resize(position.len) catch unreachable;
                for (position) |v, j| {
                    var dst = &builder.vertices.items[j + vertex_offset];
                    dst.position = v;
                    dst.normal = normal[j];
                    dst.color = zigla.Vec3.init(1, 1, 1);
                }
                vertex_offset += position.len;
            }

            break :blk;
        }

        defer self.allocator.free(data);
    }

    pub fn render(self: *Self, camera: *zigla.Camera) void {
        if (self.shader == null) {
            var shader = glo.Shader.load(self.allocator, vs, fs) catch {
                std.debug.print("{s}\n", .{glo.getErrorMessage()});
                @panic("load");
            };
            self.shader = shader;
        }

        if (self.shader) |*shader| {
            if (self.loader) |*loader| {
                defer self.loader = null;
                defer loader.deinit();

                var vbo = glo.Vbo.init();
                const vertices = loader.getVertices();
                vbo.setVertices(scene_loader.Vertex, vertices, false);
                if (self.vao) |*vao| {
                    vao.deinit();
                }

                if (loader.getIndices()) |indices| {
                    var ibo = glo.Ibo.init();
                    ibo.setIndices(u32, indices, false);
                    self.draw_count = @intCast(u32, indices.len);
                    self.vao = glo.Vao.init(vbo, shader.createVertexLayout(self.allocator), ibo);
                } else {
                    self.draw_count = @intCast(u32, vertices.len);
                    self.vao = glo.Vao.init(vbo, shader.createVertexLayout(self.allocator), null);
                }
            }
        }

        if (self.shader) |*shader| {
            shader.use();
            defer shader.unuse();

            shader.setMat4("uMVP", &camera.getViewProjectionMatrix()._0.x);
            shader.setMat4("uView", &camera.view.getViewMatrix()._0.x);
            shader.setVec4("uLight", &self.light.x);
            if (self.vao) |vao| {
                vao.draw(self.draw_count, .{});
            }
        }
    }
};
