const std = @import("std");
const screen = @import("screen");
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

const vertices: [3]Vertex = .{
    Vertex.create(.{ -0.6, -0.4, 0, 0, 0, 1, 1.0, 0.0, 0.0 }),
    Vertex.create(.{ 0.6, -0.4, 0, 0, 0, 1, 0.0, 1.0, 0.0 }),
    Vertex.create(.{ 0.0, 0.6, 0, 0, 0, 1, 0.0, 0.0, 1.0 }),
};

const Projection = struct {
    const Self = @This();

    pub fn resize(self: *Self, width: u32, height: u32) void {
        _ = self;
        _ = width;
        _ = height;
    }
};

const View = struct {
    const Self = @This();
};

const Camera = struct {
    const Self = @This();

    projection: Projection = .{},
    view: View = .{},
    mvp: [16]f32 = .{
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
    },

    pub fn update(self: *Self, mouse_input: screen.MouseInput) void {
        _ = self;
        _ = mouse_input;
    }

    pub fn getMVP(self: *Self) [16]f32 {
        return self.mvp;
    }
};

pub const Scene = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    shader: ?glo.ShaderProgram = null,
    vao: ?glo.Vao = null,
    camera: Camera = .{},

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

    pub fn render(self: *Self, mouse_input: screen.MouseInput) void {
        self.camera.update(mouse_input);

        if (self.shader == null) {
            var error_buffer: [1024]u8 = undefined;
            var shader = glo.ShaderProgram.init(self.allocator);
            if (shader.load(error_buffer[0..error_buffer.len], vs, fs)) |error_message| {
                std.debug.print("{s}\n", .{error_message});
                shader.deinit();
            } else {
                self.shader = shader;

                var vbo = glo.Vbo.init();
                vbo.setVertices(vertices, false);
                self.vao = glo.Vao.create(vbo, shader.createVertexLayout(self.allocator));
            }
        }

        if (self.shader) |*shader| {
            shader.use();
            defer shader.unuse();
            shader.setMat4("uMVP", self.camera.getMVP());
            if (self.vao) |vao| {
                vao.draw(3, .{});
            }
        }
    }
};
