#include <proto.h>
#include <userlib.h>

u32 print();
u32 print_int(int input)
{
	 char output[16];
	 output[0] = '0';
	 output[1] = 'x';

	 itoa(&output[2], input);
	 return print(output);
}
