
all:	sim
SHELL = /bin/sh
MS="-s"

##########################################################################
#
# DUT Sources
#
##########################################################################
DUT_SRC_DIR=../../../rtl/verilog
_TARGETS_=	$(DUT_SRC_DIR)/ac97_top.v                      \
		$(DUT_SRC_DIR)/ac97_sout.v                     \
		$(DUT_SRC_DIR)/ac97_sin.v                      \
		$(DUT_SRC_DIR)/ac97_soc.v                      \
		$(DUT_SRC_DIR)/ac97_out_fifo.v                 \
		$(DUT_SRC_DIR)/ac97_in_fifo.v                  \
		$(DUT_SRC_DIR)/ac97_wb_if.v                    \
		$(DUT_SRC_DIR)/ac97_rf.v                       \
		$(DUT_SRC_DIR)/ac97_prc.v                      \
		$(DUT_SRC_DIR)/ac97_fifo_ctrl.v                \
		$(DUT_SRC_DIR)/ac97_cra.v                      \
		$(DUT_SRC_DIR)/ac97_dma_if.v                   \
		$(DUT_SRC_DIR)/ac97_dma_req.v                  \
		$(DUT_SRC_DIR)/ac97_int.v                      \
		$(DUT_SRC_DIR)/ac97_rst.v 

##########################################################################
#
# Test Bench Sources
#
##########################################################################
_TOP_=test
TB_SRC_DIR=../../../bench/verilog
_TB_=		$(TB_SRC_DIR)/ac97_codec_sout.v            \
		$(TB_SRC_DIR)/ac97_codec_sin.v             \
		$(TB_SRC_DIR)/ac97_codec_top.v             \
		$(TB_SRC_DIR)/test_bench_top.v             \
		$(TB_SRC_DIR)/wb_mast_model.v 

##########################################################################
#
# Misc Variables
#
##########################################################################

INCDIR=+incdir+./$(DUT_SRC_DIR)/ +incdir+./$(TB_SRC_DIR)/
LOGF=-l .nclog
#NCCOMMON=-CDSLIB ncwork/cds.lib -HDLVAR ncwork/hdl.var -NOCOPYRIGHT
UMC_LIB=/tools/dc_libraries/virtual_silicon/umc_lib.v
GATE_NETLIST = ../../../syn/out/mc_top_ps.v

##########################################################################
#
# Make Targets
#
##########################################################################

ss:
	signalscan -do waves/waves.do -waves waves/waves.trn &

simw:
	@$(MAKE) -s sim ACCESS="+access+r " WAVES="+define+WAVES"

simxl:
	verilog +incdir+$(DUT_SRC_DIR) +incdir+$(TB_SRC_DIR)	\
	$(_TARGETS_) $(_TB_)

sim:
	ncverilog -q +define+RUDIS_TB $(_TARGETS_) $(_TB_)	\
		$(INCDIR) $(WAVES) $(ACCESS) $(LOGF) +ncstatus	\
		+ncuid+`hostname`

hal:
	@echo ""
	@echo "----- Running HAL ... ----------"
	@hal    +incdir+$(DUT_SRC_DIR)				\
		-NOP -NOS -nocheck STYVAL:USEPRT:NOBLKN:DLNBLK	\
		$(_TARGETS_)
	@echo "----- DONE ... ----------"

clean:
	rm -rf	./waves/*.dsn ./waves/*.trn		\
		ncwork/.inc* ncwork/inc*		\
		./verilog.* .nclog hal.log		\
		INCA_libs/

##########################################################################

