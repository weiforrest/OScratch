#################################
# Makefile for My Oprate System #
#################################

# Programs
ASM			= nasm

#FLAGS
ASMFLAGS	= -o

# Targets
BOOT		= boot.bin
IMGNAME		= a.img
# Phony Targets
.PHONY: everything image buildimg clean

# the default starting postion
nop:
	@echo "why not \'make image' huh? :)"
# create all 
everything: $(BOOT)

# create the final image
image:  everything buildimg

# build image
bulidimg: image
	rm -f $(IMGNAME)
	bximage -q -fd -size=1.44 $(IMGNAME) 
	dd if=boot.bin of=$(IMGNAME) bs=512 count=1 conv=notrunc

clean:
	rm -f $(BOOT)

boot.bin: boot.asm
	$(ASM) $(ASMFLAGS) $@ $<

