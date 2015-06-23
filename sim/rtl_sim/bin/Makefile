
all:	simpo
SHELL = /bin/sh

##########################################################################
#
# DUT Sources
#
##########################################################################
DUT_SRC_DIR=../../../rtl/verilog
_TARGETS_COM_=	$(DUT_SRC_DIR)/common/crp.v		\
		$(DUT_SRC_DIR)/common/sbox1.v		\
		$(DUT_SRC_DIR)/common/sbox2.v		\
		$(DUT_SRC_DIR)/common/sbox3.v		\
		$(DUT_SRC_DIR)/common/sbox4.v		\
		$(DUT_SRC_DIR)/common/sbox5.v		\
		$(DUT_SRC_DIR)/common/sbox6.v		\
		$(DUT_SRC_DIR)/common/sbox7.v		\
		$(DUT_SRC_DIR)/common/sbox8.v

_TARGETS_AO_=	$(DUT_SRC_DIR)/area_opt/des.v		\
		$(DUT_SRC_DIR)/area_opt/key_sel.v 

_TARGETS_AO3_=	$(DUT_SRC_DIR)/area_opt/des3.v		\
		$(DUT_SRC_DIR)/area_opt/key_sel3.v 


_TARGETS_PO_=	$(DUT_SRC_DIR)/perf_opt/des.v		\
		$(DUT_SRC_DIR)/perf_opt/key_sel.v 

_TARGETS_PO3_=	$(DUT_SRC_DIR)/perf_opt/des3.v		\
		$(DUT_SRC_DIR)/perf_opt/des.v		\
		$(DUT_SRC_DIR)/perf_opt/key_sel.v 


##########################################################################
#
# Test Bench Sources
#
##########################################################################
TB_SRC_DIR=../../../bench/verilog

_TB_PO_=	$(TB_SRC_DIR)/des_test_po.v

_TB_PO3_=	$(TB_SRC_DIR)/des3_test_po.v

_TB_AO_=	$(TB_SRC_DIR)/des_test_ao.v

_TB_AO3_=	$(TB_SRC_DIR)/des3_test_ao.v


##########################################################################
#
# Misc Variables
#
##########################################################################

_TOP_=test
INCDIR=+incdir+./$(DUT_SRC_DIR)/ +incdir+./$(TB_SRC_DIR)/ 
LOGF=-l .nclog

##########################################################################
#
# Make Targets
#
##########################################################################

ss:
	signalscan -do waves/waves.do -waves waves/waves.trn &

simpow:
	@$(MAKE) simpo WAVES="+access+r +define+WAVES "

simpo:
	@echo ""
	@echo "----- Running NCVLOG ... ----------"
	ncverilog					\
		$(LOGF)					\
		$(WAVES)				\
		$(INCDIR)				\
		$(_TARGETS_COM_) $(_TARGETS_PO_)	\
		$(_TB_PO_)


simaow:
	@$(MAKE) simao WAVES="+define+WAVES +access+r "

simao:
	@echo ""
	@echo "----- Running NCVLOG ... ----------"
	ncverilog					\
		$(LOGF)					\
		$(WAVES)				\
		$(INCDIR)				\
		$(_TARGETS_COM_) $(_TARGETS_AO_)	\
		$(_TB_AO_)


simpow3:
	@$(MAKE) simpo3 WAVES="+access+r +define+WAVES "

simpo3:
	@echo ""
	@echo "----- Running NCVLOG ... ----------"
	ncverilog					\
		$(LOGF)					\
		$(WAVES)				\
		$(INCDIR)				\
		$(_TARGETS_COM_) $(_TARGETS_PO3_)	\
		$(_TB_PO3_)

simaow3:
	@$(MAKE) simao3 WAVES="+define+WAVES +access+r "


simao3:
	@echo ""
	@echo "----- Running NCVLOG ... ----------"
	ncverilog					\
		$(LOGF)					\
		$(WAVES)				\
		$(INCDIR)				\
		$(_TARGETS_COM_) $(_TARGETS_AO3_)	\
		$(_TB_AO3_)





clean:
	rm -rf	./waves/*.dsn ./waves/*.trn		\
		INCA*					\
		./verilog.* .nclog hal.log


