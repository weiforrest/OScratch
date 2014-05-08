extern disp_pos
[SECTION .text]

SELECTOR_KERNEL_GS equ 0x18
global disp_color_str
global itoa

;;; void disp_color_str(char *, int)
disp_color_str:
		push ebp
		mov ebp, esp

		push gs
		push esi
		push edi

		mov ax, SELECTOR_KERNEL_GS
		mov gs, ax
		
		mov esi, [ebp + 8]		;
		mov edi, [disp_pos]
		mov ah, [ebp + 12]
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
		mov word [gs:edi], ax
		add edi, 2
		jmp .1
.done:
		mov dword [disp_pos], edi

		pop edi
		pop esi
		pop gs
		pop ebp
		ret

		
;;; char * itoa(char *, int)
itoa:
		push ebp
		mov ebp, esp

		push edi
		push ebx
		push ecx
		
		mov edi, dword [ebp + 8]
		add edi, 7
		mov byte[edi + 1], 0
		mov ebx, dword [ebp + 12]
		xor eax, eax
		mov ecx, 8
.1:
		mov al, bl
		and al, 0xf
		cmp al, 9
		ja .hex
		add al, '0'
		jmp .high_half
.hex:
		add al, 55
.high_half:
		mov byte [edi], al
		dec edi
		shr ebx, 4
		dec ecx
		jnz .1

		mov eax, edi
		pop ecx
		pop ebx
		pop edi
		pop ebp
		ret
		
		
		
		
