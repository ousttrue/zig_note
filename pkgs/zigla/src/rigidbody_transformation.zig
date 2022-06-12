const std = @import("std");
const la = @import("./linear_algebra.zig");

/// R|0
/// -+-
/// T|1
pub const RigidBodyTransformation = struct {
    const Self = @This();

    rotation: la.Quaternion = .{},
    translation: la.Vec3 = la.Vec3.scalar(0),

    pub fn mat4(m: la.Mat4) Self {
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

    pub fn transform(self: Self, point: la.Vec3) la.Vec3 {
        return self.rotation.rotate(point).add(self.translation);
    }
};

test "RigidBody inv" {
    const rb = RigidBodyTransformation{};
    const inv = rb.inversed();
    try std.testing.expectEqual(rb, inv);
}

test "RigidBody" {
    const q = la.Quaternion.angleAxis(std.math.pi / 2.0, la.Vec3.init(1, 0, 0));
    const t = la.Vec3.init(0, 0, 1);
    const rb = RigidBodyTransformation{ .rotation = q, .translation = t };
    const inv = rb.inversed();
    try std.testing.expect(la.nearlyEqual(@as(f32, 1e-5), 3, la.Vec3.init(0, -1, 0).array(), inv.translation.const_array()));
}
