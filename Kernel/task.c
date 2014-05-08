/* task.c    (c) weiforrest */
/* define some test task function*/
#include <const.h>
#include <types.h>
#include <protect.h>
#include <userlib.h>

void taska()
{
	 char *p = "A";
	 while(1){
		  print(p);
		  delay(10);
		  /* (*p)++; */
	 }
}

void taskb()
{
	 char *p = "B";
	 while(1){
		  print(p);
		  delay(10);
	 }
}
