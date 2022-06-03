const gl = @import("gl");
const shader = @import("./shader.zig");

pub const Vbo = struct {
    const Self = @This();

    handle: gl.GLuint,

    pub fn init() Self {
        var handle: gl.GLuint = undefined;
        gl.genBuffers(1, &handle);

        return .{
            .handle = handle,
        };
    }

    pub fn deinit(self: *Self) void {
        gl.deleteBuffers(1, &self.handle);
    }

    pub fn bind(self: *const Self) void {
        gl.bindBuffer(gl.ARRAY_BUFFER, self.handle);
    }

    pub fn unbind(self: *Self) void {
        _ = self;
        gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    }

    pub fn setVertices(self: *Self, vertices: anytype, isDynamic: bool) void {
        self.bind();
        gl.bufferData(gl.ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), &vertices, if (isDynamic) gl.DYNAMIC_DRAW else gl.STATIC_DRAW);
        self.unbind();
    }

    pub fn update(self: *Self, vertices: []const u8, offset: u32) void {
        self.bind();
        gl.bufferSubData(gl.ARRAY_BUFFER, offset, vertices.len, vertices);
        self.unbind();
    }
};

// class Ibo:
//     def __init__(self):
//         self.vbo = gl.glGenBuffers(1)
//         self.format = 0

//     def __del__(self):
//         logger.debug(f'delete vbo: {self.vbo}')
//         gl.glDeleteBuffers(1, [self.vbo])

//     def bind(self):
//         gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, self.vbo)

//     def unbind(self):
//         gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, 0)

//     def set_indices(self, indices: ctypes.Array, *, is_dynamic: bool = False):
//         match indices._type_:
//             case ctypes.c_ushort:
//                 self.format = gl.GL_UNSIGNED_SHORT
//             case ctypes.c_uint:
//                 self.format = gl.GL_UNSIGNED_INT
//             case _:
//                 raise NotImplementedError()
//         self.bind()
//         gl.glBufferData(gl.GL_ELEMENT_ARRAY_BUFFER, ctypes.sizeof(indices),
//                         indices, gl.GL_DYNAMIC_DRAW if is_dynamic else gl.GL_STATIC_DRAW)
//         self.unbind()

//     def update(self, indices, offset=0) -> None:
//         self.bind()
//         gl.glBufferSubData(gl.GL_ELEMENT_ARRAY_BUFFER, offset,
//                            ctypes.sizeof(indices), indices)
//         self.unbind()

pub const Vao = struct {
    const Self = @This();

    handle: gl.GLuint,
    vbo: Vbo,

    pub fn init(vbo: Vbo) Self {
        var handle: gl.GLuint = undefined;
        gl.genVertexArrays(1, &handle);

        return .{
            .handle = handle,
            .vbo = vbo,
        };
    }

    pub fn deinit(self: *Self) void {
        gl.deleteVertexArrays(1, &self.vao);
    }

    pub fn create(vbo: Vbo, layouts: []const shader.VertexLayout) Self {
        var self = Self.init(vbo);
        self.bind();
        vbo.bind();
        for (layouts) |*layout| {
            gl.enableVertexAttribArray(layout.attribute.location);
            const value = @intCast(usize, layout.byteOffset);
            const p = if (value == 0) null else @intToPtr(*anyopaque, value);
            gl.vertexAttribPointer(layout.attribute.location, layout.itemCount, gl.FLOAT, gl.FALSE, layout.stride, p);
        }
        // self.ibo = None
        // if ibo:
        //     self.ibo = ibo
        //     ibo.bind()
        self.unbind();
        return self;
    }

    pub fn bind(self: *const Self) void {
        gl.bindVertexArray(self.handle);
    }

    pub fn unbind(self: *const Self) void {
        _ = self;
        gl.bindVertexArray(0);
    }

    pub fn draw(self: *const Self, count: i32, __default__: struct { offset: i32 = 0, topology: gl.GLenum = gl.TRIANGLES }) void {
        self.bind();
        defer self.unbind();

        // if self.ibo:
        //     GL.glDrawElements(topology, count,
        //                       self.ibo.format, ctypes.c_void_p(offset))
        // else:
        gl.drawArrays(__default__.topology, __default__.offset, count);
    }
};
