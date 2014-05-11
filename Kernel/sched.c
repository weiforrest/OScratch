/* sched.c    (c) weiforrest */
/* schedule for process */
#include <const.h>
#include <proto.h>
#include <global.h>


void clock_handler()
{
	 /* disp_str("#"); */
	 delay(1);
	 if(!--(p_proc_ready->proc.counter)){
		  p_proc_ready->proc.counter = 10;
		  p_proc_ready++;
		  if(p_proc_ready >= proc_table + 2){
			   p_proc_ready = proc_table;
		  }
	 }
}
