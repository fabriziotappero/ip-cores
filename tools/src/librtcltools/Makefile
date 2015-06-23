# $Id: Makefile 529 2013-08-02 17:15:43Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-02-01   479   1.1.2  use checkpath_cpp.mk
# 2012-12-24   464   1.1.1  add TCLINC
# 2011-07-31   401   1.1    rename realclean->distclean
# 2011-07-01   386   1.0.1  add BOOSTINC
# 2011-02-11   360   1.0    Initial version
#---
#
# Name of the sharable library
#
SONAME     = rtcltools
SOMAJV     = 1
SOMINV     = 0
#
# Compile and Link search paths
#
include ../checkpath_cpp.mk
#
INCLFLAGS  = -I${RETROBASE}/tools/src -I${TCLINC} -I${BOOSTINC}
LDLIBS     = -L${RETROBASE}/tools/lib -lrtools
#
# Object files to be included
#
OBJ_all    = Rtcl.o RtclArgs.o RtclClassBase.o RtclContext.o 
OBJ_all   +=   RtclNameSet.o RtclCmdBase.o RtclProxyBase.o RtclStats.o
OBJ_all   +=   RtclGetBase.o RtclGetList.o RtclSetBase.o RtclSetList.o
#
DEP_all    = $(OBJ_all:.o=.dep)
#
#- generic part ----------------------------------------------------------------
#
SOFILE     = lib$(SONAME).so
SOFILEV    = lib$(SONAME).so.$(SOMAJV)
SOFILEVV   = lib$(SONAME).so.$(SOMAJV).$(SOMINV)
#
include $(RETROBASE)/tools/make/generic_cpp.mk
include $(RETROBASE)/tools/make/generic_dep.mk
include $(RETROBASE)/tools/make/generic_so.mk
include $(RETROBASE)/tools/make/dontincdep.mk
#
# The magic auto-dependency include
#
ifndef DONTINCDEP
include $(DEP_all)
endif
#
# cleanup phonies:
#
.PHONY    : clean cleandep distclean
clean     :
	@ rm -f $(OBJ_all)
	@ echo "Object files removed"
#
cleandep  :
	@ rm -f $(DEP_all)
	@ echo "Dependency files removed"
#
distclean : clean cleandep
	@ rm -f $(SOPATH)/lib$(SONAME).a $(SOPATH)/lib$(SONAME).so*
	@ echo "Libraries removed"
#
