
all:	sim

SHELL = /bin/sh
MS=-s

##########################################################################
#
# DUT Sources
#
##########################################################################
DUT_SRC_DIR=../../../rtl/verilog
_TARGETS_=	$(DUT_SRC_DIR)/wb_conmax_top.v		\
		$(DUT_SRC_DIR)/wb_conmax_slave_if.v	\
		$(DUT_SRC_DIR)/wb_conmax_master_if.v	\
		$(DUT_SRC_DIR)/wb_conmax_msel.v		\
		$(DUT_SRC_DIR)/wb_conmax_arb.v		\
		$(DUT_SRC_DIR)/wb_conmax_pri_enc.v	\
		$(DUT_SRC_DIR)/wb_conmax_pri_dec.v	\
		$(DUT_SRC_DIR)/wb_conmax_rf.v


##########################################################################
#
# Test Bench Sources
#
##########################################################################
_TOP_=test
TB_SRC_DIR=../../../bench/verilog
_TB_=		$(TB_SRC_DIR)/test_bench_top.v		\
		$(TB_SRC_DIR)/wb_slv_model.v		\
		$(TB_SRC_DIR)/wb_mast_model.v

##########################################################################
#
# Misc Variables
#
##########################################################################

INCDIR="-INCDIR ./$(DUT_SRC_DIR)/ -INCDIR ./$(TB_SRC_DIR)/"
LOGF=-LOGFILE .nclog
NCCOMMON=-CDSLIB ncwork/cds.lib -HDLVAR ncwork/hdl.var -NOCOPYRIGHT
UMC_LIB=/tools/dc_libraries/virtual_silicon/umc_lib.v
GATE_NETLIST = ../../../syn/out/wb_dma_top_ps.v

##########################################################################
#
# Make Targets
#
##########################################################################

ss:
	signalscan -do waves/waves.do -waves waves/waves.trn &

simxl:
	verilog +incdir+$(DUT_SRC_DIR) +incdir+$(TB_SRC_DIR)	\
	$(_TARGETS_) $(_TB_)

simw:
	@$(MAKE) $(MS) sim ACCESS="-ACCESS +r" WAVES="-DEFINE WAVES"

sim:
	@echo ""
	@echo "----- Running NCVLOG ... ----------"
	@$(MAKE) $(MS) vlog				\
		TARGETS="$(_TARGETS_)"			\
		TB="$(_TB_)"				\
		INCDIR=$(INCDIR)			\
		WAVES="$(WAVES)"
	@echo ""
	@echo "----- Running NCELAB ... ----------"
	@$(MAKE) $(MS) elab				\
		ACCESS="$(ACCESS)" TOP=$(_TOP_)
	@echo ""
	@echo "----- Running NCSIM ... ----------"
	@$(MAKE) $(MS) ncsim TOP=$(_TOP_)
	@echo ""

gatew:
	@$(MAKE) -s gate ACCESS="-ACCESS +r " WAVES="-DEFINE WAVES"

gate:
	@echo ""
	@echo "----- Running NCVLOG ... ----------"
	@$(MAKE) $(MS) vlog				\
		TARGETS="$(UMC_LIB) $(GATE_NETLIST)"	\
		TB="$(_TB_)"				\
		INCDIR=$(INCDIR)			\
		WAVES="$(WAVES)"
	@echo ""
	@echo "----- Running NCELAB ... ----------"
	@$(MAKE) $(MS) elab				\
		ACCESS="$(ACCESS)" TOP=$(_TOP_)
	@echo ""
	@echo "----- Running NCSIM ... ----------"
	@$(MAKE) $(MS) ncsim TOP=$(_TOP_)
	@echo ""

hal:
	@echo ""
	@echo "----- Running HAL ... ----------"
	@hal	-NOP -NOS -nocheck STYVAL:USEPRT:NOBLKN:DLNBLK	\
		+incdir+$(DUT_SRC_DIR) $(_TARGETS_)
	@echo "----- DONE ... ----------"

clean:
	rm -rf	./waves/*.dsn ./waves/*.trn		\
		ncwork/inc* ncwork/.inc* 		\
		./verilog.* .nclog hal.log

##########################################################################
#
# NCVLOG
#
##########################################################################

vhdl:
	ncvhdl $(NCCOMMON) $(LOGF) -APPEND_LOG			\
		-WORK count -V93 hdl/counter.vhd
	ncvhdl $(NCCOMMON) $(LOGF) -APPEND_LOG			\
		-WORK work -V93 $(TARGETS)

vlog:
	ncvlog $(NCCOMMON) $(LOGF) 				\
		-WORK work $(WAVES) $(TB) $(TARGETS) $(INCDIR)

##########################################################################
#
# NCELAB
#
##########################################################################

elab:
	ncelab	$(NCCOMMON) $(LOGF) -APPEND_LOG 		\
		-WORK work $(ACCESS) -NOTIMINGCHECKS		\
		work.$(TOP)

##########################################################################
#
# NCSIM
#
##########################################################################

ncsim:
	ncsim	$(NCCOMMON) $(LOGF) -APPEND_LOG			\
		-EXIT -ERRORMAX 10 work.$(TOP)


