



proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "plb2wb_bridge" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" "C_STATUS_BASEADDR" "C_STATUS_HIGHADDR" "WB_PIC_INTS"
 xdefine_config_file  $drv_handle "plb2wb_bridge_g.c" "PLB2WB_Bridge"  "C_BASEADDR" "C_STATUS_BASEADDR" "DEVICE_ID"  


}




