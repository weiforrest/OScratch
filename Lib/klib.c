/* klib.c    (c) weiforrest */
/* kernel function libaray */
#include <proto.h>

void delay(int time)
{
	 int i, j, k;
	 for(i = 0; i<time ; i++){
		  for(j = 0; j< 100; j++){
			   for(k = 0; k< 100; k++){}
		  }
	 }
}

