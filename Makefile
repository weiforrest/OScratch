#################################
# Makefile for My Oprate System #
#################################

# Programs
ASM			= nasm
DASM		= ndisasm
#FLAGS
ASMFLAGS	= -I Include/ -o
DASMFLAGS	= -o 0x7c00 -s 0x7c3e

# Targets
BOOT		= boot.bin
LOAD		= load.bin
IMGNAME		= a.img
TMPDIR		= /tmp/floppy
DASMOUT		= ndisasm.asm
# Phony Targets
.PHONY: everything image buildimg clean nop disasm

# the default starting postion
nop:
	@echo "why not \'make image' huh? :)"
# create all 
everything: $(BOOT) $(LOAD)

# create the final image
image:  everything bulidimg

# build image
bulidimg:
	rm -rf $(IMGNAME)
	bximage -q -fd -size=1.44 $(IMGNAME) 
	dd if=$(BOOT) of=$(IMGNAME) bs=512 count=1 conv=notrunc
	mount -o loop $(IMGNAME) $(TMPDIR)
	@cp $(LOAD) $(TMPDIR) -v
	@sleep 1
	umount $(TMPDIR)

disasm:
	rm -rf $(DASMOUT)
	$(DASM) $(DASMFLAGS) $(BOOT) >> $(DASMOUT)
clean:
	rm -f $(BOOT) $(LOAD) $(IMGNAME)

boot.bin: boot.asm
	$(ASM) $(ASMFLAGS) $@ $<

load.bin: load.asm
	$(ASM) $(ASMFLAGS) $@ $<

