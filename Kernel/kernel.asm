;;; kernel.asm		(c) 2014 weiforrest
;;; 
%include "const.inc"
;;; extern function
extern cstart


;;; extern global variable
extern gdt_ptr
extern idt_ptr
extern disp_pos
extern p_proc_ready
extern tss
global StackTop
		
[SECTION .bss]
StackSpace		resb 4 * 1024
StackTop:		
[SECTION .data]
[SECTION .text]
		
global _start
global restart
global restart_reenter


_start:							;the gcc ld default use to be program entry
		mov esp, StackTop
		mov dword [disp_pos], 0
		sgdt	[gdt_ptr]
		call cstart
		lgdt	[gdt_ptr]
		lidt	[idt_ptr]
		mov ax, SELECTOR_TSS
		ltr ax

		jmp SELECTOR_KERNEL_CS:restart ;flush the instructor register cache
;;; set the corrent TSS for ready proc
;;; all interrupt use restart to return
restart:
		mov dword esp, [p_proc_ready]
		lldt [esp + OFFSET_LDT_PROC]
		lea eax, [esp + OFFSET_REGS_TOP]
		mov dword [tss + OFFSET_SP0_TSS], eax
restart_reenter:
		dec dword [reenter]
		pop gs
		pop fs
		pop es
		pop ds
		popad
		iretd					; will set the if bit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TODO: I find a implict bug in interrupt handle process,
;;; it like overwrite stack, but i don.t find it, I will be
;;; fix it by next occur
global save_regs
global reenter
reenter:		dd 0	;flag for interrupt reenter
;;; 这里使用reenter 作为是否已经在内核栈的判断
save_regs:		
		xchg dword eax, [esp] 	; ret addr <-> eax
		push ecx
		push edx
		push ebx
		push eax				;because esp not use,use it to save ret addr
		push ebp
		push esi
		push edi
		push ds
		push es
		push fs
		push gs
		
;;; 这里使用edi 保存着 eax在REGS的地址,用于syscall中修改作为返回值eax的值
;;; 不使用p_proc_ready,防止在syscall中, 时钟中断改变p_proc_ready的值.
		mov edi, esp				;edi is top of stack
		mov eax, SELECTOR_KERNEL_GS ;set the kernel segment selector
		mov gs, ax
		mov eax, SELECTOR_KERNEL_DS
		mov ds, ax
		mov es, ax
		mov fs, ax				;TODO: fs set the user date segment

		mov eax, [edi + 44] 	;restore eax
		
		inc dword [reenter]
		cmp dword [reenter], 0
		jne .reenter

		mov esp, StackTop
		push restart
		jmp [edi + 28]
;;; whatever the interrupt is reenter, the handle alway run
.reenter:
		push restart_reenter	;in kernel stack
		jmp [edi + 28]
;;; when save_regs return, esp still in kernel stack
;;; end of save_regs
