# Copyright (C) 1991-2014 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, the Altera Quartus II License Agreement,
# the Altera MegaCore Function License Agreement, or other 
# applicable license agreement, including, without limitation, 
# that your use is for the sole purpose of programming logic 
# devices manufactured by Altera and sold by Altera or its 
# authorized distributors.  Please refer to the applicable 
# agreement for further details.

# Quartus II: Generate Tcl File for Project
# File: wiegand_tx_top.tcl
# Generated on: Mon Feb 16 11:00:47 2015

# Load Quartus II Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "wiegand_tx_top"]} {
		puts "Project wiegand_tx_top is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists wiegand_tx_top]} {
		project_open -revision wiegand_tx_top wiegand_tx_top
	} else {
		project_new -revision wiegand_tx_top wiegand_tx_top
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone IV GX"
	set_global_assignment -name DEVICE auto
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 14.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "10:59:20  FEBRUARY 16, 2015"
	set_global_assignment -name LAST_QUARTUS_VERSION 14.0
	set_global_assignment -name VERILOG_FILE ../../../rtl/verilog/wiegand_tx_top.v
	set_global_assignment -name VERILOG_FILE ../../../rtl/verilog/wiegand_defines.v
	set_global_assignment -name VERILOG_FILE ../../../rtl/verilog/wb_interface.v
	set_global_assignment -name VERILOG_FILE ../../../rtl/verilog/fifos.v
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (Verilog)"
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
