/* protect.c    (c) weiforrest */
/* protect mode function */
#include <types.h>
#include <const.h>
#include <protect.h>
#include <proto.h>
#include <global.h>

void divide_error();
void single_step_exception();
void nmi();
void breakpoint_exception();
void overflow();
void bounds_check();
void inval_opcode();
void copr_not_available();
void double_fault();
void copr_seg_overrun();
void inval_tss();
void segment_not_present();
void stack_exception();
void general_protection();
void page_fault();
void copr_error();

void i8259aint00();
void i8259aint01();
void i8259aint02();
void i8259aint03();
void i8259aint04();
void i8259aint05();
void i8259aint06();
void i8259aint07();
void i8259aint08();
void i8259aint09();
void i8259aint10();
void i8259aint11();
void i8259aint12();
void i8259aint13();
void i8259aint14();
void i8259aint15();


void exception_handler(u32 vec_no, u32 err_code, int eip, int cs, int eflags)
{
	 char *err_msg[] = {"#DE Divide Error",
						"#DB RESERVED",
						"#NMI Interrupt",
						"#BP BreakPoint",
						"#OF Overflow",
						"#BR BOUND Range Exceeded",
						"#UD Invalid Opcode",
						"#NM Device Not Avialable",
						"#DF Double Fault",
						"#-- Coprocessor Segment Overrun",
						"#TS Invalid TSS",
						"#NP Segment Not Present",
						"#SS Stack-Segment Fault",
						"#GP General Protection",
						"#PF Page Fault",
						"#-- Intel Reserved",
						"#MF x87 FPU Floating Point Error",
						"#AC Alignment Check",
						"#MC Machine Check",
						"#XF SIMD Floating-Point Exception"
	 };
	 disp_pos = 0;
	 int i;
	 for(i = 0; i<80*5; i++){
		  disp_str(" ");
	 }
	 disp_pos = 0;
	 int text_color = 0x74;
	 disp_color_str("Exception! --> ", text_color);
	 disp_color_str(err_msg[vec_no], text_color);
	 disp_color_str("\n\n",text_color);
	 disp_color_str("EFLAGS:", text_color);
	 disp_int(eflags);
	 disp_color_str("CS:", text_color);
	 disp_int(cs);
	 disp_color_str("EIP", text_color);
	 disp_int(eip);

	 if(err_code != 0xffffffff){
		  disp_color_str("Error_Code:", text_color);
		  disp_int(err_code);
	 }
}

void i8259a_irq(int irq)
{
	 disp_str("recvice irq: ");
	 disp_int(irq);
	 disp_str("\n");
}

static void init_idt_desc(u8 vector, u8 desc_type,
						  int_handler handler, u8 privilege)
{
	 GATE * p_gate = &idt[vector];
	 u32 base = (u32) handler;
	 p_gate->offset_low = base & 0xffff;
	 p_gate->offset_high =  (base >> 16) & 0xffff;
	 p_gate->selector = SELECTOR_KERNEL_CS;
	 p_gate->dcount = 0;
	 p_gate->attr = desc_type | (privilege << 5);
}

void init_idt()
{
	 init_i8259a();

	 init_idt_desc(INT_VECTOR_DIVIDE, DA_386IGate,
				   divide_error, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_DEBUG, DA_386IGate,
				   single_step_exception, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_NMI, DA_386IGate,
				   nmi, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_BREAKPOINT, DA_386IGate,
				   breakpoint_exception, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_OVERFLOW, DA_386IGate,
				   overflow, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_BOUNDS, DA_386IGate,
				   bounds_check, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_INVAL_OP, DA_386IGate,
				   inval_opcode, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_COPROC_NOT, DA_386IGate,
				   copr_not_available, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_DOUBLE_FAULT, DA_386IGate,
				   double_fault, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_COPROC_SEG, DA_386IGate,
				   copr_seg_overrun, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_INVAL_TSS, DA_386IGate,
				   inval_tss, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_SEG_NOT, DA_386IGate,
				   segment_not_present, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_STACK_FAULT, DA_386IGate,
				   stack_exception, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_PROTECTION, DA_386IGate,
				   general_protection, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_PAGE_FAULT, DA_386IGate,
				   page_fault, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_COPROC_ERR, DA_386IGate,
				   copr_error, PRIVILEGE_KERNEL);
	 /* 8259a interrupt request handler */
	 init_idt_desc(INT_VECTOR_IRQ0, DA_386IGate,
				   i8259aint00, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_IRQ0 + 1, DA_386IGate,
				   i8259aint01, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_IRQ0 + 2, DA_386IGate,
				   i8259aint02, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_IRQ0 + 3, DA_386IGate,
				   i8259aint03, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_IRQ0 + 4, DA_386IGate,
				   i8259aint04, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_IRQ0 + 5, DA_386IGate,
				   i8259aint05, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_IRQ0 + 6, DA_386IGate,
				   i8259aint06, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_IRQ0 + 7, DA_386IGate,
				   i8259aint07, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_IRQ8, DA_386IGate,
				   i8259aint08, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_IRQ8 + 1, DA_386IGate,
				   i8259aint09, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_IRQ8 + 2, DA_386IGate,
				   i8259aint10, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_IRQ8 + 3, DA_386IGate,
				   i8259aint11, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_IRQ8 + 4, DA_386IGate,
				   i8259aint12, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_IRQ8 + 5, DA_386IGate,
				   i8259aint13, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_IRQ8 + 6, DA_386IGate,
				   i8259aint14, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_IRQ8 + 7 , DA_386IGate,
				   i8259aint15, PRIVILEGE_KERNEL);
}
