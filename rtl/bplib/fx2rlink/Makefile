# $Id: Makefile 639 2015-01-30 18:12:19Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2015-01-24   637   1.0.2  use nexys3 as default XTW_BOARD
# 2014-07-27   545   1.0.1  make reference board configurable via XTW_BOARD
# 2013-04-20   509   1.0    Initial version (cloned..)
#
VBOM_all = $(wildcard *.vbom)
NGC_all  = $(VBOM_all:.vbom=.ngc)
#
ifndef XTW_BOARD
  XTW_BOARD=nexys3
endif
include $(RETROBASE)/rtl/make_ise/xflow_default_$(XTW_BOARD).mk
#
.PHONY : all clean
#
all : $(NGC_all)
#
clean : ise_clean
#
#----
#
include $(RETROBASE)/rtl/make_ise/generic_xflow.mk
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
endif
#
