# Asynchronous SDM NoC
# (C)2011 Wei Song
# Advanced Processor Technologies Group
# Computer Science, the Univ. of Manchester, UK
# 
# Authors: 
# Wei Song     wsong83@gmail.com
# 
# License: LGPL 3.0 or later
# 
# Synthesis script
# currently using the Nangate 45nm cell lib.
# 
# History:
# 31/05/2009  Initial version. <wsong83@gmail.com>

set rm_top router
set rm_para "VCN=>2, DW=>8, PD=>1"

# working directory
if {[file exists work ] && [file isdirectory work ]} {
    file delete -force work
}
file mkdir work
define_design_lib work -path work

if {![file exists file ]} {
    file mkdir file
}

# set the technology libraries
source ../../common/script/tech.tcl

# read in source codes
source script/source.tcl

# elaborate the design
elaborate ${rm_top} -parameters ${rm_para}
rename_design ${current_design} router

link

check_design

# read in constraints
echo "It will be many errors in this step. Normally they are fine. For further info. please read the comments in the constraint scripts."
source script/constraint.tcl

link

#report loops
report_timing -loops -max_paths 2

compile -boundary_optimization


define_name_rules verilog -allowed "A-Za-z0-9_" -first_restricted "\\"
change_name -rules verilog -hierarchy

write -format verilog -hierarchy -out file/${current_design}_syn.v $current_design
write_sdf -significant_digits 5 file/${current_design}.sdf

report_constraints -verbose

report_constraints
report_area
exit
