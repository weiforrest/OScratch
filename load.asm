;;; load.asm		(c) 2014 weiforrest
;;; Compilation method:
;;; 		nasm load.asm -o load.bin
;;; Comment:
;;; 		Load module from floppy into 0x6000 by Boot module 
;;; 		and load the Kernel into 0x8000, now is the protect mode

		
%include "fat12def.inc"
%include "pmdef.inc"
PageDirBase equ 0x100000
PageTblBase equ 0x101000
BaseOfLoad equ 0x90000
BaseOfKernel	equ 0x8000
OffsetOfKernel	equ 0
KernelPhyAddr	equ 0x30400
		org 0x100
		jmp LABEL_START
		
;;; DATA
LoadMessage:	db	"Loading",0
NotFoundMessage:db	"Not Found Kernel",0
KernelName:		db	"KERNEL  BIN"
DotMessage:		db	".", 0
wReadSectorNo	dw	0
ReturnMessage:	db	13, 10, 0
wRootDirReadDone dw RootDirSectors
[SECTION .s16]
[BITS 16]
LABEL_START:
;;; initialization the register
		mov ax, cs				;0x9000:0x100
		mov ds, ax
		mov es, ax
		mov ss, ax
		mov sp,	0x100 

;display Loading
		mov si, LoadMessage
		call DispStr		

		
;;; begin to load kernel
;;; reset the floppy
		xor ah, ah
		xor dl, dl
		int 0x13
		mov word [wReadSectorNo], SectorNoOfRootDirectory
LABEL_BEGIN_SEARCH_ROOT_DIR:
		cmp word [wRootDirReadDone], 0
		jz LABEL_NOFOUND_LOADER
		dec word [wRootDirReadDone]
		mov ax, BaseOfKernel
		mov es, ax

		mov ax, word [wReadSectorNo]
		mov cx, 1
		mov bx, OffsetOfKernel
		call ReadSector

		add word [wReadSectorNo], 1
		mov di, OffsetOfKernel	; es:di	->	BaseOfKernel:OffsetOfKernel
		
		mov dx, 16				; each sector contain 16 dir entry
LABEL_LOOP_SECTOR:		
		mov cx, 11				; length of filename
		mov si, KernelName		; ds:si	->	KernelName
LABEL_COMPARE_NAME:		
		lodsb
		cmp [es:di], al
		jz	LABEL_COMPARE_NAME_GOON
		jmp LABEL_DIFFER_NAME
LABEL_COMPARE_NAME_GOON:
		dec cx
		cmp cx, 0
		jz LABEL_FOUND_LOADER
		inc di
		jmp LABEL_COMPARE_NAME
LABEL_DIFFER_NAME:
		and di, 0xffe0			;the entry size is 32 bytes,  small 10 0000b 
		add di, 32
		dec dx
		cmp dx, 0
		jz LABEL_BEGIN_SEARCH_ROOT_DIR
		jmp LABEL_LOOP_SECTOR
LABEL_NOFOUND_LOADER:
		mov si, NotFoundMessage
		call DispStr
		jmp $
LABEL_FOUND_LOADER:
;;; begin to load the load.bin 
		and di, 0xffe0
		add di, 0x1A
		mov ax, BaseOfKernel
		mov es, ax
		mov ax, word [es:di] 			;begin FATEntry of kernel.bin
		mov di, OffsetOfKernel			;kernel.bin to BaseOfKernel:OffsetOfKernel
		xor dx, dx
LABEL_GOON_LOAD:
		mov cx, 1
		mov si, DotMessage
		call DispStr
		push ax						;save the FATEntry
		mov bx, di
		add ax, FileDataSectorNo
		call ReadSector
		add di, 512
		pop ax
		call GetFATEntry			;ax return the next FATEntry
		cmp ax, 0xfff
		jnz LABEL_GOON_LOAD
LABEL_LOADED_BIN:		
		mov si, ReturnMessage
		call DispStr
		call CloseFloppy

		mov ax, ds 
		mov es, ax
		mov di, MemoryInfoBlk
		call GetMemoryInfo
		
;;; Into protect mode
;;; Stack DESC
		InitDesc LABEL_STACK, LABEL_DESC_STACK
;;; init the GDTPTR
		xor eax, eax
		mov ax, cs
		shl eax, 4
		add eax, LABEL_GDT
		mov dword [GdtPtr + 2], eax ;set the GDT address into GDTPTR
	
;;; close the interupt
		cli
;;; init the IDTPTR
		xor eax, eax
		mov ax, cs
		shl eax, 4
		add eax, LABEL_IDT
		mov dword [IdtPtr + 2], eax
		
;;; load the GDT and IDT
		lgdt [GdtPtr]
		lidt [IdtPtr]

;;; open the A20 address line
		in al, 0x92
		or al, 00000010b
		out 92h, al

;;; set the cr0
		mov ax, 1
		lmsw ax
		jmp dword SelectorFLATC:LABEL_CODE32 + BaseOfLoad	;jmp to LABEL_CODE32 

;;; input:
;;; es:di : address of memory info block
GetMemoryInfo:
		push eax
		push ebx
		push ecx
		push edx
		
		xor ebx, ebx
.Loop:
		mov eax, 0xe820
		mov ecx, 20
		mov edx, 0x534d4150
		int 0x15
		jc .GetError
		add di, 20
		inc dword [ddMemInfoBlkNum]
		cmp ebx, 0
		je .Done
		jmp .Loop
.GetError:
		mov dword [ddMemInfoBlkNum], 0
.Done:
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret

;;; input:
;;; 	ax:FATEntry number
GetFATEntry:
		push bp
		mov bp, sp
		sub sp, 2
		mov word [bp - 2], ax	;save the FATEntry number
		push es
		mov ax, BaseOfKernel
		sub ax, 0x100
		mov es, ax
		mov bx, OffsetOfKernel		;read FAT1 to BaseOfLoad-0x100:0x100, maximun size is 4k
		mov ax, word [bp - 2]
		shr ax, 1
		push dx
		mov dl, 3
		mul dl
		pop dx
		test word [bp - 2], 1
		jz .EVENNUM
		inc ax
.EVENNUM:
		push ax
		shr ax, 9				; ax = ax / 512 (1 << 9)
		add ax,SectorNoOfFAT1 	; get the sector number of FATEntry
		cmp ax, dx				; dx save privous sector number  
		jz .OLDSECTOR
		mov dx, ax
		mov cx, 2				;handle the FATEntry crossover two sector
		call ReadSector			;read the sector 
.OLDSECTOR:
		pop ax
		and ax, 111111111b		; Offset of FATEntry in BaseOfLoad-0x100:0x100
		add bx, ax
		mov ax, word [es:bx]
		test word [bp - 2], 1
		jz .EVENNUM1
		shr ax, 4
		jmp .DONE
.EVENNUM1:
		and ax, 0xfff
.DONE:
		pop es
		add sp, 2 
		pop bp
		ret
		
;;; input:
;;; 	ax: sector number
;;; 	cx: sector count
;;; 	es:bx:	Destination		
ReadSector:
		push bp
		mov bp, sp
		sub sp, 2
		mov byte [bp - 2], cl
		
		push dx
		push bx					;save the destination
		mov bl, SecPerTrk
		div bl
		inc ah
		mov cl, ah				;starting sector in current track
		mov dh, al
		and dh, 1				;disk head
		mov ch, al
		shr ch, 1				;track number
		pop bx
		
		mov dl, DrvNum
.GoOnReading:
		mov ah, 2
		mov al, byte [bp - 2]
		int 0x13
		jc	.GoOnReading		;if occur error the CF will be set,so go on
		
		pop dx
		add sp, 2				;pop out cx
		pop bp
		ret


		
;;; DispStr
;;; input:
;;; 			ds:si -> message
DispStr:
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

CloseFloppy:
		push dx
		mov dx, 0x03f2
		mov al, 0
		out dx, al
		pop dx
		ret


;;; End Of [SECTION .s16]

[SECTION .gdt]
;; GDT
LABEL_GDT:			Descriptor			0,			    	0,			0 		; The NULL DESC
LABEL_DESC_NORMAL:	Descriptor			0,   		   0xffff,	DA_DRW		 	; Normal DESC
LABEL_DESC_STACK:	Descriptor			0,	  	   TopOfStack,  DA_DRW + DA_32	; Stack DESC
LABEL_DESC_VIDEO:	Descriptor	  0xb8000,	 		   0xffff,  DA_DRW			; Display Memory DESC
LABEL_DESC_FLATRW:	Descriptor 			0,			  0xfffff,	DA_DRW | DA_LIMIT_4K
LABEL_DESC_FLATC:	Descriptor			0,			  0xfffff,	DA_C | DA_CR | DA_LIMIT_4K | DA_32
;;; END of GDT

GdtLen	equ	$ - LABEL_GDT
GdtPtr	dw	GdtLen - 1
		dd 0

;;; GDT Selectors
SelectorNormal	equ LABEL_DESC_NORMAL - LABEL_GDT
SelectorStack	equ LABEL_DESC_STACK - LABEL_GDT
SelectorVideo	equ	LABEL_DESC_VIDEO - LABEL_GDT
SelectorFLATC equ LABEL_DESC_FLATC - LABEL_GDT
SelectorFLATRW equ LABEL_DESC_FLATRW - LABEL_GDT
;;; END of Selectors

[SECTION .idt]
;;; IDT
LABEL_IDT:
%rep 255
		Gate	SelectorFLATC,  DefaultHandle, 0, DA_386IGate
%endrep
;;; END of IDT

IdtLen	equ $ - LABEL_IDT
IdtPtr	dw IdtLen - 1
		dd 0

[SECTION .data]
ALIGN 32
[BITS 32]
LABEL_DATA:
;; SPValueInRealMode dw 0
PMMessage:		db "BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0
OffsetPMMessage equ PMMessage + BaseOfLoad
RamSizeMessage:	db "RAM size: ", 0
OffsetRamSizeMessage equ RamSizeMessage + BaseOfLoad
MemoryInfoBlk:		times 256 db 0
OffsetMemoryInfoBlk equ MemoryInfoBlk + BaseOfLoad
ddMemInfoBlkNum:		dd 0
OffsetMemoryInfoBlkNum equ ddMemInfoBlkNum + BaseOfLoad
ddMemorySize:	dd 0
OffsetMemorySize equ ddMemorySize + BaseOfLoad
ddPageTblNum:	dd 0
OffsetPageTblNum equ ddPageTblNum + BaseOfLoad
ddCursorPosition:		dd 0
OffsetCursorPosition equ ddCursorPosition + BaseOfLoad
DataSegLen equ $ - $$
;;; END of [SECTION .data]

[SECTION .gs]
ALIGN 32
[BITS 32]
LABEL_STACK:
		times 512 db 0
TopOfStack equ $ - $$ - 1

;;; END of [SECTION .gs]

[SECTION .s32]
ALIGN 32
[BITS 32]
LABEL_CODE32:
		mov ax, SelectorVideo
		mov gs, ax

		mov ax, SelectorFLATRW
		mov ds, ax
		mov es, ax
		
		mov ax, SelectorStack
		mov ss, ax
		
		mov esp, TopOfStack
		
		mov dword [OffsetCursorPosition], 640
		mov edi, [OffsetCursorPosition]
		mov esi, OffsetPMMessage
		call DispString
		call DispReturn
		mov esi, OffsetMemoryInfoBlk
		call DispMemInfo
		mov dword [OffsetCursorPosition], edi
		call SetupPage
		
		call InitKernel
		jmp SelectorFLATC:0x30400 
%include "Displib.inc"
		
;;; input esi: Memory info block
DispMemInfo:
		push ecx
		push ebx
		push edx

		mov ecx, [OffsetMemoryInfoBlkNum]
.loop:
		cmp ecx, 0
		jz .done
		dec ecx
		mov edx, 5
		mov ebx, esi
.loop1:
		mov eax, dword [ebx]
		call DispInt
		add edi, 2
		dec edx
		add ebx, 4
		cmp edx, 0
		jnz .loop1
		call DispReturn
		cmp dword [esi + 16], 1
		jnz .Reserved
		mov eax, dword [esi]
		add eax, dword [esi + 8]
		cmp eax, dword [OffsetMemorySize]
		jb .Reserved
		mov dword [OffsetMemorySize], eax

.Reserved:
		add esi, 20
		jmp .loop
.done:
		mov esi, OffsetRamSizeMessage
		call DispString
		mov eax, dword [OffsetMemorySize]
		call DispInt
		call DispReturn

		pop edx
		pop ebx
		pop ecx
		ret

SetupPage:
		push es
		push eax
		push ebx
		push ecx
		push edx
		push edi

		mov ax, SelectorFLATRW
		mov es, ax

		xor edx, edx
		mov eax, dword [OffsetMemorySize]
		mov ebx, 0x400000		;4M
		div ebx
		mov ecx, eax
		test edx, edx
		jz .1
		inc ecx
.1:
		mov dword [OffsetPageTblNum], ecx
		mov edi, PageDirBase
		xor eax, eax
		mov eax, PageTblBase | PG_P | PG_USU | PG_RW
		cld
.2:
		stosd					;move eax to es:edi
		add eax, 4096
		loop .2

		
		mov ebx, 1024
		mov eax, dword [OffsetPageTblNum]
		mul ebx
		mov ecx, eax

		mov edi, PageTblBase
		xor eax, eax
		mov eax, PG_P | PG_USU | PG_RW
.3:
		stosd
		add eax, 4096
		loop .3

		mov eax, PageDirBase
		mov cr3, eax
		mov eax, cr0
		or eax, 0x80000000
		mov cr0, eax
		jmp short .4			;flush the instruction stream
.4:
		nop

		pop edi
		pop edx
		pop ecx
		pop ebx
		pop eax
		pop es
		ret

DefaultHandle:
		

		iretd


InitKernel:
		push eax
		push ebx
		push ecx
		push esi
		
		xor ecx, ecx
		mov cx, word [BaseOfKernel * 0x10 + 44] ;get the program header number
		mov esi, dword [BaseOfKernel * 0x10 + 28] ;get the program header table offset
		add esi, BaseOfKernel * 0x10			   ;esi point the program header table
		mov bx, word [BaseOfKernel + 42]		   ;program header size
		movzx ebx, bx
.begin:
		mov eax, dword [esi]
		cmp eax, 0
		jz .noCpy
		
		push dword [esi + 16]	;program section filesize
		mov eax, dword [esi + 4] ; program section fileoffset
		add eax, BaseOfKernel * 0x10	 ; source
		push eax
		push dword [esi + 8]	; dest
		call MemCpy
		add esp, 12
.noCpy:
		add esi, ebx			;program header size
		dec ecx
		jnz .begin
		pop esi
		pop ecx
		pop ebx
		pop eax
		ret

MemCpy:
		push ebp
		mov ebp, esp
		push eax
		push ecx
		push esi
		push edi
		mov ecx, dword [ebp + 16]
		mov esi, dword [ebp + 12]
		mov edi, dword [ebp + 8]
		cmp ecx, 0
		jz .CpyDone

		rep movsb

.CpyDone:
		pop edi
		pop esi
		pop ecx
		pop eax
		pop ebp
		ret
		

		
		
;;; End of [SECTION .s32]
Code32SegLen equ $ - $$
