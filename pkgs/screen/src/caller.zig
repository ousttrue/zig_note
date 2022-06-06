const std = @import("std");

pub fn Caller0(comptime T: type, comptime name: []const u8) type {
    const comp_size = comptime @alignOf(*T);
    return struct {
        pub fn call(src: *anyopaque) void {
            var ptr = @ptrCast(*T, @alignCast(comp_size, src));
            return @call(.{}, @field(T, name), .{ptr});
        }
    };
}
pub fn Caller1(comptime T: type, comptime name: []const u8, comptime args: [1]type) type {
    const comp_size = comptime @alignOf(*T);
    return struct {
        pub fn call(src: *anyopaque, a0: args[0]) void {
            var ptr = @ptrCast(*T, @alignCast(comp_size, src));
            return @call(.{}, @field(T, name), .{ ptr, a0 });
        }
    };
}
pub fn Caller2(comptime T: type, comptime name: []const u8, comptime args: [2]type) type {
    const comp_size = comptime @alignOf(*T);
    return struct {
        pub fn call(src: *anyopaque, a0: args[0], a1: args[1]) void {
            var ptr = @ptrCast(*T, @alignCast(comp_size, src));
            return @call(.{}, @field(T, name), .{ ptr, a0, a1 });
        }
    };
}
pub fn Caller3(comptime T: type, f: anytype, comptime A0: type, comptime A1: type, comptime A2: type) type {
    const comp_size = comptime @alignOf(*T);
    return struct {
        pub fn call(src: *anyopaque, a0: A0, a1: A1, a2: A2) void {
            var ptr = @ptrCast(*T, @alignCast(comp_size, src));
            return @call(.{}, f, .{ ptr, a0, a1, a2 });
        }
    };
}
pub fn Caller4(comptime T: type, comptime name: []const u8, comptime args: [4]type) type {
    const comp_size = comptime @alignOf(*T);
    return struct {
        pub fn call(src: *anyopaque, a0: args[0], a1: args[1], a2: args[2], a3: args[3]) void {
            var ptr = @ptrCast(*T, @alignCast(comp_size, src));
            return @call(.{}, @field(T, name), .{ ptr, a0, a1, a2, a3 });
        }
    };
}
pub fn Caller(comptime T: type, f: std.builtin.TypeInfo.Fn) type {
    return switch (f.args.len) {
        0 => Caller0(T, f.name),
        1 => Caller1(T, f.name, .{f.args[0].arg_type}),
        2 => Caller2(T, f.name, .{ f.args[0].arg_type, f.args[1].arg_type }),
        3 => Caller3(T, f.name, .{ f.args[0].arg_type, f.args[1].arg_type, f.args[2].arg_type }),
        4 => Caller4(T, f.name, .{ f.args[0].arg_type, f.args[1].arg_type, f.args[2].arg_type, f.args[3].arg_type }),
        else => @compileError("not impl over 5 args"),
    };
}
