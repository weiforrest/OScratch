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

;;; Descriptor Attribute
		
DA_32	EQU 0x4000				;32 bits code seg
		
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




	
