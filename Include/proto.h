/* proto.h save the proto which function write by asm */
#ifndef __OSCRATCH_PROTO_H_
#define __OSCRATCH_PROTO_H_

#include <types.h>

int vsprintf(char *buf, const char * fmt, va_list);
int printk(const char *fmt, ...);

void init_8259();
void *memcpy(void *, void *, u32);
void *memset(void *, u8, u32);
char * itoa(char *, int);
char *strcpy(char *, char *);

int strlen(char *);

void task0();
void task1();

void enable_hwirq(int irq);
int disable_hwirq(int irq);

void delay(int time);


void hlt();
#endif	/* __OSCRATCH_PROTO_H_ */
