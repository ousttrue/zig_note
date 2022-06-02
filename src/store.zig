const std = @import("std");

const MAGIC: u32 = 0xBEEF;
// key len(4)
// key n
// value len(4)
// value n

fn isFullPath(path: []const u8) bool {
    if (path.len >= 1) {
        if (path[0] == '/' or path[0] == '\\') {
            return true;
        }
        if (path.len >= 3 and path[1] == ':') {
            // Windows drive
            if (path[2] == '/' or path[2] == '\\') {
                return true;
            }
        }
    }
    return false;
}

fn makeFullPath(allocator: std.mem.Allocator, path: []const u8) []const u8 {
    if (isFullPath(path)) {
        return allocator.dupe(u8, path) catch @panic("dupe");
    } else {
        var buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
        const cwd = std.os.getcwd(buffer[0..buffer.len]) catch @panic("getcwd");
        return std.fmt.allocPrint(allocator, "{s}/{s}", .{cwd, path}) catch @panic("allocPrint");
    }
}

const Reader = struct {
    const Self = @This();

    buffer: []const u8,
    pos: usize = 0,

    pub fn is_end(self: *Self) bool {
        return self.pos >= self.buffer.len;
    }

    pub fn slice(self: *Self, len: usize) []const u8 {
        var values = self.buffer[self.pos .. self.pos + len];
        self.pos += len;
        return values;
    }

    pub fn readInt(self: *Self) u32 {
        const value = @ptrCast(*const u32, @alignCast(4, &self.buffer[self.pos])).*;
        self.pos += 4;
        return value;
    }
};

pub const Store = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    path: []const u8,
    buffer: std.ArrayList(u8),

    pub fn init(allocator: std.mem.Allocator, path: []const u8) !Self {
        var store = Store{
            .allocator = allocator,
            .path = makeFullPath(allocator, path),
            .buffer = std.ArrayList(u8).init(allocator),
        };
        store.load() catch {};
        return store;
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.path);
        self.buffer.deinit();
    }

    pub fn clear(self: *Self) void {
        self.buffer.resize(0) catch {};
    }

    fn load(self: *Self) !void {
        const f = try std.fs.openFileAbsolute(self.path, .{});
        defer f.close();
        const size = try f.getEndPos();
        std.debug.assert((try f.reader().readInt(u32, .Little)) == MAGIC);
        try self.buffer.resize(size - 4);
        _ = try f.readAll(self.buffer.items);
    }

    pub fn get(self: *Self, key: []const u8) ?[]const u8 {
        if (self.buffer.items.len > 0) {
            var r = Reader{ .buffer = self.buffer.items };
            while (!r.is_end()) {
                const k_len = r.readInt();
                const k = r.slice(k_len);
                const v_len = r.readInt();
                const v = r.slice(v_len);
                if (std.mem.eql(u8, k, key)) {
                    return v;
                }
            }
        }

        return null;
    }

    pub fn push(self: *Self, key: []const u8, value: []const u8) !void {
        var w = self.buffer.writer();
        try w.writeInt(i32, @intCast(i32, key.len), .Little);
        _ = try w.write(key);
        try w.writeInt(i32, @intCast(i32, value.len), .Little);
        _ = try w.write(value);
    }

    pub fn save(self: *Self) !void {
        const f = try std.fs.createFileAbsolute(self.path, .{});
        defer f.close();
        var w = f.writer();
        try w.writeInt(i32, MAGIC, .Little);
        try w.writeAll(self.buffer.items);
    }
};
