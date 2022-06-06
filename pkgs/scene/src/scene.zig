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

const Vec3 = struct {
    const Self = @This();
    x: f32,
    y: f32,
    z: f32,
    pub fn init(x: f32, y: f32, z: f32) Self {
        return .{
            .x = x,
            .y = y,
            .z = z,
        };
    }
    pub fn dot(self: *const Self, rhs: Vec3) f32 {
        return self.x * rhs.x + self.y * rhs.y + self.z + rhs.z;
    }
    pub fn mul(self: *const Self, scalar: f32) Vec3 {
        return .{ .x = self.x * scalar, .y = self.y * scalar, .z = self.z * scalar };
    }
    pub fn add(self: *const Self, rhs: Vec3) Vec3 {
        return .{ .x = self.x + rhs.x, .y = self.y + rhs.y, .z = self.z + rhs.z };
    }

    pub fn cross(self: *const Self, rhs: Vec3) Vec3 {
        return .{
            .x = self.y * rhs.z - self.z * rhs.y,
            .y = self.z * rhs.x - self.x * rhs.z,
            .z = self.x * rhs.y - self.y * rhs.x,
        };
    }
    pub fn normalize(self: *const Self) Self {
        const sqnorm = self.dot(self.*);
        const len = std.math.sqrt(sqnorm);
        const factor = 1.0 / len;
        return .{ .x = self.x * factor, .y = self.y * factor, .z = self.z * factor };
    }
};

pub const Quaternion = struct {
    const Self = @This();
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,
    w: f32 = 1,

    pub fn angleAxis(angle: f32, axis: Vec3) Quaternion {
        const half = angle / 2;
        const c = std.math.cos(half);
        const s = std.math.sin(half);
        return .{
            .x = axis.x * s,
            .y = axis.y * s,
            .z = axis.z * s,
            .w = c,
        };
    }

    pub fn normalize(self: *Self) Quaternion {
        const sqnorm = self.x * self.x + self.y * self.y + self.z * self.z + self.w + self.w;
        const factor = 1 / sqnorm;
        return .{
            .x = self.x * factor,
            .y = self.y * factor,
            .z = self.z * factor,
            .w = self.w * factor,
        };
    }

    pub fn mul(self: *Self, rhs: Self) Quaternion {
        const lv = Vec3{ .x = self.x, .y = self.y, .z = self.z };
        const rv = Vec3{ .x = rhs.x, .y = rhs.y, .z = rhs.z };
        const v = lv.mul(rhs.w).add(rv.mul(self.w)).add(lv.cross(rv));
        return .{
            .x = v.x,
            .y = v.y,
            .z = v.z,
            .w = self.w * rhs.w - lv.dot(rv),
        };
    }
};

const View = struct {
    const Self = @This();

    rotation: Quaternion = .{},
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

test {
    std.testing.expectEqual(14, Vec3.init(1, 2, 3).dot(Vec3.init(1, 2, 3)));
    std.testing.expectEqual(Vec3.init(0, 0, 1), (Vec3.init(1, 0, 0).cross(Vec3.init(0, 1, 0))));
}

pub fn getArcballVector(mouse_input: screen.MouseInput) Vec3 {
    // https://en.wikibooks.org/wiki/OpenGL_Programming/Modern_OpenGL_Tutorial_Arcball
    var P = Vec3.init(@intToFloat(f32, mouse_input.x) / @intToFloat(f32, mouse_input.width) * 2 - 1.0, @intToFloat(f32, mouse_input.y) / @intToFloat(f32, mouse_input.height) * 2 - 1.0, 0);
    P.y = -P.y;
    const OP_squared = P.x * P.x + P.y * P.y;
    if (OP_squared <= 1) {
        P.z = std.math.sqrt(1 - OP_squared); // Pythagoras
    } else {
        P = P.normalize(); // nearest point
    }
    return P;
}

const ArcBall = struct {
    const Self = @This();

    view: *View,
    projection: *Projection,
    rotation: Quaternion = .{},
    tmp_rotation: Quaternion = .{},
    x: ?i32 = null,
    y: ?i32 = null,
    va: ?Vec3 = null,

    pub fn init(view: *View, projection: *Projection) Self {
        return .{
            .view = view,
            .projection = projection,
        };
    }

    pub fn update(self: *Self) void {
        self.view.rotation = self.tmp_rotation.mul(self.rotation).normalize();
    }

    pub fn begin(self: *Self, mouse_input: screen.MouseInput) void {
        self.rotation = self.view.rotation;
        self.x = mouse_input.x;
        self.y = mouse_input.y;
        self.va = getArcballVector(mouse_input);
    }

    pub fn drag(self: *Self, mouse_input: screen.MouseInput, _: i32, _: i32) void {
        if (mouse_input.x == self.x and mouse_input.y == self.y) {
            return;
        }
        const va = self.va orelse return;
        self.x = mouse_input.x;
        self.y = mouse_input.y;
        const vb = getArcballVector(mouse_input);
        const angle = std.math.acos(std.math.min(1.0, va.dot(vb))) * 2;
        const axis = va.cross(vb);
        self.tmp_rotation = Quaternion.angleAxis(angle, axis);
        self.update();
    }

    pub fn end(self: *Self, _: screen.MouseInput) void {
        self.rotation = self.tmp_rotation.mul(self.rotation).normalize();
        self.tmp_rotation = .{};
        self.update();
    }
};

pub const Scene = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    camera: Camera = .{},
    arc: *ArcBall,
    shader: ?glo.ShaderProgram = null,
    vao: ?glo.Vao = null,

    pub fn init(allocator: std.mem.Allocator, mouse_event: *screen.MouseEvent) Self {
        var arc = allocator.create(ArcBall) catch @panic("create");
        var scene = Scene{
            .allocator = allocator,
            .arc = arc,
        };
        arc.* = ArcBall.init(&scene.camera.view, &scene.camera.projection);
        _ = mouse_event;
        var begin = screen.mouse_event.BeginEndCallback.create(arc, "begin");
        var drag = screen.mouse_event.DragCallback.create(arc, ArcBall.drag);
        _ =begin;
        _ =drag;
        // mouse_event.right_button.bind(.{
        //     .begin = ,
        //     .drag = screen.mouse_event.DragCallback.create(arc, "drag"),
        //     .end = screen.mouse_event.BeginEndCallback.create(arc, "end"),
        // });

        return scene;
    }

    pub fn deinit(self: *Self)void
    {
        self.allocator.destroy(self.arc);
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
