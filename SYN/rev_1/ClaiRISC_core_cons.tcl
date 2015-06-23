source "C:/Program Files/Synplicity/fpga_81/lib/altera/quartus_cons.tcl"
syn_create_and_open_prj ClaiRISC_core
source $::quartus(binpath)/prj_asd_import.tcl
syn_create_and_open_csf ClaiRISC_core
syn_handle_cons ClaiRISC_core
syn_compile_quartus
