#
# Makefile for ghdl simulation
#

# Programs
GHDL = ghdl
PERL = perl

# Directories
SRCDIR = ../../../rtl/vhdl
TBDIR  = ../../../bench/vhdl
SIMDIR = ../bin
LOGDIR = ../log

# UART16750 sources
SRC =  slib_clock_div.vhd
SRC += slib_counter.vhd
SRC += slib_edge_detect.vhd
SRC += slib_fifo.vhd
SRC += slib_input_filter.vhd
SRC += slib_input_sync.vhd
SRC += slib_mv_filter.vhd
SRC += uart_baudgen.vhd
SRC += uart_interrupt.vhd
SRC += uart_receiver.vhd
SRC += uart_transmitter.vhd
SRC += uart_16750.vhd

# Testbench source
TBSRC =  txt_util.vhd
TBSRC += uart_package.vhd
TBSRC += uart_transactor.vhd

# Testbench stimuli and log
TBSTIMGEN = $(SIMDIR)/uart_test_stim.pl
TBSTIMDAT = uart_stim.dat
TBLOG     = $(LOGDIR)/uart_log.txt
TBVCD     = $(LOGDIR)/uart_log.vcd

# Simulation entity and options
SIMPROG = uart_transactor
SIMOPTS = --stop-time=160ms

all: $(SIMPROG)

$(TBSTIMDAT): $(TBSTIMGEN)
			  $(PERL) $^ > $@

$(SIMPROG): $(addprefix $(SRCDIR)/,$(SRC)) $(addprefix $(TBDIR)/,$(TBSRC))
			$(GHDL) -a $^
			$(GHDL) -e $@

sim: 		$(SIMPROG) $(TBSTIMDAT)
			$(GHDL) -r $(SIMPROG) $(SIMOPTS)
			cp uart_log.txt $(TBLOG)

vcd: 		$(SIMPROG) $(TBSTIMDAT)
			$(GHDL) -r $(SIMPROG) $(SIMOPTS) --vcd=$(TBVCD)

clean:
			$(GHDL) --clean
			rm -f $(TBSTIMDAT) $(TBVCD)

.PHONY: 	clean sim vcd
