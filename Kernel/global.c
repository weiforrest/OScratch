/* global.c    (c) weiforrest */
/* use to define the global variables */
#define GLOBAL_VARIABLES_HERE
#include <const.h>
#include <types.h>
#include <protect.h>
#include <global.h>
#include <syscall.h>
void * sys_call_table[SYS_CALL_SIZE]={
	 0,
	 sys_get_ticks,
	 sys_disp
};
