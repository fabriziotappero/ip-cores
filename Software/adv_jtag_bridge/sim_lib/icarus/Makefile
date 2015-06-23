
SRCDIR=../src/



default: vpi

# This is for the Icarus simulator.
jp-io-vpi.vpi: $(SRCDIR)jp-io-vpi.c
	iverilog-vpi $(SRCDIR)jp-io-vpi.c

vpi: jp-io-vpi.vpi Makefile