const std = @import("std");
const screen = @import("screen");
const glo = @import("glo");
const gltf = @import("./gltf.zig");
const vs = @embedFile("./mvp.vs");
const fs = @embedFile("./mvp.fs");
const camera = @import("./camera.zig");

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

pub const Scene = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    camera: camera.Camera = .{},
    cameraHandler: camera.ArcBall = undefined,
    // cameraHandler: TurnTable = undefined,
    shiftHandler: camera.ScreenShift = undefined,
    shader: ?glo.Shader = null,
    vao: ?glo.Vao = null,

    pub fn new(allocator: std.mem.Allocator, mouse_event: *screen.MouseEvent) *Self {
        var scene = allocator.create(Scene) catch @panic("create");
        scene.* = Scene{
            .allocator = allocator,
        };
        scene.cameraHandler = camera.ArcBall.init(&scene.camera.view, &scene.camera.projection);
        // scene.cameraHandler = camera.TurnTable.init(&scene.camera.view);
        mouse_event.right_button.bind(.{
            .begin = screen.mouse_event.BeginEndCallback.create(&scene.cameraHandler, "begin"),
            .drag = screen.mouse_event.DragCallback.create(&scene.cameraHandler, "drag"),
            .end = screen.mouse_event.BeginEndCallback.create(&scene.cameraHandler, "end"),
        });
        scene.shiftHandler = camera.ScreenShift.init(&scene.camera.view, &scene.camera.projection);
        mouse_event.middle_button.bind(.{
            .begin = screen.mouse_event.BeginEndCallback.create(&scene.shiftHandler, "begin"),
            .drag = screen.mouse_event.DragCallback.create(&scene.shiftHandler, "drag"),
            .end = screen.mouse_event.BeginEndCallback.create(&scene.shiftHandler, "end"),
        });
        mouse_event.wheel.append(screen.mouse_event.WheelCallback.create(&scene.shiftHandler, "wheel")) catch @panic("append");

        return scene;
    }

    pub fn delete(self: *Self) void {
        self.allocator.destroy(self);
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
        self.camera.projection.width = mouse_input.width;
        self.camera.projection.height = mouse_input.height;

        if (self.shader == null) {
            var shader = glo.Shader.load(self.allocator, vs, fs) catch {
                std.debug.print("{s}\n", .{glo.getErrorMessage()});
                @panic("load");
            };
            self.shader = shader;

            var vbo = glo.Vbo.init();
            vbo.setVertices(vertices, false);
            self.vao = glo.Vao.init(vbo, shader.createVertexLayout(self.allocator), null);
        }

        if (self.shader) |*shader| {
            shader.use();
            defer shader.unuse();
            const m = self.camera.getMVP();
            shader.setMat4("uMVP", &m._0.x);
            if (self.vao) |vao| {
                vao.draw(3, .{});
            }
        }
    }
};
