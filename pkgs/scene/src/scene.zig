const std = @import("std");
const zigla = @import("zigla");
const glo = @import("glo");
const gltf = @import("./gltf.zig");
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
    x: f32,
    y: f32,
    z: f32,
    nx: f32,
    ny: f32,
    nz: f32,
    r: f32,
    g: f32,
    b: f32,

    pub fn create(v: anytype) Vertex {
        return .{
            .x = v.@"0",
            .y = v.@"1",
            .z = v.@"2",
            .nx = v.@"3",
            .ny = v.@"4",
            .nz = v.@"5",
            .r = v.@"6",
            .g = v.@"7",
            .b = v.@"8",
        };
    }
};

const g_vertices: [3]Vertex = .{
    Vertex.create(.{ -2, -2, 0, 0, 0, 1, 1.0, 0.0, 0.0 }),
    Vertex.create(.{ 2, -2, 0, 0, 0, 1, 0.0, 1.0, 0.0 }),
    Vertex.create(.{ 0.0, 2, 0, 0, 0, 1, 0.0, 0.0, 1.0 }),
};
fn triangle(_: ?*anyopaque) []const Vertex {
    return &g_vertices;
}

pub const Finalizer = fn (self: ?*anyopaque) void;
pub const GetVertices = fn (self: ?*anyopaque) []const Vertex;

pub const Loader = struct {
    const Self = @This();

    _ptr: ?*anyopaque = null,
    _deinit: ?*const Finalizer = null,
    // interfaces
    _getVertices: *const GetVertices,

    pub fn deinit(self: *Self) void {
        if (self._deinit) |callback| {
            callback.*(if (self._ptr) |ptr| ptr else null);
        }
    }

    pub fn getVertices(self: *Self) []const Vertex {
        return self._getVertices.*(if (self._ptr) |ptr| ptr else null);
    }
};

pub const Scene = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    shader: ?glo.Shader = null,
    vao: ?glo.Vao = null,

    loader: ?Loader = null,
    light: zigla.Vec4 = zigla.Vec4.init(1, 2, 3, 0).normalized(),

    pub fn new(allocator: std.mem.Allocator) *Self {
        var scene = allocator.create(Scene) catch @panic("create");

        scene.* = Scene{
            .allocator = allocator,
        };
        scene.loader = .{ ._getVertices = &triangle };

        return scene;
    }

    pub fn delete(self: *Self) void {
        self.allocator.destroy(self);
    }

    pub fn load(self: *Self, path: []const u8) void {
        const data = readsource(self.allocator, path) catch |err| {
            std.debug.print("error: {s}", .{@errorName(err)});
            return;
        };
        errdefer self.allocator.free(data);
        std.debug.print("{}bytes\n", .{data.len});

        const glb = gltf.Glb.parse(data) catch |err| {
            std.debug.print("error: {s}", .{@errorName(err)});
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
            std.debug.print("error: {s}", .{@errorName(err)});
            return;
        };
        defer std.json.parseFree(gltf.Gltf, parsed, options);
        std.debug.print("{} meshes\n", .{parsed.meshes.len});

        blk: for (parsed.meshes) |*mesh, i| {
            std.debug.print("mesh#{}: {} prims\n", .{ i, mesh.primitives.len });
            for (mesh.primitives) |*prim| {
                _ = prim;
                std.debug.print("POSITIONS={}, indices={}\n", .{ prim.indices, prim.attributes.POSITION });



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
                defer loader.deinit();
                defer self.loader = null;

                var vbo = glo.Vbo.init();
                vbo.setVertices(Vertex, loader.getVertices(), false);
                if (self.vao) |*vao| {
                    vao.deinit();
                }
                self.vao = glo.Vao.init(vbo, shader.createVertexLayout(self.allocator), null);
            }
        }

        if (self.shader) |*shader| {
            shader.use();
            defer shader.unuse();

            shader.setMat4("uMVP", &camera.getViewProjectionMatrix()._0.x);
            shader.setMat4("uView", &camera.view.getViewMatrix()._0.x);
            shader.setVec4("uLight", &self.light.x);
            if (self.vao) |vao| {
                vao.draw(3, .{});
            }
        }
    }
};
