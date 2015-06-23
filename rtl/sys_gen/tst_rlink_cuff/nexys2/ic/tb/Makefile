# $Id: Makefile 639 2015-01-30 18:12:19Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-01-01   467   1.0    Initial version
#
EXE_all = tb_tst_rlink_cuff_ic_n2
#
include $(RETROBASE)/rtl/make_ise/xflow_default_nexys2.mk
#
.PHONY : all all_ssim all_tsim clean
#
all      : $(EXE_all)
all_ssim : $(EXE_all:=_ssim)
all_tsim : $(EXE_all:=_tsim)
#
clean : ise_clean ghdl_clean
	rm -f sys_tst_rlink_cuff_ic_n2.ucf
#
#-----
#
include $(RETROBASE)/rtl/make_ise/generic_ghdl.mk
include $(RETROBASE)/rtl/make_ise/generic_xflow.mk
#
VBOM_all = $(wildcard *.vbom)
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
include $(wildcard *.o.dep_ghdl)
endif
#
