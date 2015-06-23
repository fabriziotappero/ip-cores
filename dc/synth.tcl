#=========================================================================
# TCL Script File for Synthesis using Synopsys Design Compiler
#-------------------------------------------------------------------------
# $Id: synth.tcl,v 1.3 2008-06-26 18:12:15 jamey.hicks Exp $
# 

# The makefile will generate various variables which we now read in
# and then display

source make_generated_vars.tcl
echo ${SEARCH_PATH}
echo ${DONT_TOUCH}
echo ${VERILOG_SRCS}
echo ${VERILOG_TOPLEVEL}

# The library setup is kept in a separate tcl file which we now source

source libs.tcl

# Set some options

set_ultra_optimization
set synlib_enable_dpgen true
set synlib_prefer_ultra_license true
set compile_new_boolean_structure true

# These two commands read in your verilog source

analyze -library WORK -format verilog ${VERILOG_SRCS}
elaborate ${VERILOG_TOPLEVEL} -architecture verilog -library WORK

# This command will check your design for any errors

check_design > synth_check_design.rpt

# We use set_dont_touch to prevent dc from optimizing some blocks

if {${DONT_TOUCH} != ""} {
  set_dont_touch ${DONT_TOUCH}
}

# We now load in the constraints file

source synth.sdc

# This actually does the synthesis. The map_effort and area_effort are
# how much time the synthesizer should spend optimizing your design to
# gates. Setting them to high means synthesis will take longer but will
# probably produce better results. The boundary_optimization means that
# the synthesizer is free to invert ports if it will increase performance.

link
set_flatten true -effort high
compile -map_effort high -area_effort high -boundary_optimization 
#compile_ultra

# We write out the results as a verilog netlist and in ddc format

write -format verilog -hierarchy -output synthesized.v
write -format ddc -hierarchy -output synthesized.ddc

# We create a timing report for the worst case timing path 
# and an area report for each reference in the heirachy

report_timing -capacitance -transition_time -nosplit -nworst 10 -max_paths 500 > synth_timing.rpt
report_reference -nosplit > synth_area.rpt
report_resources -nosplit > synth_resources.rpt
report_power     -nosplit -hier > synth_power.rpt

set cells [get_cells -hierarchical -filter "is_hierarchical == true"]
set zcells [sort_collection $cells { full_name }]
foreach_in_collection eachcell $zcells {
  current_instance $eachcell
  report_reference -nosplit >> synth_area.rpt
  report_resources -nosplit >> synth_resources.rpt
}

exit
