
SELECTOR_KERNEL_CS equ 0x8
SELECTOR_KERNEL_DS equ 0x10
SELECTOR_KERNEL_GS equ 0x18
SELECTOR_TSS equ 0x20
SELECTOR_FIRST_LDT equ 0x28

INT_M_CTL equ 0x20
INT_S_CTL equ 0xa0
INT_M_CTLMASK equ 0x21
INT_S_CTLMASK equ 0xa1
		
EOI equ 0x20
		
OFFSET_REGS_TOP equ 68
OFFSET_LDT_PROC equ 68

OFFSET_SP0_TSS equ 4
