##########################################################################
#                                                                        #
# Simple SPI controller testsuite                                        #
# (C) 2004 Richard Herveille   richard@asics.ws                          #
#                                                                        #
# v.0                                                                    #
#                                                                        #
##########################################################################

all: sim
SHELL = /bin/sh
MS="-s"

##########################################################################
#
# DUT Sources
#
##########################################################################
DUT_SRC_DIR=../../../rtl/verilog
_TARGETS_=	$(DUT_SRC_DIR)/fifo4.v			\
		$(DUT_SRC_DIR)/simple_spi_top.v

##########################################################################
#
# Test Bench Sources
#
##########################################################################
_TOP_=tst_bench_top
TB_SRC_DIR=../../../bench/verilog
_TB_=		$(TB_SRC_DIR)/tst_bench_top.v		\
		$(TB_SRC_DIR)/spi_slave_model.v		\
		$(TB_SRC_DIR)/wb_master_model.v

##########################################################################
#
# Misc Variables
#
##########################################################################

INCDIR="-INCDIR ./$(DUT_SRC_DIR)/ -INCDIR ./$(TB_SRC_DIR)/"
LOGF=-LOGFILE .nclog
NCCOMMON=-CDSLIB ncwork/cds.lib -HDLVAR ncwork/hdl.var -NOCOPYRIGHT

##########################################################################
#
# Make Targets
#
##########################################################################
simw:
	@$(MAKE) -s sim ACCESS="-ACCESS +r " WAVES="-DEFINE WAVES"

ss:
	signalscan -do waves/waves.do -waves waves/waves.trn &

simxl:
	verilog +incdir+$(DUT_SRC_DIR) +incdir+$(TB_SRC_DIR)	\
	$(_TARGETS_) $(_TB_)

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

hal:
	@echo ""
	@echo "----- Running HAL ... ----------"
	@hal    +incdir+$(DUT_SRC_DIR)/ocidec-1/		\
		-NOP -NOS -nocheck STYVAL:USEPRT:NOBLKN:DLNBLK	\
		$(_TARGETS_)
	@echo "----- DONE ... ----------"

clean:
	rm -rf	./waves/*.dsn ./waves/*.trn		\
		ncwork/.inc* ncwork/inc*		\
		./verilog.* .nclog hal.log

##########################################################################
#
# NCVLOG
#
##########################################################################

vhdl:
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


