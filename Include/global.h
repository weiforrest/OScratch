#ifndef __OSCRATCH_GLOBAL_H_
#define __OSCRATCH_GLOBAL_H_
#include <const.h>
#include <types.h>
#include <protect.h>
#include <task.h>


#ifdef GLOBAL_VARIABLES_HERE
#undef EXTERN
#define EXTERN
#endif

EXTERN int disp_pos;
EXTERN u8 gdt_ptr[6];
EXTERN DESCRIPTOR gdt[GDT_SIZE];
EXTERN u8 idt_ptr[6];
EXTERN GATE idt[IDT_SIZE];
EXTERN TSS tss;					/* global tss for all process */
EXTERN int enable_gdt_entry;			/* record the aviliable gdt entry */
EXTERN PROC * p_proc_ready;
EXTERN PROC proc_table[PROC_SIZE];
#endif	/* __OSCRATCH_GLOBAL_H_ */
