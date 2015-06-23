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
# File: g729a_selftest_syn.tcl
# Generated on: Sat Nov 02 09:44:58 2013

# Load Quartus II Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "g729a_selftest_syn"]} {
		puts "Project g729a_selftest_syn is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists g729a_selftest_syn]} {
		project_open -revision g729a_syn g729a_selftest_syn
	} else {
		project_new -revision g729a_syn g729a_selftest_syn
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone III"
	set_global_assignment -name DEVICE EP3C25F324C8
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 9.1
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "22:32:18  OCTOBER 15, 2013"
	set_global_assignment -name LAST_QUARTUS_VERSION 9.1
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (VHDL)"
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
	set_global_assignment -name USE_GENERATED_PHYSICAL_CONSTRAINTS OFF -section_id eda_blast_fpga
	set_global_assignment -name CYCLONEII_OPTIMIZATION_TECHNIQUE SPEED
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name NOMINAL_CORE_SUPPLY_VOLTAGE 1.2V
	set_global_assignment -name LL_ROOT_REGION ON -section_id "Root Region"
	set_global_assignment -name LL_MEMBER_STATE LOCKED -section_id "Root Region"
	set_global_assignment -name MISC_FILE "g729a_syn.dpf"
	set_global_assignment -name TIMEQUEST_MULTICORNER_ANALYSIS ON
	set_global_assignment -name TIMEQUEST_DO_CCPP_REMOVAL ON
	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "2.5 V"
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name ENABLE_DEVICE_WIDE_RESET ON
	set_global_assignment -name USE_CONFIGURATION_DEVICE OFF
	set_global_assignment -name VHDL_FILE G729A_codec_selftest.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_roms_mif.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_adder_f.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_addsub_pipeb.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_arith_pkg.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_basic_pkg.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_bjxlog.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_cfg_pkg.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_cpu_2w_p6.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_ftchlog_2w.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_fwdlog_2w_p6.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_idec.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_idec_2w.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_idec_2w_pkg.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_idec_pkg.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_ifq.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_lcstk.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_lcstklog_2w.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_lcstklog_ix.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_logic.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_lsu.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_lu.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_mulu_pipeb.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_op_pkg.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_pipe_a_2w.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_pipe_b.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_pkg.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_pstllog_2w_p6.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_pxlog.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_rams.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_regfile_16x16_2w.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_shftu.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_spc.vhd
	set_global_assignment -name VHDL_FILE G729A_asip_top_2w.vhd
	set_global_assignment -name VHDL_FILE G729A_codec_intf_pkg.vhd
	set_global_assignment -name VHDL_FILE G729A_codec_sdp.vhd
	set_global_assignment -name SDC_FILE ext_clk.sdc
	set_global_assignment -name BDF_FILE g729a_syn.bdf
	set_global_assignment -name SEARCH_PATH ../../vhdl
	set_global_assignment -name SEARCH_PATH western/
	set_global_assignment -name SEARCH_PATH tcl/
	set_global_assignment -name SEARCH_PATH hdlc/code/
	set_location_assignment PIN_V9 -to 50MHZ
	set_location_assignment PIN_N2 -to CPU_RESET_N
	set_location_assignment PIN_P13 -to LED0
	set_location_assignment PIN_P12 -to LED1
	set_location_assignment PIN_N12 -to LED2
	set_location_assignment PIN_N9 -to LED3
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
