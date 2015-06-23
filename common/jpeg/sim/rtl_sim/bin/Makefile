##########################################################################
#                                                                        #
# JPEG Huffman codec Testsuite                                           #
# (C) 2002 Richard Herveille   richard@asics.ws                          #
#                                                                        #
# v.01                                                                   #
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

_TARGETS_=	$(DUT_SRC_DIR)/huffman_enc.v		\
		$(DUT_SRC_DIR)/huffman_dec.v


##########################################################################
#
# Test Bench Sources
#
##########################################################################
_TOP_=bench_top
TB_SRC_DIR=../../../bench/verilog
_TB_=		$(TB_SRC_DIR)/bench_top.v		\
		$(TB_SRC_DIR)/generic_dpram.v		\
		$(TB_SRC_DIR)/lfsr.v			\
		$(TB_SRC_DIR)/generic_fifo_lfsr.v	\

##########################################################################
#
# Misc Variables
#
##########################################################################

INCDIR=-INCDIR ./$(TB_SRC_DIR)/ -INCDIR ./$(DUT_SRC_DIR)/
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

sim:
	@echo ""
	@echo "----- Running NCVLOG ... ----------"
	@$(MAKE) $(MS) vlog				\
		TARGETS="$(_TARGETS_)"			\
		TB="$(_TB_)"				\
		INCDIR="$(INCDIR)"			\
		WAVES="$(WAVES)"
	@echo ""
	@echo "----- Running NCELAB ... ----------"
	@$(MAKE) $(MS) elab				\
		ACCESS="$(ACCESS)" TOP=$(_TOP_)
	@echo ""
	@echo "----- Running NCSIM ... ----------"
	@$(MAKE) $(MS) ncsim TOP=$(_TOP_)
	@echo ""


clean:
	rm -rf	./waves/*.dsn ./waves/*.trn		\
		ncwork/.inc* ncwork/inc*		\
		./verilog.* .nclog hal.log

##########################################################################
#
# NCVLOG
#
##########################################################################

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


