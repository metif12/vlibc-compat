# vlibc-compat

**One pure-V library artifact that runs on both glibc and musl Linux hosts.**

`vlibc-compat` is a small, C-ABI library built on V's experimental
`vlibc` syscall layer. It ships as a shared object (`.so`) **and** a
static archive (`.a`), from a single V source tree, for 64-bit Linux
today (32-bit and other architectures are on the roadmap).

Compatibility is not achieved by careful coding against libc — it is
achieved by **not using libc at all**. The generated C only traps into
the kernel through `vlibc_*` syscalls. The kernel ABI is identical on
glibc and musl, so the same `.c` compiles and links cleanly on Ubuntu
and Alpine, with no `GLIBC_*` versioned symbols and no `libc.so`
dependency.

See [`docs/design.md`](docs/design.md) for the rationale and
[`docs/usage.md`](docs/usage.md) for consumer examples.

---

## Goals

1. **Single artifact, both libcs.** One `.so`/`.a` that loads and runs
   on glibc-based (Ubuntu, Debian, Fedora, …) and musl-based (Alpine,
   Void, …) Linux distributions without recompilation.
2. **No libc dependency.** Generated C must not reference glibc- or
   musl-specific symbols, headers, or layouts. The only external
   dependency is the Linux kernel ABI.
3. **C ABI.** Exported functions use plain C types (`int`, `const char*`,
   …) so any language with a C FFI can consume the library.
4. **Both linkage modes.** Ship `.so` (dynamic) and `.a` (static) from
   the same source.
5. **Pure V.** No hand-written C in the library; all logic is V compiled
   through `v -freestanding -d vlibc`.
6. **Reproducible builds.** Build scripts are checked in and the
   resulting `.so` is `ldd`-clean.

## Non-goals (v1)

- **No garbage collector.** Boehm GC pulls in libc; v1 is GC-free.
- **No threads / goroutines.** Thread support is vlibc-provided but not
  exercised by the v1 API.
- **No networking.** Sockets are available in vlibc but out of v1 scope.
- **No 32-bit / non-amd64 yet.** See Roadmap.
- **No Windows / macOS.** Linux kernel ABI only.

## Status

Work in progress. v1 scope: pure V, strings + builtin + file-oriented
`os` subset, amd64. Verified on Ubuntu 24.04 (glibc) and Alpine 3.21
(musl).

## Installation / build

Prerequisites:

- A V compiler with `vlibc` support (e.g. a recent `vtree/v` or
  `metif12/v` checkout). The stock/older V binaries do not ship the
  `linux_bare/vlibc_*_d_vlibc.v` files.
- `gcc` (or `clang`) and `binutils` (`ar`, `objcopy`).

```sh
git clone https://github.com/metif12/vlibc-compat.git
cd vlibc-compat
scripts/build.sh
```

`scripts/build.sh` performs:

1. `v -freestanding -d vlibc -d no_main -shared -o build/libvcompat.so src/lib.v`
2. `v -freestanding -d vlibc -d no_main -o build/libvcompat.c src/lib.v`
3. Strip the freestanding `_start` asm block from the generated C
   (`scripts/strip_start.awk`), compile with `-fno-stack-protector`,
   and archive into `build/libvcompat.a`.

Override the compiler or source:

```sh
V=/path/to/v CC=clang SRC=src/lib.v OUT=dist scripts/build.sh
```

## Usage

### From C (static)

```c
#include <stdio.h>

extern int vc_strlen(const char* s);
extern int vc_write_file(const char* path, const char* data);
extern const char* vc_read_file(const char* path);

int main(void) {
    const char* msg = "hello from consumer";
    printf("len=%d\n", vc_strlen(msg));

    if (vc_write_file("/tmp/out.txt", msg) != 0) {
        fprintf(stderr, "write failed\n");
        return 1;
    }
    printf("read=%s\n", vc_read_file("/tmp/out.txt"));
    return 0;
}
```

```sh
gcc -o consumer consumer.c build/libvcompat.a
./consumer   # len=19 / read=hello from consumer
```

### From C (dynamic)

```sh
gcc -o consumer consumer.c -Lbuild -lvcompat -Wl,-rpath,build
./consumer
```

### From another language

Any language with a C FFI (Python `ctypes`, Go `cgo`, Rust `extern "C"`,
Node `ffi-napi`, …) can load `libvcompat.so` and call `vc_*`. The
library is `ldd`-clean, so it is safe to `dlopen` on both glibc and
musl hosts.

### Verify there is no libc dependency

```sh
ldd build/libvcompat.so          # statically linked / only the musl loader
nm -D build/libvcompat.so | grep -i glibc || echo "no GLIBC symbols"
nm -D build/libvcompat.so | grep ' U ' || echo "no undefined symbols"
```

Verified on Ubuntu 24.04 (glibc) and Alpine 3.21 (musl): consumer prints
`len=19` / `read=hello from consumer`.

## API (v1)

| Symbol | Signature | Description |
|---|---|---|
| `vc_strlen` | `int vc_strlen(const char* s)` | Length of a null-terminated string. |
| `vc_write_file` | `int vc_write_file(const char* path, const char* data)` | Write `data` (null-terminated, written without the terminator) to `path`. Returns 0 on success, -1 on error. |
| `vc_read_file` | `const char* vc_read_file(const char* path)` | Read file contents into a malloc'd, null-terminated buffer. Returns `NULL`-ish on error (empty). Caller must not free (v1 has no free export). |

Full API details: [`docs/api.md`](docs/api.md).

## Repository layout

```
vlibc-compat/
├── src/lib.v              # the library (pure V)
├── tests/consumer.c       # C smoke-test consumer
├── scripts/
│   ├── build.sh           # glibc/musl build
│   ├── test_musl.sh       # Alpine/musl validation
│   └── strip_start.awk    # removes freestanding _start asm block
├── docs/
│   ├── design.md          # rationale and constraints
│   ├── usage.md           # consumer examples
│   ├── api.md             # API reference
│   └── roadmap.md         # planned work
└── README.md
```

## Scope / limits

- v1: pure V only (no GC, no threads, no net). Strings, builtin, and a
  file-oriented `os` subset.
- 64-bit (amd64) verified. 32-bit (i386) and other architectures are
  on the roadmap: vlibc is currently gated by `$if !i386` in
  `vlib/builtin/linux_bare/vlibc_*_d_vlibc.v` and needs the i386
  syscall table revived.
- The shared library requires stripping the freestanding `_start` asm
  block (handled by `scripts/strip_start.awk`) to avoid an undefined
  `main`/`_start`.

## Roadmap

See [`docs/roadmap.md`](docs/roadmap.md).

## License

MIT. See `LICENSE` (to be added).
