#!/bin/bash
# Build vlibc-compat for the host (glibc) Linux: .so + .a
# Requires: v (with vlibc support), gcc
set -e
V="${V:-/home/mr/vtree/v}"
CC="${CC:-gcc}"
SRC="${SRC:-src/lib.v}"
OUT="${OUT:-build}"
mkdir -p "$OUT"

# shared
$V -nocache -freestanding -d vlibc -d no_main -cc "$CC" -shared -o "$OUT/libvcompat.so" "$SRC" 2>&1 | tail -3

# static: compile to C, strip freestanding _start, build .a
$V -nocache -freestanding -d vlibc -d no_main -cc "$CC" -o "$OUT/libvcompat.c" "$SRC" 2>&1 | tail -3
# remove the _start asm block
awk -f scripts/strip_start.awk "$OUT/libvcompat.c" > "$OUT/libvcompat_clean.c"
$CC -fno-stack-protector -c -fPIC "$OUT/libvcompat_clean.c" -o "$OUT/libvcompat.o"
ar rcs "$OUT/libvcompat.a" "$OUT/libvcompat.o"
echo "built: $OUT/libvcompat.so  $OUT/libvcompat.a"
