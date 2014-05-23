/* protect.h   (c) weiforrest */
/* defintion about interrupt  */
#ifndef __OSCRATCH_INTERRUPT_H_
#define __OSCRATCH_INTERRUPT_H_
#include <types.h>

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

#define INT_VECTOR_SYSCALL 0x80	/* same with linux */

#define NR_CLOCK 0
#define NR_KEYBOARD 1
void set_8259a_handler(int , int_handler);
#endif	/* __OSCRATCH_INTERRUPT_H_ */
