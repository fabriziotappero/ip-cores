
set project_name DE2
set top_level    DE2
set sdc_constraints constraints.sdc

# create a new project
project -new ${project_name}

# add coregen related files, if present
if {[file exists coregen.tcl]} {
  source coregen.tcl
}

# add verilog files
# top level design must be last

set mcsfiles [glob -directory ../../macrocells -nocomplain -tails -types f -- {*.v}]
foreach mcs ${mcsfiles} {
  if [ regexp -- {assertions} ${mcs} ] {
     continue
  }
  add_file -verilog "../../macrocells/${mcs}"
}

set rtlfiles [glob -directory ../../rtl -nocomplain -tails -types f -- {*.v}]
foreach rtl ${rtlfiles} {
  if [ regexp -- {assertions} ${rtl} ] {
     continue
  }
  add_file -verilog "../../rtl/${rtl}"
}
#set_global_assignment -name VERILOG_FILE ../../../../rtl_package/simu_stubs/vsim/bram_based_stream_buffer.v
set sp6files [glob -directory  ../../../../SP6/ -nocomplain -tails -types f -- {*\.vhd}]
foreach mcs ${sp6files} {
 if [ regexp -- {assertions} ${mcs} ] {
    continue
}
  add_file -vhdl "../../../../SP6/${mcs}"
}
#DE2 files
set sp6files [glob -directory  ../../../../SP6/ -nocomplain -tails -types f -- {*\.v}]
foreach mcs ${sp6files} {
 if [ regexp -- {assertions} ${mcs} ] {
    continue
}
  add_file -verilog "../../../../SP6/${mcs}"
}

# setting options and constraints

set_option -top_module ${top_level}
add_file "${sdc_constraints}"
set_option -technology spartan6
set_option -part xc6slx45t
set_option -package fgg484
set_option -speed_grade -3

#compilation/mapping options
set_option -default_enum_encoding onehot
set_option -symbolic_fsm_compiler 1
set_option -resource_sharing 1
set_option -use_fsm_explorer 0

#map options
set_option -frequency 20
set_option -run_prop_extract 1

#Not setting the fanout limit. 
#Synplify to pick up appropriate fanout
#set_option -fanout_limit 10000

set_option -disable_io_insertion 0
set_option -pipe 1
set_option -update_models_cp 0
set_option -verification_mode 0
set_option -modular 0
set_option -retiming 0
set_option -no_sequential_opt 0
set_option -fixgatedclocks 0

#simulation options
set_option -write_verilog 1
set_option -write_vhdl 0
#VIF options
set_option -write_vif 1

#automatic place and route (vendor) options
set_option -write_apr_constraint 1

project -result_file run/synthesis/${top_level}.edf

#implementation attributes
set_option -vlog_std v2001
set_option -synthesis_onoff_pragma 0
set_option -project_relative_includes 1

# compile the design
project -run
project -save
