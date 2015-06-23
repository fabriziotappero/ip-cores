# Copyright (C) 1991-2009 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Quartus II: Generate Tcl File for Project
# File: openMSP430_fpga.tcl
# Generated on: Tue Jan 19 23:11:05 2010

# Load Quartus II Tcl packages
package require ::quartus::project
package require ::quartus::flow


# Create project
project_new -revision openMSP430_fpga openMSP430_fpga


# Make assignments
set_global_assignment -name DEVICE <DEVICE_NAME>
set_global_assignment -name FAMILY "<DEVICE_FAMILY>"

set_global_assignment -name VERILOG_FILE ..\\design_files.v
set_global_assignment -name SEARCH_PATH ..\\src/

set_global_assignment -name FMAX_REQUIREMENT "240 MHz" -section_id main_clock
set_instance_assignment -name CLOCK_SETTINGS main_clock -to dco_clk

set_global_assignment -name OPTIMIZATION_TECHNIQUE           <SPEED_AREA>
set_global_assignment -name CYCLONEII_OPTIMIZATION_TECHNIQUE <SPEED_AREA>
set_global_assignment -name STRATIX_OPTIMIZATION_TECHNIQUE   <SPEED_AREA>
set_global_assignment -name STRATIXII_OPTIMIZATION_TECHNIQUE <SPEED_AREA>
set_global_assignment -name SYNTH_TIMING_DRIVEN_SYNTHESIS ON

set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
set_global_assignment -name RESERVE_ASDO_AFTER_CONFIGURATION "AS INPUT TRI-STATED"
set_global_assignment -name RESERVE_ALL_UNUSED_PINS_NO_OUTPUT_GND "AS INPUT TRI-STATED"
set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
set_global_assignment -name CDF_FILE Chain1.cdf
set_global_assignment -name LL_ROOT_REGION ON -section_id "Root Region"
set_global_assignment -name LL_MEMBER_STATE LOCKED -section_id "Root Region"


set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85

set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"


set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

# Commit assignments
export_assignments

# Run synthesis
execute_flow -compile
