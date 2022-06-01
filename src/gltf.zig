const std = @import("std");

pub const GlbError = error{
    InvalidMagic,
    UnknownVersion,
    Format,
};

const MAGIC: u32 = 0x46546C67;
const JSON_CHUNK: u32 = 0x4E4F534A;
const BIN_CHUNK: u32 = 0x004E4942;

const Reader = struct {
    const Self = @This();

    buffer: []const u8,
    pos: u32 = 0,

    pub fn init(buffer: []const u8) Reader {
        return .{
            .buffer = buffer,
        };
    }

    pub fn isEnd(self: *Self) bool {
        return self.pos >= self.buffer.len;
    }

    pub fn read(self: *Self, size: u32) []const u8 {
        const slice = self.buffer[self.pos .. self.pos + size];
        self.pos += size;
        return slice;
    }

    pub fn readInt(self: *Self, comptime t: type) !t {
        const slice = self.read(4);
        return try std.io.fixedBufferStream(slice).reader().readInt(t, .Little);
    }
};

pub const Glb = struct {
    jsonChunk: []const u8 = undefined,
    binChunk: []const u8 = undefined,

    pub fn parse(data: []const u8) !Glb {
        var r = Reader.init(data);
        const magic = try r.readInt(u32);
        if (magic != MAGIC) {
            return GlbError.InvalidMagic;
        }

        const version = try r.readInt(u32);
        if (version != 2) {
            return GlbError.UnknownVersion;
        }

        _ = try r.readInt(u32);
        var glb = Glb{};
        while (!r.isEnd()) {
            const chunkLength = try r.readInt(u32);
            const chunkType = try r.readInt(u32);
            switch (chunkType) {
                JSON_CHUNK => glb.jsonChunk = r.read(chunkLength),
                BIN_CHUNK => glb.binChunk = r.read(chunkLength),
                else => @panic("unknown chunk"),
            }
        }
        return glb;
    }
};

pub const Gltf = struct {

    pub fn parse(json: []const u8, bin: ?[]const u8) !Gltf {
        _ = json;
        _ = bin;
        return Gltf{};
    }

};
