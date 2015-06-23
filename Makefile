# $Id:  $ From Russia with love

# ====================================================================== #
#                                                                        #
#  Makefile for  GOST 28147-89 CryptoCore project                        #       
#                                                                        #
#  Copyright (c) 2014 Dmitry Murzinov (kakstattakim@gmail.com)           #
#                                                                        #
# ====================================================================== #


# project name
PROJECT=gost28147_89
SOURCES=$(PROJECT).sv

SIM_DIR=./sim/bin
SYN_DIR=./syn/bin
CUR_DIR=$(shell pwd)

#ICARUS_SETUP:=. /soft/icarus.setup
#MENTOR_SETUP:=. /soft/mentor.setup
MENTOR_SETUP:=date
#SYNPLIFY_SETUP:=. /soft/synplify.setup
SYNPLIFY_SETUP:=date

#######################################################################
all: synthesis
default_target: help

synthesis: syn

##### HELP target #####
help:
	@echo ""
	@echo " Current project:   $(PROJECT)"
	@echo " Current directory: $(CUR_DIR)"	
	@echo ""
	@echo " Available targets :"
	@echo " =================="
	@echo " make              : print this text"
	@echo " make synthesis    : synthesize design using Synplify to get netlist"
	@echo " make sim          : compile and run simulation RTL-design using ModelSim"
	@echo " make sim-gui      : compile and run simulation RTL-design using ModelSim with GUI"
	@echo " make clean        : remove all temporary files"
	@echo ""

##### SIM target #####
sim: 
		@cd $(SIM_DIR);\
		$(MENTOR_SETUP);\
		vsim -c -quiet -do gost28147-89.tcl;\
		cd $(CUR_DIR);
sim-gui: 
		@cd $(SIM_DIR);\
		$(MENTOR_SETUP);\
		vsim -do gost28147-89_gui.tcl;\
		cd $(CUR_DIR);


##### SYN target #####
syn:
		@cd $(SYN_DIR);\
		$(SYNPLIFY_SETUP);\
		synplify_pro -enable64bit -batch synplify.tcl;\
		cd $(CUR_DIR);

##### PHONY target #####
.PHONY : clean syn sim
       