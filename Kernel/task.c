/* task.c    (c) weiforrest */
/* define some test task function*/
#include <const.h>
#include <types.h>
#include <protect.h>
#include <proto.h>

void taska()
{
	 while(1){
		  disp_str("A");
		  delay(10);
	 }
}

void taskb()
{
	 while(1){
		  disp_str("B");
		  delay(10);
	 }
}
