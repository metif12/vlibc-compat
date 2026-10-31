#!/bin/sh
apk add --no-cache build-base binutils >/dev/null 2>&1
cd /tmp
awk -f /work/scripts/strip_start.awk /work/tests/libvcompat2.c > /tmp/clean.c
echo "bare_eprint defs: $(grep -c 'void bare_eprint' /tmp/clean.c)"
gcc -fno-stack-protector -shared -fPIC /tmp/clean.c -o /tmp/libvcompat.so 2>/tmp/errs
echo "so rc=$?"
head -3 /tmp/errs
echo "--- undef symbols ---"
nm -D /tmp/libvcompat.so | grep ' U ' || echo "(none)"
echo "--- ldd ---"
ldd /tmp/libvcompat.so
echo "--- consumer ---"
gcc -o /tmp/consumer /work/tests/consumer.c -L/tmp -lvcompat -Wl,-rpath,/tmp 2>>/tmp/errs
echo "link rc=$?"
/tmp/consumer
echo "run rc=$?"
