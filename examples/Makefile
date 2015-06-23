#
# RISE- Makefile
#
# Copyright (c) 2006 Christian Walter, Vienna 2006.
#
# $Id: Makefile,v 1.2 2007-01-25 21:20:06 cwalter Exp $
#
# ---------------------------------------------------------------------------

BASE        = /opt/gcc-rise/bin
AS	        = $(BASE)/rise-as
OBJCOPY	    = $(BASE)/rise-objcopy
LD	        = $(BASE)/rise-ld
BIN2VHD     = bin2vhd

ASFLAGS     =
LDSCRIPT    = m5235-ram.ld
LDFLAGS	    = 

TGT         = demo
ASRC        = subroutine.s
OBJS        = $(ASRC:.s=.o)
BIN         = $(TGT).elf $(TGT).bin $(TGT).vhd

.PHONY: clean all

all: $(BIN)

$(TGT).elf: $(OBJS) 
	$(LD) -o $(TGT).elf $(OBJS)

clean:
	rm -f $(OBJS)
	rm -f $(BIN) 

# ---------------------------------------------------------------------------
# rules for code generation
# ---------------------------------------------------------------------------

%.o:    %.s
	$(AS) $(ASFLAGS) -o $@ $<

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@
#	$(OBJCOPY) -j .text -O binary $< $@

%.vhd: %.bin
	$(BIN2VHD) $< $@
