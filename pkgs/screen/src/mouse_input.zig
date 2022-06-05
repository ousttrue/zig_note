pub const MouseInput = struct {
    x: i32,
    y: i32,
    width: i32,
    height: i32,
    left_down: bool,
    right_down: bool,
    middle_down: bool,
    is_active: bool,
    is_hover: bool,
    wheel: i32,
};
