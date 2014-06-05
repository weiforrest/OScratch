/* string.c     (c) weiforrest */
#include <proto.h>


int strlen(char *str)
{
	 char *p = str;
	 int len = 0;
	 while(*p++){
		  len++;
	 }
	 return len;
}


char * strcpy(char *dst, char *src)
{
	 char *p = dst;
	 while(*src){
		  *p++ = *src++;
	 }
	 *p = 0;
	 return dst;
}
