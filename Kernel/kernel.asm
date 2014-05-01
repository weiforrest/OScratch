;;; kernel.asm		(c) 2014 weiforrest
;;;
SELECTOR_KERNEL_CS	equ 8
SELECTOR_IDT_CS		equ (8 & 7)
SELECTOR_IDT_SS		equ (0x10 & 7)
SELECTOR_IDT_GS		equ (0x18 & 7)
OFFSET_LTD_TASK		equ 136
;;; extern function
extern cstart
extern taska
;;; extern global variable
extern gdt_ptr
extern idt_ptr
extern disp_str
extern disp_pos
extern p_task_ready
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
		jmp SELECTOR_KERNEL_CS:csinit
csinit:
		sti
		mov ax, 0x28
		ltr ax
		mov ax, 0x20
		lldt ax
		push 0xf			;ss
		push StackTop 	;esp
		pushf
		push 0x7			;cs
		push .1;eip
		iretd
.1:
		mov eax, 0xf
		mov ds, ax
		mov es, ax
		mov fs, ax
		mov eax, 0x17
		mov gs, eax
		jmp taska
