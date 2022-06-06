const std = @import("std");

pub fn TypeEraser(comptime T: type, comptime name: []const u8) type {
    const f = @field(T, name);
    const info = @typeInfo(@TypeOf(f));
    const alignment = @typeInfo(*T).Pointer.alignment;

    switch (info) {
        .Fn => |method| {
            switch (method.args.len) {
                1 => {
                    return struct {
                        pub fn call(ptr: *anyopaque) (method.return_type orelse void) {
                            const self = @ptrCast(*T, @alignCast(alignment, ptr));
                            return @call(.{}, f, .{self});
                        }
                    };
                },
                2 => {
                    return struct {
                        pub fn call(ptr: *anyopaque, a0: method.args[1].arg_type.?) (method.return_type orelse void) {
                            const self = @ptrCast(*T, @alignCast(alignment, ptr));
                            return @call(.{}, f, .{self, a0});
                        }
                    };
                },
                4 => {
                    return struct {
                        pub fn call(ptr: *anyopaque, a0: method.args[1].arg_type.?, a1: method.args[2].arg_type.?, a2: method.args[3].arg_type.?) (method.return_type orelse void) {
                            const self = @ptrCast(*T, @alignCast(alignment, ptr));
                            return @call(.{}, f, .{self, a0, a1, a2});
                        }
                    };
                },
                else => {
                    @compileError("not implemted: args.len > 0");
                },
            }
        },
        else => {
            @compileError("not Fn");
        },
    }
}
