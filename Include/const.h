/* const.h    (c) weiforrest */
/* constant about OSCRATCH */
#ifndef __OSCRATCH_CONST_H_
#define __OSCRATCH_CONST_H_


/* EXTERN is defined as extern except global.c */
#define EXTERN extern

#define GDT_SIZE 128
#define IDT_SIZE 256

#define HWINT_SIZE 16
#define RESERVED_INT_SIZE 16
#define SYS_CALL_SIZE 16
/* THE FIRST aviliable GDT ENTRY */
#define FIRST_GDT_ENTRY 4

/* max proc size */
#define PROC_SIZE 64
#define PAGE_SIZE 4096
#define OFFSET_REGS_TOP 68

/* 8259a interrupt controller ports */
#define INT_M_CTL 0x20
#define INT_S_CTL 0xa0
#define INT_M_CTLMASK 0x21
#define INT_S_CTLMASK 0xa1
#define EOI 0x20

/* 8253 Timer defination */
#define TIMER_MODE 0x43
#define RATE_GENERATOR 0x34
#define COUNTER0 0x40
#define LATCH (1193180/100)

/* GDT selector */
#define SELECTOR_KERNEL_CS 0x8
#define SELECTOR_KERNEL_DS 0x10
#define SELECTOR_KERNEL_GS 0x18
#define SELECTOR_TSS 0x20
#define SELECTOR_FIRST_LDT 0x28

/* LDT selector */
#define SELECTOR_LDT_CS 0x7
#define SELECTOR_LDT_DS 0xf
#endif /*__OSCRATCH_CONST_H_*/
