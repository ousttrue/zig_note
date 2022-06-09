const la = @import("./linear_algebra.zig");

/// R|T
/// -+-
/// 0|1
pub const RigidBodyTransformation = struct {
    const Self = @This();

    rotation: la.Quaternion = .{},
    translation: la.Vec3 = la.Vec3.scalar(0),

    /// T * R * (Rinv * Tinv) = I
    /// Rinv | Rinv * Tinv
    /// -----+------------
    /// 0    | 1
    pub fn inverse(self: Self) RigidBodyTransformation {
        const inv = self.rotation.inverse();
        return .{
            .rotation = inv,
            .translation = inv.rotate(self.translation.inverse()),
        };
    }
};
