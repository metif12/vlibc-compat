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

## Build (Linux)

```sh
# shared
v -freestanding -d vlibc -shared -o libvcompat.so src/lib.v
# static
v -freestanding -d vlibc -o libvcompat.c src/lib.v
gcc -c -fPIC libvcompat.c -o libvcompat.o
ar rcs libvcompat.a libvcompat.o
```

## Verify (no glibc versioned symbols)

```sh
nm -D libvcompat.so | grep GLIBC || echo "clean"
ldd libvcompat.so 2>&1 | grep libc || echo "no libc dep"
```
