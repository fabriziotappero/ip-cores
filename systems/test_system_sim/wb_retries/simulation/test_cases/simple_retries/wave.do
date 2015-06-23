
set binopt {-logic}
set hexopt {-literal -hex}


eval add wave -noupdate $binopt -label Clock -color SteelBlue        /system_tb/sys_clk
eval add wave -noupdate $binopt -label Reset -color SteelBlue        /system_tb/sys_rst
eval add wave -noupdate $hexopt -label synch_in  -color Yellow        /system_tb/dut/synch_in



eval add wave -noupdate $binopt -label Mn_request  -color DarkGreen  /system_tb/dut/mb_plb/mb_plb/m_request

eval add wave -noupdate $binopt -label Mn_RNW      -color DarkGreen  /system_tb/dut/mb_plb/mb_plb/m_rnw
eval add wave -noupdate $binopt -label Mn_BE       -color DarkGreen  /system_tb/dut/mb_plb/mb_plb/m_be
eval add wave -noupdate $binopt -label Mn_size     -color DarkGreen  /system_tb/dut/mb_plb/mb_plb/m_size
eval add wave -noupdate $binopt -label Mn_type     -color DarkGreen  /system_tb/dut/mb_plb/mb_plb/m_type
eval add wave -noupdate $hexopt -label Mn_ABus     -color DarkGreen  /system_tb/dut/mb_plb/mb_plb/m_abus
eval add wave -noupdate $binopt -label PLB_PAValid -color DarkGreen  /system_tb/dut/mb_plb/mb_plb/plb_pavalid
eval add wave -noupdate $binopt -label PLB_SAValid -color DarkGreen  /system_tb/dut/mb_plb/mb_plb/plb_savalid
eval add wave -noupdate $binopt -label PLB_rdPrim  -color DarkGreen  /system_tb/dut/plb2wb_bridge_0/plb_rdprim 
eval add wave -noupdate $binopt -label PLB_wrPrim  -color DarkGreen  /system_tb/dut/plb2wb_bridge_0/plb_wrprim

eval add wave -noupdate $hexopt -label Sl_rdDBus   -color DarkGreen  /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/sl_rddbus
eval add wave -noupdate $binopt -label Sl_rdDAck   -color DarkGreen  /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/sl_rddack
eval add wave -noupdate $binopt -label Sl_rdComp   -color DarkGreen  /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/sl_rdcomp


eval add wave -noupdate $hexopt -label Sl_wrDBus   -color DarkGreen  /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/plb_wrdbus
eval add wave -noupdate $binopt -label Sl_wrDAck   -color DarkGreen  /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/sl_wrdack
eval add wave -noupdate $binopt -label Sl_wrComp   -color DarkGreen  /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/sl_wrcomp


 
eval add wave -noupdate $binopt -label WB_CLK_I -color Green         /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/wb_clk_i
eval add wave -noupdate $binopt -label WB_RST_I -color Green         /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/wb_rst_i
eval add wave -noupdate $hexopt -label WB_ADR_O -color Green         /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/wb_adr_o
eval add wave -noupdate $hexopt -label WB_DAT_O -color Green         /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/wb_dat_o
eval add wave -noupdate $hexopt -label WB_DAT_I -color Green         /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/wb_dat_i
eval add wave -noupdate $binopt -label WB_ACK_I -color Green         /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/wb_ack_i
eval add wave -noupdate $binopt -label WB_RTY_I -color Green         /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/wb_rty_i
eval add wave -noupdate $binopt -label WB_ERR_I -color Green         /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/wb_err_i
eval add wave -noupdate $binopt -label WB_SEL_O -color Green         /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/wb_sel_o
eval add wave -noupdate $binopt -label WB_STB_O -color Green         /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/wb_stb_o
eval add wave -noupdate $binopt -label WB_LOCK_O -color Green         /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/wb_lock_o
eval add wave -noupdate $binopt -label WB_WE_O  -color Green         /system_tb/dut/plb2wb_bridge_0/plb2wb_bridge_0/wb_we_o



eval add wave -noupdate $binopt -label bram0_ack_o  -color Orange        /system_tb/dut/onchip_ram_0/wb_ack_o
eval add wave -noupdate $binopt -label bram1_ack_o  -color Orange        /system_tb/dut/onchip_ram_1/wb_ack_o
eval add wave -noupdate $binopt -label bram2_ack_o  -color Orange        /system_tb/dut/onchip_ram_2/wb_ack_o


configure wave -gridperiod 1
configure wave -namecolwidth 200
