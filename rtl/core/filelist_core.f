-sverilog
$TURBO8051_PROJ/rtl/core/core.v
//----------------------------------
// GMAC File List
//---------------------------------
$TURBO8051_PROJ/rtl/gmac/top/g_mac_top.v
$TURBO8051_PROJ/rtl/gmac/mac/dble_reg.v
$TURBO8051_PROJ/rtl/gmac/mac/g_tx_fsm.v
$TURBO8051_PROJ/rtl/gmac/mac/g_deferral.v
$TURBO8051_PROJ/rtl/gmac/mac/g_tx_top.v
$TURBO8051_PROJ/rtl/gmac/mac/g_rx_fsm.v
$TURBO8051_PROJ/rtl/gmac/mac/g_cfg_mgmt.v
$TURBO8051_PROJ/rtl/gmac/mac/s2f_sync.v
$TURBO8051_PROJ/rtl/gmac/mac/g_md_intf.v
$TURBO8051_PROJ/rtl/gmac/mac/g_ad_fltr.v
$TURBO8051_PROJ/rtl/gmac/mac/g_deferral_rx.v
$TURBO8051_PROJ/rtl/gmac/mac/g_rx_top.v 
$TURBO8051_PROJ/rtl/gmac/mac/g_mii_intf.v
$TURBO8051_PROJ/rtl/gmac/mac/g_mac_core.v
$TURBO8051_PROJ/rtl/gmac/crc32/g_rx_crc32.v 
$TURBO8051_PROJ/rtl/gmac/crc32/g_tx_crc32.v
$TURBO8051_PROJ/rtl/lib/async_fifo.v

//-------------------------------------
// SPI File List
//-------------------------------------
$TURBO8051_PROJ/rtl/spi/spi_core.v  
$TURBO8051_PROJ/rtl/spi/spi_ctl.v  
$TURBO8051_PROJ/rtl/spi/spi_if.v
$TURBO8051_PROJ/rtl/spi/spi_cfg.v

//-------------------------------------
// UART File List
//-------------------------------------
$TURBO8051_PROJ/rtl/uart/uart_rxfsm.v  
$TURBO8051_PROJ/rtl/uart/uart_txfsm.v
$TURBO8051_PROJ/rtl/uart/uart_core.v
$TURBO8051_PROJ/rtl/uart/uart_cfg.v


//-------------------------------------
// clkgen File List
//-------------------------------------
$TURBO8051_PROJ/rtl/clkgen/clkgen.v  
$TURBO8051_PROJ/rtl/lib/clk_ctl.v
$TURBO8051_PROJ/rtl/lib/wb_crossbar.v


//------------------------------------
// 8051 core file list
//-----------------------------------
// Source Files
+incdir+$TURBO8051_PROJ/rtl/8051/
$TURBO8051_PROJ/rtl/8051/oc8051_top.v
$TURBO8051_PROJ/rtl/8051/oc8051_alu_src_sel.v
$TURBO8051_PROJ/rtl/8051/oc8051_alu.v
$TURBO8051_PROJ/rtl/8051/oc8051_decoder.v
$TURBO8051_PROJ/rtl/8051/oc8051_divide.v
$TURBO8051_PROJ/rtl/8051/oc8051_multiply.v
$TURBO8051_PROJ/rtl/8051/oc8051_memory_interface.v
$TURBO8051_PROJ/rtl/8051/oc8051_ram_top.v
$TURBO8051_PROJ/rtl/8051/oc8051_acc.v
$TURBO8051_PROJ/rtl/8051/oc8051_comp.v
$TURBO8051_PROJ/rtl/8051/oc8051_sp.v
$TURBO8051_PROJ/rtl/8051/oc8051_dptr.v
$TURBO8051_PROJ/rtl/8051/oc8051_cy_select.v
$TURBO8051_PROJ/rtl/8051/oc8051_psw.v
$TURBO8051_PROJ/rtl/8051/oc8051_indi_addr.v
$TURBO8051_PROJ/rtl/8051/oc8051_ports.v
$TURBO8051_PROJ/rtl/8051/oc8051_b_register.v
$TURBO8051_PROJ/rtl/8051/oc8051_uart.v
$TURBO8051_PROJ/rtl/8051/oc8051_int.v
$TURBO8051_PROJ/rtl/8051/oc8051_tc.v
$TURBO8051_PROJ/rtl/8051/oc8051_tc2.v
//$TURBO8051_PROJ/rtl/8051/oc8051_icache.v
//$TURBO8051_PROJ/rtl/8051/oc8051_wb_iinterface.v
$TURBO8051_PROJ/rtl/8051/oc8051_sfr.v
$TURBO8051_PROJ/rtl/8051/oc8051_ram_256x8_two_bist.v
//$TURBO8051_PROJ/rtl/8051/oc8051_ram_64x32_dual_bist.v

//-------------------------------------
// Altera Library
//------------------------------------
$TURBO8051_PROJ/models/altera/altera_stargate_pll.v
-v /tools/altera/altera9.0/quartus/eda/sim_lib/altera_mf.v


//-------------------------------------
// Common Lib
//-------------------------------------

-v $TURBO8051_PROJ/rtl/lib/registers.v
-v $TURBO8051_PROJ/rtl/lib/stat_counter.v
-v $TURBO8051_PROJ/rtl/lib/toggle_sync.v
-v $TURBO8051_PROJ/rtl/lib/double_sync_low.v
-v $TURBO8051_PROJ/rtl/lib/async_fifo.v

//+lint=all
+v2k
