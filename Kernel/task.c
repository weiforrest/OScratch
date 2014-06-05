/* task.c    (c) weiforrest */
/* define some test task function*/
/* 这里定义了进程0和进程1, 相当于linux中的前两个进程 */
#include <const.h>
#include <types.h>
#include <protect.h>
#include <proto.h>
#include <userlib.h>

/* 相当于linux中的进程0 */
void task0()
{
	 while(1){
		  delay(1);
		  /* printf("A"); */
	 }
}
/* 相当于linux中的进程1 */
void task1()
{
	 while(1){
		  delay(1);
		  /* read_keyboard(); */
	 }
}
