/* syscall.h    (c) weiforrest */
/* define all syscall routine */

#ifndef __OSCRATCH_SYSCALL_H_
#define __OSCRATCH_SYSCALL_H_
#include <task.h>
void sys_get_ticks();
int sys_write(char *buf, PROC * p_proc);

#endif /* __OSCRATCH_SYSCALL_H_ */

