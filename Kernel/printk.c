/* printk.c    (c) weiforrest */

#include <types.h>
#include <proto.h>
#include <global.h>

int printk(const char * fmt,...)
{
	 char buf[1024];
	 va_list args = (va_list)((char *)(&fmt) + 4);
	 int i;
	 i = vsprintf(buf, fmt, args);
	 console_print(&console_table[1], buf);
	 return i;
}

