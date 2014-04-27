#include <const.h>
#include <types.h>
#include <protect.h>
#include <proto.h>
#include <global.h>

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
	 /* setup the IDT */
	 u16 * p_idt_limit = (u16 *)idt_ptr;
	 u32 * p_idt_base = (u32 *)(&idt_ptr[2]);
	 *p_idt_limit = IDT_SIZE * sizeof(GATE) - 1;
	 *p_idt_base = (u32)&idt;
	 
	 init_idt();
	 
	 disp_str("-----\"cstart\" ends-----\n");
}
