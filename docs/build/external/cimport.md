# @cImport

https://ziglang.org/documentation/master/#toc-Import-from-C-Header-File

## 例

https://github.com/michal-z/zig-gamedev/blob/main/samples/intro/build.zig

```zig
        const external = "../../external/src";
        exe.addIncludeDir(external);

        exe.linkSystemLibrary("c");
        exe.linkSystemLibrary("c++");
        exe.linkSystemLibrary("imm32");

        exe.addCSourceFile(external ++ "/imgui/imgui.cpp", &[_][]const u8{""});
        exe.addCSourceFile(external ++ "/imgui/imgui_widgets.cpp", &[_][]const u8{""});
        exe.addCSourceFile(external ++ "/imgui/imgui_tables.cpp", &[_][]const u8{""});
        exe.addCSourceFile(external ++ "/imgui/imgui_draw.cpp", &[_][]const u8{""});
        exe.addCSourceFile(external ++ "/imgui/imgui_demo.cpp", &[_][]const u8{""});
        exe.addCSourceFile(external ++ "/cimgui.cpp", &[_][]const u8{""});
```

https://github.com/michal-z/zig-gamedev/blob/main/libs/common/c.zig

```zig
pub usingnamespace @cImport({
    @cDefine("CIMGUI_DEFINE_ENUMS_AND_STRUCTS", "");
    @cDefine("CIMGUI_NO_EXPORT", "");
    @cInclude("cimgui.h");
    @cInclude("cgltf.h");
    @cInclude("cbullet.h");
    @cInclude("meshoptimizer.h");
    @cInclude("stb_perlin.h");
    @cInclude("stb_image.h");
});
```
