# $Id: Makefile 602 2014-11-08 21:42:47Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-02-01   479   1.1.1  use checkpath_cpp.mk
# 2011-07-31   401   1.1    rename realclean->distclean
# 2011-07-01   386   1.0.1  add BOOSTINC
# 2011-01-09   354   1.0    Initial version (adopted from CTB...)
#---
#
# Name of the sharable library
#
SONAME     = rlink
SOMAJV     = 1
SOMINV     = 0
#
# Compile and Link search paths
#
include ../checkpath_cpp.mk
#
INCLFLAGS  = -I${RETROBASE}/tools/src -I${BOOSTINC}
LDLIBS     = -lusb-1.0
LDLIBS    += -L${BOOSTLIB} -lboost_thread
LDLIBS    += -L${RETROBASE}/tools/lib -lrtools
#
# Object files to be included
#
OBJ_all    = RlinkAddrMap.o 
OBJ_all   += RlinkCommand.o RlinkCommandExpect.o RlinkCommandList.o 
OBJ_all   += RlinkConnect.o RlinkContext.o  RlinkChannel.o 
OBJ_all   += RlinkCrc16.o 
OBJ_all   += RlinkPacketBuf.o RlinkPacketBufSnd.o RlinkPacketBufRcv.o 
OBJ_all   += RlinkPort.o RlinkPortFactory.o 
OBJ_all   += RlinkPortFifo.o RlinkPortTerm.o RlinkPortCuff.o 
OBJ_all   += RtimerFd.o ReventFd.o ReventLoop.o 
OBJ_all   += RlinkServer.o RlinkServerEventLoop.o 
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
