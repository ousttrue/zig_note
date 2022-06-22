const std = @import("std");
const zigla = @import("zigla");
const glo = @import("glo");
const gltf = @import("./gltf.zig");
const TypeEraser = @import("./type_eraser.zig").TypeEraser;
const vs = @embedFile("./mvp.vs");
const fs = @embedFile("./mvp.fs");

fn readsource(allocator: std.mem.Allocator, arg: []const u8) ![:0]const u8 {
    var file = try std.fs.cwd().openFile(arg, .{});
    defer file.close();
    const file_size = try file.getEndPos();

    var buffer = try allocator.allocSentinel(u8, file_size, 0);
    errdefer allocator.free(buffer);

    const bytes_read = try file.read(buffer);
    std.debug.assert(bytes_read == file_size);
    return buffer;
}

const Vertex = struct {
    position: zigla.Vec3,
    normal: zigla.Vec3,
    color: zigla.Vec3,

    pub fn create(v: anytype) Vertex {
        return .{
            .position = .{ .x = v.@"0".@"0", .y = v.@"0".@"1", .z = v.@"0".@"2" },
            .normal = .{ .x = v.@"1".@"0", .y = v.@"1".@"1", .z = v.@"1".@"2" },
            .color = .{ .x = v.@"2".@"0", .y = v.@"2".@"1", .z = v.@"2".@"2" },
        };
    }
};

const g_vertices: [3]Vertex = .{
    Vertex.create(.{ .{ -2, -2, 0 }, .{ 0, 0, 1 }, .{ 1.0, 0.0, 0.0 } }),
    Vertex.create(.{ .{ 2, -2, 0 }, .{ 0, 0, 1 }, .{ 0.0, 1.0, 0.0 } }),
    Vertex.create(.{ .{ 0.0, 2, 0 }, .{ 0, 0, 1 }, .{ 0.0, 0.0, 1.0 } }),
};

const Triangle = struct {
    const Self = @This();

    allocator: std.mem.Allocator,

    pub fn new(allocator: std.mem.Allocator) *Self {
        var self = allocator.create(Self) catch unreachable;
        self.* = Self{ .allocator = allocator };
        return self;
    }

    pub fn delete(self: *Self) void {
        self.allocator.destroy(self);
    }

    pub fn getVertices(_: *Self) []const Vertex {
        return &g_vertices;
    }

    pub fn getIndices(_: *Self) ?[]const u32 {
        return null;
    }
};
fn triangle(_: ?*anyopaque) []const Vertex {
    return &g_vertices;
}

pub const Finalizer = fn (self: *anyopaque) void;
pub const GetVertices = fn (self: *anyopaque) []const Vertex;
pub const GetIndices = fn (self: *anyopaque) ?[]const u32;

pub const Loader = struct {
    const Self = @This();

    ptr: *anyopaque,
    _deinit: *const Finalizer,
    // interfaces
    _getVertices: *const GetVertices,
    _getIndices: *const GetIndices,

    pub fn create(ptr: anytype) Self {
        const T = @TypeOf(ptr);
        const info = @typeInfo(T);
        const E = info.Pointer.child;
        return Self{
            .ptr = ptr,
            ._deinit = &TypeEraser(E, "delete").call,
            ._getVertices = &TypeEraser(E, "getVertices").call,
            ._getIndices = &TypeEraser(E, "getIndices").call,
        };
    }

    pub fn deinit(self: *Self) void {
        self._deinit.*(self.ptr);
    }

    pub fn getVertices(self: *Self) []const Vertex {
        return self._getVertices.*(self.ptr);
    }

    pub fn getIndices(self: *Self) ?[]const u32 {
        return self._getIndices.*(self.ptr);
    }
};

pub const Builder = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    vertices: std.ArrayList(Vertex),
    indices: std.ArrayList(u32),

    pub fn new(allocator: std.mem.Allocator) *Self {
        var self = allocator.create(Self) catch unreachable;
        self.* = Self{
            .allocator = allocator,
            .vertices = std.ArrayList(Vertex).init(allocator),
            .indices = std.ArrayList(u32).init(allocator),
        };
        return self;
    }

    pub fn delete(self: *Self) void {
        self.vertices.deinit();
        self.indices.deinit();
        self.allocator.destroy(self);
    }

    pub fn getVertices(self: *Self) []const Vertex {
        return self.vertices.items;
    }

    pub fn getIndices(self: *Self) ?[]const u32 {
        return self.indices.items;
    }
};

pub const Scene = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    shader: ?glo.Shader = null,
    vao: ?glo.Vao = null,
    draw_count: u32 = 0,

    loader: ?Loader = null,
    light: zigla.Vec4 = zigla.Vec4.init(1, 2, 3, 0).normalized(),

    pub fn new(allocator: std.mem.Allocator) *Self {
        var scene = allocator.create(Scene) catch @panic("create");

        scene.* = Scene{
            .allocator = allocator,
        };
        scene.loader = Loader.create(Triangle.new(allocator));

        return scene;
    }

    pub fn delete(self: *Self) void {
        self.allocator.destroy(self);
    }

    pub fn load(self: *Self, path: []const u8) void {
        const data = readsource(self.allocator, path) catch |err| {
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

        // var parser = std.json.Parser.init(self.allocator, false);
        // defer parser.deinit();
        // const parsed = parser.parse(glb.jsonChunk) catch |err| {
        //     std.debug.print("error: {s}", .{@errorName(err)});
        //     return;
        // };
        // _ = parsed;
        // std.debug.print("parsed\n", .{});

        var stream = std.json.TokenStream.init(glb.jsonChunk);
        const options = std.json.ParseOptions{ .allocator = self.allocator, .ignore_unknown_fields = true };
        const parsed = std.json.parse(gltf.Gltf, &stream, options) catch |err|
            {
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
            for (mesh.primitives) |*prim| {
                _ = prim;
                std.debug.print("POSITIONS={}, indices={}\n", .{ prim.indices, prim.attributes.POSITION });

                var builder = Builder.new(self.allocator);
                self.loader = Loader.create(builder);

                const indices_bytes = reader.getBytesFromAccessor(prim.indices.?);
                const index_count = parsed.accessors[prim.indices.?].count;
                builder.indices.resize(index_count) catch unreachable;
                switch (parsed.accessors[prim.indices.?].componentType) {
                    5123 => {
                        const indices = @ptrCast([*]const u16, @alignCast(@alignOf(u16), &indices_bytes[0]))[0..index_count];
                        for (indices) |index, j| {
                            builder.indices.items[j] = index;
                        }
                    },
                    else => {
                        unreachable;
                    },
                }

                const position = reader.getTypedFromAccessor(zigla.Vec3, prim.attributes.POSITION);
                const normal = reader.getTypedFromAccessor(zigla.Vec3, prim.attributes.NORMAL.?);
                builder.vertices.resize(position.len) catch unreachable;
                for (position) |v, j| {
                    var dst = &builder.vertices.items[j];
                    dst.position = v;
                    dst.normal = normal[j];
                    dst.color = zigla.Vec3.init(1, 1, 1);
                }

                break :blk;
            }
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
                vbo.setVertices(Vertex, vertices, false);
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
