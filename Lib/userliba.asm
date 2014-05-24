;;; userliba.asm   (c) weiforrest
		
global print

print:
		push ebp
		mov ebp, esp
		
		mov eax, 2
		mov dword ebx, [ebp + 8]
		int 0x80

		pop ebp
		ret

global get_ticks
get_ticks:
		push ebp
		mov ebp, esp
		mov eax, 1
		int 0x80
		pop ebp
		ret

global read_keyboard
read_keyboard:	
		push ebp
		mov ebp,esp
		mov eax, 3
		int 0x80
		pop ebp
		ret
