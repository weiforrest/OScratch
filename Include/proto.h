/* proto.h save the proto which function write by asm */
#ifndef __OSCRATCH_PROTO_H
#define __OSCRATCH_PROTO_H

void disp_color_str(char *, int);
#define disp_str(str) disp_color_str(str, 0xf)

void init_8259();
void *memcpy(void *, void *, int);
char * itoa(char *, int);


#endif	/* __OSCRATCH_PROTO_H */
