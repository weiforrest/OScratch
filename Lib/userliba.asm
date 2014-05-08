
global print

print:
		push ebp
		mov ebp, esp
		
		mov dword eax, [ebp + 8]
		int 0x80

		pop ebp
		ret
