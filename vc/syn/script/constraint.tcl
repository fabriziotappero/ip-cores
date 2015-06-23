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
# Constraints for wormhole/SDM routers
# 
# History:
# 26/05/2011  Initial version. <wsong83@gmail.com>

# loading the baic cell constraints
source ../../common/script/cell_constraint.tcl

# ensure the basic blocks are not ungrouped for better debugging capability
set_ungroup [get_references -hierarchical inp_buf*]  false
set_ungroup [get_references -hierarchical outp_buf*] false
set_ungroup CB false
set_ungroup ALLOC false


######### break the timing loops in the design ##############

# the cross points in the VCA
foreach_in_collection celln  [get_references -hierarchical RCBB_*] {
    set_disable_timing [get_object_name $celln]/I1 -from B -to Z
    set_disable_timing [get_object_name $celln]/I0/U1 -from B -to Z
    set_disable_timing [get_object_name $celln]/I0/U3 -from A -to Z
    set_disable_timing [get_object_name $celln]/I3/U1 -from A -to Z
    set_disable_timing [get_object_name $celln]/I3/U2 -from A -to Z

}                                                                   

set_disable_timing [get_cells ALLOC/*VCAO*] -from A -to Z

# set some timing path ending points
set DPD []
set DPA []
foreach_in_collection celln  [get_references -hierarchical dc2_*] {
    append_to_collection DPD [ get_pins [get_object_name $celln]/U1/B]
    append_to_collection DPD [ get_pins [get_object_name $celln]/U2/A]
    append_to_collection DPA [ get_pins [get_object_name $celln]/U1/A]
    append_to_collection DPA [ get_pins [get_object_name $celln]/U3/A]
}

set IODI [filter [get_ports *i*] "@port_direction == in"]
set IODO [filter [get_ports *o*] "@port_direction == out"]
set IOAI [filter [get_ports *i*] "@port_direction == out"]
set IOAO [filter [get_ports *o*] "@port_direction == in"]

# set the timing constraints for data paths and ack paths
# For better speed performance, please tune these delay and factors according different cell libraries
set DATA_dly 1.0
set ACK_dly 1.6

set_max_delay [expr ${DATA_dly} * 1.00] -from ${DPA}   -to ${DPD}   -group G_DATA
set_max_delay [expr ${ACK_dly} * 1.00]  -from ${DPA}   -to ${DPA}   -group G_ACK
set_max_delay [expr ${DATA_dly} * 0.30] -from ${IODI}  -to ${DPD}   -group G_DATA
set_max_delay [expr ${ACK_dly} * 0.75]  -from ${DPA}   -to ${IOAI}  -group G_ACK
set_max_delay [expr ${DATA_dly} * 0.70] -from ${DPA}   -to ${IODO}  -group G_DATA
set_max_delay [expr ${ACK_dly} * 0.25]  -from ${IOAO}  -to ${DPA}   -group G_ACK

group_path -weight 1.5 -critical_range 40 -name G_DATA
group_path -weight 1.5 -critical_range 40 -name G_ACK

set_critical_range 20 ${current_design}

set_max_leakage_power 0.0
set_max_dynamic_power 0.0
set_max_area 0

# timing path disabled by user constraints
suppress_message TIM-175
