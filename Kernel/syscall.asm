;;; syscall.asm		(c) weiforrest
;;;
%include "const.inc"

extern p_proc_ready
extern StackTop
extern sys_call_table
extern save_regs
global systemcall
;;; same as linux syscall
;;; eax = function number
;;; ebx ecx edx is argument
systemcall:
		call save_regs
		sti
		call [sys_call_table + eax * 4]
		mov [edi], eax	;
		cli
		ret


extern ticks
extern disp_color_str
global sys_get_ticks
sys_get_ticks:
		mov eax, [ticks]
		ret


		
global sys_disp
sys_disp:
		push 0xf
		push ebx
		call disp_color_str
		add esp, 8
		ret

