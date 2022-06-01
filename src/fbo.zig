const gl = @import("gl");
const imgui = @import("imgui");

pub const Texture = struct {
    const Self = @This();

    width: c_int,
    height: c_int,
    // gl.GL_RGBA(32bit) or gl.GL_RED(8bit graysclale)
    pixelFormat: c_int,
    handle: [1]gl.GLuint = .{0},

    fn _init(self: *Self) void {
        gl.genTextures(self.handle.len, &self.handle[0]);
    }

    pub fn init(width: c_int, height: c_int, pixelFormat: c_int, data: ?[]const u8) Texture {
        var texture = Texture{
            .width = width,
            .height = height,
            .pixelFormat = pixelFormat,
        };
        texture._init();
        // logger.debug(f'Texture: {self.handle}')
        texture.bind();
        defer texture.unbind();
        gl.pixelStorei(gl.UNPACK_ALIGNMENT, 1);
        // gl.glPixelStorei(gl.UNPACK_ROW_LENGTH, width);
        gl.pixelStorei(gl.UNPACK_SKIP_PIXELS, 0);
        gl.pixelStorei(gl.UNPACK_SKIP_ROWS, 0);
        gl.texImage2D(gl.TEXTURE_2D, 0, texture.pixelFormat, width, height, 0, @intCast(c_uint, texture.pixelFormat), gl.UNSIGNED_BYTE, if (data) |d| &d[0] else null);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        return texture;
    }

    pub fn bind(self: *Self) void {
        gl.bindTexture(gl.TEXTURE_2D, self.handle[0]);
    }

    pub fn unbind(_: *Self) void {
        gl.bindTexture(gl.TEXTURE_2D, 0);
    }
};

pub const Fbo = struct {
    const Self = @This();

    texture: Texture,
    handle: [1]gl.GLuint = .{0},

    fn _init(self: *Self) void {
        gl.genFramebuffers(self.handle.len, &self.handle[0]);
    }

    pub fn init(width: c_int, height: c_int, use_depth: bool) Fbo {
        _ = use_depth;
        var fbo = Fbo{
            .texture = Texture.init(width, height, gl.RGBA, null),
        };
        fbo._init();
        //     gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, self.fbo)
        //     gl.glFramebufferTexture2D(
        //         gl.GL_FRAMEBUFFER, gl.GL_COLOR_ATTACHMENT0, gl.GL_TEXTURE_2D, self.texture.handle, 0)
        //     gl.glDrawBuffers([gl.GL_COLOR_ATTACHMENT0])

        //     if use_depth:
        //         self.depth = gl.glGenRenderbuffers(1)
        //         gl.glBindRenderbuffer(gl.GL_RENDERBUFFER, self.depth)
        //         gl.glRenderbufferStorage(
        //             gl.GL_RENDERBUFFER, gl.GL_DEPTH_COMPONENT, width, height)
        //         gl.glFramebufferRenderbuffer(
        //             gl.GL_FRAMEBUFFER, gl.GL_DEPTH_ATTACHMENT, gl.GL_RENDERBUFFER, self.depth)
        //     else:
        //         self.depth = 0

        //     gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, 0)
        //     LOGGER.debug(
        //         f'fbo: {self.fbo}, texture: {self.texture}, depth: {self.depth}')

        return fbo;
    }

    pub fn deinit(self: *const Self) void {
        // LOGGER.debug(f'fbo: {self.fbo}')
        gl.deleteFramebuffers(1, &self.handle);
    }

    pub fn bind(self: *const Self) void {
        gl.bindFramebuffer(gl.FRAMEBUFFER, self.handle[0]);
    }

    pub fn unbind(_: *const Self) void {
        gl.bindFramebuffer(gl.FRAMEBUFFER, 0);
    }
};

pub const FboManager = struct {
    const Self = @This();

    fbo: ?Fbo = null,

    pub fn unbind(self: *Self)void
    {        
        if (self.fbo) |fbo| {
            fbo.unbind();
        }
    }

    pub fn clear(self: *Self, width: c_int, height: c_int, color: [4]f32) ?*anyopaque {
        if (width == 0 or height == 0) {
            return null;
        }

        if (self.fbo) |fbo| {
            if (fbo.texture.width != width or fbo.texture.height != height) {
                fbo.deinit();
                self.fbo = null;
            }
        }
        if (self.fbo == null) {
            self.fbo = Fbo.init(width, height, true);
        }

        if (self.fbo) |fbo| {
            fbo.bind();
            gl.viewport(0, 0, width, height);
            gl.scissor(0, 0, width, height);
            gl.clearColor(color[0] * color[3], color[1] * color[3], color[2] * color[3], color[3]);
            gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
            gl.clearDepth(1.0);
            gl.depthFunc(gl.LESS);
            return @intToPtr(*anyopaque, fbo.texture.handle[0]);
        }

        unreachable;
    }
};
