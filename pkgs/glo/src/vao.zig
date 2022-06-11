const gl = @import("gl");
const shader_program = @import("./shader_program.zig");

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

pub const Ibo = struct {
    const Self = @This();

    handle: gl.GLuint = undefined,
    format: gl.GLuint = 0,

    pub fn init() Self {
        var self = Self{};
        gl.genBuffers(1, &self.handle);
        return self;
    }

    pub fn deinit(self: *Self) void {
        gl.deleteBuffers(1, &self.handle);
    }

    pub fn bind(self: Self) void {
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.handle);
    }

    pub fn unbind(_: Self) void {
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
    }

    pub fn setIndices(self: *Self, indices: anytype, isDynamic: bool) void {
        const T = @TypeOf(indices);
        const E = @typeInfo(T).Array.child;
        switch (@sizeOf(E)) {
            2 => self.format = gl.UNSIGNED_SHORT,
            4 => self.format = gl.UNSIGNED_INT,
            else => @panic("not implemented"),
        }
        self.bind();
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, @sizeOf(T), &indices, if (isDynamic) gl.DYNAMIC_DRAW else gl.STATIC_DRAW);
        self.unbind();
    }

    pub fn update(self: Self, indices: anytype, offset: u32) void {
        const T = @TypeOf(indices);
        switch (@typeInfo(T)) {
            .Array => {},
            else => @compileError("not array"),
        }
        self.bind();
        gl.glBufferSubData(gl.GL_ELEMENT_ARRAY_BUFFER, offset, @sizeOf(T), &indices);
        self.unbind();
    }
};

pub const Vao = struct {
    const Self = @This();

    handle: gl.GLuint,
    vbo: Vbo,
    ibo: ?Ibo,

    pub fn init(vbo: Vbo, layouts: []const shader_program.VertexLayout, ibo: ?Ibo) Self {
        var handle: gl.GLuint = undefined;
        gl.genVertexArrays(1, &handle);

        var self = Self{
            .handle = handle,
            .vbo = vbo,
            .ibo = ibo,
        };
        self.bind();
        vbo.bind();
        for (layouts) |*layout| {
            gl.enableVertexAttribArray(layout.attribute.location);
            const value = @intCast(usize, layout.byteOffset);
            const p = if (value == 0) null else @intToPtr(*anyopaque, value);
            gl.vertexAttribPointer(layout.attribute.location, layout.itemCount, gl.FLOAT, gl.FALSE, layout.stride, p);
        }
        if (ibo) |ibo_| {
            self.ibo = ibo_;
            ibo_.bind();
        }
        self.unbind();
        return self;
    }

    pub fn deinit(self: *Self) void {
        gl.deleteVertexArrays(1, &self.vao);
    }

    pub fn bind(self: *const Self) void {
        gl.bindVertexArray(self.handle);
    }

    pub fn unbind(self: *const Self) void {
        _ = self;
        gl.bindVertexArray(0);
    }

    pub fn draw(self: *const Self, count: u32, __default__: struct { offset: u32 = 0, topology: gl.GLenum = gl.TRIANGLES }) void {
        self.bind();
        defer self.unbind();

        if (self.ibo) |ibo_| {
            gl.drawElements(__default__.topology, @intCast(i32, count), ibo_.format, @intToPtr(?*const anyopaque, @intCast(usize, __default__.offset)));
        } else {
            gl.drawArrays(__default__.topology, @intCast(i32, __default__.offset), @intCast(i32, count));
        }
    }
};
