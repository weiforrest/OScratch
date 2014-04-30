/* const.h    (c) weiforrest */
/* constant about OSCRATCH */
#ifndef __OSCRATCH_CONST_H_
#define __OSCRATCH_CONST_H_


/* EXTERN is defined as extern except global.c */
#define EXTERN extern


#define GDT_SIZE 128
#define IDT_SIZE 256

/* THE FIRST aviliable GDT ENTRY */
#define FIRST_GDT_ENTRY 4

/* max task size */
#define TASK_SIZE 64

/* 8259a interrupt controller ports */
#define INT_M_CTL 0x20
#define INT_S_CTL 0xa0
#define INT_M_CTLMASK 0x21
#define INT_S_CTLMASK 0xa1


#define SELECTOR_KERNEL_CS 0x8
#define SELECTOR_KERNEL_DS 0x10
#define SELECTOR_KERNEL_GS 0x18
#endif /*__OSCRATCH_CONST_H_*/
