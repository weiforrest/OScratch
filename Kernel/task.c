/* task.c    (c) weiforrest */
/* define some test task function*/
#include <const.h>
#include <types.h>
#include <protect.h>
#include <userlib.h>

void taska()
{
	 char *p = "A";
	 int i = 0x1000;
	 while(1){
		  print(p);
		  print_int(i++);
		  print(".");
		  delay(1);
		  /* (*p)++; */
	 }
}

void taskb()
{
	 char *p = "B";
	 int i = 0x2000;
	 while(1){
		  print(p);
		  print_int(i++);
		  print(".");
		  delay(1);
	 }
}
