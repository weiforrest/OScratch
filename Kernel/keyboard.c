/* keyboard.c    (c) weiforrest  */
/* contain the keyboard handle */
#include <const.h>
#include <types.h>
#include <interrupt.h>
#include <proto.h>


void do_keyboard_handler();
void setup_keyboard()
{
	 set_8259a_handler(NR_KEYBOARD, do_keyboard_handler);
	 enable_hwirq(NR_KEYBOARD);
}

void do_keyboard_handler()
{
	 disp_str("K");
}
