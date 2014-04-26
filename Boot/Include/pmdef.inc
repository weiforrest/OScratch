; The Protect Mode define

;;; Descriptor
;;; Usage Descriptor Base, Limit, Attr
;;; Base: dd
;;; limit: dd
;;; Attr: dw

%macro Descriptor 3
	dw %2 & 0xffff
	dw %1 & 0xffff
	db (%1 >> 16) & 0xff
	dw (%3 & 0xf0ff) | ((%2 >> 8) & 0x0f00)
	db (%1 >> 24) & 0xff
%endmacro

;;; Gate
;;; Usage Gate Base, Selector, DCount, Attr
;;; Base: dd
;;; Selector: dw
;;; Dcount: db
;;; Attr: db
%macro Gate 4
	dw %1 & 0xffff
	dw %2
	dw (%3 & 0x1f) | ((%4 << 8) & 0xff00)
	dw (%1 >> 16) & 0xffff
%endmacro


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
		
;;; Descriptor Attribute
		
DA_32	EQU 0x4000				;32 bits code seg
DA_LIMIT_4K EQU 0x8000			
;;; Descriptor Privilege level
DA_DPL0	EQU 0x00
DA_DPL1	EQU 0x20
DA_DPL2	EQU 0x40
DA_DPL3 EQU 0x60

;;; data or code segment 
DA_DR	EQU 0x90
DA_DRW	EQU 0x92
DA_DRWA	EQU 0x93
DA_C	EQU 0x98
DA_CR	EQU 0x9A
DA_CCO	EQU 0x9C				;only executable conforming code segment
DA_CCOR	EQU 0x9E				;executable and readable conforming code segment

;;; system or gate segment
DA_LDT		EQU 0x82
DA_TaskGate EQU 0x85
DA_386TSS	EQU 0x89
DA_386CGate	EQU 0x8C
DA_386IGate EQU 0x8E
DA_386TGate EQU 0x8F

;;; Page attribute
PG_P		EQU 0x1
PG_RW		EQU 0x2
PG_USU		EQU 0x4




	
