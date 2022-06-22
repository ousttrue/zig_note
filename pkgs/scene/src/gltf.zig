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

pub const Asset = struct {
    generator: ?[]const u8,
    version: ?[]const u8,
};

pub const Scene = struct {
    nodes: ?[]const u32,
};

pub const Node = struct {
    children: ?[]const u32,
    matrix: ?[16]f32,
    camera: ?u32,
    mesh: ?u32,
};

pub const Camera = struct {
    perspective: ?struct {
        aspectRatio: ?f32,
        yfov: ?f32,
        zfar: ?f32,
        znear: ?f32,
    },
    @"type": ?[]const u8,
};

pub const Primitive = struct {
    attributes: struct { NORMAL: ?u32 = null, POSITION: u32, TEXCOORD_0: ?u32 = null },
    indices: ?u32 = null,
    mode: ?u32,
    material: ?u32,
};

pub const Mesh = struct {
    name: ?[]const u8,
    primitives: []Primitive = &.{},
};

pub const Accessor = struct {
    const Self = @This();

    bufferView: usize,
    byteOffset: usize = 0,
    componentType: u32,
    count: usize,
    max: ?[]f32,
    min: ?[]f32,
    @"type": []const u8,

    pub fn itemSize(self: Self) usize {
        const t = self.@"type";
        const component_count: usize =
            if (std.mem.eql(u8, t, "SCALAR")) @as(usize, 1) //
        else if (std.mem.eql(u8, t, "VEC2")) @as(usize, 2) //
        else if (std.mem.eql(u8, t, "VEC3")) @as(usize, 3) //
        else if (std.mem.eql(u8, t, "VEC4")) @as(usize, 4) //
        else if (std.mem.eql(u8, t, "MAT2")) @as(usize, 4) //
        else if (std.mem.eql(u8, t, "MAT3")) @as(usize, 9) //
        else if (std.mem.eql(u8, t, "MAT4")) @as(usize, 16) //
        else unreachable;

        const component_byte_size: usize = switch (self.componentType) {
            5120 => 1,
            5121 => 1,
            5122 => 2,
            5123 => 2,
            5125 => 4,
            5126 => 4,
            else => unreachable,
        };

        return component_count * component_byte_size;
    }
};

pub const Material = struct {
    pbrMetallicRoughness: ?struct {
        baseColorTexture: ?struct { index: ?u32 },
        metallicFactor: ?f32,
    },
    emissiveFactor: ?[3]f32,
    name: ?[]const u8,
};

pub const Texture = struct {
    sampler: ?u32,
    source: ?u32,
};

pub const Image = struct {
    uri: ?[]const u8,
};

pub const Sampler = struct {
    magFilter: ?u32,
    minFilter: ?u32,
    wrapS: ?u32,
    wrapT: ?u32,
};

pub const BufferView = struct {
    buffer: usize,
    byteOffset: usize = 0,
    byteLength: usize,
    byteStride: ?usize = null,
    target: ?u32 = null,
};

pub const Buffer = struct {
    byteLength: ?u32,
    uri: ?[]const u8,
};

pub const Gltf = struct {
    // asset: ?Asset,
    // scene: ?u32,
    // scenes: ?[]Scene,
    // nodes: ?[]Node,
    // cameras: ?[]Camera,
    meshes: []Mesh = &.{},
    accessors: []Accessor = &.{},
    // materials: ?[]Material,
    // textures: ?[]Texture,
    // images: ?[]Image,
    // samplers: ?[]Sampler,
    bufferViews: []BufferView = &.{},
    // buffers: ?[]Buffer,
};

pub const GtlfBufferReader = struct {
    const Self = @This();

    buffers: []const []const u8,
    bufferViews: []const BufferView,
    accessors: []const Accessor,

    pub fn getBytesFromAccessor(self: Self, accessor_index: usize) []const u8 {
        const accessor = self.accessors[accessor_index];
        const buffer_view = self.bufferViews[accessor.bufferView];
        const buffer_view_bytes = self.buffers[0][buffer_view.byteOffset .. buffer_view.byteOffset + buffer_view.byteLength];
        return buffer_view_bytes[accessor.byteOffset .. accessor.byteOffset + accessor.count * accessor.itemSize()];
    }

    pub fn getTypedFromAccessor(self: Self, comptime T: type, accessor_index: usize) []const T {
        const bytes = self.getBytesFromAccessor(accessor_index);
        const count = self.accessors[accessor_index].count;
        return @ptrCast([*]const T, @alignCast(@alignOf(T), &bytes[0]))[0..count];
    }
};
