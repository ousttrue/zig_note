const la = @import("./linear_algebra.zig");
pub const ray_intersection = @import("./ray_intersection.zig");
pub const quad_shape = @import("./quad_shape.zig");
pub const camera = @import("./camera.zig");

pub const @"*" = la.@"*";
pub const @"+" = la.@"+";
pub const @"-" = la.@"-";
pub const Vec2 = la.Vec2;
pub const Vec3 = la.Vec3;
pub const Vec4 = la.Vec4;
pub const Quaternion = la.Quaternion;
pub const Mat3 = la.Mat3;
pub const Mat4 = la.Mat4;
pub const Camera = camera.Camera;
pub const Ray = ray_intersection.Ray;
pub const Shape = quad_shape.Shape;
