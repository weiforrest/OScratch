#ifndef __OSCRATCH_GLOBAL_H_
#define __OSCRATCH_GLOBAL_H_

#ifdef GLOBAL_VARIABLES_HERE
#undef EXTERN
#define EXTERN
#endif

EXTERN int disp_pos;
EXTERN u8 gdt_ptr[6];
EXTERN DESCRIPTOR gdt[GDT_SIZE];
EXTERN u8 idt_ptr[6];
EXTERN GATE idt[IDT_SIZE];


#endif	/* __OSCRATCH_GLOBAL_H_ */
