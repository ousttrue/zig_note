const std = @import("std");
const gl = @import("gl");

pub const ShaderCompile = struct {
    const Self = @This();

    shader: gl.GLuint,

    pub fn init(shader_type: gl.GLuint) Self {
        return .{
            .shader = gl.createShader(shader_type),
        };
    }

    pub fn deinit(self: *Self) void {
        gl.deleteShader(self.shader);
    }

    pub fn compileOrError(self: *Self, error_buffer: []u8, src: []const u8) ?[]const u8 {
        const len = [1]c_int{@intCast(c_int, src.len)};
        const sources: [1][*c]const u8 = .{&src[0]};
        gl.shaderSource(self.shader, 1, &sources, &len);
        gl.compileShader(self.shader);
        var status: [1]gl.GLint = undefined;
        gl.getShaderiv(self.shader, gl.COMPILE_STATUS, &status);
        if (status[0] == gl.TRUE) {
            return null;
        }
        // error message
        var size: [1]gl.GLsizei = undefined;
        gl.getShaderInfoLog(self.shader, @intCast(c_int, error_buffer.len), &size, @ptrCast([*c]gl.GLchar, &error_buffer[0]));
        return error_buffer[0..@intCast(usize, size[0])];
    }
};

pub const AttributeLocation = struct {
    const Self = @This();

    name: []const u8,
    location: c_uint,

    pub fn create(program: gl.GLuint, name: []const u8) Self {
        const location = gl.getAttribLocation(program, &name[0]);
        std.debug.assert(location != -1);
        return .{
            .name = name,
            .location = @intCast(c_uint, location),
        };
    }
};

pub const VertexLayout = struct {
    attribute: AttributeLocation,
    itemCount: c_int, // maybe float1, 2, 3, 4 and 16
    stride: c_int,
    byteOffset: c_int,
};

fn getLayout(layouts: []const VertexLayout, location: c_uint) ?VertexLayout {
    for (layouts) |*layout| {
        if (layout.attribute.location == location) {
            return layout.*;
        }
    }
    return null;
}

pub const ShaderProgram = struct {
    const Self = @This();

    handle: gl.GLuint,
    location_map: std.StringHashMap(c_int),

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .handle = gl.createProgram(),
            .location_map = std.StringHashMap(c_int).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.location_map.deinit();
        gl.deleteProgram(self.handle);
    }

    pub fn use(self: *Self) void {
        gl.useProgram(self.handle);
    }

    pub fn unuse(self: *Self) void {
        _ = self;
        gl.useProgram(0);
    }

    pub fn getLocation(self: *Self, name: []const u8) ?c_int {
        if (self.location_map.get(name)) |location| {
            return location;
        }
        const location = gl.getUniformLocation(self.handle, &name[0]);
        if (location < 0) {
            return null;
        }
        self.location_map.put(name, location) catch @panic("put");
        return location;
    }

    pub fn _setMat4(_: *Self, location: c_int, transpose: bool, value: *const f32) void {
        gl.uniformMatrix4fv(location, 1, if (transpose) gl.TRUE else gl.FALSE, value);
    }

    pub fn setMat4(self: *Self, name: []const u8, value: *const f32) void {
        if (self.getLocation(name)) |location| {
            self._setMat4(location, false, value);
        }
    }

    pub fn linkOrError(self: *Self, error_buffer: []u8, vs: ShaderCompile, fs: ShaderCompile) ?[]const u8 {
        gl.attachShader(self.handle, vs.shader);
        gl.attachShader(self.handle, fs.shader);
        gl.linkProgram(self.handle);
        var status: [1]gl.GLint = undefined;
        gl.getProgramiv(self.handle, gl.LINK_STATUS, &status);
        if (status[0] == gl.TRUE) {
            return null;
        }

        // error message
        var size: [1]gl.GLsizei = undefined;
        gl.getProgramInfoLog(self.handle, @intCast(c_int, error_buffer.len), &size, @ptrCast([*c]gl.GLchar, &error_buffer[0]));
        return error_buffer[0..@intCast(usize, size[0])];
    }

    pub fn load(self: *Self, error_buffer: []u8, vs_src: []const u8, fs_src: []const u8) ?[]const u8 {
        var vs = ShaderCompile.init(gl.VERTEX_SHADER);
        defer vs.deinit();
        if (vs.compileOrError(error_buffer, vs_src)) |error_message| {
            return error_message;
        }

        var fs = ShaderCompile.init(gl.FRAGMENT_SHADER);
        defer fs.deinit();
        if (fs.compileOrError(error_buffer, fs_src)) |error_message| {
            return error_message;
        }

        if (self.linkOrError(error_buffer, vs, fs)) |error_message| {
            return error_message;
        }

        return null;
    }

    pub fn createVertexLayout(self: *Self, allocator: std.mem.Allocator) []const VertexLayout {
        _ = self;
        var count: gl.GLint = undefined;
        gl.getProgramiv(self.handle, gl.ACTIVE_ATTRIBUTES, &count);
        var tmp = allocator.alloc(VertexLayout, @intCast(usize, count)) catch @panic("alloc []VertexLayout");
        defer allocator.free(tmp);

        var stride: c_int = 0;
        var i: c_uint = 0;
        while (i < count) : (i += 1) {
            var buffer: [1024]u8 = undefined;
            var length: c_int = undefined;
            var size: gl.GLsizei = undefined;
            var _type: gl.GLenum = undefined;
            gl.getActiveAttrib(self.handle, i, @intCast(gl.GLuint, buffer.len), &length, &size, &_type, &buffer[0]);
            // https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/glGetActiveAttrib.xhtml
            std.debug.assert(size == 1);
            const name = buffer[0..@intCast(usize, length)];
            const attribute = AttributeLocation.create(self.handle, name);
            const itemCount: c_int = switch (_type) {
                gl.FLOAT_VEC3 => 3,
                gl.FLOAT_VEC2 => 2,
                else => {
                    @panic("not implemented");
                },
            };
            var offset = itemCount * 4;
            tmp[i] = VertexLayout{
                .attribute = attribute,
                .itemCount = itemCount,
                .stride = 0,
                .byteOffset = offset,
            };
            stride += offset;
        }

        var layouts = allocator.dupe(VertexLayout, tmp) catch @panic("dupe");
        var offset: c_int = 0;
        i = 0;
        while (i < count) : (i += 1) {
            if (getLayout(tmp, i)) |layout| {
                layouts[i] = VertexLayout{ .attribute = layout.attribute, .itemCount = layout.itemCount, .stride = stride, .byteOffset = offset };
                offset += layout.byteOffset;
            } else {
                @panic("not found");
            }
        }
        return layouts;
    }
};
