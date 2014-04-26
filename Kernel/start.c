#include <const.h>
#include <types.h>
#include <protect.h>

void* memcpy(void * pDest, void *pSrc, int iSize);
void disp_str(char *);
u8 gdt_ptr[6];
DESCRIPTOR gdt[GDT_SIZE];

void cstart()
{
	 memcpy(gdt, (void *)(*((u32 *)(&gdt_ptr[2]))), *((u16*)(gdt_ptr))+1);

	 u16 * p_gdt_limit = (u16 *)gdt_ptr;
	 u32 * p_gdt_base = (u32 *)(&gdt_ptr[2]);
	 
	 *p_gdt_base = (u32)&gdt;
	 *p_gdt_limit = GDT_SIZE * sizeof(DESCRIPTOR) - 1;

	 disp_str("\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
			  "-----\"cstart\" begins-----\n");
}
