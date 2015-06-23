# $Id: Makefile 525 2013-07-06 12:19:39Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-03-22   496   1.0    Initial version
#---
#
MAC_all    = $(wildcard *.mac)
LSTERR_all = $(MAC_all:.mac=.lsterr)
LDART_all  = $(MAC_all:.mac=.ldart)
LSTRT_all  = $(MAC_all:.mac=.lstrt)
#
include $(RETROBASE)/tools/make/generic_asm11.mk
#
.PHONY : def alllst allrt allexp clean cleanrt
#
def : alllst
#
alllst : $(LSTERR_all)
#
allrt : $(LSTRT_all)
#
allexp : $(LSTERR_all)
	@ asm-11_expect $^
#
clean :
	@ rm -f $(LSTERR_all)
	@ echo "Listing files removed"

cleanrt :
	@ rm -f $(LDART_all) $(LSTRT_all)
	@ echo "RT-11 generated files removed"
