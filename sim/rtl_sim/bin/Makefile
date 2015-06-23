######################################################################
####                                                              ####
#### WISHBONE SD Card Controller IP Core                          ####
####                                                              ####
#### Makefile                                                     ####
####                                                              ####
#### This file is part of the WISHBONE SD Card                    ####
#### Controller IP Core project                                   ####
#### http://opencores.org/project,sd_card_controller              ####
####                                                              ####
#### Description                                                  ####
#### Simulation makefile                                          ####
####                                                              ####
#### Author(s):                                                   ####
####     - Marek Czerski, ma.czerski@gmail.com                    ####
####                                                              ####
######################################################################
####                                                              ####
#### Copyright (C) 2013 Authors                                   ####
####                                                              ####
#### This source file may be used and distributed without         ####
#### restriction provided that this copyright statement is not    ####
#### removed from the file and that any derivative work contains  ####
#### the original copyright notice and the associated disclaimer. ####
####                                                              ####
#### This source file is free software; you can redistribute it   ####
#### and/or modify it under the terms of the GNU Lesser General   ####
#### Public License as published by the Free Software Foundation; ####
#### either version 2.1 of the License, or (at your option) any   ####
#### later version.                                               ####
####                                                              ####
#### This source is distributed in the hope that it will be       ####
#### useful, but WITHOUT ANY WARRANTY; without even the implied   ####
#### warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ####
#### PURPOSE. See the GNU Lesser General Public License for more  ####
#### details.                                                     ####
####                                                              ####
#### You should have received a copy of the GNU Lesser General    ####
#### Public License along with this source; if not, download it   ####
#### from http://www.opencores.org/lgpl.shtml                     ####
####                                                              ####
######################################################################

V ?= @
VCD ?= 0

MODELSIM_DIR ?= /opt/altera/11.0/modelsim_ase

VCOM = $(MODELSIM_DIR)/bin/vcom
VLOG = $(MODELSIM_DIR)/bin/vlog
VOPT = $(MODELSIM_DIR)/bin/vopt
SCCOM = $(MODELSIM_DIR)/bin/sccom
VLIB = $(MODELSIM_DIR)/bin/vlib
VMAP = $(MODELSIM_DIR)/bin/vmap
VSIM = $(MODELSIM_DIR)/bin/vsim

# Define path to each library
LIB_SV_STD = $(MODELSIM_DIR)/sv_std
LIB_WORK = work
LIB_TEST = test

RUN_DIR = $(shell pwd)
BIN_DIR = $(shell pwd)/../bin
LOG_DIR = $(shell pwd)/../log
OUT_DIR = $(shell pwd)/../out

WORK_DIR = ../../../rtl/verilog
TEST_DIR = ../../../bench/verilog
WORK_SOURCES = $(wildcard $(WORK_DIR)/*.v)
TEST_SOURCES = $(wildcard $(TEST_DIR)/*.sv) $(wildcard $(TEST_DIR)/*.v)

WORK_OBJECTS = $(shell echo $(WORK_SOURCES) | sed 's:$(WORK_DIR):./$(LIB_WORK):g' | sed 's:\.v:/_primary.dat:g')
TEST_OBJECTS = $(shell echo $(TEST_SOURCES) | sed 's:$(TEST_DIR):./$(LIB_TEST):g' | sed 's:\.sv:/_primary.dat:g')

all: simulate

work_library: $(LIB_WORK) $(WORK_OBJECTS)

#./$(LIB_WORK)/%/_primary.dat: $(WORK_DIR)/%.v
#	@echo $@
#	$(V)$(VLOG) -work $(LIB_WORK) +incdir+$(WORK_DIR) -nocovercells -O0 $^
$(WORK_OBJECTS): $(WORK_SOURCES)
	$(V)$(VLOG) -work $(LIB_WORK) +incdir+$(WORK_DIR) -nocovercells -O0 $?
	
$(LIB_WORK) :
	$(V)echo "creating library $@ ..."
	$(V)$(VLIB) $(LIB_WORK)
	$(V)$(VMAP) $(LIB_WORK) $(LIB_WORK)

test_library: $(LIB_TEST) $(TEST_OBJECTS)

$(TEST_OBJECTS): $(TEST_SOURCES)
	$(V)$(VLOG) -work $(LIB_TEST) +incdir+$(WORK_DIR) +incdir+$(TEST_DIR) -nocovercells -O0 $?

$(LIB_TEST) : 
	$(V)echo "creating library $@ ..."
	$(V)$(VLIB) $(LIB_TEST)
	$(V)$(VMAP) $(LIB_TEST) $(LIB_TEST)


compile: work_library test_library

TESTBENCH_SOURCES = $(shell ls $(TEST_DIR)/*_tb.sv)
TESTBENCHES = $(shell echo $(TESTBENCH_SOURCES) | sed 's:$(TEST_DIR)/::g' | sed 's:\.sv::g')

ifeq ($(VCD), 1)
CLI_STARTUP_FILE = $(BIN_DIR)/vcd_startup.do
VCD_DIR = $(OUT_DIR)
else
CLI_STARTUP_FILE = $(BIN_DIR)/cli_startup.do
endif

$(OUT_DIR):
	$(V)mkdir $@

$(LOG_DIR):
	$(V)mkdir $@

%_tb: $(LOG_DIR) $(VCD_DIR) compile
	$(V)$(VSIM) -c -L $(RUN_DIR)/$(LIB_WORK) -do $(CLI_STARTUP_FILE) $(LIB_TEST).$@
	$(V)if [ $(VCD) = 1 ]; then mv tmp.vcd $(OUT_DIR)/$@.vcd; fi

simulate: $(TESTBENCHES)

modelsim: compile
	$(V)$(VSIM) -lib $(LIB_WORK)

%_tb_gui: $(LOG_DIR) compile
	$(V)$(VSIM) -L $(RUN_DIR)/$(LIB_WORK) -do $(BIN_DIR)/gui_startup.do $(LIB_TEST).$(shell echo $@ | sed 's:_gui::')

print_work_sources:
	$(V)@echo $(WORK_SOURCES)

print_test_sources:
	$(V)@echo $(TEST_SOURCES)
	
print_work_objects:
	$(V)@echo $(WORK_OBJECTS)

print_testbenches:
	$(V)@echo $(TESTBENCHES)

clean:
	$(V)rm -rfv $(LIB_WORK)
	$(V)rm -rfv $(LIB_TEST)
	$(V)rm -rfv $(LOG_DIR)
	$(V)rm -rfv $(OUT_DIR)
	$(V)rm -fv modelsim.ini *.wlf transcript
