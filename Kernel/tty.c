/* tty.c    (c) weiforrest */
/* tty.c 掌管终端的输入 */
#include <const.h>
#include <types.h>
#include <tty.h>
#include <global.h>
#include <keymap.h>

void setup_console();
void init_tty(TTY *);
static int flag_caps;
static int flag_numlock;
static int flag_scroll;
void setup_tty()
{
	 flag_caps = 0;
	 flag_numlock = 0;
	 flag_scroll = 0;
	 TTY * p_tty;
	 setup_console();
	 for(p_tty = tty_table; p_tty < tty_table + TTY_SIZE; p_tty++){
		  init_tty(p_tty);
	 }
	 /* 将光标位置移至第一空行 */
	 console_table[0].cursor_addr = 12*80;
	 select_console(0);
}
void init_tty(TTY * p_tty)
{
	 p_tty->inbuf_count = 0;
	 p_tty->p_inbuf_head = p_tty->in_buf;
	 p_tty->p_inbuf_tail = p_tty->in_buf;
	 /* TODO: 将tty和console直接按偏移对应, 以后再完善 */
	 p_tty->p_console = console_table + (p_tty - tty_table);
}

/* 将键值写入tty的缓冲区 */
void tty_do_write(TTY * p_tty, u32 key)
{
	 if(p_tty->inbuf_count < TTY_BUF_SIZE){
		  *(p_tty->p_inbuf_head++) = key;
		  if(p_tty->p_inbuf_head == p_tty->in_buf + TTY_BUF_SIZE){
			   p_tty->p_inbuf_head = p_tty->in_buf;
		  }
		  p_tty->inbuf_count++;
	 }
	 char out[2]={0,0};
	 out[0] = keymap[(key & 0x7f) * MAP_COLS];
	 console_print(p_tty->p_console, out); /* 回显当前按键字符 */
	 
}

static u32 get_key_from_tty(TTY * p_tty)
{
	 /* TODO: 始终等待,在内核中,暂时还没有阻塞这个概念 */
	 while(p_tty->inbuf_count <= 0){}
	 u32 key = *(p_tty->p_inbuf_tail++);
	 if(p_tty->p_inbuf_tail == p_tty->in_buf + TTY_BUF_SIZE){
		  p_tty->p_inbuf_tail = p_tty->in_buf;
	 }
	 p_tty->inbuf_count--;
	 return key;
}
	 
/* 从tty缓冲区中读取按键, 普通按键的键盘映射处理在这里 */
void set_caps_led();
void set_num_led();

/* 从tty缓冲区中读取键值 */
u32 tty_do_read(TTY * p_tty)
{
	 u32 column;
	 u32 key;
	 u8 key_code;
	 u32 shift_state = 0;
repeat:
	 key = get_key_from_tty(p_tty);
	 key_code = key & 0x7f;
	 switch(key_code){			/* 处理键盘LED */
	 case 0x3A:
		  flag_caps = !flag_caps;
		  set_caps_led(flag_caps);
		  goto repeat;
	 case 0x45:
		  flag_numlock = !flag_numlock;
		  set_num_led(flag_numlock);
		  goto repeat;
	 case 0x46:
		  flag_scroll = !flag_scroll;
		  set_scroll_led(flag_scroll);
	 default:
		  break;
	 }
	 if(key & FLAG_0XE0){
		  column = COL_0XE0;
	 }else {
		  if(key_code > 0x45){ /* 处理小键盘 */
			   column = flag_numlock;
		  }else{				/* 处理大小写 */
			   shift_state = (key & (FLAG_SHIFT_L | FLAG_SHIFT_R) != 0);
			   column = shift_state ^ flag_caps;
		  }
	 }	
	 return keymap[(key_code * MAP_COLS) + column];
}
