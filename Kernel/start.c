/* start.c    (c) weiforrest */
/* init the kernel environment */
#include <const.h>
#include <types.h>
#include <protect.h>
#include <proto.h>
#include <global.h>

void setup_task();
void cstart()
{
	 disp_str("\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
			  "-----\"cstart\" begins-----\n");
	 /* copy the GDT */
	 memcpy(gdt, (void *)(*((u32 *)(&gdt_ptr[2]))), *((u16*)(gdt_ptr))+1);
	 u16 * p_gdt_limit = (u16 *)gdt_ptr;
	 u32 * p_gdt_base = (u32 *)(&gdt_ptr[2]);
	 *p_gdt_base = (u32)&gdt;
	 *p_gdt_limit = GDT_SIZE * sizeof(DESCRIPTOR) - 1;
	 /* set the first aviliable gdt entry*/
	 enable_gdt_entry = FIRST_GDT_ENTRY;
	 /* setup the IDT */
	 u16 * p_idt_limit = (u16 *)idt_ptr;
	 u32 * p_idt_base = (u32 *)(&idt_ptr[2]);
	 *p_idt_limit = IDT_SIZE * sizeof(GATE) - 1;
	 *p_idt_base = (u32)&idt;
	 
	 init_idt();
	 setup_task();
	 disp_str("-----\"cstart\" ends-----\n");
}

void setup_task()
{
	 p_task_ready = task_table;
	 p_task_ready->task.pid = p_task_ready - task_table;
	 p_task_ready->task.privilege = 100;
	 p_task_ready->task.counter = 100;
	 p_task_ready->task.state = TASK_STATE_READY;
	 /* add task ldt and tss desc to gdt */
	 init_desc(&gdt[enable_gdt_entry++], (u32)&p_task_ready->task.ldt,
			   sizeof(DESCRIPTOR)*3 - 1, DA_LDT);
	 init_desc(&gdt[enable_gdt_entry++], (u32)&p_task_ready->task.tss,
			   sizeof(TSS) - 1, DA_386TSS);
	 /* init the ldt */
	 memcpy(&p_task_ready->task.ldt[0], &gdt[SELECTOR_KERNEL_CS >> 3], sizeof(DESCRIPTOR));
	 p_task_ready->task.ldt[0].attr = DA_C | PRIVILEGE_USER << 5 | DA_LIMIT_4K | DA_32 | (p_task_ready->task.ldt[0].attr & 0x0f00);
	 
	 memcpy(&p_task_ready->task.ldt[1], &gdt[SELECTOR_KERNEL_DS >> 3], sizeof(DESCRIPTOR));
	 p_task_ready->task.ldt[1].attr |= DA_DRW | PRIVILEGE_USER << 5 | DA_LIMIT_4K | DA_32 | (p_task_ready->task.ldt[1].attr & 0x0f00);

	 memcpy(&p_task_ready->task.ldt[2], &gdt[SELECTOR_KERNEL_GS >> 3], sizeof(DESCRIPTOR));
	 p_task_ready->task.ldt[2].attr |= DA_DRW | PRIVILEGE_USER << 5 | (p_task_ready->task.ldt[2].attr & 0x0f00);

	 p_task_ready->task.tss.ss0 = SELECTOR_KERNEL_DS;
	 p_task_ready->task.tss.esp0 = (u32)p_task_ready + PAGE_SIZE;
	 p_task_ready->task.tss.ldt = 0x20;
	 p_task_ready->task.tss.dtrap_iomap = 0x8000000;
	 
}



