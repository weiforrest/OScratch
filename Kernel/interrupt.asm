;;; interrupt.asm	(c)weiforrest
;;; all interrupt handler entry
extern exception_handler
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

global i8259aint00
global i8259aint01
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

extern i8259a_irq

i8259aint00:
		push 0
		jmp i8259aint
i8259aint01:
		push 1
		jmp i8259aint
i8259aint02:
		push 2
		jmp i8259aint
i8259aint03:
		push 3
		jmp i8259aint
i8259aint04:
		push 4
		jmp i8259aint
i8259aint05:
		push 5
		jmp i8259aint
i8259aint06:
		push 6
		jmp i8259aint
i8259aint07:
		push 7
		jmp i8259aint
i8259aint08:
		push 8
		jmp i8259aint
i8259aint09:
		push 9
		jmp i8259aint
i8259aint10:
		push 10
		jmp i8259aint
i8259aint11:
		push 11
		jmp i8259aint
i8259aint12:
		push 12
		jmp i8259aint
i8259aint13:
		push 13
		jmp i8259aint
i8259aint14:
		push 14
		jmp i8259aint
i8259aint15:
		push 15
		jmp i8259aint
i8259aint:
		call i8259a_irq
		add esp, 4
		hlt