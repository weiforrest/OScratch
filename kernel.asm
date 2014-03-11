;;; kernel.asm		(c) 2014 weiforrest
;;; it just a scratch kernel, only for test the load.asm



[SECTION .16]
[BITS 16]
		mov ax, 0x8000
		mov es, ax
		mov ds, ax
		
		;; call ClearScreen
		mov si, Message
		call DispString
		mov si, ReturnString
		call DispString
		jmp $


ClearScreen:
		pusha
		mov ax, 0x0600
		xor cx, cx
		xor bh, 0xf
		mov dh, 24
		mov dl,79
		int 0x10

SetCursorPostion:
		mov ah, 02
		mov bh, 0
		mov dx, 0
		int 0x10
		popa
		ret

;;; DispString
;;; input:
;;; 			es:si -> message
DispString:
		pusha
		mov ah, 0xe
		xor bh, bh
		cld
.loop:
		lodsb
		test al, al
		jz .done
		int 0x10
		jmp .loop
.done:
		popa
		ret


Message:		db "into kernel",0
ReturnString:	db 13, 10, 0
