#include <proto.h>
#include <userlib.h>

void print();
void print_int(int input)
{
	 char output[16];
	 output[0] = '0';
	 output[1] = 'x';

	 itoa(&output[2], input);
	 print(output);
}
