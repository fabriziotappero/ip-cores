#!/bin/bash
#
#	Example bash script for Mentor Graphics QuestaSim/ModelSim simulation.
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

ROOT_PATH=$PWD
MODEL_SRC_PATH=$ROOT_PATH/../model
VHDL_SRC_PATH=$ROOT_PATH/../hw/vhdl
TB_SRC_PATH=$ROOT_PATH/../hw/tester
#set COMMONFILES_PATH = $SRC_PATH/common

# model files
#set MODEL_FILES = $SRC_PATH/*.sagews $SRC_PATH/*.m $SRC_PATH/*.c

# vhdl files
#VHDL_FILES = $(SRC_PATH)/*.vhdl
#COMMON_VHDL_FILES = $(COMMONFILES_PATH)/*.vhdl

# build options
GHDL_BUILD_OPTS=--std=02 --assert-level=error
QUESTA_BUILD_OPTS=-2008
DC_BUILD_OPTS= 
VCS_BUILD_OPTS=-vhdl08

# Workspaces
GHDL_SIM_PATH=$ROOT_PATH/simulation/ghdl
QUESTA_SIM_PATH=$ROOT_PATH/simulation/questa
VCS_SIM_PATH=$ROOT_PATH/simulation/vcs-mx
VIVADO_SYNTH_PATH=$ROOT_PATH/synthesis/vivado
DC_SYNTH_PATH=$ROOT_PATH/synthesis/dc

isNotExists_vhdlan=`hash vhdlan 2>&1 | grep >&1 "not found"` ;
if [ `echo ${#isNotExists_vhdlan}` -gt 0 ]
then echo "Warning: vhdlan not installed. Skipping compilation for VCS.";
else
	echo "Starting VCS compile..."
	
	cd $VCS_SIM_PATH;
	
	eval 2>&1 "vhdlan $VCS_BUILD_OPTS -work osvvm \
		$(cat ../osvvm.f)" \
		| tee -ai ./simulate.log;
	
	#vcom -2008 -work tauhop $VHDL_SRC_PATH/packages/pkg-types.vhdl \
	eval 2>&1 "vhdlan $VCS_BUILD_OPTS -work tauhop \
		$(cat ../tauhop.f)" \
		| tee -ai ./simulate.log;
		#../../model/vhdl/packages/pkg-resolved.vhdl \
	
	eval 2>&1 "vhdlan $VCS_BUILD_OPTS -work work \
		$(cat ../work.f)" \
		| tee -ai ./simulate.log;
	
	errorStr=`grep "Error-\[" ./simulate.log`;
	if [ `echo ${#errorStr}` -gt 0 ]
	then echo "Errors exist. Refer simulate.log for more details. Exiting."; exit;
	else
		echo $(date "+[%Y-%m-%d %H:%M:%S]: Running simulation...");
		
		#vcs -R -debug_all work.system 2>&1 \
		vcs -debug_all work.system 2>&1 \
			| tee -ai ./simulate.log;
		
		./simv -gui -dve_opt -session=./view-session.tcl -dve_opt -cmd=run 2>&1 \
			| tee -ai ./simulate.log;
		
		echo $(date "+[%Y-%m-%d %H:%M:%S]: simulation loaded.");
	fi
fi

isNotExists_vcom=`hash vcom 2>&1 | grep >&1 "not found"` ;
if [ `echo ${#isNotExists_vcom}` -gt 0 ]
then echo "Warning: vcom not installed. Skipping compilation for Questa/ModelSim.";
else
	echo "Starting Questa/ModelSim compile..."
	
	cd $QUESTA_SIM_PATH;
	
	#read -p "press Enter to run full simulation now, or Ctrl-C to exit: ";
	echo $(date "+[%Y-%m-%d %H:%M:%S]: Removing previously-generated files and folders...");
	rm -rf ./transcript ./simulate.log ./work ./altera ./osvvm ./tauhop;
	echo $(date "+[%Y-%m-%d %H:%M:%S]: Remove successful.");
	
	echo $(date "+[%Y-%m-%d %H:%M:%S]: Compiling project...");
	vlib work; vmap work work;
	vlib tauhop; vmap tauhop tauhop;
	vlib osvvm; vmap osvvm osvvm;
	
	#vcom $QUESTA_BUILD_OPTS -work osvvm 2>&1 \
	#	$VHDL_SRC_PATH/packages/os-vvm/SortListPkg_int.vhd \
	#	$VHDL_SRC_PATH/packages/os-vvm/RandomBasePkg.vhd \
	#	$VHDL_SRC_PATH/packages/os-vvm/RandomPkg.vhd \
	#	$VHDL_SRC_PATH/packages/os-vvm/CoveragePkg.vhd \
	#	| tee -ai ./simulate.log;
	# Pass the simulation path into script.
	eval 2>&1 "vcom $QUESTA_BUILD_OPTS -work osvvm \
		$(cat ../osvvm.f)" \
		| tee -ai ./simulate.log;
	
	#vcom -2008 -work tauhop $VHDL_SRC_PATH/packages/pkg-types.vhdl \
	eval 2>&1 "vcom $QUESTA_BUILD_OPTS -work tauhop \
		$(cat ../tauhop.f)" \
		| tee -ai ./simulate.log;
		#../../model/vhdl/packages/pkg-resolved.vhdl \
	
	eval 2>&1 "vcom $QUESTA_BUILD_OPTS -work work \
		$(cat ../work.f)" \
		| tee -ai ./simulate.log;
	
	errorStr=`grep "\*\* Error: " ./simulate.log`
	if [ `echo ${#errorStr}` -gt 0 ]
	then echo "Errors exist. Refer simulate.log for more details. Exiting."; exit;
	else
		echo $(date "+[%Y-%m-%d %H:%M:%S]: Running simulation...");
		vsim -i -t fs -do ./waves.do -voptargs="+acc" "work.testbench(simulation)" 2>&1 \
			| tee -ai ./simulate.log &
		#vsim -t ps -voptargs="+acc" "tauhop.fifo(rtl)";
		#vsim -t ps -voptargs="+acc" "work.testbench(simulation)";
		echo $(date "+[%Y-%m-%d %H:%M:%S]: simulation loaded.");
	fi
fi
