# zls を読む

- [zls を workspace/configuration と workspace/didChangeConfiguration に対応させたい](https://zenn.dev/tamago324/scraps/d158ca008b14e1)

## `@import` のパッケージ解決を改造したい

改造していたら治った。
おそらく、 `request / response` がちゃんとペアになってないなど。

### AST

- [Zig Parser – Mitchell Hashimoto](https://mitchellh.com/zig/parser)

```zig
// DocumentStore.zig
pub fn newDocument
pub fn refreshDocument
```

`AST`

```zig
    handle.tree = try std.zig.parse(self.allocator, handle.document.text);
```

### @import

`import_uris`

```
fn collectImportUris(self: *DocumentStore, handle: *Handle) ![]const []const u8
```

```zig
// analysis.zig
/// Collects all imports we can find into a slice of import paths (without quotes).
pub fn collectImports(import_arr: *std.ArrayList([]const u8), tree: Ast) !void
```

```
```

### formatter

メモリエラー。

## `@cImport` を解決したい

`cImport` するとインテリセンスが効かない。`zig` でラップしたものの方が使いやすいかも。
`zls` の進化待ち。

https://github.com/zigtools/zls

> Notable language features that are not currently implemented include @cImport as well as most forms of compile time evaluation.
