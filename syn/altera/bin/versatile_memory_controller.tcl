# Usage: 
# cd /versatile_mem_ctrl/trunk/syn/altera/run/
# quartus_sh -t ../bin/versatile_memory_controller.tcl

# Load Quartus II Tcl Project package
package require ::quartus::project

# Add the next line to get the execute_flow command
package require ::quartus::flow

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
   if {[string compare $quartus(project) "versatile_memory_controller"]} {
      puts "Project versatile_memory_controller is not open"
      set make_assignments 0
   }
} else {
   # Only open if not already open
   if {[project_exists versatile_memory_controller]} {
      project_open -revision versatile_mem_ctrl_top versatile_memory_controller
   } else {
      project_new -revision versatile_mem_ctrl_top versatile_memory_controller
   }
   set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
   set_global_assignment -name FAMILY "Stratix III"
   set_global_assignment -name DEVICE AUTO
   set_global_assignment -name ORIGINAL_QUARTUS_VERSION "9.0 SP2"
   set_global_assignment -name PROJECT_CREATION_TIME_DATE "09:18:52  DECEMBER 14, 2009"
   set_global_assignment -name LAST_QUARTUS_VERSION "9.0 SP2"
   set_global_assignment -name USE_GENERATED_PHYSICAL_CONSTRAINTS OFF -section_id eda_blast_fpga
   set_global_assignment -name SEARCH_PATH core_prbs/rtl/
   set_global_assignment -name SEARCH_PATH core_prbs/
   set_global_assignment -name SEARCH_PATH NPU1C_XCVR_reconfig/
   set_global_assignment -name SEARCH_PATH Bacchus_PTP_ALTLVDS_DYN_LINERATE_MULTICHANNEL/
   set_global_assignment -name SEARCH_PATH Bacchus_PTP_ALTLVDS_DYN_LINERATE_MULTICHANNEL/rate_match_fifo/
   set_global_assignment -name SEARCH_PATH Bacchus_PTP_ALTLVDS_DYN_LINERATE_MULTICHANNEL/tx_phase_comp_fifo/
   set_global_assignment -name SEARCH_PATH altera/90/ip/altera/sopc_builder_ip/altera_avalon_clock_adapter/
   set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
   set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
   set_global_assignment -name LL_ROOT_REGION ON -section_id "Root Region"
   set_global_assignment -name LL_MEMBER_STATE LOCKED -section_id "Root Region"
   set_global_assignment -name MISC_FILE /home/mikael/opencores/versatile_mem_ctrl/trunk/syn/altera/run/versatile_mem_ctrl_top.dpf
   set_global_assignment -name SDC_FILE ../bin/versatile_memory_controller.sdc
   set_global_assignment -name VERILOG_FILE ../../../rtl/verilog/versatile_mem_ctrl_ip.v
   set_global_assignment -name EDA_USER_COMPILED_SIMULATION_LIBRARY_DIRECTORY /home/mikael/opencores/versatile_mem_ctrl/trunk/syn/altera/run -section_id eda_simulation
   set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim (Verilog)"
   set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

   # Commit assignments
   export_assignments

   # Compile
   execute_flow -compile


   # Close project
   if {$need_to_close_project} {
      project_close
   }
}
