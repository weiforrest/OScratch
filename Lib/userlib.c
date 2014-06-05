#include <types.h>
#include <proto.h>
#include <userlib.h>

int printf(const char * fmt, ...)
{
	 char buf[256];
	 va_list args = (va_list)((char *)(&fmt) + 4);
	 int i = vsprintf(buf, fmt, args);
	 write(buf);
	 return i;
}
