# $Id:  $  From Russia with love
# synplify -enable64bit -batch synplify.tcl

####################################################################
#    This file is part of the GOST 28147-89 CryptoCore project     #
#                                                                  #
#    Copyright (c) 2014 Dmitry Murzinov (kakstattakim@gmail.com)   # 
####################################################################


######## generic synthesis procedures for Synplif FPGA-Compiler ########



#add_file options
add_file -verilog -vlog_std sysv ../../rtl/verilog/gost28147-89.sv

#implementation: "xilinx"
impl -add xilinx -type fpga

#device options
set_option -technology  SPARTAN3E
set_option -part        XC3S100E
set_option -package     VQ100
set_option -speed_grade -4
set_option -part_companion ""

#compilation/mapping options
set_option -top_module "gost_28147_89"
set_option -vlog_std sysv
set_option -project_relative_includes 1
set_option -enable64bit 1              
set_option -hdl_define -set GOST_R_3411_TESTPARAM
set_option -include_path "../../rtl/verilog"
set_option -default_enum_encoding default
set_option -resource_sharing 1
set_option -use_fsm_explorer 0
set_option -compiler_compatible 0
set_option -multi_file_compilation_unit 1


#map options
set_option -frequency 100.000
#set_option -frequency auto
set_option -vendor_xcompatible_mode 0
set_option -run_prop_extract 1
set_option -fanout_limit 10000
set_option -disable_io_insertion 1
set_option -pipe 1
set_option -update_models_cp 0
set_option -verification_mode 0
set_option -retiming 1
set_option -no_sequential_opt 0
set_option -fixgatedclocks 3
set_option -fixgeneratedclocks 3
set_option -num_critical_paths 10
set_option -num_startend_points 10
set_option -dup 0
set_option -symbolic_fsm_compiler 1

#simulation options
set_option -write_verilog 1
set_option -write_vhdl 0

#VIF options
set_option -write_vif 0

#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#set result format/file last
project -result_file "../out/gost28147.edf"

impl -active "xilinx"

run
