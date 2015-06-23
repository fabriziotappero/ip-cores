#
#	Example Makefile for Synopsys VCS-MX simulation.
#	
#	Author(s): 
#	- Daniel C.K. Kho, daniel.kho@opencores.org | daniel.kho@tauhop.com
#	
#	Copyright (C) 2012-2013 Authors and OPENCORES.ORG
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# This notice and disclaimer must be retained as part of this text at all times.
#
#	@dependencies: 
#	@designer: Daniel C.K. Kho [daniel.kho@gmail.com] | [daniel.kho@tauhop.com]
#	@history: @see Mercurial log for full list of changes.
#	
#	@Description:
#

SHELL = /bin/bash

# project name
PROJECT = pterodactyl

ROOT_PATH = $(PWD)
MODEL_SRC_PATH = $(ROOT_PATH)/../model
VHDL_SRC_PATH = $(ROOT_PATH)/../hw
COMMONFILES_PATH = $(SRC_PATH)/common

# model files
MODEL_FILES = $(SRC_PATH)/*.sagews $(SRC_PATH)/*.m $(SRC_PATH)/*.c

# vhdl files
#VHDL_FILES = $(SRC_PATH)/*.vhdl
#COMMON_VHDL_FILES = $(COMMONFILES_PATH)/*.vhdl

# build options
GHDL_BUILD_OPTS = #--std=02
DC_BUILD_OPTS = 
VCS_BUILD_OPTS = -vhdl08

# Simulation break condition
GHDL_SIM_OPTS    = --assert-level=error
#GHDL_SIM_OPTS    = --stop-time=5us		#500ns

# Workspaces
#SIM_PATH = $(ROOT_PATH)/simulation/ghdl
#SYNTH_PATH = $(ROOT_PATH)/synthesis/vivado
QUESTA_SIM_PATH = $(ROOT_PATH)/simulation/questa
VCS_SIM_PATH = $(ROOT_PATH)/simulation/vcs-mx
GHDL_SIM_PATH = $(ROOT_PATH)/simulation/ghdl
DC_SYNTH_PATH = $(ROOT_PATH)/synthesis/dc

# testbench
TARGET = tb_blowfish
#SIMFILES = testbench/led_top_tb.vhd

#LIBS = -Pcommon
LIBS = -P$(SRC_PATH)/common
#GHDL_FLAGS      = --ieee=synopsys --warn-no-vital-generic

model-build:
	sage ...
	gcc ...

ghdl-build:
	#mkdir -p $(SIM_PATH)
	ghdl $(GHDL_BUILD_OPTS) -i $(LIBS) --workdir=$(COMMONFILES_PATH) --work=common $(COMMON_FILES)
	ghdl $(GHDL_BUILD_OPTS) -i $(LIBS) --workdir=$(SIM_PATH) --work=work $(FILES)
	ghdl -m $(LIBS) --workdir=$(SIM_PATH) --work=work $(TARGET)
	
ghdl-run:
	#ghdl -r $(TARGET)
	@$(GHDL_SIM_PATH)/$(TARGET) $(GHDL_SIM_OPTS) --vcdgz=$(GHDL_SIM_PATH)/$(TARGET).vcdgz &
	#@$(SRC_PATH)/$(TARGET) $(GHDL_SIM_OPTS) --wave=$(SIM_PATH)/$(TARGET).ghw &
	
ghdl-view:
	gzip --decompress --stdout $(GHDL_SIM_PATH)/$(TARGET).vcdgz | gtkwave --vcd $(GHDL_SIM_PATH)/$(TARGET).gtkwave.sav &
	#gtkwave $(SIM_PATH)/$(TARGET).ghw $(SRC_PATH)/$(TARGET).gtkwave.gtkw &
	
	
simulate:
	make clean-sim;
	
	cd $(SIM_PATH); \
		mkdir -p ./work ./tauhop ./osvvm;
	
	#cd $(SIM_PATH); \
	#	vhdlan $(VCS_BUILD_OPTS) -work tauhop \
	#		$(VHDL_SRC_PATH)/packages/tauhop/pkg-tlm.vhdl \
	#		$(VHDL_SRC_PATH)/packages/tauhop/pkg-dsp.vhdl \
	#		| tee -ai $(SIM_PATH)/simulate.log;
	#
	#cd $(SIM_PATH); \
	#	vhdlan $(VCS_BUILD_OPTS) -work work \
	#		$(VHDL_SRC_PATH)/flight-controller.vhdl \
	#		| tee -ai $(SIM_PATH)/simulate.log;
	#
	##	../../../rtl/vhdl-tb/cfg_multiArch.vhdl;
	
	# Pass the simulation path into script.
	cd $(SIM_PATH); \
		$(SIM_PATH)/simulate.sh `echo $(SIM_PATH)` 2>&1 \
			| tee -ai $(SIM_PATH)/simulate.log &
	
synthesise:
	make clean-synth;
	
	echo $(date);
	
	dc_shell -f $(SYNTH_PATH)/synthesise.f 2>&1 \
		| tee -i $(SYNTH_PATH)/synthesise.log;
	
ghdl-clean:
	ghdl --clean --workdir=$(SIM_PATH)
	
clean-sim:
	rm -rf \
		$(VCS_SIM_PATH)/simv* \
		$(VCS_SIM_PATH)/64 \
		$(VCS_SIM_PATH)/simulate.log \
		$(VCS_SIM_PATH)/work \
		$(VCS_SIM_PATH)/tauhop \
		$(VCS_SIM_PATH)/osvvm;
	
	rm -rf \
		$(QUESTA_SIM_PATH)/transcript \
		$(QUESTA_SIM_PATH)/*.ini \
		$(QUESTA_SIM_PATH)/*.wlf \
		$(QUESTA_SIM_PATH)/simulate.log \
		$(QUESTA_SIM_PATH)/work \
		$(QUESTA_SIM_PATH)/tauhop \
		$(QUESTA_SIM_PATH)/osvvm;
	
clean-synth:
	rm -rf \
		./command.log \
		./default.svf;
	
	echo $(date "+[%Y-%m-%d %H:%M:%S]: Remove successful.");
