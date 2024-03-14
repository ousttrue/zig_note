# nvim 設定

## lsp

```vim
:MasonInstall zls
```

## highlight

```vim
:TSInstall zig
```

## formatter

```lua
  --
  -- zig format
  --
  local null_ls = require "null-ls"
  null_ls.register {
    method = null_ls.methods.FORMATTING,
    name = "zig_fmt",
    filetypes = { "zig" },
    generator = null_ls.formatter {
      command = { "zig" },
      args = {
        "fmt",
        "$FILENAME",
      },
      to_stdin = false,
      to_temp_file = true,
      from_temp_file = true,
    },
  }
```
