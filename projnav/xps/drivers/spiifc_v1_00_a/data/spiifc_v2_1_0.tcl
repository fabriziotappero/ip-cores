##############################################################################
## Filename:          C:\Users\mjlyons\workspace\vSPI\projnav\xps/drivers/spiifc_v1_00_a/data/spiifc_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Tue Feb 28 11:11:28 2012 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "spiifc" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" "C_MEM0_BASEADDR" "C_MEM0_HIGHADDR" "C_MEM1_BASEADDR" "C_MEM1_HIGHADDR" 
}
