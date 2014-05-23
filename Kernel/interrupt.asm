;;; interrupt.asm	(c)weiforrest
;;; all interrupt handler entry for low-level
;;; contain the Intel reserver interrupt and
;;; hardware interrupt handler
%include "const.inc"


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
;;; extern do_*
extern do_divide_error
extern do_single_step_exception
extern do_nmi
extern do_breakpoint_exception
extern do_overflow
extern do_bounds_check
extern do_inval_opcode
extern do_copr_not_available
extern do_double_fault
extern do_copr_seg_overrun
extern do_inval_tss
extern do_segment_not_present
extern do_stack_exception
extern do_general_protection
extern do_page_fault
extern do_copr_error

;;; extern variable
extern StackTop
extern tss
extern hwirq_table
extern p_proc_ready
extern exception_handler

; 中断和异常 -- 异常
divide_error:
	push	0xFFFFFFFF	; no err code
	push	0		; vector_no	= 0
	jmp	exception
single_step_exception:
	push	0xFFFFFFFF	; no err code
	push	1		; vector_no	= 1
	jmp	exception
nmi:
	push	0xFFFFFFFF	; no err code
	push	2		; vector_no	= 2
	jmp	exception
breakpoint_exception:
	push	0xFFFFFFFF	; no err code
	push	3		; vector_no	= 3
	jmp	exception
overflow:
	push	0xFFFFFFFF	; no err code
	push	4		; vector_no	= 4
	jmp	exception
bounds_check:
	push	0xFFFFFFFF	; no err code
	push	5		; vector_no	= 5
	jmp	exception
inval_opcode:
	push	0xFFFFFFFF	; no err code
	push	6		; vector_no	= 6
	jmp	exception
copr_not_available:
	push	0xFFFFFFFF	; no err code
	push	7		; vector_no	= 7
	jmp	exception
double_fault:
	push	8		; vector_no	= 8
	jmp	exception
copr_seg_overrun:
	push	0xFFFFFFFF	; no err code
	push	9		; vector_no	= 9
	jmp	exception
inval_tss:
	push	10		; vector_no	= A
	jmp	exception
segment_not_present:
	push	11		; vector_no	= B
	jmp	exception
stack_exception:
	push	12		; vector_no	= C
	jmp	exception
general_protection:
	push	13		; vector_no	= D
	jmp	exception
page_fault:
	push	14		; vector_no	= E
	jmp	exception
copr_error:
	push	0xFFFFFFFF	; no err code
	push	16		; vector_no	= 10h
	jmp	exception

exception:
	call	exception_handler
	add	esp, 4*2	; 让栈顶指向 EIP，堆栈中从顶向下依次是：EIP、CS、EFLAGS
	hlt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TODO: move the hardware interrupt to independent files
global clock_interrupt
global keyboard_interrupt
global i8259aint02
global i8259aint03
global i8259aint04
global i8259aint05
global i8259aint06
global i8259aint07
global i8259aint08
global i8259aint09
global i8259aint10
global i8259aint11
global i8259aint12
global i8259aint13
global i8259aint14
global i8259aint15
global ignoreint

extern save_regs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro hwint_master 1
		call save_regs
		;; disable current interrupt
		in al, INT_M_CTLMASK
		or al, (1 << %1)
		out INT_M_CTLMASK, al
		;Send EOI
		mov al, EOI			
		out INT_M_CTL, al
		;; NOW we must be in kernel stack
		sti
		call [hwirq_table + 4 * %1]
		cli
		;; enable current interrupt
		in al, INT_M_CTLMASK
		and al, ~(1 << %1)
		out INT_M_CTLMASK, al
;;; reenter jump to restart_reenter (not to switch stack)
		ret						
%endmacro

%macro hwint_slave 1
		call save_regs
		in al, INT_S_CTLMASK
		or al, (1 << (%1 - 8))
		out INT_S_CTLMASK, al
		
		mov al, EOI			;reenable int
		out INT_M_CTL, al
		nop
		out INT_S_CTL, al		;Both Slave and Master
		sti
		call [hwirq_table + 4 * %1]
		cli
		in al, INT_S_CTLMASK
		and al, ~(1 << (%1 - 8))
		out INT_S_CTLMASK, al
		ret
%endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clock_interrupt:
		hwint_master 0
keyboard_interrupt:
		hwint_master 1		
i8259aint02:
		hwint_master 2
i8259aint03:
		hwint_master 3		
i8259aint04:
		hwint_master 4		
i8259aint05:
		hwint_master 5		
i8259aint06:
		hwint_master 6		
i8259aint07:
		hwint_master 7		
i8259aint08:
		hwint_master 8		
i8259aint09:
		hwint_slave 9
i8259aint10:
		hwint_slave 10
i8259aint11:
		hwint_slave 11
i8259aint12:
		hwint_slave 12
i8259aint13:
		hwint_slave 13
i8259aint14:
		hwint_slave 14
i8259aint15:
		hwint_slave 15
		
ignoreint:
		pushad
		push ds
		push es
		push fs
		push gs
		
		mov ax, 0x18
		mov gs, ax
		inc byte [gs:2]

		pop gs
		pop fs
		pop es
		pop ds
		popad
		iretd
