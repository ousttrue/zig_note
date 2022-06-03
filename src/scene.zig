const std = @import("std");
const gltf = @import("./gltf.zig");
const fbo = @import("./fbo.zig");
const mouse_input = @import("./mouse_input.zig");
const ShaderProgram = @import("./shader.zig").ShaderProgram;

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

pub const Scene = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    shader: ?ShaderProgram = null,
    // vao: ?Vao = null,

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

    pub fn render(self: *Self, mouseInput: mouse_input.MouseInput) void {
        _ = self;
        _ = mouseInput;

        if(self.shader==null){
            const shader_or_error = ShaderProgram.load(vs, fs);
            _ = shader_or_error;
            // if not isinstance(shader_or_error, glo.Shader):
            //     LOGGER.error(shader_or_error)
            //     return
            // self.shader = shader_or_error
            // vbo = glo.Vbo()
            // vbo.set_vertices(vertices)
            // self.vao = glo.Vao(
            //     vbo, glo.VertexLayout.create_list(self.shader.program))
        }

        // if(self.shader)|shader|{
        //     if(self.vao)|vao|{
        //         shader.begin();
        //         defer shader.end();
        //         vao.draw(3);
        //     }
        // }
    }
};
