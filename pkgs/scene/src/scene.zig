const std = @import("std");
const screen = @import("screen");
const glo = @import("glo");
const gltf = @import("./gltf.zig");
const vs = @embedFile("./mvp.vs");
const fs = @embedFile("./mvp.fs");
const Vector = std.meta.Vector;

// fn dot(lhs: Vector(4, f32), rhs: Vector(4, f32)) f32 {
//     return @reduce(.Add, lhs * rhs);
// }
fn dot(lhs: [4]f32, rhs: [4]f32) f32 {
    return lhs[0] * rhs[0] + lhs[1] * rhs[1] + lhs[2] * rhs[2] + lhs[3] * rhs[3];
}

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
    // nx: f32,
    // ny: f32,
    // nz: f32,
    // r: f32,
    // g: f32,
    // b: f32,

    pub fn create(v: anytype) Vertex {
        return .{
            .x = v.@"0",
            .y = v.@"1",
            .z = v.@"2",
            // .nx = v.@"3",
            // .ny = v.@"4",
            // .nz = v.@"5",
            // .r = v.@"6",
            // .g = v.@"7",
            // .b = v.@"8",
        };
    }
};

const vertices: [3]Vertex = .{
    Vertex.create(.{
        -0.6, -0.4, 0,
        //  0, 0, 1, 1.0, 0.0, 0.0
    }),
    Vertex.create(.{
        0.6, -0.4, 0,
        // , 0, 0, 1, 0.0, 1.0, 0.0
    }),
    Vertex.create(.{
        0.0, 0.6, 0,
        // , 0, 0, 1, 0.0, 0.0, 1.0
    }),
};

const Mat4 = struct {
    const Self = @This();

    values: [16]f32,

    pub fn ptr(self: *Self) *f32 {
        return &self.values[0];
    }

    pub fn frustum(b: f32, t: f32, l: f32, r: f32, n: f32, f: f32) Self {
        // set OpenGL perspective projection matrix
        return .{ .values = .{
            2 * n / (r - l),
            0,
            0,
            0,
            0,
            2 * n / (t - b),
            0,
            0,
            (r + l) / (r - l),
            (t + b) / (t - b),
            -(f + n) / (f - n),
            -1,
            0,
            0,
            -2 * f * n / (f - n),
            0,
        } };
    }

    pub fn perspective(fov: f32, aspect: f32, n: f32, f: f32) Self {
        const scale = std.math.tan(fov) * n;
        const r = aspect * scale;
        const l = -r;
        const t = scale;
        const b = -t;
        return frustum(b, t, l, r, n, f);
    }

    pub fn translate(x: f32, y: f32, z: f32) Self {
        return .{ .values = .{
            1, 0, 0, x,
            0, 1, 0, y,
            0, 0, 1, z,
            0, 0, 0, 1,
        } };
    }

    pub fn mul(self: Self, rhs: Self) Self {
        const r0 = self.values[0..4].*;
        const r1 = self.values[4..8].*;
        const r2 = self.values[8..12].*;
        const r3 = self.values[12..16].*;
        const c0 = .{ rhs.values[0], rhs.values[4], rhs.values[8], rhs.values[12] };
        const c1 = .{ rhs.values[1], rhs.values[5], rhs.values[9], rhs.values[13] };
        const c2 = .{ rhs.values[2], rhs.values[6], rhs.values[10], rhs.values[14] };
        const c3 = .{ rhs.values[3], rhs.values[7], rhs.values[11], rhs.values[15] };
        return .{ .values = .{
            dot(r0, c0), dot(r0, c1), dot(r0, c2), dot(r0, c3),
            dot(r1, c0), dot(r1, c1), dot(r1, c2), dot(r1, c3),
            dot(r2, c0), dot(r2, c1), dot(r2, c2), dot(r2, c3),
            dot(r3, c0), dot(r3, c1), dot(r3, c2), dot(r3, c3),
        } };
    }
};

const Projection = struct {
    const Self = @This();

    fov: f32 = std.math.pi * (60.0 / 180.0),
    near: f32 = 0.1,
    far: f32 = 100.0,
    aspect: f32 = 1.0,

    pub fn resize(self: *Self, width: u32, height: u32) void {
        _ = self;
        _ = width;
        _ = height;
    }

    pub fn getMatrix(self: *Self) Mat4 {
        // return zlm.Mat4.createPerspective(self.fov, self.aspect, self.near, self.far);
        return Mat4.perspective(self.fov, self.aspect, self.near, self.far);
    }
};

const View = struct {
    const Self = @This();

    yaw: f32 = 0,
    pitch: f32 = 0,
    shift: [3]f32 = .{ 0, 0, -5 },

    pub fn getMatrix(self: *Self) Mat4 {
        // const yaw = zlm.Mat4.createAngleAxis(zlm.Vec3.new(0, 1, 0), self.yaw);
        // const pitch = zlm.Mat4.createAngleAxis(zlm.Vec3.new(1, 0, 0), self.pitch);
        // const shift = zlm.Mat4.createTranslation(self.shift);
        // return shift.mul(pitch.mul(yaw));
        return Mat4.translate(self.shift[0], self.shift[1], self.shift[2]);
    }
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
        if (mouse_input.is_active or mouse_input.is_hover) {
            if (mouse_input.wheel < 0) {
                self.view.shift[2] *= 1.1;
            } else if (mouse_input.wheel > 0) {
                self.view.shift[2] *= 0.9;
            }
        }
        _ = self;
        _ = mouse_input;
    }

    pub fn getMVP(self: *Self) Mat4 {
        // return self.mvp;
        const p = self.projection.getMatrix();
        _ = p;
        const v = self.view.getMatrix();
        _ = v;
        // return v;
        // return p.mul(v);
        return p.mul(v);
        // return v.mul(p);
        // return p;
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
            shader.setMat4("uMVP", self.camera.getMVP().ptr());
            if (self.vao) |vao| {
                vao.draw(3, .{});
            }
        }
    }
};
