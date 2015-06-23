# Copyright (C) 1991-2012 Altera Corporation
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
# File: mesi_isc.tcl
# Generated on: Tue Dec 25 13:58:34 2012

# Load Quartus II Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "mesi_isc"]} {
		puts "Project mesi_isc is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists mesi_isc]} {
		project_open -revision mesi_isc mesi_isc
	} else {
		project_new -revision mesi_isc mesi_isc
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone IV GX"
	set_global_assignment -name DEVICE auto
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION "12.0 SP2"
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "09:58:58  NOVEMBER 06, 2012"
	set_global_assignment -name LAST_QUARTUS_VERSION "12.0 SP2"
	set_global_assignment -name VERILOG_FILE ../src/rtl/mesi_isc_define.v
	set_global_assignment -name VERILOG_FILE ../src/rtl/mesi_isc_broad_cntl.v
	set_global_assignment -name VERILOG_FILE ../src/rtl/mesi_isc_broad.v
	set_global_assignment -name VERILOG_FILE ../src/rtl/mesi_isc_breq_fifos_cntl.v
	set_global_assignment -name VERILOG_FILE ../src/rtl/mesi_isc_breq_fifos.v
	set_global_assignment -name VERILOG_FILE ../src/rtl/mesi_isc_basic_fifo.v
	set_global_assignment -name VERILOG_FILE ../src/rtl/mesi_isc.v
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
