##############################################################################
## Filename:          /drivers/tosnet_v3_20_a/data/tosnet_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Tue Aug 03 15:28:52 2010 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "tosnet" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" "C_MEM0_BASEADDR" "C_MEM0_HIGHADDR" 
}
