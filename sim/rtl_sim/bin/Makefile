
all:	sim
SHELL = /bin/sh
#MS=-s

##########################################################################
#
# DUT Sources
#
##########################################################################
DUT_SRC_DIR=../../../rtl/verilog
_TARGETS_=	$(DUT_SRC_DIR)/generic_fifo_sc_a.v				\
		$(DUT_SRC_DIR)/generic_fifo_sc_b.v				\
		$(DUT_SRC_DIR)/generic_fifo_dc.v				\
		../../../../generic_memories/rtl/verilog/generic_dpram.v


##########################################################################
#
# Test Bench Sources
#
##########################################################################
_TOP_=test
TB_SRC_DIR=../../../bench/verilog
_TB_=		$(TB_SRC_DIR)/test_bench_top.v


##########################################################################
#
# Misc Variables
#
##########################################################################

INCDIR=+incdir+./$(DUT_SRC_DIR)/ +incdir+./$(TB_SRC_DIR)/
LOGF=-l .nclog

##########################################################################
#
# Make Targets
#
##########################################################################

ss:
	signalscan -do waves/waves.do -waves waves/waves.trn &

simw:
	$(MAKE) $(MS) sim ACCESS="+access+r " WAVES="+define+WAVES"

sim:
	ncverilog -q +define+RUDIS_TB $(_TARGETS_) $(_TB_)      \
		$(INCDIR) $(WAVES) $(ACCESS) $(LOGF) +ncstatus  \
		+ncuid+`hostname`

gatew:
	@$(MAKE) -s gate ACCESS="+access+r" WAVES="+define+WAVES"

gate:
	ncverilog -q +define+RUDIS_TB $(_TB_) $(UMC_LIB)        \
		$(GATE_NETLIST) $(INCDIR) $(WAVES) $(ACCESS)    \
		$(LOGF) +ncstatus +ncuid+`hostname`

clean:
	rm -rf	./waves/*.dsn ./waves/*.trn		\
		INCA_libs				\
		./verilog.* .nclog hal.log

##########################################################################
