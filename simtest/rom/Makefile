#
# Makefile for assembling different system ROMs
#

BUILD = ../../build

SFILES = $(wildcard *.s)
OBJFILES = $(patsubst %.s,%.o,$(SFILES))
BINFILES = $(patsubst %.s,%.bin,$(SFILES))

.PHONY:		all install clean
.PRECIOUS:	$(OBJFILES)

all:		$(BINFILES)

install:	$(BINFILES)
		mkdir -p $(BUILD)/simtest
		cp $(BINFILES) $(BUILD)/simtest

%.bin:		%.o
		$(BUILD)/bin/ld -h -rc 0xE0000000 -o $@ $<

%.o:		%.s
		$(BUILD)/bin/as -o $@ $<

clean:
		rm -f *~ *.bin *.o
