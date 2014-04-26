;;; kernel.asm		(c) 2014 weiforrest
;;;



SELECTOR_KERNEL_CS	equ 32
;;; extern function
extern cstart

;;; extern global variable
extern gdt_ptr


[SECTION .bss]
StackSpace		resb 2 * 1024
StackTop:		
[SECTION .text]
		
global _start


_start:
		mov esp, StackTop
		sgdt	[gdt_ptr]
		call cstart
		lgdt	[gdt_ptr]

		jmp SELECTOR_KERNEL_CS:csinit
csinit:
		push 0
		popfd

		hlt
