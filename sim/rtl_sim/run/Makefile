
all:	sim
SHELL = /bin/sh
#MS=-s

##########################################################################
#
# DUT Sources
#
##########################################################################
DUT_SRC_DIR=../../../rtl/verilog
PHY_SRC_DIR=../../../../usb_phy/rtl/verilog
FIFO_SRC_DIR=../../../../generic_fifos/rtl/verilog
GMEM_SRC_DIR=../../../../generic_memories/rtl/verilog

#_TARGETS_=	$(DUT_SRC_DIR)/usb1_top.v

_TARGETS_=	$(DUT_SRC_DIR)/usb1_utmi_if.v		\
		$(DUT_SRC_DIR)/usb1_pl.v		\
		$(DUT_SRC_DIR)/usb1_pd.v		\
		$(DUT_SRC_DIR)/usb1_pa.v		\
		$(DUT_SRC_DIR)/usb1_pe.v		\
		$(DUT_SRC_DIR)/usb1_idma.v		\
		$(DUT_SRC_DIR)/usb1_crc5.v		\
		$(DUT_SRC_DIR)/usb1_crc16.v		\
		$(DUT_SRC_DIR)/usb1_fifo2.v		\
		$(DUT_SRC_DIR)/usb1_ctrl.v		\
		$(DUT_SRC_DIR)/usb1_rom1.v		\
		$(DUT_SRC_DIR)/usb1_core.v		\
							\
		$(PHY_SRC_DIR)/usb_tx_phy.v		\
		$(PHY_SRC_DIR)/usb_rx_phy.v		\
		$(PHY_SRC_DIR)/usb_phy.v		\
							\
		$(FIFO_SRC_DIR)/generic_fifo_sc_a.v	\
							\
		$(GMEM_SRC_DIR)/generic_dpram.v		\
							\




##########################################################################
#
# Test Bench Sources
#
##########################################################################
_TOP_=test
TB_SRC_DIR=../../../bench/verilog
_TB_=		$(TB_SRC_DIR)/test_bench_top.v         \


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

simw_old:
	@$(MAKE) $(MS) sim ACCESS="-ACCESS +r " WAVES="-DEFINE WAVES"

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

simxl:
	verilog +incdir+$(DUT_SRC_DIR) +incdir+$(TB_SRC_DIR)	\
	+access+r +define+WAVES $(_TARGETS_) $(_TB_)

clean:
	rm -rf	./waves/*.dsn ./waves/*.trn		\
		INCA_libs ncverilog.key			\
		./verilog.* .nclog hal.log

