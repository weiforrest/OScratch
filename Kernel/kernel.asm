;;; kernel.asm		(c) 2014 weiforrest
;;;
%include "const.inc"
;;; extern function
extern cstart
;;; extern global variable
extern gdt_ptr
extern idt_ptr
extern disp_str
extern disp_pos
extern p_proc_ready
global StackTop
[SECTION .bss]
StackSpace		resb 4 * 1024
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
		mov ax, SELECTOR_TSS
		ltr ax

		jmp SELECTOR_KERNEL_CS:csinit
csinit:
		;; sti
		mov dword esp, [p_proc_ready]
		lldt [esp + OFFSET_LDT_PROC]
		pop gs
		pop fs
		pop es
		pop ds
		popad
		iretd

