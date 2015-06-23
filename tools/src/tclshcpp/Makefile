# $Id: Makefile 601 2014-11-07 22:44:43Z mueller $
#

#
#  Revision History: 
# Date         Rev Version  Comment
# 2014-11-07   601   1.0    Initial version
#
# Compile and Link search paths
#
include ../checkpath_cpp.mk
#
INCLFLAGS  = -I${TCLINC}
LDLIBS    += -L$(TCLLIB) -l$(TCLLIBNAME)
#
BINPATH    = $(RETROBASE)/tools/bin
#
# Object files to be included
#
OBJ_all    = tclshcpp.o
#
DEP_all    = $(OBJ_all:.o=.dep)
#
# link target
#
$(BINPATH)/tclshcpp : $(OBJ_all)
	$(CXX) -o $(BINPATH)/tclshcpp $(OBJ_all) $(LDLIBS)

#- generic part ----------------------------------------------------------------
#
include $(RETROBASE)/tools/make/generic_cpp.mk
include $(RETROBASE)/tools/make/generic_dep.mk
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
distclean :
	@ rm -f $(BINPATH)/tclshcpp
	@ echo "Executable files removed"
