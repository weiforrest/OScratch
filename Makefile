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
CFLAGS		= -c -m32 -nostdinc -I Include/ -fno-builtin -o
KLDFLAGS	= -m elf_i386 -s -Ttext $(ENTRYPOINT) -o
BOOTDASMFLAGS	= -o 0x7c00 -s 0x7c3e
KERNELDASMFLAGS = -u -o $(ENTRYPOINT) -e $(ENTRYOFFSET)

# Targets
BOOT		= Boot/boot.bin
LOAD		= Boot/load.bin
BOOT_OBJ	= $(BOOT) $(LOAD)
KERNEL		= kernel.bin
KERNEL_OBJ	= Kernel/kernel.o Kernel/start.o Lib/string.o Lib/klib.o
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
nop:
	@echo "why not \'make image' huh? :)"
# create all 
everything: $(BOOT) $(LOAD) $(KERNEL)

# create the final image
image:  everything bulidimg

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


Kernel/start.o:	Include/const.h Include/types.h Include/protect.h

Kernel/kernel.o: Kernel/kernel.asm
	$(ASM) $(KASMFLAGS) $@ $<

Lib/string.o: Lib/string.asm
	$(ASM) $(KASMFLAGS) $@ $<

Lib/klib.o: Lib/klib.asm
	$(ASM) $(KASMFLAGS) $@ $<
