;;; kernel.asm		(c) 2014 weiforrest
;;;

SELECTOR_KERNEL_CS	equ 32
;;; extern function
extern cstart
extern exception_handler

;;; extern global variable
extern gdt_ptr
extern idt_ptr
extern disp_str
		
[SECTION .bss]
StackSpace		resb 2 * 1024
StackTop:		
[SECTION .data]
[SECTION .text]
		
global _start


_start:
		mov esp, StackTop
		sgdt	[gdt_ptr]
		call cstart
		lgdt	[gdt_ptr]
		lidt	[idt_ptr]
		jmp SELECTOR_KERNEL_CS:csinit
csinit:
		sti
		jmp 0x40:0


;;; interrupt handler
global divide_error
global single_step_exception
global nmi
global breakpoint_exception
global overflow
global bounds_check
global inval_opcode
global copr_not_available
global double_fault
global copr_seg_overrun
global inval_tss
global segment_not_present
global stack_exception
global general_protection
global page_fault
global copr_error		


divide_error:
		push 0xffffffff
		push 0
		jmp exception
single_step_exception:
		push 0xffffffff
		push 1
		jmp exception
nmi:
		push 0xffffffff
		push 2
		jmp exception
breakpoint_exception:
		push 0xffffffff
		push 3
		jmp exception
overflow:
		push 0xffffffff
		push 4
		jmp exception
bounds_check:
		push 0xffffffff
		push 5
		jmp exception
inval_opcode:
		push 0xffffffff
		push 6
		jmp exception
copr_not_available:
		push 0xffffffff
		push 7
		jmp exception
double_fault:
		push 0xffffffff
		push 8
		jmp exception
copr_seg_overrun:
		push 0xffffffff
		push 9
		jmp exception
inval_tss:						;have a error code 
		push 10
		jmp exception
segment_not_present:
		push 11
		jmp exception
stack_exception:
		push 12
		jmp exception
general_protection:
		push 13
		jmp exception
page_fault:
		push 14
		jmp exception
copr_error:
		push 16
		jmp exception
exception:
		call exception_handler
		add esp, 4 * 2
		hlt
