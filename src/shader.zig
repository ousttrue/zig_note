const gl = @import("gl");

pub const ShaderCompile = struct{
    const Self = @This();

    shader: gl.GLuint,

    pub fn init(shader_type: gl.GLuint) Self{
        return .{
            .shader = gl.createShader(shader_type),
        };
    }

    pub fn deinit(self: *Self) void {
        gl.deleteShader(self.shader);
    }

    pub fn compileGetError(self: *Self, src: []const u8)?[]const u8
    {
        gl.shaderSource(self.shader, src, null);
        gl.compileShader(self.shader);
        const status = gl.GetShaderiv(self.shader, gl._COMPILE_STATUS);
        if(status == gl._TRUE){
            return null;
        }
        // error message
        const info = gl.GetShaderInfoLog(self.shader);
        return info;
    }
};


pub const ShaderProgram = struct{
    const Self = @This();

    program: gl.GLuint,

    fn init() Self{
        return .{
            .program = gl.createProgram(),
        };
    }

    fn deinit(self: *Self)void{
        gl.deleteProgram(self.program);
    }

    pub fn linkGetError(self: *Self, vs: ShaderCompile, fs: ShaderCompile)?[]const u8
    {
        gl.AttachShader(self.program, vs);
        gl.AttachShader(self.program, fs);
        gl.LinkProgram(self.program);
        const status = gl.GetProgramiv(self.program, gl._LINK_STATUS);
        if(status == gl._TRUE){
            return null;
        }

        // error message
        const info = gl.GetProgramInfoLog(self.program);
        return info;
    }

    pub fn load(vs_src: []const u8, fs_src: []const u8)union(enum){shader:ShaderProgram, errorMessage:[]const u8}
    {
        const vs = ShaderCompile.init(gl.VERTEX_SHADER);
        defer vs.deinit();
        if(vs.compileGetError(vs_src))|errorMessage|{
            return errorMessage;
        }
        const fs = ShaderCompile.init(gl.FRAGMENT_SHADER);
        defer fs.deinit();
        if(fs.compile(fs_src))|errorMessage|{
            return errorMessage;
        }
        
        const shader = Self.init();
        if(shader.linkHasError(vs.shader, fs.shader))|errorMessage|
        {
            shader.deinit();
            return errorMessage;
        }
        return shader;
    }
};
