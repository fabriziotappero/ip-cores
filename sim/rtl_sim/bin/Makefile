
all:	sim
SHELL = /bin/sh
MS="-s"

##########################################################################
#
# DUT Sources
#
##########################################################################
DUT_SRC_DIR=../../../rtl/verilog
_TARGETS_=	$(DUT_SRC_DIR)/aes_sbox.v			\
		$(DUT_SRC_DIR)/aes_rcon.v			\
		$(DUT_SRC_DIR)/aes_key_expand_128.v		\
		$(DUT_SRC_DIR)/aes_cipher_top.v			\
		$(DUT_SRC_DIR)/aes_inv_sbox.v			\
		$(DUT_SRC_DIR)/aes_inv_cipher_top.v

		
##########################################################################
#
# Test Bench Sources
#
##########################################################################
TB_SRC_DIR=../../../bench/verilog
_TB_=		$(TB_SRC_DIR)/test_bench_top.v	

##########################################################################
#
# Misc Variables
#
##########################################################################

INCDIR=+incdir+./$(DUT_SRC_DIR)/ +incdir+./$(TB_SRC_DIR)/
LOGF=-l .nclog
UMC_LIB=/tools/dc_libraries/virtual_silicon/umc_lib.v
GATE_NETLIST = ../../../syn/out/aes_cipher_top.v

##########################################################################
#
# Make Targets
#
##########################################################################
ss:
	signalscan -do waves/waves.do -waves waves/waves.trn &

simw:
	@$(MAKE) -s sim ACCESS="+access+r " WAVES="+define+WAVES"

sim:
	ncverilog -q +define+RUDIS_TB $(_TARGETS_) $(_TB_)	\
		$(INCDIR) $(WAVES) $(ACCESS) $(LOGF) +ncstatus	\
		+ncuid+`hostname` 

ivl:
	/usr/local/bin/iverilog  -D RUDIS_TB $(_TARGETS_) $(_TB_)	\
		-I ./$(DUT_SRC_DIR)/ -I ./$(TB_SRC_DIR)/		\
		$(WAVES) $(ACCESS)  -s test 

gatew:
	@$(MAKE) -s gate ACCESS="+access+r" WAVES="+define+WAVES"

gate:
	ncverilog -q +define+RUDIS_TB $(_TB_) $(UMC_LIB)	\
		$(GATE_NETLIST) $(INCDIR) $(WAVES) $(ACCESS)	\
		$(LOGF) +ncstatus +ncuid+`hostname` 

hal:
	@echo ""
	@echo "----- Running HAL ... ----------"
	@hal    +incdir+$(DUT_SRC_DIR) 	-NOP -NOS	\
		-nocheck STYVAL:USEPRT:NOBLKN:DLNBLK	\
		$(_TARGETS_)
	@echo "----- DONE ... ----------"

clean:
	rm -rf	./waves/*.dsn ./waves/*.trn		\
		ncwork/.inc* ncwork/inc*		\
		./verilog.* .nclog hal.log INCA_libs

##########################################################################

