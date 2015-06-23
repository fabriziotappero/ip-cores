#!/bin/bash

#
# This script runs RTL and gate-level simulation using different simultion tools.
# Right now Cadence Verilog-XL and NCSim are supported.
#
# Author: Damjan Lampret
#

#
# User definitions
#

# Set simulation tool you are using (xl, ncsim, ncver)
SIMTOOL=ncsim

# Set test bench top module(s)
TB_TOP="tb_tasks"

# Set include directories
INCLUDE_DIRS="../../../rtl/verilog/ ../../../bench/verilog/"

# Set test bench files
BENCH_FILES="../../../bench/verilog/*.v"

# Set RTL source files
RTL_FILES="../../../rtl/verilog/*.v"

# Set gate-level netlist files
GATE_FILES="../syn/out/final_ptc.v"

# Set libraries (standard cell etc.)
LIB_FILES="/libs/Virtual_silicon/UMCL18U250D2_2.1/verilog_simulation_models/*.v"

# Set parameters for simulation tool
if [ $SIMTOOL == xl ]; then
	PARAM="+turbo+3 -q"
	for i in $INCLUDE_DIRS; do
		INCDIR=$INCDIR" +incdir+$i"
	done
elif [ $SIMTOOL == ncver ]; then
	NCVER_PARAM=""
	for i in $INCLUDE_DIRS; do
		INCDIR=$INCDIR" +incdir+$i"
	done	
elif [ $SIMTOOL == ncsim ]; then
	NCPREP_PARAM="-UPDATE +overwrite"
	NCSIM_PARAM="-MESSAGES -NOCOPYRIGHT"
	for i in $INCLUDE_DIRS; do
		INCDIR=$INCDIR" +incdir+$i"
	done	
else
	echo "$SIMTOOL is unsupported simulation tool."
	exit 0
fi

#
# Don't change anything below unless you know what you are doing
#

# Run simulation in sim directory
cd ../sim

# Run actual simulation

# Cadence Verilog-XL
if [ $SIMTOOL == xl ]; then

	# RTL simulation
	if [ "$1" == rtl ]; then
		verilog $PARAM $INCDIR $BENCH_FILES $RTL_FILES
	
	# Gate-level simulation
	elif [ "$1" == gate ]; then
		verilog $PARAM $INCDIR $BENCH_FILES $GATE_FILES $LIB_FILES

	# Wrong parameter or no parameter
	else
		echo "Usage: $0 [rtl|gate]"
		exit 0
	fi

# Cadence Ncverilog
elif [ $SIMTOOL == ncver ]; then

	# RTL simulation
	if [ "$1" == rtl ]; then
		ncverilog $NCVER_PARAM $INCDIR $BENCH_FILES $RTL_FILES
		cp ncverilog.log ../log

	# Gate-level simulation
	elif [ "$1" == gate ]; then
		ncverilog $NCVER_PARAM $INCDIR $BENCH_FILES $GATE_FILES $LIB_FILES
		cp ncverilog.log ../log

	# Wrong parameter or no parameter
	else
		echo "Usage: $0 [rtl|gate]"
		exit 0
	fi

# Cadence Ncsim
elif [ $SIMTOOL == ncsim ]; then

	# RTL simulation
	if [ "$1" == rtl ]; then
		ncprep $NCPREP_PARAM $INCDIR $BENCH_FILES $RTL_FILES
		./RUN_NC

	# Gate-level simulation
	elif [ "$1" == gate ]; then
		ncprep $NCPREP_PARAM $INCDIR $BENCH_FILES $GATE_FILES $LIB_FILES
		./RUN_NC

	# Wrong parameter or no parameter
	else
		echo "Usage: $0 [rtl|gate]"
		exit 0
	fi

# Unsupported simulation tool
else
	echo "$SIMTOOL is unsupported simulation tool."
	exit 0;
fi
