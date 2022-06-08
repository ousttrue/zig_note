pub const MouseInput = struct {
    x: i32,
    y: i32,
    width: u32,
    height: u32,
    left_down: bool,
    right_down: bool,
    middle_down: bool,
    is_active: bool,
    is_hover: bool,
    wheel: i32,
};
