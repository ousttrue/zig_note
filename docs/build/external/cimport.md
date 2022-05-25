# @cImport

<https://ziglang.org/documentation/master/#toc-Import-from-C-Header-File>

## zls未対応問題

`cImport` するとインテリセンスが効かない。`zig` でラップしたものの方が使いやすいかも。
`zls` の進化待ち。

<https://github.com/zigtools/zls>

> Notable language features that are not currently implemented include @cImport as well as most forms of compile time evaluation.

## 例

<https://github.com/michal-z/zig-gamedev/blob/main/samples/intro/build.zig>

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

<https://github.com/michal-z/zig-gamedev/blob/main/libs/common/c.zig>

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
