#ifndef __OSCRATCH_TYPES_H_
#define __OSCRATCH_TYPES_H_

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;

typedef void (*int_handler) ();
typedef void (*reserved_int_handler)(u32, u32);
typedef char * va_list;

#endif	/* __OSCRATCH_TYPES_H_ */
