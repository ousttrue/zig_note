const std = @import("std");
const vec = @import("./vec.zig");
const rotation = @import("./rotation.zig");
const transformation = @import("./transformation.zig");
const util = @import("./util.zig");

/// R|0
/// -+-
/// T|1
pub const RigidBodyTransformation = struct {
    const Self = @This();

    rotation: rotation.Quaternion = .{},
    translation: vec.Vec3 = vec.Vec3.scalar(0),

    pub fn mat4(m: transformation.Mat4) Self {
        return .{
            .rotation = m.toMat3().toQuaternion(),
            .translation = m._3.toVec3(),
        };
    }

    /// R * T * (Tinv * Rinv) = I
    /// Rinv        |
    /// ------------+---
    /// Tinv * Rinv | 1
    pub fn inversed(self: Self) RigidBodyTransformation {
        const inv = self.rotation.inversed();
        return .{
            .rotation = inv,
            .translation = inv.rotate(self.translation.inversed()),
        };
    }

    pub fn transform(self: Self, point: vec.Vec3) vec.Vec3 {
        return self.rotation.rotate(point).add(self.translation);
    }
};

test "RigidBody inv" {
    const rb = RigidBodyTransformation{};
    const inv = rb.inversed();
    try std.testing.expectEqual(rb, inv);
}

test "RigidBody" {
    const q = rotation.Quaternion.angleAxis(std.math.pi / 2.0, vec.Vec3.values(1, 0, 0));
    const t = vec.Vec3.values(0, 0, 1);
    const rb = RigidBodyTransformation{ .rotation = q, .translation = t };
    const inv = rb.inversed();
    try std.testing.expect(util.nearlyEqual(@as(f32, 1e-5), 3, vec.Vec3.values(0, -1, 0).toArray(), inv.translation.const_array()));
}
