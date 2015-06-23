# $Id: Makefile 525 2013-07-06 12:19:39Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-03-22   496   1.0    Initial version
#---
#
MAC_all   = $(wildcard *.mac)
LDA_all   = $(MAC_all:.mac=.lda)
COF_all   = $(MAC_all:.mac=.cof)
LST_all   = $(MAC_all:.mac=.lst)
LDART_all = $(MAC_all:.mac=.ldart)
LSTRT_all = $(MAC_all:.mac=.lstrt)
#
include $(RETROBASE)/tools/make/generic_asm11.mk
#
.PHONY : def alllda allcof alllst allrt allexp clean cleanrt
#
def : alllda
#
alllda : $(LDA_all)
#
allcof : $(COF_all)
#
alllst : $(LST_all)
#
allrt : $(LSTRT_all)
#
allexp : $(LST_all)
	@ asm-11_expect $^
#
clean :
	@ rm -f $(LDA_all)
	@ echo "Object files removed"
	@ rm -f $(COF_all)
	@ echo "Compound files removed"
	@ rm -f $(LST_all)
	@ echo "Listing files removed"

cleanrt :
	@ rm -f $(LDART_all) $(LSTRT_all)
	@ echo "RT-11 generated files removed"
