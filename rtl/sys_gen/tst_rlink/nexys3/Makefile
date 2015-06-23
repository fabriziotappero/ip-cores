# $Id: Makefile 639 2015-01-30 18:12:19Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-11-26   433   1.0    Initial version
#
VBOM_all  = $(wildcard *.vbom)
BIT_all   = $(VBOM_all:.vbom=.bit)
#
include $(RETROBASE)/rtl/make_ise/xflow_default_nexys3.mk
#
.PHONY : all clean
#
all : $(BIT_all)
#
clean : ise_clean
	rm -f $(VBOM_all:.vbom=.ucf)
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
