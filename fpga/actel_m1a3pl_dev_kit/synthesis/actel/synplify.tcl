


#add_file options
add_file -verilog    "../design_files.v"
add_file -constraint "../design_constraints.pre.sdc"


#implementation: "synplify"
impl -add "synplify" -type fpga

#device options
set_option -technology  <DEVICE_FAMILY>
set_option -part        <DEVICE_NAME>
set_option -package     <DEVICE_PACKAGE>
set_option -speed_grade <SPEED_GRADE>
set_option -part_companion ""

#compilation/mapping options
set_option -default_enum_encoding default
set_option -resource_sharing 1
set_option -use_fsm_explorer 1
set_option -top_module <TOP_LEVEL>

#map options
set_option -frequency 50.0
set_option -vendor_xcompatible_mode 0
set_option -vendor_xcompatible_mode 0
set_option -run_prop_extract 1
set_option -fanout_limit 24
set_option -globalthreshold 50
set_option -maxfan_hard 0
set_option -disable_io_insertion 0
set_option -retiming 1
set_option -report_path 4000
set_option -opcond COMWC
set_option -update_models_cp 0
set_option -preserve_registers 0


#sequential_optimizations options
set_option -symbolic_fsm_compiler 1

#simulation options
set_option -write_verilog 0
set_option -write_vhdl 0

#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#set result format/file last
project -result_format "edif"
project -result_file "./synplify.edn"

#
#implementation attributes

set_option -vlog_std v2001
set_option -dup 0
set_option -project_relative_includes 1
impl -active "synplify"


# Run synthesis
project -run synthesis

# Save and quit
project -save "./synplify.prj"


#exit 0
