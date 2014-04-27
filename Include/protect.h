#ifndef __OSCRATCH_PROTECT_H
#define __OSCRATCH_PROTECT_H

#include <types.h>

typedef struct{
	 u16 limit_low;
	 u16 base_low;
	 u8 base_mid;
	 u8 attr;
	 u8 limit_high_attr;
	 u8 base_hith;
}DESCRIPTOR;

typedef struct{
	 u16 offset_low;
	 u16 selector;
	 u8 dcount;
	 u8 attr;
	 u16 offset_high;
}GATE;


#define OUT_BYTE(port, value)\
		  __asm__ volatile ("outb %%al,%%dx\n"	\
							"nop\n"				\
							"nop\n"				\
							::"d"(port),"a"(value));

#define IN_BYTE(port) ({\
	 unsigned char _v;\
__asm__ volatile ("inb %%dx,%%al\n"				\
				  "nop\n"						\
				  "nop\n"								\
				  :"=a"(_v):"d"(port));					\
_v;})

/* descriptor attribute */
#define DA_32 0x4000
#define DA_LIMIT_4K 0x8000

#define DA_LDT		0x82
#define DA_TaskGate 0x85
#define DA_386TSS	0x89
#define DA_386CGate 0x8C
#define DA_386IGate 0x8E
#define DA_386TGate 0x8F

/* privilege level */
#define PRIVILEGE_KERNEL 0
#define PRIVILEGE_USER 3
/* interrupt vector */
#define INT_VECTOR_DIVIDE 0x0
#define INT_VECTOR_DEBUG 0x1
#define INT_VECTOR_NMI 0x2
#define INT_VECTOR_BREAKPOINT 0x3
#define INT_VECTOR_OVERFLOW 0x4
#define INT_VECTOR_BOUNDS 0x5
#define INT_VECTOR_INVAL_OP 0x6
#define INT_VECTOR_COPROC_NOT 0x7
#define INT_VECTOR_DOUBLE_FAULT 0x8
#define INT_VECTOR_COPROC_SEG 0x9
#define INT_VECTOR_INVAL_TSS 0xa
#define INT_VECTOR_SEG_NOT 0xb
#define INT_VECTOR_STACK_FAULT 0xc
#define INT_VECTOR_PROTECTION 0xd
#define INT_VECTOR_PAGE_FAULT 0xe
#define INT_VECTOR_COPROC_ERR 0x10

#define INT_VECTOR_IRQ0 0x20
#define INT_VECTOR_IRQ8 0x28

#endif	/* __OSCRATCH_PROTECT_H */
