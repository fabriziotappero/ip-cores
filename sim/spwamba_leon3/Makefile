#
# Makefile for building SpaceWire AMBA testbench.
#


# Change this to your local GRLIB directory.
GRLIB = /data/leon3/grlib-gpl-1.2.2-b4123


RTLDIR = ../../rtl/vhdl
TBDIR  = ../../bench/vhdl
SWDIR  = ../../sw/spwamba_test

SWDEFS = -DTXCLKFREQ=40 -DDESCTABLESIZE=5 -DQUEUEFILL=700 -DLOOPBACKSWITCH=1

TOP = spwamba_tb
VHDLSIMFILES = \
  $(RTLDIR)/spwpkg.vhd      \
  $(RTLDIR)/spwlink.vhd     \
  $(RTLDIR)/spwrecv.vhd     \
  $(RTLDIR)/spwxmit.vhd     \
  $(RTLDIR)/spwxmit_fast.vhd \
  $(RTLDIR)/spwrecvfront_generic.vhd \
  $(RTLDIR)/spwrecvfront_fast.vhd \
  $(RTLDIR)/syncdff.vhd     \
  $(RTLDIR)/spwram.vhd      \
  $(RTLDIR)/spwambapkg.vhd  \
  $(RTLDIR)/spwamba.vhd     \
  $(RTLDIR)/spwahbmst.vhd   \
  $(TBDIR)/ahbram_loadfile.vhd \
  spwamba_tb.vhd

TECHLIBS = inferred
LIBSKIP = contrib cypress eth fmf gleichmann gsi hynix micron openchip opencores spansion spw
DIRSKIP = ata can ddr greth spacewire
FILESKIP = i2cmst.vhd i2cmst_gen.vhd ahbtrace_mb.vhd

include $(GRLIB)/bin/Makefile

all:
	@echo " specific information for SPWAMBA:"
	@echo
	@echo " make ghdl                 : compile test bench with GHDL"
	@echo " make spwamba_test.srec    : compile test software (requires sparc-elf-4.4.2)"
	@echo " make ghdl-launch          : run test software in test bench"
	@echo

spwamba_test.srec: spwamba_test.elf
	sparc-elf-objcopy -O srec $< $@

spwamba_test.elf: init_sys.o spwamba_test.o
	sparc-elf-gcc -msoft-float -s $^ -o $@

spwamba_test.o: $(SWDIR)/spwamba_test.c
	sparc-elf-gcc -msoft-float -Wall -Os -I$(SWDIR) $(SWDEFS) -c $<

init_sys.o: $(SWDIR)/init_sys.S
	sparc-elf-gcc -c $<

.PHONY: my-clean
clean: my-clean
my-clean:
	$(RM) spwamba_test.o init_sys.o spwamba_test.elf

