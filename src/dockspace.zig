const std = @import("std");
const imgui = @import("imgui");
const screen = @import("screen");
const TypeEraser = screen.TypeEraser;

pub fn dockspace(name: [*:0]const u8, toolbar_size: f32) i32 {
    var io = imgui.GetIO();
    io.ConfigFlags |= @intFromEnum(imgui.ImGuiConfigFlags._DockingEnable);

    const flags = (@intFromEnum(imgui.ImGuiWindowFlags._MenuBar) |
        @intFromEnum(imgui.ImGuiWindowFlags._NoDocking) |
        @intFromEnum(imgui.ImGuiWindowFlags._NoBackground) |
        @intFromEnum(imgui.ImGuiWindowFlags._NoTitleBar) |
        @intFromEnum(imgui.ImGuiWindowFlags._NoCollapse) |
        @intFromEnum(imgui.ImGuiWindowFlags._NoResize) |
        @intFromEnum(imgui.ImGuiWindowFlags._NoMove) |
        @intFromEnum(imgui.ImGuiWindowFlags._NoBringToFrontOnFocus) |
        @intFromEnum(imgui.ImGuiWindowFlags._NoNavFocus));

    const viewport = imgui.GetMainViewport() orelse @panic("GetMainViewport");
    const x = viewport.Pos.x;
    var y = viewport.Pos.y;
    const w = viewport.Size.x;
    var h = viewport.Size.y;
    y += toolbar_size;
    h -= toolbar_size;

    imgui.SetNextWindowPos(.{ .x = x, .y = y }, .{});
    imgui.SetNextWindowSize(.{ .x = w, .y = h }, .{});
    // imgui.set_next_window_viewport(viewport.id)
    imgui.PushStyleVar(@intFromEnum(imgui.ImGuiStyleVar._WindowBorderSize), 0.0);
    imgui.PushStyleVar(@intFromEnum(imgui.ImGuiStyleVar._WindowRounding), 0.0);

    // When using ImGuiDockNodeFlags_PassthruCentralNode, DockSpace() will render our background and handle the pass-thru hole, so we ask Begin() to not render a background.
    // local window_flags = self.window_flags
    // if bit.band(self.dockspace_flags, ) ~= 0 then
    //     window_flags = bit.bor(window_flags, const.ImGuiWindowFlags_.NoBackground)
    // end

    // Important: note that we proceed even if Begin() returns false (aka window is collapsed).
    // This is because we want to keep our DockSpace() active. If a DockSpace() is inactive,
    // all active windows docked into it will lose their parent and become undocked.
    // We cannot preserve the docking relationship between an active window and an inactive docking, otherwise
    // any change of dockspace/settings would lead to windows being stuck in limbo and never being visible.
    imgui.PushStyleVar_2(@intFromEnum(imgui.ImGuiStyleVar._WindowPadding), .{ .x = 0, .y = 0 });
    _ = imgui.Begin(name, .{ .p_open = null, .flags = flags });
    imgui.PopStyleVar(.{});
    imgui.PopStyleVar(.{ .count = 2 });

    // TODO:
    // Save off menu bar height for later.
    // menubar_height = imgui.internal.get_current_window().menu_bar_height()
    const menubar_height = 26;

    // DockSpace
    const dockspace_id = imgui.GetID(name);
    _ = imgui.DockSpace(dockspace_id, .{ .size = .{ .x = 0, .y = 0 }, .flags = @intFromEnum(imgui.ImGuiDockNodeFlags._PassthruCentralNode) });

    imgui.End();

    return menubar_height;
}

pub const Dock = struct {
    const Self = @This();

    ptr: *anyopaque,
    callback: fn (ptr: *anyopaque, p_open: *bool) void,
    name: [:0]const u8,
    is_open: bool = true,

    pub fn show(self: *Self) void {
        self.callback(self.ptr, &self.is_open);
    }

    pub fn create(p: anytype, name: [:0]const u8) Dock {
        const T = @TypeOf(p.*);
        return .{
            .ptr = p,
            .callback = TypeEraser(T, "show").call,
            .name = name,
        };
    }
};
