;;; load.asm		(c) 2014 weiforrest
;;; Compilation method:
;;; 		nasm load.asm -o load.bin
;;; Comment:
;;; 		Load module from floppy into 0x6000 by Boot module 
;;; 		and load the Kernel into 0x8000, now is the protect mode

		
%include "fat12def.inc"

		org 0x100
		jmp LABEL_START
TopOfStack	equ	0x100
BaseOfKernel	equ 0x8000
OffsetOfKernel	equ 0

[SECTION .s16]
[BITS 16]
LABEL_START:
;;; initialization the register
		mov ax, cs
		mov ds, ax
		mov es, ax
		mov ss, ax
		mov sp, TopOfStack

		mov si, LoadMessage
		call DispString		;display Loading
;;; reset the floppy
		xor ah, ah
		xor dl, dl
		int 0x13
;;; begin to load kernel
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
		cli
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
		call DispString
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
		call DispString
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
		call DispString
		jmp BaseOfKernel:OffsetOfKernel


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


		
;;; DispString
;;; input:
;;; 			ds:si -> message
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

	
;;; DATA
LoadMessage:	db	"Loading",0
NotFoundMessage:db	"Not Found Kernel",0
KernelName:		db	"KERNEL  BIN"
DotMessage:		db	".", 0
wReadSectorNo	dw	0
ReturnMessage:	db	13, 10, 0
wRootDirReadDone dw RootDirSectors
