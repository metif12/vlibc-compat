# vlibc-compat

Pure-V library (built on the experimental `vlibc` syscall layer) that
ships **one** artifact usable on both glibc and musl Linux hosts, as a
shared library (`.so`) and a static archive (`.a`), for 32- and 64-bit
targets.

Compatibility comes from avoiding libc entirely: generated C only traps
into the kernel via `vlibc_*` syscalls, so the same `.c` links clean on
Ubuntu (glibc) and Alpine (musl). See `docs/design.md`.

## Status

Work in progress. v1 scope: pure V only (no GC, no threads, no net).
Strings, builtin, and file-oriented `os` subset.

## Build (Linux, glibc or musl)

```sh
# requires a V with vlibc support (e.g. vtree/v) and gcc
scripts/build.sh
```

What build.sh does:

1. `v -freestanding -d vlibc -d no_main -shared -o build/libvcompat.so src/lib.v`
2. `v ... -o build/libvcompat.c src/lib.v` then strip the freestanding
   `_start` asm block, compile with `-fno-stack-protector`, `ar` into
   `build/libvcompat.a`.

## Verify (no libc dependency, no versioned symbols)

```sh
ldd build/libvcompat.so          # -> statically linked / only musl loader
nm -D build/libvcompat.so | grep -i glibc || echo "no GLIBC symbols"
# consumer smoke test
gcc -o /tmp/consumer tests/consumer.c build/libvcompat.a && /tmp/consumer
```

Verified on Ubuntu 24.04 (glibc) and Alpine 3.21 (musl): consumer prints
`len=19` / `read=hello from consumer`, no libc dependency in the .so.

## Scope / limits

- v1: pure V only (no GC, no threads, no net). Strings/builtin/file os.
- 64-bit (amd64) verified. 32-bit (i386) and other arches: vlibc is
  currently gated by `$if !i386` in vlib; needs the i386 syscall table
  revived (see docs/design.md).
- Shared lib needs the freestanding `_start` asm stripped (done by
  scripts/strip_start.awk) to avoid an undefined `main`/`_start`.
