const std = @import("std");
const nanovg = @import("nanovg");
const nanovg_impl_opengl3 = @import("./nanovg_impl_opengl3.zig");

fn get_system_font() [:0]const u8 {
    return "C:/Windows/Fonts/msgothic.ttc";
    // else:
    //     return pathlib.Path('/usr/share/fonts/liberation-fonts/LiberationMono-Regular.ttf')
}

pub const NanoVgRenderer = struct {
    const Self = @This();

    vg: *nanovg.NVGcontext,
    font_name: [:0]const u8,
    font_path: [:0]const u8,
    font_initialized: bool = false,
    fontNormal: c_int = 0,

    pub fn init(allocator: std.mem.Allocator, font_path: ?[:0]const u8, font_name: ?[:0]const u8) Self {
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
        nanovg_impl_opengl3.delete();
        self.nvgDestroy(self.vg);
    }

    pub fn init_font(self: *Self) void {
        // must after nanovg.nvgBeginFrame
        if (self.font_initialized) {
            return;
        }
        self.fontNormal = nanovg.nvgCreateFont(self.vg, self.font_name, self.font_path);
        std.debug.assert(self.fontNormal != -1);
        self.font_initialized = true;
    }

    pub fn begin(self: *Self, width: f32, height: f32) ?*nanovg.NVGcontext {
        if (width == 0 or height == 0) {
            return null;
        }
        const ratio = width / height;
        nanovg.nvgBeginFrame(self.vg, width, height, ratio);
        self.init_font();
        return self.vg;
    }

    pub fn end(self: *Self) void {
        if (nanovg.nvgGetDrawData(self.vg)) |data| {
            nanovg_impl_opengl3.render(data);
        }
    }
};

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
