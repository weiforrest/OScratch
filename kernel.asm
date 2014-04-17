;;; kernel.asm		(c) 2014 weiforrest
;;;



[SECTION .text]
global _start


_start:
		mov ah, 0xf
		mov al, 'K'
		mov [gs:((80*1+39)*2)], ax
		mov ebx, 0xffff
		add bx, 1 
		jmp $
