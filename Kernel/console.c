/* console.c    (c) weiforrest */
#include <const.h>
#include <types.h>
#include <protect.h>
#include <proto.h>
#include <console.h>


void setup_console()
{
	 /* 将屏幕上移15行 */
	 OUT_BYTE(CRTC_ADDR_REG, START_ADDR_H);
	 OUT_BYTE(CRTC_DATA_REG, ((80 * 15) >> 8) & 0xff);
	 OUT_BYTE(CRTC_ADDR_REG, START_ADDR_L);
	 OUT_BYTE(CRTC_DATA_REG, (80 * 15) & 0xff);
}

/* TODO:暂时这样处理  现在还没有tty,先直接打印出来*/
void in_process(u32 key)
{
	 char output[2] ={ 0, 0};
	 if(!(key & 0x100)){
		  output[0] = key & 0xff;
		  disp_str(output);
	 }
}
