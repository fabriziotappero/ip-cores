# $Id: Makefile 639 2015-01-30 18:12:19Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2014_12_26   621   1.4.2  use tbrun_tbw for check_* targets
# 2014-07-27   545   1.4.1  make reference board configurable via XTW_BOARD
# 2011-08-13   405   1.4    use includes from rtl/make
# 2010-12-30   351   1.3    retire tb_rripdp_pdp11core tb_rriext_pdp11core
# 2009-11-22   252   1.2    add ISim support
# 2007-09-16    83   1.1.1  add include *.o.dep_ghdl
# 2007-07-06    64   1.1    use vbom's
# 2007-06-17    58   1.0    Initial version
#
EXE_all  = tb_pdp11core
#
# default reference board for test synthesis is Spartan-6 based Nexys3
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
#-----
#  	time ~/misc_walter/p11_util/bin/pdp11 $*.scmd > $*.simh_raw_log
%.simh_log: %.dat
	tbdat2simh $*.dat > $*.scmd
	time pdp11 $*.scmd > $*.simh_raw_log
	simdat_check $*.simh_raw_log > $*.simh_log
	grep FAIL  $*.simh_log

check_dsim: tb_pdp11core tb_pdp11core_stim.dat
	tbrun_tbw tb_pdp11core || true
	@ echo "# diff to reference"
	diff tb_pdp11core_out_ref.dat tb_pdp11core_dsim.log

check_ssim: tb_pdp11core_ssim tb_pdp11core_stim.dat
	tbrun_tbw tb_pdp11core_ssim || true
	@ echo "# diff to reference"
	diff tb_pdp11core_out_ref.dat tb_pdp11core_ssim.log

check_simh: tb_pdp11core_stim.simh_log
