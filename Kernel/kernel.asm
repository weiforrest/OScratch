;;; kernel.asm		(c) 2014 weiforrest
;;;

SELECTOR_KERNEL_CS	equ 32
;;; extern function
extern cstart

;;; extern global variable
extern gdt_ptr
extern idt_ptr
extern disp_str
extern disp_pos
[SECTION .bss]
StackSpace		resb 2 * 1024
StackTop:		
[SECTION .data]
[SECTION .text]
		
global _start


_start:
		mov esp, StackTop
		mov dword [disp_pos], 0
		sgdt	[gdt_ptr]
		call cstart
		lgdt	[gdt_ptr]
		lidt	[idt_ptr]
		jmp SELECTOR_KERNEL_CS:csinit
csinit:
		sti
		hlt

