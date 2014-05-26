/* keyboard.c    (c) weiforrest  */
/* contain all  keyboard routine */
#include <const.h>
#include <types.h>
#include <interrupt.h>
#include <protect.h>
#include <proto.h>
#include <keyboard.h>

static keybuffer kbuf;			/* 键盘缓冲区 */
static int code_with_E0;
/* control key state */
static int shift_l;
static int shift_r;
static int alt_l;
static int alt_r;
static int ctrl_l;
static int ctrl_r;
static int caps_lock;
static int num_lock;
static int scroll_lock;
static int column;

void do_keyboard_handler();
void setup_keyboard()
{
	 kbuf.count = 0;
	 kbuf.phead = kbuf.ptail = kbuf.buf;
	 shift_l = shift_r = 0;
	 alt_l = alt_r = 0;
	 ctrl_l = ctrl_r = 0;
	 /* 设置键盘中断处理,开启键盘中断 */
	 set_8259a_handler(NR_KEYBOARD, do_keyboard_handler);
	 enable_hwirq(NR_KEYBOARD);
}

void do_keyboard_handler()
{
	 u8 scan_byte = IN_BYTE(KB_READ_PORT);
	 if(kbuf.count < KB_IN_BYTES){ /* 如果缓冲区满了,则舍弃 */
		  *(kbuf.phead) = scan_byte;
		  kbuf.phead++;
		  if(kbuf.phead == kbuf.buf + KB_IN_BYTES){
			   kbuf.phead = kbuf.buf;
		  }
		  kbuf.count++;
	 }
	 /* disp_str("*"); */
}

static u8 get_byte_from_kbuf()
{
	 u8 byte;
	 while(kbuf.count <= 0){}
	 DISABLE_INT();
	 byte = *(kbuf.ptail);
	 kbuf.ptail++;
	 if(kbuf.ptail == kbuf.buf + KB_IN_BYTES){
		  kbuf.ptail = kbuf.buf;
	 }
	 kbuf.count--;
	 ENABLE_INT();
	 return byte;
}

/* 现在键盘的读取暂时由一个进程来完成,等相应的结构建立起来以后,会使用中断把 */
/* 键值放到对应的缓冲区中,由相应的经常读取 */
/* it just copy from the orange'Os, only for now i just need some keyboard */
/* function, i will rewrite it for late */
/* TODO: and i think i can do it grace enough */
void keyboard_read()
{
	 u8	scan_code;
	 char	output[2];
	 int	make;	/* 1: press;  0: break. */

	 u32	key = 0;
	 u32*	keyrow;	/* 指向 keymap[] 的某一行,便于处于大小写 */

	 if(kbuf.count > 0){
		  code_with_E0 = 0;

		  scan_code = get_byte_from_kbuf();

		  if (scan_code == 0xE1) {
			   int i;
			   u8 pausebrk_scode[] = {0xE1, 0x1D, 0x45,
									  0xE1, 0x9D, 0xC5};
			   int is_pausebreak = 1;
			   for(i=1;i<6;i++){
					if (get_byte_from_kbuf() != pausebrk_scode[i]) {
						 is_pausebreak = 0;
						 break;
					}
			   }
			   if (is_pausebreak) {
					key = PAUSEBREAK;
			   }
		  }
		  else if (scan_code == 0xE0) {
			   scan_code = get_byte_from_kbuf();

			   /* PrintScreen press */
			   if (scan_code == 0x2A) {
					if (get_byte_from_kbuf() == 0xE0) {
						 if (get_byte_from_kbuf() == 0x37) {
							  key = PRINTSCREEN;
							  make = 1;
						 }
					}
			   }
			   /* PrintScreen break */
			   if (scan_code == 0xB7) {
					if (get_byte_from_kbuf() == 0xE0) {
						 if (get_byte_from_kbuf() == 0xAA) {
							  key = PRINTSCREEN;
							  make = 0;
						 }
					}
			   }
			   /* 不是PrintScreen, 此时scan_code为0xE0紧跟的那个值. */
			   if (key == 0) {
					code_with_E0 = 1;
			   }
		  }
		  if ((key != PAUSEBREAK) && (key != PRINTSCREEN)) {

			   make = (scan_code & FLAG_BREAK ? 0 : 1);

			   /* 先定位到 keymap 中的行 */
			   keyrow = &keymap[(scan_code & 0x7F) * MAP_COLS];
			
			   column = 0;
			   if (shift_l || shift_r) {
					column = 1;
			   }
			   if (code_with_E0) {
					column = 2; 
					code_with_E0 = 0;
			   }
			
			   key = keyrow[column];
			
			   switch(key) {
			   case SHIFT_L:
					shift_l = make;
					break;
			   case SHIFT_R:
					shift_r = make;
					break;
			   case CTRL_L:
					ctrl_l = make;
					break;
			   case CTRL_R:
					ctrl_r = make;
					break;
			   case ALT_L:
					alt_l = make;
					break;
			   case ALT_R:
					alt_l = make;
					break;
			   default:
					break;
			   }

			   if (make) { /* 忽略 Break Code */
					key |= shift_l	? FLAG_SHIFT_L	: 0;
					key |= shift_r	? FLAG_SHIFT_R	: 0;
					key |= ctrl_l	? FLAG_CTRL_L	: 0;
					key |= ctrl_r	? FLAG_CTRL_R	: 0;
					key |= alt_l	? FLAG_ALT_L	: 0;
					key |= alt_r	? FLAG_ALT_R	: 0;
			
					in_process(key);
			   }
		  }
	 }
}
