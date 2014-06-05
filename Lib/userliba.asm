;;; userliba.asm   (c) weipforrest
		
global get_ticks
get_ticks:
		push ebp
		mov ebp, esp
		mov eax, 1
		int 0x80
		pop ebp
		ret

global write
write:	
		push ebp
		mov ebp,esp
		mov ebx, [ebp + 8]
		mov eax, 2
		int 0x80
		pop ebp
		ret
