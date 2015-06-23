# $Id: dontincdep.mk 477 2013-01-27 14:07:10Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-01-27   477   1.0    Initial version
#
# DONTINCDEP controls whether dependency files are included. Set it if
# any of the 'clean' type targets is involved
#
ifneq  ($(findstring clean, $(MAKECMDGOALS)),)
DONTINCDEP = 1
endif
ifneq  ($(findstring cleandep, $(MAKECMDGOALS)),)
DONTINCDEP = 1
endif
ifneq  ($(findstring distclean, $(MAKECMDGOALS)),)
DONTINCDEP = 1
endif
ifdef DONTINCDEP
$(info DONTINCDEP set, *.dep files not included)
endif
