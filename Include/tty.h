/* tty.h    (c) weiforrest*/
#ifndef __OSCRATCH_TTY_H_
#define __OSCRATCH_TTY_H_

#include <types.h>
#include <console.h>

#define TTY_BUF_SIZE 256

typedef struct {
	 u32 in_buf[TTY_BUF_SIZE];
	 u32 * p_inbuf_head;
	 u32 * p_inbuf_tail;
	 int inbuf_count;
	 CONSOLE * p_console; 		/* 当前tty使用的控制台*/
}TTY;


#endif /*  __OSCRATCH_TTY_H_ */
