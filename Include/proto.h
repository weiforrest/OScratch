/* proto.h save the proto which function write by asm */
#ifndef __OSCRATCH_PROTO_H_
#define __OSCRATCH_PROTO_H_

#include <types.h>

void disp_color_str(char *, int);
#define disp_str(str) disp_color_str(str, 0xf)

void init_8259();
void *memcpy(void *, void *, u32);
void *memset(void *, u8, u32);
char * itoa(char *, int);

void disp_int(int);
void taska();
void taskb();
#endif	/* __OSCRATCH_PROTO_H_ */
