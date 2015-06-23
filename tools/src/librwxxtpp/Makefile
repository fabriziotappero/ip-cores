# $Id: Makefile 683 2015-05-17 21:54:35Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2014-11-08   602   1.0.2  add  TCLLIB/TCLLIBNAME to LDLIBS
# 2013-02-01   479   1.0.1  correct so name (no digits allowed in tcl load...)
# 2013-01-27   478   1.0    Initial version
#---
#
# Name of the sharable library
#
SONAME     = rwxxtpp
SOMAJV     = 1
SOMINV     = 0
#
# Compile and Link search paths
#
include ../checkpath_cpp.mk
#
INCLFLAGS  = -I${RETROBASE}/tools/src -I${TCLINC} -I${BOOSTINC}
LDLIBS     = -L$(TCLLIB) -l$(TCLLIBNAME)
LDLIBS    += -L${RETROBASE}/tools/lib -lrtools -lrtcltools 
LDLIBS    +=   -lrlink -lrw11
LDLIBS    +=   -lrlinktpp
#
# Object files to be included
#
OBJ_all    = Rwxxtpp_Init.o RtclRw11.o 
OBJ_all   +=   RtclRw11Cpu.o RtclRw11CpuW11a.o
OBJ_all   +=   RtclRw11Cntl.o RtclRw11CntlFactory.o 
OBJ_all   +=   RtclRw11Unit.o
OBJ_all   +=   RtclRw11UnitTerm.o
OBJ_all   +=   RtclRw11UnitDisk.o
OBJ_all   +=   RtclRw11UnitTape.o
OBJ_all   +=   RtclRw11UnitStream.o
OBJ_all   +=   RtclRw11CntlDL11.o RtclRw11UnitDL11.o
OBJ_all   +=   RtclRw11CntlLP11.o RtclRw11UnitLP11.o
OBJ_all   +=   RtclRw11CntlPC11.o RtclRw11UnitPC11.o
OBJ_all   +=   RtclRw11CntlRK11.o RtclRw11UnitRK11.o
OBJ_all   +=   RtclRw11CntlRL11.o RtclRw11UnitRL11.o
OBJ_all   +=   RtclRw11CntlRHRP.o RtclRw11UnitRHRP.o
OBJ_all   +=   RtclRw11CntlTM11.o RtclRw11UnitTM11.o
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
