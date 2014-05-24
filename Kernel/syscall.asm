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
;;; 系统中断发生前后,只有eax的值修改了,其他寄存器都得到了保存
systemcall:
		call save_regs
		;; 恢复edi的值,同时保存返回值eax的位置
		push edi
		push eax
		mov eax, edi
		mov edi, [eax + 16]
		pop eax
		
		sti
		call [sys_call_table + eax * 4]
		cli
		;; 修改返回值eax
		pop edi
		mov [edi + 44], eax
		mov dword [edi + 28], 0		;将nouse_esp的值设为0,出错便于查找
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

