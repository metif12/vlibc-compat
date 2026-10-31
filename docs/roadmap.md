# Roadmap

## v1 (current) — done

- [x] Pure-V library on `vlibc`, no libc dependency.
- [x] Shared (`.so`) and static (`.a`) artifacts.
- [x] C ABI exports (`vc_strlen`, `vc_write_file`, `vc_read_file`).
- [x] Verified on glibc (Ubuntu 24.04) and musl (Alpine 3.21).
- [x] Build + musl validation scripts.

## v1.1 — hardening

- [ ] Add `vc_free` to release buffers from `vc_read_file`.
- [ ] Error reporting: return errno-style codes instead of `-1`.
- [ ] `vc_file_exists`, `vc_mkdir`, `vc_remove`, `vc_rename`.
- [ ] Unit tests in V (freestanding) plus the C consumer smoke test in CI.
- [ ] CI matrix: glibc + musl, amd64, using Docker.

## v2 — 32-bit and other architectures

- [ ] Revive the i386 syscall table in
  `vlib/builtin/linux_bare/linux_syscalls.i386.v`.
- [ ] Remove the `$if !i386` gate from
  `vlib/builtin/linux_bare/vlibc_*_d_vlibc.v` (or provide i386
  variants).
- [ ] Validate on i386 under QEMU / 32-bit container.
- [ ] arm64, riscv64: vlibc already supports amd64+arm64; riscv64
  needs the syscall table.

## v3 — richer surface

- [ ] Networking (TCP/UDP) via vlibc sockets.
- [ ] Time (`vc_now_*`) and process helpers.
- [ ] Optional threading behind a build flag (still no libc: use raw
  `clone`).
- [ ] GC-free data structures (hash maps, dynamic arrays) exported
  through opaque handles.

## Explicitly out of scope

- Windows and macOS (different kernel ABIs).
- Linking against glibc/musl features (would break the single-artifact
  property).
- Anything requiring the Boehm GC.
