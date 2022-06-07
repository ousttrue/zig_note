// this is generated by rawtypes
const expect = @import("std").testing.expect;
pub const NVGcreateFlags = enum(c_int) {
    NVG_ANTIALIAS = 1,
    NVG_STENCIL_STROKES = 2,
    NVG_DEBUG = 4,
};

pub const NVGwinding = enum(c_int) {
    NVG_CCW = 1,
    NVG_CW = 2,
};

pub const NVGsolidity = enum(c_int) {
    NVG_SOLID = 1,
    NVG_HOLE = 2,
};

pub const NVGlineCap = enum(c_int) {
    NVG_BUTT = 0,
    NVG_ROUND = 1,
    NVG_SQUARE = 2,
    NVG_BEVEL = 3,
    NVG_MITER = 4,
};

pub const NVGalign = enum(c_int) {
    NVG_ALIGN_LEFT = 1,
    NVG_ALIGN_CENTER = 2,
    NVG_ALIGN_RIGHT = 4,
    NVG_ALIGN_TOP = 8,
    NVG_ALIGN_MIDDLE = 16,
    NVG_ALIGN_BOTTOM = 32,
    NVG_ALIGN_BASELINE = 64,
};

pub const NVGblendFactor = enum(c_int) {
    NVG_INVALID = 0,
    NVG_ZERO = 1,
    NVG_ONE = 2,
    NVG_SRC_COLOR = 4,
    NVG_ONE_MINUS_SRC_COLOR = 8,
    NVG_DST_COLOR = 16,
    NVG_ONE_MINUS_DST_COLOR = 32,
    NVG_SRC_ALPHA = 64,
    NVG_ONE_MINUS_SRC_ALPHA = 128,
    NVG_DST_ALPHA = 256,
    NVG_ONE_MINUS_DST_ALPHA = 512,
    NVG_SRC_ALPHA_SATURATE = 1024,
};

pub const NVGcompositeOperation = enum(c_int) {
    NVG_SOURCE_OVER = 0,
    NVG_SOURCE_IN = 1,
    NVG_SOURCE_OUT = 2,
    NVG_ATOP = 3,
    NVG_DESTINATION_OVER = 4,
    NVG_DESTINATION_IN = 5,
    NVG_DESTINATION_OUT = 6,
    NVG_DESTINATION_ATOP = 7,
    NVG_LIGHTER = 8,
    NVG_COPY = 9,
    NVG_XOR = 10,
};

pub const NVGimageFlags = enum(c_int) {
    NVG_IMAGE_GENERATE_MIPMAPS = 1,
    NVG_IMAGE_REPEATX = 2,
    NVG_IMAGE_REPEATY = 4,
    NVG_IMAGE_FLIPY = 8,
    NVG_IMAGE_PREMULTIPLIED = 16,
    NVG_IMAGE_NEAREST = 32,
};

pub const NVGtexture = enum(c_int) {
    NVG_TEXTURE_ALPHA = 1,
    NVG_TEXTURE_RGBA = 2,
};

pub const GLNVGcallType = enum(c_int) {
    GLNVG_NONE = 0,
    GLNVG_FILL = 1,
    GLNVG_CONVEXFILL = 2,
    GLNVG_STROKE = 3,
    GLNVG_TRIANGLES = 4,
};

pub const GLNVGshaderType = enum(c_int) {
    NSVG_SHADER_FILLGRAD = 0,
    NSVG_SHADER_FILLIMG = 1,
    NSVG_SHADER_SIMPLE = 2,
    NSVG_SHADER_IMG = 3,
};

pub const NVGcontext = opaque {};
pub const NVGcolor = extern struct {
    _1080869267: extern union {
        rgba: [4]f32,
        _1096691997: extern struct {
            r: f32,
            g: f32,
            b: f32,
            a: f32,
        },
    },
};

test "sizeof NVGcolor" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(NVGcolor) == 16);
}

pub const NVGpaint = extern struct {
    xform: [6]f32,
    extent: [2]f32,
    radius: f32,
    feather: f32,
    innerColor: NVGcolor,
    outerColor: NVGcolor,
    image: c_int,
};

test "sizeof NVGpaint" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(NVGpaint) == 76);
}

pub const NVGcompositeOperationState = extern struct {
    srcRGB: NVGblendFactor,
    dstRGB: NVGblendFactor,
    srcAlpha: NVGblendFactor,
    dstAlpha: NVGblendFactor,
};

test "sizeof NVGcompositeOperationState" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(NVGcompositeOperationState) == 16);
}

pub const NVGglyphPosition = extern struct {
    str: ?[*:0]const u8,
    x: f32,
    minx: f32,
    maxx: f32,
};

test "sizeof NVGglyphPosition" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(NVGglyphPosition) == 24);
}

pub const NVGtextRow = extern struct {
    start: ?[*:0]const u8,
    end: ?[*:0]const u8,
    next: ?[*:0]const u8,
    width: f32,
    minx: f32,
    maxx: f32,
};

test "sizeof NVGtextRow" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(NVGtextRow) == 40);
}

pub const NVGscissor = extern struct {
    xform: [6]f32,
    extent: [2]f32,
};

test "sizeof NVGscissor" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(NVGscissor) == 32);
}

pub const NVGvertex = extern struct {
    x: f32,
    y: f32,
    u: f32,
    v: f32,
};

test "sizeof NVGvertex" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(NVGvertex) == 16);
}

pub const NVGpath = extern struct {
    first: c_int,
    count: c_int,
    closed: u8,
    nbevel: c_int,
    fill: ?*NVGvertex,
    nfill: c_int,
    stroke: ?*NVGvertex,
    nstroke: c_int,
    winding: c_int,
    convex: c_int,
};

test "sizeof NVGpath" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(NVGpath) == 56);
}

pub const GLNVGfragUniforms = extern struct {
    scissorMat: [12]f32,
    paintMat: [12]f32,
    innerCol: NVGcolor,
    outerCol: NVGcolor,
    scissorExt: [2]f32,
    scissorScale: [2]f32,
    extent: [2]f32,
    radius: f32,
    feather: f32,
    strokeMult: f32,
    strokeThr: f32,
    texType: c_int,
    type: c_int,
};

test "sizeof GLNVGfragUniforms" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(GLNVGfragUniforms) == 176);
}

pub const GLNVGcall = extern struct {
    type: c_int,
    image: c_int,
    pathOffset: c_int,
    pathCount: c_int,
    triangleOffset: c_int,
    triangleCount: c_int,
    uniformOffset: c_int,
    blendFunc: NVGcompositeOperationState,
};

test "sizeof GLNVGcall" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(GLNVGcall) == 44);
}

pub const GLNVGpath = extern struct {
    fillOffset: c_int,
    fillCount: c_int,
    strokeOffset: c_int,
    strokeCount: c_int,
};

test "sizeof GLNVGpath" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(GLNVGpath) == 16);
}

pub const NVGdrawData = extern struct {
    view: [2]f32,
    drawData: ?*GLNVGcall,
    drawCount: usize,
    pUniform: ?*anyopaque,
    uniformByteSize: c_int,
    pVertex: ?*NVGvertex,
    vertexCount: c_int,
    pPath: ?*GLNVGpath,
};

test "sizeof NVGdrawData" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(NVGdrawData) == 64);
}

pub const NVGtextureInfo = extern struct {
    _id: c_int,
    _handle: c_uint,
    _width: c_int,
    _height: c_int,
    _type: c_int,
    _flags: c_int,
};

test "sizeof NVGtextureInfo" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(NVGtextureInfo) == 24);
}

pub const NVGparams = extern struct {
    userPtr: ?*anyopaque,
    edgeAntiAlias: c_int,
    renderCreateTexture: ?*fn (params: ?*NVGparams, _type: c_int, w: c_int, h: c_int, imageFlags: c_int, data: ?*const u8) c_int,
    renderDeleteTexture: ?*fn (params: ?*NVGparams, image: c_int) c_int,
    renderUpdateTexture: ?*fn (params: ?*NVGparams, image: c_int, x: c_int, y: c_int, w: c_int, h: c_int, data: ?*const u8) c_int,
    renderGetTexture: ?*fn (params: ?*NVGparams, image: c_int) ?*NVGtextureInfo,
    renderUniformSize: ?*fn () c_int,
    _flags: c_int,
    _draw: ?*anyopaque,
};

test "sizeof NVGparams" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(NVGparams) == 72);
}

pub extern "c" fn nvgBeginFrame(ctx: ?*NVGcontext, windowWidth: f32, windowHeight: f32, devicePixelRatio: f32) void;
pub extern "c" fn nvgCancelFrame(ctx: ?*NVGcontext) void;
pub extern "c" fn nvgGlobalCompositeOperation(ctx: ?*NVGcontext, op: c_int) void;
pub extern "c" fn nvgGlobalCompositeBlendFunc(ctx: ?*NVGcontext, sfactor: c_int, dfactor: c_int) void;
pub extern "c" fn nvgGlobalCompositeBlendFuncSeparate(ctx: ?*NVGcontext, srcRGB: c_int, dstRGB: c_int, srcAlpha: c_int, dstAlpha: c_int) void;
pub extern "c" fn nvgRGB(r: u8, g: u8, b: u8) NVGcolor;
pub extern "c" fn nvgRGBf(r: f32, g: f32, b: f32) NVGcolor;
pub extern "c" fn nvgRGBA(r: u8, g: u8, b: u8, a: u8) NVGcolor;
pub extern "c" fn nvgRGBAf(r: f32, g: f32, b: f32, a: f32) NVGcolor;
pub extern "c" fn nvgLerpRGBA(c0: NVGcolor, c1: NVGcolor, u: f32) NVGcolor;
pub extern "c" fn nvgTransRGBA(c0: NVGcolor, a: u8) NVGcolor;
pub extern "c" fn nvgTransRGBAf(c0: NVGcolor, a: f32) NVGcolor;
pub extern "c" fn nvgHSL(h: f32, s: f32, l: f32) NVGcolor;
pub extern "c" fn nvgHSLA(h: f32, s: f32, l: f32, a: u8) NVGcolor;
pub extern "c" fn nvgSave(ctx: ?*NVGcontext) void;
pub extern "c" fn nvgRestore(ctx: ?*NVGcontext) void;
pub extern "c" fn nvgReset(ctx: ?*NVGcontext) void;
pub extern "c" fn nvgShapeAntiAlias(ctx: ?*NVGcontext, enabled: c_int) void;
pub extern "c" fn nvgStrokeColor(ctx: ?*NVGcontext, color: NVGcolor) void;
pub extern "c" fn nvgStrokePaint(ctx: ?*NVGcontext, paint: NVGpaint) void;
pub extern "c" fn nvgFillColor(ctx: ?*NVGcontext, color: NVGcolor) void;
pub extern "c" fn nvgFillPaint(ctx: ?*NVGcontext, paint: NVGpaint) void;
pub extern "c" fn nvgMiterLimit(ctx: ?*NVGcontext, limit: f32) void;
pub extern "c" fn nvgStrokeWidth(ctx: ?*NVGcontext, size: f32) void;
pub extern "c" fn nvgLineCap(ctx: ?*NVGcontext, cap: c_int) void;
pub extern "c" fn nvgLineJoin(ctx: ?*NVGcontext, join: c_int) void;
pub extern "c" fn nvgGlobalAlpha(ctx: ?*NVGcontext, alpha: f32) void;
pub extern "c" fn nvgResetTransform(ctx: ?*NVGcontext) void;
pub extern "c" fn nvgTransform(ctx: ?*NVGcontext, a: f32, b: f32, c: f32, d: f32, e: f32, f: f32) void;
pub extern "c" fn nvgTranslate(ctx: ?*NVGcontext, x: f32, y: f32) void;
pub extern "c" fn nvgRotate(ctx: ?*NVGcontext, angle: f32) void;
pub extern "c" fn nvgSkewX(ctx: ?*NVGcontext, angle: f32) void;
pub extern "c" fn nvgSkewY(ctx: ?*NVGcontext, angle: f32) void;
pub extern "c" fn nvgScale(ctx: ?*NVGcontext, x: f32, y: f32) void;
pub extern "c" fn nvgCurrentTransform(ctx: ?*NVGcontext, xform: ?*f32) void;
pub extern "c" fn nvgTransformIdentity(dst: ?*f32) void;
pub extern "c" fn nvgTransformTranslate(dst: ?*f32, tx: f32, ty: f32) void;
pub extern "c" fn nvgTransformScale(dst: ?*f32, sx: f32, sy: f32) void;
pub extern "c" fn nvgTransformRotate(dst: ?*f32, a: f32) void;
pub extern "c" fn nvgTransformSkewX(dst: ?*f32, a: f32) void;
pub extern "c" fn nvgTransformSkewY(dst: ?*f32, a: f32) void;
pub extern "c" fn nvgTransformMultiply(dst: ?*f32, src: ?*const f32) void;
pub extern "c" fn nvgTransformPremultiply(dst: ?*f32, src: ?*const f32) void;
pub extern "c" fn nvgTransformInverse(dst: ?*f32, src: ?*const f32) c_int;
pub extern "c" fn nvgTransformPoint(dstx: ?*f32, dsty: ?*f32, xform: ?*const f32, srcx: f32, srcy: f32) void;
pub extern "c" fn nvgDegToRad(deg: f32) f32;
pub extern "c" fn nvgRadToDeg(rad: f32) f32;
pub extern "c" fn nvgCreateImage(ctx: ?*NVGcontext, filename: ?[*:0]const u8, imageFlags: c_int) c_int;
pub extern "c" fn nvgCreateImageMem(ctx: ?*NVGcontext, imageFlags: c_int, data: ?*u8, ndata: c_int) c_int;
pub extern "c" fn nvgCreateImageRGBA(ctx: ?*NVGcontext, w: c_int, h: c_int, imageFlags: c_int, data: ?*const u8) c_int;
pub extern "c" fn nvgUpdateImage(ctx: ?*NVGcontext, image: c_int, data: ?*const u8) void;
pub extern "c" fn nvgImageSize(ctx: ?*NVGcontext, image: c_int, w: ?*c_int, h: ?*c_int) void;
pub extern "c" fn nvgDeleteImage(ctx: ?*NVGcontext, image: c_int) void;
pub extern "c" fn nvgLinearGradient(ctx: ?*NVGcontext, sx: f32, sy: f32, ex: f32, ey: f32, icol: NVGcolor, ocol: NVGcolor) NVGpaint;
pub extern "c" fn nvgBoxGradient(ctx: ?*NVGcontext, x: f32, y: f32, w: f32, h: f32, r: f32, f: f32, icol: NVGcolor, ocol: NVGcolor) NVGpaint;
pub extern "c" fn nvgRadialGradient(ctx: ?*NVGcontext, cx: f32, cy: f32, inr: f32, outr: f32, icol: NVGcolor, ocol: NVGcolor) NVGpaint;
pub extern "c" fn nvgImagePattern(ctx: ?*NVGcontext, ox: f32, oy: f32, ex: f32, ey: f32, angle: f32, image: c_int, alpha: f32) NVGpaint;
pub extern "c" fn nvgScissor(ctx: ?*NVGcontext, x: f32, y: f32, w: f32, h: f32) void;
pub extern "c" fn nvgIntersectScissor(ctx: ?*NVGcontext, x: f32, y: f32, w: f32, h: f32) void;
pub extern "c" fn nvgResetScissor(ctx: ?*NVGcontext) void;
pub extern "c" fn nvgBeginPath(ctx: ?*NVGcontext) void;
pub extern "c" fn nvgMoveTo(ctx: ?*NVGcontext, x: f32, y: f32) void;
pub extern "c" fn nvgLineTo(ctx: ?*NVGcontext, x: f32, y: f32) void;
pub extern "c" fn nvgBezierTo(ctx: ?*NVGcontext, c1x: f32, c1y: f32, c2x: f32, c2y: f32, x: f32, y: f32) void;
pub extern "c" fn nvgQuadTo(ctx: ?*NVGcontext, cx: f32, cy: f32, x: f32, y: f32) void;
pub extern "c" fn nvgArcTo(ctx: ?*NVGcontext, x1: f32, y1: f32, x2: f32, y2: f32, radius: f32) void;
pub extern "c" fn nvgClosePath(ctx: ?*NVGcontext) void;
pub extern "c" fn nvgPathWinding(ctx: ?*NVGcontext, dir: c_int) void;
pub extern "c" fn nvgArc(ctx: ?*NVGcontext, cx: f32, cy: f32, r: f32, a0: f32, a1: f32, dir: c_int) void;
pub extern "c" fn nvgRect(ctx: ?*NVGcontext, x: f32, y: f32, w: f32, h: f32) void;
pub extern "c" fn nvgRoundedRect(ctx: ?*NVGcontext, x: f32, y: f32, w: f32, h: f32, r: f32) void;
pub extern "c" fn nvgRoundedRectVarying(ctx: ?*NVGcontext, x: f32, y: f32, w: f32, h: f32, radTopLeft: f32, radTopRight: f32, radBottomRight: f32, radBottomLeft: f32) void;
pub extern "c" fn nvgEllipse(ctx: ?*NVGcontext, cx: f32, cy: f32, rx: f32, ry: f32) void;
pub extern "c" fn nvgCircle(ctx: ?*NVGcontext, cx: f32, cy: f32, r: f32) void;
pub extern "c" fn nvgFill(ctx: ?*NVGcontext) void;
pub extern "c" fn nvgStroke(ctx: ?*NVGcontext) void;
pub extern "c" fn nvgCreateFont(ctx: ?*NVGcontext, name: ?[*:0]const u8, filename: ?[*:0]const u8) c_int;
pub extern "c" fn nvgCreateFontAtIndex(ctx: ?*NVGcontext, name: ?[*:0]const u8, filename: ?[*:0]const u8, fontIndex: c_int) c_int;
pub extern "c" fn nvgCreateFontMem(ctx: ?*NVGcontext, name: ?[*:0]const u8, data: ?*u8, ndata: c_int, freeData: c_int) c_int;
pub extern "c" fn nvgCreateFontMemAtIndex(ctx: ?*NVGcontext, name: ?[*:0]const u8, data: ?*u8, ndata: c_int, freeData: c_int, fontIndex: c_int) c_int;
pub extern "c" fn nvgFindFont(ctx: ?*NVGcontext, name: ?[*:0]const u8) c_int;
pub extern "c" fn nvgAddFallbackFontId(ctx: ?*NVGcontext, baseFont: c_int, fallbackFont: c_int) c_int;
pub extern "c" fn nvgAddFallbackFont(ctx: ?*NVGcontext, baseFont: ?[*:0]const u8, fallbackFont: ?[*:0]const u8) c_int;
pub extern "c" fn nvgResetFallbackFontsId(ctx: ?*NVGcontext, baseFont: c_int) void;
pub extern "c" fn nvgResetFallbackFonts(ctx: ?*NVGcontext, baseFont: ?[*:0]const u8) void;
pub extern "c" fn nvgFontSize(ctx: ?*NVGcontext, size: f32) void;
pub extern "c" fn nvgFontBlur(ctx: ?*NVGcontext, blur: f32) void;
pub extern "c" fn nvgTextLetterSpacing(ctx: ?*NVGcontext, spacing: f32) void;
pub extern "c" fn nvgTextLineHeight(ctx: ?*NVGcontext, lineHeight: f32) void;
pub extern "c" fn nvgTextAlign(ctx: ?*NVGcontext, _align: c_int) void;
pub extern "c" fn nvgFontFaceId(ctx: ?*NVGcontext, font: c_int) void;
pub extern "c" fn nvgFontFace(ctx: ?*NVGcontext, font: ?[*:0]const u8) void;
pub extern "c" fn nvgText(ctx: ?*NVGcontext, x: f32, y: f32, string: ?[*:0]const u8, end: ?[*:0]const u8) f32;
pub extern "c" fn nvgTextBox(ctx: ?*NVGcontext, x: f32, y: f32, breakRowWidth: f32, string: ?[*:0]const u8, end: ?[*:0]const u8) void;
pub extern "c" fn nvgTextBounds(ctx: ?*NVGcontext, x: f32, y: f32, string: ?[*:0]const u8, end: ?[*:0]const u8, bounds: ?*f32) f32;
pub extern "c" fn nvgTextBoxBounds(ctx: ?*NVGcontext, x: f32, y: f32, breakRowWidth: f32, string: ?[*:0]const u8, end: ?[*:0]const u8, bounds: ?*f32) void;
pub extern "c" fn nvgTextGlyphPositions(ctx: ?*NVGcontext, x: f32, y: f32, string: ?[*:0]const u8, end: ?[*:0]const u8, positions: ?*NVGglyphPosition, maxPositions: c_int) c_int;
pub extern "c" fn nvgTextMetrics(ctx: ?*NVGcontext, ascender: ?*f32, descender: ?*f32, lineh: ?*f32) void;
pub extern "c" fn nvgTextBreakLines(ctx: ?*NVGcontext, string: ?[*:0]const u8, end: ?[*:0]const u8, breakRowWidth: f32, rows: ?*NVGtextRow, maxRows: c_int) c_int;
pub extern "c" fn nvgCreate(flags: c_int) ?*NVGcontext;
pub extern "c" fn nvgDelete(ctx: ?*NVGcontext) void;
pub extern "c" fn nvgParams(ctx: ?*NVGcontext) ?*NVGparams;
pub extern "c" fn nvgDebugDumpPathCache(ctx: ?*NVGcontext) void;
pub extern "c" fn nvgGetDrawData(ctx: ?*NVGcontext) ?*NVGdrawData;
