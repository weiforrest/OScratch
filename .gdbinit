#file kernel.bin
target remote localhost:1234
set disassembly-flavor intel
b *0x7c00
display /5i $pc
