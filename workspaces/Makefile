#
#	Example Makefile for Synopsys VCS-MX simulation.
#	
#	Author(s): 
#	- Daniel C.K. Kho, daniel.kho@opencores.org | daniel.kho@tauhop.com
#	
#	Copyright (C) 2012-2014 Authors and OPENCORES.ORG
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
PROJECT = fir_wishbone

ROOT_PATH = $(PWD)
MODEL_SRC_PATH = $(ROOT_PATH)/../model
#VHDL_SRC_PATH = $(ROOT_PATH)/../hw
VHDL_SRC_PATH = $(ROOT_PATH)/../design
VHDL_TB_PATH = $(ROOT_PATH)/../tester
#COMMONFILES_PATH = $(SRC_PATH)/common

# model files
MODEL_FILES = $(SRC_PATH)/*.sagews $(SRC_PATH)/*.m $(SRC_PATH)/*.c

# vhdl files
#VHDL_FILES = $(SRC_PATH)/*.vhdl
#COMMON_VHDL_FILES = $(COMMONFILES_PATH)/*.vhdl

# build options
GHDL_BUILD_OPTS = #--std=02
DC_BUILD_OPTS = 
VCS_BUILD_OPTS = -vhdl08
QUESTA_BUILD_OPTS = -2008

# Simulation break condition
GHDL_SIM_OPTS    = --assert-level=error
#GHDL_SIM_OPTS    = --stop-time=5us		#500ns

# Workspaces
#SIM_PATH = $(ROOT_PATH)/simulation/ghdl
#SYNTH_PATH = $(ROOT_PATH)/synthesis/vivado
#SYNTH_PATH = $(ROOT_PATH)/synthesis/dc
SIM_PATH = $(ROOT_PATH)/simulation
SYNTH_PATH = $(ROOT_PATH)/synthesis

# testbench
TARGET = tb_fir
#SIMFILES = testbench/led_top_tb.vhd

#LIBS = -Pcommon
LIBS = -P$(SRC_PATH)/common
#GHDL_FLAGS      = --ieee=synopsys --warn-no-vital-generic

build-model:
	#sage ...
	#gcc ...

# TODO automatically check if tool exists before running commands.
simulate:
	#make clean-sim;
	
	#echo $(date "+[%Y-%m-%d %H:%M:%S]: Compiling project...");
	
	## Build the sources for simulation.
	## with GHDL:
	#cd $(SIM_PATH)/ghdl; \
	#	mkdir -p ./work ./tauhop ./osvvm;
	#
	#cd $(SIM_PATH)/ghdl; \
	#	ghdl $(GHDL_BUILD_OPTS) -i $(LIBS) --workdir=$(COMMONFILES_PATH) --work=common $(COMMON_FILES);
	#
	#cd $(SIM_PATH)/ghdl; \
	#	ghdl $(GHDL_BUILD_OPTS) -i $(LIBS) --workdir=$(SIM_PATH) --work=work $(FILES);
	#
	#cd $(SIM_PATH)/ghdl; \
	#	ghdl -m $(LIBS) --workdir=$(SIM_PATH) --work=work $(TARGET);
	## [end] build with GHDL.
	
	
	
	## with VCS:
	#cd $(SIM_PATH)/vcs-mx; \
	#	mkdir -p ./work ./tauhop ./osvvm;
	#
	#cd $(SIM_PATH)/vcs-mx; \
	#	vhdlan $(VCS_BUILD_OPTS) -work tauhop \
	#		$(VHDL_SRC_PATH)/packages/tauhop/pkg-tlm.vhdl \
	#		$(VHDL_SRC_PATH)/packages/tauhop/pkg-dsp.vhdl \
	#		| tee -ai $(SIM_PATH)/simulate.log;
	#
	#cd $(SIM_PATH)/vcs-mx; \
	#	vhdlan $(VCS_BUILD_OPTS) -work work \
	#		$(VHDL_SRC_PATH)/fir.vhdl \
	#		$(VHDL_TB_PATH)/tb_fir.vhdl \
	#		| tee -ai ./simulate.log;
	## [end] build with VCS.
	
	
	
	
	# with Questa / Modelsim:
	echo "$(date): Compiling project..." | tee -i $(SIM_PATH)/questa/simulate.log;
	make clean-sim | tee -ai $(SIM_PATH)/questa/simulate.log;
	
	cd $(SIM_PATH)/questa; \
		mkdir -p ./work ./osvvm ./tauhop \
		| tee -ai $(SIM_PATH)/questa/simulate.log;
	
	cd $(SIM_PATH)/questa; \
		vlib work; vmap ./work work | tee -ai $(SIM_PATH)/questa/simulate.log; \
		vlib osvvm; vmap ./osvvm osvvm | tee -ai $(SIM_PATH)/questa/simulate.log; \
		vlib tauhop; vmap ./tauhop tauhop | tee -ai $(SIM_PATH)/questa/simulate.log;
	
	cd $(SIM_PATH)/questa; \
		vcom $(QUESTA_BUILD_OPTS) -work tauhop \
			$(VHDL_SRC_PATH)/packages/pkg-tlm.vhdl \
			$(VHDL_SRC_PATH)/packages/pkg-dsp.vhdl \
			| tee -ai $(SIM_PATH)/questa/simulate.log;
	
	cd $(SIM_PATH)/questa; \
		vcom $(QUESTA_BUILD_OPTS) -work work \
			$(VHDL_SRC_PATH)/fir.vhdl \
			$(VHDL_TB_PATH)/tb_fir.vhdl \
			| tee -ai $(SIM_PATH)/questa/simulate.log;
	# [end] build with Questa / Modelsim.
	
	
	
	# Run the simulation and store the results.
	## with GHDL:
	##ghdl -r $(TARGET)
	#@$(SIM_PATH)/$(TARGET) $(GHDL_SIM_OPTS) --vcdgz=$(SIM_PATH)/$(TARGET).vcdgz &
	##@$(SRC_PATH)/$(TARGET) $(GHDL_SIM_OPTS) --wave=$(SIM_PATH)/$(TARGET).ghw &
	#
	## View the results with a waveform viewer.
	## View with GTKWAVE (for GHDL)
	#gzip --decompress --stdout $(SIM_PATH)/$(TARGET).vcdgz | gtkwave --vcd $(SIM_PATH)/$(TARGET).gtkwave.sav &
	##gtkwave $(SIM_PATH)/$(TARGET).ghw $(SRC_PATH)/$(TARGET).gtkwave.gtkw &
	## [end] simulate with GHDL.
	
	
	## with VCS:
	## Pass the simulation path into script.
	#$(SIM_PATH)/simulate.sh `echo $(SIM_PATH)`;
	## [end] simulate with VCS.
	
	
	# with Questa / Modelsim:
	# Pass the simulation path into script.
	cd $(SIM_PATH)/questa; \
		$(SIM_PATH)/questa/simulate.sh `echo $(SIM_PATH)/questa` \
			| tee -ai $(SIM_PATH)/questa/simulate.log;
	# [end] simulate with Questa / Modelsim.
	
	
	
	
synthesise:
	make clean-synth;
	
	echo $(date);
	
	# with Design Compiler
	#dc_shell -f $(SYNTH_PATH)/dc/synthesise.f \
	#	2>&1 \
	#	| tee -i $(SYNTH_PATH)/dc/synthesise.log;
	
	$(SYNTH_PATH)/quartus/synthesise.sh `echo $(SYNTH_PATH)/quartus` \
		| tee -ai $(SYNTH_PATH)/quartus/synthesise.log;
	
	
ghdl-clean:
	ghdl --clean --workdir=$(SIM_PATH)
	
clean-sim:
	rm -rf \
		$(SIM_PATH)/questa/modelsim.ini \
		$(SIM_PATH)/questa/transcript \
		$(SIM_PATH)/questa/vsim.wlf \
		$(SIM_PATH)/questa/work \
		$(SIM_PATH)/questa/altera \
		$(SIM_PATH)/questa/osvvm \
		$(SIM_PATH)/questa/tauhop;
		#./simv* \
		#$(SIM_PATH)/vcs-mx/simv* \
		#$(SIM_PATH)/vcs-mx/64 \
		#$(SIM_PATH)/vcs-mx/simulate.log \
		#$(SIM_PATH)/vcs-mx/work \
		#$(SIM_PATH)/vcs-mx/osvvm \
		#$(SIM_PATH)/vcs-mx/tauhop;
		
	#echo $(date "+[%Y-%m-%d %H:%M:%S]: Remove successful.");
	echo "$(date): Remove successful.";
	
clean-synth:
	rm -rf \
		$(SYNTH_PATH)/dc/command.log \
		$(SYNTH_PATH)/dc/default.svf;
	
	echo $(date "+[%Y-%m-%d %H:%M:%S]: Remove successful.");
