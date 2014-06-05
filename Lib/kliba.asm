%include "const.inc"

extern disp_pos
[SECTION .text]

global itoa		
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
		
		
global enable_hwirq
global disable_hwirq

enable_hwirq:
	mov	ecx, [esp + 4]		; irq
	pushf					;save current state of interrupt
	cli
	mov	ah, ~1
	rol	ah, cl			; ah = ~(1 << (irq % 8))
	cmp	cl, 8
	jae	enable_8		; enable irq >= 8 at the slave 8259
enable_0:
	in	al, INT_M_CTLMASK
	and	al, ah
	out	INT_M_CTLMASK, al	; clear bit at master 8259
	popf
	ret
enable_8:
	in	al, INT_S_CTLMASK
	and	al, ah
	out	INT_S_CTLMASK, al	; clear bit at slave 8259
	popf
	ret

disable_hwirq:
		mov ecx, [esp + 4]
		pushf
		cli
		mov ah, 1
		rol ah, cl
		cmp cl, 8
		jae disable_8
disable_0:
		in al, INT_M_CTLMASK
		test al, ah
		jnz dis_already
		or al, ah
		out INT_M_CTLMASK, al
		popf
		mov eax, 1
		ret
disable_8:
		in al, INT_S_CTLMASK
		test al, ah
		jnz dis_already
		or al, ah
		out INT_S_CTLMASK, al
		popf
		mov eax, 1
		ret
dis_already
		popf
		xor eax, eax
		ret

global hlt
hlt:
		hlt


