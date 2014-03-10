#################################
# Makefile for My Oprate System #
#################################

# Programs
ASM			= nasm
DASM		= ndisasm
#FLAGS
ASMFLAGS	= -I Include/ -o
BOOTDASMFLAGS	= -o 0x7c00 -s 0x7c3e

# Targets
BOOT		= boot.bin
LOAD		= load.bin
KERNEL		= kernel.bin
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
	rm -f $(BOOT) $(LOAD) $(IMGNAME) $(DASMOUT) $(KERNEL)

$(BOOT): boot.asm
	$(ASM) $(ASMFLAGS) $@ $<

$(LOAD): load.asm
	$(ASM) $(ASMFLAGS) $@ $<

$(KERNEL): kernel.asm
	$(ASM) $(ASMFLAGS) $@ $<
