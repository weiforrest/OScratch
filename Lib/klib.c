/* klib.c    (c) weiforrest */
/* kernel function libaray */
#include <proto.h>

void disp_int(int input)
{
	 char output[16];
	 output[0] = '0';
	 output[1] = 'x';
	 itoa(&output[2], input);
	 disp_str(output);
}

void delay(int time)
{
	 int i, j, k;
	 for(i = 0; i<time ; i++){
		  for(j = 0; j< 100; j++){
			   for(k = 0; k< 100; k++){}
		  }
	 }
}
