[SECTION .data]
disp_pos	dd 0
[SECTION .text]

global disp_str

disp_str:
		push ebp
		mov ebp, esp

		push esi
		push edi
		
		mov esi, [ebp + 8]		;
		mov edi, [disp_pos]
		mov ah, 0xf
.1:
		lodsb
		test al, al
		jz .done
		cmp al, 0xa				;is enter key
		jnz .2
		push eax
		push ebx
		mov eax, edi
		mov bl, 160
		div bl
		and eax, 0xff
		inc eax
		mov bl, 160
		mul bl
		mov edi, eax
		pop ebx
		pop eax
		jmp .1
.2:
		mov [gs:edi], ax
		add edi, 2
		jmp .1
.done:
		mov [disp_pos], edi

		pop edi
		pop esi
		pop ebp
		ret
