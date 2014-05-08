/* task.h    (c) weiforrest */
#ifndef __OSCRATCH_TASK_H_
#define __OSCRATCH_TASK_H_

#include <const.h>
#include <protect.h>

struct proc_struct{
	 REGS regs;
	 u32 ldt_sel;				/* 68 */
	 DESCRIPTOR ldt[3];			/* 72 */
	 u32 state; 						
	 u32 privilege;
	 u32 counter;
	 u32 pid;
	 u8 name[16];
};

typedef union{
	 struct proc_struct proc;
	 char stack[PAGE_SIZE];
}PROC;



#endif	/* __OSCRATCH_TASK_H_ */
