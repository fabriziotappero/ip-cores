# $Id: Makefile 639 2015-01-30 18:12:19Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-08-13   405   1.2    use includes from rtl/make
# 2010-05-28   295   1.1.4  rename sys_pdp11core -> sys_w11a_s3
# 2010-04-24   282   1.1.3  use %.impact rule, all=BIT_all now
# 2009-11-20   251   1.1.2  add .mcs rule
# 2009-07-26   236   1.1.1  add program: rule
# 2007-11-26    98   1.1    include $(RETROBASE)/vlib/Makefile.(ghdl|xflow)
# 2007-07-08    65   1.0    Initial version
#
VBOM_all  = $(wildcard *.vbom)
BIT_all   = $(VBOM_all:.vbom=.bit)
#
include $(RETROBASE)/rtl/make_ise/xflow_default_s3board.mk
#
.PHONY : all clean
#
all : $(BIT_all)
#
clean : ise_clean
	rm -f $(VBOM_all:.vbom=.ucf)
#
sys_w11a_s3.mcs : sys_w11a_s3.bit
	promgen -w -x xcf04s -p mcs -u 0 sys_w11a_s3
	mv sys_w11a_s3.prm sys_w11a_s3_prm.log
	mv sys_w11a_s3.cfi sys_w11a_s3_cfi.log
#
#----
#
include $(RETROBASE)/rtl/make_ise/generic_xflow.mk
include $(RETROBASE)/rtl/make_ise/generic_ghdl.mk
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
endif
#
