# module

`root_module.addImport` !

```zig
    const my_module = b.createModule(.{
        .root_source_file = .{ .path = "my_module.zig" },
    });
    exe.root_module.addImport("import_name", my_module);
```
