# $Id: Makefile 646 2015-02-15 12:04:55Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2015-01-25   639   1.0    Initial version
#
VBOM_all  = $(wildcard *.vbom)
BIT_all   = $(VBOM_all:.vbom=.bit)
#
include $(RETROBASE)/rtl/make_viv/viv_default_nexys4.mk
#
.PHONY : all clean
#
all : $(BIT_all)
#
clean : viv_clean
#
#----
#
include $(RETROBASE)/rtl/make_viv/generic_vivado.mk
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_vsyn)
##include $(VBOM_all:.vbom=.dep_ghdl)
endif
#
