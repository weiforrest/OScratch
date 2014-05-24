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
extern reserved_int_table
extern restart
extern restart_reenter
extern reenter
;;; 保留中断前后,寄存器的值没有改变(REGS中的nouse_esp的值变了)
%macro reserved_int_no_error 1
		call save_regs
		push 0x0
		push edi
		call [reserved_int_table + 4 * %1]
		add esp, 8
		ret
%endmacro

divide_error:					;(int 0)no error code
		reserved_int_no_error 0
				
single_step_exception:			;(int 1)no error code
		reserved_int_no_error 1
		
nmi:							;(int 2)no error code
		reserved_int_no_error	2
				
breakpoint_exception: 		;(int 3)no error code
		reserved_int_no_error 3
		
overflow:						;(int 4) no error code
		reserved_int_no_error 4
		
bounds_check:					;(int 5)no error code
		reserved_int_no_error 5
		
inval_opcode:					;(int 6)no error code
		reserved_int_no_error 6
		
copr_not_available:				;(int 7)no error code
		reserved_int_no_error 7

save_regs_code:
		xchg eax, [esp + 4]		; ret addr <-> eax
		xchg ecx, [esp]			; error code <-> ecx
		push edx
		push ebx
		push eax				;ret addr
		push ebp
		push esi
		push edi
		push ds
		push es
		push fs
		push gs

		mov edi, esp
		mov eax, SELECTOR_KERNEL_GS
		mov gs, ax
		mov eax, SELECTOR_KERNEL_DS
		mov ds, ax
		mov es, ax
		mov fs, ax
		
		inc dword [reenter]
		cmp dword [reenter], 0
		jne .reenter
		mov esp, StackTop
		push restart
		jmp [edi + 28]
.reenter:
		push restart_reenter
		jmp [edi + 28]
;;; end of save_regs_code

%macro reserved_int_error 1
		call save_regs_code
		push ecx				;the ecx save the error code
		push edi
		call [reserved_int_table + 4 * %1]
		add esp,8
		ret
%endmacro

double_fault:					;(int 8)error code
		reserved_int_error 8
		
copr_seg_overrun:				;(int 9)no error code
		reserved_int_error 9
		
inval_tss:						;(int 10)error code 
		reserved_int_error 10
		
segment_not_present:			;(int 11)error code
		reserved_int_no_error 11
		
stack_exception:				;(int 12)error code
		reserved_int_error 12
		
general_protection:				;(int 13)error code
		reserved_int_error 13
		
page_fault:						;(int 14)error code
		reserved_int_error 14
		
copr_error:						;(int 16)error code
		;; int 15 号没有使用,于 reserved_int_table 偏移是15
		reserved_int_error 15

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
;;; 硬件中断前后所以的寄存器的值都没有修改(在REGS中nouse_esp的值变了),
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
		hwint_slave 8		
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
