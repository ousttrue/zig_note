const std = @import("std");
const gl = @import("gl");
const glo = @import("glo");
const nanovg = @import("nanovg");

// P_PATH = ctypes.POINTER(nanovg.GLNVGpath)
// P_CALL = ctypes.POINTER(nanovg.GLNVGcall)
// FLAGS = 0

const VS = @embedFile("./nanovg.vs");
const FS = @embedFile("./nanovg.fs");

fn checkGlError() void {
    while (true) {
        const err = gl.getError();
        switch (err) {
            gl.NO_ERROR => break,
            else => {
                std.debug.print("Error {}\n", .{err});
            },
        }
    }
}

fn convertBlendFuncFactor(factor: nanovg.NVGblendFactor) u32 {
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

    fn blendCompositeOperation(op: nanovg.NVGcompositeOperationState) GLNVGblend {
        const blend = GLNVGblend{ .srcRGB = convertBlendFuncFactor(op.srcRGB), .dstRGB = convertBlendFuncFactor(op.dstRGB), .srcAlpha = convertBlendFuncFactor(op.srcAlpha), .dstAlpha = convertBlendFuncFactor(op.dstAlpha) };
        if (blend.srcRGB == gl.INVALID_ENUM or blend.dstRGB == gl.INVALID_ENUM or blend.srcAlpha == gl.INVALID_ENUM or blend.dstAlpha == gl.INVALID_ENUM) {
            return GLNVGblend{ .srcRGB = gl.ONE, .dstRGB = gl.ONE_MINUS_SRC_ALPHA, .srcAlpha = gl.ONE, .dstAlpha = gl.ONE_MINUS_SRC_ALPHA };
        }
        return blend;
    }
};

const StencilFunc = struct {
    func: c_uint = gl.ALWAYS,
    ref: c_int = 0,
    mask: c_uint = 0xffffffff,
};

const Texture = struct {
    info: nanovg.NVGtextureInfo,
    resource: glo.Texture,
};

const Pipeline = struct {
    const Self = @This();

    shader: glo.Shader,
    fragSize: usize = 0,
    texture: glo.UniformLocation,
    view: glo.UniformLocation,
    frag: glo.UniformBlockIndex,

    fn init(allocator: std.mem.Allocator) Self {
        const shader = glo.Shader.load(allocator, VS, FS) catch {
            @panic(glo.getErrorMessage());
        };

        var self = Self{
            .shader = shader,
            .texture = glo.UniformLocation.init(shader.handle, "tex"),
            .view = glo.UniformLocation.init(shader.handle, "viewSize"),
            // UBO
            .frag = glo.UniformBlockIndex.init(shader.handle, "frag"),
        };

        gl.uniformBlockBinding(shader.handle, self.frag.index, 0);

        var _align: gl.GLint = undefined;
        gl.getIntegerv(gl.UNIFORM_BUFFER_OFFSET_ALIGNMENT, &_align);
        self.fragSize = @sizeOf(nanovg.GLNVGfragUniforms) + @as(usize, @intCast(_align)) - @as(usize, @intCast(@mod(@sizeOf(nanovg.GLNVGfragUniforms), _align)));

        checkGlError();

        return self;
    }

    fn use(self: *Self) void {
        self.shader.use();
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

    allocator: std.mem.Allocator,
    next_id: c_int = 1,
    textures: std.AutoHashMap(c_int, Texture),
    pipeline: ?Pipeline = null,
    texture: gl.GLuint = 0,
    stencilMask: u32 = 0xffffffff,
    stencilFunc: StencilFunc = undefined,
    // _srcRGB: = {}
    // _srcAlpha: = {}
    // _dstRGB: = {}
    // _dstAlpha: = {}
    // shader: = None
    vertBuf: gl.GLuint = 0,
    vertArr: gl.GLuint = 0,
    fragBuf: gl.GLuint = 0,
    // cache
    blendFunc: GLNVGblend = .{},

    fn init(allocator: std.mem.Allocator) Self {
        return .{
            .allocator = allocator,
            .textures = std.AutoHashMap(c_int, Texture).init(allocator),
        };
    }

    fn deinit(self: *Self) void {
        self.textures.deinit();
    }

    fn createTexture(self: *Self, image_type: nanovg.NVGtexture, w: i32, h: i32, flags: i32, data: ?*const u8) i32 {
        const id = self.next_id;
        self.next_id += 1;

        const resource = glo.Texture.init(w, h, gl_pixel_type(image_type), data);
        const info = nanovg.NVGtextureInfo{ ._id = id, ._handle = 0, ._width = w, ._height = h, ._type = @intFromEnum(image_type), ._flags = flags };
        self.textures.put(id, Texture{ .info = info, .resource = resource }) catch @panic("put");
        return id;
    }

    fn updateTexture(self: *Self, image: i32, x: c_int, y: c_int, w: c_int, h: c_int, data: *const u8) bool {
        if (self.textures.get(image)) |*texture| {
            texture.resource.update(x, y, w, h, data);
            return true;
        }
        return false;
    }

    fn deleteTexture(self: *Self, image: i32) bool {
        return self.textures.remove(image);
    }

    fn getTexture(self: *Self, image: i32) ?*nanovg.NVGtextureInfo {
        if (self.textures.get(image)) |*texture| {
            return &texture.info;
        } else {
            return null;
        }
    }

    fn blendFuncSeparate(self: *Self, blend: GLNVGblend) void {
        if (!std.meta.eql(self.blendFunc, blend)) {
            self.blendFunc = blend;
            gl.blendFuncSeparate(blend.srcRGB, blend.dstRGB, blend.srcAlpha, blend.dstAlpha);
        }
    }

    fn setUniforms(self: *Self, uniformOffset: usize) void {
        gl.bindBufferRange(gl.UNIFORM_BUFFER, 0, self.fragBuf, uniformOffset, @sizeOf(nanovg.GLNVGfragUniforms));
    }

    fn bindTexture(self: *Self, image: i32) void {
        if (image == 0) {
            gl.bindTexture(gl.TEXTURE_2D, 0);
            self.texture = 0;
        } else {
            if (self.textures.get(image)) |*texture| {
                if (self.texture != texture.resource.handle) {
                    texture.resource.bind();
                    self.texture = texture.resource.handle;
                }
            } else {
                unreachable;
            }
        }
    }

    fn setStencilMask(self: *Self, mask: u32) void {
        if (self.stencilMask != mask) {
            self.stencilMask = mask;
            gl.stencilMask(mask);
        }
    }

    fn setStencilFunc(self: *Self, stencilFunc: StencilFunc) void {
        if (!std.meta.eql(self.stencilFunc, stencilFunc)) {
            self.stencilFunc = stencilFunc;
            gl.stencilFunc(stencilFunc.func, stencilFunc.ref, stencilFunc.mask);
        }
    }

    fn fill(self: *Self, call: *const nanovg.GLNVGcall, pPath: [*]const nanovg.GLNVGpath) void {
        const paths = pPath[@as(usize, @intCast(call.pathOffset))..@as(usize, @intCast(call.pathOffset + call.pathCount))];

        // Draw shapes
        gl.enable(gl.STENCIL_TEST);
        self.setStencilMask(0xff);
        self.setStencilFunc(StencilFunc{ .func = gl.ALWAYS, .ref = 0, .mask = 0xff });
        gl.colorMask(gl.FALSE, gl.FALSE, gl.FALSE, gl.FALSE);

        // set bindpoint for solid loc
        self.setUniforms(@as(usize, @intCast(call.uniformOffset)));
        self.bindTexture(0);

        gl.stencilOpSeparate(gl.FRONT, gl.KEEP, gl.KEEP, gl.INCR_WRAP);
        gl.stencilOpSeparate(gl.BACK, gl.KEEP, gl.KEEP, gl.DECR_WRAP);
        gl.disable(gl.CULL_FACE);
        for (paths) |*path| {
            gl.drawArrays(gl.TRIANGLE_FAN, path.fillOffset, path.fillCount);
        }
        gl.enable(gl.CULL_FACE);

        // Draw anti-aliased pixels
        gl.colorMask(gl.TRUE, gl.TRUE, gl.TRUE, gl.TRUE);

        self.setUniforms(@as(usize, @intCast(call.uniformOffset)) + self.pipeline.?.fragSize);
        self.bindTexture(call.image);

        // Draw fill
        self.setStencilFunc(StencilFunc{ .func = gl.NOTEQUAL, .ref = 0x0, .mask = 0xff });
        gl.stencilOp(gl.ZERO, gl.ZERO, gl.ZERO);
        gl.drawArrays(gl.TRIANGLE_STRIP, call.triangleOffset, call.triangleCount);
        gl.disable(gl.STENCIL_TEST);
    }

    fn convexFill(self: *Self, call: *nanovg.GLNVGcall, pPaths: [*c]const nanovg.GLNVGpath) void {
        const paths = pPaths[@as(usize, @intCast(call.pathOffset))..@as(usize, @intCast(call.pathOffset + call.pathCount))];

        self.setUniforms(@as(usize, @intCast(call.uniformOffset)));
        self.bindTexture(call.image);

        for (paths) |path| {
            gl.drawArrays(gl.TRIANGLE_FAN, path.fillOffset, path.fillCount);
            // Draw fringes
            if (path.strokeCount > 0) {
                gl.drawArrays(gl.TRIANGLE_STRIP, path.strokeOffset, path.strokeCount);
            }
        }
    }

    fn stroke(self: *Self, call: *nanovg.GLNVGcall, pPaths: [*c]const nanovg.GLNVGpath) void {
        const paths = pPaths[@as(usize, @intCast(call.pathOffset))..@as(usize, @intCast(call.pathOffset + call.pathCount))];
        self.setUniforms(@as(usize, @intCast(call.uniformOffset)));
        self.bindTexture(call.image);
        // Draw Strokes
        for (paths) |path| {
            gl.drawArrays(gl.TRIANGLE_STRIP, path.strokeOffset, path.strokeCount);
        }
    }

    fn triangles(self: *Self, call: *nanovg.GLNVGcall) void {
        self.setUniforms(@as(usize, @intCast(call.uniformOffset)));
        self.bindTexture(call.image);
        gl.drawArrays(gl.TRIANGLES, call.triangleOffset, call.triangleCount);
    }

    fn begin(self: *Self) void {
        _ = self;
        gl.enable(gl.CULL_FACE);
        gl.cullFace(gl.BACK);
        gl.frontFace(gl.CCW);
        gl.enable(gl.BLEND);
        gl.disable(gl.DEPTH_TEST);
        gl.disable(gl.SCISSOR_TEST);
        gl.colorMask(gl.TRUE, gl.TRUE, gl.TRUE, gl.TRUE);
        gl.stencilMask(0xffffffff);
        gl.stencilOp(gl.KEEP, gl.KEEP, gl.KEEP);
        gl.stencilFunc(gl.ALWAYS, 0, 0xffffffff);
        gl.bindTexture(gl.TEXTURE_2D, 0);
    }

    fn end(self: *Self) void {
        _ = self;
        gl.disableVertexAttribArray(0);
        gl.disableVertexAttribArray(1);
        gl.bindVertexArray(0);
        gl.disable(gl.CULL_FACE);
        gl.bindBuffer(gl.ARRAY_BUFFER, 0);
        gl.useProgram(0);
        gl.bindTexture(gl.TEXTURE_2D, 0);
    }

    fn render(self: *Self, data: *const nanovg.NVGdrawData) void {
        if (data.drawCount == 0) {
            return;
        }

        if (self.pipeline == null) {
            self.pipeline = Pipeline.init(self.allocator);
            gl.genVertexArrays(1, &self.vertArr);
            gl.genBuffers(1, &self.vertBuf);
            gl.genBuffers(1, &self.fragBuf);
        }

        // Upload ubo for frag shaders
        gl.bindBuffer(gl.UNIFORM_BUFFER, self.fragBuf);
        gl.bufferData(gl.UNIFORM_BUFFER, data.uniformByteSize, data.pUniform, gl.STREAM_DRAW);

        // Upload vertex data
        gl.bindVertexArray(self.vertArr);
        gl.bindBuffer(gl.ARRAY_BUFFER, self.vertBuf);
        gl.bufferData(gl.ARRAY_BUFFER, data.vertexCount * @sizeOf(nanovg.NVGvertex), data.pVertex, gl.STREAM_DRAW);
        gl.enableVertexAttribArray(0);
        gl.enableVertexAttribArray(1);
        gl.vertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, @sizeOf(nanovg.NVGvertex), null);
        gl.vertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, @sizeOf(nanovg.NVGvertex), @as(*anyopaque, @ptrFromInt(0 + 2 * @sizeOf(f32))));

        gl.bindBuffer(gl.UNIFORM_BUFFER, self.fragBuf);

        const calls = @as([*]nanovg.GLNVGcall, @ptrCast(data.drawData.?))[0..data.drawCount];
        const p_path = data.pPath;

        // Set view and texture just once per frame.
        self.pipeline.?.use();
        self.pipeline.?.texture.setInt(0);
        self.pipeline.?.view.setFloat2(&data.view[0]);
        gl.activeTexture(gl.TEXTURE0);

        for (calls) |*call| {
            const blendFunc = GLNVGblend.blendCompositeOperation(call.blendFunc);
            self.blendFuncSeparate(blendFunc);
            switch (@as(nanovg.GLNVGcallType, @enumFromInt(call.type))) {
                .GLNVG_FILL => self.fill(call, @as([*]const nanovg.GLNVGpath, @ptrCast(p_path))),
                .GLNVG_CONVEXFILL => self.convexFill(call, p_path),
                .GLNVG_STROKE => self.stroke(call, p_path),
                .GLNVG_TRIANGLES => self.triangles(call),
                else => {},
            }
        }
    }
};

var g_renderer: ?Renderer = null;

// renderCreateTexture: ?*fn (params: ?*NVGparams, _type: c_int, w: c_int, h: c_int, imageFlags: c_int, data: ?*const u8) c_int,
fn createTexture(_: ?*nanovg.NVGparams, texture_type: c_int, w: c_int, h: c_int, imageFlags: c_int, data: ?*const u8) c_int {
    return g_renderer.?.createTexture(@as(nanovg.NVGtexture, @enumFromInt(texture_type)), w, h, imageFlags, data);
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
    params.?.renderCreateTexture = @as(?*const fn (params: ?*nanovg.NVGparams, _type: c_int, w: c_int, h: c_int, imageFlags: c_int, data: ?*const u8) c_int, @ptrCast(createTexture));
    params.?.renderDeleteTexture = @as(?*const fn (params: ?*nanovg.NVGparams, image: c_int) c_int, @ptrCast(deleteTexture));
    params.?.renderUpdateTexture = @as(?*const fn (params: ?*nanovg.NVGparams, image: c_int, x: c_int, y: c_int, w: c_int, h: c_int, data: ?*const u8) c_int, @ptrCast(updateTexture));
    params.?.renderGetTexture = @as(?*const fn (params: ?*nanovg.NVGparams, image: c_int) ?*nanovg.NVGtextureInfo, @ptrCast(getTexture));
}

pub fn deinit() void {
    g_renderer.deinit();
    g_renderer = null;
}

pub fn render(data: *nanovg.NVGdrawData) void {
    g_renderer.?.begin();
    defer g_renderer.?.end();
    g_renderer.?.render(data);
}
