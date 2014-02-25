#################################
# Makefile for My Oprate System #
#################################

# Programs
ASM			= nasm

#FLAGS
ASMFLAGS	= -I Include/ -o

# Targets
BOOT		= boot.bin
LOAD		= load.bin
IMGNAME		= a.img
# Phony Targets
.PHONY: everything image buildimg clean nop

# the default starting postion
nop:
	@echo "why not \'make image' huh? :)"
# create all 
everything: $(BOOT) $(LOAD)

# create the final image
image:  everything buildimg

# build image
bulidimg:
	rm -rf $(IMGNAME)
	bximage -q -fd -size=1.44 $(IMGNAME) 
	dd if=$(BOOT) of=$(IMGNAME) bs=512 count=1 conv=notrunc

clean:
	rm -f $(BOOT) $(LOAD)

boot.bin: boot.asm
	$(ASM) $(ASMFLAGS) $@ $<

load.bin: load.asm
	$(ASM) $(ASMFLAGS) $@ $<

