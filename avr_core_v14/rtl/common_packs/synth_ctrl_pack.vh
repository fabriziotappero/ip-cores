// *****************************************************************************************
// AVR synthesis control package
// Version 2.4 
// Modified 09.06.2012
// Designed by Ruslan Lepetenok
// *****************************************************************************************

// package synth_ctrl_pack is							
	
`ifdef C_SYNTH_CTRL_PACK_VH	
	
	
`else

`define C_SYNTH_CTRL_PACK_VH TRUE
	
// pragma translate_off
// `define c_in_hex_file       : string := "E:\avr_tests\avr_test1.hex"
// pragma translate_on	
	
`define c_synth_on	     1
`define c_pm_size            16
`define c_dm_size            16
`define c_bm_use_ext_tmr     0 
`define c_dm_mst_num         2 
`define c_dm_slv_num         3 
`define c_use_rst            1
`define c_irqs_width         23
`define c_pc22b_core         0 
`define c_io_slv_num        10
`define c_sram_chip_num      1
`define c_impl_synth_core    1
`define c_impl_jtag_ocd_prg  1
`define c_impl_usart         0
`define c_impl_ext_dbg_sys   1
`define c_impl_smb           1
`define c_impl_spi           1
`define c_impl_wdt           1 
`define c_impl_srctrl	     1
`define c_impl_hw_bm 	     0

// c_tech_virtex
//`define c_tech               1
`define c_tech               4    
//`define c_tech               7    


`define c_rst_act_high       0

`define c_old_pm             0

// Added 
`define c_dm_int_sram_read_ws 1

`endif

// end synth_ctrl_pack
