#####################################################
# Makefile for My Oprate System  (c) 2014 weiforrest#
#####################################################

#constant
ENTRYPOINT	= 0x30400
ENTRYOFFSET = 0x400
# Programs
ASM			= nasm
DASM		= ndisasm
LD			= ld
CC			= gcc

#FLAGS
BASMFLAGS	= -I Boot/Include/ -o
KASMFLAGS	= -f elf -I Include/ -o 
CFLAGS		= -c -m32 -nostdinc -g -Wall -I Include/ -fno-builtin -fno-stack-protector -o 
KLDFLAGS	= -m elf_i386 -Ttext $(ENTRYPOINT) -o
BOOTDASMFLAGS	= -o 0x7c00 -s 0x7c3e
KERNELDASMFLAGS = -u -o $(ENTRYPOINT) -e $(ENTRYOFFSET)

# Targets
BOOT		= Boot/boot.bin
LOAD		= Boot/load.bin
BOOT_OBJ	= $(BOOT) $(LOAD)
KERNEL		= kernel.bin
KERNEL_STRIP= kernel.bin.stripped
LIB_OBJ = Lib/string.o Lib/klib.o Lib/kliba.o Lib/userliba.o
KERNEL_OBJ = Kernel/kernel.o Kernel/start.o Kernel/i8259a.o \
				Kernel/protect.o Kernel/global.o Kernel/interrupt.o \
				Kernel/task.o Kernel/sched.o $(LIB_OBJ)

IMGNAME		= a.img
TMPDIR		= /tmp/floppy
DASMOUT		= ndisasm.asm

.asm.o:
	$(ASM) $(KASMFLAGS) $@ $<

.c.o:
	$(CC) $(CFLAGS) $@ $<

# Phony Targets
.PHONY: everything image buildimg clean nop bootdisasm

# the default starting postion
# create the final image
image:  clean everything bulidimg

# create all 
everything: $(BOOT) $(LOAD) $(KERNEL)

# build image
bulidimg: 
	@rm -rf $(IMGNAME)
	@bximage -q -fd -size=1.44 $(IMGNAME) 
	@dd if=$(BOOT) of=$(IMGNAME) bs=512 count=1 conv=notrunc
	@test -d $(TMPDIR) || mkdir $(TMPDIR)
	@mount -o loop $(IMGNAME) $(TMPDIR)
	@cp $(LOAD) $(TMPDIR) -v
	@strip $(KERNEL) -o $(KERNEL_STRIP)
	@cp $(KERNEL_STRIP) $(TMPDIR)/$(KERNEL) -v
	@sleep 1
	@umount $(TMPDIR)

bootdisasm:
	@rm -rf $(DASMOUT)
	$(DASM) $(BOOTDASMFLAGS) $(BOOT) > $(DASMOUT)

kdisasm:
	@rm -rf $(DASMOUT)
	$(DASM) $(KERNELDASMFLAGS) $(KERNEL) > $(DASMOUT)

clean:
	rm -f $(BOOT) $(LOAD) $(IMGNAME) $(DASMOUT) $(KERNEL)\
		$(KERNEL_OBJ) $(KERNEL_STRIP)

$(BOOT_OBJ): %.bin: %.asm
	$(ASM) $(BASMFLAGS) $@ $<

$(KERNEL): $(KERNEL_OBJ) 
	$(LD) $(KLDFLAGS) $@ $^

# .c to .o
Kernel/start.o:	Include/const.h Include/types.h Include/proto.h \
		Include/protect.h Include/global.h

Kernel/i8259a.o: Include/const.h Include/types.h Include/proto.h \
		Include/protect.h Include/global.h

Kernel/protect.o: Include/const.h Include/types.h Include/proto.h \
			Include/protect.h Include/global.h

Kernel/global.o: Include/const.h Include/types.h Include/protect.h\
			Include/global.h

Kernel/task.o:	Include/const.h Include/types.h Include/proto.h\
			Include/protect.h

Kernel/sched.o: Include/const.h Include/proto.h Include/global.h

Lib/klib.o:  Include/proto.h


# .asm to .o
Kernel/kernel.o: Kernel/kernel.asm
	$(ASM) $(KASMFLAGS) $@ $<

Kernel/interrupt.o: Kernel/interrupt.asm
	$(ASM) $(KASMFLAGS) $@ $<

Lib/string.o: Lib/string.asm
	$(ASM) $(KASMFLAGS) $@ $<

Lib/userliba.o: Lib/userliba.asm
	$(ASM) $(KASMFLAGS) $@ $<

Lib/kliba.o: Lib/kliba.asm
	$(ASM) $(KASMFLAGS) $@ $<
