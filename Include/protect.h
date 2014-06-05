/* protect.h   (c) weiforrest */
/* defintion about protect mode  */
#ifndef __OSCRATCH_PROTECT_H_
#define __OSCRATCH_PROTECT_H_

#include <const.h>
#include <types.h>

#pragma pack (1)
typedef struct{
	 u16 limit_low;
	 u16 base_low;
	 u8 base_mid;
	 u16 attr;
	 u8 base_high;
}DESCRIPTOR;


typedef struct{
	 u16 offset_low;
	 u16 selector;
	 u16 dcount_attr;
	 u16 offset_high;
}GATE;
#pragma pack ()

typedef struct {
	 u32 task_link;
	 u32 esp0;
	 u32 ss0;
	 u32 esp1;
	 u32 ss1;
	 u32 esp2;
	 u32 ss2;
	 u32 gr3;
	 u32 eip;
	 u32 eflags;
	 u32 eax;					/* pushad begin */
	 u32 ecx;
	 u32 edx;
	 u32 ebx;
	 u32 esp;
	 u32 ebp;
	 u32 esi;
	 u32 edi;					/* pushad end */
	 u32 es;
	 u32 cs;
	 u32 ss;
	 u32 ds;
	 u32 fs;
	 u32 gs;
	 u32 ldt;
	 u32 dtrap_iomap;
}TSS;

typedef struct {
	 u32 gs;
	 u32 fs;
	 u32 es;
	 u32 ds;
	 u32 edi;
	 u32 esi;
	 u32 ebp;
	 u32 nouse_esp;
	 u32 ebx;
	 u32 edx;
	 u32 ecx;
	 u32 eax;
	 u32 eip;
	 u32 cs;
	 u32 eflags;
	 u32 esp;
	 u32 ss;
}REGS;

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
/* save current interrupt state */
#define ENABLE_INT()\
	 __asm__ volatile ("popf\n"\
					   ::)
#define DISABLE_INT()\
	 __asm__ volatile ("pushf\n"	\
					   "cli\n"		\
					   ::)



void spurious_irq(int);
void init_idt();
void init_desc(DESCRIPTOR * desc, u32 base, u32 limit, u16 attr);
void init_gate(GATE * gate, u32 base, u16 selector, u8 dcount, u8 attr);
void init_i8259a();
void init_tss();
/************************/
/* descriptor attribute */
/************************/

#define DA_32 0x4000
#define DA_LIMIT_4K 0x8000
/* descriptor request privilege level */
#define DA_DPL0 0x00
#define DA_DPL1 0x20
#define DA_DPL2 0x40
#define DA_DPL3 0x60

/* date segment attribute */
#define DA_DR 0x90
#define DA_DRW 0x92
#define DA_DRWA 0x93
#define DA_C 0x98
#define DA_CR 0x9A
#define DA_CCO 0x9C
#define DA_CCOR 0x9E
/* system segment attribute */
#define DA_LDT		0x82
#define DA_TaskGate 0x85
#define DA_386TSS	0x89
#define DA_386CGate 0x8C
#define DA_386IGate 0x8E
#define DA_386TGate 0x8F

/* privilege level */
#define PRIVILEGE_KERNEL 0
#define PRIVILEGE_USER 3

/* selector attribute */
#define SA_RPL0 0
#define SA_RPL1 1
#define SA_RPL2 2
#define SA_RPL3 3
#define SA_TIL 4


/* task state */
#define PROC_STATE_READY 1
#define PROC_STATE_SLEEP 2
#define PROC_STATE_WAIT 3
#endif	/* __OSCRATCH_PROTECT_H_ */
