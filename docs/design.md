# Design

## Goal

One pure-V artifact that runs on both glibc and musl Linux hosts,
delivered as `.so` and `.a`, 32- and 64-bit (other arches later).

## Strategy

Avoid libc. Build on the experimental `vlibc` layer
(`v -freestanding -d vlibc`), which issues raw kernel syscalls. The
kernel ABI is identical for glibc and musl, so generated C carries no
libc-specific symbols or layouts.

## v1 scope

- Pure V only: no GC (boehm pulls libc), no threads, no net.
- Strings, builtin, file-oriented `os` subset.

## Reused upstream work

- Merged `#31240` (base `*_bare` vlibc, Linux amd64+arm64).
- Merged `#31292` (os wired to pure-V syscalls).
- Open `#31400` (hosted os extras: rmdir/rm/rename/mkdir/ls).
- Closed PRs to revive selectively: net (tcp/udp/sockopt), time,
  crypto.rand, proc/execvp/waitpid, fcntl/select, env, term, os
  meta/ident/mmap/trunc, driver gaps (BSD `_start` guard, byte-order,
  errno strings, i386).

## 32-bit

`linux_bare/vlibc_syscall_d_vlibc.v` currently guards with `$if !i386`.
i386 syscall table is the known gap; revive from `feat/vlibc-driver-gaps`.

## Validation

Compile `lib.c` with stock `gcc` and `musl-gcc`; link a C consumer on
each; run on Ubuntu + Alpine. Audit with `nm -D` for `GLIBC_*` symbols
and `ldd` for `libc.so`.
