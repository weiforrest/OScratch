#include <proto.h>
void disp_int(int input)
{
	 char output[16];
	 output[0] = '0';
	 output[1] = 'x';
	 itoa(&output[2], input);
	 disp_str(output);
}
