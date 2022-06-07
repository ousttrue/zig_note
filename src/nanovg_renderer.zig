const nanovg = @import("nanovg");
const NanoVgRenderer = struct {
    const Self = @This();

    vg: [*c]nanovg.NVGcontext,
    font_name: []const u8 = "nanovg_font",
    font_path: []const u8 = "",
    font_initialized: bool = false,

    pub fn init(font_path: ?[]const u8, font_name: ?[]const u8) Self {
        var self = Self{ .vg = nanovg.nvgCreate(nanovg.NVGcreateFlags.NVG_ANTIALIAS | nanovg.NVGcreateFlags.NVG_STENCIL_STROKES | nanovg.NVGcreateFlags.NVG_DEBUG) };
        std.debug.assert(self.vg != null);
        // nanovg_impl_opengl3.init(self.vg)

        // if not font_path or not font_path.exists():
        //     font_path = get_system_font()

        self.font_path = font_path;
        self.font_name = font_name;
    }

    pub fn deinit(self: *Self) void {
        // nanovg_impl_opengl3.delete()
    }

    //     def init_font(self):
    //         '''
    //         must after nanovg.nvgBeginFrame
    //         '''
    //         if self.font_initialized:
    //             return
    //         self.fontNormal = nanovg.nvgCreateFont(
    //             self.vg, self.font_name, self.font_path)
    //         if self.fontNormal == -1:
    //             raise RuntimeError("Could not add font italic.")
    //         self.font_initialized = True

    pub fn beginFrame(self: *Self, width: f32, height: f32) ?*nanovg.NVGcontext {
        if (width == 0 or height == 0) {
            return null;
        }
        const ratio = width / height;
        nanovg.nvgBeginFrame(self.vg, width, height, ratio);
        self.init_font();
        return self.vg;
    }

    pub fn endFrame(self: *Self) void {
        // nanovg_impl_opengl3.render(nanovg.nvgGetDrawData(self.vg))
    }
};

//     @contextlib.contextmanager
//     def render(self, w, h):
//         vg = self.begin_frame(w, h)
//         try:
//             if vg:
//                 yield vg
//         finally:
//             self.end_frame()

// def nvg_line_from_to(vg, x0, y0, x1, y1):
//     nanovg.nvgSave(vg)
//     nanovg.nvgStrokeWidth(vg, 1.0)
//     nanovg.nvgStrokeColor(vg, nanovg.nvgRGBA(0, 192, 255, 255))
//     nanovg.nvgBeginPath(vg)
//     nanovg.nvgMoveTo(vg, x0, y0)
//     nanovg.nvgLineTo(vg, x1, y1)
//     nanovg.nvgStroke(vg)
//     nanovg.nvgRestore(vg)

// def nvg_text(vg, font_name, x, y):
//     nanovg.nvgFontSize(vg, 15.0)
//     nanovg.nvgFontFace(vg, font_name)
//     nanovg.nvgFillColor(vg, nanovg.nvgRGBA(255, 255, 255, 255))
//     nanovg.nvgTextAlign(vg, nanovg.NVGalign.NVG_ALIGN_LEFT
//                         | nanovg.NVGalign.NVG_ALIGN_MIDDLE)
//     nanovg.nvgText(vg, x, y, f'{x}, {y}', None)  # type: ignore
