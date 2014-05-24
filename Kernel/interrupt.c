/* interrupt    (c) weiforrest */
/* contain all do_* function extern by interrput.asm  */
#include <const.h>
#include <types.h>
#include <interrupt.h>
#include <protect.h>
#include <proto.h>
#include <global.h>

/*  */
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

/* need for init_idt */
void clock_interrupt();
void keyboard_interrupt();
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
void systemcall();
void ignoreint();

void do_divide_error(u32 esp, u32 error);
void do_single_step_exception(u32 esp, u32 error);
void do_nmi(u32 esp, u32 error);
void do_breakpoint_exception(u32 esp, u32 error);
void do_overflow(u32 esp, u32 error);
void do_bounds_check(u32 esp, u32 error);
void do_inval_opcode(u32 esp, u32 error);
void do_copr_not_available(u32 esp, u32 error);
void do_double_fault(u32 esp, u32 error);
void do_copr_seg_overrun(u32 esp, u32 error);
void do_inval_tss(u32 esp, u32 error);
void do_segment_not_present(u32 esp, u32 error);
void do_stack_exception(u32 esp, u32 error);
void do_general_protection(u32 esp, u32 error);
void do_page_fault(u32 esp, u32 error);
void do_copr_error(u32 esp, u32 error);

reserved_int_handler reserved_int_table[RESERVED_INT_SIZE]={
	 do_divide_error,
	 do_single_step_exception,
	 do_nmi,
	 do_breakpoint_exception,
	 do_overflow,
	 do_bounds_check,
	 do_inval_opcode,
	 do_copr_not_available,
	 do_double_fault,
	 do_copr_seg_overrun,
	 do_inval_tss,
	 do_segment_not_present,
	 do_stack_exception,
	 do_general_protection,
	 do_page_fault,
	 do_copr_error,
};


/* TODO:这里模仿linux 的处理,但是相应的系统函数还没有建立起来,所以先使用现有的函数 */
/* 对于SS和ESP,只有在用户下发生才存在的,所以内核发生,这里的值是不存在的,同时 */
/* 因为同在内核中,因为没有对是否已经在内核栈中做判断,所以在压参数的时候*/
/* 踩栈的问题,会在不久修复 使用cs的值进行判断是否是内核中中断过来的*/
static void die(char *msg, u32 esp, u32 error)
{
	 u32 * pesp = (u32 *)esp + 12; /* piont to eip */
	 disp_pos = 0;
	 int i;
	 for(i=0;i<80*5;i++){
		  disp_str(" ");
	 }
	 disp_pos = 0;
	 disp_color_str(msg, 0x74);	/* 辉底红字 */
	 if(error){
		  disp_color_str(" ERRORCODE: ", 0x74);
		  disp_int(error & 0xffff);
	 }
	 disp_color_str(" CS:", 0x74);
	 disp_int(pesp[1]);
	 disp_color_str("EIP: ", 0x74);
	 disp_int(pesp[0]);
	 disp_color_str("EFLAGS: ", 0x74);
	 disp_int(pesp[2]);
	 if(pesp[1] != SELECTOR_KERNEL_CS ){
		  disp_color_str("SS: ", 0x74);
		  disp_int(pesp[4]);
		  disp_color_str("ESP: ", 0x74);
		  disp_int(pesp[3]);
	 }else{
		  disp_color_str("IN kernel occur", 0x74);
	 }
	 hlt();
}


void do_divide_error(u32 esp, u32 error)
{
	 die("Divide_error", esp, error);
}

void do_single_step_exception(u32 esp, u32 error)
{
	 die("Single_step_excetion", esp, error);
}

void do_nmi(u32 esp, u32 error)
{
	 die("nmi", esp, error);
}

void do_breakpoint_exception(u32 esp, u32 error)
{
	 die("breakpoint_exception", esp, error);
}

void do_overflow(u32 esp, u32 error)
{
	 die("overflow", esp, error);
}

void do_bounds_check(u32 esp, u32 error)
{
	 die("bounds_check", esp, error);
}

void do_inval_opcode(u32 esp, u32 error)
{
	 die("inval_opcode", esp, error);
}

void do_copr_not_available(u32 esp, u32 error)
{
	 die("copr_not_available", esp, error);
}

void do_double_fault(u32 esp, u32 error)
{
	 die("double_fault", esp, error);
}

void do_copr_seg_overrun(u32 esp, u32 error)
{
	 die("copr_seg_overrun", esp, error);
}

void do_inval_tss(u32 esp, u32 error)
{
	 die("inval_tss", esp, error);
}

void do_segment_not_present(u32 esp, u32 error)
{
	 die("segment_not_present", esp, error);
}

void do_stack_exception(u32 esp, u32 error)
{
	 die("stack_exception", esp, error);
}

void do_general_protection(u32 esp, u32 error)
{
	 die("general_protection", esp, error);
}

void do_page_fault(u32 esp, u32 error)
{
	 die("page_fault", esp, error);
}

void do_copr_error(u32 esp, u32 error)
{
	 die("copr_error", esp, error);
}

static void init_idt_desc(u8 vector, u8 desc_type,
						  int_handler handler, u8 privilege)
{
	 GATE * p_gate = &idt[vector];
	 u32 base = (u32) handler;
	 p_gate->offset_low = base & 0xffff;
	 p_gate->offset_high =  (base >> 16) & 0xffff;
	 p_gate->selector = SELECTOR_KERNEL_CS;
	 p_gate->dcount_attr = ((desc_type | (privilege << 5))<< 8) & 0xff00;
}
/* 全部使用中断门, 陷阱门处理时允许中断,因为进程信息保存在REGS中,当发生重入时*/
/* 将破坏掉整个REGS,难以调试 */
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
	 int i;
	 for(i = 0x10; i< 0x20;i++){
		  init_idt_desc(i, DA_386IGate,
						ignoreint, PRIVILEGE_KERNEL);
	 }
	 /* 8259a interrupt request handler */
	 init_idt_desc(INT_VECTOR_IRQ0, DA_386IGate,
				   clock_interrupt, PRIVILEGE_KERNEL);
	 init_idt_desc(INT_VECTOR_IRQ0 + 1, DA_386IGate,
				   keyboard_interrupt, PRIVILEGE_KERNEL);
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
	 for(i = 0x30; i< INT_VECTOR_SYSCALL; i++){
		  init_idt_desc(i, DA_386IGate,
						ignoreint, PRIVILEGE_KERNEL);
	 }
	 init_idt_desc(INT_VECTOR_SYSCALL, DA_386IGate,
				   systemcall, PRIVILEGE_USER);
	 for(i = INT_VECTOR_SYSCALL+1; i<IDT_SIZE ;i++){
		  init_idt_desc(i, DA_386IGate,
						ignoreint, PRIVILEGE_KERNEL);
	 }
}
