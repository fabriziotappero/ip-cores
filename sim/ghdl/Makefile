#
# Makefile for building and running RTL simulation with GHDL.
#
# Simulation has been tested with GHDL 0.29.
# GHDL is available from http://ghdl.free.fr/
#

GHDL = ghdl
RTLDIR = ../../rtl/vhdl
TBDIR  = ../../bench/vhdl

.PHONY: default test_spwlink test_streamtest clean

default:
	@echo "Targets:"
	@echo "  make spwlink_tb        Build default spwlink testbench"
	@echo "  make spwlink_tb_all    Build spwlink mega testbench"
	@echo "  make test_spwlink      Run spwlink mega testbench"
	@echo "  make streamtest_tb     Build spwstream testbench"
	@echo "  make test_streamtest   Run spwstream testbench"
	@echo "  make clean             Remove build files"

SPWLINK_VHDL = $(RTLDIR)/spwpkg.vhd    \
               $(RTLDIR)/spwlink.vhd   \
               $(RTLDIR)/spwrecv.vhd   \
               $(RTLDIR)/spwxmit.vhd   \
               $(RTLDIR)/spwxmit_fast.vhd \
               $(RTLDIR)/spwrecvfront_generic.vhd \
               $(RTLDIR)/spwrecvfront_fast.vhd \
               $(RTLDIR)/syncdff.vhd \
               $(RTLDIR)/spwram.vhd

SPWSTREAM_VHDL = $(SPWLINK_VHDL) \
                 $(RTLDIR)/spwstream.vhd

spwlink_tb: $(TBDIR)/spwlink_tb.vhd $(SPWLINK_VHDL)
	$(GHDL) -c $^ -e spwlink_tb

spwlink_tb_all: $(TBDIR)/spwlink_tb_all.vhd $(TBDIR)/spwlink_tb.vhd $(SPWLINK_VHDL)
	$(GHDL) -c $^ -e spwlink_tb_all

test_spwlink: spwlink_tb_all
	$(GHDL) -r spwlink_tb_all --assert-level=error

streamtest_tb: $(TBDIR)/streamtest_tb.vhd $(RTLDIR)/streamtest.vhd $(SPWSTREAM_VHDL)
	$(GHDL) -c $^ -e streamtest_tb

test_streamtest: streamtest_tb
	$(GHDL) -r streamtest_tb --assert-level=error

clean:
	$(GHDL) --clean
	$(RM) e~spwlink_tb.o e~spwlink_tb_all.o e~streamtest_tb.o

