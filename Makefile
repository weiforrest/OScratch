#####################################################
# Makefile for My Oprate System  (c) 2014 weiforrest#
#####################################################

# Programs
ASM			= nasm
DASM		= ndisasm
LD			= ld
#FLAGS
ASMFLAGS	= -I Include/ -o
KASMFLAGS	= -f elf -o
BOOTDASMFLAGS	= -o 0x7c00 -s 0x7c3e
KLDFLAGS	= -m elf_i386 -s -Ttext 0x30400 -o
# Targets
BOOT		= boot.bin
LOAD		= load.bin
KERNEL		= kernel.bin
KERNEL_OBJ	= kernel.o
IMGNAME		= a.img
TMPDIR		= /tmp/floppy
DASMOUT		= ndisasm.asm
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
	$(DASM) $(BOOTDASMFLAGS) $(BOOT) >> $(DASMOUT)
clean:
	rm -f $(BOOT) $(LOAD) $(IMGNAME) $(DASMOUT) $(KERNEL) $(KERNEL_OBJ)

$(BOOT): boot.asm
	$(ASM) $(ASMFLAGS) $@ $<

$(LOAD): load.asm
	$(ASM) $(ASMFLAGS) $@ $<

$(KERNEL): $(KERNEL_OBJ)
	$(LD) $(KLDFLAGS) $@ $<

$(KERNEL_OBJ):kernel.asm
	$(ASM) $(KASMFLAGS) $@ $<
