# API reference (v1)

All symbols use the C calling convention. Include nothing; declare the
externs yourself (or generate them from this page). Types are plain C.

## `vc_strlen`

```c
int vc_strlen(const char* s);
```

Returns the number of bytes in `s` before the first NUL. `s` must be
null-terminated. Passing `NULL` is undefined.

## `vc_write_file`

```c
int vc_write_file(const char* path, const char* data);
```

Writes the contents of the null-terminated `data` string (excluding the
terminator) to `path`, creating or truncating the file. Returns `0` on
success and `-1` on any error (open, write, close). Partial writes are
retried internally.

## `vc_read_file`

```c
const char* vc_read_file(const char* path);
```

Reads the whole file at `path` into a freshly allocated,
null-terminated buffer and returns a pointer to it. On failure returns a
pointer to an empty string (`""`), never `NULL`.

**Ownership:** the returned buffer is allocated with the library's
internal allocator and is **not** freed by the caller in v1. A
`vc_free` export is planned (see roadmap). For long-running processes,
avoid calling `vc_read_file` in a tight loop.

## Adding new exports

New exports are plain V functions annotated with `@[export: 'name']`
in `src/lib.v`:

```v
@[export: 'vc_example']
pub fn vc_example(x int) int {
    return x + 1
}
```

Rules for C-compatible exports:

1. Parameters and return types must be C-compatible (`int`, `&u8` for
   `const char*`, `bool` is `int`-sized in this freestanding build).
   Do **not** expose V `string`, arrays, maps, or structs across the
   ABI.
2. Convert between V and C strings with `tos(ptr, len)` (V builtin) and
   `vc_strlen`.
3. Allocate outgoing buffers with `malloc` (V builtin in freestanding).
4. Keep the module free of `os`, `net`, threads, and GC-dependent code
   to preserve the no-libc property.
