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

extern "c" fn glfwInit() c_int;
pub fn glfwInit() c_int
{
    return glfwInit();
}
extern "c" fn glfwTerminate() void;
pub fn glfwTerminate() void
{
    return glfwTerminate();
}
extern "c" fn glfwGetVersion(major: ?*anyopaque, minor: ?*anyopaque, rev: ?*anyopaque) void;
pub fn glfwGetVersion(major: ?*anyopaque, minor: ?*anyopaque, rev: ?*anyopaque) void
{
    return glfwGetVersion(major, minor, rev);
}
extern "c" fn glfwGetVersionString() ?[*]const u8;
pub fn glfwGetVersionString() ?[*]const u8
{
    return glfwGetVersionString();
}
extern "c" fn glfwSetErrorCallback(cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetErrorCallback(cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetErrorCallback(cbfun);
}
extern "c" fn glfwGetMonitors(count: ?*anyopaque) ?*anyopaque;
pub fn glfwGetMonitors(count: ?*anyopaque) ?*anyopaque
{
    return glfwGetMonitors(count);
}
extern "c" fn glfwGetPrimaryMonitor() ?*anyopaque;
pub fn glfwGetPrimaryMonitor() ?*anyopaque
{
    return glfwGetPrimaryMonitor();
}
extern "c" fn glfwGetMonitorPos(monitor: ?*anyopaque, xpos: ?*anyopaque, ypos: ?*anyopaque) void;
pub fn glfwGetMonitorPos(monitor: ?*anyopaque, xpos: ?*anyopaque, ypos: ?*anyopaque) void
{
    return glfwGetMonitorPos(monitor, xpos, ypos);
}
extern "c" fn glfwGetMonitorPhysicalSize(monitor: ?*anyopaque, widthMM: ?*anyopaque, heightMM: ?*anyopaque) void;
pub fn glfwGetMonitorPhysicalSize(monitor: ?*anyopaque, widthMM: ?*anyopaque, heightMM: ?*anyopaque) void
{
    return glfwGetMonitorPhysicalSize(monitor, widthMM, heightMM);
}
extern "c" fn glfwGetMonitorName(monitor: ?*anyopaque) ?[*]const u8;
pub fn glfwGetMonitorName(monitor: ?*anyopaque) ?[*]const u8
{
    return glfwGetMonitorName(monitor);
}
extern "c" fn glfwSetMonitorCallback(cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetMonitorCallback(cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetMonitorCallback(cbfun);
}
extern "c" fn glfwGetVideoModes(monitor: ?*anyopaque, count: ?*anyopaque) ?*GLFWvidmode;
pub fn glfwGetVideoModes(monitor: ?*anyopaque, count: ?*anyopaque) ?*GLFWvidmode
{
    return glfwGetVideoModes(monitor, count);
}
extern "c" fn glfwGetVideoMode(monitor: ?*anyopaque) ?*GLFWvidmode;
pub fn glfwGetVideoMode(monitor: ?*anyopaque) ?*GLFWvidmode
{
    return glfwGetVideoMode(monitor);
}
extern "c" fn glfwSetGamma(monitor: ?*anyopaque, gamma: f32) void;
pub fn glfwSetGamma(monitor: ?*anyopaque, gamma: f32) void
{
    return glfwSetGamma(monitor, gamma);
}
extern "c" fn glfwGetGammaRamp(monitor: ?*anyopaque) ?*GLFWgammaramp;
pub fn glfwGetGammaRamp(monitor: ?*anyopaque) ?*GLFWgammaramp
{
    return glfwGetGammaRamp(monitor);
}
extern "c" fn glfwSetGammaRamp(monitor: ?*anyopaque, ramp: ?*const GLFWgammaramp) void;
pub fn glfwSetGammaRamp(monitor: ?*anyopaque, ramp: ?*const GLFWgammaramp) void
{
    return glfwSetGammaRamp(monitor, ramp);
}
extern "c" fn glfwDefaultWindowHints() void;
pub fn glfwDefaultWindowHints() void
{
    return glfwDefaultWindowHints();
}
extern "c" fn glfwWindowHint(hint: c_int, value: c_int) void;
pub fn glfwWindowHint(hint: c_int, value: c_int) void
{
    return glfwWindowHint(hint, value);
}
extern "c" fn glfwCreateWindow(width: c_int, height: c_int, title: ?[*]const u8, monitor: ?*anyopaque, share: ?*anyopaque) ?*anyopaque;
pub fn glfwCreateWindow(width: c_int, height: c_int, title: ?[*]const u8, monitor: ?*anyopaque, share: ?*anyopaque) ?*anyopaque
{
    return glfwCreateWindow(width, height, title, monitor, share);
}
extern "c" fn glfwDestroyWindow(window: ?*anyopaque) void;
pub fn glfwDestroyWindow(window: ?*anyopaque) void
{
    return glfwDestroyWindow(window);
}
extern "c" fn glfwWindowShouldClose(window: ?*anyopaque) c_int;
pub fn glfwWindowShouldClose(window: ?*anyopaque) c_int
{
    return glfwWindowShouldClose(window);
}
extern "c" fn glfwSetWindowShouldClose(window: ?*anyopaque, value: c_int) void;
pub fn glfwSetWindowShouldClose(window: ?*anyopaque, value: c_int) void
{
    return glfwSetWindowShouldClose(window, value);
}
extern "c" fn glfwSetWindowTitle(window: ?*anyopaque, title: ?[*]const u8) void;
pub fn glfwSetWindowTitle(window: ?*anyopaque, title: ?[*]const u8) void
{
    return glfwSetWindowTitle(window, title);
}
extern "c" fn glfwSetWindowIcon(window: ?*anyopaque, count: c_int, images: ?*const GLFWimage) void;
pub fn glfwSetWindowIcon(window: ?*anyopaque, count: c_int, images: ?*const GLFWimage) void
{
    return glfwSetWindowIcon(window, count, images);
}
extern "c" fn glfwGetWindowPos(window: ?*anyopaque, xpos: ?*anyopaque, ypos: ?*anyopaque) void;
pub fn glfwGetWindowPos(window: ?*anyopaque, xpos: ?*anyopaque, ypos: ?*anyopaque) void
{
    return glfwGetWindowPos(window, xpos, ypos);
}
extern "c" fn glfwSetWindowPos(window: ?*anyopaque, xpos: c_int, ypos: c_int) void;
pub fn glfwSetWindowPos(window: ?*anyopaque, xpos: c_int, ypos: c_int) void
{
    return glfwSetWindowPos(window, xpos, ypos);
}
extern "c" fn glfwGetWindowSize(window: ?*anyopaque, width: ?*anyopaque, height: ?*anyopaque) void;
pub fn glfwGetWindowSize(window: ?*anyopaque, width: ?*anyopaque, height: ?*anyopaque) void
{
    return glfwGetWindowSize(window, width, height);
}
extern "c" fn glfwSetWindowSizeLimits(window: ?*anyopaque, minwidth: c_int, minheight: c_int, maxwidth: c_int, maxheight: c_int) void;
pub fn glfwSetWindowSizeLimits(window: ?*anyopaque, minwidth: c_int, minheight: c_int, maxwidth: c_int, maxheight: c_int) void
{
    return glfwSetWindowSizeLimits(window, minwidth, minheight, maxwidth, maxheight);
}
extern "c" fn glfwSetWindowAspectRatio(window: ?*anyopaque, numer: c_int, denom: c_int) void;
pub fn glfwSetWindowAspectRatio(window: ?*anyopaque, numer: c_int, denom: c_int) void
{
    return glfwSetWindowAspectRatio(window, numer, denom);
}
extern "c" fn glfwSetWindowSize(window: ?*anyopaque, width: c_int, height: c_int) void;
pub fn glfwSetWindowSize(window: ?*anyopaque, width: c_int, height: c_int) void
{
    return glfwSetWindowSize(window, width, height);
}
extern "c" fn glfwGetFramebufferSize(window: ?*anyopaque, width: ?*anyopaque, height: ?*anyopaque) void;
pub fn glfwGetFramebufferSize(window: ?*anyopaque, width: ?*anyopaque, height: ?*anyopaque) void
{
    return glfwGetFramebufferSize(window, width, height);
}
extern "c" fn glfwGetWindowFrameSize(window: ?*anyopaque, left: ?*anyopaque, top: ?*anyopaque, right: ?*anyopaque, bottom: ?*anyopaque) void;
pub fn glfwGetWindowFrameSize(window: ?*anyopaque, left: ?*anyopaque, top: ?*anyopaque, right: ?*anyopaque, bottom: ?*anyopaque) void
{
    return glfwGetWindowFrameSize(window, left, top, right, bottom);
}
extern "c" fn glfwIconifyWindow(window: ?*anyopaque) void;
pub fn glfwIconifyWindow(window: ?*anyopaque) void
{
    return glfwIconifyWindow(window);
}
extern "c" fn glfwRestoreWindow(window: ?*anyopaque) void;
pub fn glfwRestoreWindow(window: ?*anyopaque) void
{
    return glfwRestoreWindow(window);
}
extern "c" fn glfwMaximizeWindow(window: ?*anyopaque) void;
pub fn glfwMaximizeWindow(window: ?*anyopaque) void
{
    return glfwMaximizeWindow(window);
}
extern "c" fn glfwShowWindow(window: ?*anyopaque) void;
pub fn glfwShowWindow(window: ?*anyopaque) void
{
    return glfwShowWindow(window);
}
extern "c" fn glfwHideWindow(window: ?*anyopaque) void;
pub fn glfwHideWindow(window: ?*anyopaque) void
{
    return glfwHideWindow(window);
}
extern "c" fn glfwFocusWindow(window: ?*anyopaque) void;
pub fn glfwFocusWindow(window: ?*anyopaque) void
{
    return glfwFocusWindow(window);
}
extern "c" fn glfwGetWindowMonitor(window: ?*anyopaque) ?*anyopaque;
pub fn glfwGetWindowMonitor(window: ?*anyopaque) ?*anyopaque
{
    return glfwGetWindowMonitor(window);
}
extern "c" fn glfwSetWindowMonitor(window: ?*anyopaque, monitor: ?*anyopaque, xpos: c_int, ypos: c_int, width: c_int, height: c_int, refreshRate: c_int) void;
pub fn glfwSetWindowMonitor(window: ?*anyopaque, monitor: ?*anyopaque, xpos: c_int, ypos: c_int, width: c_int, height: c_int, refreshRate: c_int) void
{
    return glfwSetWindowMonitor(window, monitor, xpos, ypos, width, height, refreshRate);
}
extern "c" fn glfwGetWindowAttrib(window: ?*anyopaque, attrib: c_int) c_int;
pub fn glfwGetWindowAttrib(window: ?*anyopaque, attrib: c_int) c_int
{
    return glfwGetWindowAttrib(window, attrib);
}
extern "c" fn glfwSetWindowUserPointer(window: ?*anyopaque, pointer: ?*anyopaque) void;
pub fn glfwSetWindowUserPointer(window: ?*anyopaque, pointer: ?*anyopaque) void
{
    return glfwSetWindowUserPointer(window, pointer);
}
extern "c" fn glfwGetWindowUserPointer(window: ?*anyopaque) ?*anyopaque;
pub fn glfwGetWindowUserPointer(window: ?*anyopaque) ?*anyopaque
{
    return glfwGetWindowUserPointer(window);
}
extern "c" fn glfwSetWindowPosCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetWindowPosCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetWindowPosCallback(window, cbfun);
}
extern "c" fn glfwSetWindowSizeCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetWindowSizeCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetWindowSizeCallback(window, cbfun);
}
extern "c" fn glfwSetWindowCloseCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetWindowCloseCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetWindowCloseCallback(window, cbfun);
}
extern "c" fn glfwSetWindowRefreshCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetWindowRefreshCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetWindowRefreshCallback(window, cbfun);
}
extern "c" fn glfwSetWindowFocusCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetWindowFocusCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetWindowFocusCallback(window, cbfun);
}
extern "c" fn glfwSetWindowIconifyCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetWindowIconifyCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetWindowIconifyCallback(window, cbfun);
}
extern "c" fn glfwSetFramebufferSizeCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetFramebufferSizeCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetFramebufferSizeCallback(window, cbfun);
}
extern "c" fn glfwPollEvents() void;
pub fn glfwPollEvents() void
{
    return glfwPollEvents();
}
extern "c" fn glfwWaitEvents() void;
pub fn glfwWaitEvents() void
{
    return glfwWaitEvents();
}
extern "c" fn glfwWaitEventsTimeout(timeout: f64) void;
pub fn glfwWaitEventsTimeout(timeout: f64) void
{
    return glfwWaitEventsTimeout(timeout);
}
extern "c" fn glfwPostEmptyEvent() void;
pub fn glfwPostEmptyEvent() void
{
    return glfwPostEmptyEvent();
}
extern "c" fn glfwGetInputMode(window: ?*anyopaque, mode: c_int) c_int;
pub fn glfwGetInputMode(window: ?*anyopaque, mode: c_int) c_int
{
    return glfwGetInputMode(window, mode);
}
extern "c" fn glfwSetInputMode(window: ?*anyopaque, mode: c_int, value: c_int) void;
pub fn glfwSetInputMode(window: ?*anyopaque, mode: c_int, value: c_int) void
{
    return glfwSetInputMode(window, mode, value);
}
extern "c" fn glfwGetKeyName(key: c_int, scancode: c_int) ?[*]const u8;
pub fn glfwGetKeyName(key: c_int, scancode: c_int) ?[*]const u8
{
    return glfwGetKeyName(key, scancode);
}
extern "c" fn glfwGetKey(window: ?*anyopaque, key: c_int) c_int;
pub fn glfwGetKey(window: ?*anyopaque, key: c_int) c_int
{
    return glfwGetKey(window, key);
}
extern "c" fn glfwGetMouseButton(window: ?*anyopaque, button: c_int) c_int;
pub fn glfwGetMouseButton(window: ?*anyopaque, button: c_int) c_int
{
    return glfwGetMouseButton(window, button);
}
extern "c" fn glfwGetCursorPos(window: ?*anyopaque, xpos: ?*anyopaque, ypos: ?*anyopaque) void;
pub fn glfwGetCursorPos(window: ?*anyopaque, xpos: ?*anyopaque, ypos: ?*anyopaque) void
{
    return glfwGetCursorPos(window, xpos, ypos);
}
extern "c" fn glfwSetCursorPos(window: ?*anyopaque, xpos: f64, ypos: f64) void;
pub fn glfwSetCursorPos(window: ?*anyopaque, xpos: f64, ypos: f64) void
{
    return glfwSetCursorPos(window, xpos, ypos);
}
extern "c" fn glfwCreateCursor(image: ?*const GLFWimage, xhot: c_int, yhot: c_int) ?*anyopaque;
pub fn glfwCreateCursor(image: ?*const GLFWimage, xhot: c_int, yhot: c_int) ?*anyopaque
{
    return glfwCreateCursor(image, xhot, yhot);
}
extern "c" fn glfwCreateStandardCursor(shape: c_int) ?*anyopaque;
pub fn glfwCreateStandardCursor(shape: c_int) ?*anyopaque
{
    return glfwCreateStandardCursor(shape);
}
extern "c" fn glfwDestroyCursor(cursor: ?*anyopaque) void;
pub fn glfwDestroyCursor(cursor: ?*anyopaque) void
{
    return glfwDestroyCursor(cursor);
}
extern "c" fn glfwSetCursor(window: ?*anyopaque, cursor: ?*anyopaque) void;
pub fn glfwSetCursor(window: ?*anyopaque, cursor: ?*anyopaque) void
{
    return glfwSetCursor(window, cursor);
}
extern "c" fn glfwSetKeyCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetKeyCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetKeyCallback(window, cbfun);
}
extern "c" fn glfwSetCharCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetCharCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetCharCallback(window, cbfun);
}
extern "c" fn glfwSetCharModsCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetCharModsCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetCharModsCallback(window, cbfun);
}
extern "c" fn glfwSetMouseButtonCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetMouseButtonCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetMouseButtonCallback(window, cbfun);
}
extern "c" fn glfwSetCursorPosCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetCursorPosCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetCursorPosCallback(window, cbfun);
}
extern "c" fn glfwSetCursorEnterCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetCursorEnterCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetCursorEnterCallback(window, cbfun);
}
extern "c" fn glfwSetScrollCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetScrollCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetScrollCallback(window, cbfun);
}
extern "c" fn glfwSetDropCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetDropCallback(window: ?*anyopaque, cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetDropCallback(window, cbfun);
}
extern "c" fn glfwJoystickPresent(joy: c_int) c_int;
pub fn glfwJoystickPresent(joy: c_int) c_int
{
    return glfwJoystickPresent(joy);
}
extern "c" fn glfwGetJoystickAxes(joy: c_int, count: ?*anyopaque) ?*anyopaque;
pub fn glfwGetJoystickAxes(joy: c_int, count: ?*anyopaque) ?*anyopaque
{
    return glfwGetJoystickAxes(joy, count);
}
extern "c" fn glfwGetJoystickButtons(joy: c_int, count: ?*anyopaque) ?*anyopaque;
pub fn glfwGetJoystickButtons(joy: c_int, count: ?*anyopaque) ?*anyopaque
{
    return glfwGetJoystickButtons(joy, count);
}
extern "c" fn glfwGetJoystickName(joy: c_int) ?[*]const u8;
pub fn glfwGetJoystickName(joy: c_int) ?[*]const u8
{
    return glfwGetJoystickName(joy);
}
extern "c" fn glfwSetJoystickCallback(cbfun: ?*anyopaque) ?*anyopaque;
pub fn glfwSetJoystickCallback(cbfun: ?*anyopaque) ?*anyopaque
{
    return glfwSetJoystickCallback(cbfun);
}
extern "c" fn glfwSetClipboardString(window: ?*anyopaque, string: ?[*]const u8) void;
pub fn glfwSetClipboardString(window: ?*anyopaque, string: ?[*]const u8) void
{
    return glfwSetClipboardString(window, string);
}
extern "c" fn glfwGetClipboardString(window: ?*anyopaque) ?[*]const u8;
pub fn glfwGetClipboardString(window: ?*anyopaque) ?[*]const u8
{
    return glfwGetClipboardString(window);
}
extern "c" fn glfwGetTime() f64;
pub fn glfwGetTime() f64
{
    return glfwGetTime();
}
extern "c" fn glfwSetTime(time: f64) void;
pub fn glfwSetTime(time: f64) void
{
    return glfwSetTime(time);
}
extern "c" fn glfwGetTimerValue() c_int;
pub fn glfwGetTimerValue() c_int
{
    return glfwGetTimerValue();
}
extern "c" fn glfwGetTimerFrequency() c_int;
pub fn glfwGetTimerFrequency() c_int
{
    return glfwGetTimerFrequency();
}
extern "c" fn glfwMakeContextCurrent(window: ?*anyopaque) void;
pub fn glfwMakeContextCurrent(window: ?*anyopaque) void
{
    return glfwMakeContextCurrent(window);
}
extern "c" fn glfwGetCurrentContext() ?*anyopaque;
pub fn glfwGetCurrentContext() ?*anyopaque
{
    return glfwGetCurrentContext();
}
extern "c" fn glfwSwapBuffers(window: ?*anyopaque) void;
pub fn glfwSwapBuffers(window: ?*anyopaque) void
{
    return glfwSwapBuffers(window);
}
extern "c" fn glfwSwapInterval(interval: c_int) void;
pub fn glfwSwapInterval(interval: c_int) void
{
    return glfwSwapInterval(interval);
}
extern "c" fn glfwExtensionSupported(extension: ?[*]const u8) c_int;
pub fn glfwExtensionSupported(extension: ?[*]const u8) c_int
{
    return glfwExtensionSupported(extension);
}
extern "c" fn glfwGetProcAddress(procname: ?[*]const u8) ?*anyopaque;
pub fn glfwGetProcAddress(procname: ?[*]const u8) ?*anyopaque
{
    return glfwGetProcAddress(procname);
}
extern "c" fn glfwVulkanSupported() c_int;
pub fn glfwVulkanSupported() c_int
{
    return glfwVulkanSupported();
}
extern "c" fn glfwGetRequiredInstanceExtensions(count: ?*anyopaque) ?*anyopaque;
pub fn glfwGetRequiredInstanceExtensions(count: ?*anyopaque) ?*anyopaque
{
    return glfwGetRequiredInstanceExtensions(count);
}
