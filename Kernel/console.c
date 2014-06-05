/* console.c    (c) weiforrest */
/* console.c 掌管屏幕的输出 */
#include <const.h>
#include <types.h>
#include <protect.h>
#include <proto.h>
#include <console.h>
#include <global.h>


static int color;
/* TODO:展示给每个控制台分配独立的显存空间, 以后实现显存的共享, 添加显示缓冲区 */
void setup_console()
{
	 CONSOLE * p_console;
	 color = DEFAULT_COLOR;
	 u32 start_addr = 0;
	 u32 console_size = V_MEM_LIMIT;
	 for(p_console = console_table; p_console < console_table + CONSOLE_SIZE;
		 p_console++){
		  p_console->current_start_addr = start_addr;
		  p_console->original_addr = start_addr;
		  p_console->v_mem_limit = console_size;
		  p_console->cursor_addr = start_addr;
		  start_addr += console_size;
	 }
}

void set_cursor(u32 addr)
{
	 DISABLE_INT();
	 OUT_BYTE(CRTC_ADDR_REG, CURSOR_H);
	 OUT_BYTE(CRTC_DATA_REG,(addr >> 8) & 0xff);
	 OUT_BYTE(CRTC_ADDR_REG, CURSOR_L);
	 OUT_BYTE(CRTC_DATA_REG, addr & 0xff);
	 ENABLE_INT();
}

void set_screen(u32 addr)
{
	 OUT_BYTE(CRTC_ADDR_REG, START_ADDR_H);
	 OUT_BYTE(CRTC_DATA_REG, (addr >> 8) & 0xff);
	 OUT_BYTE(CRTC_ADDR_REG, START_ADDR_L);
	 OUT_BYTE(CRTC_DATA_REG, addr & 0xff);
}

int is_current_console(CONSOLE* p_con)
{
	 return (p_con == &console_table[nr_current_console]);
}

void clean_screen()
{
	 u32 start_addr = console_table[nr_current_console].current_start_addr;
	 memset((void*)start_addr, 0, V_MEM_LIMIT);
	 set_screen(start_addr);
	 set_cursor(start_addr);
}

void select_console(int num)
{
	 if(num >= 0 && num < CONSOLE_SIZE){
		  nr_current_console = num;
		  set_screen(console_table[num].current_start_addr);
		  set_cursor(console_table[num].cursor_addr);
	 }
}

void  console_print(CONSOLE * p_console,char * str)
{
	 char ch;
	 u8 * p_mem = (u8 *)(V_MEM_BASE + p_console->cursor_addr * 2);
	 while(ch = *str++){
		  switch(ch){
		  case '\n':
			   if(p_console->cursor_addr < p_console->original_addr +
				  p_console->v_mem_limit - SCREEN_WIDTH){
					/* 起始地址的设置始终是SCREEN_WIDTH的倍数 */
					p_console->cursor_addr = ((p_console->cursor_addr / SCREEN_WIDTH)\
											  + 1) * SCREEN_WIDTH;
			   }
			   /* TODO:暂时不处理卷屏幕 */
			   break;
		  case '\b':
			   if(p_console->cursor_addr > p_console->original_addr){
					p_console->cursor_addr--;
					*(p_mem - 2) = ' ';
					*(p_mem - 1) = DEFAULT_COLOR;
			   }
			   break;
		  default:
			   if(p_console->cursor_addr < p_console->original_addr +
				  p_console->v_mem_limit - 1){
					*p_mem++ = ch;
					*p_mem++ = color;
					p_console->cursor_addr++;
			   }
			   break;
		  }
	 }
	 
	 if(is_current_console(p_console)){
		  set_cursor(p_console->cursor_addr);
	 }
}

int sys_write(char *buf, PROC * p_proc)
{
	 console_print(&console_table[p_proc->proc.nr_tty], buf);
	 return 0;
}
