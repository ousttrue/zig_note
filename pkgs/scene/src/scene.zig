const std = @import("std");
const screen = @import("screen");
const glo = @import("glo");
const gltf = @import("./gltf.zig");

const vs = @embedFile("./simple.vs");
const fs = @embedFile("./simple.fs");

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
    r: f32,
    g: f32,
    b: f32,

    pub fn create(v: anytype) Vertex {
        return .{
            .x = v.@"0",
            .y = v.@"1",
            .r = v.@"2",
            .g = v.@"3",
            .b = v.@"4",
        };
    }
};

const vertices: [3]Vertex = .{
    Vertex.create(.{ -0.6, -0.4, 1.0, 0.0, 0.0 }),
    Vertex.create(.{ 0.6, -0.4, 0.0, 1.0, 0.0 }),
    Vertex.create(.{ 0.0, 0.6, 0.0, 0.0, 1.0 }),
};

pub const Scene = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    shader: ?glo.ShaderProgram = null,
    vao: ?glo.Vao = null,

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .allocator = allocator,
        };
    }

    pub fn load(self: *Self, path: []const u8) void {
        _ = self;
        _ = path;

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

    pub fn render(self: *Self, mouseInput: screen.MouseInput) void {
        _ = self;
        _ = mouseInput;

        if (self.shader == null) {
            var errorBuffer: [1024]u8 = undefined;
            var shader = glo.ShaderProgram.init();
            if (shader.load(errorBuffer[0..errorBuffer.len], vs, fs)) |errorMessage| {
                std.debug.print("{s}\n", .{errorMessage});
                shader.deinit();
            } else {
                self.shader = shader;

                var vbo = glo.Vbo.init();
                vbo.setVertices(vertices, false);
                self.vao = glo.Vao.create(vbo, shader.createVertexLayout(self.allocator));
            }
        }

        if (self.shader) |shader| {
            if (self.vao) |vao| {
                shader.use();
                defer shader.unuse();
                vao.draw(3, .{});
            }
        }
    }
};
