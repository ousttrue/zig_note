const std = @import("std");
const nanovg = @import("nanovg");
const nanovg_impl_opengl3 = @import("./nanovg_impl_opengl3.zig");

fn get_system_font() []const u8 {
    return "C:/Windows/Fonts/msgothic.ttc";
    // else:
    //     return pathlib.Path('/usr/share/fonts/liberation-fonts/LiberationMono-Regular.ttf')
}

pub const NanoVgRenderer = struct {
    const Self = @This();

    vg: *nanovg.NVGcontext,
    font_name: []const u8,
    font_path: []const u8,
    font_initialized: bool = false,

    pub fn init(allocator: std.mem.Allocator, font_path: ?[]const u8, font_name: ?[]const u8) Self {
        var self = Self{
            .vg = nanovg.nvgCreate(@enumToInt(nanovg.NVGcreateFlags.NVG_ANTIALIAS) |
                @enumToInt(nanovg.NVGcreateFlags.NVG_STENCIL_STROKES) |
                @enumToInt(nanovg.NVGcreateFlags.NVG_DEBUG)).?,
            .font_path = font_path orelse get_system_font(),
            .font_name = font_name orelse "nanovg_font",
        };
        nanovg_impl_opengl3.init(allocator, self.vg);

        return self;
    }

    pub fn deinit(self: *Self) void {
        _ = self;
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
        _ = self;
        nanovg_impl_opengl3.render(nanovg.nvgGetDrawData(self.vg));
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
