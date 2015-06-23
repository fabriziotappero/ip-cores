#
# Description: Top level make file for single_port test project.
#              make com to compile 
#              make sim to simulate all tests
#              make ll_error to run this test only
#              make ll_main to run this test only
#              make mem_main to run this test only
#              make mem_error to run this test only
#              make memnoflag_main to run this test
#              make memnoflag_error to run this test
# $Author: rpaley_yid $
# $Date: 2003-01-14 21:48:11 $
# $Header: /home/marcus/revision_ctrl_test/oc_cvs/cvs/single_port/VHDL/Makefile,v 1.1.1.1 2003-01-14 21:48:11 rpaley_yid Exp $
# $Locker:  $
# $Revision: 1.1.1.1 $
# $State: Exp $

# VCOM , VSIM , and WORK variables are set for Sonata simulator,
# Change appropriately for your simulator. Ex.for Modeltech,
# VCOM = vcom
# VSIM = vsim
# WORK = work

SHELL = /bin/sh
VCOM = vhdlp
VCOMOPT = -s
VSIM = vhdle
VSIMOPT = 
WORK = work.sym
## Need to figure out how to put Bourne shell stuff in Makefile
## will do so to generate log files in 
## LOGDIR = ../LOG/
## For now, log files are in VHDL directory.


# List of main compiled objects, does not include configurations,
# which are included in the tb_single_port.vhd file.
# These targets are for the Sonata simulator, adjust accordingly for
# your simulator.

SINGLE_PORT_PKG_OBJ = $(WORK)/single_port_pkg/prim.var 
LINKED_LIST_MEM_OBJ = $(WORK)/linked_list_mem_pkg/prim.var 
PKG_IMAGE_OBJ = $(WORK)/pkg_image/prim.var 
SINGLE_PORT_OBJ = $(WORK)/single_port/prim.var
TC_SINGLE_PORT_OBJ = $(WORK)/tc_single_port/prim.var
TB_SINGLE_PORT_OBJ = $(WORK)/tb_single_port/prim.var
LL_ERROR_DEP = $(WORK)/ll_error_cfg/prim.var
LL_MAIN_DEP = $(WORK)/ll_main_cfg/prim.var
MEM_MAIN_DEP = $(WORK)/mem_main_cfg/prim.var
MEM_ERROR_DEP = $(WORK)/mem_error_cfg/prim.var
MEMNOFLAG_MAIN_DEP = $(WORK)/memnoflag_main_cfg/prim.var
MEMNOFLAG_ERROR_DEP = $(WORK)/memnoflag_error_cfg/prim.var

LL_ERROR = $(LOGDIR)ll_error.log
LL_MAIN = ll_main.log
MEM_MAIN = mem_main.log
MEM_ERROR = mem_error.log
MEMNOFLAG_MAIN = memnoflag_main.log
MEMNOFLAG_ERROR = memnoflag_error.log

OBJS =	$(SINGLE_PORT_PKG_OBJ) \
	$(LINKED_LIST_MEM_OBJ) \
	$(PKG_IMAGE_OBJ) \
	$(SINGLE_PORT_OBJ) \
	$(TC_SINGLE_PORT_OBJ) \
	$(TB_SINGLE_PORT_OBJ) 

SIMOBJS = $(LL_ERROR) \
	$(LL_MAIN) \
	$(MEM_MAIN) \
	$(MEM_ERROR) \
	$(MEMNOFLAG_MAIN) \
	$(MEMNOFLAG_ERROR) 
	  
# Compile the project
com:	$(OBJS)

# Clean the library
clean:: $(WORK)

# Simulate all tests
sim:	$(SIMOBJS)

## Run only ll_error test
ll_error: $(LL_ERROR)

# Run onle ll_main test
ll_main: $(LL_MAIN)

# Run only mem_main test
mem_main: $(MEM_MAIN)

# Run only mem_error test
mem_error: $(MEM_ERROR)

# Run only memnoflag_main test
memnoflag_main: $(MEMNOFLAG_MAIN)

# Run only memnoflag_error test
memnoflag_error: $(MEMNOFLAG_ERROR)

# Target dependency rules to run tests
$(LL_ERROR) : $(LL_ERROR_DEP)
	$(VSIM) $(VSIMOPT) ll_error_cfg | tee $@

$(LL_MAIN) : $(LL_MAIN_DEP)
	$(VSIM) $(VSIMOPT) ll_main_cfg | tee $@

$(MEM_MAIN) : $(MEM_MAIN_DEP)
	$(VSIM) $(VSIMOPT) mem_main_cfg | tee $@

$(MEM_ERROR) : $(MEM_ERROR_DEP)
	$(VSIM) $(VSIMOPT) mem_error_cfg | tee $@
	
$(MEMNOFLAG_MAIN) : $(MEMNOFLAG_MAIN_DEP)
	$(VSIM) $(VSIMOPT) memnoflag_main_cfg | tee $@

$(MEMNOFLAG_ERROR) : $(MEMNOFLAG_ERROR_DEP)
	$(VSIM) $(VSIMOPT) memnoflag_error_cfg | tee $@

# Target dependency rules to compile tests

$(SINGLE_PORT_PKG_OBJ) : single_port_pkg.vhd
	$(VCOM) $(VCOMOPT) $< 

$(LINKED_LIST_MEM_OBJ) : linked_list_mem_pkg.vhd \
				$(SINGLE_PORT_PKG_OBJ)
	$(VCOM) $(VCOMOPT) $<

$(PKG_IMAGE_OBJ) : pkg_image.vhd
	$(VCOM) $(VCOMOPT) $< 

$(SINGLE_PORT_OBJ) : single_port.vhd \
			$(SINGLE_PORT_PKG_OBJ) \
			$(LINKED_LIST_MEM_OBJ) 
	$(VCOM) $(VCOMOPT) $< 

$(TC_SINGLE_PORT_OBJ) : tc_single_port.vhd \
			$(SINGLE_PORT_PKG_OBJ) \
			$(PKG_IMAGE_OBJ) \
			$(SINGLE_PORT_OBJ)
	$(VCOM) $(VCOMOPT) $< 

$(TB_SINGLE_PORT_OBJ) : tb_single_port.vhd \
			$(SINGLE_PORT_PKG_OBJ) \
			$(LINKED_LIST_MEM_OBJ) \
			$(SINGLE_PORT_OBJ) \
			$(TC_SINGLE_PORT_OBJ)
	$(VCOM) $(VCOMOPT) $< 

$(WORK) ::
	rm -rf $(WORK)/*

	
####################################################################
# $Log: not supported by cvs2svn $
# Revision 1.1  2002/12/31 19:21:59  Default
# Initial revision
#
#

