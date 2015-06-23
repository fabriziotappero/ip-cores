# $Id: Makefile 685 2015-05-25 12:18:36Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-02-01   479   1.0.1  correct so name; use checkpath_cpp.mk
# 2013-01-27   478   1.0    Initial version
#---
#
# Name of the sharable library
#
SONAME     = rw11
SOMAJV     = 1
SOMINV     = 0
#
# Compile and Link search paths
#
include ../checkpath_cpp.mk
#
INCLFLAGS  = -I${RETROBASE}/tools/src -I${BOOSTINC}
LDLIBS     = -L${RETROBASE}/tools/lib -lrtools -lrlink
#
# Object files to be included
#
OBJ_all    = Rw11.o Rw11Cpu.o Rw11CpuW11a.o 
OBJ_all   +=   Rw11Probe.o
OBJ_all   +=   Rw11Cntl.o Rw11Unit.o
OBJ_all   +=   Rw11UnitTerm.o 
OBJ_all   +=   Rw11UnitDisk.o 
OBJ_all   +=   Rw11UnitTape.o 
OBJ_all   +=   Rw11UnitStream.o 
OBJ_all   +=   Rw11CntlDL11.o Rw11UnitDL11.o 
OBJ_all   +=   Rw11CntlLP11.o Rw11UnitLP11.o 
OBJ_all   +=   Rw11CntlPC11.o Rw11UnitPC11.o 
OBJ_all   +=   Rw11CntlRL11.o Rw11UnitRL11.o
OBJ_all   +=   Rw11CntlRK11.o Rw11UnitRK11.o
OBJ_all   +=   Rw11CntlRHRP.o Rw11UnitRHRP.o
OBJ_all   +=   Rw11CntlTM11.o Rw11UnitTM11.o
OBJ_all   +=   Rw11Virt.o 
OBJ_all   +=   Rw11VirtTerm.o Rw11VirtTermPty.o Rw11VirtTermTcp.o 
OBJ_all   +=   Rw11VirtDisk.o Rw11VirtDiskFile.o 
OBJ_all   +=   Rw11VirtTape.o Rw11VirtTapeTap.o 
OBJ_all   +=   Rw11VirtStream.o 
OBJ_all   +=   Rw11Rdma.o Rw11RdmaDisk.o 
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
