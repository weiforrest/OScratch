/* task.h    (c) weiforrest */
#ifndef __OSCRATCH_TASK_H_
#define __OSCRATCH_TASK_H_

#include <protect.h>

typedef struct{
u32 state; 						
u32 privilege;
u32 counter;
u32 pid;
DESCRIPTOR ldt[3];
TSS tss;
}TASK;



#endif	/* __OSCRATCH_TASK_H_ */
