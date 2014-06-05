/* console.h    (c) weiforrest */
#ifndef	__OSCRATCH_CONSOLE_H_
#define __OSCRATCH_CONSOLE_H_

#include <types.h>
#define CRTC_ADDR_REG 0x3d4
#define CRTC_DATA_REG 0x3d5
#define START_ADDR_H 0xc
#define START_ADDR_L 0xd
#define CURSOR_H 0xe
#define CURSOR_L 0xf
#define V_MEM_BASE 0xb8000
#define V_MEM_SIZE 0x8000		/* 32k */
#define V_MEM_LIMIT 0x800		/* 4k 每个控制台的大小 单位为word  */

/* 使用的都是相对于V_MEN_BASE的偏移,单位为word  */
typedef struct {
	 u32 current_start_addr;	/* 当前控制台显示的位置 */
	 u32 original_addr;			/* 当前控制台的开始的显存位置 */
	 u32 v_mem_limit;			/* 当前控制台的显存大小 */
	 u32 cursor_addr;				/* 当前控制台的光标位置 */
}CONSOLE;
	 
#endif	/* __OSCRATCH_CONSOLE_H_ */
