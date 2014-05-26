/* protect.c    (c) weiforrest */
/* contain some protect mode routine */
#include <types.h>
#include <const.h>
#include <interrupt.h>
#include <protect.h>
#include <proto.h>
#include <global.h>


void spurious_irq(int irq)
{
	 disp_str("recvice irq: ");
	 disp_int(irq);
	 disp_str("\n");
}


void init_desc(DESCRIPTOR * desc, u32 base, u32 limit, u16 attr)
{
	 desc->limit_low = limit & 0xffff;
	 desc->base_low = base & 0xffff;
	 desc->base_mid = (base >> 16) & 0xff;
	 desc->attr = (attr & 0xf0ff) | ((limit >> 8) & 0x0f00);
	 desc->base_high = (base >> 24) & 0xff;
}

void init_gate(GATE * gate, u32 base, u16 selector, u8 dcount, u8 attr)
{
	 gate->offset_low = base & 0xffff;
	 gate->selector = selector;
	 gate->dcount_attr = (dcount & 0x1f) | ((attr << 8) & 0xff00);
	 gate->offset_high = (base >> 16) & 0xffff;
}

void init_tss()
{
	 memset(&tss, 0, sizeof(TSS));
	 tss.ss0 = SELECTOR_KERNEL_DS;
	 tss.esp0 = (u32)p_proc_ready + OFFSET_REGS_TOP; /* REGS in PROC info region */
	 tss.ldt = SELECTOR_FIRST_LDT;
	 tss.dtrap_iomap = 0x8000000;
}
