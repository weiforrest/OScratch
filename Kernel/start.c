/* start.c    (c) weiforrest */
/* init the kernel environment */
#include <const.h>
#include <types.h>
#include <interrupt.h>
#include <protect.h>
#include <proto.h>
#include <global.h>

void setup_proc();
void setup_sched();
void setup_keyboard();
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
	 enable_gdt_entry = FIRST_GDT_ENTRY; /* NULL, CS, DS, GS */
	 /* setup the IDT_PTR ann idt */
	 u16 * p_idt_limit = (u16 *)idt_ptr;
	 u32 * p_idt_base = (u32 *)(&idt_ptr[2]);
	 *p_idt_limit = IDT_SIZE * sizeof(GATE) - 1;
	 *p_idt_base = (u32)&idt;
	 init_idt();
	 
	 /* setup the TSS descriptor int gdt */
	 init_desc(&gdt[enable_gdt_entry++], (u32)&tss,
			   sizeof(TSS) - 1, DA_386TSS);
	 p_proc_ready = proc_table;
	 setup_proc();
	 init_tss();
	 setup_sched();
	 setup_keyboard();
	 /* setup_console(); */
	 
	 disp_str("-----\"cstart\" ends-----\n");
}

void setup_proc()
{
	 memset(proc_table, 0, sizeof(PROC) * PROC_SIZE);
	 int i;
	 for(i = 0; i<2;i++){
		  p_proc_ready->proc.pid = p_proc_ready - proc_table;
		  p_proc_ready->proc.privilege = 100;
		  p_proc_ready->proc.counter = 10;
		  p_proc_ready->proc.state = PROC_STATE_READY;
		  p_proc_ready->proc.ldt_sel = (enable_gdt_entry << 3);
		  /* add proc ldt desc to gdt */
		  init_desc(&gdt[enable_gdt_entry++], (u32)&p_proc_ready->proc.ldt,
					sizeof(DESCRIPTOR)*3 - 1, DA_LDT);
		  /* init the ldt cs*/
		  memcpy(&p_proc_ready->proc.ldt[0], &gdt[SELECTOR_KERNEL_CS >> 3], sizeof(DESCRIPTOR));
		  p_proc_ready->proc.ldt[0].attr |= PRIVILEGE_USER << 5;
		  /* init the ldt ds */
		  memcpy(&p_proc_ready->proc.ldt[1], &gdt[SELECTOR_KERNEL_DS >> 3], sizeof(DESCRIPTOR));
		  p_proc_ready->proc.ldt[1].attr |= PRIVILEGE_USER << 5;
		  p_proc_ready->proc.regs.gs = SELECTOR_LDT_DS;
		  p_proc_ready->proc.regs.fs = SELECTOR_LDT_DS;
		  p_proc_ready->proc.regs.es = SELECTOR_LDT_DS;
		  p_proc_ready->proc.regs.ds = SELECTOR_LDT_DS;
		  if(!i){
			   p_proc_ready->proc.regs.eip = (u32)taska;
		  }else{
			   p_proc_ready->proc.regs.eip = (u32)taskb;
		  }
		  p_proc_ready->proc.regs.cs = SELECTOR_LDT_CS;
		  p_proc_ready->proc.regs.eflags = 0x202;
		  p_proc_ready->proc.regs.esp = (u32)p_proc_ready + PAGE_SIZE; /* task0 kernel stack */
		  p_proc_ready->proc.regs.ss = SELECTOR_LDT_DS;
		  p_proc_ready++;
	 }
	 p_proc_ready = proc_table + 1;
	 
}



