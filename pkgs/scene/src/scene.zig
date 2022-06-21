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

pub const Scene = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    shader: ?glo.Shader = null,
    vao: ?glo.Vao = null,

    vertices: ?[]const Vertex = null,
    light: zigla.Vec4 = zigla.Vec4.init(1, 2, 3, 0).normalized(),

    pub fn new(allocator: std.mem.Allocator) *Self {
        var scene = allocator.create(Scene) catch @panic("create");

        scene.* = Scene{
            .allocator = allocator,
            .vertices = &g_vertices,
        };
        return scene;
    }

    pub fn delete(self: *Self) void {
        self.allocator.destroy(self);
    }

    pub fn load(self: *Self, path: []const u8) void {
        if (readsource(self.allocator, path)) |data| {
            defer self.allocator.free(data);
            std.debug.print("{}bytes\n", .{data.len});
            if (gltf.Glb.parse(data)) |glb| {
                std.debug.print("parse glb\n", .{});

                var parser = std.json.Parser.init(self.allocator, false);
                defer parser.deinit();
                if (parser.parse(glb.jsonChunk)) |parsed| {
                    _ = parsed;
                    std.debug.print("parsed\n", .{});
                } else |err| {
                    std.debug.print("error: {s}", .{@errorName(err)});
                }
            } else |err| {
                std.debug.print("error: {s}", .{@errorName(err)});
            }
        } else |err| {
            std.debug.print("error: {s}", .{@errorName(err)});
        }
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
            if (self.vao == null) {
                if (self.vertices) |vertices| {
                    var vbo = glo.Vbo.init();
                    vbo.setVertices(Vertex, vertices, false);
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
                vao.draw(3, .{});
            }
        }
    }
};
