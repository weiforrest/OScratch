/* task.h    (c) weiforrest */
#ifndef __OSCRATCH_TASK_H_
#define __OSCRATCH_TASK_H_

#include <const.h>
#include <protect.h>

struct task_struct{
u32 state; 						
u32 privilege;
u32 counter;
u32 pid;
DESCRIPTOR ldt[3];
TSS tss;
};

typedef union{
	 struct task_struct task;
	 char stack[PAGE_SIZE];
}TASK;



#endif	/* __OSCRATCH_TASK_H_ */
