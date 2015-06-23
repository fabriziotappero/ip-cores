# $Id: Makefile 639 2015-01-30 18:12:19Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-08-13   405   1.1    use includes from rtl/make
# 2007-12-14   101   1.0    Initial version
#
#
.PHONY : clean
#
clean : ghdl_clean
#
#-----
#
include $(RETROBASE)/rtl/make_ise/generic_ghdl.mk
#
VBOM_all = $(wildcard *.vbom)
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_ghdl)
endif
#
