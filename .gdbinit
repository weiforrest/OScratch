file kernel.bin
target remote localhost:1234
set disassembly-flavor intel
b keyboard_read
b do_keyboard_handler
b save_regs
b clock_interrupt
b do_clock_handler
b taskb
b taska
set $debug_reenter = 0x30459

define dump_eip
  if ({int}$debug_reenter == 0xffffffff)
	printf "eip=%x, cs=%x ,eflag=%x esp=%x,ss=%x\n",{int}($arg0+4),{int}($arg0+8),{int}($arg0+12),{int}($arg0+16),{int}($arg0+20)
  else
	  printf "eip=%x, cs=%x ,eflag=%x\n",{int}($arg0+4),{int}($arg0+8),{int}($arg0+12)
  end
end

commands 3
  dump_eip $esp
  info reg
end
