;; boot.asm by the weiforrest
;; Compilation method:
;; 		nasm boot.asm -o boot.bin
;; Comment:
;; 		Boot module from the floppy sector 0 into 0x7c00,
;; 		and load the kernel_load from the floppy into 0x6000

BOOT_SEG 		equ 0x7c00
;;; load the load.bin to 0x9000:0x100
OffsetOfLoader	equ 0x100
BaseOfLoader	equ 0x9000

		org BOOT_SEG
;;; FAT12 boot sector format
		jmp LABEL_START			;BS_jmpBoot
		nop
BS_OEMName 		db		'WForrest' ;size must be 8
BPB_BytesPerSec dw		512		   ;bytes per sector
BPB_SecPerClus	db		1		   ;sector per cluster
BPB_RsvdSecCnt	dw		1		   ;how many sector used by boot record
BPB_NumFATS		db		2		   ;how many FAT table
BPB_ROOTEntCnt	dw		224		   ;the maximum number of file under the root
BPB_TotSec16	dw		2880	   ;count of logical sector(2*80*18)
BPB_Media		db		0xF0	   ;
BPB_FATSz16		dw		9		   ;sector per FAT
BPB_SecPerTrk	dw		18		   ;sector per track
BPB_NumHeads	dw		2		   ;count of disk head
BPB_HiddSec		dd		0		   ;count of hide sector
BPB_TotSec32	dd		0		   ;
BS_DrvNum		db		0		   ;interupt 13 drive number
BS_Reserved1	db		0		   ;
BS_BootSig		db		0x29	   ;extension boot sign
BS_VolID		dd		0		   ;
BS_VolLab		db		'wforrest0.1' ;size must be 11
BS_FileSysType	db		'FAT12   '	  ;size must be 8

LABEL_START:	
		mov ax, cs
		mov ds, ax
		mov es, ax
		mov sp, BOOT_SEG

;;; reset the floppy
		xor ah, ah
		xor dl, dl
		int 0x13
;;; begin to load
SectorNoOfRootDirectory		equ		19 ;first Sector number of RootDir
		mov word [wReadSectorNo], SectorNoOfRootDirectory
LABEL_BEGIN_SEARCH_ROOT_DIR:
		cmp word [wRootDirReadDone], 0
		jz LABEL_NOFOUND_LOADER
		dec word [wRootDirReadDone]
		mov ax, BaseOfLoader
		mov es, ax

		mov ax, word [wReadSectorNo]
		mov cx, 1
		mov bx, OffsetOfLoader
		call ReadSector

		add word [wReadSectorNo], 1
		mov di, OffsetOfLoader	; es:di	->	BaseOfLoader:OffsetOfLoader
		
		mov dx, 16				; each sector contain 16 dir entry
LABEL_LOOP_SECTOR:		
		mov cx, 11				; length of filename
		mov si, LoaderName		; ds:si	->	LoaderName
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

		jmp $
LABEL_FOUND_LOADER:
		
		call DispStr
		;; and di, 0xffe0
		;; add di, 0x1A
		jmp $


		
		
;;; input:
;;; 	ax: sector number
;;; 	cx: sector count
;;; 	es:bx:	Destination		
ReadSector:
		push bp
		mov bp, sp
		push dx
		
		sub esp, 2
		mov byte [bp - 2], cl
		
		push bx					;save the destination
		mov bl, [BPB_SecPerTrk]
		div bl
		inc ah
		mov cl, ah				;starting sector in current track
		mov dh, al
		and dh, 1				;disk head
		mov ch, al
		shr ch, 1				;track number
		pop bx
		
		mov dl, [BS_DrvNum]
.GoOnReading:
		mov ah, 2
		mov al, byte [bp - 2]
		int 0x13
		jc	.GoOnReading		;if occur error the CF will be set,so go on
		
		add sp, 2				;pop out cx
		pop dx
		pop bp
		ret

DispStr:
		mov ax, BootMessage
		mov bp,	ax				;; es:bp is the address of bootmessage 
		mov cx, 30 				;; the bootmessage length
		mov ax, 01301h
		mov bx, 000ch
		mov dl, 0				;; call the interrupt
		int 10h
		ret
		
;;; DATA
BootMessage:	db	"Hello, My World is begining..."
LoaderName:		db	"LOADER  BIN" ; size must be 11
wReadSectorNo	dw	0
RootDirSectors	equ 14			;BPB_RsvdSecCnt * 32(entry size) / 512
wRootDirReadDone dw	RootDirSectors
		times 510-($-$$)	db 0
		dw	0xaa55
		
		
