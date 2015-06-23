# $Id: Makefile 639 2015-01-30 18:12:19Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2015-01-24   637   1.0.2  use nexys3 as default XTW_BOARD
# 2014-07-27   545   1.0.1  make reference board configurable via XTW_BOARD
# 2011-11-26   433   1.0    Initial version (cloned)
#
EXE_all = tb_nx_cram_memctl_as
#
ifndef XTW_BOARD
  XTW_BOARD=nexys3
endif
include $(RETROBASE)/rtl/make_ise/xflow_default_$(XTW_BOARD).mk
#
.PHONY : all all_ssim all_tsim clean
#
all      : $(EXE_all)
all_ssim : $(EXE_all:=_ssim)
all_tsim : $(EXE_all:=_tsim)
#
clean : ise_clean ghdl_clean isim_clean
#
#-----
#
include $(RETROBASE)/rtl/make_ise/generic_ghdl.mk
include $(RETROBASE)/rtl/make_ise/generic_isim.mk
include $(RETROBASE)/rtl/make_ise/generic_xflow.mk
#
VBOM_all = $(wildcard *.vbom)
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
include $(VBOM_all:.vbom=.dep_isim)
include $(wildcard *.o.dep_ghdl)
endif
#
