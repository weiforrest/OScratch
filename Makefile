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
KASMFLAGS	= -f elf -o 
CFLAGS		= -c -m32 -nostdinc -I Include/ -fno-builtin -fno-stack-protector -o 
KLDFLAGS	= -m elf_i386 -s -Ttext $(ENTRYPOINT) -o
BOOTDASMFLAGS	= -o 0x7c00 -s 0x7c3e
KERNELDASMFLAGS = -u -o $(ENTRYPOINT) -e $(ENTRYOFFSET)

# Targets
BOOT		= Boot/boot.bin
LOAD		= Boot/load.bin
BOOT_OBJ	= $(BOOT) $(LOAD)
KERNEL		= kernel.bin
KERNEL_OBJ	= Kernel/kernel.o Kernel/start.o Kernel/i8259a.o \
Lib/string.o Lib/klib.o Lib/kliba.o Kernel/protect.o Kernel/global.o \
Kernel/interrupt.o
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
image:  everything bulidimg

# create all 
everything: $(BOOT) $(LOAD) $(KERNEL)

# build image
bulidimg: 
	rm -rf $(IMGNAME)
	bximage -q -fd -size=1.44 $(IMGNAME) 
	dd if=$(BOOT) of=$(IMGNAME) bs=512 count=1 conv=notrunc
	@test -d $(TMPDIR) || mkdir $(TMPDIR)
	mount -o loop $(IMGNAME) $(TMPDIR)
	@cp $(LOAD) $(KERNEL) $(TMPDIR) -v
	@sleep 1
	umount $(TMPDIR)

bootdisasm:
	@rm -rf $(DASMOUT)
	$(DASM) $(BOOTDASMFLAGS) $(BOOT) > $(DASMOUT)
kdisasm:
	@rm -rf $(DASMOUT)
	$(DASM) $(KERNELDASMFLAGS) $(KERNEL) > $(DASMOUT)
clean:
	rm -f $(BOOT) $(LOAD) $(IMGNAME) $(DASMOUT) $(KERNEL) $(KERNEL_OBJ)

$(BOOT_OBJ): %.bin: %.asm
	$(ASM) $(BASMFLAGS) $@ $<

$(KERNEL): $(KERNEL_OBJ) 
	$(LD) $(KLDFLAGS) $@ $^


Kernel/start.o:	Include/const.h Include/types.h Include/proto.h \
		Include/protect.h Include/global.h

Kernel/i8259a.o: Include/const.h Include/types.h Include/proto.h \
		Include/protect.h Include/global.h

Kernel/protect.o: Include/const.h Include/types.h Include/proto.h \
			Include/protect.h Include/global.h

Kernel/global.o: Include/const.h Include/types.h Include/protect.h\
			Include/global.h

Kernel/kernel.o: Kernel/kernel.asm
	$(ASM) $(KASMFLAGS) $@ $<

Kernel/interrupt.o: Kernel/interrupt.asm
	$(ASM) $(KASMFLAGS) $@ $<

Lib/string.o: Lib/string.asm
	$(ASM) $(KASMFLAGS) $@ $<

Lib/klib.o:  Include/proto.h

Lib/kliba.o: Lib/kliba.asm
	$(ASM) $(KASMFLAGS) $@ $<
