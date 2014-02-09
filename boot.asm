;; The Boot.asm by the 2013-11-23


		org 0x7c00
		mov ax, cs
		mov ds, ax
		mov es, ax
		call DispStr
		jmp $


DispStr:
		mov ax, BootMessage
		mov bp,	ax				; es:bp is the address of bootmessage 
		mov cx, 30			; the bootmessage length
		mov ax, 01301h
		mov bx, 000ch
		mov dl, 0				; call the interrupt
		int 10h
		ret

BootMessage:	db	"Hello, My World is begining..."
		times 510-($-$$)	db 0
		dw	0xaa55
		
		
