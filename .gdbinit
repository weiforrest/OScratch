add-auto-load-safe-path /home/forrest/Work/OS/NOW/.gdbinit
#file kernel.bin
target remote localhost:1234
set disassembly-flavor intel
b *0x7c00
b *0x7c4d
display /5i $pc
