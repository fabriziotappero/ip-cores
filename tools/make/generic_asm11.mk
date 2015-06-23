# $Id: generic_asm11.mk 503 2013-04-06 19:44:13Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-04-06   503   1.0.1  use --hostinc for mac2lda
# 2013-03-22   496   1.0    Initial version
#---
#

ASM11    = asm-11
ASM11EXP = asm-11_expect

MAC2LDA  = mac2lda

ifdef ASM11COMMAND
ASM11 = $(ASM11COMMAND)
endif
ifdef ASM11EXPCOMMAND
ASM11EXP = $(ASM11EXPCOMMAND)
endif

#
# Compile rules
#
%.lda : %.mac
	$(ASM11) --lda --lst $< 
%.cof : %.mac
	$(ASM11) --cof --lst $< 
#
%.lst : %.mac
	$(ASM11) --lst $< 
#
%.lsterr : %.mac
	$(ASM11) --olst=%.lsterr $< || true
#
%.lstrt %ldart : %.mac
	$(MAC2LDA) --hostinc --suff=rt $*
#
# Expect rules
#
%.lstexp : %.lst
	$(ASM11EXP) $<
#
%.lstexp : %.lsterr
	$(ASM11EXP) $<
