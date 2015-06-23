# $Id: Makefile 639 2015-01-30 18:12:19Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2014-07-27   545   1.3.1  make reference board configurable via XTW_BOARD
# 2011-08-13   405   1.3    use includes from rtl/make
# 2010-05-16   291   1.2.2  rename tb_memctl_s3sram->tb_s3_sram_memctl
# 2010-05-01   286   1.2.1  add tb_s3board_usp_dummy
# 2009-11-21   252   1.2    add ISim support
# 2007-11-26    98   1.1    use make includes
# 2007-09-23    84   1.0    Initial version
#
EXE_all  = tb_s3board_dummy
EXE_all += tb_s3board_fusp_dummy 
EXE_all += tb_s3_sram_memctl
#
ifndef XTW_BOARD
  XTW_BOARD=s3board
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
