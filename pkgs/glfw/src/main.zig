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
    red: ?*anyopaque,
    green: ?*anyopaque,
    blue: ?*anyopaque,
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
    pixels: ?*anyopaque,
};

test "sizeof GLFWimage" {
    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(GLFWimage) == 16);
}

pub extern "c" fn glfwInit() c_int;
pub extern "c" fn glfwTerminate() void;
pub extern "c" fn glfwGetVersion(major: ?*anyopaque, minor: ?*anyopaque, rev: ?*anyopaque) void;
pub extern "c" fn glfwGetVersionString() ?[*]const u8;
pub extern "c" fn glfwSetErrorCallback(cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwGetMonitors(count: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwGetPrimaryMonitor() ?*anyopaque;
pub extern "c" fn glfwGetMonitorPos(monitor: ?*anyopaque, xpos: ?*anyopaque, ypos: ?*anyopaque) void;
pub extern "c" fn glfwGetMonitorPhysicalSize(monitor: ?*anyopaque, widthMM: ?*anyopaque, heightMM: ?*anyopaque) void;
pub extern "c" fn glfwGetMonitorName(monitor: ?*anyopaque) ?[*]const u8;
pub extern "c" fn glfwSetMonitorCallback(cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwGetVideoModes(monitor: ?*anyopaque, count: ?*anyopaque) ?*GLFWvidmode;
pub extern "c" fn glfwGetVideoMode(monitor: ?*anyopaque) ?*GLFWvidmode;
pub extern "c" fn glfwSetGamma(monitor: ?*anyopaque, gamma: f32) void;
pub extern "c" fn glfwGetGammaRamp(monitor: ?*anyopaque) ?*GLFWgammaramp;
pub extern "c" fn glfwSetGammaRamp(monitor: ?*anyopaque, ramp: ?*const GLFWgammaramp) void;
pub extern "c" fn glfwDefaultWindowHints() void;
pub extern "c" fn glfwWindowHint(hint: c_int, value: c_int) void;
pub extern "c" fn glfwCreateWindow(width: c_int, height: c_int, title: ?[*]const u8, monitor: ?*anyopaque, share: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwDestroyWindow(window: ?*anyopaque) void;
pub extern "c" fn glfwWindowShouldClose(window: ?*anyopaque) c_int;
pub extern "c" fn glfwSetWindowShouldClose(window: ?*anyopaque, value: c_int) void;
pub extern "c" fn glfwSetWindowTitle(window: ?*anyopaque, title: ?[*]const u8) void;
pub extern "c" fn glfwSetWindowIcon(window: ?*anyopaque, count: c_int, images: ?*const GLFWimage) void;
pub extern "c" fn glfwGetWindowPos(window: ?*anyopaque, xpos: ?*anyopaque, ypos: ?*anyopaque) void;
pub extern "c" fn glfwSetWindowPos(window: ?*anyopaque, xpos: c_int, ypos: c_int) void;
pub extern "c" fn glfwGetWindowSize(window: ?*anyopaque, width: ?*anyopaque, height: ?*anyopaque) void;
pub extern "c" fn glfwSetWindowSizeLimits(window: ?*anyopaque, minwidth: c_int, minheight: c_int, maxwidth: c_int, maxheight: c_int) void;
pub extern "c" fn glfwSetWindowAspectRatio(window: ?*anyopaque, numer: c_int, denom: c_int) void;
pub extern "c" fn glfwSetWindowSize(window: ?*anyopaque, width: c_int, height: c_int) void;
pub extern "c" fn glfwGetFramebufferSize(window: ?*anyopaque, width: ?*anyopaque, height: ?*anyopaque) void;
pub extern "c" fn glfwGetWindowFrameSize(window: ?*anyopaque, left: ?*anyopaque, top: ?*anyopaque, right: ?*anyopaque, bottom: ?*anyopaque) void;
pub extern "c" fn glfwIconifyWindow(window: ?*anyopaque) void;
pub extern "c" fn glfwRestoreWindow(window: ?*anyopaque) void;
pub extern "c" fn glfwMaximizeWindow(window: ?*anyopaque) void;
pub extern "c" fn glfwShowWindow(window: ?*anyopaque) void;
pub extern "c" fn glfwHideWindow(window: ?*anyopaque) void;
pub extern "c" fn glfwFocusWindow(window: ?*anyopaque) void;
pub extern "c" fn glfwGetWindowMonitor(window: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwSetWindowMonitor(window: ?*anyopaque, monitor: ?*anyopaque, xpos: c_int, ypos: c_int, width: c_int, height: c_int, refreshRate: c_int) void;
pub extern "c" fn glfwGetWindowAttrib(window: ?*anyopaque, attrib: c_int) c_int;
pub extern "c" fn glfwSetWindowUserPointer(window: ?*anyopaque, pointer: ?*anyopaque) void;
pub extern "c" fn glfwGetWindowUserPointer(window: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwSetWindowPosCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwSetWindowSizeCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwSetWindowCloseCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwSetWindowRefreshCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwSetWindowFocusCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwSetWindowIconifyCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwSetFramebufferSizeCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwPollEvents() void;
pub extern "c" fn glfwWaitEvents() void;
pub extern "c" fn glfwWaitEventsTimeout(timeout: f64) void;
pub extern "c" fn glfwPostEmptyEvent() void;
pub extern "c" fn glfwGetInputMode(window: ?*anyopaque, mode: c_int) c_int;
pub extern "c" fn glfwSetInputMode(window: ?*anyopaque, mode: c_int, value: c_int) void;
pub extern "c" fn glfwGetKeyName(key: c_int, scancode: c_int) ?[*]const u8;
pub extern "c" fn glfwGetKey(window: ?*anyopaque, key: c_int) c_int;
pub extern "c" fn glfwGetMouseButton(window: ?*anyopaque, button: c_int) c_int;
pub extern "c" fn glfwGetCursorPos(window: ?*anyopaque, xpos: ?*anyopaque, ypos: ?*anyopaque) void;
pub extern "c" fn glfwSetCursorPos(window: ?*anyopaque, xpos: f64, ypos: f64) void;
pub extern "c" fn glfwCreateCursor(image: ?*const GLFWimage, xhot: c_int, yhot: c_int) ?*anyopaque;
pub extern "c" fn glfwCreateStandardCursor(shape: c_int) ?*anyopaque;
pub extern "c" fn glfwDestroyCursor(cursor: ?*anyopaque) void;
pub extern "c" fn glfwSetCursor(window: ?*anyopaque, cursor: ?*anyopaque) void;
pub extern "c" fn glfwSetKeyCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwSetCharCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwSetCharModsCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwSetMouseButtonCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwSetCursorPosCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwSetCursorEnterCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwSetScrollCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwSetDropCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwJoystickPresent(joy: c_int) c_int;
pub extern "c" fn glfwGetJoystickAxes(joy: c_int, count: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwGetJoystickButtons(joy: c_int, count: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwGetJoystickName(joy: c_int) ?[*]const u8;
pub extern "c" fn glfwSetJoystickCallback(cbfun: ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwSetClipboardString(window: ?*anyopaque, string: ?[*]const u8) void;
pub extern "c" fn glfwGetClipboardString(window: ?*anyopaque) ?[*]const u8;
pub extern "c" fn glfwGetTime() f64;
pub extern "c" fn glfwSetTime(time: f64) void;
pub extern "c" fn glfwGetTimerValue() c_int;
pub extern "c" fn glfwGetTimerFrequency() c_int;
pub extern "c" fn glfwMakeContextCurrent(window: ?*anyopaque) void;
pub extern "c" fn glfwGetCurrentContext() ?*anyopaque;
pub extern "c" fn glfwSwapBuffers(window: ?*anyopaque) void;
pub extern "c" fn glfwSwapInterval(interval: c_int) void;
pub extern "c" fn glfwExtensionSupported(extension: ?[*]const u8) c_int;
pub extern "c" fn glfwGetProcAddress(procname: ?[*]const u8) ?*anyopaque;
pub extern "c" fn glfwVulkanSupported() c_int;
pub extern "c" fn glfwGetRequiredInstanceExtensions(count: ?*anyopaque) ?*anyopaque;
