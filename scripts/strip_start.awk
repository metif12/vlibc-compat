BEGIN { skip=0 }
/__asm__ \(/ { skip=1 }
skip==1 && /^\s*\);\s*$/ { skip=0; next }
skip==1 { next }
{ print }
