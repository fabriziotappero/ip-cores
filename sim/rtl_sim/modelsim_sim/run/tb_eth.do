#/////////////////////////////////////////////////////////////////////
#///                                                              ////
#///  tb_eth.do                                                   ////
#///                                                              ////
#///  This file is part of the Ethernet IP core project           ////
#///  http://www.opencores.org/projects/ethmac/                   ////
#///                                                              ////
#///  Author(s):                                                  ////
#///      - Igor Mohor (igorM@opencores.org)                      ////
#///                                                              ////
#///  All additional information is avaliable in the Readme.txt   ////
#///  file.                                                       ////
#///                                                              ////
#/////////////////////////////////////////////////////////////////////
#///                                                              ////
#/// Copyright (C) 2001, 2002 Authors                             ////
#///                                                              ////
#/// This source file may be used and distributed without         ////
#/// restriction provided that this copyright statement is not    ////
#/// removed from the file and that any derivative work contains  ////
#/// the original copyright notice and the associated disclaimer. ////
#///                                                              ////
#/// This source file is free software; you can redistribute it   ////
#/// and/or modify it under the terms of the GNU Lesser General   ////
#/// Public License as published by the Free Software Foundation; ////
#/// either version 2.1 of the License, or (at your option) any   ////
#/// later version.                                               ////
#///                                                              ////
#/// This source is distributed in the hope that it will be       ////
#/// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
#/// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
#/// PURPOSE.  See the GNU Lesser General Public License for more ////
#/// details.                                                     ////
#///                                                              ////
#/// You should have received a copy of the GNU Lesser General    ////
#/// Public License along with this source; if not, download it   ////
#/// from http://www.opencores.org/lgpl.shtml                     ////
#///                                                              ////
#/////////////////////////////////////////////////////////////////////
#/
#/ CVS Revision History
#/
#/ $Log: not supported by cvs2svn $
#/ Revision 1.4  2002/10/11 13:33:56  mohor
#/ Bist supported.
#/
#/ Revision 1.3  2002/10/11 12:42:12  mohor
#/ Bist supported.
#/
#/ Revision 1.2  2002/09/23 18:27:36  mohor
#/ ETH_VIRTUAL_SILICON_RAM supported.
#/
#/ Revision 1.1  2002/09/17 19:10:17  mohor
#/ Macro for testbench (DO file).
#/
#/
#/
#/


#write format wave -window .wave C:/Projects/ethernet/tadejm/ethernet/sim/rtl_sim/modelsim_sim/bin/wave.do
#.main clear

vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_clockgen.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_crc.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/ethmac_defines.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_fifo.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_maccontrol.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_macstatus.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_miim.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_outputcontrol.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_random.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_receivecontrol.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_register.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_registers.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_rxaddrcheck.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_rxcounters.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_rxethmac.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_rxstatem.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_shiftreg.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_spram_256x32.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/ethmac.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_transmitcontrol.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_txcounters.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_txethmac.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_txstatem.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/eth_wishbone.v}
vlog -reportprogress 300 -work work {../../../../rtl/verilog/timescale.v}
vlog -reportprogress 300 -work work {../../../../bench/verilog/eth_phy.v}
vlog -reportprogress 300 -work work {../../../../bench/verilog/eth_phy_defines.v}
vlog -reportprogress 300 -work work {../../../../bench/verilog/tb_eth_defines.v}
vlog -reportprogress 300 -work work {../../../../bench/verilog/tb_ethernet.v}
vlog -reportprogress 300 -work work {../../../../bench/verilog/wb_bus_mon.v}
vlog -reportprogress 300 -work work {../../../../bench/verilog/wb_master_behavioral.v}
vlog -reportprogress 300 -work work {../../../../bench/verilog/wb_master32.v}
vlog -reportprogress 300 -work work {../../../../bench/verilog/wb_model_defines.v}
vlog -reportprogress 300 -work work {../../../../bench/verilog/wb_slave_behavioral.v}


# If you use define ETH_XILINX_RAMB4 switched on, then uncomment the following lines
# vlog -reportprogress 300 -work work {C:/Xilinx/verilog/src/glbl.v}
# vlog -reportprogress 300 -work work {C:/Xilinx/verilog/src/unisims/RAMB4_S16.v}

# If you use define ETH_VIRTUAL_SILICON_RAM switched on, then uncomment the following lines
# vlog -reportprogress 300 -work work {../../../../../vs_rams/018/vs_hdsp_256x32.v}

# If you use define ETH_VIRTUAL_SILICON_RAM and ETH_BIST switched on, then uncomment 
# the following lines
# vlog -reportprogress 300 -work work {../../../../../vs_rams/018/vs_hdsp_256x32_bist.v}
# vlog -reportprogress 300 -work work {../../../../../vs_rams/018/vs_hdsp_256x32_bist_int.v}
# vlog -reportprogress 300 -work work {../../../../../jtag_marvin/jt_bc1in.v}
# vlog -reportprogress 300 -work work {../../../../../bist_marvin/bist.v}

# If you use define ETH_XILINX_RAMB4 switched on, then uncomment the following lines
# !ETH_XILINX_RAMB4
  vsim work.tb_ethernet
#  ETH_XILINX_RAMB4
  #vsim work.glbl work.tb_ethernet


do ../bin/eth_wave.do
#do ../bin/wave.do
run -all
 

