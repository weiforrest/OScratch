#ifndef __OSCRATCH_PROTECT_H
#define __OSCRATCH_PROTECT_H

#include "types.h"

typedef struct{
	 u16 limit_low;
	 u16 base_low;
	 u8 base_mid;
	 u8 attr;
	 u8 limit_high_attr;
	 u8 base_hith;
}DESCRIPTOR;

#endif	/* __OSCRATCH_PROTECT_H */
