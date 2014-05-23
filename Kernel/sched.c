/* sched.c    (c) weiforrest */
/* schedule for process */
#include <const.h>
#include <types.h>
#include <interrupt.h>
#include <global.h>
#include <proto.h>
#include <protect.h>

void do_clock_handler();
void setup_sched()
{
	 /* Set the clock interrput time level */
	 /* 设置时钟中断的触发时间为10ms */
	 /* use mode 2 (rate generator ) for 8253 counter  */
	 OUT_BYTE(TIMER_MODE, RATE_GENERATOR);
	 OUT_BYTE(COUNTER0, (u8)LATCH);
	 OUT_BYTE(COUNTER0, (u8)(LATCH >> 8));
	 ticks = 0;
	 set_8259a_handler(NR_CLOCK, do_clock_handler);
	 enable_hwirq(NR_CLOCK);
}

void do_clock_handler()
{
	 /* disp_str("#"); */
	 ticks++;
	 if(!--(p_proc_ready->proc.counter)){
		  p_proc_ready->proc.counter = 10;
		  p_proc_ready++;
		  if(p_proc_ready >= proc_table + 2){
			   p_proc_ready = proc_table;
		  }
	 }
}
