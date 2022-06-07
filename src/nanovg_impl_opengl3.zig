const std = @import("std");
const gl = @import("gl");
const glo = @import("glo");
const nanovg = @import("nanovg");

// P_PATH = ctypes.POINTER(nanovg.GLNVGpath)
// P_CALL = ctypes.POINTER(nanovg.GLNVGcall)

const VS = @embedFile("./nanovg.vs");
const FS = @embedFile("./nanovg.fs");

// FLAGS = 0

fn checkGlError() void {
    while (true) {
        const err = gl.GetError();
        switch (err) {
            .NO_ERROR => break,
            else => {
                std.debug.print("Error {s}\n", @tagName(err));
            },
        }
    }
}

fn convertBlendFuncFactor(factor: nanovg.NVGblendFactor) i32 {
    return switch (factor) {
        .NVG_ZERO => gl.ZERO,
        .NVG_ONE => gl.ONE,
        .NVG_SRC_COLOR => gl.SRC_COLOR,
        .NVG_ONE_MINUS_SRC_COLOR => gl.ONE_MINUS_SRC_COLOR,
        .NVG_DST_COLOR => gl.DST_COLOR,
        .NVG_ONE_MINUS_DST_COLOR => gl.ONE_MINUS_DST_COLOR,
        .NVG_SRC_ALPHA => gl.SRC_ALPHA,
        .NVG_ONE_MINUS_SRC_ALPHA => gl.ONE_MINUS_SRC_ALPHA,
        .NVG_DST_ALPHA => gl.DST_ALPHA,
        .NVG_ONE_MINUS_DST_ALPHA => gl.ONE_MINUS_DST_ALPHA,
        .NVG_SRC_ALPHA_SATURATE => gl.SRC_ALPHA_SATURATE,
        else => gl.INVALID_ENUM,
    };
}

const GLNVGblend = struct {
    srcRGB: gl.GLenum = 0,
    dstRGB: gl.GLenum = 0,
    srcAlpha: gl.GLenum = 0,
    dstAlpha: gl.GLenum = 0,
};

fn blendCompositeOperation(op: nanovg.NVGcompositeOperationState) nanovg.GLNVGblend {
    const blend = GLNVGblend{ convertBlendFuncFactor(op.srcRGB), convertBlendFuncFactor(op.dstRGB), convertBlendFuncFactor(op.srcAlpha), convertBlendFuncFactor(op.dstAlpha) };
    if (blend.srcRGB == gl.INVALID_ENUM or blend.dstRGB == gl.INVALID_ENUM or blend.srcAlpha == gl.INVALID_ENUM or blend.dstAlpha == gl.INVALID_ENUM) {
        return GLNVGblend{ gl.ONE, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ONE_MINUS_SRC_ALPHA };
    }
    return blend;
}

const StencilFunc = struct {
    func: c_int = gl.ALWAYS,
    ref: c_int = 0,
    mask: c_int = 0xffffffff,
};

const Texture = struct {
    info: nanovg.NVGtextureInfo,
    resource: glo.Texture,
};

const Pipeline = struct {
    const Self = @This();

    shader: glo.ShaderProgram,

    fn init() Self {
        var shader = glo.ShaderProgram.load(VS, FS);
        std.debug.assert(shader != null);

        var self = Self{
            .shader = shader,
            // .texture = glo.UniformLocation.create(self._shader.program, "tex"),
            // .view = glo.UniformLocation.create(self._shader.program, "viewSize"),
            // UBO
            // .frag = glo.UniformBlockIndex.create(self._shader.program, "frag"),
        };

        //gl.uniformBlockBinding(self.shader.handle, self.frag.index, 0);

        const _align = gl.GetIntegerv(gl.UNIFORM_BUFFER_OFFSET_ALIGNMENT);
        self._fragSize = @sizeOf(nanovg.GLNVGfragUniforms) + _align - @sizeOf(nanovg.GLNVGfragUniforms) % _align;

        checkGlError();

        return self;
    }

    fn use(self: *Self) void {
        self._shader.use();
    }
};

fn gl_pixel_type(pixel_type: nanovg.NVGtexture) i32 {
    return switch (pixel_type) {
        .NVG_TEXTURE_RGBA => gl.RGBA,
        .NVG_TEXTURE_ALPHA => gl.RED,
    };
}

const Renderer = struct {
    const Self = @This();

    next_id: c_int = 1,
    _textures: std.AutoHashMap(c_int, Texture),
    _pipeline: ?Pipeline = null,
    _texure: u32 = 0,
    _stencilMask: u32 = 0xffffffff,
    _stencilFunc: StencilFunc = undefined,
    // _srcRGB: = {}
    // _srcAlpha: = {}
    // _dstRGB: = {}
    // _dstAlpha: = {}
    // shader: = None
    // _vertBuf: = 0
    // _vertArr: = 0
    _fragBuf: gl.GLuint = 0,
    // cache
    _blendFunc: GLNVGblend = .{},

    fn init(allocator: std.mem.Allocator) Self {
        return .{
            ._textures = std.AutoHashMap(c_int, Texture).init(allocator),
        };
    }

    fn deinit(self: *Self) void {
        self._textures.deinit();
    }

    fn createTexture(self: *Self, image_type: nanovg.NVGtexture, w: i32, h: i32, flags: i32, data: ?*const u8) i32 {
        const id = self.next_id;
        self.next_id += 1;

        const resource = glo.Texture.init(w, h, gl_pixel_type(image_type), data);
        const info = nanovg.NVGtextureInfo{ ._id = id, ._handle = 0, ._width = w, ._height = h, ._type = @enumToInt(image_type), ._flags = flags };
        self._textures.put(id, Texture{ .info = info, .resource = resource }) catch @panic("put");
        return id;
    }

    fn updateTexture(self: *Self, image: i32, x: c_int, y: c_int, w: c_int, h: c_int, data: *const u8) bool {
        if (self._textures.get(image)) |*texture| {
            texture.resource.update(x, y, w, h, data);
            return true;
        }
        return false;
    }

    fn deleteTexture(self: *Self, image: i32) bool {
        return self._textures.remove(image);
    }

    fn getTexture(self: *Self, image: i32) ?*nanovg.NVGtextureInfo {
        if (self._textures.get(image)) |*texture| {
            return &texture.info;
        } else {
            return null;
        }
    }

    fn blendFuncSeparate(self: *Self, blend: GLNVGblend) void {
        if (self._blendFunc != blend) {
            self._blendFunc = blend;
            gl.blendFuncSeparate(blend.srcRGB, blend.dstRGB, blend.srcAlpha, blend.dstAlpha);
        }
    }

    fn setUniforms(self: *Self, uniformOffset: i32) void {
        gl.bindBufferRange(gl.UNIFORM_BUFFER, 0, self._fragBuf, uniformOffset, @sizeOf(nanovg.GLNVGfragUniforms));
    }

    fn bindTexture(self: *Self, image: i32) void {
        if (image == 0) {
            gl.BindTexture(gl.TEXTURE_2D, 0);
            self._texure = 0;
        } else {
            if (self._textures.get(image)) |*texture| {
                if (self._texure != texture.resource.handle) {
                    texture.resource.bind();
                    self._texure = texture.resource.handle;
                }
            } else {
                unreachable;
            }
        }
    }

    fn setStencilMask(self: *Self, mask: i32) void {
        if (self._stencilMask != mask) {
            self._stencilMask = mask;
            gl.StencilMask(mask);
        }
    }

    fn setStencilFunc(self: *Self, stencilFunc: StencilFunc) void {
        if (self._stencilFunc != stencilFunc) {
            self._stencilFunc = stencilFunc;
            gl.StencilFunc(stencilFunc.func, stencilFunc.ref, stencilFunc.mask);
        }
    }

    fn fill(self: *Self, call: nanovg.GLNVGcall, pPath: [*c]const nanovg.GLNVGpath) void {
        const paths = pPath[call.pathOffset .. call.pathOffset + call.pathCount];

        // Draw shapes
        gl.enable(gl.STENCIL_TEST);
        self.stencilMask(0xff);
        self.stencilFunc(StencilFunc(gl.ALWAYS, 0, 0xff));
        gl.colorMask(gl.FALSE, gl.FALSE, gl.FALSE, gl.FALSE);

        // set bindpoint for solid loc
        self.setUniforms(call.uniformOffset);
        self.bind_texture(0);

        gl.stencilOpSeparate(gl.FRONT, gl.KEEP, gl.KEEP, gl.INCR_WRAP);
        gl.stencilOpSeparate(gl.BACK, gl.KEEP, gl.KEEP, gl.DECR_WRAP);
        gl.disable(gl.CULL_FACE);
        for (paths) |*path| {
            gl.DrawArrays(gl.TRIANGLE_FAN, path.fillOffset, path.fillCount);
        }
        gl.Enable(gl.CULL_FACE);

        // Draw anti-aliased pixels
        gl.ColorMask(gl.TRUE, gl.TRUE, gl.TRUE, gl.TRUE);

        self.setUniforms(call.uniformOffset + self._pipeline._fragSize);
        self.bind_texture(call.image);

        // Draw fill
        self.stencilFunc(StencilFunc(gl.NOTEQUAL, 0x0, 0xff));
        gl.StencilOp(gl.ZERO, gl.ZERO, gl.ZERO);
        gl.DrawArrays(gl.TRIANGLE_STRIP, call.triangleOffset, call.triangleCount);

        gl.Disable(gl.STENCIL_TEST);
    }

    fn convexFill(self: *Self, call: nanovg.GLNVGcall, pPaths: [*c]const nanovg.GLNVGpath) void {
        const paths = pPaths[call.pathOffset .. call.pathOffset + call.pathCount];

        self.setUniforms(call.uniformOffset);
        self.bind_texture(call.image);

        for (paths) |path| {
            gl.DrawArrays(gl.TRIANGLE_FAN, path.fillOffset, path.fillCount);
            // Draw fringes
            if (path.strokeCount > 0) {
                gl.DrawArrays(gl.TRIANGLE_STRIP, path.strokeOffset, path.strokeCount);
            }
        }
    }

    fn stroke(self: *Self, call: nanovg.GLNVGcall, pPaths: [*c]const nanovg.GLNVGpath) void {
        const paths = pPaths[call.pathOffset .. call.pathOffset + call.pathCount];
        self.setUniforms(call.uniformOffset);
        self.bind_texture(call.image);
        // Draw Strokes
        for (paths) |path| {
            gl.DrawArrays(gl.TRIANGLE_STRIP, path.strokeOffset, path.strokeCount);
        }
    }

    fn triangles(self: *Self, call: nanovg.GLNVGcall) void {
        self.setUniforms(call.uniformOffset);
        self.bind_texture(call.image);
        gl.DrawArrays(gl.TRIANGLES, call.triangleOffset, call.triangleCount);
    }

    fn begin(self: *Self) void {
        _ = self;
        gl.Enable(gl.CULL_FACE);
        gl.CullFace(gl.BACK);
        gl.FrontFace(gl.CCW);
        gl.Enable(gl.BLEND);
        gl.Disable(gl.DEPTH_TEST);
        gl.Disable(gl.SCISSOR_TEST);
        gl.ColorMask(gl.TRUE, gl.TRUE, gl.TRUE, gl.TRUE);
        gl.StencilMask(0xffffffff);
        gl.StencilOp(gl.KEEP, gl.KEEP, gl.KEEP);
        gl.StencilFunc(gl.ALWAYS, 0, 0xffffffff);
        gl.BindTexture(gl.TEXTURE_2D, 0);
    }

    fn end(self: *Self) void {
        _ = self;
        gl.DisableVertexAttribArray(0);
        gl.DisableVertexAttribArray(1);
        gl.BindVertexArray(0);
        gl.Disable(gl.CULL_FACE);
        gl.BindBuffer(gl.ARRAY_BUFFER, 0);
        gl.UseProgram(0);
        gl.BindTexture(gl.TEXTURE_2D, 0);
    }

    fn render(self: *Self, data: [*c]const nanovg.NVGdrawData) void {
        if (self._pipeline == null) {
            self._pipeline = Pipeline{};
            self._vertArr = gl.GenVertexArrays(1);
            self._vertBuf = gl.GenBuffers(1);
            self._fragBuf = gl.GenBuffers(1);
        }

        // Upload ubo for frag shaders
        gl.BindBuffer(gl.UNIFORM_BUFFER, self._fragBuf);
        gl.BufferData(gl.UNIFORM_BUFFER, data.uniformByteSize, data.pUniform, gl.STREAM_DRAW);

        // Upload vertex data
        gl.BindVertexArray(self._vertArr);
        gl.BindBuffer(gl.ARRAY_BUFFER, self._vertBuf);
        gl.BufferData(gl.ARRAY_BUFFER, data.vertexCount * @sizeOf(nanovg.NVGvertex), data.pVertex, gl.STREAM_DRAW);
        gl.EnableVertexAttribArray(0);
        gl.EnableVertexAttribArray(1);
        gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, @sizeOf(nanovg.NVGvertex), null);
        gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, @sizeOf(nanovg.NVGvertex), @intToPtr(*anyopaque, 0 + 2 * @sizeOf(f32)));

        gl.BindBuffer(gl.UNIFORM_BUFFER, self._fragBuf);

        const calls = data.drawData[0..data.drawCount];
        const p_path = data.pPath;

        // Set view and texture just once per frame.
        self._pipeline.use();
        self._pipeline.texture.set_int(0);
        self._pipeline.view.set_float2(data.view);
        gl.ActiveTexture(gl.TEXTURE0);

        for (calls) |*call| {
            const blendFunc = blendCompositeOperation(call.blendFunc);
            self.blendFuncSeparate(blendFunc);
            switch (call.type) {
                .GLNVG_FILL => self.fill(call, p_path),
                .GLNVG_CONVEXFILL => self.convexFill(call, p_path),
                .GLNVG_STROKE => self.stroke(call, p_path),
                .GLNVG_TRIANGLES => self.triangles(call),
            }
        }
    }
};

var g_renderer: ?Renderer = null;

// renderCreateTexture: ?*fn (params: ?*NVGparams, _type: c_int, w: c_int, h: c_int, imageFlags: c_int, data: ?*const u8) c_int,
fn createTexture(_: ?*nanovg.NVGparams, texture_type: c_int, w: c_int, h: c_int, imageFlags: c_int, data: ?*const u8) c_int {
    return g_renderer.?.createTexture(@intToEnum(nanovg.NVGtexture, texture_type), w, h, imageFlags, data);
}

// renderDeleteTexture: ?*fn (params: ?*NVGparams, image: c_int) c_int,
fn deleteTexture(_: ?*nanovg.NVGparams, image: c_int) c_int {
    return if (g_renderer.?.deleteTexture(image)) 1 else 0;
}

// renderUpdateTexture: ?*fn (params: ?*NVGparams, image: c_int, x: c_int, y: c_int, w: c_int, h: c_int, data: ?*const u8) c_int,
fn updateTexture(_: ?*nanovg.NVGparams, image: c_int, x: c_int, y: c_int, w: c_int, h: c_int, p: ?*const u8) c_int {
    if (p) |data| {
        return if (g_renderer.?.updateTexture(image, x, y, w, h, data)) 1 else 0;
    } else {
        return 0;
    }
}

// renderGetTexture: ?*fn (params: ?*NVGparams, image: c_int) ?*NVGtextureInfo,
fn getTexture(_: ?*nanovg.NVGparams, image: c_int) ?*nanovg.NVGtextureInfo {
    return g_renderer.?.getTexture(image);
}

pub fn init(allocator: std.mem.Allocator, vg: *nanovg.NVGcontext) void {
    g_renderer = Renderer.init(allocator);
    var params = nanovg.nvgParams(vg);
    params.?.renderCreateTexture = @ptrCast(?*const fn (params: ?*nanovg.NVGparams, _type: c_int, w: c_int, h: c_int, imageFlags: c_int, data: ?*const u8) c_int, createTexture);
    params.?.renderDeleteTexture = @ptrCast(?*const fn (params: ?*nanovg.NVGparams, image: c_int) c_int, deleteTexture);
    params.?.renderUpdateTexture = @ptrCast(?*const fn (params: ?*nanovg.NVGparams, image: c_int, x: c_int, y: c_int, w: c_int, h: c_int, data: ?*const u8) c_int, updateTexture);
    params.?.renderGetTexture = @ptrCast(?*const fn (params: ?*nanovg.NVGparams, image: c_int) ?*nanovg.NVGtextureInfo, getTexture);
}

pub fn deinit() void {
    g_renderer.deinit();
    g_renderer = null;
}

pub fn render(data: *nanovg.NVGdrawData) void {
    g_renderer.begin();
    defer g_renderer.end();
    g_renderer.render(data);
}
