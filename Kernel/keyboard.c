/* keyboard.c    (c) weiforrest  */
/* contain all  keyboard routine */
#include <const.h>
#include <types.h>
#include <interrupt.h>
#include <protect.h>
#include <proto.h>
#include <keyboard.h>
#include <tty.h>
#include <global.h>
/* static keybuffer kbuf;			/\* 键盘缓冲区 *\/ */
/* static int code_with_E0; */
/* control key state */
static int control_statue;
static int  num_led;
static int caps_led;
static int scroll_led;
void do_keyboard_handler();
void select_console(int);
static void set_leds();
void setup_keyboard()
{
	 /* kbuf.count = 0; */
	 /* kbuf.phead = kbuf.ptail = kbuf.buf; */
	 /* 初始化键盘状态 */
	 control_statue = 0;
	 num_led = 0;
	 caps_led = 0;
	 scroll_led = 0;
	 set_leds();
	 /* 设置键盘中断处理,开启键盘中断 */
	 set_8259a_handler(NR_KEYBOARD, do_keyboard_handler);
	 enable_hwirq(NR_KEYBOARD);
}


/* 为了追求键盘中断的速度,将扫描码放到当前tty的缓冲区中,只处理特殊键 */
/* 普通的按键放在tty读取中处理 */
void tty_do_write(TTY *, u32);
void do_keyboard_handler()
{
	 u8 scan_byte = IN_BYTE(KB_READ_PORT);
	 u32 key;
	 if(scan_byte == 0xE0){		/* 处理0xE0 */
		  control_statue |= FLAG_0XE0;
		  return;
	 }
	 if((scan_byte & 0x7f) > 0x58){		/* 暂时忽略 */
		  return;
	 }
	 /* 处理控制键 */
	 switch(scan_byte & 0x7f){
	 case 0x1d:					/* control */
		  control_statue ^= FLAG_CONTROL;
		  break;
	 case 0x2a:					/* shift_l */
		  control_statue ^= FLAG_SHIFT_L;
		  break;
	 case 0x36:					/* shift_r */
		  control_statue ^= FLAG_SHIFT_R;
		  break;
	 case 0x38:					/* ALT */
		  control_statue ^= FLAG_ALT;
		  break;
	 case 0x3b:					/* F1-F3 控制台切换 */
	 case 0x3C:
	 case 0x3e:
		  /* if(control_statue & FLAG_ALT) */
		  select_console((scan_byte & 0x7f) - 0x3b);
		  return;
	 default:
		  key = scan_byte | control_statue;
		  control_statue &= (0xfffffeff);					/* 清除FLAG_0XE0 */
		  /* 忽略释放按键 */
		  if(!(scan_byte & FLAG_BREAK)){
			   /* 控制台和tty的偏移相同 */
			   tty_do_write(&tty_table[nr_current_console], key);
		  }
		  break;
	 }

}
static void kb_wait()
{
	 u8 kb_stat;
	 do{
		  kb_stat = IN_BYTE(KB_CMD);
	 }while(kb_stat & 0x02);
}

static void kb_ack()
{
	 u8 kb_read;
	 do{
		  kb_read = IN_BYTE(KB_DATA);
	 }while(kb_read != KB_ACK);
	 
}

static void set_leds()
{
	 u8 leds = (caps_led << 2) | (num_led << 1) | scroll_led;
	 kb_wait();
	 OUT_BYTE(KB_DATA, LED_CODE);
	 kb_ack();
	 kb_wait();
	 OUT_BYTE(KB_DATA, leds);
	 kb_ack();
}

void set_num_led(u32 statue)
{
	 num_led = statue;
	 set_leds();
}

void set_caps_led(u32 statue)
{
	 caps_led = statue;
	 set_leds();
}

void set_scroll_led(u32 statue)
{
	 scroll_led = statue;
	 set_leds();
}
	 
