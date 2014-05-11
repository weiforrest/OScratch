;;; userliba.asm   (c) weiforrest
		
global print

print:
		push ebp
		mov ebp, esp
		
		mov eax, 1
		mov dword ebx, [ebp + 8]
		int 0x80

		pop ebp
		ret
