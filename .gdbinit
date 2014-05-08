file kernel.bin
target remote localhost:1234
set disassembly-flavor intel
b start.c:26
