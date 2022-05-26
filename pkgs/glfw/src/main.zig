// this is generated by rawtypes
const expect = @import("std").testing.expect;
pub const GLFWmonitor = opaque {};
pub const GLFWwindow = opaque {};
pub const GLFWcursor = opaque {};
pub const GLFWvidmode = extern struct {
    width: c_int,
    height: c_int,
    redBits: c_int,
    greenBits: c_int,
    blueBits: c_int,
    refreshRate: c_int,
};

test "sizeof GLFWvidmode" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(GLFWvidmode) == 24);
}

pub const GLFWgammaramp = extern struct {
    red: ?*c_ushort,
    green: ?*c_ushort,
    blue: ?*c_ushort,
    size: c_uint,
};

test "sizeof GLFWgammaramp" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(GLFWgammaramp) == 32);
}

pub const GLFWimage = extern struct {
    width: c_int,
    height: c_int,
    pixels: ?*u8,
};

test "sizeof GLFWimage" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(GLFWimage) == 16);
}

pub const GLFWgamepadstate = extern struct {
    buttons: [15]u8,
    axes: [6]f32,
};

test "sizeof GLFWgamepadstate" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(GLFWgamepadstate) == 40);
}

pub const GLFWallocator = extern struct {
    allocate: ?*?*anyopaque,
    reallocate: ?*?*anyopaque,
    deallocate: ?*?*anyopaque,
    user: ?*anyopaque,
};

test "sizeof GLFWallocator" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(GLFWallocator) == 32);
}

pub extern "c" fn glfwInit() c_int;
pub extern "c" fn glfwTerminate() void;
pub extern "c" fn glfwInitHint(hint: c_int, value: c_int) void;
pub extern "c" fn glfwInitAllocator(allocator: ?*const GLFWallocator) void;
pub extern "c" fn glfwGetVersion(major: ?*c_int, minor: ?*c_int, rev: ?*c_int) void;
pub extern "c" fn glfwGetVersionString() ?[*]const u8;
pub extern "c" fn glfwGetError(description: ?*?[*]const u8) c_int;
pub extern "c" fn glfwSetErrorCallback(callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwGetPlatform() c_int;
pub extern "c" fn glfwPlatformSupported(platform: c_int) c_int;
pub extern "c" fn glfwGetMonitors(count: ?*c_int) ?*?*GLFWmonitor;
pub extern "c" fn glfwGetPrimaryMonitor() ?*GLFWmonitor;
pub extern "c" fn glfwGetMonitorPos(monitor: ?*GLFWmonitor, xpos: ?*c_int, ypos: ?*c_int) void;
pub extern "c" fn glfwGetMonitorWorkarea(monitor: ?*GLFWmonitor, xpos: ?*c_int, ypos: ?*c_int, width: ?*c_int, height: ?*c_int) void;
pub extern "c" fn glfwGetMonitorPhysicalSize(monitor: ?*GLFWmonitor, widthMM: ?*c_int, heightMM: ?*c_int) void;
pub extern "c" fn glfwGetMonitorContentScale(monitor: ?*GLFWmonitor, xscale: ?*f32, yscale: ?*f32) void;
pub extern "c" fn glfwGetMonitorName(monitor: ?*GLFWmonitor) ?[*]const u8;
pub extern "c" fn glfwSetMonitorUserPointer(monitor: ?*GLFWmonitor, pointer: ?*anyopaque) void;
pub extern "c" fn glfwGetMonitorUserPointer(monitor: ?*GLFWmonitor) ?*anyopaque;
pub extern "c" fn glfwSetMonitorCallback(callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwGetVideoModes(monitor: ?*GLFWmonitor, count: ?*c_int) ?*GLFWvidmode;
pub extern "c" fn glfwGetVideoMode(monitor: ?*GLFWmonitor) ?*GLFWvidmode;
pub extern "c" fn glfwSetGamma(monitor: ?*GLFWmonitor, gamma: f32) void;
pub extern "c" fn glfwGetGammaRamp(monitor: ?*GLFWmonitor) ?*GLFWgammaramp;
pub extern "c" fn glfwSetGammaRamp(monitor: ?*GLFWmonitor, ramp: ?*const GLFWgammaramp) void;
pub extern "c" fn glfwDefaultWindowHints() void;
pub extern "c" fn glfwWindowHint(hint: c_int, value: c_int) void;
pub extern "c" fn glfwWindowHintString(hint: c_int, value: ?[*]const u8) void;
pub extern "c" fn glfwCreateWindow(width: c_int, height: c_int, title: ?[*]const u8, monitor: ?*GLFWmonitor, share: ?*GLFWwindow) ?*GLFWwindow;
pub extern "c" fn glfwDestroyWindow(window: ?*GLFWwindow) void;
pub extern "c" fn glfwWindowShouldClose(window: ?*GLFWwindow) c_int;
pub extern "c" fn glfwSetWindowShouldClose(window: ?*GLFWwindow, value: c_int) void;
pub extern "c" fn glfwSetWindowTitle(window: ?*GLFWwindow, title: ?[*]const u8) void;
pub extern "c" fn glfwSetWindowIcon(window: ?*GLFWwindow, count: c_int, images: ?*const GLFWimage) void;
pub extern "c" fn glfwGetWindowPos(window: ?*GLFWwindow, xpos: ?*c_int, ypos: ?*c_int) void;
pub extern "c" fn glfwSetWindowPos(window: ?*GLFWwindow, xpos: c_int, ypos: c_int) void;
pub extern "c" fn glfwGetWindowSize(window: ?*GLFWwindow, width: ?*c_int, height: ?*c_int) void;
pub extern "c" fn glfwSetWindowSizeLimits(window: ?*GLFWwindow, minwidth: c_int, minheight: c_int, maxwidth: c_int, maxheight: c_int) void;
pub extern "c" fn glfwSetWindowAspectRatio(window: ?*GLFWwindow, numer: c_int, denom: c_int) void;
pub extern "c" fn glfwSetWindowSize(window: ?*GLFWwindow, width: c_int, height: c_int) void;
pub extern "c" fn glfwGetFramebufferSize(window: ?*GLFWwindow, width: ?*c_int, height: ?*c_int) void;
pub extern "c" fn glfwGetWindowFrameSize(window: ?*GLFWwindow, left: ?*c_int, top: ?*c_int, right: ?*c_int, bottom: ?*c_int) void;
pub extern "c" fn glfwGetWindowContentScale(window: ?*GLFWwindow, xscale: ?*f32, yscale: ?*f32) void;
pub extern "c" fn glfwGetWindowOpacity(window: ?*GLFWwindow) f32;
pub extern "c" fn glfwSetWindowOpacity(window: ?*GLFWwindow, opacity: f32) void;
pub extern "c" fn glfwIconifyWindow(window: ?*GLFWwindow) void;
pub extern "c" fn glfwRestoreWindow(window: ?*GLFWwindow) void;
pub extern "c" fn glfwMaximizeWindow(window: ?*GLFWwindow) void;
pub extern "c" fn glfwShowWindow(window: ?*GLFWwindow) void;
pub extern "c" fn glfwHideWindow(window: ?*GLFWwindow) void;
pub extern "c" fn glfwFocusWindow(window: ?*GLFWwindow) void;
pub extern "c" fn glfwRequestWindowAttention(window: ?*GLFWwindow) void;
pub extern "c" fn glfwGetWindowMonitor(window: ?*GLFWwindow) ?*GLFWmonitor;
pub extern "c" fn glfwSetWindowMonitor(window: ?*GLFWwindow, monitor: ?*GLFWmonitor, xpos: c_int, ypos: c_int, width: c_int, height: c_int, refreshRate: c_int) void;
pub extern "c" fn glfwGetWindowAttrib(window: ?*GLFWwindow, attrib: c_int) c_int;
pub extern "c" fn glfwSetWindowAttrib(window: ?*GLFWwindow, attrib: c_int, value: c_int) void;
pub extern "c" fn glfwSetWindowUserPointer(window: ?*GLFWwindow, pointer: ?*anyopaque) void;
pub extern "c" fn glfwGetWindowUserPointer(window: ?*GLFWwindow) ?*anyopaque;
pub extern "c" fn glfwSetWindowPosCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwSetWindowSizeCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwSetWindowCloseCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwSetWindowRefreshCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwSetWindowFocusCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwSetWindowIconifyCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwSetWindowMaximizeCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwSetFramebufferSizeCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwSetWindowContentScaleCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwPollEvents() void;
pub extern "c" fn glfwWaitEvents() void;
pub extern "c" fn glfwWaitEventsTimeout(timeout: f64) void;
pub extern "c" fn glfwPostEmptyEvent() void;
pub extern "c" fn glfwGetInputMode(window: ?*GLFWwindow, mode: c_int) c_int;
pub extern "c" fn glfwSetInputMode(window: ?*GLFWwindow, mode: c_int, value: c_int) void;
pub extern "c" fn glfwRawMouseMotionSupported() c_int;
pub extern "c" fn glfwGetKeyName(key: c_int, scancode: c_int) ?[*]const u8;
pub extern "c" fn glfwGetKeyScancode(key: c_int) c_int;
pub extern "c" fn glfwGetKey(window: ?*GLFWwindow, key: c_int) c_int;
pub extern "c" fn glfwGetMouseButton(window: ?*GLFWwindow, button: c_int) c_int;
pub extern "c" fn glfwGetCursorPos(window: ?*GLFWwindow, xpos: ?*f64, ypos: ?*f64) void;
pub extern "c" fn glfwSetCursorPos(window: ?*GLFWwindow, xpos: f64, ypos: f64) void;
pub extern "c" fn glfwCreateCursor(image: ?*const GLFWimage, xhot: c_int, yhot: c_int) ?*GLFWcursor;
pub extern "c" fn glfwCreateStandardCursor(shape: c_int) ?*GLFWcursor;
pub extern "c" fn glfwDestroyCursor(cursor: ?*GLFWcursor) void;
pub extern "c" fn glfwSetCursor(window: ?*GLFWwindow, cursor: ?*GLFWcursor) void;
pub extern "c" fn glfwSetKeyCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwSetCharCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwSetCharModsCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwSetMouseButtonCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwSetCursorPosCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwSetCursorEnterCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwSetScrollCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwSetDropCallback(window: ?*GLFWwindow, callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwJoystickPresent(jid: c_int) c_int;
pub extern "c" fn glfwGetJoystickAxes(jid: c_int, count: ?*c_int) ?*f32;
pub extern "c" fn glfwGetJoystickButtons(jid: c_int, count: ?*c_int) ?*u8;
pub extern "c" fn glfwGetJoystickHats(jid: c_int, count: ?*c_int) ?*u8;
pub extern "c" fn glfwGetJoystickName(jid: c_int) ?[*]const u8;
pub extern "c" fn glfwGetJoystickGUID(jid: c_int) ?[*]const u8;
pub extern "c" fn glfwSetJoystickUserPointer(jid: c_int, pointer: ?*anyopaque) void;
pub extern "c" fn glfwGetJoystickUserPointer(jid: c_int) ?*anyopaque;
pub extern "c" fn glfwJoystickIsGamepad(jid: c_int) c_int;
pub extern "c" fn glfwSetJoystickCallback(callback: ?*?*anyopaque) ?*?*anyopaque;
pub extern "c" fn glfwUpdateGamepadMappings(string: ?[*]const u8) c_int;
pub extern "c" fn glfwGetGamepadName(jid: c_int) ?[*]const u8;
pub extern "c" fn glfwGetGamepadState(jid: c_int, state: ?*GLFWgamepadstate) c_int;
pub extern "c" fn glfwSetClipboardString(window: ?*GLFWwindow, string: ?[*]const u8) void;
pub extern "c" fn glfwGetClipboardString(window: ?*GLFWwindow) ?[*]const u8;
pub extern "c" fn glfwGetTime() f64;
pub extern "c" fn glfwSetTime(time: f64) void;
pub extern "c" fn glfwGetTimerValue() c_int;
pub extern "c" fn glfwGetTimerFrequency() c_int;
pub extern "c" fn glfwMakeContextCurrent(window: ?*GLFWwindow) void;
pub extern "c" fn glfwGetCurrentContext() ?*GLFWwindow;
pub extern "c" fn glfwSwapBuffers(window: ?*GLFWwindow) void;
pub extern "c" fn glfwSwapInterval(interval: c_int) void;
pub extern "c" fn glfwExtensionSupported(extension: ?[*]const u8) c_int;
pub extern "c" fn glfwGetProcAddress(procname: ?[*]const u8) ?*?*anyopaque;
pub extern "c" fn glfwVulkanSupported() c_int;
pub extern "c" fn glfwGetRequiredInstanceExtensions(count: ?*c_int) ?*?[*]const u8;