/* i8259a.c    (c) weiforrest */
/* operation about i8259a */
#include <const.h>
#include <types.h>
#include <interrupt.h>
#include <protect.h>
#include <proto.h>
#include <global.h>

void init_i8259a()
{
	 /* Master 8259 ICW1 */
	 OUT_BYTE(INT_M_CTL, 0x11);
	 /* Slave 8259 ICW1*/
	 OUT_BYTE(INT_S_CTL, 0x11);
	 /* Master 8259 ICW2 interrupt entry is INT_VECTOR_IRQ0*/
	 OUT_BYTE(INT_M_CTLMASK, INT_VECTOR_IRQ0);
	 /* Slave 8259 ICW2 interrupt entry is INT_VECTOR_IRQ8*/
	 OUT_BYTE(INT_S_CTLMASK, INT_VECTOR_IRQ8);
	 /* Master 8259 ICW3 IR2 set for Slave 8259*/
	 OUT_BYTE(INT_M_CTLMASK, 0x4);
	 /* Slave 8259 ICW3 */
	 OUT_BYTE(INT_S_CTLMASK, 0x2);
	 /* Master 8259 ICW4 */
	 OUT_BYTE(INT_M_CTLMASK, 0x1);
	 /* Slave 8259 ICW4 */
	 OUT_BYTE(INT_S_CTLMASK, 0x1);
	 /* Master 8259 OCW1 */
	 OUT_BYTE(INT_M_CTLMASK, 0xff); /* disable all hardware interrupt */
	 /* Slave 8259 OCW1 */
	 OUT_BYTE(INT_S_CTLMASK, 0xff);
	 int i;
	 for(i = 0; i < HWINT_SIZE ;i++){
		  hwirq_table[i] = spurious_irq;
	 }
}

void set_8259a_handler(int irq, int_handler handle)
{
	 disable_hwirq(irq);
	 hwirq_table[irq] = handle;
}
