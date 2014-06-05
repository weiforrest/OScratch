DispString:
		push eax
		mov ah, 0xc
		cld
.goon:
		lodsb
		test al, al
		jz .done
		mov [gs:edi], ax
		add edi, 2
		jmp .goon
.done:
		pop eax
		ret
		
DispReturn:
		push eax
		push ebx
		xor eax, eax
		
		mov bl, 160
		mov eax, edi
		div bl
		and eax,0xff
		inc eax
		mov bl, 160
		mul bl
		mov edi, eax
		pop ebx
		pop eax
		ret

DispAl:
		push ebx
		xor ebx, ebx
		mov bl, al
		and eax, 0xff
		shr al, 4
.char:
		cmp al, 9
		ja .hex
		add al, '0'
		jmp .display
.hex:
		sub al, 10
		add al, 'A'
.display:
		mov ah, 0xc
		mov [gs:edi], ax
		add edi, 2
		cmp bh, 0
		jnz .done
		mov al, bl
		and al, 0xf
		mov bh, 1
		jmp .char
.done:
		pop ebx
		ret

;;; input: eax
DispInt:
		push ebx
		mov ebx, eax
		shr eax, 24
		call DispAl

		mov eax, ebx
		shr eax, 16
		call DispAl

		mov eax, ebx
		shr eax, 8
		call DispAl

		mov eax, ebx
		call DispAl

		mov ah, 0x7
		mov al, 'h'
		mov [gs:edi], ax
		add edi, 2
		
		pop ebx
		ret

