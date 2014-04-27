#ifndef __OSCRATCH_CONST_H_
#define __OSCRATCH_CONST_H_


#define GDT_SIZE 128
#define IDT_SIZE 256
/* 8259a interrupt controller ports */
#define INT_M_CTL 0x20
#define INT_S_CTL 0xa0
#define INT_M_CTLMASK 0x21
#define INT_S_CTLMASK 0xa1

/* EXTERN is defined as extern except global.c */
#define EXTERN extern

#define SELECTOR_KERNEL_CS 32
#endif /*__OSCRATCH_CONST_H_*/
