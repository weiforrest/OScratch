file kernel.bin
target remote localhost:1234
set disassembly-flavor intel
b keyboard_read
b do_keyboard_handler
