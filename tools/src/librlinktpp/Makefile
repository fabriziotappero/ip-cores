# $Id: Makefile 602 2014-11-08 21:42:47Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2014-11-08   602   1.1.4  add  TCLLIB/TCLLIBNAME to LDLIBS
# 2013-02-01   479   1.1.3  use checkpath_cpp.mk
# 2013-01-27   478   1.1.2  add RtclRlinkPort
# 2012-12-24   464   1.1.1  add TCLINC
# 2011-07-31   401   1.1    rename realclean->distclean
# 2011-07-01   386   1.0.2  add BOOSTINC
# 2011-03-20   372   1.0.1  renamed ..tcl -> ..tpp
# 2011-02-12   360   1.0    Initial version
#---
#
# Name of the sharable library
#
SONAME     = rlinktpp
SOMAJV     = 1
SOMINV     = 0
#
# Compile and Link search paths
#
include ../checkpath_cpp.mk
#
INCLFLAGS  = -I${RETROBASE}/tools/src -I${TCLINC} -I${BOOSTINC}
LDLIBS     = -L$(TCLLIB) -l$(TCLLIBNAME)
LDLIBS    += -L${RETROBASE}/tools/lib -lrtools -lrtcltools -lrlink
#
# Object files to be included
#
OBJ_all    = Rlinktpp_Init.o RtclRlinkPort.o RtclRlinkConnect.o \
		RtclRlinkServer.o RtclAttnShuttle.o
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
