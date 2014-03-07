;;; load.asm by the weiforrest
;;; Compilation method:
;;; 		nasm load.asm -o load.bin
;;; Comment:
;;; 		Load module from floppy into 0x6000 by Boot module 
;;; 		and load the Kernel into 0x8000, now is the protect mode


%include "pmdef.inc"		
	
		org 0x100
		jmp LABEL_START
[SECTION .gdt]
;; GDT
LABEL_GDT:			Descriptor			0,			    	0,			0 		; The NULL DESC
LABEL_DESC_NORMAL:	Descriptor			0,   		   0xffff,	DA_DRW		 	; Normal DESC
LABEL_DESC_CODE16:	Descriptor			0,			   0xffff,  DA_C
LABEL_DESC_CODE32:	Descriptor			0,   Code32SegLen - 1,	DA_C + DA_32 	; Code32 DESC
LABEL_DESC_DATA:	Descriptor			0,	   DataSegLen - 1,	DA_DRW 			; Data32 DESC
LABEL_DESC_STACK:	Descriptor			0,	  	   TopOfStack,  DA_DRW + DA_32	; Stack DESC
LABEL_DESC_VIDEO:	Descriptor	  0xb8000,	 		   0xffff,  DA_DRW			; Display Memory DESC
;;; END of GDT

		
GdtLen	equ	$ - LABEL_GDT
GdtPtr	dw	GdtLen - 1
		dd 0
		
;;; GDT Selectors
SelectorNormal	equ LABEL_DESC_NORMAL - LABEL_GDT
SelectorCode32	equ LABEL_DESC_CODE32 - LABEL_GDT
SelectorCode16 	equ LABEL_DESC_CODE16 - LABEL_GDT
SelectorData	equ LABEL_DESC_DATA - LABEL_GDT
SelectorStack	equ LABEL_DESC_STACK - LABEL_GDT
SelectorVideo	equ	LABEL_DESC_VIDEO - LABEL_GDT
;;; END of Selectors

[SECTION .data]
ALIGN 32
[BITS 32]
LABEL_DATA:
;; SPValueInRealMode dw 0
PMMessage:		db "In Protect Mode now. ^-^", 0
OffsetPMMessage equ PMMessage - $$
;; TestString:		db "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
;; OffsetTestString equ TestString - $$
DataSegLen equ $ - $$
;;; END of [SECTION .data]

[SECTION .gs]
ALIGN 32
[BITS 32]
LABEL_STACK:
		times 512 db 0
TopOfStack equ $ - $$ - 1

;;; END of [SECTION .gs]
		
[SECTION .s16]
[BITS 16]
LABEL_START:
;;; initialization the register
		mov ax, cs
		mov ds, ax
		mov es, ax
		mov ss, ax
		mov sp, 0x100
		
;;; initialization the Descriptor MACRO
;;; usage: InitDesc Lable, Desc		
%macro InitDesc 2
		xor eax, eax
		mov ax, cs
		shl eax, 4				;shifted left
		add eax, %1				;get the lable address in read-mode
		mov [%2 + 2], ax
		shr eax, 16				;shifted right
		mov byte [%2 + 4], al
		mov byte [%2 + 7], ah
%endmacro
		
		
;;; init the Code32 DESC
		InitDesc LABEL_CODE32, LABEL_DESC_CODE32
		
;;; Data DESC
		InitDesc LABEL_DATA, LABEL_DESC_DATA
		
;;; Stack DESC
		InitDesc LABEL_STACK, LABEL_DESC_STACK
		
;;; init the GDTPTR
		xor eax, eax
		mov ax, cs
		shl eax, 4
		add eax, LABEL_GDT
		mov dword [GdtPtr + 2], eax ;set the GDT address into GDTPTR
	
;;; load the GDT
		lgdt [GdtPtr]
		
;;; close the interupt
		cli
		
;;; open the A20 address line
		in al, 0x92
		or al, 00000010b
		out 92h, al

;;; set the cr0
		mov eax, cr0
		or eax, 1
		mov cr0, eax
		
;;; jmp to protect mode
		jmp dword SelectorCode32:0	;jmp to LABEL_CODE32 

;;; END of [SECTION .s16]

[SECTION .s32]
[BITS 32]
LABEL_CODE32:

		mov ax, SelectorVideo
		mov gs, ax

		mov ax, SelectorData
		mov ds, ax
		
		mov ax, SelectorStack
		mov ss, ax
		
		mov esp, TopOfStack
		
		mov eax, OffsetPMMessage
		mov ebx, 2
		call DispStr32

		jmp $


DispStr32:
		push esi
		push edi
		mov esi, eax
		mov eax, 80*2
		mul bl
		mov edi, eax			;edi = ebx * 160
		xor eax, eax
		mov ah, 0xC				;set the string color: red letter, black background
		cld						;set the direct for lodsb
.1:
		lodsb					;mov al, [esi] ;inc esi
		test al,al
		jz .2
		mov [gs:edi], ax
		add edi, 2
		jmp .1
.2:
		call DispReturn
		pop edi
		pop esi
		ret

DispReturn:
		push ebx
		push eax
		mov eax, edi
		mov bl, 80*2
		div bl
		and eax, 0xff			;retain quotient
		inc eax
		mov bl, 80*2
		mul bl
		mov edi, eax
		pop eax
		pop ebx
		ret 
;;; END of [SECTION .s32]
Code32SegLen equ $ - $$ - 1
