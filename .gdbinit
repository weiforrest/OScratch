file kernel.bin
target remote localhost:1234
set disassembly-flavor intel
b start.c:39
b kernel.asm:40
