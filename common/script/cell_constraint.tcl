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
# Disable the timing loops in asynchronous cells
# currently using the Nangate 45nm cell lib.
# 
# History:
# 03/07/2009  Initial version. <wsong83@gmail.com>
# 27/05/2011  Change to the Nangate cell library. <wsong83@gmail.com>

set_dont_touch mutex2
set_dont_touch delay
# It is not a problem if there is no delay cells in the design.

uniquify -force

# C-gates on control path
foreach_in_collection celln  [get_references -hierarchical c2_*] {
    set_disable_timing [get_object_name $celln]/U2 -from B -to Z
    set_disable_timing [get_object_name $celln]/U3 -from B -to Z
}

# C-gates on data path, feedback and data input are disabled from timing analysis
foreach_in_collection celln  [get_references -hierarchical dc2_*] {
    set_disable_timing [get_object_name $celln]/U1 -from B -to Z 
    set_disable_timing [get_object_name $celln]/U2 -from A -to Z
    set_disable_timing [get_object_name $celln]/U2 -from B -to Z
    set_disable_timing [get_object_name $celln]/U3 -from B -to Z
}

# c2n gates
foreach_in_collection celln  [get_references -hierarchical c2n_*] {
    set_disable_timing [get_object_name $celln]/U1 -from B -to Z
}
# It is not a problem if there is no c2n cells in the design.

# c2p gates
foreach_in_collection celln  [get_references -hierarchical c2p_*] {
    set_disable_timing [get_object_name $celln]/U1 -from B -to Z
}
# It is not a problem if there is no c2p cells in the design.

# mutex gates
foreach_in_collection celln  [get_references -hierarchical mutex2_*] {
    set_disable_timing [get_object_name $celln]/U1 -from A2 -to ZN
    set_disable_timing [get_object_name $celln]/U4 -from A2 -to ZN
    set_dont_touch [get_object_name $celln]/U2
    set_dont_touch [get_object_name $celln]/U3
}

# c2p1 gates
foreach_in_collection celln  [get_references -hierarchical c2p1_*] {
    set_disable_timing [get_object_name $celln]/U2 -from B -to Z
    set_disable_timing [get_object_name $celln]/U3 -from B -to Z
}
# It is not a problem if MRMA is not used in the design.

# tarb
foreach_in_collection celln  [get_references -hierarchical tarb_*] {
    set_disable_timing [get_object_name $celln]/U2 -from A -to Z                
    set_disable_timing [get_object_name $celln]/U3 -from A -to Z                
}                                                                   
# It is not a problem if tree arbiter is not used in the design.

# cr_blk
foreach_in_collection celln  [get_references -hierarchical cr_blk_*] {
    set_disable_timing [get_object_name $celln]/XG/U1 -from C -to Z                               
}                                                                   
# It is not a problem if MRMA is not used in the design.

# mrma multi-resource match arbiter
foreach_in_collection celln  [get_references -hierarchical mrma_*] {
    set_disable_timing [get_object_name $celln]/*.AND_*G* -from B -to Z
    set_disable_timing [get_object_name $celln]/*.AND_RG* -from A -to Z
}                                                                   
# It is not a problem if MRMA is not used in the design.

# dcb data crossbar
foreach_in_collection celln  [get_references -hierarchical dcb_*] {
    set_disable_timing [get_object_name $celln]/*.A* -from B -to Z                               
}                                                                   

# dcb data crossbar
foreach_in_collection celln  [get_references -hierarchical rcb_*] {
    set_disable_timing [get_object_name $celln]/*.A* -from B -to Z                               
}                                                                   
#It is not a problem if there is no rcb modules in the design.

# mnmr m-n match allocator
foreach_in_collection celln  [get_references -hierarchical mnma_*] {
    set_disable_timing [get_object_name $celln]/*.AND_OPRen* -from B -to Z                               
}                                                                   
#It is not a problem if MNMA is not used in the design.
