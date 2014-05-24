/* task.c    (c) weiforrest */
/* define some test task function*/
#include <const.h>
#include <types.h>
#include <protect.h>
#include <proto.h>
#include <userlib.h>

void taska()
{
	 char *p = "A";
	 while(1){
		  /* print(p); */
		  /* print("."); */
		  delay(1);
		  /* (*p)++; */
	 }
}

void taskb()
{
	 char *p = "B";
	 while(1){
		  /* print(p); */
		  /* print("."); */
		  delay(2);
		  read_keyboard();
	 }
}
