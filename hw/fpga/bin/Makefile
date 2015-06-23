# ----------------------------------------------------------------
#                                                               //
#   FPGA synthesis Makefile                                     //
#                                                               //
#   This file is part of the Amber project                      //
#   http://www.opencores.org/project,amber                      //
#                                                               //
#   Description                                                 //
#   Runs a full FPGA synthesis of the Amber system.             //
#                                                               //
#   Author(s):                                                  //
#       - Conor Santifort, csantifort.amber@gmail.com           //
#                                                               //
#/ ///////////////////////////////////////////////////////////////
#                                                               //
#  Copyright (C) 2010 Authors and OPENCORES.ORG                 //
#                                                               //
#  This source file may be used and distributed without         //
#  restriction provided that this copyright statement is not    //
#  removed from the file and that any derivative work contains  //
#  the original copyright notice and the associated disclaimer. //
#                                                               //
#  This source file is free software; you can redistribute it   //
#  and/or modify it under the terms of the GNU Lesser General   //
#  Public License as published by the Free Software Foundation; //
#  either version 2.1 of the License, or (at your option) any   //
#  later version.                                               //
#                                                               //
#  This source is distributed in the hope that it will be       //
#  useful, but WITHOUT ANY WARRANTY; without even the implied   //
#  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
#  PURPOSE.  See the GNU Lesser General Public License for more //
#  details.                                                     //
#                                                               //
#  You should have received a copy of the GNU Lesser General    //
#  Public License along with this source; if not, download it   //
#  from http://www.opencores.org/lgpl.shtml                     //
#                                                               //
# ----------------------------------------------------------------

# ----------------------------------------------------
# Environment Configuration
# ----------------------------------------------------

# Directories
BIN_FOLDER              = ../bin
LOG_FOLDER              = ../logs
BITFILE_FOLDER          = ../bitfiles
BOOT_LOADER_ETHMAC      = 1

# Can supply different work directories
# for multiple runs in parallel
ifdef WORK
    WORK_FOLDER             = ../$(WORK)
else
    WORK_FOLDER             = ../work0
endif

ifdef BOOT_LOADER_ETHMAC
        BOOT_LOADER_DIR         = ../../../sw/boot-loader-ethmac
        BOOT_LOADER_DEF         = BOOT_LOADER_ETHMAC
else
        BOOT_LOADER_DIR         = ../../../sw/boot-loader-serial
        BOOT_LOADER_DEF         =
endif

VERILOG_INCLUDE_PATH    = ../../vlog/lib ../../vlog/tb $(BOOT_LOADER_DIR)

# Name of top level verilog file (must be the same as its module name)
RTL_TOP         = system



# ----------------------------------------------------
# Build Configuration
# ----------------------------------------------------

# Select either the A23 or A25 core
ifdef A25
    AMBER_CORE = AMBER_A25_CORE
    AMBER_CORE_NAME = a25
else
    AMBER_CORE = AMBER_A23_CORE
    AMBER_CORE_NAME = a23
endif


# AMBER_CLK_DIVIDER
# Sets the system clock frequency
# Divide 800MHz by this number to get the frequency
#   e.g. AMBER_CLK_DIVIDER=24
#   800 MHz / 24 = 33.33 MHz
AMBER_CLK_DIVIDER ?= 20
# The spartan6 device used on SP605 Development board
XILINX_FPGA     = xc6slx45tfgg484-3
XST_DEFINES     = XILINX_FPGA XILINX_SPARTAN6_FPGA $(AMBER_CORE) AMBER_CLK_DIVIDER=$(AMBER_CLK_DIVIDER) $(BOOT_LOADER_DEF)
# Xilinx placement and timing constraints
XST_CONST_FILE  = xs6_constraints.ucf
# List of verilog source files for Xilinx Spartan-6 device
XST_PROJ_FILE   = xs6_source_files.prj



# ----------------------------------------------------
# Focus on speed or area
# ----------------------------------------------------
#OPT = area
OPT = speed


# ----------------------------------------------------
# Xilinx XST Compile Options
# ----------------------------------------------------

XST_OPTIONS   =  -vlgincdir {$(VERILOG_INCLUDE_PATH)}  \
                 -ifmt mixed                           \
                 -ofmt NGC                             \
                 -p $(XILINX_FPGA)                     \
                 -opt_mode $(OPT)                      \
                 -opt_level 2                          \
                 -power NO                             \
                 -iuc NO                               \
                 -keep_hierarchy NO                    \
                 -rtlview Yes                          \
                 -glob_opt AllClockNets                \
                 -read_cores YES                       \
                 -write_timing_constraints NO          \
                 -cross_clock_analysis NO              \
                 -hierarchy_separator /                \
                 -bus_delimiter \<\>                   \
                 -case maintain                        \
                 -slice_utilization_ratio 100          \
                 -bram_utilization_ratio 100           \
                 -dsp_utilization_ratio 100            \
                 -fsm_extract YES                      \
                 -fsm_encoding Auto                    \
                 -safe_implementation No               \
                 -fsm_style lut                        \
                 -ram_extract Yes                      \
                 -ram_style Auto                       \
                 -rom_extract Yes                      \
                 -shreg_extract YES                    \
                 -rom_style Auto                       \
                 -auto_bram_packing NO                 \
                 -resource_sharing YES                 \
                 -async_to_sync NO                     \
                 -max_fanout 10000                     \
                 -bufg 32                              \
                 -register_duplication YES             \
                 -register_balancing No                \
                 -optimize_primitives NO               \
                 -use_clock_enable Auto                \
                 -use_sync_set Auto                    \
                 -use_sync_reset Auto                  \
                 -iob auto                             \
                 -equivalent_register_removal YES      \
                 -slice_utilization_ratio_maxmargin 5

# ----------------------------------------------------

RUN_ID      = $(shell cat $(WORK_FOLDER)/run_id.txt)
MAP_SEED    = $(shell $(BIN_FOLDER)/increment_seed.sh $(WORK_FOLDER)/seed.txt)
# ----------------------------------------------------


all : bitgen trce

new : clean all

map : cleanmap all

help :
	@echo ""
	@echo "Valid targets:"
	@echo "              new        Start a new run with a new ID"
	@echo "              all        Continue last run from where ever it left off"
	@echo "              map        Rerun the map and par with a new seed"
	@echo "              clean      Delete all temporary files"
	@echo "              bitgen     Create a bitfile. Don't run trce"
	@echo "              trce       Running timing analysis. Don't run buitgen"
	@echo "              help       Print this message"
	@echo ""
	@echo "Optional switches: A25=1 WORK=<work directory name>"
	@echo "e.g. > make A25=1 WORK=work1 map"

clean :
	rm -Rf   $(WORK_FOLDER)/*

cleanmap :
	if [ -f $(WORK_FOLDER)/$(RTL_TOP).map.ncd ]; then rm $(WORK_FOLDER)/$(RTL_TOP).map.ncd; fi

bitgen : $(WORK_FOLDER)/$(RTL_TOP).bit

trce : $(WORK_FOLDER)/$(RTL_TOP).trc.twr


# ----------------------------------------------------
# trce
# ----------------------------------------------------
# Can be done before or after bitgen
$(WORK_FOLDER)/$(RTL_TOP).trc.twr : $(WORK_FOLDER)/$(RTL_TOP).ncd
	\
	cd $(WORK_FOLDER); \
	trce -v 5 -l 5 -n 5 -xml $(RTL_TOP) $(RTL_TOP).ncd \
          -o $(WORK_FOLDER)/$(RTL_TOP).trc.twr \
          $(RTL_TOP).pcf
	cp $(WORK_FOLDER)/$(RTL_TOP).trc.twr $(LOG_FOLDER)/$(RTL_TOP).trc.$(RUN_ID).twr


# ----------------------------------------------------
# bitgen
# ----------------------------------------------------
$(WORK_FOLDER)/$(RTL_TOP).bit : $(WORK_FOLDER)/$(RTL_TOP).ncd
	\
	cd $(WORK_FOLDER); \
	bitgen -intstyle xflow -f $(BIN_FOLDER)/bitfile_config.ut $(RTL_TOP).ncd
	cp $(WORK_FOLDER)/$(RTL_TOP).bit $(BITFILE_FOLDER)/$(RTL_TOP).$(AMBER_CORE_NAME).$(RUN_ID).bit
	mv $(WORK_FOLDER)/$(RTL_TOP).bgn $(LOG_FOLDER)/$(RTL_TOP).$(AMBER_CORE_NAME).$(RUN_ID).bgn


# ----------------------------------------------------
# par
# ----------------------------------------------------
# -xe c  = Extra Effort, continue on Impossible
# -p means don't run the placer. We use map as the placer
# -k =  Re-entrant route. Keep the current placement. Continue the routing
#       using the existing routing as a starting point.
$(WORK_FOLDER)/$(RTL_TOP).ncd : $(WORK_FOLDER)/$(RTL_TOP).map.ncd
	\
	cd $(WORK_FOLDER); \
	par  -intstyle xflow -w -k -ol high $(RTL_TOP).map.ncd $(RTL_TOP).ncd $(RTL_TOP).pcf
	cp $(WORK_FOLDER)/$(RTL_TOP)_pad.txt $(LOG_FOLDER)/$(RTL_TOP).pad.$(RUN_ID).txt

# ----------------------------------------------------
# map
# ----------------------------------------------------
$(WORK_FOLDER)/$(RTL_TOP).map.ncd : $(WORK_FOLDER)/$(RTL_TOP).ngd
	cd $(WORK_FOLDER); \
	map -intstyle xflow        \
          -p $(XILINX_FPGA)        \
          -ol high                 \
          -t $(MAP_SEED)           \
          -w                       \
          -ignore_keep_hierarchy   \
          -timing                  \
          -detail                  \
          -register_duplication on \
          -lc auto                 \
          -xe c -mt off -ir off    \
          -pr off  -power off      \
          -o $(RTL_TOP).map.ncd    \
          $(RTL_TOP).ngd           \
          $(RTL_TOP).pcf
	cp $(WORK_FOLDER)/$(RTL_TOP).map.mrp $(LOG_FOLDER)/$(RTL_TOP).map.$(RUN_ID).mrp


# ----------------------------------------------------
# ngdbuild
# ----------------------------------------------------
$(WORK_FOLDER)/$(RTL_TOP).ngd : $(WORK_FOLDER)/$(RTL_TOP).ngc $(BIN_FOLDER)/$(XST_CONST_FILE)
	cd $(WORK_FOLDER); \
	ngdbuild -intstyle xflow -verbose -p $(XILINX_FPGA) \
          -dd _ngo  -nt on \
          -uc $(BIN_FOLDER)/$(XST_CONST_FILE) $(RTL_TOP).ngc $(RTL_TOP).ngd


# ----------------------------------------------------
# xst
# ----------------------------------------------------

# Note -iobuf YES is needed for the top-level verilog
# module synthesis

$(WORK_FOLDER)/$(RTL_TOP).ngc : $(WORK_FOLDER)/run_id.txt $(XST_PROJ_FILE)
	@echo "work: $(WORK_FOLDER)" > $(LOG_FOLDER)/$(RTL_TOP).cfg.$(RUN_ID).txt
	@echo "$(XST_DEFINES)" >> $(LOG_FOLDER)/$(RTL_TOP).cfg.$(RUN_ID).txt
	export XST_DESIGN=$(RTL_TOP)
	export XST_OFN=$(RTL_TOP)
	rm -Rf $(WORK_FOLDER)/$(RTL_TOP)xst $(WORK_FOLDER)/_ngo
	mkdir -p $(WORK_FOLDER)/$(RTL_TOP)xst/tmp $(WORK_FOLDER)/_ngo
	echo "work"                                         > $(WORK_FOLDER)/$(RTL_TOP).lso
	echo "set -tmpdir     ./$(RTL_TOP)xst/tmp"          > $(WORK_FOLDER)/$(RTL_TOP).xst
	echo "set -xsthdpdir  ./$(RTL_TOP)xst"             >> $(WORK_FOLDER)/$(RTL_TOP).xst
	echo "run -ifn $(BIN_FOLDER)/$(XST_PROJ_FILE)"     >> $(WORK_FOLDER)/$(RTL_TOP).xst
	echo "-ofn $(RTL_TOP) -top $(RTL_TOP)"             >> $(WORK_FOLDER)/$(RTL_TOP).xst
	echo "-lso ./$(RTL_TOP).lso"                       >> $(WORK_FOLDER)/$(RTL_TOP).xst
	echo $(XST_OPTIONS)                                >> $(WORK_FOLDER)/$(RTL_TOP).xst
	echo "-iobuf YES"                                  >> $(WORK_FOLDER)/$(RTL_TOP).xst
	echo "-define { $(XST_DEFINES) }"                  >> $(WORK_FOLDER)/$(RTL_TOP).xst
	cd $(WORK_FOLDER); \
	xst -intstyle xflow -ifn ./$(RTL_TOP).xst -ofn $(LOG_FOLDER)/$(RTL_TOP).xst.$(RUN_ID).srp


# ----------------------------------------------------
# Generate the Run ID, initial Map seed
# Recompile the boot-loader program - it gets build
# into the FPGA's RamBlocks and uses the run_id as
# the version number
# ----------------------------------------------------
$(WORK_FOLDER)/run_id.txt :
	test -e $(WORK_FOLDER) || mkdir $(WORK_FOLDER)
	test -e $(LOG_FOLDER) || mkdir $(LOG_FOLDER)
	test -e $(BITFILE_FOLDER) || mkdir $(BITFILE_FOLDER)
	echo 0 > $(WORK_FOLDER)/seed.txt
	date +%Y%m%d%H%M%S > $(WORK_FOLDER)/run_id.txt
	$(BIN_FOLDER)/set_fpga_version.sh $(WORK_FOLDER)/run_id.txt
	$(MAKE) -C $(BOOT_LOADER_DIR) clean
	$(MAKE) -C $(BOOT_LOADER_DIR)

