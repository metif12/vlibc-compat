import re
p = "/work/tests/libvcompat2.c"
s = open(p).read()
pat = re.compile(r'__asm__ \(\s*\n\t"\\.pushsection \\.text.*?\\.popsection\\n\t"\);', re.S)
s2 = pat.sub("", s)
open("/tmp/libvcompat2_clean.c", "w").write(s2)
print("removed" if s2 != s else "NO MATCH")
print("remaining _start asm:", s2.count("globl _start"))
