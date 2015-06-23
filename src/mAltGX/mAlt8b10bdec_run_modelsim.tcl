#!/usr/bin/env tcl
######################################################################
#
# Synopsis:
# tcl run_modelsim.tcl [-option value]* (Unix Systems)
# vish run_modelsim.tcl [-option value]* (Any Command Line)
# do run_modelsim.tcl [-option value]* (Modelsim GUI)
#
# Options:
#   -gate <device_family>
#     Forces Script to run Gate Level Simulation with <device_family>
#     Simulation Model must have been compiled using quartus_eda
#   -tbfile <testbench[.v|.vhd]>
#     Specifies Testbench File Name
#   -tbmod <testbench_module_name>
#     Specifies Testbench Module Name
#   -simfile <simulation_model[.vo|.vho]>
#     Specifies IP Functional Simulation Model File Name
#
# Usage:
# *The Filename for this script must be have a .tcl extension
#  To run a testbench specify the testbench file, the simulation
#  model file (.vo or .vho), and the testbench module name.
#  This can be done by either editing the DEFAULTS SECTION given 
#  below or by means of command line arguments.
# *This script uses the file name of the simulation model to determine
#  whether to run either a verilog (.vo) or vhdl (.vho) simulation.
#  If there are additional Verilog or VHDL files that need to be
#  compiled they can be specified under their respective lists in the
#  DEFAULTS SECTION (Reminder: you can use '\' for line continuation)
# *The script defaults to running simgen simulations.
#  To run a Gate Level Simulation you must use the '-gate' option.
#  Libraries for the respective device families must be supplied
#  in the QUARTUS LIBRARIES SECTION (See Below).
#
# Prerequisistes:
# This script is assumes that the user successfully ran IPToolBench
# and has all the necessary files (.vo, .iv. etc.) in the folder
# In the case of a Gate Level Simulation the '.vo'/'.vho' file must
# have been previously compiled using quartus_eda and the device family
# specified by '-gate' should match the device family with which the 
# Simulation Model was compiled with.  A version of Modelsim compatible
# with the simulation file must also be available and the path to the 
# Modelsim commands must be included in the PATH environment variable.
# Ideally you should run this script using 'vish' in the command line. 
# The script can also be executed using the Modelsim GUI using  
# 'do run_modelsim.tcl'.  You cannot execute the script if 
# QUARTUS_ROOTDIR Environment Variable is not set to a valid
# Quartus II Installation.
# 
# Simulator Output:
# run_modelsim.log
#
# Device Family Libraries supported in Current Version:
# stratix, stratixii, stratixgx, stratixiigx, cyclone, cycloneii,
# apexii, apex20ke, apex20kc, cycloneii, hardcopyii
#
########################################################################

########################################################################
# DEFAULTS SECTION                                                     #
########################################################################
# Edit these Variables to match your required Testbench Settings       #

# Default Device Family
# e.g. "stratixii"
set def_device_fam "stingray"
# Default Testbench File
# e.g. "rio_c_8_32_4_tb.v"
set def_test_bench "mAlt8b10bdec_tb.v"
# Default Model Language
# e.g. "verilog"
set def_model_lang "verilog"
# Default Simgen/Gate Level Model Filename
# e.g. rio_c_8_32_4.vo or rio_c_8_32_4.vho
set def_model_file "mAlt8b10bdec.vo"
# Default Testbench Modelsim Module
# Usually this is set to 'tb' or something like 'slite_tb'
set def_model_tb "tb"
# List of Additional Verilog Files to be Compiled
# e.g. {sii_clk_gen.v sii_av_master.v sii_reset.v}
set add_verilog_files {}
# List of Additional VHDL Files to be Compiled
# e.g. {sii_clk_gen.vhd sii_clk_gen_components.vhd}
set add_vhdl_files {}

if {[catch {vsim -version} ]} {
 set shell 1
} else {
 set shell 0
}

# Procedure to display Info Messages
proc myinfo { args } {
  global shell
  foreach mesg $args {
    if {$shell} {
      puts stdout "\# Info: $mesg"
    } else {
      puts "\# Info: $mesg"
    }
  }
}

# Procedure to display Error Messages and exit the script
proc myerror { args } {
  global shell
  foreach mesg $args {
    if {$shell} {
      puts stderr "\# Error: $mesg"
    } else {
      puts "\# Error: $mesg"
    }
  }
  if {$shell} {
    exit
  } else {
    error "Terminating script"
  }
}

# Procedure to run an external command (such as vsim)
proc myexec { args } {
  global shell
  if {$shell} {
    eval "exec $args"
  } else {
    eval $args
  }
}

########################################################################
# END DEFAULTS SECTION                                                 #
########################################################################
# Get Command Line Arguments
# Gate Level Simulation must be specified along with a device family name
if {[info exists device_fam]} {
  unset device_fam 
}
if {[info exists testbench]} {
  unset testbench
}
if {[info exists model_tb]} {
  unset model_tb
}
if {[info exists model_file]} {
  unset model_file
}

foreach arg $argv {
  if {[info exists next_val]} {
    set $next_val $arg
    unset next_val
  } else {
    if {[string match -nocase "-gate" $arg]} {
      set next_val "device_fam";
    } elseif {[string match -nocase "-tbfile" $arg]} {
      set next_val "testbench"
    } elseif {[string match -nocase "-tbmod" $arg]} {
      set next_val "model_tb"
    } elseif {[string match -nocase "-simfile" $arg]} {
      set next_val "model_file"
    } elseif {[string match -nocase "-gui" $arg]} {
      myinfo "Testbench is run in GUI mode"          
    } else {
      myerror "Invalid Argument Specified: $arg\n"
    }
  }
}

if {![info exists device_fam]} {
  set device_fam $def_device_fam
}
if {![info exists testbench]} {
  set testbench $def_test_bench
}
if {![info exists model_tb]} {
  set model_tb $def_model_tb
}
if {![info exists model_file]} {
  set model_file $def_model_file
}

# Check to make sure script is being run in the correct directory
if {![file exists $testbench]} {
  if {[file exists tb.v]} {
    file copy tb.v $testbench
  } else {
    set mesg1 "Testbench File not Found.\n"
    set mesg2 "Please run from the testbench directory\n"
    myerror $mesg1 $mesg2
  }
}

# Identify Simulation Type through Filename  
if {[string match -nocase "*.vo" $model_file]} {
  set model_file [string trimright $model_file "vo"]
  set model_file [string trimright $model_file "."]
  set f_ext ".vo"
  set exec_com "vlog"
  set exec_arg1 "-hazards"
  set exec_arg2 "-work"
} elseif {[string match -nocase "*.vho" $model_file]} {
  set model_file [string trimright $model_file "vho"]
  set model_file [string trimright $model_file "."]
  set f_ext ".vho"
  set exec_com "vcom"
  set exec_arg1 "-93"
  set exec_arg2 "-work"
} else {
  myerror "Unrecognized File Extension for $model_file\n"
}

# Check for presence of IP functional simulation model
if {![file exists ${model_file}${f_ext}]} {
  set mesg1 "Can't find Verilog IP Functional Simulation Model."
  set mesg2 "Make sure it is created before attempting to run this script."
  myerror $mesg1 $mesg2  
}

# Get Location of Quartus Libraries
global env

if {[info exists env(QUARTUS_ROOTDIR)]} {
  set lib_path "$env(QUARTUS_ROOTDIR)/eda/sim_lib/"
} else {
  myerror "Can't find QUARTUS II\n"
}

########################################################################
# QUARTUS LIBRARIES SECTION                                            #
########################################################################
# Edit this section to add support for additional device families      #

# Library Information for Modelsim
# ORDER OF FILES IS IMPORTANT
# $libraries: A list with library names
# $lib_files: A nested list of library files for items in $libraries
#              Files must be located in $QUARTUS_ROOTDIR/eda/sim_libs/
if {$f_ext == ".vo"} {
  # Default Simgen Libraries
  set libraries {lpm altera_mf sgate }
  set lib_files {{220model.v} {altera_mf.v} {sgate.v} }
} else {
  # Default Simgen Libraries
  set libraries {lpm altera_mf sgate }
  set lib_files {{220pack.vhd 220model.vhd } \
    {altera_mf_components.vhd altera_mf.vhd } \
    {sgate_pack.vhd sgate.vhd} }
}

########################################################################
# END QUARTUS LIBRARIES SECTION                                        #
########################################################################

# Remove modelsim.ini
if {[file exists modelsim.ini]} {
  myinfo "Removing modelsim.ini"
  file delete -force modelsim.ini
}

set includ_str ""
# Check if we are running a version of ModelSim Altera Edition
set version [myexec vsim -version]
if {[string match -nocase "*ALTERA*" $version]} {
  # Verilog Libraries have a '_ver' appended
  if {$f_ext == ".vo"} {
    set ver_addon "_ver"
  } else {
    set ver_addon ""
  }
  # Map Precompiled Libraries to current Project
  foreach lib_dir $libraries {
    myinfo "Including Library ${lib_dir}${ver_addon}"
    append includ_str " -L ${lib_dir}${ver_addon}"
  }
} else {
  # If we aren't running an Altera Edition of Modelsim,
  # take information from $libraries and $lib_files
  # to compile the Modelsim libraries for Simulation
  set lib_count 0
  foreach lib_dir $libraries {
    if {[file isdirectory $lib_dir]} {
      myinfo "Cleaning ${lib_dir} Directory"
      file delete -force $lib_dir
    }
    myinfo "Compiling Library ${lib_dir}"
    myexec vlib $lib_dir
    foreach lib_file [lindex $lib_files $lib_count] {
      myexec $exec_com $exec_arg1 $exec_arg2 $lib_dir ${lib_path}${lib_file}
    }
    set lib_count [expr $lib_count+1]
    append includ_str " -L $lib_dir"
  }
}

# Compile Simulation Model
if {[file isdirectory $model_file]} {
  myinfo "Cleaning ${model_file} Directory"
  file delete -force $model_file
}
myinfo "Compiling Model $model_file"
myexec vlib $model_file
myexec $exec_com $exec_arg2 $model_file ${model_file}${f_ext}
append includ_str " -L $model_file"

# Clean work Directory
if {[file isdirectory work]} {
  myinfo "Cleaning work Directory"
  file delete -force work
}
myexec vlib work
myexec vmap work

# Compile Testbench

myinfo "Compiling Testbench $testbench"
if {[string match -nocase "*.v" $testbench]} {
  myexec vlog -hazards -work work $testbench
} elseif {[string match -nocase "*.vhd" $testbench]} {
  vcom -93 -work work $testbench
} else {
  myerror "Unrecognized Testbench File Extension\n"
}

# Compile Extra Files if specified

foreach add_file $add_verilog_files {
  myinfo "Compiling File $add_file"
  myexec vlog $add_file
}

foreach add_file $add_vhdl_files {
  myinfo "Compiling File $add_file"
  myexec vcom $add_file
}

myinfo "Running Testbench"

# Finally we get to Run the Testbench
eval "myexec vsim +nowarnTSCALE +nowarnTFMPC +nowarnTOFD -c $includ_str -l run_modelsim.log -do \"run -all; quit\" $model_tb"

myinfo "Testbench Completed"

# Extract Testbench Exit Status from Log File
if {[catch {open "run_modelsim.log" "r"} log_input]} {
  myerror "Could not Open File run_modelsim.log for reading\n"
} else {
  while {[gets $log_input next_line] >= 0} {
    if {[string match -nocase "*Exit status for testbench*" $next_line]} {
      set next_line [string replace $next_line 0 5]
      myinfo "$next_line"
    }
  }
}

close $log_input

myinfo "Check run_modelsim.log for more Details"

exit
