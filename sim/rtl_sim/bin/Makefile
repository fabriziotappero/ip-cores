
all:	sim
SHELL = /bin/sh
#MS="-s"

##########################################################################
#
# DUT Sources
#
##########################################################################
DUT_SRC_DIR=../../../rtl/verilog
_TARGETS_=	$(DUT_SRC_DIR)/generic_dpram.v		\
		$(DUT_SRC_DIR)/generic_spram.v		\
		$(DUT_SRC_DIR)/csm_spram_bw.v		\
		$(DUT_SRC_DIR)/vga_colproc.v		\
		$(DUT_SRC_DIR)/vga_csm_pb.v		\
		$(DUT_SRC_DIR)/vga_cur_cregs.v		\
		$(DUT_SRC_DIR)/vga_curproc.v		\
		$(DUT_SRC_DIR)/vga_enh_top.v 		\
		$(DUT_SRC_DIR)/vga_dvi_top.v 		\
		$(DUT_SRC_DIR)/vga_fifo.v		\
		$(DUT_SRC_DIR)/vga_fifo_dc.v		\
		$(DUT_SRC_DIR)/vga_pgen.v		\
		$(DUT_SRC_DIR)/vga_tgen.v		\
		$(DUT_SRC_DIR)/vga_vtim.v		\
		$(DUT_SRC_DIR)/vga_wb_master.v		\
		$(DUT_SRC_DIR)/vga_wb_slave.v


##########################################################################
#
# Test Bench Sources
#
##########################################################################
TB_SRC_DIR=../../../bench/verilog
_TB_=		$(TB_SRC_DIR)/test_bench_top.v		\
		$(TB_SRC_DIR)/wb_slv_model.v		\
		$(TB_SRC_DIR)/wb_mast_model.v		\
		$(TB_SRC_DIR)/sync_check.v		\
		$(TB_SRC_DIR)/artsmcl18u_ram/art_hssp_512x24_bw_bist.v	\
		$(TB_SRC_DIR)/artsmcl18u_ram/art_hsdp_128x24_bist.v	\
		$(TB_SRC_DIR)/bist/rtl/verilog/bist_dp_top.v        \
		$(TB_SRC_DIR)/bist/rtl/verilog/bist_sp_top.v        \
		$(TB_SRC_DIR)/bist/rtl/verilog/bist_tp_top.v        \
		$(TB_SRC_DIR)/bist/rtl/verilog/bist.v               \
		$(TB_SRC_DIR)/artsmcl18u_ram/art_hssp_512x24_bw/art_hssp_512x24_bw.v	\
		$(TB_SRC_DIR)/artsmcl18u_ram/art_hsdp_128x24/art_hsdp_128x24.v	\
		$(TB_SRC_DIR)/wb_b3_check.v

##########################################################################
#
# Misc Variables
#
##########################################################################

_TOP_=test
INCDIR="-INCDIR ./$(DUT_SRC_DIR)/ -INCDIR ./$(TB_SRC_DIR)/"
LOGF=-LOGFILE .nclog
NCCOMMON=-CDSLIB ncwork/cds.lib -HDLVAR ncwork/hdl.var -NOCOPYRIGHT
UMC_LIB=/tools/dc_libraries/virtual_silicon/umc_lib.v
GATE_NETLIST=../../../syn/out/vga_vga_and_clut_ps.v

##########################################################################
#
# Make Targets
#
##########################################################################
simw:
	@$(MAKE) -s sim ACCESS="-ACCESS +r" WAVES="-DEFINE WAVES"

ss:
	signalscan -do waves/waves.do -waves waves/waves.trn &

sim:
	@echo ""
	@echo "----- Running NCVLOG ... ----------"
	@$(MAKE) $(MS) vlog				\
		TARGETS="$(_TARGETS_)"			\
		TB="$(_TB_)"				\
		INCDIR=$(INCDIR)			\
		WAVES="$(WAVES)"			\
		TOP=$(_TOP_)
	@echo ""
	@echo "----- Running NCELAB ... ----------"
	@$(MAKE) $(MS) elab				\
		ACCESS="$(ACCESS)" TOP=$(_TOP_)
	@echo ""
	@echo "----- Running NCSIM ... ----------"
	@$(MAKE) $(MS) ncsim				\
		TOP=$(_TOP_)
	@echo ""


gatew:
	@$(MAKE) -s gate ACCESS="-ACCESS +r " WAVES="-DEFINE WAVES"

gate:
	@echo ""
	@echo "----- Running NCVLOG ... ----------"
	$(MAKE)$(MS) vlog				\
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
	hal	+incdir+$(DUT_SRC_DIR)                          \
		-NOP -NOS -nocheck STYVAL:USEPRT:NOBLKN:DLNBLK  \
		"$(_TARGETS_)"
	@echo "----- DONE ... ----------"

clean:
	rm -rf	./waves/*.dsn ./waves/*.trn	\
		ncwork/worklib/* ncwork/count/*	\
		ncwork/worklib/.i* ncwork/count/.i* 

##########################################################################
#
# NCVLOG
#
##########################################################################

vlog:
	ncvlog $(NCCOMMON) $(LOGF) 				\
		-WORK worklib $(WAVES) $(TARGETS) $(TB) $(INCDIR)

##########################################################################
#
# NCELAB
#
##########################################################################

elab:
	ncelab	$(NCCOMMON) $(LOGF) -APPEND_LOG 		\
		-WORK worklib $(ACCESS) 				\
		-NOTIMINGCHECKS        \
		worklib.$(TOP)

##########################################################################
#
# NCSIM
#
##########################################################################

ncsim:
	ncsim	$(NCCOMMON) $(LOGF) -APPEND_LOG			\
		-EXIT -ERRORMAX 10 worklib.$(TOP)



