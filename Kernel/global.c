/* global.c    (c) weiforrest */
/* global.c use to define the global variables */
#define GLOBAL_VARIABLES_HERE
#include <const.h>
#include <types.h>
#include <protect.h>
#include <global.h>
#include <syscall.h>
void keyboard_read();
int_handler sys_call_table[SYS_CALL_SIZE]={
	 0,
	 sys_get_ticks,
	 sys_write
};
