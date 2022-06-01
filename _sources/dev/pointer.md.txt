# pointer / slice / sentinel

## single pointer: *

### to slice
無理？

## array: [N]
### sentinel: [N:0]

## multi pointer: [*]
### sentinel: [*:0]

## slice: []
### sentinel: [:0]

## function pointer? : fn()void

```zig
const Holder = struct {
    callback: fn () void,
};

fn some() void
{
}

const holder = Holder{ .callback = some };
```

関数ポインターなのかよくわからない。

### *const fn()void: との違い？
cast できる？

### comptime
関数ポインタのアドレスを得るのか、 `generics` で `inline` 展開しているのかよくわからない。
