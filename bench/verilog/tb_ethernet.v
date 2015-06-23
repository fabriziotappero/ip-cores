//////////////////////////////////////////////////////////////////////
////                                                              ////
////  tb_ethernet.v                                               ////
////                                                              ////
////  This file is part of the Ethernet IP core project           ////
////  http://www.opencores.org/project,ethmac                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Tadej Markovic, tadej@opencores.org                   ////
////      - Igor Mohor,     igorM@opencores.org                  ////
////                                                              ////
////  All additional information is available in the Readme.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001, 2002 Authors                             ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.33  2005/02/21 13:02:13  igorm
// Tests for delayed CRC and defer indication added.
//
// Revision 1.32  2004/03/26 15:59:21  tadejm
// Latest Ethernet IP core testbench.
//
// Revision 1.31  2003/12/05 12:46:26  tadejm
// Updated testbench. Some more testcases, some repaired.
//
// Revision 1.30  2003/10/17 07:45:17  markom
// mbist signals updated according to newest convention
//
// Revision 1.29  2003/08/20 12:06:24  mohor
// Artisan RAMs added.
//
// Revision 1.28  2003/01/31 15:58:27  mohor
// Tests test_mac_full_duplex_receive 4-7  fixed to proper BD.
//
// Revision 1.27  2003/01/30 13:38:15  mohor
// Underrun test fixed. Many other tests fixed.
//
// Revision 1.26  2003/01/22 19:40:10  tadejm
// Backup version. Not fully working.
//
// Revision 1.25  2002/11/27 16:21:55  mohor
// Full duplex control frames tested.
//
// Revision 1.24  2002/11/22 17:29:42  mohor
// Flow control test almost finished.
//
// Revision 1.23  2002/11/22 02:12:16  mohor
// test_mac_full_duplex_flow_control tests pretty much finished.
// TEST 0: INSERT CONTROL FRM. WHILE TRANSMITTING NORMAL
// FRM. AT 4 TX BD ( 10Mbps ) finished.
// TEST 2: RECEIVE CONTROL FRAMES WITH PASSALL OPTION
// TURNED OFF AT ONE RX BD ( 10Mbps ) finished.
//
// Revision 1.22  2002/11/21 13:56:50  mohor
// test_mac_full_duplex_flow test 0 finished. Sending the control (PAUSE) frame
// finished.
//
// Revision 1.21  2002/11/19 20:27:45  mohor
// Temp version.
//
// Revision 1.20  2002/11/19 17:41:19  tadejm
// Just some updates.
//
// Revision 1.19  2002/11/14 13:12:47  tadejm
// Late collision is not reported any more.
//
// Revision 1.18  2002/10/18 17:03:34  tadejm
// Changed BIST scan signals.
//
// Revision 1.17  2002/10/18 13:58:22  tadejm
// Some code changed due to bug fixes.
//
// Revision 1.16  2002/10/09 13:16:51  tadejm
// Just back-up; not completed testbench and some testcases are not
// wotking properly yet.
//
// Revision 1.15  2002/09/20 14:29:12  tadej
// Full duplex tests modified and testbench bug repaired.
//
// Revision 1.14  2002/09/18 17:56:38  tadej
// Some additional reports added
//
// Revision 1.13  2002/09/16 17:53:49  tadej
// Full duplex test improved.
//
// Revision 1.12  2002/09/16 15:10:42  mohor
// MIIM test look better.
//
// Revision 1.11  2002/09/13 19:18:04  mohor
// Bench outputs data to display every 128 bytes.
//
// Revision 1.10  2002/09/13 18:44:29  mohor
// Beautiful tests merget together
//
// Revision 1.9  2002/09/13 18:41:45  mohor
// Rearanged testcases
//
// Revision 1.8  2002/09/13 14:50:15  mohor
// Bug in MIIM fixed.
//
// Revision 1.7  2002/09/13 12:29:14  mohor
// Headers changed.
//
// Revision 1.6  2002/09/13 11:57:20  mohor
// New testbench. Thanks to Tadej M - "The Spammer".
//
// Revision 1.2  2002/07/19 14:02:47  mohor
// Clock mrx_clk set to 2.5 MHz.
//
// Revision 1.1  2002/07/19 13:57:53  mohor
// Testing environment also includes traffic cop, memory interface and host
// interface.
//
//
//
//
//


`include "eth_phy_defines.v"
`include "wb_model_defines.v"
`include "tb_eth_defines.v"
`include "ethmac_defines.v"
`include "timescale.v"

module tb_ethernet();


reg           wb_clk;
reg           wb_rst;
wire          wb_int;

wire          mtx_clk;  // This goes to PHY
wire          mrx_clk;  // This goes to PHY

wire   [3:0]  MTxD;
wire          MTxEn;
wire          MTxErr;

wire   [3:0]  MRxD;     // This goes to PHY
wire          MRxDV;    // This goes to PHY
wire          MRxErr;   // This goes to PHY
wire          MColl;    // This goes to PHY
wire          MCrs;     // This goes to PHY

wire          Mdi_I;
wire          Mdo_O;
wire          Mdo_OE;
tri           Mdio_IO;
wire          Mdc_O;


parameter Tp = 1;


// Ethernet Slave Interface signals
wire [31:0] eth_sl_wb_adr;
wire [31:0] eth_sl_wb_adr_i, eth_sl_wb_dat_o, eth_sl_wb_dat_i;
wire  [3:0] eth_sl_wb_sel_i;
wire        eth_sl_wb_we_i, eth_sl_wb_cyc_i, eth_sl_wb_stb_i, eth_sl_wb_ack_o, eth_sl_wb_err_o;

// Ethernet Master Interface signals
wire [31:0] eth_ma_wb_adr_o, eth_ma_wb_dat_i, eth_ma_wb_dat_o;
wire  [3:0] eth_ma_wb_sel_o;
wire        eth_ma_wb_we_o, eth_ma_wb_cyc_o, eth_ma_wb_stb_o, eth_ma_wb_ack_i, eth_ma_wb_err_i;

wire  [2:0] eth_ma_wb_cti_o;
wire  [1:0] eth_ma_wb_bte_o;


// Connecting Ethernet top module
ethmac eth_top
(
  // WISHBONE common
  .wb_clk_i(wb_clk),              .wb_rst_i(wb_rst), 

  // WISHBONE slave
  .wb_adr_i(eth_sl_wb_adr_i[11:2]), .wb_sel_i(eth_sl_wb_sel_i),   .wb_we_i(eth_sl_wb_we_i), 
  .wb_cyc_i(eth_sl_wb_cyc_i),       .wb_stb_i(eth_sl_wb_stb_i),   .wb_ack_o(eth_sl_wb_ack_o), 
  .wb_err_o(eth_sl_wb_err_o),       .wb_dat_i(eth_sl_wb_dat_i),   .wb_dat_o(eth_sl_wb_dat_o), 
 	
  // WISHBONE master
  .m_wb_adr_o(eth_ma_wb_adr_o),     .m_wb_sel_o(eth_ma_wb_sel_o), .m_wb_we_o(eth_ma_wb_we_o), 
  .m_wb_dat_i(eth_ma_wb_dat_i),     .m_wb_dat_o(eth_ma_wb_dat_o), .m_wb_cyc_o(eth_ma_wb_cyc_o), 
  .m_wb_stb_o(eth_ma_wb_stb_o),     .m_wb_ack_i(eth_ma_wb_ack_i), .m_wb_err_i(eth_ma_wb_err_i), 

`ifdef ETH_WISHBONE_B3
  .m_wb_cti_o(eth_ma_wb_cti_o),     .m_wb_bte_o(eth_ma_wb_bte_o),
`endif

  //TX
  .mtx_clk_pad_i(mtx_clk), .mtxd_pad_o(MTxD), .mtxen_pad_o(MTxEn), .mtxerr_pad_o(MTxErr),

  //RX
  .mrx_clk_pad_i(mrx_clk), .mrxd_pad_i(MRxD), .mrxdv_pad_i(MRxDV), .mrxerr_pad_i(MRxErr), 
  .mcoll_pad_i(MColl),    .mcrs_pad_i(MCrs), 
  
  // MIIM
  .mdc_pad_o(Mdc_O), .md_pad_i(Mdi_I), .md_pad_o(Mdo_O), .md_padoe_o(Mdo_OE),
  
  .int_o(wb_int)

  // Bist
`ifdef ETH_BIST
  ,
  .mbist_si_i       (1'b0),
  .mbist_so_o       (),
  .mbist_ctrl_i       (3'b001) // {enable, clock, reset}
`endif
);



// Connecting Ethernet PHY Module
assign Mdio_IO = Mdo_OE ? Mdo_O : 1'bz ;
assign Mdi_I   = Mdio_IO;
integer phy_log_file_desc;

eth_phy eth_phy
(
  // WISHBONE reset
  .m_rst_n_i(!wb_rst),

  // MAC TX
  .mtx_clk_o(mtx_clk),    .mtxd_i(MTxD),    .mtxen_i(MTxEn),    .mtxerr_i(MTxErr),

  // MAC RX
  .mrx_clk_o(mrx_clk),    .mrxd_o(MRxD),    .mrxdv_o(MRxDV),    .mrxerr_o(MRxErr),
  .mcoll_o(MColl),        .mcrs_o(MCrs),

  // MIIM
  .mdc_i(Mdc_O),          .md_io(Mdio_IO),

  // SYSTEM
  .phy_log(phy_log_file_desc)
);



// Connecting WB Master as Host Interface
integer host_log_file_desc;

WB_MASTER_BEHAVIORAL wb_master
(
    .CLK_I(wb_clk),
    .RST_I(wb_rst),
    .TAG_I({`WB_TAG_WIDTH{1'b0}}),
    .TAG_O(),
    .ACK_I(eth_sl_wb_ack_o),
    .ADR_O(eth_sl_wb_adr), // only eth_sl_wb_adr_i[11:2] used
    .CYC_O(eth_sl_wb_cyc_i),
    .DAT_I(eth_sl_wb_dat_o),
    .DAT_O(eth_sl_wb_dat_i),
    .ERR_I(eth_sl_wb_err_o),
    .RTY_I(1'b0),  // inactive (1'b0)
    .SEL_O(eth_sl_wb_sel_i),
    .STB_O(eth_sl_wb_stb_i),
    .WE_O (eth_sl_wb_we_i),
    .CAB_O()       // NOT USED for now!
);

assign eth_sl_wb_adr_i = {20'h0, eth_sl_wb_adr[11:2], 2'h0};



// Connecting WB Slave as Memory Interface Module
integer memory_log_file_desc;

WB_SLAVE_BEHAVIORAL wb_slave
(
    .CLK_I(wb_clk),
    .RST_I(wb_rst),
    .ACK_O(eth_ma_wb_ack_i),
    .ADR_I(eth_ma_wb_adr_o),
    .CYC_I(eth_ma_wb_cyc_o),
    .DAT_O(eth_ma_wb_dat_i),
    .DAT_I(eth_ma_wb_dat_o),
    .ERR_O(eth_ma_wb_err_i),
    .RTY_O(),      // NOT USED for now!
    .SEL_I(eth_ma_wb_sel_o),
    .STB_I(eth_ma_wb_stb_o),
    .WE_I (eth_ma_wb_we_o),
    .CAB_I(1'b0)
);



// Connecting WISHBONE Bus Monitors to ethernet master and slave interfaces
integer wb_s_mon_log_file_desc ;
integer wb_m_mon_log_file_desc ;

WB_BUS_MON wb_eth_slave_bus_mon
(
  // WISHBONE common
  .CLK_I(wb_clk),
  .RST_I(wb_rst),

  // WISHBONE slave
  .ACK_I(eth_sl_wb_ack_o),
  .ADDR_O({20'h0, eth_sl_wb_adr_i[11:2], 2'b0}),
  .CYC_O(eth_sl_wb_cyc_i),
  .DAT_I(eth_sl_wb_dat_o),
  .DAT_O(eth_sl_wb_dat_i),
  .ERR_I(eth_sl_wb_err_o),
  .RTY_I(1'b0),
  .SEL_O(eth_sl_wb_sel_i),
  .STB_O(eth_sl_wb_stb_i),
  .WE_O (eth_sl_wb_we_i),
  .TAG_I({`WB_TAG_WIDTH{1'b0}}),
`ifdef ETH_WISHBONE_B3
  .TAG_O({eth_ma_wb_cti_o, eth_ma_wb_bte_o}),
`else
  .TAG_O(5'h0),
`endif
  .CAB_O(1'b0),
`ifdef ETH_WISHBONE_B3
  .check_CTI          (1'b1),
`else
  .check_CTI          (1'b0),
`endif
  .log_file_desc (wb_s_mon_log_file_desc)
);

WB_BUS_MON wb_eth_master_bus_mon
(
  // WISHBONE common
  .CLK_I(wb_clk),
  .RST_I(wb_rst),

  // WISHBONE master
  .ACK_I(eth_ma_wb_ack_i),
  .ADDR_O(eth_ma_wb_adr_o),
  .CYC_O(eth_ma_wb_cyc_o),
  .DAT_I(eth_ma_wb_dat_i),
  .DAT_O(eth_ma_wb_dat_o),
  .ERR_I(eth_ma_wb_err_i),
  .RTY_I(1'b0),
  .SEL_O(eth_ma_wb_sel_o),
  .STB_O(eth_ma_wb_stb_o),
  .WE_O (eth_ma_wb_we_o),
  .TAG_I({`WB_TAG_WIDTH{1'b0}}),
  .TAG_O(5'h0),
  .CAB_O(1'b0),
  .check_CTI(1'b0), // NO need
  .log_file_desc(wb_m_mon_log_file_desc)
);



reg         StartTB;
integer     tb_log_file;

initial
begin
  tb_log_file = $fopen("../log/eth_tb.log");
  if (tb_log_file < 2)
  begin
    $display("*E Could not open/create testbench log file in ../log/ directory!");
    $finish;
  end
  $fdisplay(tb_log_file, "========================== ETHERNET IP Core Testbench results ===========================");
  $fdisplay(tb_log_file, " ");

  phy_log_file_desc = $fopen("../log/eth_tb_phy.log");
  if (phy_log_file_desc < 2)
  begin
    $fdisplay(tb_log_file, "*E Could not open/create eth_tb_phy.log file in ../log/ directory!");
    $finish;
  end
  $fdisplay(phy_log_file_desc, "================ PHY Module  Testbench access log ================");
  $fdisplay(phy_log_file_desc, " ");

  memory_log_file_desc = $fopen("../log/eth_tb_memory.log");
  if (memory_log_file_desc < 2)
  begin
    $fdisplay(tb_log_file, "*E Could not open/create eth_tb_memory.log file in ../log/ directory!");
    $finish;
  end
  $fdisplay(memory_log_file_desc, "=============== MEMORY Module Testbench access log ===============");
  $fdisplay(memory_log_file_desc, " ");

  host_log_file_desc = $fopen("../log/eth_tb_host.log");
  if (host_log_file_desc < 2)
  begin
    $fdisplay(tb_log_file, "*E Could not open/create eth_tb_host.log file in ../log/ directory!");
    $finish;
  end
  $fdisplay(host_log_file_desc, "================ HOST Module Testbench access log ================");
  $fdisplay(host_log_file_desc, " ");

  wb_s_mon_log_file_desc = $fopen("../log/eth_tb_wb_s_mon.log");
  if (wb_s_mon_log_file_desc < 2)
  begin
    $fdisplay(tb_log_file, "*E Could not open/create eth_tb_wb_s_mon.log file in ../log/ directory!");
    $finish;
  end
  $fdisplay(wb_s_mon_log_file_desc, "============== WISHBONE Slave Bus Monitor error log ==============");
  $fdisplay(wb_s_mon_log_file_desc, " ");
  $fdisplay(wb_s_mon_log_file_desc, "   Only ERRONEOUS conditions are logged !");
  $fdisplay(wb_s_mon_log_file_desc, " ");

  wb_m_mon_log_file_desc = $fopen("../log/eth_tb_wb_m_mon.log");
  if (wb_m_mon_log_file_desc < 2)
  begin
    $fdisplay(tb_log_file, "*E Could not open/create eth_tb_wb_m_mon.log file in ../log/ directory!");
    $finish;
  end
  $fdisplay(wb_m_mon_log_file_desc, "============= WISHBONE Master Bus Monitor  error log =============");
  $fdisplay(wb_m_mon_log_file_desc, " ");
  $fdisplay(wb_m_mon_log_file_desc, "   Only ERRONEOUS conditions are logged !");
  $fdisplay(wb_m_mon_log_file_desc, " ");

`ifdef VCD
   $dumpfile("../build/sim/ethmac.vcd");
   $dumpvars(0);
`endif
  // Reset pulse
  wb_rst =  1'b1;
  #423 wb_rst =  1'b0;

  // Clear memories
  clear_memories;
  clear_buffer_descriptors;

  #423 StartTB  =  1'b1;
end



// Generating wb_clk clock
initial
begin
  wb_clk=0;
//  forever #2.5 wb_clk = ~wb_clk;  // 2*2.5 ns -> 200.0 MHz    
//  forever #5 wb_clk = ~wb_clk;  // 2*5 ns -> 100.0 MHz    
//  forever #10 wb_clk = ~wb_clk;  // 2*10 ns -> 50.0 MHz    
//  forever #12.5 wb_clk = ~wb_clk;  // 2*12.5 ns -> 40 MHz    
  forever #15 wb_clk = ~wb_clk;  // 2*10 ns -> 33.3 MHz    
//  forever #20 wb_clk = ~wb_clk;  // 2*20 ns -> 25 MHz    
//  forever #25 wb_clk = ~wb_clk;  // 2*25 ns -> 20.0 MHz
//  forever #31.25 wb_clk = ~wb_clk;  // 2*31.25 ns -> 16.0 MHz    
//  forever #50 wb_clk = ~wb_clk;  // 2*50 ns -> 10.0 MHz
//  forever #55 wb_clk = ~wb_clk;  // 2*55 ns ->  9.1 MHz    
end



integer      tests_successfull;
integer      tests_failed;
reg [799:0]  test_name; // used for tb_log_file

reg   [3:0]  wbm_init_waits; // initial wait cycles between CYC_O and STB_O of WB Master
reg   [3:0]  wbm_subseq_waits; // subsequent wait cycles between STB_Os of WB Master
reg   [3:0]  wbs_waits; // wait cycles befor WB Slave responds
reg   [7:0]  wbs_retries; // if RTY response, then this is the number of retries before ACK

reg          wbm_working; // tasks wbm_write and wbm_read set signal when working and reset it when stop working


initial
begin
  wait(StartTB);  // Start of testbench

  // Initial global values
  tests_successfull = 0;
  tests_failed = 0;
  
  wbm_working = 0;

  wbm_init_waits = 4'h1;
  wbm_subseq_waits = 4'h3;
  wbs_waits = 4'h1;
  wbs_retries = 8'h2; 
  wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

  // set DIFFERENT mrx_clk to mtx_clk!
//  eth_phy.set_mrx_equal_mtx = 1'b0;

  //  Call tests
  //  ----------
    test_access_to_mac_reg(0, 4);           // 0 - 4
    test_mii(0, 17);                        // 0 - 17
  $display("");
  $display("===========================================================================");
  $display("PHY generates ideal Carrier sense and Collision signals for following tests");
  $display("===========================================================================");
  test_note("PHY generates ideal Carrier sense and Collision signals for following tests");
  eth_phy.carrier_sense_real_delay(0);
    test_mac_full_duplex_transmit(0, 23);    // 0 - 23
    test_mac_full_duplex_receive(0, 15);     // 0 - 15
    test_mac_full_duplex_flow_control(0, 5); // 0 - 5

    // Tests not working, yet.
    // test_mac_half_duplex_flow(0, 5);  // 0, 1, 2, 3, 4, 5 These tests need to be fixed !!!

    $display("");
    $display("===========================================================================");
    $display("PHY generates 'real delayed' Carrier sense and Collision signals for following tests");
    $display("===========================================================================");
    test_note("PHY generates 'real delayed' Carrier sense and Collision signals for following tests");
    eth_phy.carrier_sense_real_delay(1);
    test_mac_full_duplex_transmit(0, 23);    // 0 - 23
    test_mac_full_duplex_receive(0, 15);     // 0 - 15
    test_mac_full_duplex_flow_control(0, 5); // 0 - 5
    //test_mac_half_duplex_flow(0, 5);
 
 
  // Finish test's logs
  test_summary;
  $display("\n\n END of SIMULATION");
  $fclose(tb_log_file | phy_log_file_desc | memory_log_file_desc | host_log_file_desc);
  $fclose(wb_s_mon_log_file_desc | wb_m_mon_log_file_desc);

  $stop;
end
  


//////////////////////////////////////////////////////////////
// Test tasks
//////////////////////////////////////////////////////////////

task test_access_to_mac_reg;
  input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        bit_start_1;
  integer        bit_end_1;
  integer        bit_start_2;
  integer        bit_end_2;
  integer        num_of_reg;
  integer        i_addr;
  integer        i_data;
  integer        i_length;
  integer        tmp_data;
  reg    [31:0]  tx_bd_num;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_data;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_tmp_data;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        fail;
  integer        test_num;
  reg    [31:0]  addr;
  reg    [31:0]  data;
  reg     [3:0]  sel;
  reg     [3:0]  rand_sel;
  reg    [31:0]  data_max;
begin
// ACCESS TO MAC REGISTERS TEST
test_heading("ACCESS TO MAC REGISTERS TEST");
$display(" ");
$display("ACCESS TO MAC REGISTERS TEST");
fail = 0;

// reset MAC registers
hard_reset;


//////////////////////////////////////////////////////////////////////
////                                                              ////
////  test_access_to_mac_reg:                                     ////
////                                                              ////
////  0: Byte selects on 3 32-bit RW registers.                   ////
////  1: Walking 1 with single cycles across MAC regs.            ////
////  2: Walking 1 with single cycles across MAC buffer descript. ////
////  3: Test max reg. values and reg. values after writing       ////
////     inverse reset values and hard reset of the MAC           ////
////  4: Test buffer desc. RAM preserving values after hard reset ////
////     of the MAC and resetting the logic                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin

  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Byte selects on 4 32-bit RW registers.                    ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 0) //
  begin
    // TEST 0: BYTE SELECTS ON 3 32-BIT READ-WRITE REGISTERS ( VARIOUS BUS DELAYS )
    test_name   = "TEST 0: BYTE SELECTS ON 3 32-BIT READ-WRITE REGISTERS ( VARIOUS BUS DELAYS )";
    `TIME; $display("  TEST 0: BYTE SELECTS ON 3 32-BIT READ-WRITE REGISTERS ( VARIOUS BUS DELAYS )");
    
    data = 0;
    rand_sel = 0;
    sel = 0;
    for (i = 1; i <= 3; i = i + 1) // num of active byte selects at each register
    begin
      wbm_init_waits = 0;
      wbm_subseq_waits = {$random} % 5; // it is not important for single accesses
      case (i)
      1:       i_addr = `ETH_MAC_ADDR0;
      2:       i_addr = `ETH_HASH_ADDR0;
      default: i_addr = `ETH_HASH_ADDR1;
      endcase
      addr = `ETH_BASE + i_addr;
      sel = 4'hF;
      wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
      if (tmp_data !== 32'h0)
      begin
        fail = fail + 1;
        test_fail_num("Register default value is not ZERO", i_addr);
        `TIME;
        $display("Register default value is not ZERO - addr %h, tmp_data %h", addr, tmp_data);
      end
      for (i1 = 0; i1 <= 3; i1 = i1 + 1) // position of first active byte select
      begin
        case ({i, i1})
        10:      sel = 4'b0001; // data = 32'hFFFF_FF00;
        11:      sel = 4'b0010; // data = 32'hFFFF_00FF;
        12:      sel = 4'b0100; // data = 32'hFF00_FFFF;
        13:      sel = 4'b1000; // data = 32'h00FF_FFFF;
        20:      sel = 4'b0011; // data = 32'hFFFF_0000;
        21:      sel = 4'b0110; // data = 32'hFF00_00FF;
        22:      sel = 4'b1100; // data = 32'h0000_FFFF;
        23:      sel = 4'b1001; // data = 32'h00FF_FF00;
        30:      sel = 4'b0111; // data = 32'hFF00_0000;
        31:      sel = 4'b1110; // data = 32'h0000_00FF;
        32:      sel = 4'b1101; // data = 32'h0000_FF00;
        default: sel = 4'b1011; // data = 32'h00FF_0000;
        endcase
        // set value to 32'hFFFF_FFFF
        data = 32'hFFFF_FFFF;
        wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        wait (wbm_working == 0);
        wbm_read(addr, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (tmp_data !== data)
        begin
          fail = fail + 1;
          test_fail_num("Register could not be written to FFFF_FFFF", i_addr);
          `TIME;
          $display("Register could not be written to FFFF_FFFF - addr %h, tmp_data %h", addr, tmp_data);
        end
        // write appropriate byte(s) to 0
        data = 32'h0;
        wbm_write(addr, data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        wait (wbm_working == 0);
        if (i1[0])
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
        else
          wbm_read(addr, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        data = {({8{~sel[3]}}), ({8{~sel[2]}}), ({8{~sel[1]}}), ({8{~sel[0]}})};
        if (tmp_data !== data)
        begin
          fail = fail + 1;
          test_fail_num("Wrong data read out from register", i_addr);
          `TIME;
          $display("Wrong data read out from register - addr %h, data %h, tmp_data %h, sel %b", 
                   addr, data, tmp_data, sel);
        end
      end
    end
    if(fail == 0)
      test_ok;
    else
      fail = 0;    // Errors were reported previously
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Walking 1 with single cycles across MAC regs.             ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 1) //
  begin
    // TEST 1: 'WALKING ONE' WITH SINGLE CYCLES ACROSS MAC REGISTERS ( VARIOUS BUS DELAYS )
    test_name   = "TEST 1: 'WALKING ONE' WITH SINGLE CYCLES ACROSS MAC REGISTERS ( VARIOUS BUS DELAYS )";
    `TIME; $display("  TEST 1: 'WALKING ONE' WITH SINGLE CYCLES ACROSS MAC REGISTERS ( VARIOUS BUS DELAYS )");
    
    data = 0;
    rand_sel = 0;
    sel = 0;
    for (i_addr = 0; i_addr <= {22'h0, `ETH_TX_CTRL_ADR, 2'h0}; i_addr = i_addr + 4) // register address
    begin
      if (i_addr[6:4] < 5)
        wbm_init_waits = i_addr[6:4];
      else
        wbm_init_waits = 4;
      wbm_subseq_waits = {$random} % 5; // it is not important for single accesses
      addr = `ETH_BASE + i_addr;
      // set ranges of R/W bits
      case (addr)
      `ETH_MODER:
      begin
        bit_start_1 = 0;
        bit_end_1   = 16;
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_INT: // READONLY - tested within INT test
      begin
        bit_start_1 = 32; // not used
        bit_end_1   = 32; // not used
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_INT_MASK:
      begin
        bit_start_1 = 0;
        bit_end_1   = 6;
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_IPGT:
      begin
        bit_start_1 = 0;
        bit_end_1   = 6;
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_IPGR1:
      begin
        bit_start_1 = 0;
        bit_end_1   = 6;
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_IPGR2:
      begin
        bit_start_1 = 0;
        bit_end_1   = 6;
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_PACKETLEN:
      begin
        bit_start_1 = 0;
        bit_end_1   = 31;
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_COLLCONF:
      begin
        bit_start_1 = 0;
        bit_end_1   = 5;
        bit_start_2 = 16; 
        bit_end_2   = 19; 
      end
      `ETH_TX_BD_NUM: 
      begin
        bit_start_1 = 0;
        bit_end_1   = 7;
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_CTRLMODER:
      begin
        bit_start_1 = 0;
        bit_end_1   = 2;
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_MIIMODER:
      begin
        bit_start_1 = 0;
        bit_end_1   = 8;
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_MIICOMMAND: // "WRITEONLY" - tested within MIIM test - 3 LSBits are not written here!!!
      begin
        bit_start_1 = 32; // not used
        bit_end_1   = 32; // not used
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_MIIADDRESS:
      begin
        bit_start_1 = 0;
        bit_end_1   = 4;
        bit_start_2 = 8; 
        bit_end_2   = 12;
      end
      `ETH_MIITX_DATA:
      begin
        bit_start_1 = 0;
        bit_end_1   = 15;
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_MIIRX_DATA: // READONLY - tested within MIIM test
      begin
        bit_start_1 = 32; // not used
        bit_end_1   = 32; // not used
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_MIISTATUS: // READONLY - tested within MIIM test
      begin
        bit_start_1 = 32; // not used
        bit_end_1   = 32; // not used
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_MAC_ADDR0:
      begin
        bit_start_1 = 0;
        bit_end_1   = 31;
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_MAC_ADDR1:
      begin
        bit_start_1 = 0;
        bit_end_1   = 15;
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_HASH_ADDR0:
      begin
        bit_start_1 = 0;
        bit_end_1   = 31;
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      `ETH_HASH_ADDR1:
      begin
        bit_start_1 = 0;
        bit_end_1   = 31;
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      default: // `ETH_TX_CTRL_ADR:
      begin
        bit_start_1 = 0;
        bit_end_1   = 16;
        bit_start_2 = 32; // not used
        bit_end_2   = 32; // not used
      end
      endcase
      
      for (i_data = 0; i_data <= 31; i_data = i_data + 1) // the position of walking one
      begin
        data = 1'b1 << i_data;
        if ( (addr == `ETH_MIICOMMAND)/* && (i_data <= 2)*/ ) // DO NOT WRITE to 3 LSBits of MIICOMMAND !!!
          ;
        else
        begin
          rand_sel[2:0] = {$random} % 8;
          if ((i_data >= 0) && (i_data < 8))
            sel = {rand_sel[2:0], 1'b1};
          else if ((i_data >= 8) && (i_data < 16))
            sel = {rand_sel[2:1], 1'b1, rand_sel[0]};
          else if ((i_data >= 16) && (i_data < 24))
            sel = {rand_sel[2], 1'b1, rand_sel[1:0]};
          else // if ((i_data >= 24) && (i_data < 32))
            sel = {1'b1, rand_sel[2:0]};
          wbm_write(addr, data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          wait (wbm_working == 0);
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if ( ((i_data >= bit_start_1) && (i_data <= bit_end_1)) ||
               ((i_data >= bit_start_2) && (i_data <= bit_end_2)) ) // data should be equal to tmp_data
          begin
            if ( ((tmp_data[31:24] !== data[31:24]) && sel[3]) || ((tmp_data[23:16] !== data[23:16]) && sel[2]) ||
                 ((tmp_data[15: 8] !== data[15: 8]) && sel[1]) || ((tmp_data[ 7: 0] !== data[ 7: 0]) && sel[0]) )
            begin
              fail = fail + 1;
              test_fail_num("RW bit of the MAC register was not written or not read", i_addr);
              `TIME;
              $display("Wrong RW bit - wbm_init_waits %d, addr %h, data %h, tmp_data %h, sel %b", 
                        wbm_init_waits, addr, data, tmp_data, sel);
            end
          end
          else // data should not be equal to tmp_data
          begin
            if ( ((tmp_data[31:24] === data[31:24]) && sel[3]) && ((tmp_data[23:16] === data[23:16]) && sel[2]) &&
                 ((tmp_data[15: 8] === data[15: 8]) && sel[1]) && ((tmp_data[ 7: 0] === data[ 7: 0]) && sel[0]) )
            begin
              fail = fail + 1;
              test_fail_num("NON RW bit of the MAC register was written, but it shouldn't be", i_addr);
              `TIME;
              $display("Wrong NON RW bit - wbm_init_waits %d, addr %h, data %h, tmp_data %h, sel %b",
                        wbm_init_waits, addr, data, tmp_data, sel);
            end
          end
        end
      end
    end
    // INTERMEDIATE DISPLAYS (The only one)
    $display("    ->registers tested with 0, 1, 2, 3 and 4 bus delay cycles");
    if(fail == 0)
      test_ok;
    else
      fail = 0;    // Errors were reported previously
  end
        
        
  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Walking 1 with single cycles across MAC buffer descript.  ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 2) //
  begin
    // TEST 2: 'WALKING ONE' WITH SINGLE CYCLES ACROSS MAC BUFFER DESC. ( VARIOUS BUS DELAYS )
    test_name   = "TEST 2: 'WALKING ONE' WITH SINGLE CYCLES ACROSS MAC BUFFER DESC. ( VARIOUS BUS DELAYS )";
    `TIME; $display("  TEST 2: 'WALKING ONE' WITH SINGLE CYCLES ACROSS MAC BUFFER DESC. ( VARIOUS BUS DELAYS )");
        
    data = 0;
    rand_sel = 0;
    sel = 0;
    // set TX and RX buffer descriptors
    tx_bd_num = 32'h40;
    wbm_write(`ETH_TX_BD_NUM, tx_bd_num, 4'hF, 1, 0, 0);
    for (i_addr = 32'h400; i_addr <= 32'h7FC; i_addr = i_addr + 4) // buffer descriptor address
    begin
      if (i_addr[11:8] < 8)
        wbm_init_waits = i_addr[10:8] - 3'h4;
      else
        wbm_init_waits = 3;
      wbm_subseq_waits = {$random} % 5; // it is not important for single accesses
      addr = `ETH_BASE + i_addr;
      if (i_addr < (32'h400 + (tx_bd_num << 3))) // TX buffer descriptors
      begin
        // set ranges of R/W bits
        case (addr[3])
          1'b0: // buffer control bits
          begin
            bit_start_1 = 0;
            bit_end_1   = 31; // 8;
            bit_start_2 = 11;
            bit_end_2   = 31;
          end
          default: // 1'b1: // buffer pointer
          begin
            bit_start_1 = 0;
            bit_end_1   = 31;
            bit_start_2 = 32; // not used
            bit_end_2   = 32; // not used
          end
        endcase
      end
      else // RX buffer descriptors
      begin
        // set ranges of R/W bits
        case (addr[3])
          1'b0: // buffer control bits
          begin
            bit_start_1 = 0;
            bit_end_1   = 31; // 7;
            bit_start_2 = 13;
            bit_end_2   = 31;
          end
          default: // 1'b1: // buffer pointer
          begin
            bit_start_1 = 0;
            bit_end_1   = 31;
            bit_start_2 = 32; // not used
            bit_end_2   = 32; // not used
          end
        endcase
      end
      
      for (i_data = 0; i_data <= 31; i_data = i_data + 1) // the position of walking one
      begin
        data = 1'b1 << i_data;
        if ( (addr[3] == 0) && (i_data == 15) ) // DO NOT WRITE to this bit !!!
          ;
        else
        begin
          rand_sel[2:0] = {$random} % 8;
          if ((i_data >= 0) && (i_data < 8))
            sel = {rand_sel[2:0], 1'b1};
          else if ((i_data >= 8) && (i_data < 16))
            sel = {rand_sel[2:1], 1'b1, rand_sel[0]};
          else if ((i_data >= 16) && (i_data < 24))
            sel = {rand_sel[2], 1'b1, rand_sel[1:0]};
          else // if ((i_data >= 24) && (i_data < 32))
            sel = {1'b1, rand_sel[2:0]};
          wbm_write(addr, data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
          if ( ((i_data >= bit_start_1) && (i_data <= bit_end_1)) ||
               ((i_data >= bit_start_2) && (i_data <= bit_end_2)) ) // data should be equal to tmp_data
          begin
            if ( ((tmp_data[31:24] !== data[31:24]) && sel[3]) || ((tmp_data[23:16] !== data[23:16]) && sel[2]) ||
                 ((tmp_data[15: 8] !== data[15: 8]) && sel[1]) || ((tmp_data[ 7: 0] !== data[ 7: 0]) && sel[0]) )
            begin
              fail = fail + 1;
              test_fail("RW bit of the MAC buffer descriptors was not written or not read");
              `TIME;
              $display("Wrong RW bit - wbm_init_waits %d, addr %h, data %h, tmp_data %h, sel %b", 
                        wbm_init_waits, addr, data, tmp_data, sel);
            end
          end
          else // data should not be equal to tmp_data
          begin
            if ( ((tmp_data[31:24] === data[31:24]) && sel[3]) && ((tmp_data[23:16] === data[23:16]) && sel[2]) &&
                 ((tmp_data[15: 8] === data[15: 8]) && sel[1]) && ((tmp_data[ 7: 0] === data[ 7: 0]) && sel[0]) )
            begin
              fail = fail + 1;
              test_fail("NON RW bit of the MAC buffer descriptors was written, but it shouldn't be");
              `TIME;
              $display("Wrong NON RW bit - wbm_init_waits %d, addr %h, data %h, tmp_data %h, sel %b",
                        wbm_init_waits, addr, data, tmp_data, sel);
            end
          end
        end
      end
      // INTERMEDIATE DISPLAYS
      if (i_addr[11:0] == 12'h500)
        $display("    ->buffer descriptors tested with 0 bus delay");
      else if (i_addr[11:0] == 12'h600)
        $display("    ->buffer descriptors tested with 1 bus delay cycle");
      else if (i_addr[11:0] == 12'h700)
        $display("    ->buffer descriptors tested with 2 bus delay cycles");
    end
    $display("    ->buffer descriptors tested with 3 bus delay cycles");
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end
        
        
  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test max reg. values and reg. values after writing        ////
  ////  inverse reset values and hard reset of the MAC            ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 3) //
  begin
    // TEST 3: MAX REG. VALUES AND REG. VALUES AFTER WRITING INVERSE RESET VALUES AND HARD RESET OF THE MAC
    test_name   = 
      "TEST 3: MAX REG. VALUES AND REG. VALUES AFTER WRITING INVERSE RESET VALUES AND HARD RESET OF THE MAC";
    `TIME; $display(
      "  TEST 3: MAX REG. VALUES AND REG. VALUES AFTER WRITING INVERSE RESET VALUES AND HARD RESET OF THE MAC");
        
    // reset MAC registers
    hard_reset;
    for (i = 0; i <= 4; i = i + 1) // 0, 2 - WRITE; 1, 3, 4 - READ
    begin
      for (i_addr = 0; i_addr <= {22'h0, `ETH_TX_CTRL_ADR, 2'h0}; i_addr = i_addr + 4) // register address
      begin
        addr = `ETH_BASE + i_addr;
        // set ranges of R/W bits
        case (addr)
        `ETH_MODER:
        begin
          data = 32'h0000_A000; // bit 11 not used any more
          data_max = 32'h0001_FFFF;
        end
        `ETH_INT: // READONLY - tested within INT test
        begin
          data = 32'h0000_0000;
          data_max = 32'h0000_0000;
        end
        `ETH_INT_MASK:
        begin
          data = 32'h0000_0000;
          data_max = 32'h0000_007F;
        end
        `ETH_IPGT:
        begin
          data = 32'h0000_0012;
          data_max = 32'h0000_007F;
        end
        `ETH_IPGR1:
        begin
          data = 32'h0000_000C;
          data_max = 32'h0000_007F;
        end
        `ETH_IPGR2:
        begin
          data = 32'h0000_0012;
          data_max = 32'h0000_007F;
        end
        `ETH_PACKETLEN:
        begin
          data = 32'h0040_0600;
          data_max = 32'hFFFF_FFFF;
        end
        `ETH_COLLCONF:
        begin
          data = 32'h000F_003F;
          data_max = 32'h000F_003F;
        end
        `ETH_TX_BD_NUM: 
        begin
          data = 32'h0000_0040;
          data_max = 32'h0000_0080;
        end
        `ETH_CTRLMODER:
        begin
          data = 32'h0000_0000;
          data_max = 32'h0000_0007;
        end
        `ETH_MIIMODER:
        begin
          data = 32'h0000_0064;
          data_max = 32'h0000_01FF;
        end
        `ETH_MIICOMMAND: // "WRITEONLY" - tested within MIIM test - 3 LSBits are not written here!!!
        begin
          data = 32'h0000_0000;
          data_max = 32'h0000_0000;
        end
        `ETH_MIIADDRESS:
        begin
          data = 32'h0000_0000;
          data_max = 32'h0000_1F1F;
        end
        `ETH_MIITX_DATA:
        begin
          data = 32'h0000_0000;
          data_max = 32'h0000_FFFF;
        end
        `ETH_MIIRX_DATA: // READONLY - tested within MIIM test
        begin
          data = 32'h0000_0000;
          data_max = 32'h0000_0000;
        end
        `ETH_MIISTATUS: // READONLY - tested within MIIM test
        begin
          data = 32'h0000_0000;
          data_max = 32'h0000_0000;
        end
        `ETH_MAC_ADDR0:
        begin
          data = 32'h0000_0000;
          data_max = 32'hFFFF_FFFF;
        end
        `ETH_MAC_ADDR1:
        begin
          data = 32'h0000_0000;
          data_max = 32'h0000_FFFF;
        end
        `ETH_HASH_ADDR0:
        begin
          data = 32'h0000_0000;
          data_max = 32'hFFFF_FFFF;
        end
        `ETH_HASH_ADDR1:
        begin
          data = 32'h0000_0000;
          data_max = 32'hFFFF_FFFF;
        end
        default: // `ETH_TX_CTRL_ADR:
        begin
          data = 32'h0000_0000;
          data_max = 32'h0000_FFFF;
        end
        endcase
        
        wbm_init_waits = {$random} % 3;
        wbm_subseq_waits = {$random} % 5; // it is not important for single accesses
        if (i == 0)
        begin
          if (addr == `ETH_MIICOMMAND) // DO NOT WRITE to 3 LSBits of MIICOMMAND !!!
            ;
          else
          wbm_write(addr, ~data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        end
        else if (i == 2)
        begin
          if (addr == `ETH_MIICOMMAND) // DO NOT WRITE to 3 LSBits of MIICOMMAND !!!
            ;
          else
          wbm_write(addr, 32'hFFFFFFFF, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        end
        else if ((i == 1) || (i == 4))
        begin
          wbm_read(addr, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data !== data)
          begin
            fail = fail + 1;
            test_fail("RESET value of the MAC register is not correct");
            `TIME;
            $display("  addr %h, data %h, tmp_data %h", addr, data, tmp_data);
          end
        end
        else // check maximum values
        begin
          wbm_read(addr, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
          if (addr == `ETH_TX_BD_NUM) // previous data should remain in this register
          begin
            if (tmp_data !== data)
            begin
              fail = fail + 1;
              test_fail("Previous value of the TX_BD_NUM register did not remain");
              `TIME;
              $display("  addr %h, data_max %h, tmp_data %h", addr, data_max, tmp_data);
            end
            // try maximum (80)
            wbm_write(addr, data_max, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            wbm_read(addr, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (tmp_data !== data_max)
            begin
              fail = fail + 1;
              test_fail("MAX value of the TX_BD_NUM register is not correct");
              `TIME;
              $display("  addr %h, data_max %h, tmp_data %h", addr, data_max, tmp_data);
            end
            // try one less than maximum (80)
            wbm_write(addr, (data_max - 1), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            wbm_read(addr, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (tmp_data !== (data_max - 1))
            begin
              fail = fail + 1;
              test_fail("ONE less than MAX value of the TX_BD_NUM register is not correct");
              `TIME;
              $display("  addr %h, data_max %h, tmp_data %h", addr, data_max, tmp_data);
            end
            // try one more than maximum (80)
            wbm_write(addr, (data_max + 1), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            wbm_read(addr, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (tmp_data !== (data_max - 1)) // previous data should remain in this register
            begin
              fail = fail + 1;
              test_fail("Previous value of the TX_BD_NUM register did not remain");
              `TIME;
              $display("  addr %h, data_max %h, tmp_data %h", addr, data_max, tmp_data);
            end
          end
          else
          begin
            if (tmp_data !== data_max)
            begin
              fail = fail + 1;
              test_fail("MAX value of the MAC register is not correct");
              `TIME;
              $display("  addr %h, data_max %h, tmp_data %h", addr, data_max, tmp_data);
            end
          end
        end
      end
      // reset MAC registers
      if ((i == 0) || (i == 3))
        hard_reset;
    end
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test buffer desc. ram preserving values after hard reset  ////
  ////  of the mac and reseting the logic                         ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 4) //
  begin
    // TEST 4: BUFFER DESC. RAM PRESERVING VALUES AFTER HARD RESET OF THE MAC AND RESETING THE LOGIC
    test_name   = "TEST 4: BUFFER DESC. RAM PRESERVING VALUES AFTER HARD RESET OF THE MAC AND RESETING THE LOGIC";
    `TIME; 
    $display("  TEST 4: BUFFER DESC. RAM PRESERVING VALUES AFTER HARD RESET OF THE MAC AND RESETING THE LOGIC");
        
    // reset MAC registers
    hard_reset;
    for (i = 0; i <= 3; i = i + 1) // 0, 2 - WRITE; 1, 3 - READ
    begin
      for (i_addr = 32'h400; i_addr <= 32'h7FC; i_addr = i_addr + 4) // buffer descriptor address
      begin
        addr = `ETH_BASE + i_addr;
        
        wbm_init_waits = {$random} % 3;
        wbm_subseq_waits = {$random} % 5; // it is not important for single accesses
        if (i == 0)
        begin
          data = 32'hFFFFFFFF;
          wbm_write(addr, 32'hFFFFFFFF, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        end
        else if (i == 2)
        begin
          data = 32'h00000000;
          wbm_write(addr, 32'h00000000, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        end
        else
        begin
          wbm_read(addr, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
          if (tmp_data !== data)
          begin
            fail = fail + 1;
            test_fail("PRESERVED value of the MAC buffer descriptors is not correct");
            `TIME;
            $display("  addr %h, data %h, tmp_data %h", addr, data, tmp_data);
          end
        end
      end
      if ((i == 0) || (i == 2))
      begin
        // reset MAC registers
        hard_reset;
      end
    end
    if(fail == 0)
      test_ok;
    else
    fail = 0;
  end


  if (test_num == 5) //
  begin
        /*  // TEST 5: 'WALKING ONE' WITH BURST CYCLES ACROSS MAC REGISTERS ( VARIOUS BUS DELAYS )
          test_name   = "TEST 5: 'WALKING ONE' WITH BURST CYCLES ACROSS MAC REGISTERS ( VARIOUS BUS DELAYS )";
          `TIME; $display("  TEST 5: 'WALKING ONE' WITH BURST CYCLES ACROSS MAC REGISTERS ( VARIOUS BUS DELAYS )");
        
          data = 0;
          burst_data = 0;
          burst_tmp_data = 0;
          i_length = 10; // two bursts for length 20
          for (i = 0; i <= 4; i = i + 1) // for initial wait cycles on WB bus
          begin
            for (i1 = 0; i1 <= 4; i1 = i1 + 1) // for initial wait cycles on WB bus
            begin
              wbm_init_waits = i;
              wbm_subseq_waits = i1; 
              #1;
              for (i_data = 0; i_data <= 31; i_data = i_data + 1) // the position of walking one
              begin
                data = 1'b1 << i_data;
                #1;
                for (i2 = 32'h4C; i2 >= 0; i2 = i2 - 4)
                begin
                  burst_data = burst_data << 32;
                  // DO NOT WRITE to 3 LSBits of MIICOMMAND !!!
                  if ( ((`ETH_BASE + i2) == `ETH_MIICOMMAND) && (i_data <= 2) ) 
                  begin
                    #1 burst_data[31:0] = 0;
                  end
                  else
                  begin
                    #1 burst_data[31:0] = data;
                  end
                end
                #1;
                // 2 burst writes
                addr = `ETH_BASE; // address of a first burst
                wbm_write(addr, burst_data[(32 * 10 - 1):0], 4'hF, i_length, wbm_init_waits, wbm_subseq_waits);
                burst_tmp_data = burst_data >> (32 * i_length);
                addr = addr + 32'h28; // address of a second burst
                wbm_write(addr, burst_tmp_data[(32 * 10 - 1):0], 4'hF, i_length, wbm_init_waits, wbm_subseq_waits);
                #1;
                // 2 burst reads
                addr = `ETH_BASE; // address of a first burst
                wbm_read(addr, burst_tmp_data[(32 * 10 - 1):0], 4'hF, i_length, 
                         wbm_init_waits, wbm_subseq_waits); // first burst
                burst_tmp_data = burst_tmp_data << (32 * i_length);
                addr = addr + 32'h28; // address of a second burst
                wbm_read(addr, burst_tmp_data[(32 * 10 - 1):0], 4'hF, i_length,
                         wbm_init_waits, wbm_subseq_waits); // second burst
                #1;
                for (i2 = 0; i2 <= 32'h4C; i2 = i2 + 4)
                begin
                  // set ranges of R/W bits
                  case (`ETH_BASE + i2)
                  `ETH_MODER:
                    begin
                      bit_start_1 = 0;
                      bit_end_1   = 16;
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  `ETH_INT: // READONLY - tested within INT test
                    begin
                      bit_start_1 = 32; // not used
                      bit_end_1   = 32; // not used
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  `ETH_INT_MASK:
                    begin
                      bit_start_1 = 0;
                      bit_end_1   = 6;
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  `ETH_IPGT:
                    begin
                      bit_start_1 = 0;
                      bit_end_1   = 6;
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  `ETH_IPGR1:
                    begin
                      bit_start_1 = 0;
                      bit_end_1   = 6;
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  `ETH_IPGR2:
                    begin
                      bit_start_1 = 0;
                      bit_end_1   = 6;
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  `ETH_PACKETLEN:
                    begin
                      bit_start_1 = 0;
                      bit_end_1   = 31;
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  `ETH_COLLCONF:
                    begin
                      bit_start_1 = 0;
                      bit_end_1   = 5;
                      bit_start_2 = 16; 
                      bit_end_2   = 19; 
                    end
                  `ETH_TX_BD_NUM: 
                    begin
                      bit_start_1 = 0;
                      bit_end_1   = 7;
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  `ETH_CTRLMODER:
                    begin
                      bit_start_1 = 0;
                      bit_end_1   = 2;
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  `ETH_MIIMODER:
                    begin
                      bit_start_1 = 0;
                      bit_end_1   = 9;
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  `ETH_MIICOMMAND: // "WRITEONLY" - tested within MIIM test - 3 LSBits are not written here!!!
                    begin
                      bit_start_1 = 32; // not used
                      bit_end_1   = 32; // not used
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  `ETH_MIIADDRESS:
                    begin
                      bit_start_1 = 0;
                      bit_end_1   = 4;
                      bit_start_2 = 8; 
                      bit_end_2   = 12;
                    end
                  `ETH_MIITX_DATA:
                    begin
                      bit_start_1 = 0;
                      bit_end_1   = 15;
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  `ETH_MIIRX_DATA: // READONLY - tested within MIIM test
                    begin
                      bit_start_1 = 32; // not used
                      bit_end_1   = 32; // not used
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  `ETH_MIISTATUS: // READONLY - tested within MIIM test
                    begin
                      bit_start_1 = 32; // not used
                      bit_end_1   = 32; // not used
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  `ETH_MAC_ADDR0:
                    begin
                      bit_start_1 = 0;
                      bit_end_1   = 31;
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  `ETH_MAC_ADDR1:
                    begin
                      bit_start_1 = 0;
                      bit_end_1   = 15;
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  `ETH_HASH_ADDR0:
                    begin
                      bit_start_1 = 0;
                      bit_end_1   = 31;
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  default: // `ETH_HASH_ADDR1:
                    begin
                      bit_start_1 = 0;
                      bit_end_1   = 31;
                      bit_start_2 = 32; // not used
                      bit_end_2   = 32; // not used
                    end
                  endcase
                  #1;
                  // 3 LSBits of MIICOMMAND are NOT written !!!
                  if ( ((`ETH_BASE + i2) == `ETH_MIICOMMAND) && (i_data <= 2) )
                  begin
                    if (burst_tmp_data[31:0] !== burst_data[31:0])
                    begin
                      fail = fail + 1;
                      test_fail("NON WR bit of the MAC MIICOMMAND register was wrong written or read");
                      `TIME;
                      $display("wbm_init_waits %d, wbm_subseq_waits %d, addr %h, data %h, tmp_data %h",
                                wbm_init_waits, wbm_subseq_waits, i2, burst_data[31:0], burst_tmp_data[31:0]);
                    end
                  end
                  else
                  begin
                    if ( ((i_data >= bit_start_1) && (i_data <= bit_end_1)) ||
                         ((i_data >= bit_start_2) && (i_data <= bit_end_2)) ) // data should be equal to tmp_data
                    begin
                      if (burst_tmp_data[31:0] !== burst_data[31:0])
                      begin
                        fail = fail + 1;
                        test_fail("RW bit of the MAC register was not written or not read");
                        `TIME;
                        $display("wbm_init_waits %d, wbm_subseq_waits %d, addr %h, data %h, tmp_data %h", 
                                  wbm_init_waits, wbm_subseq_waits, i2, burst_data[31:0], burst_tmp_data[31:0]);
                      end
                    end
                    else // data should not be equal to tmp_data
                    begin
                      if (burst_tmp_data[31:0] === burst_data[31:0])
                      begin
                        fail = fail + 1;
                        test_fail("NON RW bit of the MAC register was written, but it shouldn't be");
                        `TIME;
                        $display("wbm_init_waits %d, wbm_subseq_waits %d, addr %h, data %h, tmp_data %h", 
                                  wbm_init_waits, wbm_subseq_waits, i2, burst_data[31:0], burst_tmp_data[31:0]);
                      end
                    end
                  end
                  burst_tmp_data = burst_tmp_data >> 32;
                  burst_data = burst_data >> 32;
                end
              end
            end
          end
          if(fail == 0)
            test_ok;
          else
            fail = 0;*/
  end

end

end
endtask // test_access_to_mac_reg


task test_mii;
  input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        cnt;
  integer        fail;
  integer        test_num;
  reg     [8:0]  clk_div; // only 8 bits are valid!
  reg     [4:0]  phy_addr;
  reg     [4:0]  reg_addr;
  reg     [15:0] phy_data;
  reg     [15:0] tmp_data;
begin
// MIIM MODULE TEST
test_heading("MIIM MODULE TEST");
$display(" ");
$display("MIIM MODULE TEST");
fail = 0;

// reset MAC registers
hard_reset;


//////////////////////////////////////////////////////////////////////
////                                                              ////
////  test_mii:                                                   ////
////                                                              ////
////  0:  Test clock divider of mii management module with all    ////
////      possible frequences.                                    ////
////  1:  Test various readings from 'real' phy registers.        ////
////  2:  Test various writings to 'real' phy registers (control  ////
////      and non writable registers)                             ////
////  3:  Test reset phy through mii management module            ////
////  4:  Test 'walking one' across phy address (with and without ////
////      preamble)                                               ////
////  5:  Test 'walking one' across phy's register address (with  ////
////      and without preamble)                                   ////
////  6:  Test 'walking one' across phy's data (with and without  ////
////      preamble)                                               ////
////  7:  Test reading from phy with wrong phy address (host      ////
////      reading high 'z' data)                                  ////
////  8:  Test writing to phy with wrong phy address and reading  ////
////      from correct one                                        ////
////  9:  Test sliding stop scan command immediately after read   ////
////      request (with and without preamble)                     ////
//// 10:  Test sliding stop scan command immediately after write  ////
////      request (with and without preamble)                     ////
//// 11:  Test busy and nvalid status durations during write      ////
////      (with and without preamble)                             ////
//// 12:  Test busy and nvalid status durations during write      ////
////      (with and without preamble)                             ////
//// 13:  Test busy and nvalid status durations during scan (with ////
////      and without preamble)                                   ////
//// 14:  Test scan status from phy with detecting link-fail bit  ////
////      (with and without preamble)                             ////
//// 15:  Test scan status from phy with sliding link-fail bit    ////
////      (with and without preamble)                             ////
//// 16:  Test sliding stop scan command immediately after scan   ////
////      request (with and without preamble)                     ////
//// 17:  Test sliding stop scan command after 2. scan (with and  ////
////      without preamble)                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin

  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test clock divider of mii management module with all      ////
  ////  possible frequences.                                      ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 0) //
  begin
    // TEST 0: CLOCK DIVIDER OF MII MANAGEMENT MODULE WITH ALL POSSIBLE FREQUENCES
    test_name   = "TEST 0: CLOCK DIVIDER OF MII MANAGEMENT MODULE WITH ALL POSSIBLE FREQUENCES";
    `TIME; $display("  TEST 0: CLOCK DIVIDER OF MII MANAGEMENT MODULE WITH ALL POSSIBLE FREQUENCES");
  
    wait(Mdc_O); // wait for MII clock to be 1
    for(clk_div = 0; clk_div <= 255; clk_div = clk_div + 1)
    begin
      i1 = 0;
      i2 = 0;
      #Tp mii_set_clk_div(clk_div[7:0]);
      @(posedge Mdc_O);
      #Tp;
      fork
        begin
          @(posedge Mdc_O);
          #Tp;
          disable count_i1;
          disable count_i2;
        end
        begin: count_i1
          forever
          begin
            @(posedge wb_clk);
            i1 = i1 + 1;
            #Tp;
          end
        end
        begin: count_i2
          forever
          begin
            @(negedge wb_clk);
            i2 = i2 + 1;
            #Tp;
          end
        end
      join
      if((clk_div[7:0] == 0) || (clk_div[7:0] == 1) || (clk_div[7:0] == 2) || (clk_div[7:0] == 3))
      begin
        if((i1 == i2) && (i1 == 2))
        begin
        end
        else
        begin
          fail = fail + 1;
          test_fail("Clock divider of MII module did'nt divide frequency corectly (it should divide by 2)");
        end
      end
      else
      begin
        if((i1 == i2) && (i1 == {clk_div[7:1], 1'b0}))
        begin
        end
        else
        begin
          fail = fail + 1;
          test_fail("Clock divider of MII module did'nt divide frequency corectly");
        end
      end
    end
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end
  
  
  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test various readings from 'real' phy registers.          ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 1) //
  begin
    // TEST 1: VARIOUS READINGS FROM 'REAL' PHY REGISTERS
    test_name   = "TEST 1: VARIOUS READINGS FROM 'REAL' PHY REGISTERS";
    `TIME; $display("  TEST 1: VARIOUS READINGS FROM 'REAL' PHY REGISTERS");
  
    // set the fastest possible MII
    clk_div = 0;
    mii_set_clk_div(clk_div[7:0]);
    // set address
    reg_addr = 5'h1F;
    phy_addr = 5'h1;
    while(reg_addr >= 5'h4)
    begin
      // read request
      #Tp mii_read_req(phy_addr, reg_addr);
      check_mii_busy; // wait for read to finish
      // read data
      wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (phy_data !== 16'hDEAD)
      begin
        test_fail("Wrong data was read from PHY from 'not used' address space");
        fail = fail + 1;
      end
      if (reg_addr == 5'h4) // go out of for loop
        reg_addr = 5'h3;
      else
        reg_addr = reg_addr - 5'h9;
    end
  
    // set address
    reg_addr = 5'h3;
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (phy_data !== {`PHY_ID2, `MAN_MODEL_NUM, `MAN_REVISION_NUM})
    begin
      test_fail("Wrong data was read from PHY from ID register 2");
      fail = fail + 1;
    end
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test various writings to 'real' phy registers (control    ////
  ////  and non writable registers)                               ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 2) // 
  begin
    // TEST 2: VARIOUS WRITINGS TO 'REAL' PHY REGISTERS ( CONTROL AND NON WRITABLE REGISTERS )
    test_name   = "TEST 2: VARIOUS WRITINGS TO 'REAL' PHY REGISTERS ( CONTROL AND NON WRITABLE REGISTERS )";
    `TIME; $display("  TEST 2: VARIOUS WRITINGS TO 'REAL' PHY REGISTERS ( CONTROL AND NON WRITABLE REGISTERS )");
  
    // negate data and try to write into unwritable register
    tmp_data = ~phy_data;
    // write request
    #Tp mii_write_req(phy_addr, reg_addr, tmp_data);
    check_mii_busy; // wait for write to finish
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (tmp_data !== phy_data)
    begin
      test_fail("Data was written into unwritable PHY register - ID register 2");
      fail = fail + 1;
    end
  
    // set address
    reg_addr = 5'h0; // control register
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // write request
    phy_data = 16'h7DFF; // bit 15 (RESET bit) and bit 9 are self clearing bits
    #Tp mii_write_req(phy_addr, reg_addr, phy_data);
    check_mii_busy; // wait for write to finish
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (phy_data !== 16'h7DFF)
    begin
      test_fail("Data was not correctly written into OR read from writable PHY register - control register");
      fail = fail + 1;
    end
    // write request
    #Tp mii_write_req(phy_addr, reg_addr, tmp_data);
    check_mii_busy; // wait for write to finish
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (phy_data !== tmp_data)
    begin
      test_fail("Data was not correctly written into OR read from writable PHY register - control register");
      fail = fail + 1;
    end
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test reset phy through mii management module              ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 3) // 
  begin
    // TEST 3: RESET PHY THROUGH MII MANAGEMENT MODULE
    test_name   = "TEST 3: RESET PHY THROUGH MII MANAGEMENT MODULE";
    `TIME; $display("  TEST 3: RESET PHY THROUGH MII MANAGEMENT MODULE");
  
    // set address
    reg_addr = 5'h0; // control register
    // write request
    phy_data = 16'h7DFF; // bit 15 (RESET bit) and bit 9 are self clearing bits
    #Tp mii_write_req(phy_addr, reg_addr, phy_data);
    check_mii_busy; // wait for write to finish
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (phy_data !== tmp_data)
    begin
      test_fail("Data was not correctly written into OR read from writable PHY register - control register");
      fail = fail + 1;
    end
    // set reset bit - selfclearing bit in PHY
    phy_data = phy_data | 16'h8000;
    // write request
    #Tp mii_write_req(phy_addr, reg_addr, phy_data);
    check_mii_busy; // wait for write to finish
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check self clearing of reset bit
    if (tmp_data[15] !== 1'b0)
    begin
      test_fail("Reset bit should be self cleared - control register");
      fail = fail + 1;
    end
    // check reset value of control register
    if (tmp_data !== {2'h0, (`LED_CFG1 || `LED_CFG2), `LED_CFG1, 3'h0, `LED_CFG3, 8'h0})
    begin
      test_fail("PHY was not reset correctly AND/OR reset bit not self cleared");
      fail = fail + 1;
    end
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test 'walking one' across phy address (with and without   ////
  ////  preamble)                                                 ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 4) // 
  begin
    // TEST 4: 'WALKING ONE' ACROSS PHY ADDRESS ( WITH AND WITHOUT PREAMBLE )
    test_name   = "TEST 4: 'WALKING ONE' ACROSS PHY ADDRESS ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 4: 'WALKING ONE' ACROSS PHY ADDRESS ( WITH AND WITHOUT PREAMBLE )");
  
    // set PHY to test mode
    #Tp eth_phy.test_regs(1); // set test registers (wholy writable registers) and respond to all PHY addresses
    for (i = 0; i <= 1; i = i + 1)
    begin
      #Tp eth_phy.preamble_suppresed(i); 
      #Tp eth_phy.clear_test_regs;
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i, 8'h0}), 4'hF, 1, wbm_init_waits, 
                wbm_subseq_waits);
      // walk one across phy address
      for (phy_addr = 5'h1; phy_addr > 5'h0; phy_addr = phy_addr << 1)
      begin
        reg_addr = $random;
        tmp_data = $random;
        // write request
        #Tp mii_write_req(phy_addr, reg_addr, tmp_data);
        check_mii_busy; // wait for write to finish
        // read request
        #Tp mii_read_req(phy_addr, reg_addr);
        check_mii_busy; // wait for read to finish
        // read data
        wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        #Tp;
        if (phy_data !== tmp_data)
        begin
          if (i)
            test_fail("Data was not correctly written into OR read from test registers (without preamble)");
          else
            test_fail("Data was not correctly written into OR read from test registers (with preamble)");
          fail = fail + 1;
        end
        @(posedge wb_clk);
        #Tp;
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.test_regs(0);
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test 'walking one' across phy's register address (with    ////
  ////  and without preamble)                                     ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 5) // 
  begin
    // TEST 5: 'WALKING ONE' ACROSS PHY'S REGISTER ADDRESS ( WITH AND WITHOUT PREAMBLE )
    test_name   = "TEST 5: 'WALKING ONE' ACROSS PHY'S REGISTER ADDRESS ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 5: 'WALKING ONE' ACROSS PHY'S REGISTER ADDRESS ( WITH AND WITHOUT PREAMBLE )");
  
    // set PHY to test mode
    #Tp eth_phy.test_regs(1); // set test registers (wholy writable registers) and respond to all PHY addresses
    for (i = 0; i <= 1; i = i + 1)
    begin
      #Tp eth_phy.preamble_suppresed(i);
      #Tp eth_phy.clear_test_regs;
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i, 8'h0}), 4'hF, 1, wbm_init_waits, 
                wbm_subseq_waits);
      // walk one across reg address
      for (reg_addr = 5'h1; reg_addr > 5'h0; reg_addr = reg_addr << 1)
      begin
        phy_addr = $random;
        tmp_data = $random;
        // write request
        #Tp mii_write_req(phy_addr, reg_addr, tmp_data);
        check_mii_busy; // wait for write to finish
        // read request
        #Tp mii_read_req(phy_addr, reg_addr);
        check_mii_busy; // wait for read to finish
        // read data
        wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        #Tp;
        if (phy_data !== tmp_data)
        begin
          if (i)
            test_fail("Data was not correctly written into OR read from test registers (without preamble)");
          else
            test_fail("Data was not correctly written into OR read from test registers (with preamble)");
          fail = fail + 1;
        end
        @(posedge wb_clk);
        #Tp;
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.test_regs(0);
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test 'walking one' across phy's data (with and without    ////
  ////  preamble)                                                 ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 6) // 
  begin
    // TEST 6: 'WALKING ONE' ACROSS PHY'S DATA ( WITH AND WITHOUT PREAMBLE )
    test_name   = "TEST 6: 'WALKING ONE' ACROSS PHY'S DATA ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 6: 'WALKING ONE' ACROSS PHY'S DATA ( WITH AND WITHOUT PREAMBLE )");
  
    // set PHY to test mode
    #Tp eth_phy.test_regs(1); // set test registers (wholy writable registers) and respond to all PHY addresses
    for (i = 0; i <= 1; i = i + 1)
    begin
      #Tp eth_phy.preamble_suppresed(i);
      #Tp eth_phy.clear_test_regs;
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i, 8'h0}), 4'hF, 1, wbm_init_waits,
                wbm_subseq_waits);
      // walk one across data
      for (tmp_data = 16'h1; tmp_data > 16'h0; tmp_data = tmp_data << 1)
      begin
        phy_addr = $random;
        reg_addr = $random;
        // write request
        #Tp mii_write_req(phy_addr, reg_addr, tmp_data);
        check_mii_busy; // wait for write to finish
        // read request
        #Tp mii_read_req(phy_addr, reg_addr);
        check_mii_busy; // wait for read to finish
        // read data
        wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        #Tp;
        if (phy_data !== tmp_data)
        begin
          if (i)
            test_fail("Data was not correctly written into OR read from test registers (without preamble)");
          else
            test_fail("Data was not correctly written into OR read from test registers (with preamble)");
          fail = fail + 1;
        end
        @(posedge wb_clk);
        #Tp;
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.test_regs(0);
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test reading from phy with wrong phy address (host        ////
  ////  reading high 'z' data)                                    ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 7) // 
  begin
    // TEST 7: READING FROM PHY WITH WRONG PHY ADDRESS ( HOST READING HIGH 'Z' DATA )
    test_name   = "TEST 7: READING FROM PHY WITH WRONG PHY ADDRESS ( HOST READING HIGH 'Z' DATA )";
    `TIME; $display("  TEST 7: READING FROM PHY WITH WRONG PHY ADDRESS ( HOST READING HIGH 'Z' DATA )");
  
    phy_addr = 5'h2; // wrong PHY address
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    $display("  => Two error lines will be displayed from WB Bus Monitor, because correct HIGH Z data was read");
    wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (tmp_data !== 16'hzzzz)
    begin
      test_fail("Data was read from PHY register with wrong PHY address - control register");
      fail = fail + 1;
    end
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test writing to phy with wrong phy address and reading    ////
  ////  from correct one                                          ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 8) // 
  begin
    // TEST 8: WRITING TO PHY WITH WRONG PHY ADDRESS AND READING FROM CORRECT ONE
    test_name   = "TEST 8: WRITING TO PHY WITH WRONG PHY ADDRESS AND READING FROM CORRECT ONE";
    `TIME; $display("  TEST 8: WRITING TO PHY WITH WRONG PHY ADDRESS AND READING FROM CORRECT ONE");
  
    // set address
    reg_addr = 5'h0; // control register
    phy_addr = 5'h2; // wrong PHY address
    // write request
    phy_data = 16'h7DFF; // bit 15 (RESET bit) and bit 9 are self clearing bits
    #Tp mii_write_req(phy_addr, reg_addr, phy_data);
    check_mii_busy; // wait for write to finish
  
    phy_addr = 5'h1; // correct PHY address
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data
    wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (phy_data === tmp_data)
    begin
      test_fail("Data was written into PHY register with wrong PHY address - control register");
      fail = fail + 1;
    end
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test sliding stop scan command immediately after read     ////
  ////  request (with and without preamble)                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 9) // 
  begin
    // TEST 9: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER READ REQUEST ( WITH AND WITHOUT PREAMBLE )
    test_name = "TEST 9: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER READ REQUEST ( WITH AND WITHOUT PREAMBLE )";
    `TIME; 
    $display("  TEST 9: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER READ REQUEST ( WITH AND WITHOUT PREAMBLE )");
  
    for (i2 = 0; i2 <= 1; i2 = i2 + 1) // choose preamble or not
    begin
      #Tp eth_phy.preamble_suppresed(i2);
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i2, 8'h0}), 4'hF, 1, wbm_init_waits, 
               wbm_subseq_waits);
      i = 0;
      cnt = 0;
      while (i < 80) // delay for sliding of writing a STOP SCAN command
      begin
        for (i3 = 0; i3 <= 1; i3 = i3 + 1) // choose read or write after read will be finished
        begin
          // set address
          reg_addr = 5'h0; // control register
          phy_addr = 5'h1; // correct PHY address
          cnt = 0;
          // read request
          #Tp mii_read_req(phy_addr, reg_addr);
          fork
            begin
              repeat(i) @(posedge Mdc_O);
              // write command 0x0 into MII command register
              // MII command written while read in progress
              wbm_write(`ETH_MIICOMMAND, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
              @(posedge wb_clk);
              #Tp check_mii_busy; // wait for read to finish
            end
            begin
              // wait for serial bus to become active
              wait(Mdio_IO !== 1'bz);
              // count transfer length
              while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
              begin
                @(posedge Mdc_O);
                #Tp cnt = cnt + 1;
              end
            end
          join
          // check transfer length
          if (i2) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Read request did not proceed correctly, while SCAN STOP command was written");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Read request did not proceed correctly, while SCAN STOP command was written");
              fail = fail + 1;
            end
          end
          // check the BUSY signal to see if the bus is still IDLE
          for (i1 = 0; i1 < 8; i1 = i1 + 1)
            check_mii_busy; // wait for bus to become idle
    
          // try normal write or read after read was finished
          #Tp phy_data = {8'h7D, (i[7:0] + 1'b1)};
          #Tp cnt = 0;
          if (i3 == 0) // write after read
          begin
            // write request
            #Tp mii_write_req(phy_addr, reg_addr, phy_data);
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while(Mdio_IO !== 1'bz)
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            @(posedge Mdc_O);
            // read request
            #Tp mii_read_req(phy_addr, reg_addr);
            check_mii_busy; // wait for read to finish
            // read and check data
            wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (phy_data !== tmp_data)
            begin
              test_fail("Data was not correctly written into OR read from PHY register - control register");
              fail = fail + 1;
            end
          end
          else // read after read
          begin
            // read request
            #Tp mii_read_req(phy_addr, reg_addr);
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            @(posedge Mdc_O);
            check_mii_busy; // wait for read to finish
            // read and check data
            wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (phy_data !== tmp_data)
            begin
              test_fail("Data was not correctly written into OR read from PHY register - control register");
              fail = fail + 1;
            end
          end
          // check if transfer was a proper length
          if (i2) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("New request did not proceed correctly, after read request");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("New request did not proceed correctly, after read request");
              fail = fail + 1;
            end
          end
        end
        #Tp;
        // set delay of writing the command
        if (i2) // without preamble
        begin
          case(i)
            0, 1:               i = i + 1;
            18, 19, 20, 21, 22,
            23, 24, 25, 26, 27,
            28, 29, 30, 31, 32,
            33, 34, 35:         i = i + 1;
            36:                 i = 80;
            default:            i = 18;
          endcase
        end
        else // with preamble
        begin
          case(i)
            0, 1:               i = i + 1;
            50, 51, 52, 53, 54, 
            55, 56, 57, 58, 59, 
            60, 61, 62, 63, 64, 
            65, 66, 67:         i = i + 1;
            68:                 i = 80;
            default:            i = 50;
          endcase
        end
        @(posedge wb_clk);
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test sliding stop scan command immediately after write    ////
  ////  request (with and without preamble)                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 10) // 
  begin
    // TEST 10: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER WRITE REQUEST ( WITH AND WITHOUT PREAMBLE )
    test_name = "TEST 10: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER WRITE REQUEST ( WITH AND WITHOUT PREAMBLE )";
    `TIME; 
    $display("  TEST 10: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER WRITE REQUEST ( WITH AND WITHOUT PREAMBLE )");
  
    for (i2 = 0; i2 <= 1; i2 = i2 + 1) // choose preamble or not
    begin
      #Tp eth_phy.preamble_suppresed(i2);
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i2, 8'h0}), 4'hF, 1, wbm_init_waits, 
                wbm_subseq_waits);
      i = 0;
      cnt = 0;
      while (i < 80) // delay for sliding of writing a STOP SCAN command
      begin
        for (i3 = 0; i3 <= 1; i3 = i3 + 1) // choose read or write after write will be finished
        begin
          // set address
          reg_addr = 5'h0; // control register
          phy_addr = 5'h1; // correct PHY address
          cnt = 0;
          // write request
          phy_data = {8'h75, (i[7:0] + 1'b1)};
          #Tp mii_write_req(phy_addr, reg_addr, phy_data);
          fork
            begin
              repeat(i) @(posedge Mdc_O);
              // write command 0x0 into MII command register
              // MII command written while read in progress
              wbm_write(`ETH_MIICOMMAND, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
              @(posedge wb_clk);
              #Tp check_mii_busy; // wait for write to finish
            end
            begin
              // wait for serial bus to become active
              wait(Mdio_IO !== 1'bz);
              // count transfer length
              while(Mdio_IO !== 1'bz)
              begin
                @(posedge Mdc_O);
                #Tp cnt = cnt + 1;
              end
            end
          join
          // check transfer length
          if (i2) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Write request did not proceed correctly, while SCAN STOP command was written");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Write request did not proceed correctly, while SCAN STOP command was written");
              fail = fail + 1;
            end
          end
          // check the BUSY signal to see if the bus is still IDLE
          for (i1 = 0; i1 < 8; i1 = i1 + 1)
            check_mii_busy; // wait for bus to become idle
    
          // try normal write or read after write was finished
          #Tp cnt = 0;
          if (i3 == 0) // write after write
          begin
            phy_data = {8'h78, (i[7:0] + 1'b1)};
            // write request, bit 9 in phy_data is self-clearing
            #Tp mii_write_req(phy_addr, reg_addr, (phy_data|16'h0200));
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while(Mdio_IO !== 1'bz)
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            @(posedge Mdc_O);
            // read request
            #Tp mii_read_req(phy_addr, reg_addr);
            check_mii_busy; // wait for read to finish
            // read and check data
            wbm_read(`ETH_MIIRX_DATA, tmp_data , 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (phy_data !== tmp_data)
            begin
              test_fail("Data was not correctly written into OR read from PHY register - control register");
              fail = fail + 1;
            end
          end
          else // read after write
          begin
            // read request
            #Tp mii_read_req(phy_addr, reg_addr);
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            @(posedge Mdc_O);
            check_mii_busy; // wait for read to finish
            // read and check data
            wbm_read(`ETH_MIIRX_DATA, tmp_data , 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (phy_data !== tmp_data)
            begin
              test_fail("Data was not correctly written into OR read from PHY register - control register");
              fail = fail + 1;
            end
          end
          // check if transfer was a proper length
          if (i2) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("New request did not proceed correctly, after write request");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("New request did not proceed correctly, after write request");
              fail = fail + 1;
            end
          end
        end
        #Tp;
        // set delay of writing the command
        if (i2) // without preamble
        begin
          case(i)
            0, 1:               i = i + 1;
            18, 19, 20, 21, 22,
            23, 24, 25, 26, 27,
            28, 29, 30, 31, 32,
            33, 34, 35:         i = i + 1;
            36:                 i = 80;
            default:            i = 18;
          endcase
        end
        else // with preamble
        begin
          case(i)
            0, 1:               i = i + 1;
            50, 51, 52, 53, 54, 
            55, 56, 57, 58, 59, 
            60, 61, 62, 63, 64, 
            65, 66, 67:         i = i + 1;
            68:                 i = 80;
            default:            i = 50;
          endcase
        end
        @(posedge wb_clk);
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test busy and nvalid status durations during write (with  ////
  ////  and without preamble)                                     ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 11) // 
  begin
    // TEST 11: BUSY AND NVALID STATUS DURATIONS DURING WRITE ( WITH AND WITHOUT PREAMBLE )
    test_name   = "TEST 11: BUSY AND NVALID STATUS DURATIONS DURING WRITE ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 11: BUSY AND NVALID STATUS DURATIONS DURING WRITE ( WITH AND WITHOUT PREAMBLE )");
  
    // set link up, if it wasn't due to previous tests, since there weren't PHY registers
    #Tp eth_phy.link_up_down(1);
    // set the MII
    clk_div = 64;
    mii_set_clk_div(clk_div[7:0]);
    // set address
    reg_addr = 5'h1; // status register
    phy_addr = 5'h1; // correct PHY address
  
    for (i = 0; i <= 1; i = i + 1)
    begin
      #Tp eth_phy.preamble_suppresed(i);
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i, 8'h0}) | (`ETH_MIIMODER_CLKDIV & clk_div), 
                4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      @(posedge Mdc_O);
      // write request
      #Tp mii_write_req(phy_addr, reg_addr, 16'h5A5A);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to late, Mdio_IO is not HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal was not set while MII IO signal is not HIGH Z anymore - 1. read");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during write");
          fail = fail + 1;
        end
      end
      else // Busy bit should already be set to '1', due to reads from MII status register
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set after write, due to reads from MII status register");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during write");
          fail = fail + 1;
        end
      end
  
      // wait for serial bus to become active
      wait(Mdio_IO !== 1'bz);
      // count transfer bits
      if (i)
      begin
        repeat(32) @(posedge Mdc_O);
      end
      else
      begin
        repeat(64) @(posedge Mdc_O);
      end
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO === 1'bz) // Mdio_IO should not be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to late, Mdio_IO is HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set while MII IO signal is not active anymore");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during write");
          fail = fail + 1;
        end
      end
      else // Busy bit should still be set to '1'
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set while MII IO signal not HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during write");
          fail = fail + 1;
        end
      end
  
      // wait for next negative clock edge
      @(negedge Mdc_O);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to early, Mdio_IO is not HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal was not set while MII IO signal is not HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during write");
          fail = fail + 1;
        end
      end
      else // Busy bit should still be set to '1'
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set after MII IO signal become HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during write");
          fail = fail + 1;
        end
      end
  
      // wait for Busy to become inactive
      i1 = 0;
      while (i1 <= 2)
      begin
        // wait for next positive clock edge
        @(posedge Mdc_O);
        // read data from MII status register - Busy and Nvalid bits
        wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
        // check MII IO signal and Busy and Nvalid bits
        if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
        begin
          test_fail("Testbench error - read was to early, Mdio_IO is not HIGH Z - set higher clock divider");
          if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
          begin
            test_fail("Busy signal was not set while MII IO signal is not HIGH Z");
            fail = fail + 1;
          end
          if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
          begin
            test_fail("Nvalid signal was set during write");
            fail = fail + 1;
          end
        end
        else // wait for Busy bit to be set to '0'
        begin
          if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
          begin
            i1 = 3; // end of Busy checking
          end
          else
          begin
            if (i1 == 2)
            begin
              test_fail("Busy signal should be cleared after 2 periods after MII IO signal become HIGH Z");
              fail = fail + 1;
            end
            #Tp i1 = i1 + 1;
          end
          if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
          begin
            test_fail("Nvalid signal was set after write");
            fail = fail + 1;
          end
        end
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test busy and nvalid status durations during write (with  ////
  ////  and without preamble)                                     ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 12) // 
  begin
    // TEST 12: BUSY AND NVALID STATUS DURATIONS DURING READ ( WITH AND WITHOUT PREAMBLE )
    test_name   = "TEST 12: BUSY AND NVALID STATUS DURATIONS DURING READ ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 12: BUSY AND NVALID STATUS DURATIONS DURING READ ( WITH AND WITHOUT PREAMBLE )");
  
    // set link up, if it wasn't due to previous tests, since there weren't PHY registers
    #Tp eth_phy.link_up_down(1); 
    // set the MII
    clk_div = 64;
    mii_set_clk_div(clk_div[7:0]);
    // set address
    reg_addr = 5'h1; // status register
    phy_addr = 5'h1; // correct PHY address
  
    for (i = 0; i <= 1; i = i + 1)
    begin
      #Tp eth_phy.preamble_suppresed(i);
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i, 8'h0}) | (`ETH_MIIMODER_CLKDIV & clk_div),
                4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      @(posedge Mdc_O);
      // read request
      #Tp mii_read_req(phy_addr, reg_addr);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to late, Mdio_IO is not HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal was not set while MII IO signal is not HIGH Z anymore - 1. read");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during read");
          fail = fail + 1;
        end
      end
      else // Busy bit should already be set to '1', due to reads from MII status register
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set after read, due to reads from MII status register");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during read");
          fail = fail + 1;
        end
      end
  
      // wait for serial bus to become active
      wait(Mdio_IO !== 1'bz);
      // count transfer bits
      if (i)
      begin
        repeat(31) @(posedge Mdc_O);
      end
      else
      begin
        repeat(63) @(posedge Mdc_O);
      end
      // wait for next negative clock edge
      @(negedge Mdc_O);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO === 1'bz) // Mdio_IO should not be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to late, Mdio_IO is HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set while MII IO signal is not active anymore");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during read");
          fail = fail + 1;
        end
      end
      else // Busy bit should still be set to '1'
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set while MII IO signal not HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during read");
          fail = fail + 1;
        end
      end
  
      // wait for next positive clock edge
      @(posedge Mdc_O);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to early, Mdio_IO is not HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal was not set while MII IO signal is not HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during read");
          fail = fail + 1;
        end
      end
      else // Busy bit should still be set to '1'
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set after MII IO signal become HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
        begin
          test_fail("Nvalid signal was set during read");
          fail = fail + 1;
        end
      end
  
      // wait for Busy to become inactive
      i1 = 0;
      while (i1 <= 2)
      begin
        // wait for next positive clock edge
        @(posedge Mdc_O);
        // read data from MII status register - Busy and Nvalid bits
        wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
        // check MII IO signal and Busy and Nvalid bits
        if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
        begin
          test_fail("Testbench error - read was to early, Mdio_IO is not HIGH Z - set higher clock divider");
          if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
          begin
            test_fail("Busy signal was not set while MII IO signal is not HIGH Z");
            fail = fail + 1;
          end
          if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
          begin
            test_fail("Nvalid signal was set during read");
            fail = fail + 1;
          end
        end
        else // wait for Busy bit to be set to '0'
        begin
          if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
          begin
            i1 = 3; // end of Busy checking
          end
          else
          begin
            if (i1 == 2)
            begin
              test_fail("Busy signal should be cleared after 2 periods after MII IO signal become HIGH Z");
              fail = fail + 1;
            end
            #Tp i1 = i1 + 1;
          end
          if (phy_data[`ETH_MIISTATUS_NVALID] !== 1'b0)
          begin
            test_fail("Nvalid signal was set after read");
            fail = fail + 1;
          end
        end
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test busy and nvalid status durations during scan (with   ////
  ////  and without preamble)                                     ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 13) // 
  begin
    // TEST 13: BUSY AND NVALID STATUS DURATIONS DURING SCAN ( WITH AND WITHOUT PREAMBLE )
    test_name   = "TEST 13: BUSY AND NVALID STATUS DURATIONS DURING SCAN ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 13: BUSY AND NVALID STATUS DURATIONS DURING SCAN ( WITH AND WITHOUT PREAMBLE )");
  
    // set link up, if it wasn't due to previous tests, since there weren't PHY registers
    #Tp eth_phy.link_up_down(1); 
    // set the MII
    clk_div = 64;
    mii_set_clk_div(clk_div[7:0]);
    // set address
    reg_addr = 5'h1; // status register
    phy_addr = 5'h1; // correct PHY address
  
    for (i = 0; i <= 1; i = i + 1)
    begin
      #Tp eth_phy.preamble_suppresed(i);
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i, 8'h0}) | (`ETH_MIIMODER_CLKDIV & clk_div),
                4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      @(posedge Mdc_O);
      // scan request
      #Tp mii_scan_req(phy_addr, reg_addr);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to late, Mdio_IO is not HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal was not set while MII IO signal is not HIGH Z anymore - 1. read");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] === 1'b0)
        begin
          test_fail("Nvalid signal was not set while MII IO signal is not HIGH Z anymore - 1. read");
          fail = fail + 1;
        end
      end
      else // Busy bit should already be set to '1', due to reads from MII status register
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set after scan, due to reads from MII status register");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] === 1'b0)
        begin
          test_fail("Nvalid signal should be set after scan, due to reads from MII status register");
          fail = fail + 1;
        end
      end
  
      // wait for serial bus to become active
      wait(Mdio_IO !== 1'bz);
      // count transfer bits
      if (i)
      begin
        repeat(21) @(posedge Mdc_O);
      end
      else
      begin
        repeat(53) @(posedge Mdc_O);
      end
      // stop scan
      #Tp mii_scan_finish; // finish scan operation
  
      // wait for next positive clock edge
      repeat(10) @(posedge Mdc_O);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO === 1'bz) // Mdio_IO should not be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to late, Mdio_IO is HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set while MII IO signal is not active anymore");
          fail = fail + 1;
        end
        // Nvalid signal can be cleared here - it is still Testbench error
      end
      else // Busy bit should still be set to '1', Nvalid bit should still be set to '1'
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set while MII IO signal not HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] === 1'b0)
        begin
          test_fail("Nvalid signal should be set while MII IO signal not HIGH Z");
          fail = fail + 1;
        end
      end
  
      // wait for next negative clock edge
      @(negedge Mdc_O);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO === 1'bz) // Mdio_IO should not be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to late, Mdio_IO is HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set while MII IO signal is not active anymore");
          fail = fail + 1;
        end
        // Nvalid signal can be cleared here - it is still Testbench error
      end
      else // Busy bit should still be set to '1', Nvalid bit should still be set to '1'
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set while MII IO signal not HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] === 1'b0)
        begin
          test_fail("Nvalid signal should be set while MII IO signal not HIGH Z");
          fail = fail + 1;
        end
      end
  
      // wait for next negative clock edge
      @(posedge Mdc_O);
      // read data from MII status register - Busy and Nvalid bits
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
      // check MII IO signal and Busy and Nvalid bits
      if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
      begin
        test_fail("Testbench error - read was to early, Mdio_IO is not HIGH Z - set higher clock divider");
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal was not set while MII IO signal is not HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] === 1'b0)
        begin
          test_fail("Nvalid signal was not set while MII IO signal is not HIGH Z");
          fail = fail + 1;
        end
      end
      else // Busy bit should still be set to '1', Nvalid bit can be set to '0'
      begin
        if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
        begin
          test_fail("Busy signal should be set after MII IO signal become HIGH Z");
          fail = fail + 1;
        end
        if (phy_data[`ETH_MIISTATUS_NVALID] === 1'b0)
        begin
          i2 = 1; // check finished
        end
        else
        begin
          i2 = 0; // check must continue
        end
      end
  
      // wait for Busy to become inactive
      i1 = 0;
      while ((i1 <= 2) || (i2 == 0))
      begin
        // wait for next positive clock edge
        @(posedge Mdc_O);
        // read data from MII status register - Busy and Nvalid bits
        wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
        // check MII IO signal and Busy and Nvalid bits
        if (Mdio_IO !== 1'bz) // Mdio_IO should be HIGH Z here - testbench selfcheck
        begin
          test_fail("Testbench error - read was to early, Mdio_IO is not HIGH Z - set higher clock divider");
          if (i1 <= 2)
          begin
            if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
            begin
              test_fail("Busy signal was not set while MII IO signal is not HIGH Z");
              fail = fail + 1;
            end
          end
          if (i2 == 0)
          begin
            if (phy_data[`ETH_MIISTATUS_NVALID] === 1'b0)
            begin
              test_fail("Nvalid signal was not set while MII IO signal is not HIGH Z");
              fail = fail + 1;
            end
          end
        end
        else // wait for Busy bit to be set to '0'
        begin
          if (i1 <= 2)
          begin
            if (phy_data[`ETH_MIISTATUS_BUSY] === 1'b0)
            begin
              i1 = 3; // end of Busy checking
            end
            else
            begin
              if (i1 == 2)
              begin
                test_fail("Busy signal should be cleared after 2 periods after MII IO signal become HIGH Z");
                fail = fail + 1;
              end
              #Tp i1 = i1 + 1;
            end
          end
          if (i2 == 0)
          begin
            if (phy_data[`ETH_MIISTATUS_NVALID] === 1'b0)
            begin
              i2 = 1;
            end
            else
            begin
              test_fail("Nvalid signal should be cleared after MII IO signal become HIGH Z");
              fail = fail + 1;
            end
          end
        end
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test scan status from phy with detecting link-fail bit    ////
  ////  (with and without preamble)                               ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 14) // 
  begin
    // TEST 14: SCAN STATUS FROM PHY WITH DETECTING LINK-FAIL BIT ( WITH AND WITHOUT PREAMBLE )
    test_name   = "TEST 14: SCAN STATUS FROM PHY WITH DETECTING LINK-FAIL BIT ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 14: SCAN STATUS FROM PHY WITH DETECTING LINK-FAIL BIT ( WITH AND WITHOUT PREAMBLE )");
  
    // set link up, if it wasn't due to previous tests, since there weren't PHY registers
    #Tp eth_phy.link_up_down(1); 
    // set MII speed
    clk_div = 6;
    mii_set_clk_div(clk_div[7:0]);
    // set address
    reg_addr = 5'h1; // status register
    phy_addr = 5'h1; // correct PHY address
  
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data from PHY status register - remember LINK-UP status
    wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
    for (i = 0; i <= 1; i = i + 1)
    begin
      #Tp eth_phy.preamble_suppresed(i);
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i, 8'h0}) | (`ETH_MIIMODER_CLKDIV & clk_div),
                4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // scan request
      #Tp mii_scan_req(phy_addr, reg_addr);
      check_mii_scan_valid; // wait for scan to make first data valid
     
      fork
      begin 
        repeat(2) @(posedge Mdc_O);
        // read data from PHY status register
        wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (phy_data !== tmp_data)
        begin
          test_fail("Data was not correctly scaned from status register");
          fail = fail + 1;
        end
        // read data from MII status register
        wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (phy_data[0] !== 1'b0)
        begin
          test_fail("Link FAIL bit was set in the MII status register");
          fail = fail + 1;
        end
      end
      begin
      // Completely check second scan
        #Tp cnt = 0;
        // wait for serial bus to become active - second scan
        wait(Mdio_IO !== 1'bz);
        // count transfer length
        while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i == 0)) || ((cnt == 15) && (i == 1)) )
        begin
          @(posedge Mdc_O);
          #Tp cnt = cnt + 1;
        end
        // check transfer length
        if (i) // without preamble
        begin
          if (cnt != 33) // at this value Mdio_IO is HIGH Z
          begin
            test_fail("Second scan request did not proceed correctly");
            fail = fail + 1;
          end
        end
        else // with preamble
        begin
          if (cnt != 65) // at this value Mdio_IO is HIGH Z
          begin
            test_fail("Second scan request did not proceed correctly");
            fail = fail + 1;
          end
        end
      end
      join
      // check third to fifth scans
      for (i3 = 0; i3 <= 2; i3 = i3 + 1)
      begin
        fork
        begin
          repeat(2) @(posedge Mdc_O);
          // read data from PHY status register
          wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
          if (phy_data !== tmp_data)
          begin
            test_fail("Data was not correctly scaned from status register");
            fail = fail + 1;
          end
          // read data from MII status register
          wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
          if (phy_data[0] !== 1'b0)
          begin
            test_fail("Link FAIL bit was set in the MII status register");
            fail = fail + 1;
          end
          if (i3 == 2) // after fourth scan read
          begin
            @(posedge Mdc_O);
            // change saved data
            #Tp tmp_data = tmp_data & 16'hFFFB; // put bit 3 to ZERO
            // set link down
            #Tp eth_phy.link_up_down(0);
          end
        end
        begin
        // Completely check scans
          #Tp cnt = 0;
          // wait for serial bus to become active - second scan
          wait(Mdio_IO !== 1'bz);
          // count transfer length
          while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i == 0)) || ((cnt == 15) && (i == 1)) )
          begin
            @(posedge Mdc_O);
            #Tp cnt = cnt + 1;
          end
          // check transfer length
          if (i) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Fifth scan request did not proceed correctly");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Fifth scan request did not proceed correctly");
              fail = fail + 1;
            end
          end
        end
        join
      end
  
      fork
      begin
        repeat(2) @(posedge Mdc_O);
        // read data from PHY status register
        wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (phy_data !== tmp_data)
        begin
          test_fail("Data was not correctly scaned from status register");
          fail = fail + 1;
        end
        // read data from MII status register
        wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (phy_data[0] === 1'b0)
        begin
          test_fail("Link FAIL bit was not set in the MII status register");
          fail = fail + 1;
        end
        // wait to see if data stayed latched
        repeat(4) @(posedge Mdc_O);
        // read data from PHY status register
        wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (phy_data !== tmp_data)
        begin
          test_fail("Data was not latched correctly in status register");
          fail = fail + 1;
        end
        // read data from MII status register
        wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (phy_data[0] === 1'b0)
        begin
          test_fail("Link FAIL bit was not set in the MII status register");
          fail = fail + 1;
        end
        // change saved data
        #Tp tmp_data = tmp_data | 16'h0004; // put bit 2 to ONE
        // set link up
        #Tp eth_phy.link_up_down(1);
      end
      begin
      // Wait for sixth scan
        // wait for serial bus to become active - sixth scan
        wait(Mdio_IO !== 1'bz);
        // wait for serial bus to become inactive - turn-around cycle in sixth scan
        wait(Mdio_IO === 1'bz);
        // wait for serial bus to become active - end of turn-around cycle in sixth scan
        wait(Mdio_IO !== 1'bz);
        // wait for serial bus to become inactive - end of sixth scan
        wait(Mdio_IO === 1'bz);
      end
      join
  
      @(posedge Mdc_O);
      // read data from PHY status register
      wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (phy_data !== tmp_data)
      begin
        test_fail("Data was not correctly scaned from status register");
        fail = fail + 1;
      end
      // read data from MII status register
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (phy_data[0] !== 1'b0)
      begin
        test_fail("Link FAIL bit was set in the MII status register");
        fail = fail + 1;
      end
      // wait to see if data stayed latched
      repeat(4) @(posedge Mdc_O);
      // read data from PHY status register
      wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (phy_data !== tmp_data)
      begin
        test_fail("Data was not correctly scaned from status register");
        fail = fail + 1;
      end
      // read data from MII status register
      wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (phy_data[0] !== 1'b0)
      begin
        test_fail("Link FAIL bit was set in the MII status register");
        fail = fail + 1;
      end
  
      // STOP SCAN
      #Tp mii_scan_finish; // finish scan operation
      #Tp check_mii_busy; // wait for scan to finish
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test scan status from phy with sliding link-fail bit      ////
  ////  (with and without preamble)                               ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 15) // 
  begin
    // TEST 15: SCAN STATUS FROM PHY WITH SLIDING LINK-FAIL BIT ( WITH AND WITHOUT PREAMBLE )
    test_name   = "TEST 15: SCAN STATUS FROM PHY WITH SLIDING LINK-FAIL BIT ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 15: SCAN STATUS FROM PHY WITH SLIDING LINK-FAIL BIT ( WITH AND WITHOUT PREAMBLE )");
  
    // set address
    reg_addr = 5'h1; // status register
    phy_addr = 5'h1; // correct PHY address
  
    // read request
    #Tp mii_read_req(phy_addr, reg_addr);
    check_mii_busy; // wait for read to finish
    // read data from PHY status register - remember LINK-UP status
    wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
    for (i2 = 0; i2 <= 1; i2 = i2 + 1) // choose preamble or not
    begin
      #Tp eth_phy.preamble_suppresed(i2);
      // MII mode register
      #Tp wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i2, 8'h0}), 4'hF, 1, wbm_init_waits, 
                    wbm_subseq_waits);
      i = 0;
      while (i < 80) // delay for sliding of LinkFail bit
      begin
        // first there are two scans
        #Tp cnt = 0;
        // scan request
        #Tp mii_scan_req(phy_addr, reg_addr);
        #Tp check_mii_scan_valid; // wait for scan to make first data valid
  
        // check second scan
        fork
        begin
          repeat(4) @(posedge Mdc_O);
          // read data from PHY status register
          wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
          if (phy_data !== tmp_data)
          begin
            test_fail("Second data was not correctly scaned from status register");
            fail = fail + 1;
          end
          // read data from MII status register
          wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
          if (phy_data[0] !== 1'b0)
          begin
            test_fail("Link FAIL bit was set in the MII status register");
            fail = fail + 1;
          end
        end
        begin
        // Completely check scan
          #Tp cnt = 0;
          // wait for serial bus to become active - second scan
          wait(Mdio_IO !== 1'bz);
          // count transfer length
          while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
          begin
            @(posedge Mdc_O);
            #Tp cnt = cnt + 1;
          end
          // check transfer length
          if (i2) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Second scan request did not proceed correctly");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Second scan request did not proceed correctly");
              fail = fail + 1;
            end
          end
        end
        join
        // reset counter 
        #Tp cnt = 0;
        // SLIDING LINK DOWN and CHECK
        fork
          begin
          // set link down
            repeat(i) @(posedge Mdc_O);
            // set link down
            #Tp eth_phy.link_up_down(0);
          end
          begin
          // check data in MII registers after each scan in this fork statement
            if (i2) // without preamble
              wait (cnt == 32);
            else // with preamble
              wait (cnt == 64);
            repeat(3) @(posedge Mdc_O);
            // read data from PHY status register
            wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if ( ((i < 49) && !i2) || ((i < 17) && i2) )
            begin
              if (phy_data !== (tmp_data & 16'hFFFB)) // bit 3 is ZERO
              begin
                test_fail("Third data was not correctly scaned from status register");
                fail = fail + 1;
              end
            end
            else
            begin
              if (phy_data !== tmp_data)
              begin
                test_fail("Third data was not correctly scaned from status register");
                fail = fail + 1;
              end
            end
            // read data from MII status register
            wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if ( ((i < 49) && !i2) || ((i < 17) && i2) )
            begin
              if (phy_data[0] === 1'b0)
              begin
                test_fail("Link FAIL bit was not set in the MII status register");
                fail = fail + 1;
              end
            end
            else
            begin
              if (phy_data[0] !== 1'b0)
              begin
                test_fail("Link FAIL bit was set in the MII status register");
                fail = fail + 1;
              end
            end
          end
          begin
          // check length
            for (i3 = 0; i3 <= 1; i3 = i3 + 1) // two scans
            begin
              #Tp cnt = 0;
              // wait for serial bus to become active if there is more than one scan
              wait(Mdio_IO !== 1'bz);
              // count transfer length
              while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
              begin
                @(posedge Mdc_O);
                #Tp cnt = cnt + 1;
              end
              // check transfer length
              if (i2) // without preamble
              begin
                if (cnt != 33) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("3. or 4. scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
              else // with preamble
              begin
                if (cnt != 65) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("3. or 4. scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
            end
          end
        join
        // reset counter
        #Tp cnt = 0;
        // check fifth scan and data from fourth scan
        fork
        begin
          repeat(2) @(posedge Mdc_O);
          // read data from PHY status register
          wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
          if (phy_data !== (tmp_data & 16'hFFFB)) // bit 3 is ZERO
          begin
            test_fail("4. data was not correctly scaned from status register");
            fail = fail + 1;
          end
          // read data from MII status register
          wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
          if (phy_data[0] === 1'b0)
          begin
            test_fail("Link FAIL bit was not set in the MII status register");
            fail = fail + 1;
          end
        end
        begin
        // Completely check intermediate scan
          #Tp cnt = 0;
          // wait for serial bus to become active - second scan
          wait(Mdio_IO !== 1'bz);
          // count transfer length
          while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
          begin
            @(posedge Mdc_O);
            #Tp cnt = cnt + 1;
          end
          // check transfer length
          if (i2) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Fifth scan request did not proceed correctly");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("Fifth scan request did not proceed correctly");
              fail = fail + 1;
            end
          end
        end
        join
        // reset counter 
        #Tp cnt = 0;
        // SLIDING LINK UP and CHECK
        fork
          begin
          // set link up
            repeat(i) @(posedge Mdc_O);
            // set link up
            #Tp eth_phy.link_up_down(1);
          end
          begin
          // check data in MII registers after each scan in this fork statement
            repeat(2) @(posedge Mdc_O);
            if (i2) // without preamble
              wait (cnt == 32);
            else // with preamble
              wait (cnt == 64);
            repeat(3) @(posedge Mdc_O);
            // read data from PHY status register
            wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if ( ((i < 49) && !i2) || ((i < 17) && i2) )
            begin
              if (phy_data !== tmp_data) 
              begin
                test_fail("6. data was not correctly scaned from status register");
                fail = fail + 1;
              end
            end
            else
            begin
              if (phy_data !== (tmp_data & 16'hFFFB)) // bit 3 is ZERO
              begin
                test_fail("6. data was not correctly scaned from status register");
                fail = fail + 1;
              end
            end
            // read data from MII status register
            wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if ( ((i < 49) && !i2) || ((i < 17) && i2) )
            begin
              if (phy_data[0] !== 1'b0)
              begin
                test_fail("Link FAIL bit was set in the MII status register");
                fail = fail + 1;
              end
            end
            else
            begin
              if (phy_data[0] === 1'b0)
              begin
                test_fail("Link FAIL bit was not set in the MII status register");
                fail = fail + 1;
              end
            end
          end
          begin
          // check length
            for (i3 = 0; i3 <= 1; i3 = i3 + 1) // two scans
            begin
              #Tp cnt = 0;
              // wait for serial bus to become active if there is more than one scan
              wait(Mdio_IO !== 1'bz);
              // count transfer length
              while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
              begin
                @(posedge Mdc_O);
                #Tp cnt = cnt + 1;
              end
              // check transfer length
              if (i2) // without preamble
              begin
                if (cnt != 33) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("Scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
              else // with preamble
              begin
                if (cnt != 65) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("Scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
            end
          end
        join
        // check last scan 
        repeat(4) @(posedge Mdc_O);
        // read data from PHY status register
        wbm_read(`ETH_MIIRX_DATA, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (phy_data !== tmp_data)
        begin
          test_fail("7. data was not correctly scaned from status register");
          fail = fail + 1;
        end
        // read data from MII status register
        wbm_read(`ETH_MIISTATUS, phy_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (phy_data[0] !== 1'b0)
        begin
          test_fail("Link FAIL bit was set in the MII status register");
          fail = fail + 1;
        end
  
        #Tp mii_scan_finish; // finish scan operation
        #Tp check_mii_busy; // wait for scan to finish
        #Tp;
        // set delay of writing the command
        if (i2) // without preamble
        begin
          case(i)
            0,  1,  2,  3,  4:  i = i + 1;
            13, 14, 15, 16, 17,
            18, 19, 20, 21, 22,
            23, 24, 25, 26, 27,
            28, 29, 30, 31, 32,
            33, 34, 35:         i = i + 1;
            36:                 i = 80;
            default:            i = 13;
          endcase
        end
        else // with preamble
        begin
          case(i)
            0,  1,  2,  3,  4:  i = i + 1;
            45, 46, 47, 48, 49,
            50, 51, 52, 53, 54, 
            55, 56, 57, 58, 59, 
            60, 61, 62, 63, 64, 
            65, 66, 67:         i = i + 1;
            68:                 i = 80;
            default:            i = 45;
          endcase
        end
        @(posedge wb_clk);
        #Tp;
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test sliding stop scan command immediately after scan     ////
  ////  request (with and without preamble)                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 16) // 
  begin
    // TEST 16: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER SCAN REQUEST ( WITH AND WITHOUT PREAMBLE )
    test_name = "TEST 16: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER SCAN REQUEST ( WITH AND WITHOUT PREAMBLE )";
    `TIME; 
    $display("  TEST 16: SLIDING STOP SCAN COMMAND IMMEDIATELY AFTER SCAN REQUEST ( WITH AND WITHOUT PREAMBLE )");
  
    for (i2 = 0; i2 <= 1; i2 = i2 + 1) // choose preamble or not
    begin
      #Tp eth_phy.preamble_suppresed(i2);
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i2, 8'h0}), 4'hF, 1, wbm_init_waits, 
                wbm_subseq_waits);
      i = 0;
      cnt = 0;
      while (i < 80) // delay for sliding of writing a STOP SCAN command
      begin
        for (i3 = 0; i3 <= 1; i3 = i3 + 1) // choose read or write after scan will be finished
        begin
          // set address
          reg_addr = 5'h0; // control register
          phy_addr = 5'h1; // correct PHY address
          cnt = 0;
          // scan request
          #Tp mii_scan_req(phy_addr, reg_addr);
          fork
            begin
              repeat(i) @(posedge Mdc_O);
              // write command 0x0 into MII command register
              // MII command written while scan in progress
              wbm_write(`ETH_MIICOMMAND, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
              @(posedge wb_clk);
              #Tp check_mii_busy; // wait for scan to finish
              @(posedge wb_clk);
              disable check;
            end
            begin: check
              // wait for serial bus to become active
              wait(Mdio_IO !== 1'bz);
              // count transfer length
              while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
              begin
                @(posedge Mdc_O);
                #Tp cnt = cnt + 1;
              end
              // check transfer length
              if (i2) // without preamble
              begin
                if (cnt != 33) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
              else // with preamble
              begin
                if (cnt != 65) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
              cnt = 0;
              // wait for serial bus to become active if there is more than one scan
              wait(Mdio_IO !== 1'bz);
              // count transfer length
              while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
              begin
                @(posedge Mdc_O);
                #Tp cnt = cnt + 1;
              end
              // check transfer length
              if (i2) // without preamble
              begin
                if (cnt != 33) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
              else // with preamble
              begin
                if (cnt != 65) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
            end
          join
          // check the BUSY signal to see if the bus is still IDLE
          for (i1 = 0; i1 < 8; i1 = i1 + 1)
            check_mii_busy; // wait for bus to become idle
    
          // try normal write or read after scan was finished
          phy_data = {8'h7D, (i[7:0] + 1'b1)};
          cnt = 0;
          if (i3 == 0) // write after scan
          begin
            // write request
            #Tp mii_write_req(phy_addr, reg_addr, phy_data);
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while(Mdio_IO !== 1'bz)
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            @(posedge Mdc_O);
            // read request
            #Tp mii_read_req(phy_addr, reg_addr);
            check_mii_busy; // wait for read to finish
            // read and check data
            wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (phy_data !== tmp_data)
            begin
              test_fail("Data was not correctly written into OR read from PHY register - control register");
              fail = fail + 1;
            end
          end
          else // read after scan
          begin
            // read request
            #Tp mii_read_req(phy_addr, reg_addr);
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            @(posedge Mdc_O);
            check_mii_busy; // wait for read to finish
            // read and check data
            wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (phy_data !== tmp_data)
            begin
              test_fail("Data was not correctly written into OR read from PHY register - control register");
              fail = fail + 1;
            end
          end
          // check if transfer was a proper length
          if (i2) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("New request did not proceed correctly, after scan request");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("New request did not proceed correctly, after scan request");
              fail = fail + 1;
            end
          end
        end
        #Tp;
        // set delay of writing the command
        if (i2) // without preamble
        begin
          case(i)
            0, 1:               i = i + 1;
            18, 19, 20, 21, 22,
            23, 24, 25, 26, 27,
            28, 29, 30, 31, 32,
            33, 34, 35:         i = i + 1;
            36:                 i = 80;
            default:            i = 18;
          endcase
        end
        else // with preamble
        begin
          case(i)
            0, 1:               i = i + 1;
            50, 51, 52, 53, 54, 
            55, 56, 57, 58, 59, 
            60, 61, 62, 63, 64, 
            65, 66, 67:         i = i + 1;
            68:                 i = 80;
            default:            i = 50;
          endcase
        end
        @(posedge wb_clk);
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test sliding stop scan command after 2. scan (with and    ////
  ////  without preamble)                                         ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 17) // 
  begin
    // TEST 17: SLIDING STOP SCAN COMMAND AFTER 2. SCAN ( WITH AND WITHOUT PREAMBLE )
    test_name = "TEST 17: SLIDING STOP SCAN COMMAND AFTER 2. SCAN ( WITH AND WITHOUT PREAMBLE )";
    `TIME; $display("  TEST 17: SLIDING STOP SCAN COMMAND AFTER 2. SCAN ( WITH AND WITHOUT PREAMBLE )");
  
    for (i2 = 0; i2 <= 1; i2 = i2 + 1) // choose preamble or not
    begin
      #Tp eth_phy.preamble_suppresed(i2);
      // MII mode register
      wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_NOPRE & {23'h0, i2, 8'h0}), 4'hF, 1, wbm_init_waits, 
                wbm_subseq_waits);
  
      i = 0;
      cnt = 0;
      while (i < 80) // delay for sliding of writing a STOP SCAN command
      begin
        for (i3 = 0; i3 <= 1; i3 = i3 + 1) // choose read or write after scan will be finished
        begin
          // first there are two scans
          // set address
          reg_addr = 5'h0; // control register
          phy_addr = 5'h1; // correct PHY address
          cnt = 0;
          // scan request
          #Tp mii_scan_req(phy_addr, reg_addr);
          // wait and check first 2 scans
          begin
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            // check transfer length
            if (i2) // without preamble
            begin
              if (cnt != 33) // at this value Mdio_IO is HIGH Z
              begin
                test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                fail = fail + 1;
              end
            end
            else // with preamble
            begin
              if (cnt != 65) // at this value Mdio_IO is HIGH Z
              begin
                test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                fail = fail + 1;
              end
            end
            cnt = 0;
            // wait for serial bus to become active if there is more than one scan
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            // check transfer length
            if (i2) // without preamble
            begin
              if (cnt != 33) // at this value Mdio_IO is HIGH Z
              begin
                test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                fail = fail + 1;
              end
            end
            else // with preamble
            begin
              if (cnt != 65) // at this value Mdio_IO is HIGH Z
              begin
                test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                fail = fail + 1;
              end
            end
          end
  
          // reset counter 
          cnt = 0;
          fork
            begin
              repeat(i) @(posedge Mdc_O);
              // write command 0x0 into MII command register
              // MII command written while scan in progress
              wbm_write(`ETH_MIICOMMAND, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
              @(posedge wb_clk);
              #Tp check_mii_busy; // wait for scan to finish
              @(posedge wb_clk);
              disable check_3;
            end
            begin: check_3
              // wait for serial bus to become active
              wait(Mdio_IO !== 1'bz);
              // count transfer length
              while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
              begin
                @(posedge Mdc_O);
                #Tp cnt = cnt + 1;
              end
              // check transfer length
              if (i2) // without preamble
              begin
                if (cnt != 33) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
              else // with preamble
              begin
                if (cnt != 65) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
              cnt = 0;
              // wait for serial bus to become active if there is more than one scan
              wait(Mdio_IO !== 1'bz);
              // count transfer length
              while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
              begin
                @(posedge Mdc_O);
                #Tp cnt = cnt + 1;
              end
              // check transfer length
              if (i2) // without preamble
              begin
                if (cnt != 33) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
              else // with preamble
              begin
                if (cnt != 65) // at this value Mdio_IO is HIGH Z
                begin
                  test_fail("First scan request did not proceed correctly, while SCAN STOP was written");
                  fail = fail + 1;
                end
              end
            end
          join
          // check the BUSY signal to see if the bus is still IDLE
          for (i1 = 0; i1 < 8; i1 = i1 + 1)
            check_mii_busy; // wait for bus to become idle
    
          // try normal write or read after scan was finished
          phy_data = {8'h7D, (i[7:0] + 1'b1)};
          cnt = 0;
          if (i3 == 0) // write after scan
          begin
            // write request
            #Tp mii_write_req(phy_addr, reg_addr, phy_data);
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while(Mdio_IO !== 1'bz)
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            @(posedge Mdc_O);
            // read request
            #Tp mii_read_req(phy_addr, reg_addr);
            check_mii_busy; // wait for read to finish
            // read and check data
            wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (phy_data !== tmp_data)
            begin
              test_fail("Data was not correctly written into OR read from PHY register - control register");
              fail = fail + 1;
            end
          end
          else // read after scan
          begin
            // read request
            #Tp mii_read_req(phy_addr, reg_addr);
            // wait for serial bus to become active
            wait(Mdio_IO !== 1'bz);
            // count transfer length
            while( (Mdio_IO !== 1'bz) || ((cnt == 47) && (i2 == 0)) || ((cnt == 15) && (i2 == 1)) )
            begin
              @(posedge Mdc_O);
              #Tp cnt = cnt + 1;
            end
            @(posedge Mdc_O);
            check_mii_busy; // wait for read to finish
            // read and check data
            wbm_read(`ETH_MIIRX_DATA, tmp_data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
            if (phy_data !== tmp_data)
            begin
              test_fail("Data was not correctly written into OR read from PHY register - control register");
              fail = fail + 1;
            end
          end
          // check if transfer was a proper length
          if (i2) // without preamble
          begin
            if (cnt != 33) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("New request did not proceed correctly, after scan request");
              fail = fail + 1;
            end
          end
          else // with preamble
          begin
            if (cnt != 65) // at this value Mdio_IO is HIGH Z
            begin
              test_fail("New request did not proceed correctly, after scan request");
              fail = fail + 1;
            end
          end
        end
        #Tp;
        // set delay of writing the command
        if (i2) // without preamble
        begin
          case(i)
            0, 1:               i = i + 1;
            18, 19, 20, 21, 22,
            23, 24, 25, 26, 27,
            28, 29, 30, 31, 32,
            33, 34, 35:         i = i + 1;
            36:                 i = 80;
            default:            i = 18;
          endcase
        end
        else // with preamble
        begin
          case(i)
            0, 1:               i = i + 1;
            50, 51, 52, 53, 54, 
            55, 56, 57, 58, 59, 
            60, 61, 62, 63, 64, 
            65, 66, 67:         i = i + 1;
            68:                 i = 80;
            default:            i = 50;
          endcase
        end
        @(posedge wb_clk);
      end
    end
    // set PHY to normal mode
    #Tp eth_phy.preamble_suppresed(0);
    // MII mode register
    wbm_write(`ETH_MIIMODER, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end

end   //  for (test_num=start_task; test_num <= end_task; test_num=test_num+1)

end
endtask // test_mii


task test_mac_full_duplex_transmit;
  input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        bit_start_1;
  integer        bit_end_1;
  integer        bit_start_2;
  integer        bit_end_2;
  integer        num_of_reg;
  integer        num_of_frames;
  integer        num_of_bd;
  integer        i_addr;
  integer        i_data;
  integer        i_length;
  integer        tmp_len;
  integer        tmp_bd;
  integer        tmp_bd_num;
  integer        tmp_data;
  integer        tmp_ipgt;
  integer        test_num;
  reg    [31:0]  tx_bd_num;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_data;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_tmp_data;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        fail;
  integer        speed;
  reg            no_underrun;
  reg            frame_started;
  reg            frame_ended;
  reg            wait_for_frame;
  reg    [31:0]  addr;
  reg    [31:0]  data;
  reg    [31:0]  tmp;
  reg    [ 7:0]  st_data;
  reg    [15:0]  max_tmp;
  reg    [15:0]  min_tmp;

begin
// MAC FULL DUPLEX TRANSMIT TEST
test_heading("MAC FULL DUPLEX TRANSMIT TEST");
$display(" ");
$display("MAC FULL DUPLEX TRANSMIT TEST");
fail = 0;

// reset MAC registers
hard_reset;
// set wb slave response
wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

  /*
  TASKS for set and control TX buffer descriptors (also send packet - set_tx_bd_ready):
  -------------------------------------------------------------------------------------
  set_tx_bd 
    (tx_bd_num_start[6:0], tx_bd_num_end[6:0], len[15:0], irq, pad, crc, txpnt[31:0]);
  set_tx_bd_wrap 
    (tx_bd_num_end[6:0]);
  set_tx_bd_ready 
    (tx_bd_num_start[6:0], tx_bd_num_end[6:0]);
  check_tx_bd 
    (tx_bd_num_start[6:0], tx_bd_status[31:0]);
  clear_tx_bd 
    (tx_bd_num_start[6:0], tx_bd_num_end[6:0]);

  TASKS for set and control RX buffer descriptors:
  ------------------------------------------------
  set_rx_bd 
    (rx_bd_num_strat[6:0], rx_bd_num_end[6:0], irq, rxpnt[31:0]);
  set_rx_bd_wrap 
    (rx_bd_num_end[6:0]);
  set_rx_bd_empty 
    (rx_bd_num_strat[6:0], rx_bd_num_end[6:0]);
  check_rx_bd 
    (rx_bd_num_end[6:0], rx_bd_status);
  clear_rx_bd 
    (rx_bd_num_strat[6:0], rx_bd_num_end[6:0]);

  TASKS for set and check TX packets:
  -----------------------------------
  set_tx_packet 
    (txpnt[31:0], len[15:0], eth_start_data[7:0]);
  check_tx_packet 
    (txpnt_wb[31:0], txpnt_phy[31:0], len[15:0], failure[31:0]);

  TASKS for set and check RX packets:
  -----------------------------------
  set_rx_packet 
    (rxpnt[31:0], len[15:0], plus_nibble, d_addr[47:0], s_addr[47:0], type_len[15:0], start_data[7:0]);
  check_rx_packet 
    (rxpnt_phy[31:0], rxpnt_wb[31:0], len[15:0], plus_nibble, successful_nibble, failure[31:0]);

  TASKS for append and check CRC to/of TX packet:
  -----------------------------------------------
  append_tx_crc 
    (txpnt_wb[31:0], len[15:0], negated_crc);
  check_tx_crc 
    (txpnt_phy[31:0], len[15:0], negated_crc, failure[31:0]); 

  TASK for append CRC to RX packet (CRC is checked together with check_rx_packet):
  --------------------------------------------------------------------------------
  append_rx_crc 
    (rxpnt_phy[31:0], len[15:0], plus_nibble, negated_crc);
  */

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  test_mac_full_duplex_transmit:                              ////
////                                                              ////
////  0: Test no transmit when all buffers are RX ( 10Mbps ).     ////
////  1: Test no transmit when all buffers are RX ( 100Mbps ).    ////
////  2: Test transmit packets from MINFL to MAXFL sizes at       ////
////     one TX buffer decriptor ( 10Mbps ).                      ////
////  3: Test transmit packets from MINFL to MAXFL sizes at       ////
////     one TX buffer decriptor ( 100Mbps ).                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin

  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test no transmit when all buffers are RX ( 10Mbps ).      ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 0) //
  begin
    // TEST 0: NO TRANSMIT WHEN ALL BUFFERS ARE RX ( 10Mbps )
    test_name   = "TEST 0: NO TRANSMIT WHEN ALL BUFFERS ARE RX ( 10Mbps )";
    `TIME; $display("  TEST 0: NO TRANSMIT WHEN ALL BUFFERS ARE RX ( 10Mbps )");
  
    // unmask interrupts
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set all buffer descriptors to RX - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;
  
    i = 0;
    while (i < 128)
    begin
      for (i1 = 0; i1 <= i; i1 = i1 + 1)
      begin
        set_tx_packet((`MEMORY_BASE + (i1 * 200)), 100, 0);
        set_tx_bd(i1, i1, 100, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + (i1 * 200)));
      end
      set_tx_bd_wrap(i);
      fork
        begin
          set_tx_bd_ready(0, i);
          repeat(20) @(negedge mtx_clk);
          #1 disable check_tx_en10;
        end
        begin: check_tx_en10
          wait (MTxEn === 1'b1);
          test_fail("Tramsmit should not start at all");
          fail = fail + 1;
          `TIME; $display("*E Transmit of %d packets should not start at all - active MTxEn", i);
        end
      join
      for (i2 = 0; i2 < 20; i2 = i2 + 1)
      begin
        check_tx_bd(0, tmp);
        #1;
        if (tmp[15] === 1'b0)
        begin
          test_fail("Tramsmit should not start at all");
          fail = fail + 1;
          `TIME; $display("*E Transmit of %d packets should not start at all - ready is 0", i);
        end
        if (tmp[8:0] !== 0)
        begin
          test_fail("Tramsmit should not be finished since it should not start at all");
          fail = fail + 1;
          `TIME; $display("*E Transmit of should not be finished since it should not start at all");
        end
        @(posedge wb_clk);
      end
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (tmp[6:0] !== 0)
      begin
        test_fail("Tramsmit should not get INT since it should not start at all");
        fail = fail + 1;
        `TIME; $display("*E Transmit of should not get INT since it should not start at all");
      end
      clear_tx_bd(0, i);
      if ((i < 5) || (i > 124))
        i = i + 1;
      else
        i = i + 120;
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test no transmit when all buffers are RX ( 100Mbps ).     ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 1) //
  begin
    // TEST 1: NO TRANSMIT WHEN ALL BUFFERS ARE RX ( 100Mbps )
    test_name   = "TEST 1: NO TRANSMIT WHEN ALL BUFFERS ARE RX ( 100Mbps )";
    `TIME; $display("  TEST 1: NO TRANSMIT WHEN ALL BUFFERS ARE RX ( 100Mbps )");
  
    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set all buffer descriptors to RX - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;
  
    i = 0;
    while (i < 128)
    begin
      for (i1 = 0; i1 <= i; i1 = i1 + 1)
      begin
        set_tx_packet((`MEMORY_BASE + (i1 * 200)), 100, 0);
        set_tx_bd(i1, i1, 100, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + (i1 * 200)));
      end
      set_tx_bd_wrap(i);
      fork
        begin
          set_tx_bd_ready(0, i);
          repeat(20) @(negedge mtx_clk);
          #1 disable check_tx_en100;
        end
        begin: check_tx_en100
          wait (MTxEn === 1'b1);
          test_fail("Tramsmit should not start at all");
          fail = fail + 1;
          `TIME; $display("*E Transmit of %d packets should not start at all - active MTxEn", i);
        end
      join
      for (i2 = 0; i2 < 20; i2 = i2 + 1)
      begin
        check_tx_bd(0, tmp);
        #1;
        if (tmp[15] === 1'b0)
        begin
          test_fail("Tramsmit should not start at all");
          fail = fail + 1;
          `TIME; $display("*E Transmit of %d packets should not start at all - ready is 0", i);
        end
        if (tmp[8:0] !== 0)
        begin
          test_fail("Tramsmit should not be finished since it should not start at all");
          fail = fail + 1;
          `TIME; $display("*E Transmit of should not be finished since it should not start at all");
        end
        @(posedge wb_clk);
      end
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (tmp[6:0] !== 0)
      begin
        test_fail("Tramsmit should not get INT since it should not start at all");
        fail = fail + 1;
        `TIME; $display("*E Transmit of should not get INT since it should not start at all");
      end
      clear_tx_bd(0, i);
      if ((i < 5) || (i > 124))
        i = i + 1;
      else
        i = i + 120;
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets from MINFL to MAXFL sizes at        ////
  ////  one TX buffer decriptor ( 10Mbps ).                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 2) //
  begin
    // TEST 2: TRANSMIT PACKETS FROM MINFL TO MAXFL SIZES AT ONE TX BD ( 10Mbps )
    test_name = "TEST 2: TRANSMIT PACKETS FROM MINFL TO MAXFL SIZES AT ONE TX BD ( 10Mbps )";
    `TIME; $display("  TEST 2: TRANSMIT PACKETS FROM MINFL TO MAXFL SIZES AT ONE TX BD ( 10Mbps )");
  
    max_tmp = 0;
    min_tmp = 0;
    // set one TX buffer descriptor - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h1, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, NO padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h01;
    set_tx_packet(`MEMORY_BASE, (max_tmp), st_data); // length without CRC
    st_data = 8'h10;
    set_tx_packet((`MEMORY_BASE + max_tmp), (max_tmp), st_data); // length without CRC
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;
  
    i_length = (min_tmp - 4);
    while (i_length <= (max_tmp - 4))
    begin
      // choose generating carrier sense and collision for first and last 64 lengths of frames
      case (i_length[1:0])
      2'h0: // Interrupt is generated
      begin
        // enable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + i_length[1:0]));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is not generated
      begin
        // enable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b0, 1'b1, 1'b1, (`MEMORY_BASE + i_length[1:0]));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b0, 1'b1, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      eth_phy.set_tx_mem_addr(max_tmp);
      // set wrap bit
      set_tx_bd_wrap(0);
      set_tx_bd_ready(0, 0);
      #1 check_tx_bd(0, data);


      if (i_length < min_tmp) // just first four
      begin
        while (data[15] === 1)
        begin
          #1 check_tx_bd(0, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      else if (i_length > (max_tmp - 8)) // just last four
      begin
        tmp = 0;
        wait (MTxEn === 1'b1); // start transmit
        while (tmp < (i_length - 20))
        begin
          #1 tmp = tmp + 1;
          @(posedge wb_clk);
        end
        #1 check_tx_bd(0, data);
        while (data[15] === 1)
        begin
          #1 check_tx_bd(0, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      else
      begin
        wait (MTxEn === 1'b1); // start transmit
        #1 check_tx_bd(0, data);
        if (data[15] !== 1)
        begin
          test_fail("Wrong buffer descriptor's ready bit read out from MAC");
          fail = fail + 1;
        end
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
          #1 check_tx_bd(0, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end

      repeat(5) @(posedge mtx_clk);  // Wait some time so PHY stores the CRC

      // check length of a PACKET
      if (eth_phy.tx_len != (i_length + 4))
      begin
        test_fail("Wrong length of the packet out from MAC");
        fail = fail + 1;
      end
      // checking in the following if statement is performed only for first and last 64 lengths
      if ( ((i_length + 4) <= (min_tmp + 64)) || ((i_length + 4) > (max_tmp - 64)) )
      begin
        // check transmitted TX packet data
        if (i_length[0] == 0)
        begin
          check_tx_packet((`MEMORY_BASE + i_length[1:0]), max_tmp, i_length, tmp);
        end
        else
        begin
          check_tx_packet(((`MEMORY_BASE + i_length[1:0]) + max_tmp), max_tmp, i_length, tmp);
        end
        if (tmp > 0)
        begin
          test_fail("Wrong data of the transmitted packet");
          fail = fail + 1;
        end
        // check transmited TX packet CRC
        check_tx_crc(max_tmp, i_length, 1'b0, tmp); // length without CRC

        if (tmp > 0)
        begin
          test_fail("Wrong CRC of the transmitted packet");
          fail = fail + 1;
        end
      end
      // check WB INT signal
      if (i_length[1:0] == 2'h0)
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(0, data);
      if (i_length[1] == 1'b0) // interrupt enabled
      begin
        if (data[15:0] !== 16'h7800)
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else // interrupt not enabled
      begin
        if (data[15:0] !== 16'h3800)
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear TX buffer descriptor
      clear_tx_bd(0, 0);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1))
      begin
        if ((data & `ETH_INT_TXB) !== 1'b1)
        begin
          `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Transmit Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_TXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Transmit Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Transmit Buffer) was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Transmit Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if ((i_length + 4) == (min_tmp + 64))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 64)
        $display("    pads appending to packets is NOT selected");
        $display("    ->packets with lengths from %0d (MINFL) to %0d are checked (length increasing by 1 byte)",
                 min_tmp, (min_tmp + 64));
        // set padding, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (max_tmp - 16))
      begin
        // starting length is for +128 longer than previous ending length, while ending length is tmp_data
        $display("    pads appending to packets is selected");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 128 bytes)",
                 (min_tmp + 64 + 128), tmp_data); 
        // reset padding, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == max_tmp)
      begin
        $display("    pads appending to packets is NOT selected");
        $display("    ->packets with lengths from %0d to %0d (MAXFL) are checked (length increasing by 1 byte)",
                 (max_tmp - (4 + 16)), max_tmp);
      end
      // set length (loop variable)
      if ((i_length + 4) < (min_tmp + 64))
        i_length = i_length + 1;
      else if ( ((i_length + 4) >= (min_tmp + 64)) && ((i_length + 4) <= (max_tmp - 256)) )
      begin
        i_length = i_length + 128;
        tmp_data = i_length + 4; // last tmp_data is ending length
      end
      else if ( ((i_length + 4) > (max_tmp - 256)) && ((i_length + 4) < (max_tmp - 16)) )
        i_length = max_tmp - (4 + 16);
      else if ((i_length + 4) >= (max_tmp - 16))
        i_length = i_length + 1;
      else
      begin
        $display("*E TESTBENCH ERROR - WRONG PARAMETERS IN TESTBENCH");
        #10 $stop;
      end
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets from MINFL to MAXFL sizes at        ////
  ////  one TX buffer decriptor ( 100Mbps ).                      ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 3) //
  begin
    // TEST 3: TRANSMIT PACKETS FROM MINFL TO MAXFL SIZES AT ONE TX BD ( 100Mbps )
    test_name = "TEST 3: TRANSMIT PACKETS FROM MINFL TO MAXFL SIZES AT ONE TX BD ( 100Mbps )";
    `TIME; $display("  TEST 3: TRANSMIT PACKETS FROM MINFL TO MAXFL SIZES AT ONE TX BD ( 100Mbps )");
  
    max_tmp = 0;
    min_tmp = 0;
    // set one TX buffer descriptor - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h1, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, NO padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h5A;
    set_tx_packet(`MEMORY_BASE, (max_tmp), st_data); // length without CRC
    st_data = 8'h10;
    set_tx_packet((`MEMORY_BASE + max_tmp), (max_tmp), st_data); // length without CRC
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;

    i_length = (min_tmp - 4);
    while (i_length <= (max_tmp - 4))
    begin
      // choose generating carrier sense and collision
      case (i_length[1:0])
      2'h0: // Interrupt is generated
      begin
        // enable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + i_length[1:0]));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is not generated
      begin
        // enable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b0, 1'b1, 1'b1, (`MEMORY_BASE + i_length[1:0]));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b0, 1'b1, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      eth_phy.set_tx_mem_addr(max_tmp);
      // set wrap bit
      set_tx_bd_wrap(0);
      set_tx_bd_ready(0, 0);
      #1 check_tx_bd(0, data);
      if (i_length < min_tmp) // just first four
      begin
        while (data[15] === 1)
        begin
          #1 check_tx_bd(0, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      else if (i_length > (max_tmp - 8)) // just last four
      begin
        tmp = 0;
        wait (MTxEn === 1'b1); // start transmit
        while (tmp < (i_length - 20))
        begin
          #1 tmp = tmp + 1;
          @(posedge wb_clk);
        end
        #1 check_tx_bd(0, data);
        while (data[15] === 1)
        begin
          #1 check_tx_bd(0, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      else
      begin
        wait (MTxEn === 1'b1); // start transmit
        #1 check_tx_bd(0, data);
        if (data[15] !== 1)
        begin
          test_fail("Wrong buffer descriptor's ready bit read out from MAC");
          fail = fail + 1;
        end
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
          #1 check_tx_bd(0, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      // check length of a PACKET
      if (eth_phy.tx_len != (i_length + 4))
      begin
        test_fail("Wrong length of the packet out from MAC");
        fail = fail + 1;
      end
      // check transmitted TX packet data
      if (i_length[0] == 0)
      begin
        check_tx_packet((`MEMORY_BASE + i_length[1:0]), max_tmp, i_length, tmp);
      end
      else
      begin
        check_tx_packet(((`MEMORY_BASE + i_length[1:0]) + max_tmp), max_tmp, i_length, tmp);
      end
      if (tmp > 0)
      begin
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end
      // check transmited TX packet CRC
      check_tx_crc(max_tmp, i_length, 1'b0, tmp); // length without CRC
      if (tmp > 0)
      begin
        test_fail("Wrong CRC of the transmitted packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (i_length[1:0] == 2'h0)
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(0, data);
      if (i_length[1] == 1'b0) // interrupt enabled
      begin
        if (data[15:0] !== 16'h7800)
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else // interrupt not enabled
      begin
        if (data[15:0] !== 16'h3800)
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear TX buffer descriptor
      clear_tx_bd(0, 0);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1))
      begin
        if ((data & `ETH_INT_TXB) !== 1'b1)
        begin
          `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Transmit Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_TXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Transmit Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Transmit Buffer) was set, interrupt reg: %0h", data);
          test_fail("Any of interrupts (except Transmit Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if ((i_length + 4) == (min_tmp + 64))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 64)
        $display("    pads appending to packets is NOT selected");
        $display("    ->packets with lengths from %0d (MINFL) to %0d are checked (length increasing by 1 byte)",
                 min_tmp, (min_tmp + 64));
        // set padding, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (max_tmp - 16))
      begin
        // starting length is for +128 longer than previous ending length, while ending length is tmp_data
        $display("    pads appending to packets is selected");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 128 bytes)",
                 (min_tmp + 64 + 128), tmp_data); 
        // reset padding, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == max_tmp)
      begin
        $display("    pads appending to packets is NOT selected");
        $display("    ->packets with lengths from %0d to %0d (MAXFL) are checked (length increasing by 1 byte)",
                 (max_tmp - (4 + 16)), max_tmp);
      end
      // set length (loop variable)
      if ((i_length + 4) < (min_tmp + 64))
        i_length = i_length + 1;
      else if ( ((i_length + 4) >= (min_tmp + 64)) && ((i_length + 4) <= (max_tmp - 256)) )
      begin
        i_length = i_length + 128;
        tmp_data = i_length + 4; // last tmp_data is ending length
      end
      else if ( ((i_length + 4) > (max_tmp - 256)) && ((i_length + 4) < (max_tmp - 16)) )
        i_length = max_tmp - (4 + 16);
      else if ((i_length + 4) >= (max_tmp - 16))
        i_length = i_length + 1;
      else
      begin
        $display("*E TESTBENCH ERROR - WRONG PARAMETERS IN TESTBENCH");
        #10 $stop;
      end
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets from MINFL to MAXFL sizes at        ////
  ////  maximum TX buffer decriptors ( 10Mbps ).                  ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 4) //
  begin
    // TEST 4: TRANSMIT PACKETS FROM MINFL TO MAXFL SIZES AT MAX TX BDs ( 10Mbps )
    test_name = "TEST 4: TRANSMIT PACKETS FROM MINFL TO MAXFL SIZES AT MAX TX BDs ( 10Mbps )";
    `TIME; $display("  TEST 4: TRANSMIT PACKETS FROM MINFL TO MAXFL SIZES AT MAX TX BDs ( 10Mbps )");
 
    // reset MAC registers
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    // set maximum TX buffer descriptors (128) - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h80, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, NO padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'hA5;
    set_tx_packet(`MEMORY_BASE, (max_tmp), st_data); // length without CRC
    st_data = 8'h71;
    set_tx_packet((`MEMORY_BASE + max_tmp), (max_tmp), st_data); // length without CRC
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      `TIME; $display("*E WB INT signal should not be set");
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;
 
    i_length = (min_tmp - 4);
    while (i_length <= (max_tmp - 4))
    begin
      // choose generating carrier sense and collision
      case (i_length[1:0])
      2'h0: // Interrupt is generated
      begin
        // Reset_tx_bd nable interrupt generation
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is not generated
      begin
        // set_tx_bd enable interrupt generation
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is not generated
      begin
        // set_tx_bd disable the interrupt generation
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is not generated
      begin
        // set_tx_bd disable the interrupt generation
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      // first destination address on ethernet PHY
      if (i_length[0] == 0)
        eth_phy.set_tx_mem_addr(0);
      else
        eth_phy.set_tx_mem_addr(max_tmp);
      // first 8 frames are transmitted with TX BD 0 (wrap bit on TX BD 0)
      // number of all frames is 154 (146 without first 8)
      if (num_of_frames < 8)
      begin
        case (i_length[1:0])
        2'h0: // Interrupt is generated
        begin
          // enable interrupt generation
          set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + i_length[1:0]));
          // interrupts are unmasked
        end
        2'h1: // Interrupt is not generated
        begin
          // enable interrupt generation
          set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
          // interrupts are masked
        end
        2'h2: // Interrupt is not generated
        begin
          // disable interrupt generation
          set_tx_bd(0, 0, i_length, 1'b0, 1'b1, 1'b1, (`MEMORY_BASE + i_length[1:0]));
          // interrupts are unmasked
        end
        default: // 2'h3: // Interrupt is not generated
        begin
          // disable interrupt generation
          set_tx_bd(0, 0, i_length, 1'b0, 1'b1, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
          // interrupts are masked
        end
        endcase
        // set wrap bit
        set_tx_bd_wrap(0);
      end
      // after first 8 number of frames, 128 frames from TX BD 0 to 127 will be transmitted
      else if ((num_of_frames - 8) == 0)
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 128) // (tmp_len <= (max_tmp - 4)) - this is the last frame
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          if ((tmp_len + 4) < (min_tmp + 128))
            tmp_len = tmp_len + 1;
          else if ( ((tmp_len + 4) == (min_tmp + 128)) && ((tmp_len + 4) <= (max_tmp - 256)) )
            tmp_len = 256;
          else if ( ((tmp_len + 4) > (min_tmp + 128)) && ((tmp_len + 4) <= (max_tmp - 256)) )
            tmp_len = tmp_len + 128;
          else if ( ((tmp_len + 4) > (max_tmp - 256)) && ((tmp_len + 4) < (max_tmp - 16)) )
            tmp_len = max_tmp - (4 + 16);
          else if ((tmp_len + 4) >= (max_tmp - 16))
            tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(127);
      end
      // after 128 + first 8 number of frames, 19 frames from TX BD 0 to 18 will be transmitted
      else if ((num_of_frames - 8) == 20) // 128
      begin
        tmp_len = tmp_len; // length of frame remaines from previous settings
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 19) // (tmp_len <= (max_tmp - 4)) - this is the last frame
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          if ((tmp_len + 4) < (min_tmp + 128))
            tmp_len = tmp_len + 1;
          else if ( ((tmp_len + 4) == (min_tmp + 128)) && ((tmp_len + 4) <= (max_tmp - 256)) )
            tmp_len = 256;
          else if ( ((tmp_len + 4) > (min_tmp + 128)) && ((tmp_len + 4) <= (max_tmp - 256)) )
            tmp_len = tmp_len + 128;
          else if ( ((tmp_len + 4) > (max_tmp - 256)) && ((tmp_len + 4) < (max_tmp - 16)) )
            tmp_len = max_tmp - (4 + 16);
          else if ((tmp_len + 4) >= (max_tmp - 16))
            tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
      end
      // set ready bit
      if (num_of_frames < 8)
        set_tx_bd_ready(0, 0);
      else if ((num_of_frames - 8) < 128)
        set_tx_bd_ready((num_of_frames - 8), (num_of_frames - 8));
      else if ((num_of_frames - 136) < 19)
        set_tx_bd_ready((num_of_frames - 136), (num_of_frames - 136));
      // CHECK END OF TRANSMITION
      #1 check_tx_bd(num_of_bd, data);
      if (i_length < min_tmp) // just first four
      begin
        while (data[15] === 1)
        begin
          #1 check_tx_bd(num_of_bd, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      else if (i_length > (max_tmp - 8)) // just last four
      begin
        tmp = 0;
        wait (MTxEn === 1'b1); // start transmit
        while (tmp < (i_length - 20))
        begin
          #1 tmp = tmp + 1;
          @(posedge wb_clk);
        end
        #1 check_tx_bd(num_of_bd, data);
        while (data[15] === 1)
        begin
          #1 check_tx_bd(num_of_bd, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      else
      begin
        wait (MTxEn === 1'b1); // start transmit
        #1 check_tx_bd(num_of_bd, data);
        if (data[15] !== 1)
        begin
          `TIME; $display("*E Wrong buffer descriptor's ready bit read out from MAC");
          test_fail("Wrong buffer descriptor's ready bit read out from MAC");
          fail = fail + 1;
        end
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
          #1 check_tx_bd(num_of_bd, data);
          @(posedge wb_clk);
        end
        repeat(1) @(posedge wb_clk);
      end
      repeat(2) @(posedge wb_clk);
      repeat(2) @(posedge mrx_clk);
      // check length of a PACKET
      if (eth_phy.tx_len != (i_length + 4))
      begin
        `TIME; $display("*E Wrong length of the packet out from MAC: %0d instead of %0d", eth_phy.tx_len, i_length + 4);
        test_fail("Wrong length of the packet out from MAC");
        fail = fail + 1;
      end
      // checking in the following if statement is performed only for first and last 64 lengths
        // check transmitted TX packet data
        if (i_length[0] == 0)
        begin
          check_tx_packet((`MEMORY_BASE + i_length[1:0]), 0, i_length, tmp);
        end
        else
        begin
          check_tx_packet(((`MEMORY_BASE + i_length[1:0]) + max_tmp), max_tmp, i_length, tmp);
        end
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the transmitted packet");
          test_fail("Wrong data of the transmitted packet");
          fail = fail + 1;
        end
        // check transmited TX packet CRC
        if (i_length[0] == 0)
          check_tx_crc(0, i_length, 1'b0, tmp); // length without CRC
        else
          check_tx_crc(max_tmp, i_length, 1'b0, tmp); // length without CRC
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong CRC of the transmitted packet");
          test_fail("Wrong CRC of the transmitted packet");
          fail = fail + 1;
        end
      // check WB INT signal
      if (i_length[1:0] == 2'h0)
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(num_of_bd, data);
      if (i_length[1] == 1'b0) // interrupt enabled
      begin
        if ( ((data[15:0] !== 16'h7800) && ((num_of_frames < 8) || ((num_of_frames - 8) == 127))) || // wrap bit
             ((data[15:0] !== 16'h5800) && (num_of_frames >= 8) && ((num_of_frames - 8) != 127)) ) // without wrap bit
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else // interrupt not enabled
      begin
        if ( ((data[15:0] !== 16'h3800)  && ((num_of_frames < 8) || ((num_of_frames - 8) == 127))) || // wrap bit
             ((data[15:0] !== 16'h1800) && (num_of_frames >= 8) && ((num_of_frames - 8) != 127)) ) // without wrap bit
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear first half of 8 frames from TX buffer descriptor 0
      if (num_of_frames < 4)
        clear_tx_bd(num_of_bd, num_of_bd);
      // clear BD with wrap bit
      if (num_of_frames == 140)
        clear_tx_bd(127, 127);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1))
      begin
        if ((data & `ETH_INT_TXB) !== 1'b1)
        begin
          `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Transmit Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_TXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Transmit Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Transmit Buffer) was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Transmit Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        `TIME; $display("*E WB INT signal should not be set");
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if ((i_length + 4) == (min_tmp + 7))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 128)
        $display("    pads appending to packets is NOT selected");
        $display("    using only TX BD 0 out of 128 BDs assigned to TX (wrap at first BD - TX BD 0)");
        $display("    ->packets with lengths from %0d (MINFL) to %0d are checked (length increasing by 1 byte)",
                 min_tmp, (min_tmp + 7));
        $display("    ->all packets were send from TX BD 0");
        // set padding, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (min_tmp + 128))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 128)
        $display("    pads appending to packets is NOT selected");
        $display("    using all 128 BDs assigned to TX (wrap at 128th BD - TX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 (min_tmp + 8), (min_tmp + 128));
        $display("    ->packets were send from TX BD %0d to TX BD %0d respectively",
                 1'b0, num_of_bd);
        tmp_bd = num_of_bd + 1;
        // set padding, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (max_tmp - 16))
      begin
        // starting length is for +128 longer than previous ending length, while ending length is tmp_data
        $display("    pads appending to packets is selected");
        $display("    using all 128 BDs assigned to TX (wrap at 128th BD - TX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 128 bytes)",
                 (min_tmp + 64 + 128), tmp_data); 
        if (tmp_bd > num_of_bd)
          $display("    ->packets were send from TX BD %0d to TX BD 127 and from TX BD 0 to TX BD %0d respectively",
                   tmp_bd, num_of_bd);
        else
          $display("    ->packets were send from TX BD %0d to TX BD %0d respectively",
                   tmp_bd, num_of_bd);
        tmp_bd = num_of_bd + 1;
        // reset padding, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == max_tmp)
      begin
        $display("    pads appending to packets is NOT selected");
        $display("    using all 128 BDs assigned to TX (wrap at 128th BD - TX BD 127)");
        $display("    ->packets with lengths from %0d to %0d (MAXFL) are checked (length increasing by 1 byte)",
                 (max_tmp - (4 + 16)), max_tmp);
        if (tmp_bd > num_of_bd)
          $display("    ->packets were send from TX BD %0d to TX BD 127 and from TX BD 0 to TX BD %0d respectively",
                   tmp_bd, num_of_bd);
        else
          $display("    ->packets were send from TX BD %0d to TX BD %0d respectively",
                   tmp_bd, num_of_bd);
      end
      // set length (loop variable)
      if ((i_length + 4) < (min_tmp + 128))
        i_length = i_length + 1;
      else if ( ((i_length + 4) == (min_tmp + 128)) && ((i_length + 4) <= (max_tmp - 256)) )
        i_length = 256;
      else if ( ((i_length + 4) > (min_tmp + 128)) && ((i_length + 4) <= (max_tmp - 256)) )
      begin
        i_length = i_length + 128;
        tmp_data = i_length + 4; // last tmp_data is ending length
      end
      else if ( ((i_length + 4) > (max_tmp - 256)) && ((i_length + 4) < (max_tmp - 16)) )
        i_length = max_tmp - (4 + 16);
      else if ((i_length + 4) >= (max_tmp - 16))
        i_length = i_length + 1;
      else
      begin
        $display("*E TESTBENCH ERROR - WRONG PARAMETERS IN TESTBENCH");
        #10 $stop;
      end
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      if ((num_of_frames <= 8) || ((num_of_frames - 8) == 128))
        num_of_bd = 0;
      else
        num_of_bd = num_of_bd + 1;
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets from MINFL to MAXFL sizes at        ////
  ////  maximum TX buffer decriptors ( 100Mbps ).                 ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 5) //
  begin
    // TEST 5: TRANSMIT PACKETS FROM MINFL TO MAXFL SIZES AT MAX TX BDs ( 100Mbps )
    test_name = "TEST 5: TRANSMIT PACKETS FROM MINFL TO MAXFL SIZES AT MAX TX BDs ( 100Mbps )";
    `TIME; $display("  TEST 5: TRANSMIT PACKETS FROM MINFL TO MAXFL SIZES AT MAX TX BDs ( 100Mbps )");
  
    // reset MAC registers
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    // set maximum TX buffer descriptors (128) - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h80, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, NO padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'hA5;
    set_tx_packet(`MEMORY_BASE, (max_tmp), st_data); // length without CRC
    st_data = 8'h71;
    set_tx_packet((`MEMORY_BASE + max_tmp), (max_tmp), st_data); // length without CRC
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      `TIME; $display("*E WB INT signal should not be set");
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;

    i_length = (min_tmp - 4);
    while (i_length <= (max_tmp - 4))
    begin
      // choose generating carrier sense and collision
      case (i_length[1:0])
      2'h0: // Interrupt is generated
      begin
        // Reset_tx_bd nable interrupt generation
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is not generated
      begin
        // set_tx_bd enable interrupt generation
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is not generated
      begin
        // set_tx_bd disable the interrupt generation
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is not generated
      begin
        // set_tx_bd disable the interrupt generation
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      // first destination address on ethernet PHY
      if (i_length[0] == 0)
        eth_phy.set_tx_mem_addr(0);
      else
        eth_phy.set_tx_mem_addr(max_tmp);
      // first 8 frames are transmitted with TX BD 0 (wrap bit on TX BD 0)
      // number of all frames is 154 (146 without first 8)
      if (num_of_frames < 8)
      begin
        case (i_length[1:0])
        2'h0: // Interrupt is generated
        begin
          // enable interrupt generation
          set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + i_length[1:0]));
          // interrupts are unmasked
        end
        2'h1: // Interrupt is not generated
        begin
          // enable interrupt generation
          set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
          // interrupts are masked
        end
        2'h2: // Interrupt is not generated
        begin
          // disable interrupt generation
          set_tx_bd(0, 0, i_length, 1'b0, 1'b1, 1'b1, (`MEMORY_BASE + i_length[1:0]));
          // interrupts are unmasked
        end
        default: // 2'h3: // Interrupt is not generated
        begin
          // disable interrupt generation
          set_tx_bd(0, 0, i_length, 1'b0, 1'b1, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
          // interrupts are masked
        end
        endcase
        // set wrap bit
        set_tx_bd_wrap(0);
      end
      // after first 8 number of frames, 128 frames from TX BD 0 to 127 will be transmitted
      else if ((num_of_frames - 8) == 0)
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 128) // (tmp_len <= (max_tmp - 4)) - this is the last frame
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          if ((tmp_len + 4) < (min_tmp + 128))
            tmp_len = tmp_len + 1;
          else if ( ((tmp_len + 4) == (min_tmp + 128)) && ((tmp_len + 4) <= (max_tmp - 256)) )
            tmp_len = 256;
          else if ( ((tmp_len + 4) > (min_tmp + 128)) && ((tmp_len + 4) <= (max_tmp - 256)) )
            tmp_len = tmp_len + 128;
          else if ( ((tmp_len + 4) > (max_tmp - 256)) && ((tmp_len + 4) < (max_tmp - 16)) )
            tmp_len = max_tmp - (4 + 16);
          else if ((tmp_len + 4) >= (max_tmp - 16))
            tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(127);
      end
      // after 128 + first 8 number of frames, 19 frames from TX BD 0 to 18 will be transmitted
      else if ((num_of_frames - 8) == 20) // 128
      begin
        tmp_len = tmp_len; // length of frame remaines from previous settings
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 19) // (tmp_len <= (max_tmp - 4)) - this is the last frame
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          if ((tmp_len + 4) < (min_tmp + 128))
            tmp_len = tmp_len + 1;
          else if ( ((tmp_len + 4) == (min_tmp + 128)) && ((tmp_len + 4) <= (max_tmp - 256)) )
            tmp_len = 256;
          else if ( ((tmp_len + 4) > (min_tmp + 128)) && ((tmp_len + 4) <= (max_tmp - 256)) )
            tmp_len = tmp_len + 128;
          else if ( ((tmp_len + 4) > (max_tmp - 256)) && ((tmp_len + 4) < (max_tmp - 16)) )
            tmp_len = max_tmp - (4 + 16);
          else if ((tmp_len + 4) >= (max_tmp - 16))
            tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
      end
      // set ready bit
      if (num_of_frames < 8)
        set_tx_bd_ready(0, 0);
      else if ((num_of_frames - 8) < 128)
        set_tx_bd_ready((num_of_frames - 8), (num_of_frames - 8));
      else if ((num_of_frames - 136) < 19)
        set_tx_bd_ready((num_of_frames - 136), (num_of_frames - 136));
      // CHECK END OF TRANSMITION
      #1 check_tx_bd(num_of_bd, data);
      if (i_length < min_tmp) // just first four
      begin
        while (data[15] === 1)
        begin
          #1 check_tx_bd(num_of_bd, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      else if (i_length > (max_tmp - 8)) // just last four
      begin
        tmp = 0;
        wait (MTxEn === 1'b1); // start transmit
        while (tmp < (i_length - 20))
        begin
          #1 tmp = tmp + 1;
          @(posedge wb_clk);
        end
        #1 check_tx_bd(num_of_bd, data);
        while (data[15] === 1)
        begin
          #1 check_tx_bd(num_of_bd, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      else
      begin
        wait (MTxEn === 1'b1); // start transmit
        #1 check_tx_bd(num_of_bd, data);
        if (data[15] !== 1)
        begin
          `TIME; $display("*E Wrong buffer descriptor's ready bit read out from MAC");
          test_fail("Wrong buffer descriptor's ready bit read out from MAC");
          fail = fail + 1;
        end
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
          #1 check_tx_bd(num_of_bd, data);
          @(posedge wb_clk);
        end
        repeat(1) @(posedge wb_clk);
      end
      repeat(2) @(posedge wb_clk);
      repeat(2) @(posedge mrx_clk);
      // check length of a PACKET
      if (eth_phy.tx_len != (i_length + 4))
      begin
        `TIME; $display("*E Wrong length of the packet out from MAC: %0d instead of %0d", eth_phy.tx_len, i_length + 4);
        test_fail("Wrong length of the packet out from MAC");
        fail = fail + 1;
      end
      // checking in the following if statement is performed only for first and last 64 lengths
        // check transmitted TX packet data
        if (i_length[0] == 0)
        begin
          check_tx_packet((`MEMORY_BASE + i_length[1:0]), 0, i_length, tmp);
        end
        else
        begin
          check_tx_packet(((`MEMORY_BASE + i_length[1:0]) + max_tmp), max_tmp, i_length, tmp);
        end
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the transmitted packet");
          test_fail("Wrong data of the transmitted packet");
          fail = fail + 1;
        end
        // check transmited TX packet CRC
        if (i_length[0] == 0)
          check_tx_crc(0, i_length, 1'b0, tmp); // length without CRC
        else
          check_tx_crc(max_tmp, i_length, 1'b0, tmp); // length without CRC
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong CRC of the transmitted packet");
          test_fail("Wrong CRC of the transmitted packet");
          fail = fail + 1;
        end
      // check WB INT signal
      if (i_length[1:0] == 2'h0)
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(num_of_bd, data);
      if (i_length[1] == 1'b0) // interrupt enabled
      begin
        if ( ((data[15:0] !== 16'h7800) && ((num_of_frames < 8) || ((num_of_frames - 8) == 127))) || // wrap bit
             ((data[15:0] !== 16'h5800) && (num_of_frames >= 8) && ((num_of_frames - 8) != 127)) ) // without wrap bit
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else // interrupt not enabled
      begin
        if ( ((data[15:0] !== 16'h3800)  && ((num_of_frames < 8) || ((num_of_frames - 8) == 127))) || // wrap bit
             ((data[15:0] !== 16'h1800) && (num_of_frames >= 8) && ((num_of_frames - 8) != 127)) ) // without wrap bit
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear first half of 8 frames from TX buffer descriptor 0
      if (num_of_frames < 4)
        clear_tx_bd(num_of_bd, num_of_bd);
      // clear BD with wrap bit
      if (num_of_frames == 140)
        clear_tx_bd(127, 127);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1))
      begin
        if ((data & `ETH_INT_TXB) !== 1'b1)
        begin
          `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Transmit Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_TXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Transmit Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Transmit Buffer) was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Transmit Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        `TIME; $display("*E WB INT signal should not be set");
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if ((i_length + 4) == (min_tmp + 7))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 128)
        $display("    pads appending to packets is NOT selected");
        $display("    using only TX BD 0 out of 128 BDs assigned to TX (wrap at first BD - TX BD 0)");
        $display("    ->packets with lengths from %0d (MINFL) to %0d are checked (length increasing by 1 byte)",
                 min_tmp, (min_tmp + 7));
        $display("    ->all packets were send from TX BD 0");
        // set padding, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (min_tmp + 128))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 128)
        $display("    pads appending to packets is NOT selected");
        $display("    using all 128 BDs assigned to TX (wrap at 128th BD - TX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 (min_tmp + 8), (min_tmp + 128));
        $display("    ->packets were send from TX BD %0d to TX BD %0d respectively",
                 1'b0, num_of_bd);
        tmp_bd = num_of_bd + 1;
        // set padding, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (max_tmp - 16))
      begin
        // starting length is for +128 longer than previous ending length, while ending length is tmp_data
        $display("    pads appending to packets is selected");
        $display("    using all 128 BDs assigned to TX (wrap at 128th BD - TX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 128 bytes)",
                 (min_tmp + 64 + 128), tmp_data); 
        if (tmp_bd > num_of_bd)
          $display("    ->packets were send from TX BD %0d to TX BD 127 and from TX BD 0 to TX BD %0d respectively",
                   tmp_bd, num_of_bd);
        else
          $display("    ->packets were send from TX BD %0d to TX BD %0d respectively",
                   tmp_bd, num_of_bd);
        tmp_bd = num_of_bd + 1;
        // reset padding, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == max_tmp)
      begin
        $display("    pads appending to packets is NOT selected");
        $display("    using all 128 BDs assigned to TX (wrap at 128th BD - TX BD 127)");
        $display("    ->packets with lengths from %0d to %0d (MAXFL) are checked (length increasing by 1 byte)",
                 (max_tmp - (4 + 16)), max_tmp);
        if (tmp_bd > num_of_bd)
          $display("    ->packets were send from TX BD %0d to TX BD 127 and from TX BD 0 to TX BD %0d respectively",
                   tmp_bd, num_of_bd);
        else
          $display("    ->packets were send from TX BD %0d to TX BD %0d respectively",
                   tmp_bd, num_of_bd);
      end
      // set length (loop variable)
      if ((i_length + 4) < (min_tmp + 128))
        i_length = i_length + 1;
      else if ( ((i_length + 4) == (min_tmp + 128)) && ((i_length + 4) <= (max_tmp - 256)) )
        i_length = 256;
      else if ( ((i_length + 4) > (min_tmp + 128)) && ((i_length + 4) <= (max_tmp - 256)) )
      begin
        i_length = i_length + 128;
        tmp_data = i_length + 4; // last tmp_data is ending length
      end
      else if ( ((i_length + 4) > (max_tmp - 256)) && ((i_length + 4) < (max_tmp - 16)) )
        i_length = max_tmp - (4 + 16);
      else if ((i_length + 4) >= (max_tmp - 16))
        i_length = i_length + 1;
      else
      begin
        $display("*E TESTBENCH ERROR - WRONG PARAMETERS IN TESTBENCH");
        #10 $stop;
      end
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      if ((num_of_frames <= 8) || ((num_of_frames - 8) == 128))
        num_of_bd = 0;
      else
        num_of_bd = num_of_bd + 1;
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets from 0 to (MINFL - 1) sizes at      ////
  ////  8 TX buffer decriptors ( 10Mbps ).                        ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 6) // 
  begin
    // TEST 6: TRANSMIT PACKETS FROM 0 TO (MINFL - 1) SIZES AT 8 TX BD ( 10Mbps )
    test_name = "TEST 6: TRANSMIT PACKETS FROM 0 TO (MINFL - 1) SIZES AT 8 TX BD ( 10Mbps )";
    `TIME; $display("  TEST 6: TRANSMIT PACKETS FROM 0 TO (MINFL - 1) SIZES AT 8 TX BD ( 10Mbps )");
  
    // reset MAC registers
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    // set 8 TX buffer descriptors - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h8, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_PAD | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h12;
    set_tx_packet(`MEMORY_BASE, (max_tmp - 4), st_data); // length without CRC
    st_data = 8'h34;
    set_tx_packet((`MEMORY_BASE + max_tmp), (max_tmp - 4), st_data); // length without CRC
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;
  
    frame_started = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    i_length = 0; // 0;
    while (i_length < 70) // (min_tmp - 4))
    begin
      #1;
      // choose generating carrier sense and collision
      case (i_length[1:0])
      2'h0: // Interrupt is generated
      begin
        // Reset_tx_bd nable interrupt generation
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is not generated
      begin
        // set_tx_bd enable interrupt generation
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is not generated
      begin
        // set_tx_bd disable the interrupt generation
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is not generated
      begin
        // set_tx_bd disable the interrupt generation
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      #1;
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(num_of_frames * 16);
      // SET packets and wrap bit
      // num_of_frames <= 9 => wrap set to TX BD 0
      if (num_of_frames <= 9)
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        // if i_length[1] == 0 then enable interrupt generation otherwise disable it
        // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
        if (tmp_len[0] == 0)
          set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, `MEMORY_BASE);
        else
          set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
        // set wrap bit
        set_tx_bd_wrap(0);
      end
      // 10 <= num_of_frames < 18 => wrap set to TX BD 3
      else if ((num_of_frames == 10) || (num_of_frames == 14))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 4) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(3);
      end
      // 18 <= num_of_frames < 28 => wrap set to TX BD 4
      else if ((num_of_frames == 18) || (num_of_frames == 23))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 5) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(4);
      end
      // 28 <= num_of_frames < 40 => wrap set to TX BD 5
      else if ((num_of_frames == 28) || (num_of_frames == 34))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 6) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(5);
      end
      // 40 <= num_of_frames < 54 => wrap set to TX BD 6
      else if ((num_of_frames == 40) || (num_of_frames == 47))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 7) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(6);
      end
      // 54 <= num_of_frames < 70 => wrap set to TX BD 7
      else if ((num_of_frames == 54) || (num_of_frames == 62))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 8) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(7);
      end
      #1;
      // SET ready bit
      if (num_of_frames < 10)
        set_tx_bd_ready(0, 0);
      else if (num_of_frames < 14)
        set_tx_bd_ready((num_of_frames - 10), (num_of_frames - 10));
      else if (num_of_frames < 18)
        set_tx_bd_ready((num_of_frames - 14), (num_of_frames - 14));
      else if (num_of_frames < 23)
        set_tx_bd_ready((num_of_frames - 18), (num_of_frames - 18));
      else if (num_of_frames < 28)
        set_tx_bd_ready((num_of_frames - 23), (num_of_frames - 23));
      else if (num_of_frames < 34)
        set_tx_bd_ready((num_of_frames - 28), (num_of_frames - 28));
      else if (num_of_frames < 40)
        set_tx_bd_ready((num_of_frames - 34), (num_of_frames - 34));
      else if (num_of_frames < 47)
        set_tx_bd_ready((num_of_frames - 40), (num_of_frames - 40));
      else if (num_of_frames < 54)
        set_tx_bd_ready((num_of_frames - 47), (num_of_frames - 47));
      else if (num_of_frames < 62)
        set_tx_bd_ready((num_of_frames - 54), (num_of_frames - 54));
      else if (num_of_frames < 70)
        set_tx_bd_ready((num_of_frames - 62), (num_of_frames - 62));
      // CHECK END OF TRANSMITION
      frame_started = 0;
      if (num_of_frames >= 5)
        #1 check_tx_bd(num_of_bd, data);
      fork
      begin: fr_st
        wait (MTxEn === 1'b1); // start transmit
        frame_started = 1;
      end
      begin
        repeat (30) @(posedge mtx_clk);
        if (num_of_frames < 5)
        begin
          if (frame_started == 1)
          begin
            `TIME; $display("*E Frame should NOT start!");
          end
          disable fr_st;
        end
        else
        begin
          if (frame_started == 0)
          begin
            `TIME; $display("*W Frame should start!");
            disable fr_st;
          end
        end
      end
      join
      // check packets larger than 4 bytes
      if (num_of_frames >= 5)
      begin
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
          #1 check_tx_bd(num_of_bd, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
        // check length of a PACKET
        if (i_length <= (min_tmp - 4))
        begin
          if (eth_phy.tx_len != min_tmp)
          begin
            test_fail("Wrong length of the packet out from MAC");
            fail = fail + 1;
          end
        end
        else
        begin
          if (eth_phy.tx_len != (i_length + 4))
          begin
            test_fail("Wrong length of the packet out from MAC");
            fail = fail + 1;
          end
        end
        // check transmitted TX packet data
        if (i_length[0] == 0)
        begin
          #1 check_tx_packet(`MEMORY_BASE, (num_of_frames * 16), i_length, tmp);
        end
        else
        begin
          #1 check_tx_packet((`MEMORY_BASE + max_tmp), (num_of_frames * 16), i_length, tmp);
        end
        if (tmp > 0)
        begin
          test_fail("Wrong data of the transmitted packet");
          fail = fail + 1;
        end
        // check transmited TX packet CRC
        if (num_of_frames < (min_tmp - 4))
          #1 check_tx_crc((num_of_frames * 16), (min_tmp - 4), 1'b0, tmp); // length without CRC
        else
          #1 check_tx_crc((num_of_frames * 16), i_length, 1'b0, tmp); // length without CRC
        if (tmp > 0)
        begin
          test_fail("Wrong CRC of the transmitted packet");
          fail = fail + 1;
        end
      end
      // check WB INT signal
      if ((i_length[1:0] == 2'h0) && (num_of_frames >= 5))
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(num_of_bd, data);
      if (num_of_frames >= 5)
      begin
        if (i_length[1] == 1'b0) // interrupt enabled
        begin
          if ( (data[15:0] !== 16'h7800) && // wrap bit
               (data[15:0] !== 16'h5800) ) // without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end
        end
        else // interrupt not enabled
        begin
          if ( (data[15:0] !== 16'h3800) && // wrap bit
               (data[15:0] !== 16'h1800) ) // without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end
        end
      end
      else
      begin
        if (data[15] !== 1'b1)
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear TX BD with wrap bit
      if (num_of_frames == 63)
        clear_tx_bd(16, 16);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ( ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1)) && (num_of_frames >= 5) )
      begin
        if ((data & `ETH_INT_TXB) !== 1'b1)
        begin
          `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Transmit Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_TXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Transmit Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Transmit Buffer) was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Transmit Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if (i_length == 3)
      begin
        $display("    pads appending to packets is selected");
        $display("    using 1 BD out of 8 BDs assigned to TX (wrap at 1st BD - TX BD 0)");
        $display("    ->packets with lengths from %0d to %0d are not transmitted (length increasing by 1 byte)",
                 0, 3);
      end
      else if (i_length == 9)
      begin
        $display("    using 1 BD out of 8 BDs assigned to TX (wrap at 1st BD - TX BD 0)");
        $display("    ->packet with length 4 is not transmitted (length increasing by 1 byte)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 5, 9);
      end
      else if (i_length == 17)
      begin
        $display("    using 4 BDs out of 8 BDs assigned to TX (wrap at 4th BD - TX BD 3)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 10, 17);
      end
      else if (i_length == 27)
      begin
        $display("    using 5 BDs out of 8 BDs assigned to TX (wrap at 5th BD - TX BD 4)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 18, 27);
      end
      else if (i_length == 40)
      begin
        $display("    using 6 BDs out of 8 BDs assigned to TX (wrap at 6th BD - TX BD 5)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 28, 40);
      end
      else if (i_length == 54)
      begin
        $display("    using 7 BDs out of 8 BDs assigned to TX (wrap at 7th BD - TX BD 6)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 41, 54);
      end
      else if (i_length == 69)
      begin
        $display("    using 8 BDs out of 8 BDs assigned to TX (wrap at 8th BD - TX BD 7)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 55, 69);
      end
      // set length (loop variable)
      i_length = i_length + 1;
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      if (/*(num_of_frames == 2) || (num_of_frames == 4) || (num_of_frames == 7) ||*/ (num_of_frames <= 10) || 
          (num_of_frames == 14) || (num_of_frames == 18) || (num_of_frames == 23) || (num_of_frames == 28) ||
          (num_of_frames == 34) || (num_of_frames == 40) || (num_of_frames == 47) ||
          (num_of_frames == 54) || (num_of_frames == 62))
        num_of_bd = 0;
      else
        num_of_bd = num_of_bd + 1;
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets from 0 to (MINFL - 1) sizes at      ////
  ////  8 TX buffer decriptors ( 100Mbps ).                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 7) // 
  begin
    // TEST 7: TRANSMIT PACKETS FROM 0 TO (MINFL - 1) SIZES AT 8 TX BD ( 100Mbps )
    test_name = "TEST 7: TRANSMIT PACKETS FROM 0 TO (MINFL - 1) SIZES AT 8 TX BD ( 100Mbps )";
    `TIME; $display("  TEST 7: TRANSMIT PACKETS FROM 0 TO (MINFL - 1) SIZES AT 8 TX BD ( 100Mbps )");
  
    // reset MAC registers
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    // set 8 TX buffer descriptors - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h8, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_PAD | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h12;
    set_tx_packet(`MEMORY_BASE, (max_tmp - 4), st_data); // length without CRC
    st_data = 8'h34;
    set_tx_packet((`MEMORY_BASE + max_tmp), (max_tmp - 4), st_data); // length without CRC
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;
  
    frame_started = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    i_length = 0; // 0;
    while (i_length < 70) // (min_tmp - 4))
    begin
      #1;
      // choose generating carrier sense and collision
      case (i_length[1:0])
      2'h0: // Interrupt is generated
      begin
        // Reset_tx_bd nable interrupt generation
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is not generated
      begin
        // set_tx_bd enable interrupt generation
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is not generated
      begin
        // set_tx_bd disable the interrupt generation
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is not generated
      begin
        // set_tx_bd disable the interrupt generation
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      #1;
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(num_of_frames * 16);
      // SET packets and wrap bit
      // num_of_frames <= 9 => wrap set to TX BD 0
      if (num_of_frames <= 9)
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        // if i_length[1] == 0 then enable interrupt generation otherwise disable it
        // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
        if (tmp_len[0] == 0)
          set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, `MEMORY_BASE);
        else
          set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
        // set wrap bit
        set_tx_bd_wrap(0);
      end
      // 10 <= num_of_frames < 18 => wrap set to TX BD 3
      else if ((num_of_frames == 10) || (num_of_frames == 14))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 4) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(3);
      end
      // 18 <= num_of_frames < 28 => wrap set to TX BD 4
      else if ((num_of_frames == 18) || (num_of_frames == 23))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 5) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(4);
      end
      // 28 <= num_of_frames < 40 => wrap set to TX BD 5
      else if ((num_of_frames == 28) || (num_of_frames == 34))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 6) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(5);
      end
      // 40 <= num_of_frames < 54 => wrap set to TX BD 6
      else if ((num_of_frames == 40) || (num_of_frames == 47))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 7) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(6);
      end
      // 54 <= num_of_frames < 70 => wrap set to TX BD 7
      else if ((num_of_frames == 54) || (num_of_frames == 62))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 8) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(7);
      end
      #1;
      // SET ready bit
      if (num_of_frames < 10)
        set_tx_bd_ready(0, 0);
      else if (num_of_frames < 14)
        set_tx_bd_ready((num_of_frames - 10), (num_of_frames - 10));
      else if (num_of_frames < 18)
        set_tx_bd_ready((num_of_frames - 14), (num_of_frames - 14));
      else if (num_of_frames < 23)
        set_tx_bd_ready((num_of_frames - 18), (num_of_frames - 18));
      else if (num_of_frames < 28)
        set_tx_bd_ready((num_of_frames - 23), (num_of_frames - 23));
      else if (num_of_frames < 34)
        set_tx_bd_ready((num_of_frames - 28), (num_of_frames - 28));
      else if (num_of_frames < 40)
        set_tx_bd_ready((num_of_frames - 34), (num_of_frames - 34));
      else if (num_of_frames < 47)
        set_tx_bd_ready((num_of_frames - 40), (num_of_frames - 40));
      else if (num_of_frames < 54)
        set_tx_bd_ready((num_of_frames - 47), (num_of_frames - 47));
      else if (num_of_frames < 62)
        set_tx_bd_ready((num_of_frames - 54), (num_of_frames - 54));
      else if (num_of_frames < 70)
        set_tx_bd_ready((num_of_frames - 62), (num_of_frames - 62));
      // CHECK END OF TRANSMITION
      frame_started = 0;
      if (num_of_frames >= 5)
        #1 check_tx_bd(num_of_bd, data);
      fork
      begin: fr_st1
        wait (MTxEn === 1'b1); // start transmit
        frame_started = 1;
      end
      begin
        repeat (50) @(posedge mtx_clk);     // Increased from 30 to 50
        if (num_of_frames < 5)
        begin
          if (frame_started == 1)
          begin
            `TIME; $display("*E Frame should NOT start!");
          end
          disable fr_st1;
        end
        else
        begin
          if (frame_started == 0)
          begin
            `TIME; $display("*W Frame should start!");
            disable fr_st1;
          end
        end
      end
      join
      // check packets larger than 4 bytes
      if (num_of_frames >= 5)
      begin
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
          #1 check_tx_bd(num_of_bd, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
        // check length of a PACKET
        if (i_length <= (min_tmp - 4))
        begin
          if (eth_phy.tx_len != min_tmp)
          begin
            test_fail("Wrong length of the packet out from MAC");
            fail = fail + 1;
          end
        end
        else
        begin
          if (eth_phy.tx_len != (i_length + 4))
          begin
            test_fail("Wrong length of the packet out from MAC");
            fail = fail + 1;
          end
        end
        // check transmitted TX packet data
        if (i_length[0] == 0)
        begin
          #1 check_tx_packet(`MEMORY_BASE, (num_of_frames * 16), i_length, tmp);
        end
        else
        begin
          #1 check_tx_packet((`MEMORY_BASE + max_tmp), (num_of_frames * 16), i_length, tmp);
        end
        if (tmp > 0)
        begin
          test_fail("Wrong data of the transmitted packet");
          fail = fail + 1;
        end
        // check transmited TX packet CRC
        if (num_of_frames < (min_tmp - 4))
          #1 check_tx_crc((num_of_frames * 16), (min_tmp - 4), 1'b0, tmp); // length without CRC
        else
          #1 check_tx_crc((num_of_frames * 16), i_length, 1'b0, tmp); // length without CRC
        if (tmp > 0)
        begin
          test_fail("Wrong CRC of the transmitted packet");
          fail = fail + 1;
        end
      end
      // check WB INT signal
      if ((i_length[1:0] == 2'h0) && (num_of_frames >= 5))
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(num_of_bd, data);
      if (num_of_frames >= 5)
      begin
        if (i_length[1] == 1'b0) // interrupt enabled
        begin
          if ( (data[15:0] !== 16'h7800) && // wrap bit
               (data[15:0] !== 16'h5800) ) // without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end
        end
        else // interrupt not enabled
        begin
          if ( (data[15:0] !== 16'h3800) && // wrap bit
               (data[15:0] !== 16'h1800) ) // without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end
        end
      end
      else
      begin
        if (data[15] !== 1'b1)
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear TX BD with wrap bit
      if (num_of_frames == 63)
        clear_tx_bd(16, 16);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ( ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1)) && (num_of_frames >= 5) )
      begin
        if ((data & `ETH_INT_TXB) !== 1'b1)
        begin
          `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Transmit Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_TXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Transmit Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Transmit Buffer) was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Transmit Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if (i_length == 3)
      begin
        $display("    pads appending to packets is selected");
        $display("    using 1 BD out of 8 BDs assigned to TX (wrap at 1st BD - TX BD 0)");
        $display("    ->packets with lengths from %0d to %0d are not transmitted (length increasing by 1 byte)",
                 0, 3);
      end
      else if (i_length == 9)
      begin
        $display("    using 1 BD out of 8 BDs assigned to TX (wrap at 1st BD - TX BD 0)");
        $display("    ->packet with length 4 is not transmitted (length increasing by 1 byte)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 5, 9);
      end
      else if (i_length == 17)
      begin
        $display("    using 4 BDs out of 8 BDs assigned to TX (wrap at 4th BD - TX BD 3)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 10, 17);
      end
      else if (i_length == 27)
      begin
        $display("    using 5 BDs out of 8 BDs assigned to TX (wrap at 5th BD - TX BD 4)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 18, 27);
      end
      else if (i_length == 40)
      begin
        $display("    using 6 BDs out of 8 BDs assigned to TX (wrap at 6th BD - TX BD 5)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 28, 40);
      end
      else if (i_length == 54)
      begin
        $display("    using 7 BDs out of 8 BDs assigned to TX (wrap at 7th BD - TX BD 6)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 41, 54);
      end
      else if (i_length == 69)
      begin
        $display("    using 8 BDs out of 8 BDs assigned to TX (wrap at 8th BD - TX BD 7)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 55, 69);
      end
      // set length (loop variable)
      i_length = i_length + 1;
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      if (/*(num_of_frames == 2) || (num_of_frames == 4) || (num_of_frames == 7) ||*/ (num_of_frames <= 10) || 
          (num_of_frames == 14) || (num_of_frames == 18) || (num_of_frames == 23) || (num_of_frames == 28) ||
          (num_of_frames == 34) || (num_of_frames == 40) || (num_of_frames == 47) ||
          (num_of_frames == 54) || (num_of_frames == 62))
        num_of_bd = 0;
      else
        num_of_bd = num_of_bd + 1;
    end
    // disable TX
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets (no pads) from 0 to (MINFL - 1)     ////
  ////  sizes at 8 TX buffer decriptors ( 10Mbps ).               ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 8) // 
  begin
    // TEST 8: TRANSMIT PACKETS (NO PADs) FROM 0 TO (MINFL - 1) SIZES AT 8 TX BD ( 10Mbps )
    test_name = "TEST 8: TRANSMIT PACKETS (NO PADs) FROM 0 TO (MINFL - 1) SIZES AT 8 TX BD ( 10Mbps )";
    `TIME; $display("  TEST 8: TRANSMIT PACKETS (NO PADs) FROM 0 TO (MINFL - 1) SIZES AT 8 TX BD ( 10Mbps )");

    // reset MAC registers
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    // set 8 TX buffer descriptors - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h8, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, padding and CRC appending
    wait (wbm_working == 0);
//    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_PAD | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h12;
    set_tx_packet(`MEMORY_BASE, (max_tmp - 4), st_data); // length without CRC
    st_data = 8'h34;
    set_tx_packet((`MEMORY_BASE + max_tmp), (max_tmp - 4), st_data); // length without CRC
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;
  
    frame_started = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    i_length = 0; // 0;
    while (i_length < 70) // (min_tmp - 4))
    begin
      #1;
      // choose generating carrier sense and collision
      case (i_length[1:0])
      2'h0: // Interrupt is generated
      begin
        // Reset_tx_bd nable interrupt generation
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is not generated
      begin
        // set_tx_bd enable interrupt generation
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is not generated
      begin
        // set_tx_bd disable the interrupt generation
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is not generated
      begin
        // set_tx_bd disable the interrupt generation
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
//      // append CRC
//      if ((i_length[0] == 1'b0) && (num_of_frames >= 6))
//      begin
//        append_tx_crc(`MEMORY_BASE, i_length, 1'b0);
//      end
      #1;
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(num_of_frames * 16);
      // SET packets and wrap bit
      // num_of_frames <= 9 => wrap set to TX BD 0
      if (num_of_frames <= 5)
        begin
          tmp_len = i_length; // length of frame
          tmp_bd_num = 0; // TX BD number
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp

          if (tmp_len[0] == 0) // CRC appended by 'HARDWARE'
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b1, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b1, (`MEMORY_BASE + max_tmp));
          // set wrap bit
          set_tx_bd_wrap(0);
        end
        else if (num_of_frames <= 9)
        begin
          tmp_len = i_length; // length of frame
          tmp_bd_num = 0; // TX BD number
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0) // CRC appended by 'SOFTWARE'
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b0, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b1, (`MEMORY_BASE + max_tmp));
          // set wrap bit
          set_tx_bd_wrap(0);
        end
        // 10 <= num_of_frames < 18 => wrap set to TX BD 3
        else if ((num_of_frames == 10) || (num_of_frames == 14))
        begin
          tmp_len = i_length; // length of frame
          tmp_bd_num = 0; // TX BD number
          while (tmp_bd_num < 4)
          begin
            // if i_length[1] == 0 then enable interrupt generation otherwise disable it
            // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
            if (tmp_len[0] == 0)
              set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b0, `MEMORY_BASE);
            else
              set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b1, (`MEMORY_BASE + max_tmp));
            tmp_len = tmp_len + 1;
            // set TX BD number
            tmp_bd_num = tmp_bd_num + 1;
          end
          // set wrap bit
          set_tx_bd_wrap(3);
        end
      // 18 <= num_of_frames < 28 => wrap set to TX BD 4
      else if ((num_of_frames == 18) || (num_of_frames == 23))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 5) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b0, `MEMORY_BASE);
          else // when (num_of_frames == 23), (i_length == 23) and therefor i_length[0] == 1 !!!
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 
                      ((num_of_frames == 23) && (tmp_bd_num == 0)), 1'b1, (`MEMORY_BASE + max_tmp));

          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(4);
      end
      // 28 <= num_of_frames < 40 => wrap set to TX BD 5
      else if ((num_of_frames == 28) || (num_of_frames == 34))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 6) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b0, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b1, (`MEMORY_BASE + max_tmp));
          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(5);
      end
      // 40 <= num_of_frames < 54 => wrap set to TX BD 6
      else if ((num_of_frames == 40) || (num_of_frames == 47))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 7) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b0, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b1, (`MEMORY_BASE + max_tmp));
          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(6);
      end
      // 54 <= num_of_frames < 70 => wrap set to TX BD 7
      else if ((num_of_frames == 54) || (num_of_frames == 62))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 8) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b0, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b1, (`MEMORY_BASE + max_tmp));
          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(7);
      end
      #1;
      // SET ready bit
      if (num_of_frames < 10)
        set_tx_bd_ready(0, 0);
      else if (num_of_frames < 14)
        set_tx_bd_ready((num_of_frames - 10), (num_of_frames - 10));
      else if (num_of_frames < 18)
        set_tx_bd_ready((num_of_frames - 14), (num_of_frames - 14));
      else if (num_of_frames < 23)
        set_tx_bd_ready((num_of_frames - 18), (num_of_frames - 18));
      else if (num_of_frames < 28)
        set_tx_bd_ready((num_of_frames - 23), (num_of_frames - 23));
      else if (num_of_frames < 34)
        set_tx_bd_ready((num_of_frames - 28), (num_of_frames - 28));
      else if (num_of_frames < 40)
        set_tx_bd_ready((num_of_frames - 34), (num_of_frames - 34));
      else if (num_of_frames < 47)
        set_tx_bd_ready((num_of_frames - 40), (num_of_frames - 40));
      else if (num_of_frames < 54)
        set_tx_bd_ready((num_of_frames - 47), (num_of_frames - 47));
      else if (num_of_frames < 62)
        set_tx_bd_ready((num_of_frames - 54), (num_of_frames - 54));
      else if (num_of_frames < 70)
        set_tx_bd_ready((num_of_frames - 62), (num_of_frames - 62));
      // CHECK END OF TRANSMITION
      frame_started = 0;
      if (num_of_frames >= 5)
        #1 check_tx_bd(num_of_bd, data);
      fork
      begin: fr_st2
        wait (MTxEn === 1'b1); // start transmit
        frame_started = 1;
      end
      begin
        repeat (30) @(posedge mtx_clk);
        if (num_of_frames < 5)
        begin
          if (frame_started == 1)
          begin
            `TIME; $display("*E Frame should NOT start!");
          end
          disable fr_st2;
        end
        else
        begin
          if (frame_started == 0)
          begin
            `TIME; $display("*W Frame should start!");
            disable fr_st2;
          end
        end
      end
      join
      // check packets larger than 4 bytes
      if (num_of_frames >= 5)
      begin
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
          #1 check_tx_bd(num_of_bd, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
        // check length of a PACKET     // Check this if it is OK igor
        if (num_of_frames < 6)
          begin
            if (eth_phy.tx_len != (i_length + 4))
              begin
                `TIME; $display("*E Wrong length of the packet out from MAC");
                test_fail("Wrong length of the packet out from MAC");
                fail = fail + 1;
              end
          end
        else if (num_of_frames != 23) // 6 - 53 except 23
          begin
            if (i_length[0] == 1'b0)
              begin
                if (eth_phy.tx_len != i_length)
                  begin
                    `TIME; $display("*E Wrong length of the packet out from MAC");
                    test_fail("Wrong length of the packet out from MAC");
                    fail = fail + 1;
                  end
              end
            else
              begin
                if (eth_phy.tx_len != (i_length + 4))
                  begin
                    `TIME; $display("*E Wrong length of the packet out from MAC");
                    test_fail("Wrong length of the packet out from MAC");
                    fail = fail + 1;
                  end
              end
          end
        else // num_of_frames == 23
          begin
            if (data[12]) // Padding
              begin
                if (eth_phy.tx_len != (64))
                  begin
                    `TIME; $display("*E Wrong length of the packet out from MAC");
                    test_fail("Wrong length of the packet out from MAC");
                    fail = fail + 1;
                  end
              end
            else
              begin
                if (eth_phy.tx_len != (i_length + 4))
                  begin
                    `TIME; $display("*E Wrong length of the packet out from MAC");
                    test_fail("Wrong length of the packet out from MAC");
                    fail = fail + 1;
                  end
              end
          end
        // check transmitted TX packet data
        if (i_length[0] == 0)
        begin
          #1 check_tx_packet(`MEMORY_BASE, (num_of_frames * 16), i_length, tmp);
        end
        else if (num_of_frames == 23) // i_length[0] == 1 here
        begin
          #1 check_tx_packet((`MEMORY_BASE + max_tmp), (num_of_frames * 16), i_length, tmp);
          #1 check_tx_packet( 0, (num_of_frames * 16 + i_length), (min_tmp - i_length - 4), tmp);
        end
        else
        begin
          #1 check_tx_packet((`MEMORY_BASE + max_tmp), (num_of_frames * 16), i_length, tmp);
        end
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the transmitted packet");
          test_fail("Wrong data of the transmitted packet");
          fail = fail + 1;
        end
        // check transmited TX packet CRC
        #1;
        if ((i_length[0] == 1'b0) && (num_of_frames >= 6))
        begin
        end
        else
          check_tx_crc((num_of_frames * 16), (eth_phy.tx_len - 4), 1'b0, tmp); // length without CRC
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong CRC of the transmitted packet");
          test_fail("Wrong CRC of the transmitted packet");
          fail = fail + 1;
        end
      end
      // check WB INT signal
      if ((i_length[1:0] == 2'h0) && (num_of_frames >= 5))
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(num_of_bd, data);
      if (num_of_frames >= 5)
      begin
        if ((i_length[1] == 1'b0) && (i_length[0] == 1'b0)) // interrupt enabled
        begin
          if ( (data[15:0] !== 16'h6000) &&  // wrap bit
               (data[15:0] !== 16'h4000) )  // without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct 1: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end
        end
        else if ((i_length[1] == 1'b1) && (i_length[0] == 1'b0)) // interrupt not enabled
        begin
          if ( (data[15:0] !== 16'h2000) && // wrap bit
               (data[15:0] !== 16'h0000) ) // without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct 2: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end
        end
        else if ((i_length[1] == 1'b0) && (i_length[0] == 1'b1)) // interrupt enabled
        begin
          if ( (data[15:0] !== 16'h6800) && // wrap bit
               (data[15:0] !== 16'h4800) ) // without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct 3: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end
        end
        else if (num_of_frames != 23) // ((i_length[1] == 1'b1) && (i_length[0] == 1'b1)) // interrupt not enabled
        begin
          if ( (data[15:0] !== 16'h2800) && // wrap bit
               (data[15:0] !== 16'h0800) ) // without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct 4: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end
        end
        else // ((num_of_frames != 23) && (i_length[1] == 1'b1) && (i_length[0] == 1'b1)) // interrupt not enabled
        begin
          if ( (data[15:0] !== 16'h3800) && // wrap bit
               (data[15:0] !== 16'h1800) ) // without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct 5: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end
        end
      end
      else
      begin
        if (data[15] !== 1'b1)
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear TX BD with wrap bit
      if (num_of_frames == 63)
        clear_tx_bd(16, 16);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ( ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1)) && (num_of_frames >= 5) )
      begin
        if ((data & `ETH_INT_TXB) !== 1'b1)
        begin
          `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Transmit Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_TXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Transmit Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Transmit Buffer) was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Transmit Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        `TIME; $display("*E WB INT signal should not be set");
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if (i_length == 3)
      begin
        $display("    pads appending to packets is not selected (except for 0x23)");
        $display("    using 1 BD out of 8 BDs assigned to TX (wrap at 1st BD - TX BD 0)");
        $display("    ->packets with lengths from %0d to %0d are not transmitted (length increasing by 1 byte)",
                 0, 3);
      end
      else if (i_length == 9)
      begin
        $display("    using 1 BD out of 8 BDs assigned to TX (wrap at 1st BD - TX BD 0)");
        $display("    ->packet with length 4 is not transmitted (length increasing by 1 byte)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 5, 9);
      end
      else if (i_length == 17)
      begin
        $display("    using 4 BDs out of 8 BDs assigned to TX (wrap at 4th BD - TX BD 3)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 10, 17);
      end
      else if (i_length == 27)
      begin
        $display("    using 5 BDs out of 8 BDs assigned to TX (wrap at 5th BD - TX BD 4)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 18, 27);
      end
      else if (i_length == 40)
      begin
        $display("    using 6 BDs out of 8 BDs assigned to TX (wrap at 6th BD - TX BD 5)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 28, 40);
      end
      else if (i_length == 54)
      begin
        $display("    using 7 BDs out of 8 BDs assigned to TX (wrap at 7th BD - TX BD 6)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 41, 54);
      end
      else if (i_length == 69)
      begin
        $display("    using 8 BDs out of 8 BDs assigned to TX (wrap at 8th BD - TX BD 7)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 55, 69);
      end
      // set length (loop variable)
      i_length = i_length + 1;
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      if (/*(num_of_frames == 2) || (num_of_frames == 4) || (num_of_frames == 7) ||*/ (num_of_frames <= 10) || 
          (num_of_frames == 14) || (num_of_frames == 18) || (num_of_frames == 23) || (num_of_frames == 28) ||
          (num_of_frames == 34) || (num_of_frames == 40) || (num_of_frames == 47) ||
          (num_of_frames == 54) || (num_of_frames == 62))
        num_of_bd = 0;
      else
        num_of_bd = num_of_bd + 1;
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets (no pads) from 0 to (MINFL - 1)     ////
  ////  sizes at 8 TX buffer decriptors ( 100Mbps ).              ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 9) // 
  begin
    // TEST 9: TRANSMIT PACKETS (NO PADs) FROM 0 TO (MINFL - 1) SIZES AT 8 TX BD ( 100Mbps )
    test_name = "TEST 9: TRANSMIT PACKETS (NO PADs) FROM 0 TO (MINFL - 1) SIZES AT 8 TX BD ( 100Mbps )";
    `TIME; $display("  TEST 9: TRANSMIT PACKETS (NO PADs) FROM 0 TO (MINFL - 1) SIZES AT 8 TX BD ( 100Mbps )");
  
    // reset MAC registers
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    // set 8 TX buffer descriptors - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h8, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, padding and CRC appending
    wait (wbm_working == 0);
//    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_PAD | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h12;
    set_tx_packet(`MEMORY_BASE, (max_tmp - 4), st_data); // length without CRC
    st_data = 8'h34;
    set_tx_packet((`MEMORY_BASE + max_tmp), (max_tmp - 4), st_data); // length without CRC
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;
 
    frame_started = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    i_length = 0; // 0;
    while (i_length < 70) // (min_tmp - 4))
    begin
      #1;
      // choose generating carrier sense and collision
      case (i_length[1:0])
      2'h0: // Interrupt is generated
      begin
        // Reset_tx_bd nable interrupt generation
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is not generated
      begin
        // set_tx_bd enable interrupt generation
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is not generated
      begin
        // set_tx_bd disable the interrupt generation
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is not generated
      begin
        // set_tx_bd disable the interrupt generation
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
//      // append CRC
//      if ((i_length[0] == 1'b0) && (num_of_frames >= 6))
//      begin
//        append_tx_crc(`MEMORY_BASE, i_length, 1'b0);
//      end
      #1;
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(num_of_frames * 16);
      // SET packets and wrap bit
      // num_of_frames <= 9 => wrap set to TX BD 0
      if (num_of_frames <= 5)
        begin
          tmp_len = i_length; // length of frame
          tmp_bd_num = 0; // TX BD number
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp

          if (tmp_len[0] == 0) // CRC appended by 'HARDWARE'
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b1, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b1, (`MEMORY_BASE + max_tmp));
          // set wrap bit
          set_tx_bd_wrap(0);
        end
        else if (num_of_frames <= 9)
        begin
          tmp_len = i_length; // length of frame
          tmp_bd_num = 0; // TX BD number
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0) // CRC appended by 'SOFTWARE'
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b0, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b1, (`MEMORY_BASE + max_tmp));
          // set wrap bit
          set_tx_bd_wrap(0);
        end
        // 10 <= num_of_frames < 18 => wrap set to TX BD 3
        else if ((num_of_frames == 10) || (num_of_frames == 14))
        begin
          tmp_len = i_length; // length of frame
          tmp_bd_num = 0; // TX BD number
          while (tmp_bd_num < 4)
          begin
            // if i_length[1] == 0 then enable interrupt generation otherwise disable it
            // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
            if (tmp_len[0] == 0)
              set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b0, `MEMORY_BASE);
            else
              set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b1, (`MEMORY_BASE + max_tmp));
            tmp_len = tmp_len + 1;
            // set TX BD number
            tmp_bd_num = tmp_bd_num + 1;
          end
          // set wrap bit
          set_tx_bd_wrap(3);
        end
      // 18 <= num_of_frames < 28 => wrap set to TX BD 4
      else if ((num_of_frames == 18) || (num_of_frames == 23))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 5) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b0, `MEMORY_BASE);
          else // when (num_of_frames == 23), (i_length == 23) and therefor i_length[0] == 1 !!!
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 
                      ((num_of_frames == 23) && (tmp_bd_num == 0)), 1'b1, (`MEMORY_BASE + max_tmp));

          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(4);
      end
      // 28 <= num_of_frames < 40 => wrap set to TX BD 5
      else if ((num_of_frames == 28) || (num_of_frames == 34))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 6) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b0, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b1, (`MEMORY_BASE + max_tmp));
          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(5);
      end
      // 40 <= num_of_frames < 54 => wrap set to TX BD 6
      else if ((num_of_frames == 40) || (num_of_frames == 47))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 7) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b0, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b1, (`MEMORY_BASE + max_tmp));
          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(6);
      end
      // 54 <= num_of_frames < 70 => wrap set to TX BD 7
      else if ((num_of_frames == 54) || (num_of_frames == 62))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 8) //
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b0, `MEMORY_BASE);
          else
            set_tx_bd(tmp_bd_num, tmp_bd_num, tmp_len, !tmp_len[1], 1'b0, 1'b1, (`MEMORY_BASE + max_tmp));
          tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_tx_bd_wrap(7);
      end
      #1;
      // SET ready bit
      if (num_of_frames < 10)
        set_tx_bd_ready(0, 0);
      else if (num_of_frames < 14)
        set_tx_bd_ready((num_of_frames - 10), (num_of_frames - 10));
      else if (num_of_frames < 18)
        set_tx_bd_ready((num_of_frames - 14), (num_of_frames - 14));
      else if (num_of_frames < 23)
        set_tx_bd_ready((num_of_frames - 18), (num_of_frames - 18));
      else if (num_of_frames < 28)
        set_tx_bd_ready((num_of_frames - 23), (num_of_frames - 23));
      else if (num_of_frames < 34)
        set_tx_bd_ready((num_of_frames - 28), (num_of_frames - 28));
      else if (num_of_frames < 40)
        set_tx_bd_ready((num_of_frames - 34), (num_of_frames - 34));
      else if (num_of_frames < 47)
        set_tx_bd_ready((num_of_frames - 40), (num_of_frames - 40));
      else if (num_of_frames < 54)
        set_tx_bd_ready((num_of_frames - 47), (num_of_frames - 47));
      else if (num_of_frames < 62)
        set_tx_bd_ready((num_of_frames - 54), (num_of_frames - 54));
      else if (num_of_frames < 70)
        set_tx_bd_ready((num_of_frames - 62), (num_of_frames - 62));
      // CHECK END OF TRANSMITION
      frame_started = 0;
      if (num_of_frames >= 5)
        #1 check_tx_bd(num_of_bd, data);
      fork
      begin: fr_st3
        wait (MTxEn === 1'b1); // start transmit
        frame_started = 1;
      end
      begin
        repeat (50) @(posedge mtx_clk);
        if (num_of_frames < 5)
        begin
          if (frame_started == 1)
          begin
            `TIME; $display("*E Frame should NOT start!");
          end
          disable fr_st3;
        end
        else
        begin
          if (frame_started == 0)
          begin
            `TIME; $display("*W Frame should start!");
            disable fr_st3;
          end
        end
      end
      join
      // check packets larger than 4 bytes
      if (num_of_frames >= 5)
      begin
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
          #1 check_tx_bd(num_of_bd, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
        // check length of a PACKET     // Check this if it is OK igor
        if (num_of_frames < 6)
          begin
            if (eth_phy.tx_len != (i_length + 4))
              begin
                `TIME; $display("*E Wrong length of the packet out from MAC");
                test_fail("Wrong length of the packet out from MAC");
                fail = fail + 1;
              end
          end
        else if (num_of_frames != 23) // 6 - 53 except 23
          begin
            if (i_length[0] == 1'b0)
              begin
                if (eth_phy.tx_len != i_length)
                  begin
                    `TIME; $display("*E Wrong length of the packet out from MAC");
                    test_fail("Wrong length of the packet out from MAC");
                    fail = fail + 1;
                  end
              end
            else
              begin
                if (eth_phy.tx_len != (i_length + 4))
                  begin
                    `TIME; $display("*E Wrong length of the packet out from MAC");
                    test_fail("Wrong length of the packet out from MAC");
                    fail = fail + 1;
                  end
              end
          end
        else // num_of_frames == 23
          begin
            if (data[12]) // Padding
              begin
                if (eth_phy.tx_len != (64))
                  begin
                    `TIME; $display("*E Wrong length of the packet out from MAC");
                    test_fail("Wrong length of the packet out from MAC");
                    fail = fail + 1;
                  end
              end
            else
              begin
                if (eth_phy.tx_len != (i_length + 4))
                  begin
                    `TIME; $display("*E Wrong length of the packet out from MAC");
                    test_fail("Wrong length of the packet out from MAC");
                    fail = fail + 1;
                  end
              end
          end
        // check transmitted TX packet data
        if (i_length[0] == 0)
        begin
          #1 check_tx_packet(`MEMORY_BASE, (num_of_frames * 16), i_length, tmp);
        end
        else if (num_of_frames == 23) // i_length[0] == 1 here
        begin
          #1 check_tx_packet((`MEMORY_BASE + max_tmp), (num_of_frames * 16), i_length, tmp);
          #1 check_tx_packet( 0, (num_of_frames * 16 + i_length), (min_tmp - i_length - 4), tmp);
        end
        else
        begin
          #1 check_tx_packet((`MEMORY_BASE + max_tmp), (num_of_frames * 16), i_length, tmp);
        end
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the transmitted packet");
          test_fail("Wrong data of the transmitted packet");
          fail = fail + 1;
        end
        // check transmited TX packet CRC
        #1;
        if ((i_length[0] == 1'b0) && (num_of_frames >= 6))
        begin
        end
        else
          check_tx_crc((num_of_frames * 16), (eth_phy.tx_len - 4), 1'b0, tmp); // length without CRC
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong CRC of the transmitted packet");
          test_fail("Wrong CRC of the transmitted packet");
          fail = fail + 1;
        end
      end
      // check WB INT signal
      if ((i_length[1:0] == 2'h0) && (num_of_frames >= 5))
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(num_of_bd, data);
      if (num_of_frames >= 5)
      begin
        if ((i_length[1] == 1'b0) && (i_length[0] == 1'b0)) // interrupt enabled
        begin
          if ( (data[15:0] !== 16'h6000) &&  // wrap bit
               (data[15:0] !== 16'h4000) )  // without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct 1: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end
        end
        else if ((i_length[1] == 1'b1) && (i_length[0] == 1'b0)) // interrupt not enabled
        begin
          if ( (data[15:0] !== 16'h2000) && // wrap bit
               (data[15:0] !== 16'h0000) ) // without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct 2: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end
        end
        else if ((i_length[1] == 1'b0) && (i_length[0] == 1'b1)) // interrupt enabled
        begin
          if ( (data[15:0] !== 16'h6800) && // wrap bit
               (data[15:0] !== 16'h4800) ) // without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct 3: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end
        end
        else if (num_of_frames != 23) // ((i_length[1] == 1'b1) && (i_length[0] == 1'b1)) // interrupt not enabled
        begin
          if ( (data[15:0] !== 16'h2800) && // wrap bit
               (data[15:0] !== 16'h0800) ) // without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct 4: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end
        end
        else // ((num_of_frames != 23) && (i_length[1] == 1'b1) && (i_length[0] == 1'b1)) // interrupt not enabled
        begin
          if ( (data[15:0] !== 16'h3800) && // wrap bit
               (data[15:0] !== 16'h1800) ) // without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct 5: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end
        end
      end
      else
      begin
        if (data[15] !== 1'b1)
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear TX BD with wrap bit
      if (num_of_frames == 63)
        clear_tx_bd(16, 16);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ( ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1)) && (num_of_frames >= 5) )
      begin
        if ((data & `ETH_INT_TXB) !== 1'b1)
        begin
          `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Transmit Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_TXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Transmit Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Transmit Buffer) was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Transmit Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        `TIME; $display("*E WB INT signal should not be set");
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if (i_length == 3)
      begin
        $display("    pads appending to packets is not selected (except for 0x23)");
        $display("    using 1 BD out of 8 BDs assigned to TX (wrap at 1st BD - TX BD 0)");
        $display("    ->packets with lengths from %0d to %0d are not transmitted (length increasing by 1 byte)",
                 0, 3);
      end
      else if (i_length == 9)
      begin
        $display("    using 1 BD out of 8 BDs assigned to TX (wrap at 1st BD - TX BD 0)");
        $display("    ->packet with length 4 is not transmitted (length increasing by 1 byte)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 5, 9);
      end
      else if (i_length == 17)
      begin
        $display("    using 4 BDs out of 8 BDs assigned to TX (wrap at 4th BD - TX BD 3)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 10, 17);
      end
      else if (i_length == 27)
      begin
        $display("    using 5 BDs out of 8 BDs assigned to TX (wrap at 5th BD - TX BD 4)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 18, 27);
      end
      else if (i_length == 40)
      begin
        $display("    using 6 BDs out of 8 BDs assigned to TX (wrap at 6th BD - TX BD 5)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 28, 40);
      end
      else if (i_length == 54)
      begin
        $display("    using 7 BDs out of 8 BDs assigned to TX (wrap at 7th BD - TX BD 6)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 41, 54);
      end
      else if (i_length == 69)
      begin
        $display("    using 8 BDs out of 8 BDs assigned to TX (wrap at 8th BD - TX BD 7)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 55, 69);
      end
      // set length (loop variable)
      i_length = i_length + 1;
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      if (/*(num_of_frames == 2) || (num_of_frames == 4) || (num_of_frames == 7) ||*/ (num_of_frames <= 10) || 
          (num_of_frames == 14) || (num_of_frames == 18) || (num_of_frames == 23) || (num_of_frames == 28) ||
          (num_of_frames == 34) || (num_of_frames == 40) || (num_of_frames == 47) ||
          (num_of_frames == 54) || (num_of_frames == 62))
        num_of_bd = 0;
      else
        num_of_bd = num_of_bd + 1;
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets across MAXFL value at               ////
  ////  13 TX buffer decriptors ( 10Mbps ).                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 10) //
  begin
    // TEST 10: TRANSMIT PACKETS ACROSS MAXFL VALUE AT 13 TX BDs ( 10Mbps )
    test_name = "TEST 10: TRANSMIT PACKETS ACROSS MAXFL VALUE AT 13 TX BDs ( 10Mbps )";
    `TIME; $display("  TEST 10: TRANSMIT PACKETS ACROSS MAXFL VALUE AT 13 TX BDs ( 10Mbps )");
  
    // reset MAC registers
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    tx_bd_num = 0;
    // set 13 TX buffer descriptors - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'hD, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, NO padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare a packet of MAXFL + 10 length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'hA3;
    set_tx_packet(`MEMORY_BASE, (max_tmp + 10), st_data); // length without CRC
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;
  
    i_length = (max_tmp - 5);
    while (num_of_bd <= 3)
    begin
      // unmask interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                               `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // not detect carrier sense in FD and no collision
      eth_phy.carrier_sense_tx_fd_detect(0);
      eth_phy.collision(0);
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);

      if (num_of_bd == 0)
      begin
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(1, 1, i_length+1, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(2, 2, i_length+2, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd_wrap(2);
        set_tx_bd_ready(0, 0);
      end
      else if (num_of_bd == 1)
      begin
        set_tx_bd_ready(1, 1);
        tx_bd_num = 1;
      end
      else if (num_of_bd == 2)
      begin
        set_tx_bd_ready(2, 2);
        tx_bd_num = 2;
      end
      else if (num_of_bd == 3)
      begin
        set_tx_bd(0, 0, 100, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd_wrap(2);
        set_tx_bd_ready(0, 0);
        i_length = 100;
        tx_bd_num = 0;
      end
        

      // CHECK END OF TRANSMITION
      check_tx_bd(tx_bd_num, data);
      wait (MTxEn === 1'b1); // start transmit
      check_tx_bd(tx_bd_num, data);
      if (data[15] !== 1)
      begin
        test_fail("Wrong buffer descriptor's ready bit read out from MAC");
        fail = fail + 1;
      end
      wait (MTxEn === 1'b0); // end transmit
      while (data[15] === 1)
      begin
        check_tx_bd(tx_bd_num, data);
        @(posedge wb_clk);
      end
      repeat (1) @(posedge wb_clk);
      // check length of a PACKET
      tmp_len = eth_phy.tx_len;
      #1;
      if ((i_length + 4) <= max_tmp)
      begin
        if (tmp_len != (i_length + 4))
        begin
          test_fail("Wrong length of the packet out from MAC");
          fail = fail + 1;
        end
      end
      else
      begin
        if (tmp_len != (i_length + 4 - 1))
        begin
          test_fail("Wrong length of the packet out from MAC");
          fail = fail + 1;
        end
      end

      // check transmitted TX packet data
      if ((i_length + 4) == 100)
        check_tx_packet(`MEMORY_BASE, 0, 100 - 4, tmp);
      else if ((i_length + 4) <= max_tmp)
        check_tx_packet(`MEMORY_BASE, 0, i_length, tmp);
      else
        check_tx_packet(`MEMORY_BASE, 0, max_tmp - 4, tmp);

      if (tmp > 0)
      begin
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end

      // check transmited TX packet CRC
      if ((i_length + 4) == 100)
        check_tx_crc(0, 100, 1'b0, tmp); // length without CRC
      else if ((i_length + 4) <= max_tmp)
        check_tx_crc(0, i_length, 1'b0, tmp); // length without CRC

      if (tmp > 0)
      begin
        test_fail("Wrong CRC of the transmitted packet");
        fail = fail + 1;
      end

      if (wb_int !== 1'b1)
      begin
        `TIME; $display("*E WB INT signal should be set");
        test_fail("WB INT signal should be set");
        fail = fail + 1;
      end

      check_tx_bd(tx_bd_num, data);
      if ( ((data[15:0] !== 16'h7800) && (num_of_bd == 2)) || // wrap bit
           ((data[15:0] !== 16'h5800) && (num_of_bd < 2)) )   // without wrap bit
      begin
        `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
        test_fail("TX buffer descriptor status is not correct");
        fail = fail + 1;
      end

      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((data & `ETH_INT_TXB) !== `ETH_INT_TXB)
      begin
        `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
        test_fail("Interrupt Transmit Buffer was not set");
        fail = fail + 1;
      end
      if ((data & (~`ETH_INT_TXB)) !== 0)
      begin
        `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
        test_fail("Other interrupts (except Transmit Buffer) were set");
        fail = fail + 1;
      end

      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end

      // INTERMEDIATE DISPLAYS
      if (num_of_bd == 0)
        $display("    ->packet with length %0d sent", (i_length + 4));
      else if (num_of_bd == 1)
        $display("    ->packet with length %0d sent", (i_length + 4));
      else if (num_of_bd == 2)
        $display("    ->packet with length %0d sent", (i_length + 4));
      else if (num_of_bd == 3)
        $display("    ->packet with length %0d sent", (104));
      // set length (loop variable)
      i_length = i_length + 1;
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      num_of_bd = num_of_bd + 1;
      @(posedge wb_clk);
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets across MAXFL value at               ////
  ////  13 TX buffer decriptors ( 100Mbps ).                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 11) //
  begin
    // TEST 11: TRANSMIT PACKETS ACROSS MAXFL VALUE AT 13 TX BDs ( 100Mbps )
    test_name = "TEST 11: TRANSMIT PACKETS ACROSS MAXFL VALUE AT 13 TX BDs ( 100Mbps )";
    `TIME; $display("  TEST 11: TRANSMIT PACKETS ACROSS MAXFL VALUE AT 13 TX BDs ( 100Mbps )");
  
    // reset MAC registers
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    tx_bd_num = 0;
    // set 13 TX buffer descriptors - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'hD, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, NO padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare a packet of MAXFL + 10 length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'hA3;
    set_tx_packet(`MEMORY_BASE, (max_tmp + 10), st_data); // length without CRC
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 reset - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 100;
  
    i_length = (max_tmp - 5);
    while (num_of_bd <= 3)
    begin
      // unmask interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                               `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // not detect carrier sense in FD and no collision
      eth_phy.carrier_sense_tx_fd_detect(0);
      eth_phy.collision(0);
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);

      if (num_of_bd == 0)
      begin
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(1, 1, i_length+1, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(2, 2, i_length+2, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd_wrap(2);
        set_tx_bd_ready(0, 0);
      end
      else if (num_of_bd == 1)
      begin
        set_tx_bd_ready(1, 1);
        tx_bd_num = 1;
      end
      else if (num_of_bd == 2)
      begin
        set_tx_bd_ready(2, 2);
        tx_bd_num = 2;
      end
      else if (num_of_bd == 3)
      begin
        set_tx_bd(0, 0, 100, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd_wrap(2);
        set_tx_bd_ready(0, 0);
        i_length = 100;
        tx_bd_num = 0;
      end
        

      // CHECK END OF TRANSMITION
      check_tx_bd(tx_bd_num, data);
      wait (MTxEn === 1'b1); // start transmit
      check_tx_bd(tx_bd_num, data);
      if (data[15] !== 1)
      begin
        test_fail("Wrong buffer descriptor's ready bit read out from MAC");
        fail = fail + 1;
      end
      wait (MTxEn === 1'b0); // end transmit
      while (data[15] === 1)
      begin
        check_tx_bd(tx_bd_num, data);
        @(posedge wb_clk);
      end
      repeat (1) @(posedge wb_clk);
      repeat (10) @(posedge mtx_clk);
      // check length of a PACKET
      tmp_len = eth_phy.tx_len;
      #1;
      if ((i_length + 4) <= max_tmp)
      begin
        if (tmp_len != (i_length + 4))
        begin
          test_fail("Wrong length of the packet out from MAC");
          fail = fail + 1;
        end
      end
      else
      begin
        if (tmp_len != (i_length + 4 - 1))
        begin
          test_fail("Wrong length of the packet out from MAC");
          fail = fail + 1;
        end
      end

      // check transmitted TX packet data
      if ((i_length + 4) == 100)
        check_tx_packet(`MEMORY_BASE, 0, 100 - 4, tmp);
      else if ((i_length + 4) <= max_tmp)
        check_tx_packet(`MEMORY_BASE, 0, i_length, tmp);
      else
        check_tx_packet(`MEMORY_BASE, 0, max_tmp - 4, tmp);

      if (tmp > 0)
      begin
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end

      // check transmited TX packet CRC
      if ((i_length + 4) == 100)
        check_tx_crc(0, 100, 1'b0, tmp); // length without CRC
      else if ((i_length + 4) <= max_tmp)
        check_tx_crc(0, i_length, 1'b0, tmp); // length without CRC

      if (tmp > 0)
      begin
        test_fail("Wrong CRC of the transmitted packet");
        fail = fail + 1;
      end

      if (wb_int !== 1'b1)
      begin
        `TIME; $display("*E WB INT signal should be set");
        test_fail("WB INT signal should be set");
        fail = fail + 1;
      end

      check_tx_bd(tx_bd_num, data);
      if ( ((data[15:0] !== 16'h7800) && (num_of_bd == 2)) || // wrap bit
           ((data[15:0] !== 16'h5800) && (num_of_bd < 2)) )   // without wrap bit
      begin
        `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
        test_fail("TX buffer descriptor status is not correct");
        fail = fail + 1;
      end

      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((data & `ETH_INT_TXB) !== `ETH_INT_TXB)
      begin
        `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
        test_fail("Interrupt Transmit Buffer was not set");
        fail = fail + 1;
      end
      if ((data & (~`ETH_INT_TXB)) !== 0)
      begin
        `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
        test_fail("Other interrupts (except Transmit Buffer) were set");
        fail = fail + 1;
      end

      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end

      // INTERMEDIATE DISPLAYS
      if (num_of_bd == 0)
        $display("    ->packet with length %0d sent", (i_length + 4));
      else if (num_of_bd == 1)
        $display("    ->packet with length %0d sent", (i_length + 4));
      else if (num_of_bd == 2)
        $display("    ->packet with length %0d sent", (i_length + 4));
      else if (num_of_bd == 3)
        $display("    ->packet with length %0d sent", (104));
      // set length (loop variable)
      i_length = i_length + 1;
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      num_of_bd = num_of_bd + 1;
      @(posedge wb_clk);
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end




  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets across changed MAXFL value at       ////
  ////  47 TX buffer decriptors ( 10Mbps ).                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 12) //
  begin
    // TEST 12: TRANSMIT PACKETS ACROSS CHANGED MAXFL VALUE AT 13 TX BDs ( 10Mbps )
    test_name = "TEST 12: TRANSMIT PACKETS ACROSS CHANGED MAXFL VALUE AT 13 TX BDs ( 10Mbps )";
    `TIME; $display("  TEST 12: TRANSMIT PACKETS ACROSS CHANGED MAXFL VALUE AT 13 TX BDs ( 10Mbps )");
  
    // reset MAC registers
    hard_reset;
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    tx_bd_num = 0;
    // set 47 TX buffer descriptors - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h2F, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare a packet of MAXFL + 10 length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    // change MAXFL value
    max_tmp = min_tmp + 53;
    wait (wbm_working == 0);
    wbm_write(`ETH_PACKETLEN, {min_tmp, max_tmp}, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    st_data = 8'h62;
    set_tx_packet(`MEMORY_BASE, max_tmp, st_data); // length with CRC
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;
  
    i_length = (max_tmp - 5); // (max_tmp - 1); // not (max_tmp - 5) because NO automatic CRC appending
    while (i_length <= (max_tmp - 3)) // (max_tmp + 1)) // (max_tmp) is the limit
    begin
      wait (wbm_working == 0);
      wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                               `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // not detect carrier sense in FD and no collision
      eth_phy.carrier_sense_tx_fd_detect(0);
      eth_phy.collision(0);
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      // prepare BDs
      if (num_of_bd == 0)
      begin
        set_tx_bd(0, 0, i_length+4, 1'b1, 1'b1, 1'b0, `MEMORY_BASE); // no CRC adding
        set_tx_bd(1, 1, i_length+1, 1'b1, 1'b0, 1'b1, `MEMORY_BASE); // no PADDING
        set_tx_bd(2, 2, i_length+2, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd_wrap(2);
        set_tx_bd_ready(0, 0);
      end
      else if (num_of_bd == 1)
      begin
        set_tx_bd_ready(1, 1);
        tx_bd_num = 1;
      end
      else if (num_of_bd == 2)
      begin
        set_tx_bd_ready(2, 2);
        tx_bd_num = 2;
      end
      // CHECK END OF TRANSMITION
      check_tx_bd(tx_bd_num, data);
        wait (MTxEn === 1'b1); // start transmit
      check_tx_bd(tx_bd_num, data);
        if (data[15] !== 1)
        begin
          test_fail("Wrong buffer descriptor's ready bit read out from MAC");
          fail = fail + 1;
        end
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
      check_tx_bd(tx_bd_num, data);
          @(posedge wb_clk);
        end
        repeat (5) @(posedge mtx_clk);
      // check length of a PACKET
      tmp_len = eth_phy.tx_len;
      #1;
      if ((i_length + 4) <= max_tmp)
      begin
        if (tmp_len != (i_length + 4))
        begin
          test_fail("Wrong length of the packet out from MAC");
          fail = fail + 1;
        end
      end
      else
      begin
        if (tmp_len != (i_length + 4 - 1))
        begin
          test_fail("Wrong length of the packet out from MAC");
          fail = fail + 1;
        end
      end

      // checking packet
      if (num_of_bd === 0)
        check_tx_packet(`MEMORY_BASE, 0, i_length + 4, tmp); // also data representing CRC
      else
        check_tx_packet(`MEMORY_BASE, 0, i_length, tmp);
      if (tmp > 0)
      begin
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end
      // check transmited TX packet CRC
      if (num_of_bd === 1)
        check_tx_crc(0, i_length, 1'b0, tmp); // length without CRC
      if (tmp > 0)
      begin
        test_fail("Wrong CRC of the transmitted packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (wb_int !== 1'b1)
      begin
        `TIME; $display("*E WB INT signal should be set");
        test_fail("WB INT signal should be set");
        fail = fail + 1;
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(tx_bd_num, data);
      if ( ((data[15:0] !== 16'h7800) && (num_of_bd == 2)) || // wrap bit
           ((data[15:0] !== 16'h4800) && (num_of_bd == 1)) || // without wrap bit and without pad bit
           ((data[15:0] !== 16'h5000) && (num_of_bd == 0)) )   // without wrap bit and without crc bit
      begin
        `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
        test_fail("TX buffer descriptor status is not correct");
        fail = fail + 1;
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((data & `ETH_INT_TXB) !== 1'b1)
      begin
        `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
        test_fail("Interrupt Transmit Buffer was not set");
        fail = fail + 1;
      end
      if ((data & (~`ETH_INT_TXB)) !== 0)
      begin
        `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
        test_fail("Other interrupts (except Transmit Buffer) were set");
        fail = fail + 1;
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if (num_of_bd == 0)
        $display("    ->packet with length %0d sent", (i_length + 4));
      else if (num_of_bd == 1)
        $display("    ->packet with length %0d sent", (i_length + 4));
      else if (num_of_bd == 2)
        $display("    ->packet with length %0d sent", (i_length + 4));
      // set length (loop variable)
      i_length = i_length + 1;
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      num_of_bd = num_of_bd + 1;
      @(posedge wb_clk);
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets across changed MAXFL value at       ////
  ////  47 TX buffer decriptors ( 100Mbps ).                      ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 13) //
  begin
    // TEST 13: TRANSMIT PACKETS ACROSS CHANGED MAXFL VALUE AT 13 TX BDs ( 100Mbps )
    test_name = "TEST 13: TRANSMIT PACKETS ACROSS CHANGED MAXFL VALUE AT 13 TX BDs ( 100Mbps )";
    `TIME; $display("  TEST 13: TRANSMIT PACKETS ACROSS CHANGED MAXFL VALUE AT 13 TX BDs ( 100Mbps )");
  
    // reset MAC registers
    hard_reset;
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    tx_bd_num = 0;
    // set 47 TX buffer descriptors - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h2F, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare a packet of MAXFL + 10 length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    // change MAXFL value
    max_tmp = min_tmp + 53;
    wait (wbm_working == 0);
    wbm_write(`ETH_PACKETLEN, {min_tmp, max_tmp}, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    st_data = 8'h62;
    set_tx_packet(`MEMORY_BASE, max_tmp, st_data); // length with CRC
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 reset - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 100;
  
    i_length = (max_tmp - 5); // (max_tmp - 1); // not (max_tmp - 5) because NO automatic CRC appending
    while (i_length <= (max_tmp - 3)) // (max_tmp + 1)) // (max_tmp) is the limit
    begin
      wait (wbm_working == 0);
      wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                               `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // not detect carrier sense in FD and no collision
      eth_phy.carrier_sense_tx_fd_detect(0);
      eth_phy.collision(0);
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      // prepare BDs
      if (num_of_bd == 0)
      begin
        set_tx_bd(0, 0, i_length+4, 1'b1, 1'b1, 1'b0, `MEMORY_BASE); // no CRC adding
        set_tx_bd(1, 1, i_length+1, 1'b1, 1'b0, 1'b1, `MEMORY_BASE); // no PADDING
        set_tx_bd(2, 2, i_length+2, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd_wrap(2);
        set_tx_bd_ready(0, 0);
      end
      else if (num_of_bd == 1)
      begin
        set_tx_bd_ready(1, 1);
        tx_bd_num = 1;
      end
      else if (num_of_bd == 2)
      begin
        set_tx_bd_ready(2, 2);
        tx_bd_num = 2;
      end
      // CHECK END OF TRANSMITION
      check_tx_bd(tx_bd_num, data);
        wait (MTxEn === 1'b1); // start transmit
      check_tx_bd(tx_bd_num, data);
        if (data[15] !== 1)
        begin
          test_fail("Wrong buffer descriptor's ready bit read out from MAC");
          fail = fail + 1;
        end
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
      check_tx_bd(tx_bd_num, data);
          @(posedge wb_clk);
        end
        repeat (5) @(posedge mtx_clk);
      // check length of a PACKET
      tmp_len = eth_phy.tx_len;
      #1;
      if ((i_length + 4) <= max_tmp)
      begin
        if (tmp_len != (i_length + 4))
        begin
          test_fail("Wrong length of the packet out from MAC");
          fail = fail + 1;
        end
      end
      else
      begin
        if (tmp_len != (i_length + 4 - 1))
        begin
          test_fail("Wrong length of the packet out from MAC");
          fail = fail + 1;
        end
      end

      // checking packet
      if (num_of_bd === 0)
        check_tx_packet(`MEMORY_BASE, 0, i_length + 4, tmp); // also data representing CRC
      else
        check_tx_packet(`MEMORY_BASE, 0, i_length, tmp);
      if (tmp > 0)
      begin
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end
      // check transmited TX packet CRC
      if (num_of_bd === 1)
        check_tx_crc(0, i_length, 1'b0, tmp); // length without CRC
      if (tmp > 0)
      begin
        test_fail("Wrong CRC of the transmitted packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (wb_int !== 1'b1)
      begin
        `TIME; $display("*E WB INT signal should be set");
        test_fail("WB INT signal should be set");
        fail = fail + 1;
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(tx_bd_num, data);
      if ( ((data[15:0] !== 16'h7800) && (num_of_bd == 2)) || // wrap bit
           ((data[15:0] !== 16'h4800) && (num_of_bd == 1)) || // without wrap bit and without pad bit
           ((data[15:0] !== 16'h5000) && (num_of_bd == 0)) )   // without wrap bit and without crc bit
      begin
        `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
        test_fail("TX buffer descriptor status is not correct");
        fail = fail + 1;
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((data & `ETH_INT_TXB) !== 1'b1)
      begin
        `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
        test_fail("Interrupt Transmit Buffer was not set");
        fail = fail + 1;
      end
      if ((data & (~`ETH_INT_TXB)) !== 0)
      begin
        `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
        test_fail("Other interrupts (except Transmit Buffer) were set");
        fail = fail + 1;
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if (num_of_bd == 0)
        $display("    ->packet with length %0d sent", (i_length + 4));
      else if (num_of_bd == 1)
        $display("    ->packet with length %0d sent", (i_length + 4));
      else if (num_of_bd == 2)
        $display("    ->packet with length %0d sent", (i_length + 4));
      // set length (loop variable)
      i_length = i_length + 1;
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      num_of_bd = num_of_bd + 1;
      @(posedge wb_clk);
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets across changed MINFL value at       ////
  ////  7 TX buffer decriptors ( 10Mbps ).                        ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 14) //
  begin
    // TEST 14: TRANSMIT PACKETS ACROSS CHANGED MINFL VALUE AT 7 TX BDs ( 10Mbps )
    test_name = "TEST 14: TRANSMIT PACKETS ACROSS CHANGED MINFL VALUE AT 7 TX BDs ( 10Mbps )";
    `TIME; $display("  TEST 14: TRANSMIT PACKETS ACROSS CHANGED MINFL VALUE AT 7 TX BDs ( 10Mbps )");
  
    // reset MAC registers
    hard_reset;

    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    // set 7 TX buffer descriptors - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h7, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare a packet of MAXFL + 10 length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];

    // change MINFL value
    min_tmp = max_tmp - 177;
    wait (wbm_working == 0);
    wbm_write(`ETH_PACKETLEN, {min_tmp, max_tmp}, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    st_data = 8'h62;
    set_tx_packet(`MEMORY_BASE, min_tmp, st_data); // length without CRC
    // enable TX, set full-duplex mode, padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_PAD | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;
  
    i_length = (min_tmp - 5); 
    while (i_length <= (min_tmp - 3)) // (min_tmp - 4) is the limit
    begin
      // Reset_tx_bd nable interrupt generation
      // unmask interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                               `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // not detect carrier sense in FD and no collision
      eth_phy.carrier_sense_tx_fd_detect(0);
      eth_phy.collision(0);
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      // prepare BDs
      if (num_of_bd == 0)
      begin
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(1, 1, i_length+1, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(2, 2, i_length+2, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd_wrap(2);
        set_tx_bd_ready(0, 0);
      end
      else if (num_of_bd == 1)
        set_tx_bd_ready(1, 1);
      else if (num_of_bd == 2)
        set_tx_bd_ready(2, 2);
      // CHECK END OF TRANSMITION
      check_tx_bd(num_of_bd, data);
        wait (MTxEn === 1'b1); // start transmit
      check_tx_bd(num_of_bd, data);
        if (data[15] !== 1)
        begin
          test_fail("Wrong buffer descriptor's ready bit read out from MAC");
          fail = fail + 1;
        end
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
      check_tx_bd(num_of_bd, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      // check length of a PACKET
      tmp_len = eth_phy.tx_len;
      #1;
      if ((i_length + 4) >= min_tmp)
      begin
        if (tmp_len != (i_length + 4))
        begin
          test_fail("Wrong length of the packet out from MAC");
          fail = fail + 1;
        end
      end
      else
      begin
        if (tmp_len != (i_length + 4 + 1))
        begin
          test_fail("Wrong length of the packet out from MAC");
          fail = fail + 1;
        end
      end
      // checking packet
      check_tx_packet(`MEMORY_BASE, 0, i_length, tmp);
      if (tmp > 0)
      begin
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end
      // check transmited TX packet CRC
      if (num_of_bd !== 0)  // First packet is padded and CRC does not match.
        check_tx_crc(0, i_length, 1'b0, tmp); // length without CRC
      else
        tmp = 0;
      if (tmp > 0)
      begin
        test_fail("Wrong CRC of the transmitted packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (wb_int !== 1'b1)
      begin
        `TIME; $display("*E WB INT signal should be set");
        test_fail("WB INT signal should be set");
        fail = fail + 1;
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(num_of_bd, data);
      if ( ((data[15:0] !== 16'h7800) && (num_of_bd == 2)) || // wrap bit
           ((data[15:0] !== 16'h5800) && (num_of_bd < 2)) )   // without wrap bit
      begin
        `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
        test_fail("TX buffer descriptor status is not correct");
        fail = fail + 1;
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((data & `ETH_INT_TXB) !== 1'b1)
      begin
        `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
        test_fail("Interrupt Transmit Buffer was not set");
        fail = fail + 1;
      end
      if ((data & (~`ETH_INT_TXB)) !== 0)
      begin
        `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
        test_fail("Other interrupts (except Transmit Buffer) were set");
        fail = fail + 1;
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if (num_of_bd == 0)
        $display("    ->packet with length %0d sent", (i_length + 4));
      else if (num_of_bd == 1)
        $display("    ->packet with length %0d sent", (i_length + 4));
      else if (num_of_bd == 2)
        $display("    ->packet with length %0d sent", (i_length + 4));
      // set length (loop variable)
      i_length = i_length + 1;
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      num_of_bd = num_of_bd + 1;
      @(posedge wb_clk);
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets across changed MINFL value at       ////
  ////  7 TX buffer decriptors ( 100Mbps ).                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 15) //
  begin
    // TEST 15: TRANSMIT PACKETS ACROSS CHANGED MINFL VALUE AT 7 TX BDs ( 100Mbps )
    test_name = "TEST 15: TRANSMIT PACKETS ACROSS CHANGED MINFL VALUE AT 7 TX BDs ( 100Mbps )";
    `TIME; $display("  TEST 15: TRANSMIT PACKETS ACROSS CHANGED MINFL VALUE AT 7 TX BDs ( 100Mbps )");
  
    hard_reset;

    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    // set 7 TX buffer descriptors - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h7, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare a packet of MAXFL + 10 length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    // change MINFL value
    min_tmp = max_tmp - 177;
    wait (wbm_working == 0);
    wbm_write(`ETH_PACKETLEN, {min_tmp, max_tmp}, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    st_data = 8'h62;
    set_tx_packet(`MEMORY_BASE, min_tmp, st_data); // length without CRC
    // enable TX, set full-duplex mode, padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_PAD | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;
  
    i_length = (min_tmp - 5); 
    while (i_length <= (min_tmp - 3)) // (min_tmp - 4) is the limit
    begin
      // Reset_tx_bd nable interrupt generation
      // unmask interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                               `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // not detect carrier sense in FD and no collision
      eth_phy.carrier_sense_tx_fd_detect(0);
      eth_phy.collision(0);
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      // prepare BDs
      if (num_of_bd == 0)
      begin
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(1, 1, i_length+1, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(2, 2, i_length+2, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd_wrap(2);
        set_tx_bd_ready(0, 0);
      end
      else if (num_of_bd == 1)
        set_tx_bd_ready(1, 1);
      else if (num_of_bd == 2)
        set_tx_bd_ready(2, 2);
      // CHECK END OF TRANSMITION
      check_tx_bd(num_of_bd, data);
        wait (MTxEn === 1'b1); // start transmit
      check_tx_bd(num_of_bd, data);
        if (data[15] !== 1)
        begin
          test_fail("Wrong buffer descriptor's ready bit read out from MAC");
          fail = fail + 1;
        end
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
      check_tx_bd(num_of_bd, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      // check length of a PACKET
      tmp_len = eth_phy.tx_len;
      #1;
      if ((i_length + 4) >= min_tmp)
      begin
        if (tmp_len != (i_length + 4))
        begin
          test_fail("Wrong length of the packet out from MAC");
          fail = fail + 1;
        end
      end
      else
      begin
        if (tmp_len != (i_length + 4 + 1))
        begin
          test_fail("Wrong length of the packet out from MAC");
          fail = fail + 1;
        end
      end
      // checking packet
      check_tx_packet(`MEMORY_BASE, 0, i_length, tmp);
      if (tmp > 0)
      begin
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end
      // check transmited TX packet CRC
      if (num_of_bd !== 0)
        check_tx_crc(0, i_length, 1'b0, tmp); // length without CRC
      else
        tmp = 0;

      if (tmp > 0)
      begin
        test_fail("Wrong CRC of the transmitted packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (wb_int !== 1'b1)
      begin
        `TIME; $display("*E WB INT signal should be set");
        test_fail("WB INT signal should be set");
        fail = fail + 1;
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(num_of_bd, data);
      if ( ((data[15:0] !== 16'h7800) && (num_of_bd == 2)) || // wrap bit
           ((data[15:0] !== 16'h5800) && (num_of_bd < 2)) )   // without wrap bit
      begin
        `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
        test_fail("TX buffer descriptor status is not correct");
        fail = fail + 1;
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((data & `ETH_INT_TXB) !== 1'b1)
      begin
        `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
        test_fail("Interrupt Transmit Buffer was not set");
        fail = fail + 1;
      end
      if ((data & (~`ETH_INT_TXB)) !== 0)
      begin
        `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
        test_fail("Other interrupts (except Transmit Buffer) were set");
        fail = fail + 1;
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if (num_of_bd == 0)
        $display("    ->packet with length %0d sent", (i_length + 4));
      else if (num_of_bd == 1)
        $display("    ->packet with length %0d sent", (i_length + 4));
      else if (num_of_bd == 2)
        $display("    ->packet with length %0d sent", (i_length + 4));
      // set length (loop variable)
      i_length = i_length + 1;
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      num_of_bd = num_of_bd + 1;
      @(posedge wb_clk);
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets across MAXFL with HUGEN at          ////
  ////  19 TX buffer decriptors ( 10Mbps ).                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 16) //
  begin
    // TEST 16: TRANSMIT PACKETS ACROSS MAXFL WITH HUGEN AT 19 TX BDs ( 10Mbps )
    test_name = "TEST 16: TRANSMIT PACKETS ACROSS MAXFL WITH HUGEN AT 19 TX BDs ( 10Mbps )";
    `TIME; $display("  TEST 16: TRANSMIT PACKETS ACROSS MAXFL WITH HUGEN AT 19 TX BDs ( 10Mbps )");
  
    // reset MAC registers
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    // set 19 TX buffer descriptors - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h13, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare a packet of 64k - 1 length (16'hFFFF)
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h8D;
    set_tx_packet(`MEMORY_BASE, 16'hFFFF, st_data); // length with CRC
    // enable TX, set full-duplex mode, NO padding, CRC appending and huge enabled
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN | `ETH_MODER_HUGEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;
  
    i_length = (max_tmp - 5); // (max_tmp - 4) is the MAXFL limit
    while (i_length <= (16'hFFFF - 4)) // (16'hFFFF - 4) is the limit
    begin
      $display("   i_length = %0d", i_length);
      // Reset_tx_bd nable interrupt generation
      // unmask interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                               `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // not detect carrier sense in FD and no collision
      eth_phy.carrier_sense_tx_fd_detect(0);
      eth_phy.collision(0);
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      // prepare BDs
      if (num_of_bd == 0)
      begin
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(1, 1, i_length+1, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(2, 2, i_length+2, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(3, 3, (16'hFFFF - 5), 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(4, 4, (16'hFFFF - 4), 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd_wrap(4);
        set_tx_bd_ready(0, 0);
      end
      else if (num_of_bd == 1)
        set_tx_bd_ready(1, 1);
      else if (num_of_bd == 2)
        set_tx_bd_ready(2, 2);
      else if (num_of_bd == 3)
        set_tx_bd_ready(3, 3);
      else if (num_of_bd == 4)
        set_tx_bd_ready(4, 4);
      // CHECK END OF TRANSMITION
      check_tx_bd(num_of_bd, data);
        wait (MTxEn === 1'b1); // start transmit
      check_tx_bd(num_of_bd, data);
        if (data[15] !== 1)
        begin
          test_fail("Wrong buffer descriptor's ready bit read out from MAC");
          fail = fail + 1;
        end
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
      check_tx_bd(num_of_bd, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      // check length of a PACKET
      $display("   eth_phy length = %0d", eth_phy.tx_len);
      tmp_len = eth_phy.tx_len;
      #1;
      if (tmp_len != (i_length + 4))
      begin
        test_fail("Wrong length of the packet out from MAC");
        fail = fail + 1;
      end
      // checking packet
      check_tx_packet(`MEMORY_BASE, 0, i_length, tmp);
      if (tmp > 0)
      begin
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end
      // check transmited TX packet CRC
      check_tx_crc(0, i_length, 1'b0, tmp); // length without CRC
      if (tmp > 0)
      begin
        test_fail("Wrong CRC of the transmitted packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (wb_int !== 1'b1)
      begin
        `TIME; $display("*E WB INT signal should be set");
        test_fail("WB INT signal should be set");
        fail = fail + 1;
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(num_of_bd, data);
      if ( ((data[15:0] !== 16'h7800) && (num_of_bd == 4)) || // wrap bit
           ((data[15:0] !== 16'h5800) && (num_of_bd < 4)) )   // without wrap bit
      begin
        `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
        test_fail("TX buffer descriptor status is not correct");
        fail = fail + 1;
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((data & `ETH_INT_TXB) !== 1'b1)
      begin
        `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
        test_fail("Interrupt Transmit Buffer was not set");
        fail = fail + 1;
      end
      if ((data & (~`ETH_INT_TXB)) !== 0)
      begin
        `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
        test_fail("Other interrupts (except Transmit Buffer) were set");
        fail = fail + 1;
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      $display("    ->packet with length %0d sent", (i_length + 4));
      // set length (loop variable)
      if ((num_of_bd < 2) || (num_of_bd >= 3))
        i_length = i_length + 1;
      else if (num_of_bd == 2)
        i_length = (16'hFFFF - 5);
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      num_of_bd = num_of_bd + 1;
      @(posedge wb_clk);
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets across MAXFL with HUGEN at          ////
  ////  19 TX buffer decriptors ( 100Mbps ).                      ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 17) //
  begin
    // TEST 17: TRANSMIT PACKETS ACROSS MAXFL WITH HUGEN AT 19 TX BDs ( 100Mbps )
    test_name = "TEST 17: TRANSMIT PACKETS ACROSS MAXFL WITH HUGEN AT 19 TX BDs ( 100Mbps )";
    `TIME; $display("  TEST 17: TRANSMIT PACKETS ACROSS MAXFL WITH HUGEN AT 19 TX BDs ( 100Mbps )");
  
    // reset MAC registers
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    // set 19 TX buffer descriptors - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h13, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare a packet of 64k - 1 length (16'hFFFF)
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h8D;
    set_tx_packet(`MEMORY_BASE, 16'hFFFF, st_data); // length with CRC
    // enable TX, set full-duplex mode, NO padding, CRC appending and huge enabled
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN | `ETH_MODER_HUGEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;
  
    i_length = (max_tmp - 5); // (max_tmp - 4) is the MAXFL limit
    while (i_length <= (16'hFFFF - 4)) // (16'hFFFF - 4) is the limit
    begin
      $display("   i_length = %0d", i_length);
      // Reset_tx_bd nable interrupt generation
      // unmask interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                               `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // not detect carrier sense in FD and no collision
      eth_phy.carrier_sense_tx_fd_detect(0);
      eth_phy.collision(0);
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      // prepare BDs
      if (num_of_bd == 0)
      begin
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(1, 1, i_length+1, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(2, 2, i_length+2, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(3, 3, (16'hFFFF - 5), 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(4, 4, (16'hFFFF - 4), 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd_wrap(4);
        set_tx_bd_ready(0, 0);
      end
      else if (num_of_bd == 1)
        set_tx_bd_ready(1, 1);
      else if (num_of_bd == 2)
        set_tx_bd_ready(2, 2);
      else if (num_of_bd == 3)
        set_tx_bd_ready(3, 3);
      else if (num_of_bd == 4)
        set_tx_bd_ready(4, 4);
      // CHECK END OF TRANSMITION
      check_tx_bd(num_of_bd, data);
        wait (MTxEn === 1'b1); // start transmit
      check_tx_bd(num_of_bd, data);
        if (data[15] !== 1)
        begin
          test_fail("Wrong buffer descriptor's ready bit read out from MAC");
          fail = fail + 1;
        end
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
      check_tx_bd(num_of_bd, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      // check length of a PACKET
      $display("   eth_phy length = %0d", eth_phy.tx_len);
      tmp_len = eth_phy.tx_len;
      #1;
      if (tmp_len != (i_length + 4))
      begin
        test_fail("Wrong length of the packet out from MAC");
        fail = fail + 1;
      end
      // checking packet
      check_tx_packet(`MEMORY_BASE, 0, i_length, tmp);
      if (tmp > 0)
      begin
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end
      // check transmited TX packet CRC
      check_tx_crc(0, i_length, 1'b0, tmp); // length without CRC
      if (tmp > 0)
      begin
        test_fail("Wrong CRC of the transmitted packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (wb_int !== 1'b1)
      begin
        `TIME; $display("*E WB INT signal should be set");
        test_fail("WB INT signal should be set");
        fail = fail + 1;
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(num_of_bd, data);
      if ( ((data[15:0] !== 16'h7800) && (num_of_bd == 4)) || // wrap bit
           ((data[15:0] !== 16'h5800) && (num_of_bd < 4)) )   // without wrap bit
      begin
        `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
        test_fail("TX buffer descriptor status is not correct");
        fail = fail + 1;
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((data & `ETH_INT_TXB) !== 1'b1)
      begin
        `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
        test_fail("Interrupt Transmit Buffer was not set");
        fail = fail + 1;
      end
      if ((data & (~`ETH_INT_TXB)) !== 0)
      begin
        `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
        test_fail("Other interrupts (except Transmit Buffer) were set");
        fail = fail + 1;
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      $display("    ->packet with length %0d sent", (i_length + 4));
      // set length (loop variable)
      if ((num_of_bd < 2) || (num_of_bd >= 3))
        i_length = i_length + 1;
      else if (num_of_bd == 2)
        i_length = (16'hFFFF - 5);
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      num_of_bd = num_of_bd + 1;
      @(posedge wb_clk);
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test IPG during Back-to-Back transmit at                  ////
  ////  88 TX buffer decriptors ( 10Mbps ).                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 18) //
  begin
    // TEST 18: IPG DURING BACK-TO-BACK TRANSMIT AT 88 TX BDs ( 10Mbps )
    test_name = "TEST 18: IPG DURING BACK-TO-BACK TRANSMIT AT 88 TX BDs ( 10Mbps )";
    `TIME; $display("  TEST 18: IPG DURING BACK-TO-BACK TRANSMIT AT 88 TX BDs ( 10Mbps )");
  
    // reset MAC registers
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    tmp_ipgt = 0;
    // set 88 TX buffer descriptors - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h58, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, NO padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h29;
    set_tx_packet(`MEMORY_BASE, (max_tmp - 4), st_data); // length without CRC
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;
  
    i_length = (min_tmp - 4);
    while (i_length < (max_tmp - 4))
    begin
      // disable TX, set full-duplex mode, NO padding and CRC appending
      wait (wbm_working == 0);
      wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
                4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // set IPGT register
      wait (wbm_working == 0);
      wbm_write(`ETH_IPGT, tmp_ipgt, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // enable TX, set full-duplex mode, NO padding and CRC appending
      wait (wbm_working == 0);
      wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
                4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // Reset_tx_bd enable interrupt generation
      // unmask interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                               `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // not detect carrier sense in FD and no collision
      eth_phy.carrier_sense_tx_fd_detect(0);
      eth_phy.collision(0);
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      // prepare BDs
      if (num_of_bd == 0)
      begin
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(1, 1, i_length+1, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd_wrap(1);
        set_tx_bd_ready(0, 0);
        set_tx_bd_ready(1, 1);
      end
      // CHECK END OF TWO TRANSMITIONs
      // wait for first transmit to end
      check_tx_bd(num_of_bd, data);
      wait (MTxEn === 1'b1); // start transmit
      if (data[15] !== 1)
      begin
        test_fail("Wrong buffer descriptor's ready bit read out from MAC");
        fail = fail + 1;
      end
      wait (MTxEn === 1'b0); // end transmit
      num_of_frames = num_of_frames + 1;
      num_of_bd = num_of_bd + 1;
      #Tp;
      // destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      i1 = 0;
      i2 = 0;
      // count IPG clock periods
      fork
        begin
          wait (MTxEn === 1'b1); // start second transmit
          #Tp;
          disable count_rising;
          disable count_falling;
        end
        begin: count_rising
          forever
          begin
            @(posedge mtx_clk);
            i1 = i1 + 1;
            #Tp;
          end
        end
        begin: count_falling
          forever
          begin
            @(negedge mtx_clk);
            i2 = i2 + 1;
            #Tp;
          end
        end
      join
      // check IPG length - INTERMEDIATE DISPLAYS
      if((i1 == i2) && (i1 >= (tmp_ipgt + 3)))
      begin
        $display("    ->IPG with %0d mtx_clk periods (min %0d) between packets with lengths %0d and %0d checked",
                  i1, (tmp_ipgt + 3), (i_length + 4), (i_length + 4 + 1));
      end
      else
      begin
        `TIME; $display("*E IPG is not correct: (%0d + %0d) / 2, requested: %d", i1, i2, (tmp_ipgt + 3));
        fail = fail + 1;
        test_fail("IPG is not correct");
      end
      // wait for second transmit to end
      wait (MTxEn === 1'b0); // end second transmit
      while (data[15] === 1)
      begin
        check_tx_bd(num_of_bd, data);
        @(posedge wb_clk);
      end
      repeat (1) @(posedge wb_clk);
      // check length of a second PACKET
      tmp_len = eth_phy.tx_len;
      #1;
      if (tmp_len != (i_length + 4 + 1))
      begin
        test_fail("Wrong length of second packet out from MAC");
        fail = fail + 1;
      end
      // checking second packet
      check_tx_packet(`MEMORY_BASE, 0, (i_length + 1), tmp);
      if (tmp > 0)
      begin
        test_fail("Wrong data of second transmitted packet");
        fail = fail + 1;
      end
      // check second transmited TX packet CRC
      check_tx_crc(0, (i_length + 1), 1'b0, tmp); // length without CRC
      if (tmp > 0)
      begin
        test_fail("Wrong CRC of second transmitted packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (wb_int !== 1'b1)
      begin
        `TIME; $display("*E WB INT signal should be set");
        test_fail("WB INT signal should be set");
        fail = fail + 1;
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(num_of_bd, data);
      if ( ((data[15:0] !== 16'h7800) && (num_of_bd == 1)) || // wrap bit
           ((data[15:0] !== 16'h5800) && (num_of_bd < 1)) )   // without wrap bit
      begin
        `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
        test_fail("TX buffer descriptor status is not correct");
        fail = fail + 1;
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((data & `ETH_INT_TXB) !== 1'b1)
      begin
        `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
        test_fail("Interrupt Transmit Buffer was not set");
        fail = fail + 1;
      end
      if ((data & (~`ETH_INT_TXB)) !== 0)
      begin
        `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
        test_fail("Other interrupts (except Transmit Buffer) were set");
        fail = fail + 1;
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // set length (LOOP variable)
      if ((tmp_ipgt + 3) < 130) // tmp_ipgt < 124
        i_length = i_length + 2;
      else
        i_length = (max_tmp - 4);
      // set IPGT
      if ((tmp_ipgt + 3) < 10)
        tmp_ipgt = tmp_ipgt + 1;
      else if ((tmp_ipgt + 3) < 24)
        tmp_ipgt = tmp_ipgt + 7;
      else if ((tmp_ipgt + 3) == 24)
        tmp_ipgt = 38 - 3;
      else if ((tmp_ipgt + 3) == 38)
        tmp_ipgt = 72 - 3;
      else if ((tmp_ipgt + 3) == 72)
        tmp_ipgt = 130 - 3; // 124 - 3
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      num_of_bd = 0;
      @(posedge wb_clk);
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test IPG during Back-to-Back transmit at                  ////
  ////  88 TX buffer decriptors ( 100Mbps ).                      ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 19) //
  begin
    // TEST 19: IPG DURING BACK-TO-BACK TRANSMIT AT 88 TX BDs ( 100Mbps )
    test_name = "TEST 19: IPG DURING BACK-TO-BACK TRANSMIT AT 88 TX BDs ( 100Mbps )";
    `TIME; $display("  TEST 19: IPG DURING BACK-TO-BACK TRANSMIT AT 88 TX BDs ( 100Mbps )");
  
    // reset MAC registers
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    tmp_ipgt = 0;
    // set 88 TX buffer descriptors - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h58, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, NO padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h29;
    set_tx_packet(`MEMORY_BASE, (max_tmp - 4), st_data); // length without CRC
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;
  
    i_length = (min_tmp - 4);
    while (i_length < (max_tmp - 4))
    begin
      // disable TX, set full-duplex mode, NO padding and CRC appending
      wait (wbm_working == 0);
      wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
                4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // set IPGT register
      wait (wbm_working == 0);
      wbm_write(`ETH_IPGT, tmp_ipgt, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // enable TX, set full-duplex mode, NO padding and CRC appending
      wait (wbm_working == 0);
      wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
                4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // Reset_tx_bd enable interrupt generation
      // unmask interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                               `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // not detect carrier sense in FD and no collision
      eth_phy.carrier_sense_tx_fd_detect(0);
      eth_phy.collision(0);
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      // prepare BDs
      if (num_of_bd == 0)
      begin
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd(1, 1, i_length+1, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd_wrap(1);
        set_tx_bd_ready(0, 0);
        set_tx_bd_ready(1, 1);
      end
      // CHECK END OF TWO TRANSMITIONs
      // wait for first transmit to end
      check_tx_bd(num_of_bd, data);
      wait (MTxEn === 1'b1); // start transmit
      if (data[15] !== 1)
      begin
        test_fail("Wrong buffer descriptor's ready bit read out from MAC");
        fail = fail + 1;
      end
      wait (MTxEn === 1'b0); // end transmit
      num_of_frames = num_of_frames + 1;
      num_of_bd = num_of_bd + 1;
      #Tp;
      // destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      i1 = 0;
      i2 = 0;
      // count IPG clock periods
      fork
        begin
          wait (MTxEn === 1'b1); // start second transmit
          #Tp;
          disable count_rising1;
          disable count_falling1;
        end
        begin: count_rising1
          forever
          begin
            @(posedge mtx_clk);
            i1 = i1 + 1;
            #Tp;
          end
        end
        begin: count_falling1
          forever
          begin
            @(negedge mtx_clk);
            i2 = i2 + 1;
            #Tp;
          end
        end
      join
      // check IPG length - INTERMEDIATE DISPLAYS
      if((i1 == i2) && (i1 >= (tmp_ipgt + 3)))
      begin
        $display("    ->IPG with %0d mtx_clk periods (min %0d) between packets with lengths %0d and %0d checked",
                  i1, (tmp_ipgt + 3), (i_length + 4), (i_length + 4 + 1));
      end
      else
      begin
        `TIME; $display("*E IPG is not correct: (%0d + %0d) / 2, requested: %d", i1, i2, (tmp_ipgt + 3));
        fail = fail + 1;
        test_fail("IPG is not correct");
      end
      // wait for second transmit to end
      wait (MTxEn === 1'b0); // end second transmit
      while (data[15] === 1)
      begin
        check_tx_bd(num_of_bd, data);
        @(posedge wb_clk);
      end
      repeat (1) @(posedge wb_clk);
      // check length of a second PACKET
      tmp_len = eth_phy.tx_len;
      #1;
      if (tmp_len != (i_length + 4 + 1))
      begin
        test_fail("Wrong length of second packet out from MAC");
        fail = fail + 1;
      end
      // checking second packet
      check_tx_packet(`MEMORY_BASE, 0, (i_length + 1), tmp);
      if (tmp > 0)
      begin
        test_fail("Wrong data of second transmitted packet");
        fail = fail + 1;
      end
      // check second transmited TX packet CRC
      check_tx_crc(0, (i_length + 1), 1'b0, tmp); // length without CRC
      if (tmp > 0)
      begin
        test_fail("Wrong CRC of second transmitted packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (wb_int !== 1'b1)
      begin
        `TIME; $display("*E WB INT signal should be set");
        test_fail("WB INT signal should be set");
        fail = fail + 1;
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(num_of_bd, data);
      if ( ((data[15:0] !== 16'h7800) && (num_of_bd == 1)) || // wrap bit
           ((data[15:0] !== 16'h5800) && (num_of_bd < 1)) )   // without wrap bit
      begin
        `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
        test_fail("TX buffer descriptor status is not correct");
        fail = fail + 1;
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((data & `ETH_INT_TXB) !== 1'b1)
      begin
        `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
        test_fail("Interrupt Transmit Buffer was not set");
        fail = fail + 1;
      end
      if ((data & (~`ETH_INT_TXB)) !== 0)
      begin
        `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
        test_fail("Other interrupts (except Transmit Buffer) were set");
        fail = fail + 1;
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // set length (LOOP variable)
      if ((tmp_ipgt + 3) < 130) // tmp_ipgt < 124
        i_length = i_length + 2;
      else
        i_length = (max_tmp - 4);
      // set IPGT
      if ((tmp_ipgt + 3) < 10)
        tmp_ipgt = tmp_ipgt + 1;
      else if ((tmp_ipgt + 3) < 24)
        tmp_ipgt = tmp_ipgt + 7;
      else if ((tmp_ipgt + 3) == 24)
        tmp_ipgt = 38 - 3;
      else if ((tmp_ipgt + 3) == 38)
        tmp_ipgt = 72 - 3;
      else if ((tmp_ipgt + 3) == 72)
        tmp_ipgt = 130 - 3; // 124 - 3
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      num_of_bd = 0;
      @(posedge wb_clk);
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets after TX under-run on each packet's ////
  ////  byte at 2 TX buffer decriptors ( 10Mbps ).                ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 20) //
  begin
    // TEST 20: TRANSMIT PACKETS AFTER TX UNDER-RUN ON EACH PACKET's BYTE AT 2 TX BDs ( 10Mbps )
    test_name = "TEST 20: TRANSMIT PACKETS AFTER TX UNDER-RUN ON EACH PACKET's BYTE AT 2 TX BDs ( 10Mbps )";
    `TIME; 
    $display("  TEST 20: TRANSMIT PACKETS AFTER TX UNDER-RUN ON EACH PACKET's BYTE AT 2 TX BDs ( 10Mbps )");
  
    // reset MAC registers
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    // set 2 TX buffer descriptors - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h2, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, NO padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN |/* `ETH_MODER_PAD |*/ `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare a packet of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h99;
    set_tx_packet(`MEMORY_BASE, (max_tmp - 4), st_data); // length without CRC
    // read IPG value
    wait (wbm_working == 0);
    wbm_read(`ETH_IPGT, tmp_ipgt, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;
  
    num_of_frames = 60; // (0..3) => start under-run on first word
    num_of_bd = 0;
    i_data = 3; // (3) => one BYTE read in first word - FIRST byte
    i_length = 80;
    while (i_length < (max_tmp - 4))
    begin
      // Reset_tx_bd enable interrupt generation
      // unmask interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                               `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // not detect carrier sense in FD and no collision
      eth_phy.carrier_sense_tx_fd_detect(0);
      eth_phy.collision(0);
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      // prepare BDs
      if (num_of_bd == 0)
      begin
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + i_data[1:0]));
        set_tx_bd(1, 1, i_length, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd_wrap(1);
        // set wb slave response: ACK (response), wbs_waits[2:0] (waits before response), 
        //                       wbs_retries[7:0] (RTYs before ACK if RTY response selected)
        #1 wb_slave.cycle_response(`ACK_RESPONSE, 3'h0, 8'h0);
        set_tx_bd_ready(1, 1);
        set_tx_bd_ready(0, 0);
      end
      // frame under-run checking
      frame_started = 0;
      frame_ended = 0;
      wait_for_frame = 0;
      no_underrun = 0;
      fork
        begin
          // for every 4 frames bytes 1, 2, 3 and 4 respectively are read in first word => 1 ACK
          // in other words 4 bytes are read, since length is MINFL => num_of_frames[31:2] ACKs
          i = 0;
          while (i <= (num_of_frames[31:2] + 1))
          begin
            @(negedge wb_clk);
            if (eth_ma_wb_ack_i)
            begin
              i = i + 1;
            end
          end
          // set wb slave response: ACK (response), wbs_waits[2:0] (waits before response), 
          //                       wbs_retries[7:0] (RTYs before ACK if RTY response selected)
          #1 wb_slave.cycle_response(`NO_RESPONSE, 3'h0, 8'hFF);
          // wait for synchronization and some additional clocks
          wait_for_frame = 1;
          // wait for frame
          wait ((wait_for_frame == 0) || (frame_started == 1))
          if ((wait_for_frame == 0) && (frame_started == 0)) // frame didn't start
          begin
            disable check_fr;
          end
          else if ((wait_for_frame == 1) && (frame_started == 1)) // frame started
          begin
            disable wait_fr;
            if (frame_ended == 1)
            begin
              $display("    ->no under-run on %0d. byte, since length of frame (without CRC) is only %0d bytes", 
                        ({num_of_frames[31:2], 2'h0} + (4 - i_data[1:0])), i_length); 
              no_underrun = 1;
            end
            else
            begin
              wait (frame_ended == 1);
              $display("    ->under-run on %0d. byte", 
                        ({num_of_frames[31:2], 2'h0} + (4 - i_data[1:0]))); 
              no_underrun = 0;
            end
          end
          repeat (2) @(posedge wb_clk);
          // set wb slave response: ACK (response), wbs_waits[2:0] (waits before response), 
          //                       wbs_retries[7:0] (RTYs before ACK if RTY response selected)
          wb_slave.cycle_response(`ACK_RESPONSE, 3'h0, 8'h0);
        end
        begin: wait_fr
          wait (wait_for_frame == 1)
          begin
            // wait for synchronization and some additional clocks
            repeat (3) @(posedge wb_clk);
            repeat (2 * tmp_ipgt) @(posedge mtx_clk);
            repeat (2) @(posedge wb_clk);
            repeat (2) @(posedge mtx_clk);
            wait_for_frame = 0;
          end
        end
        begin: check_fr
          // wait for frame to start
          @(posedge MTxEn);
          frame_started = 1;
          // wait for frame to end due to under-run
          @(negedge MTxEn);
          frame_ended = 1;
        end
      join

      repeat (5) @ (posedge mtx_clk);

      // wait for first transmit to end, if under-run didn't happen
      if (frame_ended == 0)
      begin
        // WAIT FOR FIRST TRANSMIT
        check_tx_bd(num_of_bd, data);
        wait (MTxEn === 1'b1); // start first transmit
        if (data[15] !== 1)
        begin
          `TIME; $display("*E Wrong buffer descriptor's ready bit read out from MAC");
          test_fail("Wrong buffer descriptor's ready bit read out from MAC");
          fail = fail + 1;
        end
        wait (MTxEn === 1'b0); // end first transmit
        while (data[15] === 1)
        begin
          check_tx_bd(num_of_bd, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
        // CHECK FIRST FRAME
        // check length of a first PACKET
        tmp_len = eth_phy.tx_len;

        #1;
        if (tmp_len != (i_length + 4))
        begin
          `TIME; $display("*E Wrong length of first packet out from MAC");
          test_fail("Wrong length of first packet out from MAC");
          fail = fail + 1;
        end
        // checking first packet
        check_tx_packet((`MEMORY_BASE + i_data[1:0]), 0, (i_length), tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of first transmitted packet");
          test_fail("Wrong data of first transmitted packet");
          fail = fail + 1;
        end
        // check first transmited TX packet CRC
        check_tx_crc(0, (i_length), 1'b0, tmp); // length without CRC
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong CRC of first transmitted packet");
          test_fail("Wrong CRC of first transmitted packet");
          fail = fail + 1;
        end
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        // check TX buffer descriptor of a packet
        check_tx_bd(num_of_bd, data);
        if ( ((data[15:0] !== 16'h7800) && (num_of_bd == 1)) || // wrap bit
             ((data[15:0] !== 16'h5800) && (num_of_bd < 1)) )   // without wrap bit
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_TXB) !== 1'b1)
        begin
          `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Transmit Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_TXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Transmit Buffer) were set");
          fail = fail + 1;
        end
        // clear interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      else // if (frame_ended == 1)
      begin
        // CHECK FIRST FRAME
        // check length of a first PACKET

        if (no_underrun)
        begin
          // CHECK FIRST FRAME, without under-run !!!
          // check length of a first PACKET
          tmp_len = eth_phy.tx_len;
          #1;
          if (tmp_len != (i_length + 4))
          begin
            `TIME; $display("*E Wrong length of first packet out from MAC (no under-run)");
            test_fail("Wrong length of first packet out from MAC (no under-run)");
            fail = fail + 1;
          end
        end
        else
        begin
          // CHECK FIRST FRAME, on which under-run occure !!!
          // check length of a first PACKET
          tmp_len = eth_phy.tx_len_err;
          #1;
          if (tmp_len != ({num_of_frames[31:2], 2'h0} + (4 - i_data[1:0])))
          begin
            `TIME; $display("*E Wrong length of first packet out from MAC");
            test_fail("Wrong length of first packet out from MAC");
            fail = fail + 1;
          end
        end
        // checking first packet
        if (no_underrun)
          check_tx_packet((`MEMORY_BASE + i_data[1:0]), 0, (i_length), tmp);    // only received are checked
        else
          check_tx_packet((`MEMORY_BASE + i_data[1:0]), 0, (num_of_frames), tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of first transmitted packet");
          test_fail("Wrong data of first transmitted packet");
          fail = fail + 1;
        end
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        
        // check TX buffer descriptor of a packet
        check_tx_bd(num_of_bd, data);
        if (no_underrun)
        begin
          if ( ((data[15:0] !== 16'h7800) && (num_of_bd == 1)) || // under-run, wrap bit
               ((data[15:0] !== 16'h5800) && (num_of_bd < 1)) )   // under-run, without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end
        end
        else
          if ( ((data[15:0] !== 16'h7900) && (num_of_bd == 1)) || // under-run, wrap bit
               ((data[15:0] !== 16'h5900) && (num_of_bd < 1)) )   // under-run, without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end

        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);

        if (no_underrun)
        begin
          if ((data & `ETH_INT_TXB) !== 2'b01)
          begin
            `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
            test_fail("Interrupt Transmit Buffer was not set");
            fail = fail + 1;
          end
          if ((data & (~`ETH_INT_TXB)) !== 0)
          begin
            `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
            test_fail("Other interrupts (except Transmit Buffer) were set");
            fail = fail + 1;
          end
        end
        else
        begin
          if ((data & `ETH_INT_TXE) !== 2'b10)
          begin
            `TIME; $display("*E Interrupt Transmit Error was not set, interrupt reg: %0h", data);
            test_fail("Interrupt Transmit Error was not set");
            fail = fail + 1;
          end
          if ((data & (~`ETH_INT_TXE)) !== 0)
          begin
            `TIME; $display("*E Other interrupts (except Transmit Error) were set, interrupt reg: %0h", data);
            test_fail("Other interrupts (except Transmit Buffer) were set");
            fail = fail + 1;
          end
        end

        // clear interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      num_of_bd = num_of_bd + 1;
      // destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      // WAIT FOR SECOND TRANSMIT
      check_tx_bd(num_of_bd, data);
      wait (MTxEn === 1'b1); // start first transmit
      if (data[15] !== 1)
      begin
        test_fail("Wrong buffer descriptor's ready bit read out from MAC");
        fail = fail + 1;
      end
      wait (MTxEn === 1'b0); // end first transmit
      while (data[15] === 1)
      begin
        check_tx_bd(num_of_bd, data);
        @(posedge wb_clk);
      end
      repeat (1) @(posedge wb_clk);
      // CHECK SECOND FRAME
      // check length of a second PACKET
      tmp_len = eth_phy.tx_len;
      #1;
      if (tmp_len != (i_length + 4))
      begin
        `TIME; $display("*E Wrong length of second packet out from MAC");
        test_fail("Wrong length of second packet out from MAC");
        fail = fail + 1;
      end
      // checking second packet
      check_tx_packet(`MEMORY_BASE, 0, (i_length), tmp);
      if (tmp > 0)
      begin
        `TIME; $display("*E Wrong data of second transmitted packet");
        test_fail("Wrong data of second transmitted packet");
        fail = fail + 1;
      end
      // check second transmited TX packet CRC
      check_tx_crc(0, (i_length), 1'b0, tmp); // length without CRC
      if (tmp > 0)
      begin
        `TIME; $display("*E Wrong CRC of second transmitted packet");
        test_fail("Wrong CRC of second transmitted packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (wb_int !== 1'b1)
      begin
        `TIME; $display("*E WB INT signal should be set");
        test_fail("WB INT signal should be set");
        fail = fail + 1;
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(num_of_bd, data);
      if ( ((data[15:0] !== 16'h7800) && (num_of_bd == 1)) || // wrap bit
           ((data[15:0] !== 16'h5800) && (num_of_bd < 1)) )   // without wrap bit
      begin
        `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
        test_fail("TX buffer descriptor status is not correct");
        fail = fail + 1;
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((data & `ETH_INT_TXB) !== 1'b1)
      begin
        `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
        test_fail("Interrupt Transmit Buffer was not set");
        fail = fail + 1;
      end
      if ((data & (~`ETH_INT_TXB)) !== 0)
      begin
        `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
        test_fail("Other interrupts (except Transmit Buffer) were set");
        fail = fail + 1;
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // set initial value
      i_data = i_data - 1;
      // the number of frames transmitted
      num_of_frames = num_of_frames + 1;
      num_of_bd = 0;
      // set length (LOOP variable)
      if (num_of_frames == i_length + 4) // 64 => this was last Byte (1st .. 64th) when i_length = min_tmp - 4
        i_length = (max_tmp - 4);
      @(posedge wb_clk);
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets after TX under-run on each packet's ////
  ////  byte at 2 TX buffer decriptors ( 100Mbps ).               ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 21) //
  begin
    // TEST 21: TRANSMIT PACKETS AFTER TX UNDER-RUN ON EACH PACKET's BYTE AT 2 TX BDs ( 100Mbps )
    test_name = "TEST 21: TRANSMIT PACKETS AFTER TX UNDER-RUN ON EACH PACKET's BYTE AT 2 TX BDs ( 100Mbps )";
    `TIME; 
    $display("  TEST 21: TRANSMIT PACKETS AFTER TX UNDER-RUN ON EACH PACKET's BYTE AT 2 TX BDs ( 100Mbps )");
  
    // reset MAC registers
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    // set 2 TX buffer descriptors - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h2, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, NO padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN |/* `ETH_MODER_PAD |*/ `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare a packet of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h99;
    set_tx_packet(`MEMORY_BASE, (max_tmp - 4), st_data); // length without CRC
    // read IPG value
    wait (wbm_working == 0);
    wbm_read(`ETH_IPGT, tmp_ipgt, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 100;
  
    num_of_frames = 60; // (0..3) => start under-run on first word
    num_of_bd = 0;
    i_data = 3; // (3) => one BYTE read in first word - FIRST byte
    i_length = 80;
    while (i_length < (max_tmp - 4))
    begin
      // Reset_tx_bd enable interrupt generation
      // unmask interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                               `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // not detect carrier sense in FD and no collision
      eth_phy.carrier_sense_tx_fd_detect(0);
      eth_phy.collision(0);
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      // prepare BDs
      if (num_of_bd == 0)
      begin
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + i_data[1:0]));
        set_tx_bd(1, 1, i_length, 1'b1, 1'b1, 1'b1, `MEMORY_BASE);
        set_tx_bd_wrap(1);
        // set wb slave response: ACK (response), wbs_waits[2:0] (waits before response), 
        //                       wbs_retries[7:0] (RTYs before ACK if RTY response selected)
        #1 wb_slave.cycle_response(`ACK_RESPONSE, 3'h0, 8'h0);
        set_tx_bd_ready(1, 1);
        set_tx_bd_ready(0, 0);
      end
      // frame under-run checking
      frame_started = 0;
      frame_ended = 0;
      wait_for_frame = 0;
      no_underrun = 0;
      fork
        begin
          // for every 4 frames bytes 1, 2, 3 and 4 respectively are read in first word => 1 ACK
          // in other words 4 bytes are read, since length is MINFL => num_of_frames[31:2] ACKs
          i = 0;
          while (i <= (num_of_frames[31:2] + 1))
          begin
            @(negedge wb_clk);
            if (eth_ma_wb_ack_i)
            begin
              i = i + 1;
            end
          end
          // set wb slave response: ACK (response), wbs_waits[2:0] (waits before response), 
          //                       wbs_retries[7:0] (RTYs before ACK if RTY response selected)
          #1 wb_slave.cycle_response(`NO_RESPONSE, 3'h0, 8'hFF);
          // wait for synchronization and some additional clocks
          wait_for_frame = 1;
          // wait for frame
          wait ((wait_for_frame == 0) || (frame_started == 1))
          if ((wait_for_frame == 0) && (frame_started == 0)) // frame didn't start
          begin
            disable check_fr1;
          end
          else if ((wait_for_frame == 1) && (frame_started == 1)) // frame started
          begin
            disable wait_fr1;
            if (frame_ended == 1)
            begin
              $display("    ->no under-run on %0d. byte, since length of frame (without CRC) is only %0d bytes", 
                        ({num_of_frames[31:2], 2'h0} + (4 - i_data[1:0])), i_length); 
              no_underrun = 1;
            end
            else
            begin
              wait (frame_ended == 1);
              $display("    ->under-run on %0d. byte", 
                        ({num_of_frames[31:2], 2'h0} + (4 - i_data[1:0]))); 
              no_underrun = 0;
            end
          end
          repeat (2) @(posedge wb_clk);
          // set wb slave response: ACK (response), wbs_waits[2:0] (waits before response), 
          //                       wbs_retries[7:0] (RTYs before ACK if RTY response selected)
          wb_slave.cycle_response(`ACK_RESPONSE, 3'h0, 8'h0);
        end
        begin: wait_fr1
          wait (wait_for_frame == 1)
          begin
            // wait for synchronization and some additional clocks
            repeat (3) @(posedge wb_clk);
            repeat (2 * tmp_ipgt) @(posedge mtx_clk);
            repeat (2) @(posedge wb_clk);
            repeat (2) @(posedge mtx_clk);
            wait_for_frame = 0;
          end
        end
        begin: check_fr1
          // wait for frame to start
          @(posedge MTxEn);
          frame_started = 1;
          // wait for frame to end due to under-run
          @(negedge MTxEn);
          frame_ended = 1;
        end
      join

      repeat (5) @ (posedge mtx_clk);

      // wait for first transmit to end, if under-run didn't happen
      if (frame_ended == 0)
      begin
        // WAIT FOR FIRST TRANSMIT
        check_tx_bd(num_of_bd, data);
        wait (MTxEn === 1'b1); // start first transmit
        if (data[15] !== 1)
        begin
          `TIME; $display("*E Wrong buffer descriptor's ready bit read out from MAC");
          test_fail("Wrong buffer descriptor's ready bit read out from MAC");
          fail = fail + 1;
        end
        wait (MTxEn === 1'b0); // end first transmit
        while (data[15] === 1)
        begin
          check_tx_bd(num_of_bd, data);
          @(posedge wb_clk);
        end
        repeat (10) @(posedge wb_clk);
        // CHECK FIRST FRAME
        // check length of a first PACKET
        tmp_len = eth_phy.tx_len;

        #1;
        if (tmp_len != (i_length + 4))
        begin
          `TIME; $display("*E Wrong length of first packet out from MAC");
          test_fail("Wrong length of first packet out from MAC");
          fail = fail + 1;
        end
        // checking first packet
        check_tx_packet((`MEMORY_BASE + i_data[1:0]), 0, (i_length), tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of first transmitted packet");
          test_fail("Wrong data of first transmitted packet");
          fail = fail + 1;
        end
        // check first transmited TX packet CRC
        check_tx_crc(0, (i_length), 1'b0, tmp); // length without CRC
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong CRC of first transmitted packet");
          test_fail("Wrong CRC of first transmitted packet");
          fail = fail + 1;
        end
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        // check TX buffer descriptor of a packet
        check_tx_bd(num_of_bd, data);
        if ( ((data[15:0] !== 16'h7800) && (num_of_bd == 1)) || // wrap bit
             ((data[15:0] !== 16'h5800) && (num_of_bd < 1)) )   // without wrap bit
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_TXB) !== 1'b1)
        begin
          `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Transmit Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_TXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Transmit Buffer) were set");
          fail = fail + 1;
        end
        // clear interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      else // if (frame_ended == 1)
      begin
        // CHECK FIRST FRAME
        // check length of a first PACKET

        if (no_underrun)
        begin
          // CHECK FIRST FRAME, without under-run !!!
          // check length of a first PACKET
          tmp_len = eth_phy.tx_len;
          #1;
          if (tmp_len != (i_length + 4))
          begin
            `TIME; $display("*E Wrong length of first packet out from MAC (no under-run)");
            test_fail("Wrong length of first packet out from MAC (no under-run)");
            fail = fail + 1;
          end
        end
        else
        begin
          // CHECK FIRST FRAME, on which under-run occure !!!
          // check length of a first PACKET
          tmp_len = eth_phy.tx_len_err-1;   // -1 because synchronization at 100 Mbps is slover then at 10 Mbps (wb_clk remains the same)
          #1;
          if (tmp_len != ({num_of_frames[31:2], 2'h0} + (4 - i_data[1:0])))
          begin
            `TIME; $display("*E Wrong length of first packet out from MAC");
            test_fail("Wrong length of first packet out from MAC");
            fail = fail + 1;
          end
        end
        // checking first packet
        if (no_underrun)
          check_tx_packet((`MEMORY_BASE + i_data[1:0]), 0, (i_length), tmp);    // only received are checked
        else
          check_tx_packet((`MEMORY_BASE + i_data[1:0]), 0, (num_of_frames), tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of first transmitted packet");
          test_fail("Wrong data of first transmitted packet");
          fail = fail + 1;
        end
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        
        // check TX buffer descriptor of a packet
        check_tx_bd(num_of_bd, data);
        if (no_underrun)
        begin
          if ( ((data[15:0] !== 16'h7800) && (num_of_bd == 1)) || // under-run, wrap bit
               ((data[15:0] !== 16'h5800) && (num_of_bd < 1)) )   // under-run, without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end
        end
        else
          if ( ((data[15:0] !== 16'h7900) && (num_of_bd == 1)) || // under-run, wrap bit
               ((data[15:0] !== 16'h5900) && (num_of_bd < 1)) )   // under-run, without wrap bit
          begin
            `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
            test_fail("TX buffer descriptor status is not correct");
            fail = fail + 1;
          end

        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);

        if (no_underrun)
        begin
          if ((data & `ETH_INT_TXB) !== 2'b01)
          begin
            `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
            test_fail("Interrupt Transmit Buffer was not set");
            fail = fail + 1;
          end
          if ((data & (~`ETH_INT_TXB)) !== 0)
          begin
            `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
            test_fail("Other interrupts (except Transmit Buffer) were set");
            fail = fail + 1;
          end
        end
        else
        begin
          if ((data & `ETH_INT_TXE) !== 2'b10)
          begin
            `TIME; $display("*E Interrupt Transmit Error was not set, interrupt reg: %0h", data);
            test_fail("Interrupt Transmit Error was not set");
            fail = fail + 1;
          end
          if ((data & (~`ETH_INT_TXE)) !== 0)
          begin
            `TIME; $display("*E Other interrupts (except Transmit Error) were set, interrupt reg: %0h", data);
            test_fail("Other interrupts (except Transmit Buffer) were set");
            fail = fail + 1;
          end
        end

        // clear interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      num_of_bd = num_of_bd + 1;
      // destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      // WAIT FOR SECOND TRANSMIT
      check_tx_bd(num_of_bd, data);
      wait (MTxEn === 1'b1); // start first transmit
      if (data[15] !== 1)
      begin
        test_fail("Wrong buffer descriptor's ready bit read out from MAC");
        fail = fail + 1;
      end
      wait (MTxEn === 1'b0); // end first transmit
      while (data[15] === 1)
      begin
        check_tx_bd(num_of_bd, data);
        @(posedge wb_clk);
      end
      repeat (1) @(posedge wb_clk);
      // CHECK SECOND FRAME
      // check length of a second PACKET
      tmp_len = eth_phy.tx_len;
      #1;
      if (tmp_len != (i_length + 4))
      begin
        `TIME; $display("*E Wrong length of second packet out from MAC");
        test_fail("Wrong length of second packet out from MAC");
        fail = fail + 1;
      end
      // checking second packet
      check_tx_packet(`MEMORY_BASE, 0, (i_length), tmp);
      if (tmp > 0)
      begin
        `TIME; $display("*E Wrong data of second transmitted packet");
        test_fail("Wrong data of second transmitted packet");
        fail = fail + 1;
      end
      // check second transmited TX packet CRC
      check_tx_crc(0, (i_length), 1'b0, tmp); // length without CRC
      if (tmp > 0)
      begin
        `TIME; $display("*E Wrong CRC of second transmitted packet");
        test_fail("Wrong CRC of second transmitted packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (wb_int !== 1'b1)
      begin
        `TIME; $display("*E WB INT signal should be set");
        test_fail("WB INT signal should be set");
        fail = fail + 1;
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(num_of_bd, data);
      if ( ((data[15:0] !== 16'h7800) && (num_of_bd == 1)) || // wrap bit
           ((data[15:0] !== 16'h5800) && (num_of_bd < 1)) )   // without wrap bit
      begin
        `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
        test_fail("TX buffer descriptor status is not correct");
        fail = fail + 1;
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((data & `ETH_INT_TXB) !== 1'b1)
      begin
        `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
        test_fail("Interrupt Transmit Buffer was not set");
        fail = fail + 1;
      end
      if ((data & (~`ETH_INT_TXB)) !== 0)
      begin
        `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
        test_fail("Other interrupts (except Transmit Buffer) were set");
        fail = fail + 1;
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // set initial value
      i_data = i_data - 1;
      // the number of frames transmitted
      num_of_frames = num_of_frames + 1;
      num_of_bd = 0;
      // set length (LOOP variable)
      if (num_of_frames == i_length + 4) // 64 => this was last Byte (1st .. 64th) when i_length = min_tmp - 4
        i_length = (max_tmp - 4);
      @(posedge wb_clk);
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets (delayed CRC) from MINFL to MAXFL   ////
  ////  sizes at one TX buffer decriptor ( 10Mbps ).              ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 22) //
  begin
    // TEST 22: TRANSMIT PACKETS (DELAYED CRC) FROM MINFL TO MAXFL SIZES AT ONE TX BD ( 10Mbps )
    test_name = "TEST 22: TRANSMIT PACKETS (DELAYED CRC) FROM MINFL TO MAXFL SIZES AT ONE TX BD ( 10Mbps )";
    `TIME; $display("  TEST 22: TRANSMIT (DELAYED CRC) PACKETS FROM MINFL TO MAXFL SIZES AT ONE TX BD ( 10Mbps )");
  
    max_tmp = 0;
    min_tmp = 0;
    // set one TX buffer descriptor - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h1, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, NO padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN | `ETH_MODER_DLYCRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h01;
    set_tx_packet(`MEMORY_BASE, (max_tmp), st_data); // length without CRC
    st_data = 8'h10;
    set_tx_packet((`MEMORY_BASE + max_tmp), (max_tmp), st_data); // length without CRC
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;
  
    i_length = (min_tmp - 4);
    while (i_length <= (max_tmp - 4))
    begin
      // choose generating carrier sense and collision for first and last 64 lengths of frames
      case (i_length[1:0])
      2'h0: // Interrupt is generated
      begin
        // enable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + i_length[1:0]));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, 
                                 wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is not generated
      begin
        // enable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b0, 1'b1, 1'b1, (`MEMORY_BASE + i_length[1:0]));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b0, 1'b1, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      eth_phy.set_tx_mem_addr(max_tmp);
      // set wrap bit
      set_tx_bd_wrap(0);
      set_tx_bd_ready(0, 0);
      #1 check_tx_bd(0, data);


      if (i_length < min_tmp) // just first four
      begin
        while (data[15] === 1)
        begin
          #1 check_tx_bd(0, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      else if (i_length > (max_tmp - 8)) // just last four
      begin
        tmp = 0;
        wait (MTxEn === 1'b1); // start transmit
        while (tmp < (i_length - 20))
        begin
          #1 tmp = tmp + 1;
          @(posedge wb_clk);
        end
        #1 check_tx_bd(0, data);
        while (data[15] === 1)
        begin
          #1 check_tx_bd(0, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      else
      begin
        wait (MTxEn === 1'b1); // start transmit
        #1 check_tx_bd(0, data);
        if (data[15] !== 1)
        begin
          test_fail("Wrong buffer descriptor's ready bit read out from MAC");
          fail = fail + 1;
        end
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
          #1 check_tx_bd(0, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end

      repeat(5) @(posedge mtx_clk);  // Wait some time so PHY stores the CRC

      // check length of a PACKET
      if (eth_phy.tx_len != (i_length + 4))
      begin
        test_fail("Wrong length of the packet out from MAC");
        fail = fail + 1;
      end
      // checking in the following if statement is performed only for first and last 64 lengths
      if ( ((i_length + 4) <= (min_tmp + 64)) || ((i_length + 4) > (max_tmp - 64)) )
      begin
        // check transmitted TX packet data
        if (i_length[0] == 0)
        begin
          check_tx_packet((`MEMORY_BASE + i_length[1:0]), max_tmp, i_length, tmp);
        end
        else
        begin
          check_tx_packet(((`MEMORY_BASE + i_length[1:0]) + max_tmp), max_tmp, i_length, tmp);
        end
        if (tmp > 0)
        begin
          test_fail("Wrong data of the transmitted packet");
          fail = fail + 1;
        end
        // check transmited TX packet CRC
        check_tx_crc_delayed(max_tmp, i_length, 1'b0, tmp); // length without CRC

        if (tmp > 0)
        begin
          test_fail("Wrong CRC of the transmitted packet");
          fail = fail + 1;
        end
      end
      // check WB INT signal
      if (i_length[1:0] == 2'h0)
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(0, data);
      if (i_length[1] == 1'b0) // interrupt enabled
      begin
        if (data[15:0] !== 16'h7800)
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else // interrupt not enabled
      begin
        if (data[15:0] !== 16'h3800)
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear TX buffer descriptor
      clear_tx_bd(0, 0);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1))
      begin
        if ((data & `ETH_INT_TXB) !== 1'b1)
        begin
          `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Transmit Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_TXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Transmit Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Transmit Buffer) was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Transmit Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if ((i_length + 4) == (min_tmp + 64))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 64)
        $display("    pads appending to packets is NOT selected");
        $display("    ->packets with lengths from %0d (MINFL) to %0d are checked (length increasing by 1 byte)",
                 min_tmp, (min_tmp + 64));
        // set padding, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN | `ETH_MODER_DLYCRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (max_tmp - 16))
      begin
        // starting length is for +128 longer than previous ending length, while ending length is tmp_data
        $display("    pads appending to packets is selected");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 128 bytes)",
                 (min_tmp + 64 + 128), tmp_data); 
        // reset padding, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN | `ETH_MODER_DLYCRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == max_tmp)
      begin
        $display("    pads appending to packets is NOT selected");
        $display("    ->packets with lengths from %0d to %0d (MAXFL) are checked (length increasing by 1 byte)",
                 (max_tmp - (4 + 16)), max_tmp);
      end
      // set length (loop variable)
      if ((i_length + 4) < (min_tmp + 64))
        i_length = i_length + 1;
      else if ( ((i_length + 4) >= (min_tmp + 64)) && ((i_length + 4) <= (max_tmp - 256)) )
      begin
        i_length = i_length + 128;
        tmp_data = i_length + 4; // last tmp_data is ending length
      end
      else if ( ((i_length + 4) > (max_tmp - 256)) && ((i_length + 4) < (max_tmp - 16)) )
        i_length = max_tmp - (4 + 16);
      else if ((i_length + 4) >= (max_tmp - 16))
        i_length = i_length + 1;
      else
      begin
        $display("*E TESTBENCH ERROR - WRONG PARAMETERS IN TESTBENCH");
        #10 $stop;
      end
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN | `ETH_MODER_DLYCRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test transmit packets (DELAYED CRC) from MINFL to MAXFL   ////
  ////  sizes at one TX buffer decriptor ( 100Mbps ).             ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 23) //
  begin
    // TEST 23: TRANSMIT PACKETS (DELAYED CRC) FROM MINFL TO MAXFL SIZES AT ONE TX BD ( 100Mbps )
    test_name = "TEST 23: TRANSMIT PACKETS (DELAYED CRC) FROM MINFL TO MAXFL SIZES AT ONE TX BD ( 100Mbps )";
    `TIME; $display("  TEST 23: TRANSMIT PACKETS (DELAYED CRC) FROM MINFL TO MAXFL SIZES AT ONE TX BD ( 100Mbps )");
  
    max_tmp = 0;
    min_tmp = 0;
    // set one TX buffer descriptor - must be set before TX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h1, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, NO padding and CRC appending
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN | `ETH_MODER_DLYCRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h5A;
    set_tx_packet(`MEMORY_BASE, (max_tmp), st_data); // length without CRC
    st_data = 8'h10;
    set_tx_packet((`MEMORY_BASE + max_tmp), (max_tmp), st_data); // length without CRC
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;

    i_length = (min_tmp - 4);
    while (i_length <= (max_tmp - 4))
    begin
      // choose generating carrier sense and collision
      case (i_length[1:0])
      2'h0: // Interrupt is generated
      begin
        // enable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + i_length[1:0]));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is not generated
      begin
        // enable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b1, 1'b1, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b0, 1'b1, 1'b1, (`MEMORY_BASE + i_length[1:0]));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_tx_bd(0, 0, i_length, 1'b0, 1'b1, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.carrier_sense_tx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      eth_phy.set_tx_mem_addr(max_tmp);
      // set wrap bit
      set_tx_bd_wrap(0);
      set_tx_bd_ready(0, 0);
      #1 check_tx_bd(0, data);
      if (i_length < min_tmp) // just first four
      begin
        while (data[15] === 1)
        begin
          #1 check_tx_bd(0, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      else if (i_length > (max_tmp - 8)) // just last four
      begin
        tmp = 0;
        wait (MTxEn === 1'b1); // start transmit
        while (tmp < (i_length - 20))
        begin
          #1 tmp = tmp + 1;
          @(posedge wb_clk);
        end
        #1 check_tx_bd(0, data);
        while (data[15] === 1)
        begin
          #1 check_tx_bd(0, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      else
      begin
        wait (MTxEn === 1'b1); // start transmit
        #1 check_tx_bd(0, data);
        if (data[15] !== 1)
        begin
          test_fail("Wrong buffer descriptor's ready bit read out from MAC");
          fail = fail + 1;
        end
        wait (MTxEn === 1'b0); // end transmit
        while (data[15] === 1)
        begin
          #1 check_tx_bd(0, data);
          @(posedge wb_clk);
        end
        repeat (1) @(posedge wb_clk);
      end
      // check length of a PACKET
      if (eth_phy.tx_len != (i_length + 4))
      begin
        test_fail("Wrong length of the packet out from MAC");
        fail = fail + 1;
      end
      // check transmitted TX packet data
      if (i_length[0] == 0)
      begin
        check_tx_packet((`MEMORY_BASE + i_length[1:0]), max_tmp, i_length, tmp);
      end
      else
      begin
        check_tx_packet(((`MEMORY_BASE + i_length[1:0]) + max_tmp), max_tmp, i_length, tmp);
      end
      if (tmp > 0)
      begin
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end
      // check transmited TX packet CRC
      check_tx_crc_delayed(max_tmp, i_length, 1'b0, tmp); // length without CRC
      if (tmp > 0)
      begin
        test_fail("Wrong CRC of the transmitted packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (i_length[1:0] == 2'h0)
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check TX buffer descriptor of a packet
      check_tx_bd(0, data);
      if (i_length[1] == 1'b0) // interrupt enabled
      begin
        if (data[15:0] !== 16'h7800)
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else // interrupt not enabled
      begin
        if (data[15:0] !== 16'h3800)
        begin
          `TIME; $display("*E TX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear TX buffer descriptor
      clear_tx_bd(0, 0);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1))
      begin
        if ((data & `ETH_INT_TXB) !== 1'b1)
        begin
          `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Transmit Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_TXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Transmit Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Transmit Buffer) was set, interrupt reg: %0h", data);
          test_fail("Any of interrupts (except Transmit Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if ((i_length + 4) == (min_tmp + 64))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 64)
        $display("    pads appending to packets is NOT selected");
        $display("    ->packets with lengths from %0d (MINFL) to %0d are checked (length increasing by 1 byte)",
                 min_tmp, (min_tmp + 64));
        // set padding, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN | `ETH_MODER_DLYCRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (max_tmp - 16))
      begin
        // starting length is for +128 longer than previous ending length, while ending length is tmp_data
        $display("    pads appending to packets is selected");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 128 bytes)",
                 (min_tmp + 64 + 128), tmp_data); 
        // reset padding, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_CRCEN | `ETH_MODER_DLYCRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == max_tmp)
      begin
        $display("    pads appending to packets is NOT selected");
        $display("    ->packets with lengths from %0d to %0d (MAXFL) are checked (length increasing by 1 byte)",
                 (max_tmp - (4 + 16)), max_tmp);
      end
      // set length (loop variable)
      if ((i_length + 4) < (min_tmp + 64))
        i_length = i_length + 1;
      else if ( ((i_length + 4) >= (min_tmp + 64)) && ((i_length + 4) <= (max_tmp - 256)) )
      begin
        i_length = i_length + 128;
        tmp_data = i_length + 4; // last tmp_data is ending length
      end
      else if ( ((i_length + 4) > (max_tmp - 256)) && ((i_length + 4) < (max_tmp - 16)) )
        i_length = max_tmp - (4 + 16);
      else if ((i_length + 4) >= (max_tmp - 16))
        i_length = i_length + 1;
      else
      begin
        $display("*E TESTBENCH ERROR - WRONG PARAMETERS IN TESTBENCH");
        #10 $stop;
      end
    end
    // disable TX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN | `ETH_MODER_DLYCRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end



end   //  for (test_num=start_task; test_num <= end_task; test_num=test_num+1)

end
endtask // test_mac_full_duplex_transmit


task test_mac_full_duplex_receive;
  input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        bit_start_1;
  integer        bit_end_1;
  integer        bit_start_2;
  integer        bit_end_2;
  integer        num_of_reg;
  integer        num_of_frames;
  integer        num_of_bd;
  integer        i_addr;
  integer        i_data;
  integer        i_length;
  integer        tmp_len;
  integer        tmp_bd;
  integer        tmp_bd_num;
  integer        tmp_data;
  integer        tmp_ipgt;
  integer        test_num;
  reg    [31:0]  tx_bd_num;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_data;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_tmp_data;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        fail;
  integer        speed;
  reg            frame_started;
  reg            frame_ended;
  reg            wait_for_frame;
  reg            check_frame;
  reg            stop_checking_frame;
  reg            first_fr_received;
  reg    [31:0]  addr;
  reg    [31:0]  data;
  reg    [31:0]  tmp;
  reg    [ 7:0]  st_data;
  reg    [15:0]  max_tmp;
  reg    [15:0]  min_tmp;
begin
// MAC FULL DUPLEX RECEIVE TEST
test_heading("MAC FULL DUPLEX RECEIVE TEST");
$display(" ");
$display("MAC FULL DUPLEX RECEIVE TEST");
fail = 0;

// reset MAC registers
hard_reset;
// set wb slave response
wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

  /*
  TASKS for set and control TX buffer descriptors (also send packet - set_tx_bd_ready):
  -------------------------------------------------------------------------------------
  set_tx_bd 
    (tx_bd_num_start[6:0], tx_bd_num_end[6:0], len[15:0], irq, pad, crc, txpnt[31:0]);
  set_tx_bd_wrap 
    (tx_bd_num_end[6:0]);
  set_tx_bd_ready 
    (tx_bd_num_start[6:0], tx_bd_num_end[6:0]);
  check_tx_bd 
    (tx_bd_num_start[6:0], tx_bd_status[31:0]);
  clear_tx_bd 
    (tx_bd_num_start[6:0], tx_bd_num_end[6:0]);

  TASKS for set and control RX buffer descriptors:
  ------------------------------------------------
  set_rx_bd 
    (rx_bd_num_strat[6:0], rx_bd_num_end[6:0], irq, rxpnt[31:0]);
  set_rx_bd_wrap 
    (rx_bd_num_end[6:0]);
  set_rx_bd_empty 
    (rx_bd_num_strat[6:0], rx_bd_num_end[6:0]);
  check_rx_bd 
    (rx_bd_num_end[6:0], rx_bd_status);
  clear_rx_bd 
    (rx_bd_num_strat[6:0], rx_bd_num_end[6:0]);

  TASKS for set and check TX packets:
  -----------------------------------
  set_tx_packet 
    (txpnt[31:0], len[15:0], eth_start_data[7:0]);
  check_tx_packet 
    (txpnt_wb[31:0], txpnt_phy[31:0], len[15:0], failure[31:0]);

  TASKS for set and check RX packets:
  -----------------------------------
  set_rx_packet 
    (rxpnt[31:0], len[15:0], plus_nibble, d_addr[47:0], s_addr[47:0], type_len[15:0], start_data[7:0]);
  check_rx_packet 
    (rxpnt_phy[31:0], rxpnt_wb[31:0], len[15:0], plus_nibble, successful_nibble, failure[31:0]);

  TASKS for append and check CRC to/of TX packet:
  -----------------------------------------------
  append_tx_crc 
    (txpnt_wb[31:0], len[15:0], negated_crc);
  check_tx_crc 
    (txpnt_phy[31:0], len[15:0], negated_crc, failure[31:0]); 

  TASK for append CRC to RX packet (CRC is checked together with check_rx_packet):
  --------------------------------------------------------------------------------
  append_rx_crc 
    (rxpnt_phy[31:0], len[15:0], plus_nibble, negated_crc);
  */

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  test_mac_full_duplex_receive:                               ////
////                                                              ////
////  0: Test no receive when all buffers are TX ( 10Mbps ).      ////
////  1: Test no receive when all buffers are TX ( 100Mbps ).     ////
////  2: Test receive packet synchronization with receive         ////
////     disable/enable ( 10Mbps ).                               ////
////  3: Test receive packet synchronization with receive         ////
////     disable/enable ( 100Mbps ).                              ////
////  4: Test receive packets from MINFL to MAXFL sizes at        ////
////     one RX buffer decriptor ( 10Mbps ).                      ////
////  5: Test receive packets from MINFL to MAXFL sizes at        ////
////     one RX buffer decriptor ( 100Mbps ).                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin

  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test no receive when all buffers are TX ( 10Mbps ).       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 0) //
  begin
    // TEST 0: NO RECEIVE WHEN ALL BUFFERS ARE TX ( 10Mbps )
    test_name   = "TEST 0: NO RECEIVE WHEN ALL BUFFERS ARE TX ( 10Mbps )";
    `TIME; $display("  TEST 0: NO RECEIVE WHEN ALL BUFFERS ARE TX ( 10Mbps )");

    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set all buffer descriptors to TX - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h80, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;
  
    i = 0;
    while (i < 128)
    begin
      for (i1 = 0; i1 <= i; i1 = i1 + 1)
      begin
        set_rx_packet((i1 * 50), 10, 1'b0, 48'h1234_5678_8765, 48'h0011_2233_4455, 16'h0101, 8'h0);
        append_rx_crc((i1 * 50), 10, 1'b0, 1'b0);
        set_rx_bd(i1, i1, 1'b1, (`MEMORY_BASE + (i1 * 50)));
      end
      set_rx_bd_wrap(i);
      set_rx_bd_empty(0, i);
      for (i1 = 0; i1 <= i; i1 = i1 + 1)
      begin
        #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, (i1 * 50), 14, 1'b0);
        repeat(10) @(posedge mrx_clk);
      end
      @(posedge mrx_clk);
      for (i2 = 0; i2 < 20; i2 = i2 + 1)
      begin
        check_rx_bd(0, tmp);
        #1;
        if (tmp[15] === 1'b0)
        begin
          test_fail("Receive should not start at all");
          fail = fail + 1;
          `TIME; $display("*E Receive of %d packets should not start at all - empty is 0", i);
        end
        if (tmp[7:0] !== 0)
        begin
          test_fail("Receive should not be finished since it should not start at all");
          fail = fail + 1;
          `TIME; $display("*E Receive of should not be finished since it should not start at all");
        end
        @(posedge wb_clk);
      end
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (tmp[6:0] !== 0)
      begin
        test_fail("Receive should not get INT since it should not start at all");
        fail = fail + 1;
        `TIME; $display("*E Receive of should not get INT since it should not start at all");
      end
      clear_rx_bd(0, i);
      if ((i < 5) || (i > 124))
        i = i + 1;
      else
        i = i + 120;
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test no receive when all buffers are TX ( 100Mbps ).      ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 1) //
  begin
    // TEST 1: NO RECEIVE WHEN ALL BUFFERS ARE TX ( 100Mbps )
    test_name   = "TEST 1: NO RECEIVE WHEN ALL BUFFERS ARE TX ( 100Mbps )";
    `TIME; $display("  TEST 1: NO RECEIVE WHEN ALL BUFFERS ARE TX ( 100Mbps )");

    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set all buffer descriptors to TX - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h80, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;
  
    i = 0;
    while (i < 128)
    begin
      for (i1 = 0; i1 <= i; i1 = i1 + 1)
      begin
        set_rx_packet((i1 * 50), 10, 1'b0, 48'h1234_5678_8765, 48'h0011_2233_4455, 16'h0101, 8'h0);
        append_rx_crc((i1 * 50), 10, 1'b0, 1'b0);
        set_rx_bd(i1, i1, 1'b1, (`MEMORY_BASE + (i1 * 50)));
      end
      set_rx_bd_wrap(i);
      set_rx_bd_empty(0, i);
      for (i1 = 0; i1 <= i; i1 = i1 + 1)
      begin
        #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, (i1 * 50), 14, 1'b0);
        repeat(10) @(posedge mrx_clk);
      end
      @(posedge mrx_clk);
      for (i2 = 0; i2 < 20; i2 = i2 + 1)
      begin
        check_rx_bd(0, tmp);
        #1;
        if (tmp[15] === 1'b0)
        begin
          test_fail("Receive should not start at all");
          fail = fail + 1;
          `TIME; $display("*E Receive of %d packets should not start at all - empty is 0", i);
        end
        if (tmp[7:0] !== 0)
        begin
          test_fail("Receive should not be finished since it should not start at all");
          fail = fail + 1;
          `TIME; $display("*E Receive of should not be finished since it should not start at all");
        end
        @(posedge wb_clk);
      end
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (tmp[6:0] !== 0)
      begin
        test_fail("Receive should not get INT since it should not start at all");
        fail = fail + 1;
        `TIME; $display("*E Receive of should not get INT since it should not start at all");
      end
      clear_rx_bd(0, i);
      if ((i < 5) || (i > 124))
        i = i + 1;
      else
        i = i + 120;
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test receive packet synchronization with receive          ////
  ////  disable/enable ( 10Mbps ).                                ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 2) //
  begin
    // TEST 2: RECEIVE PACKET SYNCHRONIZATION WITH RECEIVE DISABLE/ENABLE ( 10Mbps )
    test_name   = "TEST 2: RECEIVE PACKET SYNCHRONIZATION WITH RECEIVE DISABLE/ENABLE ( 10Mbps )";
    `TIME; $display("  TEST 2: RECEIVE PACKET SYNCHRONIZATION WITH RECEIVE DISABLE/ENABLE ( 10Mbps )");

    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set 10 RX buffer descriptor (8'h80 - 8'hA) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h76, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // disable RX, set full-duplex mode, NO receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h0F;
    set_rx_packet(0, (min_tmp + 1), 1'b0, 48'h0102_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
    append_rx_crc(0, (min_tmp + 1), 1'b0, 1'b0);
    st_data = 8'h1A;
    set_rx_packet(max_tmp, (min_tmp + 1), 1'b0, 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E, st_data); 
    append_rx_crc(max_tmp, (min_tmp + 1), 1'b0, 1'b0);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;

    frame_started = 0;
    frame_ended = 0;
    wait_for_frame = 0;
    check_frame = 0;
    stop_checking_frame = 0;
    first_fr_received = 1; // at the beginning the first frame of each two will be received!
    
    num_of_frames = 0; // 
    num_of_bd = 0;
    i_length = (min_tmp + 1); // 5 bytes longer than MINFL
    while (i_length < (max_tmp - 4))
    begin
      // choose generating carrier sense and collision 
      case (num_of_frames[1:0])
      2'h0: // Interrupt is generated
      begin
        // enable interrupt generation
        set_rx_bd(118, 118, 1'b1, (`MEMORY_BASE + num_of_frames[1:0]));
        // not detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is generated
      begin
        // enable interrupt generation
        set_rx_bd(118, 118, 1'b1, (`MEMORY_BASE + num_of_frames[1:0]));
        // detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is generated
      begin
        // disable interrupt generation
        set_rx_bd(118, 118, 1'b1, (`MEMORY_BASE + num_of_frames[1:0]));
        // not detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is generated
      begin
        // disable interrupt generation
        set_rx_bd(118, 118, 1'b1, (`MEMORY_BASE + num_of_frames[1:0]));
        // detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      // set wrap bit
      set_rx_bd_wrap(118);
      set_rx_bd_empty(118, 118);
      check_frame = 0;
      stop_checking_frame = 0;
      tmp_data = 0;
      fork
        begin // enable RX MAC on first of each two packets - every second should be recived normaly
          if (num_of_frames[0] == 1'b0)
          begin
            repeat(1) @(posedge wb_clk);
            if (num_of_frames[1] == 1'b0)
            begin
              repeat (num_of_frames[31:2]) @(posedge mrx_clk); // for every (second) frame enable receiver one clock later
            end
            else
            begin
              @(posedge mrx_clk);
              repeat (num_of_frames[31:2]) @(negedge mrx_clk); // for every (second) frame enable receiver one clock later
            end
            // enable RX, set full-duplex mode, NO receive small, NO correct IFG
            wbm_init_waits = 4'h0;
            wbm_subseq_waits = 4'h0;
            #1 wait (wbm_working == 0);
            wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                      `ETH_MODER_PRO | `ETH_MODER_BRO, 
                      4'hF, 1, wbm_init_waits, wbm_subseq_waits); // write ASAP
          end
        end
        begin // send a packet from PHY RX
          repeat(1) @(posedge wb_clk); // wait for WB write when it is without delays
          if (num_of_frames[1] == 1'b0)
          begin
            set_rx_addr_type(0, 48'h0102_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E);
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, (i_length + 4), 1'b0);
          end
          else
          begin
            set_rx_addr_type((max_tmp), 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E);
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, max_tmp, (i_length + 4), 1'b0);
          end
        end
        begin: send_packet0
          wait (MRxDV === 1'b1); // start transmit
          wait (MRxDV === 1'b0); // end transmit
          check_frame = 1;
          repeat(10) @(posedge mrx_clk);
          repeat(15) @(posedge wb_clk);
          stop_checking_frame = 1;
        end
        begin // count WB clocks between ACK (negedge) and RX_DV (posedge) or vice-versa
          @(posedge eth_sl_wb_ack_o or posedge MRxDV);
          if ((eth_sl_wb_ack_o === 1'b1) && (MRxDV === 1'b1))
          begin
            tmp_data = 32'h8000_0001; // bit[31]==1 => 'posedge MRxDV' was before 'negedge eth_sl_wb_ack_o'
          end
          else if (MRxDV === 1'b1)
          begin
            while (eth_sl_wb_ack_o === 1'b0)
            begin
              @(posedge wb_clk);
              tmp_data = tmp_data + 1;
            end
            tmp_data = tmp_data | 32'h8000_0000; // bit[31]==1 => 'posedge MRxDV' was before 'negedge eth_sl_wb_ack_o'
          end
          else if (eth_sl_wb_ack_o === 1'b1)
          begin
            @(posedge wb_clk); // wait for one clock => tmp_data 'becomes' 0
            while (MRxDV === 1'b0)
            begin
              @(posedge wb_clk);
              tmp_data = tmp_data + 1; // bit[31]==0 => 'negedge eth_sl_wb_ack_o' was equal or before 'posedge MRxDV'
            end
          end
        end
        begin // check packet
          wait (check_frame == 1);
          check_rx_bd(118, tmp_bd);
          while ((tmp_bd[15] === 1) && (stop_checking_frame == 0))
          begin
            #1 check_rx_bd(118, tmp_bd);
            @(posedge wb_clk);
          end
          if (num_of_frames[0] == 1'b0)
          begin
            if (tmp_bd[15] === 1)
            begin
              if (first_fr_received == 1)
              begin
                first_fr_received = 0;
                $display("    %0d packets (without this one) are checked - packets are received by two in a set",
                         num_of_frames); // +1 due to start with 0 AND -1 because this packet is excluded
                $display("    From this moment:"); 
                $display("    first one of two packets (including this one) is not accepted due to late RX enable");
                if (tmp_data[31])
                  $display("    ->RX enable set %0d WB clks after RX_DV", tmp_data[30:0]);
                else
                  $display("    ->RX enable set %0d WB clks before RX_DV", tmp_data[30:0]);
              end
              // check FB, etc.
              if (tmp_bd[31:0] !== 32'h0000_E000)
              begin
                `TIME; $display("*E RX buffer descriptor status of NOT received packet is not correct: %0h", tmp_bd[31:0]);
                test_fail("RX buffer descriptor status of NOT received packet is not correct");
                fail = fail + 1;
              end
            end
            // else // (tmp_bd[15] === 0) - check FB, packet, etc.
          end
          else // (num_of_frames[0] == 1'b1)
          begin
            if (tmp_bd[15] === 1) // ERROR, because second packet of each two frames should be received
            begin // check NOTHING
                `TIME; $display("*E RX packet should be accepted, buffer descriptor is not correct: %0h", tmp_bd[31:0]);
                test_fail("RX packet should be accepted, buffer descriptor is not correct");
                fail = fail + 1;
            end
            // else // (tmp_bd[15] === 0) - check FB, packet, etc.
          end
          if (stop_checking_frame == 0)
            disable send_packet1;
        end
      join
      // ONLY IF packet was received!
      if (tmp_bd[15] === 0) 
      begin
        // check length of a PACKET
        if (tmp_bd[31:16] != (i_length + 4))
        begin
          `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                          tmp_bd[31:16], (i_length + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        if (first_fr_received == 0) // if PREVIOUS RX buffer descriptor was not ready, pointer address is -1
        begin
          if (num_of_frames[1] == 1'b0)
          begin
            check_rx_packet(0, (`MEMORY_BASE + num_of_frames[1:0] - 1'b1), (i_length + 4), 1'b0, 1'b0, tmp);
          end
          else
          begin
            check_rx_packet(max_tmp, (`MEMORY_BASE + num_of_frames[1:0] - 1'b1), (i_length + 4), 1'b0, 1'b0, tmp);
          end
          if (tmp > 0)
          begin
            `TIME; $display("*E Wrong data of the received packet");
            test_fail("Wrong data of the received packet");
            fail = fail + 1;
          end
        end
        else // if PREVIOUS RX buffer descriptor was ready
        begin
          if (num_of_frames[1] == 1'b0)
          begin
            check_rx_packet(0, (`MEMORY_BASE + num_of_frames[1:0]), (i_length + 4), 1'b0, 1'b0, tmp);
          end
          else
          begin
            check_rx_packet(max_tmp, (`MEMORY_BASE + num_of_frames[1:0]), (i_length + 4), 1'b0, 1'b0, tmp);
          end
          if (tmp > 0)
          begin
            `TIME; $display("*E Wrong data of the received packet");
            test_fail("Wrong data of the received packet");
            fail = fail + 1;
          end
        end
      end
      // check WB INT signal
      if ((num_of_frames[0] == 1'b0) && (first_fr_received == 0)) // interrupt enabled but no receive
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      // check RX buffer descriptor of a packet - only 15 LSBits
      check_rx_bd(118, data);
      if ((num_of_frames[0] == 1'b0) && (first_fr_received == 0)) // interrupt enabled but no receive
      begin
        if (data[15:0] !== 16'hE000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else // interrupt enabled
      begin
        if ((data[15:0] !== 16'h6000) && (data[15:0] !== 16'h6080)) // because of promiscuous
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((num_of_frames[0] == 1'b0) && (first_fr_received == 0)) // interrupt enabled but no receive
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts was set, interrupt reg: %0h, len: %0h", data, num_of_frames[1:0]);
          test_fail("Any of interrupts was set");
          fail = fail + 1;
        end
      end
      else
      begin
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // disable RX after two packets
      if (num_of_frames[0] == 1'b1)
      begin
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, 4'h0, 4'h0); // write ASAP
      end
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      num_of_bd = 0;
      // set length (LOOP variable)
      if (num_of_frames[31:2] == (i_length * 2 + 16)) // 64 => this vas last Byte (1st .. 64th) when i_length = min_tmp - 4
        i_length = (max_tmp - 4);
      @(posedge wb_clk);
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test receive packet synchronization with receive          ////
  ////  disable/enable ( 100Mbps ).                               ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 3) //
  begin
    // TEST 3: RECEIVE PACKET SYNCHRONIZATION WITH RECEIVE DISABLE/ENABLE ( 100Mbps )
    test_name   = "TEST 3: RECEIVE PACKET SYNCHRONIZATION WITH RECEIVE DISABLE/ENABLE ( 100Mbps )";
    `TIME; $display("  TEST 3: RECEIVE PACKET SYNCHRONIZATION WITH RECEIVE DISABLE/ENABLE ( 100Mbps )");

    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set 10 RX buffer descriptor (8'h80 - 8'hA) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h76, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // disable RX, set full-duplex mode, NO receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h0F;
    set_rx_packet(0, (min_tmp + 1), 1'b0, 48'h0102_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
    append_rx_crc(0, (min_tmp + 1), 1'b0, 1'b0);
    st_data = 8'h1A;
    set_rx_packet(max_tmp, (min_tmp + 1), 1'b0, 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E, st_data); 
    append_rx_crc(max_tmp, (min_tmp + 1), 1'b0, 1'b0);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;

    frame_started = 0;
    frame_ended = 0;
    wait_for_frame = 0;
    check_frame = 0;
    stop_checking_frame = 0;
    first_fr_received = 1; // at the beginning the first frame of each two will be received!
    
    num_of_frames = 0; // 
    num_of_bd = 0;
    i_length = (min_tmp + 1); // 5 bytes longer than MINFL
    while (i_length < (max_tmp - 4))
    begin
      // choose generating carrier sense and collision 
      case (num_of_frames[1:0])
      2'h0: // Interrupt is generated
      begin
        // enable interrupt generation
        set_rx_bd(118, 118, 1'b1, (`MEMORY_BASE + num_of_frames[1:0]));
        // not detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is generated
      begin
        // enable interrupt generation
        set_rx_bd(118, 118, 1'b1, (`MEMORY_BASE + num_of_frames[1:0]));
        // detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is generated
      begin
        // disable interrupt generation
        set_rx_bd(118, 118, 1'b1, (`MEMORY_BASE + num_of_frames[1:0]));
        // not detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is generated
      begin
        // disable interrupt generation
        set_rx_bd(118, 118, 1'b1, (`MEMORY_BASE + num_of_frames[1:0]));
        // detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      // set wrap bit
      set_rx_bd_wrap(118);
      set_rx_bd_empty(118, 118);
      check_frame = 0;
      stop_checking_frame = 0;
      tmp_data = 0;
      fork
        begin // enable RX MAC on first of each two packets - every second should be recived normaly
          if (num_of_frames[0] == 1'b0)
          begin
            repeat(1) @(posedge wb_clk);
            if (num_of_frames[1] == 1'b0)
            begin
              repeat (num_of_frames[31:2]) @(posedge mrx_clk); // for every (second) frame enable receiver one clock later
            end
            else
            begin
              @(posedge mrx_clk);
              repeat (num_of_frames[31:2]) @(negedge mrx_clk); // for every (second) frame enable receiver one clock later
            end
            // enable RX, set full-duplex mode, NO receive small, NO correct IFG
            wbm_init_waits = 4'h0;
            wbm_subseq_waits = 4'h0;
            #1 wait (wbm_working == 0);
            wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                      `ETH_MODER_PRO | `ETH_MODER_BRO, 
                      4'hF, 1, wbm_init_waits, wbm_subseq_waits); // write ASAP
          end
        end
        begin // send a packet from PHY RX
          repeat(1) @(posedge wb_clk); // wait for WB write when it is without delays
          if (num_of_frames[1] == 1'b0)
          begin
            set_rx_addr_type(0, 48'h0102_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E);
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, (i_length + 4), 1'b0);
          end
          else
          begin
            set_rx_addr_type((max_tmp), 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E);
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, max_tmp, (i_length + 4), 1'b0);
          end
        end
        begin: send_packet1
          wait (MRxDV === 1'b1); // start transmit
          wait (MRxDV === 1'b0); // end transmit
          check_frame = 1;
          repeat(10) @(posedge mrx_clk);
          repeat(15) @(posedge wb_clk);
          stop_checking_frame = 1;
        end
        begin // count WB clocks between ACK (negedge) and RX_DV (posedge) or vice-versa
          @(posedge eth_sl_wb_ack_o or posedge MRxDV);
          if ((eth_sl_wb_ack_o === 1'b1) && (MRxDV === 1'b1))
          begin
            tmp_data = 32'h8000_0001; // bit[31]==1 => 'posedge MRxDV' was before 'negedge eth_sl_wb_ack_o'
          end
          else if (MRxDV === 1'b1)
          begin
            while (eth_sl_wb_ack_o === 1'b0)
            begin
              @(posedge wb_clk);
              tmp_data = tmp_data + 1;
            end
            tmp_data = tmp_data | 32'h8000_0000; // bit[31]==1 => 'posedge MRxDV' was before 'negedge eth_sl_wb_ack_o'
          end
          else if (eth_sl_wb_ack_o === 1'b1)
          begin
            @(posedge wb_clk); // wait for one clock => tmp_data 'becomes' 0
            while (MRxDV === 1'b0)
            begin
              @(posedge wb_clk);
              tmp_data = tmp_data + 1; // bit[31]==0 => 'negedge eth_sl_wb_ack_o' was equal or before 'posedge MRxDV'
            end
          end
        end
        begin // check packet
          wait (check_frame == 1);
          check_rx_bd(118, tmp_bd);
          while ((tmp_bd[15] === 1) && (stop_checking_frame == 0))
          begin
            #1 check_rx_bd(118, tmp_bd);
            @(posedge wb_clk);
          end
          if (num_of_frames[0] == 1'b0)
          begin
            if (tmp_bd[15] === 1)
            begin
              if (first_fr_received == 1)
              begin
                first_fr_received = 0;
                $display("    %0d packets (without this one) are checked - packets are received by two in a set",
                         num_of_frames); // +1 due to start with 0 AND -1 because this packet is excluded
                $display("    From this moment:"); 
                $display("    first one of two packets (including this one) is not accepted due to late RX enable");
                if (tmp_data[31])
                  $display("    ->RX enable set %0d WB clks after RX_DV", tmp_data[30:0]);
                else
                  $display("    ->RX enable set %0d WB clks before RX_DV", tmp_data[30:0]);
              end
              // check FB, etc.
              if (tmp_bd[31:0] !== 32'h0000_E000)
              begin
                `TIME; $display("*E RX buffer descriptor status of NOT received packet is not correct: %0h", tmp_bd[31:0]);
                test_fail("RX buffer descriptor status of NOT received packet is not correct");
                fail = fail + 1;
              end
            end
            // else // (tmp_bd[15] === 0) - check FB, packet, etc.
          end
          else // (num_of_frames[0] == 1'b1)
          begin
            if (tmp_bd[15] === 1) // ERROR, because second packet of each two frames should be received
            begin // check NOTHING
                `TIME; $display("*E RX packet should be accepted, buffer descriptor is not correct: %0h", tmp_bd[31:0]);
                test_fail("RX packet should be accepted, buffer descriptor is not correct");
                fail = fail + 1;
            end
            // else // (tmp_bd[15] === 0) - check FB, packet, etc.
          end
          if (stop_checking_frame == 0)
            disable send_packet1;
        end
      join
      // ONLY IF packet was received!
      if (tmp_bd[15] === 0) 
      begin
        // check length of a PACKET
        if (tmp_bd[31:16] != (i_length + 4))
        begin
          `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                          tmp_bd[31:16], (i_length + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        if (first_fr_received == 0) // if PREVIOUS RX buffer descriptor was not ready, pointer address is -1
        begin
          if (num_of_frames[1] == 1'b0)
          begin
            check_rx_packet(0, (`MEMORY_BASE + num_of_frames[1:0] - 1'b1), (i_length + 4), 1'b0, 1'b0, tmp);
          end
          else
          begin
            check_rx_packet(max_tmp, (`MEMORY_BASE + num_of_frames[1:0] - 1'b1), (i_length + 4), 1'b0, 1'b0, tmp);
          end
          if (tmp > 0)
          begin
            `TIME; $display("*E Wrong data of the received packet");
            test_fail("Wrong data of the received packet");
            fail = fail + 1;
          end
        end
        else // if PREVIOUS RX buffer descriptor was ready
        begin
          if (num_of_frames[1] == 1'b0)
          begin
            check_rx_packet(0, (`MEMORY_BASE + num_of_frames[1:0]), (i_length + 4), 1'b0, 1'b0, tmp);
          end
          else
          begin
            check_rx_packet(max_tmp, (`MEMORY_BASE + num_of_frames[1:0]), (i_length + 4), 1'b0, 1'b0, tmp);
          end
          if (tmp > 0)
          begin
            `TIME; $display("*E Wrong data of the received packet");
            test_fail("Wrong data of the received packet");
            fail = fail + 1;
          end
        end
      end
      // check WB INT signal
      if ((num_of_frames[0] == 1'b0) && (first_fr_received == 0)) // interrupt enabled but no receive
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      // check RX buffer descriptor of a packet - only 15 LSBits
      check_rx_bd(118, data);
      if ((num_of_frames[0] == 1'b0) && (first_fr_received == 0)) // interrupt enabled but no receive
      begin
        if (data[15:0] !== 16'hE000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else // interrupt enabled
      begin
        if ((data[15:0] !== 16'h6000) && (data[15:0] !== 16'h6080)) // because of promiscuous
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((num_of_frames[0] == 1'b0) && (first_fr_received == 0)) // interrupt enabled but no receive
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts was set, interrupt reg: %0h, len: %0h", data, num_of_frames[1:0]);
          test_fail("Any of interrupts was set");
          fail = fail + 1;
        end
      end
      else
      begin
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // disable RX after two packets
      if (num_of_frames[0] == 1'b1)
      begin
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, 4'h0, 4'h0); // write ASAP
      end
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      num_of_bd = 0;
      // set length (LOOP variable)
      if (num_of_frames[31:2] == (i_length * 2 + 16)) // 64 => this vas last Byte (1st .. 64th) when i_length = min_tmp - 4
        i_length = (max_tmp - 4);
      @(posedge wb_clk);
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test receive packets from MINFL to MAXFL sizes at         ////
  ////  one RX buffer decriptor ( 10Mbps ).                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 4) // 
  begin
    // TEST 4: RECEIVE PACKETS FROM MINFL TO MAXFL SIZES AT ONE RX BD ( 10Mbps )
    test_name   = "TEST 4: RECEIVE PACKETS FROM MINFL TO MAXFL SIZES AT ONE RX BD ( 10Mbps )";
    `TIME; $display("  TEST 4: RECEIVE PACKETS FROM MINFL TO MAXFL SIZES AT ONE RX BD ( 10Mbps )");

    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set 1 RX buffer descriptor (8'h80 - 1) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h7F, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, NO receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
              `ETH_MODER_PRO,// | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h0F;
    set_rx_packet(0, (max_tmp - 4), 1'b0, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
    st_data = 8'h1A;
    set_rx_packet((max_tmp), (max_tmp - 4), 1'b0, 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E, st_data); 
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;

    i_length = (min_tmp - 4);
    while (i_length <= (max_tmp - 4))
    begin
      // choose generating carrier sense and collision for first and last 64 lengths of frames
      case (i_length[1:0])
      2'h0: // Interrupt is generated
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, (`MEMORY_BASE + i_length[1:0]));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is not generated
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_rx_bd(127, 127, 1'b0, (`MEMORY_BASE + i_length[1:0]));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_rx_bd(127, 127, 1'b0, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      if (i_length[0] == 1'b0)
        append_rx_crc (0, i_length, 1'b0, 1'b0);
      else
        append_rx_crc (max_tmp, i_length, 1'b0, 1'b0);
      // set wrap bit
      set_rx_bd_wrap(127);
      set_rx_bd_empty(127, 127);
      fork
        begin
          if (i_length[0] == 1'b0)
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, (i_length + 4), 1'b0);
          else
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, max_tmp, (i_length + 4), 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin
          #1 check_rx_bd(127, data);
          if (i_length < min_tmp) // just first four
          begin
            while (data[15] === 1)
            begin
              #1 check_rx_bd(127, data);
              @(posedge wb_clk);
            end
            repeat (1) @(posedge wb_clk);
          end
          else
          begin
            wait (MRxDV === 1'b1); // start transmit
            #1 check_rx_bd(127, data);
            if (data[15] !== 1)
            begin
              test_fail("Wrong buffer descriptor's ready bit read out from MAC");
              fail = fail + 1;
            end
            wait (MRxDV === 1'b0); // end transmit
            while (data[15] === 1)
            begin
              #1 check_rx_bd(127, data);
              @(posedge wb_clk);
            end
            repeat (1) @(posedge wb_clk);
          end
        end
      join
      // check length of a PACKET
      if (data[31:16] != (i_length + 4))
      begin
        `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                        data[31:16], (i_length + 4));
        test_fail("Wrong length of the packet out from PHY");
        fail = fail + 1;
      end
      // checking in the following if statement is performed only for first and last 64 lengths
      // check received RX packet data and CRC
      if (i_length[0] == 1'b0)
      begin
        check_rx_packet(0, (`MEMORY_BASE + i_length[1:0]), (i_length + 4), 1'b0, 1'b0, tmp);
      end
      else
      begin
        check_rx_packet(max_tmp, ((`MEMORY_BASE + i_length[1:0]) + max_tmp), (i_length + 4), 1'b0, 1'b0, tmp);
      end
      if (tmp > 0)
      begin
        `TIME; $display("*E Wrong data of the received packet");
        test_fail("Wrong data of the received packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (i_length[1:0] == 2'h0)
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check RX buffer descriptor of a packet
      check_rx_bd(127, data);
      if (i_length[1] == 1'b0) // interrupt enabled no_carrier_sense_rx_fd_detect
      begin
        if ( ((data[15:0] !== 16'h6080) && (i_length[0] == 1'b0)) ||
             ((data[15:0] !== 16'h6080) && (i_length[0] == 1'b1)) )
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else // interrupt not enabled
      begin
        if ( ((data[15:0] !== 16'h2080) && (i_length[0] == 1'b0)) ||
             ((data[15:0] !== 16'h2080) && (i_length[0] == 1'b1)) )
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear RX buffer descriptor for first 4 frames
      if (i_length < min_tmp)
        clear_rx_bd(127, 127);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1))
      begin
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Receive Buffer) was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if ((i_length + 4) == (min_tmp + 64))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 64)
        $display("    receive small packets is NOT selected");
        $display("    ->packets with lengths from %0d (MINFL) to %0d are checked (length increasing by 1 byte)",
                 min_tmp, (min_tmp + 64));
        // set receive small, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (max_tmp - 16))
      begin
        // starting length is for +128 longer than previous ending length, while ending length is tmp_data
        $display("    receive small packets is selected");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 128 bytes)",
                 (min_tmp + 64 + 128), tmp_data); 
        // reset receive small, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == max_tmp)
      begin
        $display("    receive small packets is NOT selected");
        $display("    ->packets with lengths from %0d to %0d (MAXFL) are checked (length increasing by 1 byte)",
                 (max_tmp - (4 + 16)), max_tmp);
      end
      // set length (loop variable)
      if ((i_length + 4) < (min_tmp + 64))
        i_length = i_length + 1;
      else if ( ((i_length + 4) >= (min_tmp + 64)) && ((i_length + 4) <= (max_tmp - 256)) )
      begin
        i_length = i_length + 128;
        tmp_data = i_length + 4; // last tmp_data is ending length
      end
      else if ( ((i_length + 4) > (max_tmp - 256)) && ((i_length + 4) < (max_tmp - 16)) )
        i_length = max_tmp - (4 + 16);
      else if ((i_length + 4) >= (max_tmp - 16))
        i_length = i_length + 1;
      else
      begin
        $display("*E TESTBENCH ERROR - WRONG PARAMETERS IN TESTBENCH");
        #10 $stop;
      end
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test receive packets from MINFL to MAXFL sizes at         ////
  ////  one RX buffer decriptor ( 100Mbps ).                      ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 5) //
  begin
    // TEST 5: RECEIVE PACKETS FROM MINFL TO MAXFL SIZES AT ONE RX BD ( 100Mbps )
    test_name   = "TEST 5: RECEIVE PACKETS FROM MINFL TO MAXFL SIZES AT ONE RX BD ( 100Mbps )";
    `TIME; $display("  TEST 5: RECEIVE PACKETS FROM MINFL TO MAXFL SIZES AT ONE RX BD ( 100Mbps )");

    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set 1 RX buffer descriptor (8'h80 - 1) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h7F, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, NO receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h0F;
    set_rx_packet(0, (max_tmp - 4), 1'b0, 48'h0102_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
    st_data = 8'h1A;
    set_rx_packet((max_tmp), (max_tmp - 4), 1'b0, 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E, st_data); 
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;

    i_length = (min_tmp - 4);
    while (i_length <= (max_tmp - 4))
    begin
      // choose generating carrier sense and collision for first and last 64 lengths of frames
      case (i_length[1:0])
      2'h0: // Interrupt is generated
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, (`MEMORY_BASE + i_length[1:0]));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is not generated
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_rx_bd(127, 127, 1'b0, (`MEMORY_BASE + i_length[1:0]));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_rx_bd(127, 127, 1'b0, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      if (i_length[0] == 1'b0)
        append_rx_crc (0, i_length, 1'b0, 1'b0);
      else
        append_rx_crc (max_tmp, i_length, 1'b0, 1'b0);
      // set wrap bit
      set_rx_bd_wrap(127);
      set_rx_bd_empty(127, 127);
      fork
        begin
          if (i_length[0] == 1'b0)
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, (i_length + 4), 1'b0);
          else
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, max_tmp, (i_length + 4), 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin
          #1 check_rx_bd(127, data);
          if (i_length < min_tmp) // just first four
          begin
            while (data[15] === 1)
            begin
              #1 check_rx_bd(127, data);
              @(posedge wb_clk);
            end
            repeat (1) @(posedge wb_clk);
          end
          else
          begin
            wait (MRxDV === 1'b1); // start transmit
            #1 check_rx_bd(127, data);
            if (data[15] !== 1)
            begin
              test_fail("Wrong buffer descriptor's ready bit read out from MAC");
              fail = fail + 1;
            end
            wait (MRxDV === 1'b0); // end transmit
            while (data[15] === 1)
            begin
              #1 check_rx_bd(127, data);
              @(posedge wb_clk);
            end
            repeat (1) @(posedge wb_clk);
          end
        end
      join
      // check length of a PACKET
      if (data[31:16] != (i_length + 4))
      begin
        `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                        data[31:16], (i_length + 4));
        test_fail("Wrong length of the packet out from PHY");
        fail = fail + 1;
      end
      // checking in the following if statement is performed only for first and last 64 lengths
      // check received RX packet data and CRC
      if (i_length[0] == 1'b0)
      begin
        check_rx_packet(0, (`MEMORY_BASE + i_length[1:0]), (i_length + 4), 1'b0, 1'b0, tmp);
      end
      else
      begin
        check_rx_packet(max_tmp, ((`MEMORY_BASE + i_length[1:0]) + max_tmp), (i_length + 4), 1'b0, 1'b0, tmp);
      end
      if (tmp > 0)
      begin
        `TIME; $display("*E Wrong data of the received packet");
        test_fail("Wrong data of the received packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (i_length[1:0] == 2'h0)
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check RX buffer descriptor of a packet
      check_rx_bd(127, data);
      if (i_length[1] == 1'b0) // interrupt enabled 
      begin
        if ( ((data[15:0] !== 16'h6080) && (i_length[0] == 1'b0)) ||
             ((data[15:0] !== 16'h6080) && (i_length[0] == 1'b1)) )
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else // interrupt not enabled
      begin
        if ( ((data[15:0] !== 16'h2080) && (i_length[0] == 1'b0)) ||
             ((data[15:0] !== 16'h2080) && (i_length[0] == 1'b1)) )
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear RX buffer descriptor for first 4 frames
      if (i_length < min_tmp)
        clear_rx_bd(127, 127);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1))
      begin
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Receive Buffer) was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if ((i_length + 4) == (min_tmp + 64))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 64)
        $display("    receive small packets is NOT selected");
        $display("    ->packets with lengths from %0d (MINFL) to %0d are checked (length increasing by 1 byte)",
                 min_tmp, (min_tmp + 64));
        // set receive small, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (max_tmp - 16))
      begin
        // starting length is for +128 longer than previous ending length, while ending length is tmp_data
        $display("    receive small packets is selected");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 128 bytes)",
                 (min_tmp + 64 + 128), tmp_data); 
        // reset receive small, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == max_tmp)
      begin
        $display("    receive small packets is NOT selected");
        $display("    ->packets with lengths from %0d to %0d (MAXFL) are checked (length increasing by 1 byte)",
                 (max_tmp - (4 + 16)), max_tmp);
      end
      // set length (loop variable)
      if ((i_length + 4) < (min_tmp + 64))
        i_length = i_length + 1;
      else if ( ((i_length + 4) >= (min_tmp + 64)) && ((i_length + 4) <= (max_tmp - 256)) )
      begin
        i_length = i_length + 128;
        tmp_data = i_length + 4; // last tmp_data is ending length
      end
      else if ( ((i_length + 4) > (max_tmp - 256)) && ((i_length + 4) < (max_tmp - 16)) )
        i_length = max_tmp - (4 + 16);
      else if ((i_length + 4) >= (max_tmp - 16))
        i_length = i_length + 1;
      else
      begin
        $display("*E TESTBENCH ERROR - WRONG PARAMETERS IN TESTBENCH");
        #10 $stop;
      end
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test receive packets from MINFL to MAXFL sizes at         ////
  ////  maximum RX buffer decriptors ( 10Mbps ).                  ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 6) // 
  begin
    // TEST 6: RECEIVE PACKETS FROM MINFL TO MAXFL SIZES AT MAX RX BDs ( 10Mbps )
    test_name = "TEST 6: RECEIVE PACKETS FROM MINFL TO MAXFL SIZES AT MAX RX BDs ( 10Mbps )";
    `TIME; $display("  TEST 6: RECEIVE PACKETS FROM MINFL TO MAXFL SIZES AT MAX RX BDs ( 10Mbps )");
    // set maximum RX buffer descriptors (128) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, NO receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'hAC;
    set_rx_packet(0, (max_tmp - 4), 1'b0, 48'h0102_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
    st_data = 8'h35;
    set_rx_packet((max_tmp), (max_tmp - 4), 1'b0, 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E, st_data);
    num_of_frames = 0;
    num_of_bd = 0;
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;

    i_length = (min_tmp - 4);
    while (i_length <= (max_tmp - 4))
    begin
      // append CRC to packet
      if (i_length[0] == 1'b0)
        append_rx_crc (0, i_length, 1'b0, 1'b0);
      else
        append_rx_crc (max_tmp, i_length, 1'b0, 1'b0);
      // choose generating carrier sense and collision
      case (i_length[1:0])
      2'h0: // Interrupt is generated
      begin
        // Reset_tx_bd nable interrupt generation
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is not generated
      begin
        // set_tx_bd enable interrupt generation
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is not generated
      begin
        // set_tx_bd disable the interrupt generation
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is not generated
      begin
        // set_tx_bd disable the interrupt generation
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      // first 8 frames are received with RX BD 0 (wrap bit on RX BD 0)
      // number of all frames is 154 (146 without first 8)
      if (num_of_frames < 8)
      begin
        case (i_length[1:0])
        2'h0: // Interrupt is generated
        begin
          // enable interrupt generation
          set_rx_bd(0, 0, 1'b1, (`MEMORY_BASE + i_length[1:0]));
          // interrupts are unmasked
        end
        2'h1: // Interrupt is not generated
        begin
          // enable interrupt generation
          set_rx_bd(0, 0, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
          // interrupts are masked
        end
        2'h2: // Interrupt is not generated
        begin
          // disable interrupt generation
          set_rx_bd(0, 0, 1'b0, (`MEMORY_BASE + i_length[1:0]));
          // interrupts are unmasked
        end
        default: // 2'h3: // Interrupt is not generated
        begin
          // disable interrupt generation
          set_rx_bd(0, 0, 1'b0, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
          // interrupts are masked
        end
        endcase
        // set wrap bit
        set_rx_bd_wrap(0);
      end
      // after first 8 number of frames, 128 frames from RX BD 0 to 127 will be received
      else if ((num_of_frames - 8) == 0)
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // RX BD number
        while (tmp_bd_num < 128) // (tmp_len <= (max_tmp - 4)) - this is the last frame
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_rx_bd(tmp_bd_num, tmp_bd_num, !tmp_len[1], (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_rx_bd(tmp_bd_num, tmp_bd_num, !tmp_len[1], ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          if ((tmp_len + 4) < (min_tmp + 128))
            tmp_len = tmp_len + 1;
          else if ( ((tmp_len + 4) == (min_tmp + 128)) && ((tmp_len + 4) <= (max_tmp - 256)) )
            tmp_len = 256;
          else if ( ((tmp_len + 4) > (min_tmp + 128)) && ((tmp_len + 4) <= (max_tmp - 256)) )
            tmp_len = tmp_len + 128;
          else if ( ((tmp_len + 4) > (max_tmp - 256)) && ((tmp_len + 4) < (max_tmp - 16)) )
            tmp_len = max_tmp - (4 + 16);
          else if ((tmp_len + 4) >= (max_tmp - 16))
            tmp_len = tmp_len + 1;
          // set RX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_rx_bd_wrap(127);
      end
      // after 128 + first 8 number of frames, 19 frames from RX BD 0 to 18 will be received
      else if ((num_of_frames - 8) == 128)
      begin
        tmp_len = tmp_len; // length of frame remaines from previous settings
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 19) // (tmp_len <= (max_tmp - 4)) - this is the last frame
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_rx_bd(tmp_bd_num, tmp_bd_num, !tmp_len[1], (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_rx_bd(tmp_bd_num, tmp_bd_num, !tmp_len[1], ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          if ((tmp_len + 4) < (min_tmp + 128))
            tmp_len = tmp_len + 1;
          else if ( ((tmp_len + 4) == (min_tmp + 128)) && ((tmp_len + 4) <= (max_tmp - 256)) )
            tmp_len = 256;
          else if ( ((tmp_len + 4) > (min_tmp + 128)) && ((tmp_len + 4) <= (max_tmp - 256)) )
            tmp_len = tmp_len + 128;
          else if ( ((tmp_len + 4) > (max_tmp - 256)) && ((tmp_len + 4) < (max_tmp - 16)) )
            tmp_len = max_tmp - (4 + 16);
          else if ((tmp_len + 4) >= (max_tmp - 16))
            tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
      end
      // set empty bit
      if (num_of_frames < 8)
        set_rx_bd_empty(0, 0);
      else if ((num_of_frames - 8) < 128)
        set_rx_bd_empty((num_of_frames - 8), (num_of_frames - 8));
      else if ((num_of_frames - 136) < 19)
        set_rx_bd_empty((num_of_frames - 136), (num_of_frames - 136));
      // CHECK END OF RECEIVE
      fork
        begin
          if (i_length[0] == 1'b0)
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, (i_length + 4), 1'b0);
          else
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, max_tmp, (i_length + 4), 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin
          #1 check_rx_bd(num_of_bd, data);
          if (i_length < min_tmp) // just first four
          begin
            while (data[15] === 1)
            begin
              #1 check_rx_bd(num_of_bd, data);
              @(posedge wb_clk);
            end
            repeat (1) @(posedge wb_clk);
          end
          else
          begin
            wait (MRxDV === 1'b1); // start transmit
            #1 check_rx_bd(num_of_bd, data);
            if (data[15] !== 1)
            begin
              test_fail("Wrong buffer descriptor's ready bit read out from MAC");
              fail = fail + 1;
            end
            wait (MRxDV === 1'b0); // end transmit
            while (data[15] === 1)
            begin
              #1 check_rx_bd(num_of_bd, data);
              @(posedge wb_clk);
            end
            repeat (1) @(posedge wb_clk);
          end
        end
      join
      // check length of a PACKET
      if (data[31:16] != (i_length + 4))
      begin
        `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                        data[31:16], (i_length + 4));
        test_fail("Wrong length of the packet out from PHY");
        fail = fail + 1;
      end
      // checking in the following if statement is performed only for first and last 64 lengths
      // check received RX packet data and CRC
      if (i_length[0] == 1'b0)
      begin
        check_rx_packet(0, (`MEMORY_BASE + i_length[1:0]), (i_length + 4), 1'b0, 1'b0, tmp);
      end
      else
      begin
        check_rx_packet(max_tmp, ((`MEMORY_BASE + i_length[1:0]) + max_tmp), (i_length + 4), 1'b0, 1'b0, tmp);
      end
      if (tmp > 0)
      begin
        `TIME; $display("*E Wrong data of the received packet");
        test_fail("Wrong data of the received packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (i_length[1:0] == 2'h0)
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check RX buffer descriptor of a packet
      check_rx_bd(num_of_bd, data);
      if (i_length[1] == 1'b0) // interrupt enabled
      begin
        if ( ((data[15:0] !== 16'h6080) && ((num_of_frames < 8) || ((num_of_frames - 8) == 127))) || // wrap bit
             ((data[15:0] !== 16'h4080) && (num_of_frames >= 8) && ((num_of_frames - 8) != 127)) ) // without wrap bit
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else // interrupt not enabled
      begin
        if ( ((data[15:0] !== 16'h2080)  && ((num_of_frames < 8) || ((num_of_frames - 8) == 127))) || // wrap bit
             ((data[15:0] !== 16'h0080) && (num_of_frames >= 8) && ((num_of_frames - 8) != 127)) ) // without wrap bit
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear first half of 8 frames from RX buffer descriptor 0
      if (num_of_frames < 4)
        clear_rx_bd(num_of_bd, num_of_bd);
      // clear BD with wrap bit
      if (num_of_frames == 140)
        clear_rx_bd(127, 127);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1))
      begin
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Receive Buffer) was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if ((i_length + 4) == (min_tmp + 7))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 128)
        $display("    receive small packets is NOT selected");
        $display("    using only RX BD 0 out of 128 BDs assigned to RX (wrap at first BD - RX BD 0)");
        $display("    ->packets with lengths from %0d (MINFL) to %0d are checked (length increasing by 1 byte)",
                 min_tmp, (min_tmp + 7));
        $display("    ->all packets were received on RX BD 0");
        // reset receive small, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (min_tmp + 128))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 128)
        $display("    receive small packets is NOT selected");
        $display("    using all 128 BDs assigned to RX (wrap at 128th BD - RX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 (min_tmp + 8), (min_tmp + 128));
        $display("    ->packets were received on RX BD %0d to RX BD %0d respectively",
                 1'b0, num_of_bd);
        tmp_bd = num_of_bd + 1;
        // set receive small, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (max_tmp - 16))
      begin
        // starting length is for +128 longer than previous ending length, while ending length is tmp_data
        $display("    receive small packets is selected");
        $display("    using all 128 BDs assigned to RX (wrap at 128th BD - RX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 128 bytes)",
                 (min_tmp + 64 + 128), tmp_data); 
        if (tmp_bd > num_of_bd)
          $display("    ->packets were received from RX BD %0d to RX BD 127 and from RX BD 0 to RX BD %0d respectively",
                   tmp_bd, num_of_bd);
        else
          $display("    ->packets were received from RX BD %0d to RX BD %0d respectively",
                   tmp_bd, num_of_bd);
        tmp_bd = num_of_bd + 1;
        // reset receive small, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == max_tmp)
      begin
        $display("    receive small packets is NOT selected");
        $display("    using all 128 BDs assigned to RX (wrap at 128th BD - RX BD 127)");
        $display("    ->packets with lengths from %0d to %0d (MAXFL) are checked (length increasing by 1 byte)",
                 (max_tmp - (4 + 16)), max_tmp);
        if (tmp_bd > num_of_bd)
          $display("    ->packets were received from RX BD %0d to RX BD 127 and from RX BD 0 to RX BD %0d respectively",
                   tmp_bd, num_of_bd);
        else
          $display("    ->packets were received from RX BD %0d to RX BD %0d respectively",
                   tmp_bd, num_of_bd);
      end
      // set length (loop variable)
      if ((i_length + 4) < (min_tmp + 128))
        i_length = i_length + 1;
      else if ( ((i_length + 4) == (min_tmp + 128)) && ((i_length + 4) <= (max_tmp - 256)) )
        i_length = 256;
      else if ( ((i_length + 4) > (min_tmp + 128)) && ((i_length + 4) <= (max_tmp - 256)) )
      begin
        i_length = i_length + 128;
        tmp_data = i_length + 4; // last tmp_data is ending length
      end
      else if ( ((i_length + 4) > (max_tmp - 256)) && ((i_length + 4) < (max_tmp - 16)) )
        i_length = max_tmp - (4 + 16);
      else if ((i_length + 4) >= (max_tmp - 16))
        i_length = i_length + 1;
      else
      begin
        $display("*E TESTBENCH ERROR - WRONG PARAMETERS IN TESTBENCH");
        #10 $stop;
      end
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      if ((num_of_frames <= 8) || ((num_of_frames - 8) == 128))
        num_of_bd = 0;
      else
        num_of_bd = num_of_bd + 1;
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test receive packets from MINFL to MAXFL sizes at         ////
  ////  maximum RX buffer decriptors ( 100Mbps ).                 ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 7) // 
  begin
    // TEST 7: RECEIVE PACKETS FROM MINFL TO MAXFL SIZES AT MAX RX BDs ( 100Mbps )
    test_name = "TEST 7: RECEIVE PACKETS FROM MINFL TO MAXFL SIZES AT MAX RX BDs ( 100Mbps )";
    `TIME; $display("  TEST 7: RECEIVE PACKETS FROM MINFL TO MAXFL SIZES AT MAX RX BDs ( 100Mbps )");
    // set maximum RX buffer descriptors (128) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, NO receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'hAC;
    set_rx_packet(0, (max_tmp - 4), 1'b0, 48'h0102_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
    st_data = 8'h35;
    set_rx_packet((max_tmp), (max_tmp - 4), 1'b0, 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E, st_data); 
    num_of_frames = 0;
    num_of_bd = 0;
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;

    i_length = (min_tmp - 4);
    while (i_length <= (max_tmp - 4))
    begin
      // append CRC to packet
      if (i_length[0] == 1'b0)
        append_rx_crc (0, i_length, 1'b0, 1'b0);
      else
        append_rx_crc (max_tmp, i_length, 1'b0, 1'b0);
      // choose generating carrier sense and collision
      case (i_length[1:0])
      2'h0: // Interrupt is generated
      begin
        // Reset_tx_bd nable interrupt generation
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: // Interrupt is not generated
      begin
        // set_tx_bd enable interrupt generation
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: // Interrupt is not generated
      begin
        // set_tx_bd disable the interrupt generation
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3: // Interrupt is not generated
      begin
        // set_tx_bd disable the interrupt generation
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      // first 8 frames are received with RX BD 0 (wrap bit on RX BD 0)
      // number of all frames is 154 (146 without first 8)
      if (num_of_frames < 8)
      begin
        case (i_length[1:0])
        2'h0: // Interrupt is generated
        begin
          // enable interrupt generation
          set_rx_bd(0, 0, 1'b1, (`MEMORY_BASE + i_length[1:0]));
          // interrupts are unmasked
        end
        2'h1: // Interrupt is not generated
        begin
          // enable interrupt generation
          set_rx_bd(0, 0, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
          // interrupts are masked
        end
        2'h2: // Interrupt is not generated
        begin
          // disable interrupt generation
          set_rx_bd(0, 0, 1'b0, (`MEMORY_BASE + i_length[1:0]));
          // interrupts are unmasked
        end
        default: // 2'h3: // Interrupt is not generated
        begin
          // disable interrupt generation
          set_rx_bd(0, 0, 1'b0, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
          // interrupts are masked
        end
        endcase
        // set wrap bit
        set_rx_bd_wrap(0);
      end
      // after first 8 number of frames, 128 frames from RX BD 0 to 127 will be received
      else if ((num_of_frames - 8) == 0)
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 0; // RX BD number
        while (tmp_bd_num < 128) // (tmp_len <= (max_tmp - 4)) - this is the last frame
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_rx_bd(tmp_bd_num, tmp_bd_num, !tmp_len[1], (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_rx_bd(tmp_bd_num, tmp_bd_num, !tmp_len[1], ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          if ((tmp_len + 4) < (min_tmp + 128))
            tmp_len = tmp_len + 1;
          else if ( ((tmp_len + 4) == (min_tmp + 128)) && ((tmp_len + 4) <= (max_tmp - 256)) )
            tmp_len = 256;
          else if ( ((tmp_len + 4) > (min_tmp + 128)) && ((tmp_len + 4) <= (max_tmp - 256)) )
            tmp_len = tmp_len + 128;
          else if ( ((tmp_len + 4) > (max_tmp - 256)) && ((tmp_len + 4) < (max_tmp - 16)) )
            tmp_len = max_tmp - (4 + 16);
          else if ((tmp_len + 4) >= (max_tmp - 16))
            tmp_len = tmp_len + 1;
          // set RX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_rx_bd_wrap(127);
      end
      // after 128 + first 8 number of frames, 19 frames from RX BD 0 to 18 will be received
      else if ((num_of_frames - 8) == 128)
      begin
        tmp_len = tmp_len; // length of frame remaines from previous settings
        tmp_bd_num = 0; // TX BD number
        while (tmp_bd_num < 19) // (tmp_len <= (max_tmp - 4)) - this is the last frame
        begin
          // if i_length[1] == 0 then enable interrupt generation otherwise disable it
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_rx_bd(tmp_bd_num, tmp_bd_num, !tmp_len[1], (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_rx_bd(tmp_bd_num, tmp_bd_num, !tmp_len[1], ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          if ((tmp_len + 4) < (min_tmp + 128))
            tmp_len = tmp_len + 1;
          else if ( ((tmp_len + 4) == (min_tmp + 128)) && ((tmp_len + 4) <= (max_tmp - 256)) )
            tmp_len = 256;
          else if ( ((tmp_len + 4) > (min_tmp + 128)) && ((tmp_len + 4) <= (max_tmp - 256)) )
            tmp_len = tmp_len + 128;
          else if ( ((tmp_len + 4) > (max_tmp - 256)) && ((tmp_len + 4) < (max_tmp - 16)) )
            tmp_len = max_tmp - (4 + 16);
          else if ((tmp_len + 4) >= (max_tmp - 16))
            tmp_len = tmp_len + 1;
          // set TX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
      end
      // set empty bit
      if (num_of_frames < 8)
        set_rx_bd_empty(0, 0);
      else if ((num_of_frames - 8) < 128)
        set_rx_bd_empty((num_of_frames - 8), (num_of_frames - 8));
      else if ((num_of_frames - 136) < 19)
        set_rx_bd_empty((num_of_frames - 136), (num_of_frames - 136));
      // CHECK END OF RECEIVE
      fork
        begin
          if (i_length[0] == 1'b0)
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, (i_length + 4), 1'b0);
          else
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, max_tmp, (i_length + 4), 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin
          #1 check_rx_bd(num_of_bd, data);
          if (i_length < min_tmp) // just first four
          begin
            while (data[15] === 1)
            begin
              #1 check_rx_bd(num_of_bd, data);
              @(posedge wb_clk);
            end
            repeat (1) @(posedge wb_clk);
          end
          else
          begin
            wait (MRxDV === 1'b1); // start transmit
            #1 check_rx_bd(num_of_bd, data);
            if (data[15] !== 1)
            begin
              test_fail("Wrong buffer descriptor's ready bit read out from MAC");
              fail = fail + 1;
            end
            wait (MRxDV === 1'b0); // end transmit
            while (data[15] === 1)
            begin
              #1 check_rx_bd(num_of_bd, data);
              @(posedge wb_clk);
            end
            repeat (1) @(posedge wb_clk);
          end
        end
      join
      // check length of a PACKET
      if (data[31:16] != (i_length + 4))
      begin
        `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                        data[31:16], (i_length + 4));
        test_fail("Wrong length of the packet out from PHY");
        fail = fail + 1;
      end
      // check received RX packet data and CRC
      if (i_length[0] == 1'b0)
      begin
        check_rx_packet(0, (`MEMORY_BASE + i_length[1:0]), (i_length + 4), 1'b0, 1'b0, tmp);
      end
      else
      begin
        check_rx_packet(max_tmp, ((`MEMORY_BASE + i_length[1:0]) + max_tmp), (i_length + 4), 1'b0, 1'b0, tmp);
      end
      if (tmp > 0)
      begin
        `TIME; $display("*E Wrong data of the received packet");
        test_fail("Wrong data of the received packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (i_length[1:0] == 2'h0)
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check RX buffer descriptor of a packet
      check_rx_bd(num_of_bd, data);
      if (i_length[1] == 1'b0) // interrupt enabled
      begin
        if ( ((data[15:0] !== 16'h6080) && ((num_of_frames < 8) || ((num_of_frames - 8) == 127))) || // wrap bit
             ((data[15:0] !== 16'h4080) && (num_of_frames >= 8) && ((num_of_frames - 8) != 127)) ) // without wrap bit
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else // interrupt not enabled
      begin
        if ( ((data[15:0] !== 16'h2080)  && ((num_of_frames < 8) || ((num_of_frames - 8) == 127))) || // wrap bit
             ((data[15:0] !== 16'h0080) && (num_of_frames >= 8) && ((num_of_frames - 8) != 127)) ) // without wrap bit
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear first half of 8 frames from RX buffer descriptor 0
      if (num_of_frames < 4)
        clear_rx_bd(num_of_bd, num_of_bd);
      // clear BD with wrap bit
      if (num_of_frames == 140)
        clear_rx_bd(127, 127);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1))
      begin
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Receive Buffer) was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if ((i_length + 4) == (min_tmp + 7))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 128)
        $display("    receive small packets is NOT selected");
        $display("    using only RX BD 0 out of 128 BDs assigned to RX (wrap at first BD - RX BD 0)");
        $display("    ->packets with lengths from %0d (MINFL) to %0d are checked (length increasing by 1 byte)",
                 min_tmp, (min_tmp + 7));
        $display("    ->all packets were received on RX BD 0");
        // reset receive small, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (min_tmp + 128))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 128)
        $display("    receive small packets is NOT selected");
        $display("    using all 128 BDs assigned to RX (wrap at 128th BD - RX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 (min_tmp + 8), (min_tmp + 128));
        $display("    ->packets were received on RX BD %0d to RX BD %0d respectively",
                 1'b0, num_of_bd);
        tmp_bd = num_of_bd + 1;
        // set receive small, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (max_tmp - 16))
      begin
        // starting length is for +128 longer than previous ending length, while ending length is tmp_data
        $display("    receive small packets is selected");
        $display("    using all 128 BDs assigned to RX (wrap at 128th BD - RX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 128 bytes)",
                 (min_tmp + 64 + 128), tmp_data); 
        if (tmp_bd > num_of_bd)
          $display("    ->packets were received from RX BD %0d to RX BD 127 and from RX BD 0 to RX BD %0d respectively",
                   tmp_bd, num_of_bd);
        else
          $display("    ->packets were received from RX BD %0d to RX BD %0d respectively",
                   tmp_bd, num_of_bd);
        tmp_bd = num_of_bd + 1;
        // reset receive small, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == max_tmp)
      begin
        $display("    receive small packets is NOT selected");
        $display("    using all 128 BDs assigned to RX (wrap at 128th BD - RX BD 127)");
        $display("    ->packets with lengths from %0d to %0d (MAXFL) are checked (length increasing by 1 byte)",
                 (max_tmp - (4 + 16)), max_tmp);
        if (tmp_bd > num_of_bd)
          $display("    ->packets were received from RX BD %0d to RX BD 127 and from RX BD 0 to RX BD %0d respectively",
                   tmp_bd, num_of_bd);
        else
          $display("    ->packets were received from RX BD %0d to RX BD %0d respectively",
                   tmp_bd, num_of_bd);
      end
      // set length (loop variable)
      if ((i_length + 4) < (min_tmp + 128))
        i_length = i_length + 1;
      else if ( ((i_length + 4) == (min_tmp + 128)) && ((i_length + 4) <= (max_tmp - 256)) )
        i_length = 256;
      else if ( ((i_length + 4) > (min_tmp + 128)) && ((i_length + 4) <= (max_tmp - 256)) )
      begin
        i_length = i_length + 128;
        tmp_data = i_length + 4; // last tmp_data is ending length
      end
      else if ( ((i_length + 4) > (max_tmp - 256)) && ((i_length + 4) < (max_tmp - 16)) )
        i_length = max_tmp - (4 + 16);
      else if ((i_length + 4) >= (max_tmp - 16))
        i_length = i_length + 1;
      else
      begin
        $display("*E TESTBENCH ERROR - WRONG PARAMETERS IN TESTBENCH");
        #10 $stop;
      end
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      if ((num_of_frames <= 8) || ((num_of_frames - 8) == 128))
        num_of_bd = 0;
      else
        num_of_bd = num_of_bd + 1;
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test receive packets from 0 to (MINFL + 12) sizes at       ////
  ////  8 RX buffer decriptors ( 10Mbps ).                        ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 8) // 
  begin
    // TEST 8: RECEIVE PACKETS FROM 0 TO (MINFL + 12) SIZES AT 8 RX BD ( 10Mbps )
    test_name = "TEST 8: RECEIVE PACKETS FROM 0 TO (MINFL + 12) SIZES AT 8 RX BD ( 10Mbps )";
    `TIME; $display("  TEST 8: RECEIVE PACKETS FROM 0 TO (MINFL + 12) SIZES AT 8 RX BD ( 10Mbps )");
    // set 8 RX buffer descriptors (120 - 127) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h78, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'hAC;
    set_rx_packet(0, (max_tmp - 4), 1'b0, 48'h0102_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
    st_data = 8'h35;
    set_rx_packet((max_tmp), (max_tmp - 4), 1'b0, 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E, st_data); 
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);

    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;
  
    frame_ended = 0;
    num_of_frames = 0;// 0; // 10;
    num_of_bd = 120;
    i_length = 0 - 4;// (0 - 4); // 6; // 4 less due to CRC
    while ((i_length + 4) < 78) // (min_tmp - 4))
    begin
      // append CRC to packet
      if ((i_length[0] == 1'b0) && (num_of_frames > 4))
        append_rx_crc (0, i_length, 1'b0, 1'b0);
      else if (num_of_frames > 4)
        append_rx_crc (max_tmp, i_length, 1'b0, 1'b0);
      // choose generating carrier sense and collision
      case (i_length[1:0])
      2'h0: 
      begin
        // not detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: 
      begin
        // detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: 
      begin
        // not detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3:
      begin
        // detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      #1;
      // first 10 frames are received with RX BD 120 (wrap bit on RX BD 120)
      if (num_of_frames <= 9)
      begin
        case (i_length[1:0])
        2'h0: // Interrupt is generated
        begin
          // enable interrupt generation
          set_rx_bd(120, 120, 1'b1, (`MEMORY_BASE + i_length[1:0]));
        end
        2'h1: // Interrupt is generated
        begin
          // enable interrupt generation
          set_rx_bd(120, 120, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        end
        2'h2: // Interrupt is generated
        begin
          // enable interrupt generation
          set_rx_bd(120, 120, 1'b1, (`MEMORY_BASE + i_length[1:0]));
        end
        default: // 2'h3: // Interrupt is generated
        begin
          // enable interrupt generation
          set_rx_bd(120, 120, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        end
        endcase
        // set wrap bit
        set_rx_bd_wrap(120);
      end
      // 10 <= num_of_frames < 18 => wrap set to TX BD 123
      else if ((num_of_frames == 10) || (num_of_frames == 14))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 120; // RX BD number
        while (tmp_bd_num < 124) // 
        begin
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          tmp_len = tmp_len + 1;
          // set RX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_rx_bd_wrap(123);
      end
      // 18 <= num_of_frames < 28 => wrap set to RX BD 124
      else if ((num_of_frames == 18) || (num_of_frames == 23))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 120; // RX BD number
        while (tmp_bd_num < 125) // 
        begin
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          tmp_len = tmp_len + 1;
          // set RX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_rx_bd_wrap(124);
      end
      // 28 <= num_of_frames < 40 => wrap set to RX BD 125
      else if ((num_of_frames == 28) || (num_of_frames == 34))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 120; // RX BD number
        while (tmp_bd_num < 126) // 
        begin
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          tmp_len = tmp_len + 1;
          // set RX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_rx_bd_wrap(125);
      end
      // 40 <= num_of_frames < 54 => wrap set to RX BD 126
      else if ((num_of_frames == 40) || (num_of_frames == 47))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 120; // RX BD number
        while (tmp_bd_num < 127) // 
        begin
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          tmp_len = tmp_len + 1;
          // set RX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_rx_bd_wrap(126);
      end
      // 54 <= num_of_frames < 70 => wrap set to RX BD 127
      else if ((num_of_frames == 54) || (num_of_frames == 62))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 120; // RX BD number
        while (tmp_bd_num < 128) // 
        begin
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          tmp_len = tmp_len + 1;
          // set RX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_rx_bd_wrap(127);
      end
      // 70 <= num_of_frames < 78 => wrap set to RX BD 127
      else if (num_of_frames == 70)
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 120; // RX BD number
        while (tmp_bd_num < 128) // 
        begin
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          tmp_len = tmp_len + 1;
          // set RX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_rx_bd_wrap(127);
      end
      #1;
      // SET empty bit
      if (num_of_frames < 10)
        set_rx_bd_empty(120, 120);
      else if (num_of_frames < 14)
        set_rx_bd_empty((120 + num_of_frames - 10), (120 + num_of_frames - 10));
      else if (num_of_frames < 18)
        set_rx_bd_empty((120 + num_of_frames - 14), (120 + num_of_frames - 14));
      else if (num_of_frames < 23)
        set_rx_bd_empty((120 + num_of_frames - 18), (120 + num_of_frames - 18));
      else if (num_of_frames < 28)
        set_rx_bd_empty((120 + num_of_frames - 23), (120 + num_of_frames - 23));
      else if (num_of_frames < 34)
        set_rx_bd_empty((120 + num_of_frames - 28), (120 + num_of_frames - 28));
      else if (num_of_frames < 40)
        set_rx_bd_empty((120 + num_of_frames - 34), (120 + num_of_frames - 34));
      else if (num_of_frames < 47)
        set_rx_bd_empty((120 + num_of_frames - 40), (120 + num_of_frames - 40));
      else if (num_of_frames < 54)
        set_rx_bd_empty((120 + num_of_frames - 47), (120 + num_of_frames - 47));
      else if (num_of_frames < 62)
        set_rx_bd_empty((120 + num_of_frames - 54), (120 + num_of_frames - 54));
      else if (num_of_frames < 70)
        set_rx_bd_empty((120 + num_of_frames - 62), (120 + num_of_frames - 62));
      else if (num_of_frames < 78)
        set_rx_bd_empty((120 + num_of_frames - 70), (120 + num_of_frames - 70));
      // CHECK END OF RECEIVE
      // receive just preamble between some packets
      if ((num_of_frames == 0) || (num_of_frames == 4) || (num_of_frames == 9))
      begin
        #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h6, 8'h55, 0, 0, 1'b0);
        @(posedge mrx_clk);
        wait (MRxDV === 1'b0); // end receive
        repeat(10) @(posedge mrx_clk);
        repeat(15) @(posedge wb_clk);
      end
      // receiving frames and checking end of them
      frame_ended = 0;
      check_frame = 0;
      fork
        begin
          if (i_length[0] == 1'b0)
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, (i_length + 4), 1'b0);
          else
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, max_tmp, (i_length + 4), 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin: fr_end1
          wait (MRxDV === 1'b1); // start receive
          #1 check_rx_bd(num_of_bd, data);
          if (data[15] !== 1)
          begin
            test_fail("Wrong buffer descriptor's empty bit read out from MAC");
            fail = fail + 1;
          end
          wait (MRxDV === 1'b0); // end receive
          while ((data[15] === 1) && (check_frame == 0))
          begin
            #1 check_rx_bd(num_of_bd, data);
            @(posedge wb_clk);
          end
          if (data[15] === 0)
            frame_ended = 1;
          repeat (1) @(posedge wb_clk);
        end
        begin
          wait (MRxDV === 1'b1); // start receive
          wait (MRxDV === 1'b0); // end receive
          repeat(10) @(posedge mrx_clk);
          repeat(15) @(posedge wb_clk);
          check_frame = 1;
        end
      join
      // check length of a PACKET
       tmp_data = data[31:16];
      if ( ((tmp_data != (i_length + 4)) && (num_of_frames >= 3)) ||
           ((data[31:16] != 0) && (num_of_frames < 3)) )
      begin
        `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                        data[31:16], (i_length + 4));
        test_fail("Wrong length of the packet out from PHY");
        fail = fail + 1;
      end
      // check received RX packet data and CRC
      if ((frame_ended == 1) && (num_of_frames >= 5)) // 5 bytes is minimum size without CRC error, since
      begin                                           // CRC has 4 bytes for itself
        if (i_length[0] == 1'b0)
        begin
          check_rx_packet(0, (`MEMORY_BASE + i_length[1:0]), (i_length + 4), 1'b0, 1'b0, tmp);
        end
        else
        begin
          check_rx_packet(max_tmp, ((`MEMORY_BASE + i_length[1:0]) + max_tmp), (i_length + 4), 1'b0, 1'b0, tmp);
        end
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the received packet");
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
      end
      // check WB INT signal
      if (num_of_frames >= 3) // Frames smaller than 3 are not received.
      begin                   // Frames greater then 5 always cause an interrupt (Frame received)
        if (wb_int !== 1'b1)  // Frames with length 3 or 4 always cause an interrupt (CRC error)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else 
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check RX buffer descriptor of a packet
      // check RX buffer descriptor of a packet
      if (num_of_frames >= min_tmp)
      begin
        if ( (data[15:0] !== 16'h6080) && // wrap bit
             (data[15:0] !== 16'h4080) ) // without wrap bit
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h - len: %0d", data[15:0], num_of_frames);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else if (num_of_frames > 6)
      begin
        if ( (data[15:0] !== 16'h6084) && // wrap bit
             (data[15:0] !== 16'h4084) ) // without wrap bit
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h - len: %0d", data[15:0], num_of_frames);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else if (num_of_frames > 4) // MAC does not recognize Dest. ADDR. for lengths 5, 6 => no MISS
      begin
        if ( (data[15:0] !== 16'h6004) && // wrap bit
             (data[15:0] !== 16'h4004) ) // without wrap bit
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h - len: %0d", data[15:0], num_of_frames);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else if (num_of_frames > 2) // MAC does not recognize Dest. ADDR. for length 3, 4 => no MISS, CRC ERROR
      begin
        if ( (data[15:0] !== 16'h6006) && // wrap bit
             (data[15:0] !== 16'h4006) ) // without wrap bit
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h - len: %0d", data[15:0], num_of_frames);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data[15] !== 1'b1)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h - len: %0d", data[15:0], num_of_frames);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (num_of_frames >= 5)
      begin
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      else if ((num_of_frames < 3)) // Frames smaller than 3 are not received.
      begin
        if (data) // Checking if any interrupt is pending)
        begin
          `TIME; $display("*E Interrupt(s) is(are) pending although frame was ignored, interrupt reg: %0h", data);
          test_fail("Interrupts were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if ((data & `ETH_INT_RXE) !== `ETH_INT_RXE)
        begin
          `TIME; $display("*E Interrupt Receive Buffer Error was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer Error was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXE)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer Error) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer Error) were set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if (num_of_frames == 3)
      begin
        $display("    using 1 BD out of 8 BDs (120..127) assigned to RX (wrap at 1st BD - RX BD 120)");
        $display("    ->packets with lengths from %0d to %0d are not received (length increasing by 1 byte)",
                 0, 3);
      end
      else if (num_of_frames == 9)
      begin
        $display("    using 1 BD out of 8 BDs (120..127) assigned to RX (wrap at 1st BD - RX BD 120)");
        $display("    ->packet with length 4 is not received (length increasing by 1 byte)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 5, 9);
      end
      else if (num_of_frames == 17)
      begin
        $display("    using 4 BDs out of 8 BDs (120..127) assigned to RX (wrap at 4th BD - RX BD 123)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 10, 17);
      end
      else if (num_of_frames == 27)
      begin
        $display("    using 5 BDs out of 8 BDs (120..127) assigned to RX (wrap at 5th BD - RX BD 124)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 18, 27);
      end
      else if (num_of_frames == 40)
      begin
        $display("    using 6 BDs out of 8 BDs (120..127) assigned to RX (wrap at 6th BD - RX BD 125)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 28, 40);
      end
      else if (num_of_frames == 54)
      begin
        $display("    using 7 BDs out of 8 BDs (120..127) assigned to RX (wrap at 7th BD - RX BD 126)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 41, 54);
      end
      else if (num_of_frames == 69)
      begin
        $display("    using 8 BDs out of 8 BDs (120..127) assigned to RX (wrap at 8th BD - RX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 55, 69);
      end
      else if (num_of_frames == 69)
      begin
        $display("    using 8 BDs out of 8 BDs (120..127) assigned to RX (wrap at 8th BD - RX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 55, 69);
      end
      else if (num_of_frames == 77)
      begin
        $display("    using 8 BDs out of 8 BDs (120..127) assigned to RX (wrap at 8th BD - RX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 70, 77);
      end
      // set length (loop variable)
      i_length = i_length + 1;
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      if (/*(num_of_frames == 2) || (num_of_frames == 4) || (num_of_frames == 7) ||*/ (num_of_frames <= 10) || 
          (num_of_frames == 14) || (num_of_frames == 18) || (num_of_frames == 23) || (num_of_frames == 28) ||
          (num_of_frames == 34) || (num_of_frames == 40) || (num_of_frames == 47) ||
          (num_of_frames == 54) || (num_of_frames == 62) || (num_of_frames == 70))
        num_of_bd = 120;
      else
        num_of_bd = num_of_bd + 1;
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test receive packets from 0 to (MINFL + 12) sizes at      ////
  ////  8 RX buffer decriptors ( 100Mbps ).                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 9) // 
  begin
    // TEST 9: RECEIVE PACKETS FROM 0 TO (MINFL + 12) SIZES AT 8 RX BD ( 100Mbps )
    test_name = "TEST 9: RECEIVE PACKETS FROM 0 TO (MINFL + 12) SIZES AT 8 RX BD ( 100Mbps )";
    `TIME; $display("  TEST 9: RECEIVE PACKETS FROM 0 TO (MINFL + 12) SIZES AT 8 RX BD ( 100Mbps )");
    // set 8 RX buffer descriptors (120 - 127) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h78, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'hAC;
    set_rx_packet(0, (max_tmp - 4), 1'b0, 48'h0102_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
    st_data = 8'h35;
    set_rx_packet((max_tmp), (max_tmp - 4), 1'b0, 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E, st_data); 
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);

    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;
  
    frame_ended = 0;
    num_of_frames = 0;// 0; // 10;
    num_of_bd = 120;
    i_length = 0 - 4;// (0 - 4); // 6; // 4 less due to CRC
    while ((i_length + 4) < 78) // (min_tmp - 4))
    begin
      // append CRC to packet
      if ((i_length[0] == 1'b0) && (num_of_frames > 4))
        append_rx_crc (0, i_length, 1'b0, 1'b0);
      else if (num_of_frames > 4)
        append_rx_crc (max_tmp, i_length, 1'b0, 1'b0);
      // choose generating carrier sense and collision
      case (i_length[1:0])
      2'h0: 
      begin
        // not detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(0);
      end
      2'h1: 
      begin
        // detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(0);
      end
      2'h2: 
      begin
        // not detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 2'h3:
      begin
        // detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase
      #1;
      // first 10 frames are received with RX BD 120 (wrap bit on RX BD 120)
      if (num_of_frames <= 9)
      begin
        case (i_length[1:0])
        2'h0: // Interrupt is generated
        begin
          // enable interrupt generation
          set_rx_bd(120, 120, 1'b1, (`MEMORY_BASE + i_length[1:0]));
        end
        2'h1: // Interrupt is generated
        begin
          // enable interrupt generation
          set_rx_bd(120, 120, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        end
        2'h2: // Interrupt is generated
        begin
          // enable interrupt generation
          set_rx_bd(120, 120, 1'b1, (`MEMORY_BASE + i_length[1:0]));
        end
        default: // 2'h3: // Interrupt is generated
        begin
          // enable interrupt generation
          set_rx_bd(120, 120, 1'b1, ((`MEMORY_BASE + i_length[1:0]) + max_tmp));
        end
        endcase
        // set wrap bit
        set_rx_bd_wrap(120);
      end
      // 10 <= num_of_frames < 18 => wrap set to TX BD 123
      else if ((num_of_frames == 10) || (num_of_frames == 14))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 120; // RX BD number
        while (tmp_bd_num < 124) // 
        begin
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          tmp_len = tmp_len + 1;
          // set RX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_rx_bd_wrap(123);
      end
      // 18 <= num_of_frames < 28 => wrap set to RX BD 124
      else if ((num_of_frames == 18) || (num_of_frames == 23))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 120; // RX BD number
        while (tmp_bd_num < 125) // 
        begin
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          tmp_len = tmp_len + 1;
          // set RX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_rx_bd_wrap(124);
      end
      // 28 <= num_of_frames < 40 => wrap set to RX BD 125
      else if ((num_of_frames == 28) || (num_of_frames == 34))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 120; // RX BD number
        while (tmp_bd_num < 126) // 
        begin
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          tmp_len = tmp_len + 1;
          // set RX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_rx_bd_wrap(125);
      end
      // 40 <= num_of_frames < 54 => wrap set to RX BD 126
      else if ((num_of_frames == 40) || (num_of_frames == 47))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 120; // RX BD number
        while (tmp_bd_num < 127) // 
        begin
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          tmp_len = tmp_len + 1;
          // set RX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_rx_bd_wrap(126);
      end
      // 54 <= num_of_frames < 70 => wrap set to RX BD 127
      else if ((num_of_frames == 54) || (num_of_frames == 62))
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 120; // RX BD number
        while (tmp_bd_num < 128) // 
        begin
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          tmp_len = tmp_len + 1;
          // set RX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_rx_bd_wrap(127);
      end
      // 70 <= num_of_frames < 78 => wrap set to RX BD 127
      else if (num_of_frames == 70)
      begin
        tmp_len = i_length; // length of frame
        tmp_bd_num = 120; // RX BD number
        while (tmp_bd_num < 128) // 
        begin
          // if i_length[0] == 0 then base address is `MEMORY_BASE otherwise it is `MEMORY_BASE + max_tmp
          if (tmp_len[0] == 0)
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, (`MEMORY_BASE + tmp_len[1:0]));
          else
            set_rx_bd(tmp_bd_num, tmp_bd_num, 1'b1, ((`MEMORY_BASE + tmp_len[1:0]) + max_tmp));
          // set length (loop variable) - THE SAME AS AT THE END OF THIS TASK !!!
          tmp_len = tmp_len + 1;
          // set RX BD number
          tmp_bd_num = tmp_bd_num + 1;
        end
        // set wrap bit
        set_rx_bd_wrap(127);
      end
      #1;
      // SET empty bit
      if (num_of_frames < 10)
        set_rx_bd_empty(120, 120);
      else if (num_of_frames < 14)
        set_rx_bd_empty((120 + num_of_frames - 10), (120 + num_of_frames - 10));
      else if (num_of_frames < 18)
        set_rx_bd_empty((120 + num_of_frames - 14), (120 + num_of_frames - 14));
      else if (num_of_frames < 23)
        set_rx_bd_empty((120 + num_of_frames - 18), (120 + num_of_frames - 18));
      else if (num_of_frames < 28)
        set_rx_bd_empty((120 + num_of_frames - 23), (120 + num_of_frames - 23));
      else if (num_of_frames < 34)
        set_rx_bd_empty((120 + num_of_frames - 28), (120 + num_of_frames - 28));
      else if (num_of_frames < 40)
        set_rx_bd_empty((120 + num_of_frames - 34), (120 + num_of_frames - 34));
      else if (num_of_frames < 47)
        set_rx_bd_empty((120 + num_of_frames - 40), (120 + num_of_frames - 40));
      else if (num_of_frames < 54)
        set_rx_bd_empty((120 + num_of_frames - 47), (120 + num_of_frames - 47));
      else if (num_of_frames < 62)
        set_rx_bd_empty((120 + num_of_frames - 54), (120 + num_of_frames - 54));
      else if (num_of_frames < 70)
        set_rx_bd_empty((120 + num_of_frames - 62), (120 + num_of_frames - 62));
      else if (num_of_frames < 78)
        set_rx_bd_empty((120 + num_of_frames - 70), (120 + num_of_frames - 70));
      // CHECK END OF RECEIVE
      // receive just preamble between some packets
      if ((num_of_frames == 0) || (num_of_frames == 4) || (num_of_frames == 9))
      begin
        #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h6, 8'h55, 0, 0, 1'b0);
        @(posedge mrx_clk);
        wait (MRxDV === 1'b0); // end receive
        repeat(10) @(posedge mrx_clk);
        repeat(15) @(posedge wb_clk);
      end
      // receiving frames and checking end of them
      frame_ended = 0;
      check_frame = 0;
      fork
        begin
          if (i_length[0] == 1'b0)
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, (i_length + 4), 1'b0);
          else
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, max_tmp, (i_length + 4), 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin: fr_end2
          wait (MRxDV === 1'b1); // start receive
          #1 check_rx_bd(num_of_bd, data);
          if (data[15] !== 1)
          begin
            test_fail("Wrong buffer descriptor's empty bit read out from MAC");
            fail = fail + 1;
          end
          wait (MRxDV === 1'b0); // end receive
          while ((data[15] === 1) && (check_frame == 0))
          begin
            #1 check_rx_bd(num_of_bd, data);
            @(posedge wb_clk);
          end
          if (data[15] === 0)
            frame_ended = 1;
          repeat (1) @(posedge wb_clk);
        end
        begin
          wait (MRxDV === 1'b1); // start receive
          wait (MRxDV === 1'b0); // end receive
          repeat(10) @(posedge mrx_clk);
          repeat(15) @(posedge wb_clk);
          check_frame = 1;
        end
      join
      // check length of a PACKET
       tmp_data = data[31:16];
      if ( ((tmp_data != (i_length + 4)) && (num_of_frames >= 3)) ||
           ((data[31:16] != 0) && (num_of_frames < 3)) )
      begin
        `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                        data[31:16], (i_length + 4));
        test_fail("Wrong length of the packet out from PHY");
        fail = fail + 1;
      end
      // check received RX packet data and CRC
      if ((frame_ended == 1) && (num_of_frames >= 5)) // 5 bytes is minimum size without CRC error, since
      begin                                           // CRC has 4 bytes for itself
        if (i_length[0] == 1'b0)
        begin
          check_rx_packet(0, (`MEMORY_BASE + i_length[1:0]), (i_length + 4), 1'b0, 1'b0, tmp);
        end
        else
        begin
          check_rx_packet(max_tmp, ((`MEMORY_BASE + i_length[1:0]) + max_tmp), (i_length + 4), 1'b0, 1'b0, tmp);
        end
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the received packet");
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
      end
      // check WB INT signal
      if (num_of_frames >= 3) // Frames smaller than 3 are not received.
      begin                   // Frames greater then 5 always cause an interrupt (Frame received)
        if (wb_int !== 1'b1)  // Frames with length 3 or 4 always cause an interrupt (CRC error)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else 
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check RX buffer descriptor of a packet
      if (num_of_frames >= min_tmp)
      begin
        if ( (data[15:0] !== 16'h6080) && // wrap bit
             (data[15:0] !== 16'h4080) ) // without wrap bit
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h - len: %0d", data[15:0], num_of_frames);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else if (num_of_frames > 6)
      begin
        if ( (data[15:0] !== 16'h6084) && // wrap bit
             (data[15:0] !== 16'h4084) ) // without wrap bit
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h - len: %0d", data[15:0], num_of_frames);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else if (num_of_frames > 4) // MAC does not recognize Dest. ADDR. for lengths 5, 6 => no MISS
      begin
        if ( (data[15:0] !== 16'h6004) && // wrap bit
             (data[15:0] !== 16'h4004) ) // without wrap bit
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h - len: %0d", data[15:0], num_of_frames);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else if (num_of_frames > 2) // MAC does not recognize Dest. ADDR. for length 3, 4 => no MISS, CRC ERROR
      begin
        if ( (data[15:0] !== 16'h6006) && // wrap bit
             (data[15:0] !== 16'h4006) ) // without wrap bit
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h - len: %0d", data[15:0], num_of_frames);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data[15] !== 1'b1)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h - len: %0d", data[15:0], num_of_frames);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (num_of_frames >= 5)
      begin
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      else if ((num_of_frames < 3)) // Frames smaller than 3 are not received.
      begin
        if (data) // Checking if any interrupt is pending)
        begin
          `TIME; $display("*E Interrupt(s) is(are) pending although frame was ignored, interrupt reg: %0h", data);
          test_fail("Interrupts were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if ((data & `ETH_INT_RXE) !== `ETH_INT_RXE)
        begin
          `TIME; $display("*E Interrupt Receive Buffer Error was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer Error was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXE)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer Error) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer Error) were set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if (num_of_frames == 3)
      begin
        $display("    using 1 BD out of 8 BDs (120..127) assigned to RX (wrap at 1st BD - RX BD 120)");
        $display("    ->packets with lengths from %0d to %0d are not received (length increasing by 1 byte)",
                 0, 3);
      end
      else if (num_of_frames == 9)
      begin
        $display("    using 1 BD out of 8 BDs (120..127) assigned to RX (wrap at 1st BD - RX BD 120)");
        $display("    ->packet with length 4 is not received (length increasing by 1 byte)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 5, 9);
      end
      else if (num_of_frames == 17)
      begin
        $display("    using 4 BDs out of 8 BDs (120..127) assigned to RX (wrap at 4th BD - RX BD 123)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 10, 17);
      end
      else if (num_of_frames == 27)
      begin
        $display("    using 5 BDs out of 8 BDs (120..127) assigned to RX (wrap at 5th BD - RX BD 124)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 18, 27);
      end
      else if (num_of_frames == 40)
      begin
        $display("    using 6 BDs out of 8 BDs (120..127) assigned to RX (wrap at 6th BD - RX BD 125)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 28, 40);
      end
      else if (num_of_frames == 54)
      begin
        $display("    using 7 BDs out of 8 BDs (120..127) assigned to RX (wrap at 7th BD - RX BD 126)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 41, 54);
      end
      else if (num_of_frames == 69)
      begin
        $display("    using 8 BDs out of 8 BDs (120..127) assigned to RX (wrap at 8th BD - RX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 55, 69);
      end
      else if (num_of_frames == 69)
      begin
        $display("    using 8 BDs out of 8 BDs (120..127) assigned to RX (wrap at 8th BD - RX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 55, 69);
      end
      else if (num_of_frames == 77)
      begin
        $display("    using 8 BDs out of 8 BDs (120..127) assigned to RX (wrap at 8th BD - RX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 70, 77);
      end
      // set length (loop variable)
      i_length = i_length + 1;
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      if (/*(num_of_frames == 2) || (num_of_frames == 4) || (num_of_frames == 7) ||*/ (num_of_frames <= 10) || 
          (num_of_frames == 14) || (num_of_frames == 18) || (num_of_frames == 23) || (num_of_frames == 28) ||
          (num_of_frames == 34) || (num_of_frames == 40) || (num_of_frames == 47) ||
          (num_of_frames == 54) || (num_of_frames == 62) || (num_of_frames == 70))
        num_of_bd = 120;
      else
        num_of_bd = num_of_bd + 1;
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test receive packets at one RX BD and                     ////
  ////  check addresses ( 10Mbps ).                               ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 10) //
  begin
    // TEST 10: RECEIVE PACKETS AT ONE RX BD AND CHECK ADDRESSES ( 10Mbps )
    test_name   = "TEST 10: RECEIVE PACKETS AT ONE RX BD AND CHECK ADDRESSES ( 10Mbps )";
    `TIME; $display("  TEST 10: RECEIVE PACKETS AT ONE RX BD AND CHECK ADDRESSES ( 10Mbps )");

    // set 1 RX buffer descriptor (8'h80 - 1) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h7F, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;

    num_of_frames = 0;
    i_length = 64;
    while (num_of_frames < 8)
    begin
      // not detect carrier sense in FD and no collision
      eth_phy.no_carrier_sense_rx_fd_detect(0);
      eth_phy.collision(0);
      case (num_of_frames)
      0: // unicast + PRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h0F;
        set_rx_packet(0, i_length, 1'b0, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
        $display("    Unicast packet is going to be received with PRO bit (wrap at 1st BD)");
      end
      1: // unicast
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                                   `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h12;
        set_rx_packet(0, i_length, 1'b0, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
        $display("    Unicast packet is going to be received without PRO bit (wrap at 1st BD)");
      end
      2: // wrong unicast + PRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h31;
        set_rx_packet(0, i_length, 1'b0, 48'hAA02_0304_0507, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
        $display("    non Unicast packet is going to be received with PRO bit (wrap at 1st BD)");
      end
      3: // wrong unicast
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                                   `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h0F;
        set_rx_packet(0, i_length, 1'b0, 48'hAA02_0304_0507, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
        $display("    non Unicast packet is NOT going to be received without PRO bit (wrap at 1st BD)");
      end
      4: // broadcast + PRO + ~BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h84;
        set_rx_packet(0, i_length, 1'b0, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet is going to be received with PRO & without Reject_BRO bit (wrap at 1st BD)");
      end
      5: // broadcast       + ~BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h48;
        set_rx_packet(0, i_length, 1'b0, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet is going to be received without Reject_BRO bit (wrap at 1st BD)");
      end
      6: // broadcast + PRO + BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h30;
        set_rx_packet(0, i_length, 1'b0, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet is going to be received with PRO & with Reject_BRO bit (wrap at 1st BD)");
      end
      7: // broadcast       + BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG |
                                   `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h04;
        set_rx_packet(0, i_length, 1'b0, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet is NOT going to be received with Reject_BRO bit (wrap at 1st BD)");
      end
      default:
      begin
      end
      endcase
      // set wrap bit
      set_rx_bd_wrap(127);
      set_rx_bd_empty(127, 127);
      fork
        begin
          #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, (i_length + 4), 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin: wait_for_rec0
          wait (MRxDV === 1'b1); // start transmit
          #1 check_rx_bd(127, data);
          if (data[15] !== 1)
          begin
            test_fail("Wrong buffer descriptor's ready bit read out from MAC");
            fail = fail + 1;
          end
          wait (MRxDV === 1'b0); // end transmit
          while (data[15] === 1)
          begin
            #1 check_rx_bd(127, data);
            @(posedge wb_clk);
          end
          disable check_wait_for_rec0;
          $display("    ->packet received");
          repeat (1) @(posedge wb_clk);
        end
        begin: check_wait_for_rec0
          wait (MRxDV === 1'b1); // start transmit
          wait (MRxDV === 1'b0); // end transmit
          repeat(10) @(posedge mrx_clk);
          repeat(50) @(posedge wb_clk);
          wait (wbm_working == 0);
          disable wait_for_rec0;
          $display("    ->packet NOT received");
        end
      join
      // PACKET checking
      wait (wbm_working == 0);
      check_rx_bd(127, data);
      case (num_of_frames)
      0, 1, 4, 5:
      begin
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'h6000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check length of a PACKET
        if (data[31:16] != (i_length + 4))
        begin
          `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                          data[31:16], (i_length + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        check_rx_packet(0, `MEMORY_BASE, (i_length + 4), 1'b0, 1'b0, tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the received packet");
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      2, 6:
      begin
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'h6080)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check length of a PACKET
        if (data[31:16] != (i_length + 4))
        begin
          `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                          data[31:16], (i_length + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        check_rx_packet(0, `MEMORY_BASE, (i_length + 4), 1'b0, 1'b0, tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the received packet");
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      3, 7:
      begin
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'hE000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end
      end
      default:
      begin
      end
      endcase
      // clear RX buffer descriptor
      clear_rx_bd(127, 127);
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      num_of_frames = num_of_frames + 1;
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test receive packets at one RX BD and                     ////
  ////  check addresses ( 100Mbps ).                              ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 11) //
  begin
    // TEST 11: RECEIVE PACKETS AT ONE RX BD AND CHECK ADDRESSES ( 100Mbps )
    test_name   = "TEST 11: RECEIVE PACKETS AT ONE RX BD AND CHECK ADDRESSES ( 100Mbps )";
    `TIME; $display("  TEST 11: RECEIVE PACKETS AT ONE RX BD AND CHECK ADDRESSES ( 100Mbps )");

    // set 1 RX buffer descriptor (8'h80 - 1) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h7F, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;

    num_of_frames = 0;
    i_length = 64;
    while (num_of_frames < 8)
    begin
      // not detect carrier sense in FD and no collision
      eth_phy.no_carrier_sense_rx_fd_detect(0);
      eth_phy.collision(0);
      case (num_of_frames)
      0: // unicast + PRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h0F;
        set_rx_packet(0, i_length, 1'b0, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
        $display("    Unicast packet is going to be received with PRO bit (wrap at 1st BD)");
      end
      1: // unicast
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                                   `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h12;
        set_rx_packet(0, i_length, 1'b0, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
        $display("    Unicast packet is going to be received without PRO bit (wrap at 1st BD)");
      end
      2: // wrong unicast + PRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h31;
        set_rx_packet(0, i_length, 1'b0, 48'hAA02_0304_0507, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
        $display("    non Unicast packet is going to be received with PRO bit (wrap at 1st BD)");
      end
      3: // wrong unicast
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                                   `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h0F;
        set_rx_packet(0, i_length, 1'b0, 48'hAA02_0304_0507, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
        $display("    non Unicast packet is NOT going to be received without PRO bit (wrap at 1st BD)");
      end
      4: // broadcast + PRO + ~BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h84;
        set_rx_packet(0, i_length, 1'b0, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet is going to be received with PRO & without Reject_BRO bit (wrap at 1st BD)");
      end
      5: // broadcast       + ~BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h48;
        set_rx_packet(0, i_length, 1'b0, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet is going to be received without Reject_BRO bit (wrap at 1st BD)");
      end
      6: // broadcast + PRO + BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h30;
        set_rx_packet(0, i_length, 1'b0, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet is going to be received with PRO & with Reject_BRO bit (wrap at 1st BD)");
      end
      7: // broadcast       + BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG |
                                   `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h04;
        set_rx_packet(0, i_length, 1'b0, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet is NOT going to be received with Reject_BRO bit (wrap at 1st BD)");
      end
      default:
      begin
      end
      endcase
      // set wrap bit
      set_rx_bd_wrap(127);
      set_rx_bd_empty(127, 127);
      fork
        begin
          #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, (i_length + 4), 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin: wait_for_rec1
          wait (MRxDV === 1'b1); // start transmit
          #1 check_rx_bd(127, data);
          if (data[15] !== 1)
          begin
            test_fail("Wrong buffer descriptor's ready bit read out from MAC");
            fail = fail + 1;
          end
          wait (MRxDV === 1'b0); // end transmit
          while (data[15] === 1)
          begin
            #1 check_rx_bd(127, data);
            @(posedge wb_clk);
          end
          disable check_wait_for_rec1;
          $display("    ->packet received");
          repeat (1) @(posedge wb_clk);
        end
        begin: check_wait_for_rec1
          wait (MRxDV === 1'b1); // start transmit
          wait (MRxDV === 1'b0); // end transmit
          repeat(10) @(posedge mrx_clk);
          repeat(50) @(posedge wb_clk);
          wait (wbm_working == 0);
          disable wait_for_rec1;
          $display("    ->packet NOT received");
        end
      join
      // PACKET checking
      wait (wbm_working == 0);
      check_rx_bd(127, data);
      case (num_of_frames)
      0, 1, 4, 5:
      begin
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'h6000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check length of a PACKET
        if (data[31:16] != (i_length + 4))
        begin
          `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                          data[31:16], (i_length + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        check_rx_packet(0, `MEMORY_BASE, (i_length + 4), 1'b0, 1'b0, tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the received packet");
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      2, 6:
      begin
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'h6080)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check length of a PACKET
        if (data[31:16] != (i_length + 4))
        begin
          `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                          data[31:16], (i_length + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        check_rx_packet(0, `MEMORY_BASE, (i_length + 4), 1'b0, 1'b0, tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the received packet");
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      3, 7:
      begin
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'hE000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end
      end
      default:
      begin
      end
      endcase
      // clear RX buffer descriptor
      clear_rx_bd(127, 127);
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      num_of_frames = num_of_frames + 1;
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test receive packets at 8 RX BD with                      ////
  ////  RX FIFO and RX BD overrun ( 10Mbps ).                     ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 12) //
  begin
    // TEST 12: RECEIVE PACKETS AT 8 RX BD WITH RX FIFO AND RX BD OVERRUN ( 10Mbps )
    test_name   = "TEST 12: RECEIVE PACKETS AT 8 RX BD WITH RX FIFO AND RX BD OVERRUN ( 10Mbps )";
    `TIME; $display("  TEST 12: RECEIVE PACKETS AT 8 RX BD WITH RX FIFO AND RX BD OVERRUN ( 10Mbps )");
    // set 8 RX buffer descriptors (120 - 127) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h78, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set Destination address - Byte 0 sent first
    wait (wbm_working == 0);
    wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
    wait (wbm_working == 0);
    wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.

    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);

    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;

    // enable interrupt generation
    set_rx_bd(120, 127, 1'b1, `MEMORY_BASE);
    // set wrap bit
    set_rx_bd_wrap(127);
    // SET empty bit
    set_rx_bd_empty(120, 127);

//check_rx_bd(120, data);
//$display("RX BD 120 = %h", data);
//check_rx_bd(121, data);
//$display("RX BD 121 = %h", data);
//check_rx_bd(122, data);
//$display("RX BD 122 = %h", data);
//check_rx_bd(123, data);
//$display("RX BD 123 = %h", data);
//check_rx_bd(124, data);
//$display("RX BD 124 = %h", data);
//check_rx_bd(125, data);
//$display("RX BD 125 = %h", data);
//check_rx_bd(126, data);
//$display("RX BD 126 = %h", data);
//check_rx_bd(127, data);
//$display("RX BD 127 = %h", data);

    num_of_frames = 0;
    while (num_of_frames < 11)
    begin
      // not detect carrier sense in FD and no collision
      eth_phy.no_carrier_sense_rx_fd_detect(0);
      eth_phy.collision(0);
      if (num_of_frames < 2)
        num_of_bd = 120 + num_of_frames;
      else if (num_of_frames < 9)
        num_of_bd = 120 + num_of_frames - 1;
      else
        num_of_bd = 120;
      case (num_of_frames)
      0:
      begin
        // prepare packet
        i_length = 60;
        st_data = 8'h0F;
        set_rx_packet(0, i_length, 1'b0, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
      end
      3:
      begin
        // prepare packet
        i_length = 68;
        st_data = 8'h01;
        set_rx_packet(0, i_length, 1'b0, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
      end
      6:
      begin
        // prepare packet
        i_length = 80;
        st_data = 8'hA1;
        set_rx_packet(0, i_length, 1'b0, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
      end
      10:
      begin
        // SET empty bit
        set_rx_bd_empty(120, 127);
      end
      default:
      begin
      end
      endcase
      // DISPLAYS
      case (num_of_frames)
      0, 3, 5, 7, 8, 10: // correct packet received
      begin
        $display("    packet shoud be successfuly received");
      end
      1: // correct packet stayed in RX FIFO
      begin
        $display("    packet (64Bytes) should be retained in RX FIFO and written to MEM after next RX FIFO overrun");
      end
      2, 4, 6: // RX FIFO overrun
      begin
        $display("    packet should NOT be received - RX FIFO overrun");
      end
      9: // RX BD overrun
      begin
        $display("    packet should NOT be received - RX FIFO overrun due to lack of RX BDs");
      end
      default:
      begin
      end
      endcase

      fork
        begin
          #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, (i_length + 4), 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin: set_no_resp2
          if ((num_of_frames == 1) || (num_of_frames == 4)) // RX FIFO overrun!
            #1 wb_slave.cycle_response(`NO_RESPONSE, 3'h0, 8'hFF);
          if (num_of_frames == 6) // RX FIFO overrun!
          begin
            wait (MRxDV === 1'b1); // start transmit
            wait (eth_ma_wb_ack_i === 1'b1) // WB transfer
            wait (eth_ma_wb_ack_i === 1'b0) // WB transfer
            #1 wb_slave.cycle_response(`NO_RESPONSE, 3'h0, 8'hFF);
          end
        end
        begin: wait_for_rec2
          wait (MRxDV === 1'b1); // start transmit
          #1 check_rx_bd(num_of_bd, data);
//$display("Num of RX BD = %d, RX BD %0d = %h", num_of_bd, num_of_bd, data);
          if (((data[15] !== 1) && (num_of_frames != 9)) || // RX BD must be Empty
              ((data[15] !== 0) && (num_of_frames == 9)))   // RX BD must NOT be Empty - RX BD overrun!!!
          begin
            test_fail("Wrong buffer descriptor's ready bit read out from MAC");
            fail = fail + 1;
          end
          wait (MRxDV === 1'b0); // end transmit
          while (((data[15] === 1) && (num_of_frames != 9)) || 
                 ((data[15] === 0) && (num_of_frames == 9)))
          begin
            #1 check_rx_bd(num_of_bd, data);
            @(posedge wb_clk);
          end
          disable check_wait_for_rec2;
          disable set_no_resp2;
          $display("    ->packet received");
          repeat (1) @(posedge wb_clk);
        end
        begin: check_wait_for_rec2
          wait (MRxDV === 1'b1); // start transmit
          wait (MRxDV === 1'b0); // end transmit
          repeat(10) @(posedge mrx_clk);
          repeat(50) @(posedge wb_clk);
          wait (wbm_working == 0);
          disable wait_for_rec2;
          disable set_no_resp2;
          $display("    ->packet NOT received");
        end
      join
      // PACKET checking
      case (num_of_frames)
      0, 3, 5, 7, 8, 10: // correct packet received
      begin

//check_rx_bd(120, data);
//$display("RX BD 120 = %h", data);
//check_rx_bd(121, data);
//$display("RX BD 121 = %h", data);
//check_rx_bd(122, data);
//$display("RX BD 122 = %h", data);
//check_rx_bd(123, data);
//$display("RX BD 123 = %h", data);
//check_rx_bd(124, data);
//$display("RX BD 124 = %h", data);
//check_rx_bd(125, data);
//$display("RX BD 125 = %h", data);
//check_rx_bd(126, data);
//$display("RX BD 126 = %h", data);
//check_rx_bd(127, data);
//$display("RX BD 127 = %h", data);

        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        check_rx_bd(num_of_bd, data);
        // check RX buffer descriptor of a packet
        if (((data[15:0] !== 16'h4000) && (num_of_bd != 127)) || // without wrap bit
            ((data[15:0] !== 16'h6000) && (num_of_bd == 127)))
        begin
          `TIME; 
          if (num_of_bd != 127)
            $display("*E RX buffer descriptor status is not correct: %0h instead of 4000", data[15:0]);
          else
            $display("*E RX buffer descriptor status is not correct: %0h instead of 6000", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check length of a PACKET
        if (data[31:16] != (i_length + 4))
        begin
          `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                          data[31:16], (i_length + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        check_rx_packet(0, `MEMORY_BASE, (i_length + 4), 1'b0, 1'b0, tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the received packet");
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      1: // correct packet stayed in RX FIFO
      begin

//check_rx_bd(120, data);
//$display("RX BD 120 = %h", data);
//check_rx_bd(121, data);
//$display("RX BD 121 = %h", data);
//check_rx_bd(122, data);
//$display("RX BD 122 = %h", data);
//check_rx_bd(123, data);
//$display("RX BD 123 = %h", data);
//check_rx_bd(124, data);
//$display("RX BD 124 = %h", data);
//check_rx_bd(125, data);
//$display("RX BD 125 = %h", data);
//check_rx_bd(126, data);
//$display("RX BD 126 = %h", data);
//check_rx_bd(127, data);
//$display("RX BD 127 = %h", data);

        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        check_rx_bd(num_of_bd, data);
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'hC000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h instead of C000", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end
      end
      2: // RX FIFO overrun & previous packet written
      begin

//check_rx_bd(120, data);
//$display("RX BD 120 = %h", data);
//check_rx_bd(121, data);
//$display("RX BD 121 = %h", data);
//check_rx_bd(122, data);
//$display("RX BD 122 = %h", data);
//check_rx_bd(123, data);
//$display("RX BD 123 = %h", data);
//check_rx_bd(124, data);
//$display("RX BD 124 = %h", data);
//check_rx_bd(125, data);
//$display("RX BD 125 = %h", data);
//check_rx_bd(126, data);
//$display("RX BD 126 = %h", data);
//check_rx_bd(127, data);
//$display("RX BD 127 = %h", data);

        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        check_rx_bd(num_of_bd, data);
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'hC000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h instead of C000", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end

        // Release packet
        #1 wb_slave.cycle_response(`ACK_RESPONSE, 3'h0, 8'h0);
        repeat(128) @(posedge wb_clk);
          $display("    ->previous packet written into MEM");

//check_rx_bd(120, data);
//$display("RX BD 120 = %h", data);
//check_rx_bd(121, data);
//$display("RX BD 121 = %h", data);
//check_rx_bd(122, data);
//$display("RX BD 122 = %h", data);
//check_rx_bd(123, data);
//$display("RX BD 123 = %h", data);
//check_rx_bd(124, data);
//$display("RX BD 124 = %h", data);
//check_rx_bd(125, data);
//$display("RX BD 125 = %h", data);
//check_rx_bd(126, data);
//$display("RX BD 126 = %h", data);
//check_rx_bd(127, data);
//$display("RX BD 127 = %h", data);

        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        check_rx_bd(num_of_bd, data);
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'h4000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h instead of 4000", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer Error was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer Error was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer Error) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer Error) were set");
          fail = fail + 1;
        end

      end
      4, 6: // RX FIFO overrun
      begin

//check_rx_bd(120, data);
//$display("RX BD 120 = %h", data);
//check_rx_bd(121, data);
//$display("RX BD 121 = %h", data);
//check_rx_bd(122, data);
//$display("RX BD 122 = %h", data);
//check_rx_bd(123, data);
//$display("RX BD 123 = %h", data);
//check_rx_bd(124, data);
//$display("RX BD 124 = %h", data);
//check_rx_bd(125, data);
//$display("RX BD 125 = %h", data);
//check_rx_bd(126, data);
//$display("RX BD 126 = %h", data);
//check_rx_bd(127, data);
//$display("RX BD 127 = %h", data);

        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        check_rx_bd(num_of_bd, data);
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'hC000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h instead of C000", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end

        // Release packet
        #1 wb_slave.cycle_response(`ACK_RESPONSE, 3'h0, 8'h0);
        repeat(128) @(posedge wb_clk);

//check_rx_bd(120, data);
//$display("RX BD 120 = %h", data);
//check_rx_bd(121, data);
//$display("RX BD 121 = %h", data);
//check_rx_bd(122, data);
//$display("RX BD 122 = %h", data);
//check_rx_bd(123, data);
//$display("RX BD 123 = %h", data);
//check_rx_bd(124, data);
//$display("RX BD 124 = %h", data);
//check_rx_bd(125, data);
//$display("RX BD 125 = %h", data);
//check_rx_bd(126, data);
//$display("RX BD 126 = %h", data);
//check_rx_bd(127, data);
//$display("RX BD 127 = %h", data);

        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        check_rx_bd(num_of_bd, data);
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'h4040)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h instead of 4040", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_RXE) !== `ETH_INT_RXE)
        begin
          `TIME; $display("*E Interrupt Receive Buffer Error was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer Error was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXE)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer Error) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer Error) were set");
          fail = fail + 1;
        end

      end
      9: // RX BD overrun
      begin

//check_rx_bd(120, data);
//$display("RX BD 120 = %h", data);
//check_rx_bd(121, data);
//$display("RX BD 121 = %h", data);
//check_rx_bd(122, data);
//$display("RX BD 122 = %h", data);
//check_rx_bd(123, data);
//$display("RX BD 123 = %h", data);
//check_rx_bd(124, data);
//$display("RX BD 124 = %h", data);
//check_rx_bd(125, data);
//$display("RX BD 125 = %h", data);
//check_rx_bd(126, data);
//$display("RX BD 126 = %h", data);
//check_rx_bd(127, data);
//$display("RX BD 127 = %h", data);

        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        check_rx_bd(num_of_bd, data);
        // check RX buffer descriptor of a packet
          // NOT checked since BD value is from first packet - RX BD overrun
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_BUSY) !== `ETH_INT_BUSY)
        begin
          `TIME; $display("*E Interrupt BUSY was not set, interrupt reg: %0h", data);
          test_fail("Interrupt BUSY was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_BUSY)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except BUSY) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except BUSY) were set");
          fail = fail + 1;
        end
      end
      default:
      begin
      end
      endcase
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      num_of_frames = num_of_frames + 1;
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG |
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test receive packets at 8 RX BD with                      ////
  ////  RX FIFO and RX BD overrun ( 100Mbps ).                    ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 13) //
  begin
    // TEST 13: RECEIVE PACKETS AT 8 RX BD WITH RX FIFO AND RX BD OVERRUN ( 100Mbps )
    test_name   = "TEST 13: RECEIVE PACKETS AT 8 RX BD WITH RX FIFO AND RX BD OVERRUN ( 100Mbps )";
    `TIME; $display("  TEST 13: RECEIVE PACKETS AT 8 RX BD WITH RX FIFO AND RX BD OVERRUN ( 100Mbps )");
    // set 8 RX buffer descriptors (120 - 127) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h78, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set Destination address - Byte 0 sent first
    wait (wbm_working == 0);
    wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
    wait (wbm_working == 0);
    wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.

    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);

    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;

    // enable interrupt generation
    set_rx_bd(120, 127, 1'b1, `MEMORY_BASE);
    // set wrap bit
    set_rx_bd_wrap(127);
    // SET empty bit
    set_rx_bd_empty(120, 127);

    num_of_frames = 0;
    while (num_of_frames < 11)
    begin
      // not detect carrier sense in FD and no collision
      eth_phy.no_carrier_sense_rx_fd_detect(0);
      eth_phy.collision(0);
      if (num_of_frames < 2)
        num_of_bd = 120 + num_of_frames;
      else if (num_of_frames < 9)
        num_of_bd = 120 + num_of_frames - 1;
      else
        num_of_bd = 120;
      case (num_of_frames)
      0:
      begin
        // prepare packet
        i_length = 60;
        st_data = 8'h0F;
        set_rx_packet(0, i_length, 1'b0, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
      end
      3:
      begin
        // prepare packet
        i_length = 68;
        st_data = 8'h01;
        set_rx_packet(0, i_length, 1'b0, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
      end
      6:
      begin
        // prepare packet
        i_length = 80;
        st_data = 8'hA1;
        set_rx_packet(0, i_length, 1'b0, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc (0, i_length, 1'b0, 1'b0);
      end
      10:
      begin
        // SET empty bit
        set_rx_bd_empty(120, 127);
      end
      default:
      begin
      end
      endcase
      // DISPLAYS
      case (num_of_frames)
      0, 3, 5, 7, 8, 10: // correct packet received
      begin
        $display("    packet shoud be successfuly received");
      end
      1: // correct packet stayed in RX FIFO
      begin
        $display("    packet (64Bytes) should be retained in RX FIFO and written to MEM after next RX FIFO overrun");
      end
      2, 4, 6: // RX FIFO overrun
      begin
        $display("    packet should NOT be received - RX FIFO overrun");
      end
      9: // RX BD overrun
      begin
        $display("    packet should NOT be received - RX FIFO overrun due to lack of RX BDs");
      end
      default:
      begin
      end
      endcase

      fork
        begin
          #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, (i_length + 4), 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin: set_no_resp3
          if ((num_of_frames == 1) || (num_of_frames == 4)) // RX FIFO overrun!
            #1 wb_slave.cycle_response(`NO_RESPONSE, 3'h0, 8'hFF);
          if (num_of_frames == 6) // RX FIFO overrun!
          begin
            wait (MRxDV === 1'b1); // start transmit
            wait (eth_ma_wb_ack_i === 1'b1) // WB transfer
            wait (eth_ma_wb_ack_i === 1'b0) // WB transfer
            #1 wb_slave.cycle_response(`NO_RESPONSE, 3'h0, 8'hFF);
          end
        end
        begin: wait_for_rec3
          wait (MRxDV === 1'b1); // start transmit
          #1 check_rx_bd(num_of_bd, data);
          if (((data[15] !== 1) && (num_of_frames != 9)) || // RX BD must be Empty
              ((data[15] !== 0) && (num_of_frames == 9)))   // RX BD must NOT be Empty - RX BD overrun!!!
          begin
            test_fail("Wrong buffer descriptor's ready bit read out from MAC");
            fail = fail + 1;
          end
          wait (MRxDV === 1'b0); // end transmit
          while (((data[15] === 1) && (num_of_frames != 9)) || 
                 ((data[15] === 0) && (num_of_frames == 9)))
          begin
            #1 check_rx_bd(num_of_bd, data);
            @(posedge wb_clk);
          end
          disable check_wait_for_rec3;
          disable set_no_resp3;
          $display("    ->packet received");
          repeat (1) @(posedge wb_clk);
        end
        begin: check_wait_for_rec3
          wait (MRxDV === 1'b1); // start transmit
          wait (MRxDV === 1'b0); // end transmit
          repeat(10) @(posedge mrx_clk);
          repeat(50) @(posedge wb_clk);
          wait (wbm_working == 0);
          disable wait_for_rec3;
          disable set_no_resp3;
          $display("    ->packet NOT received");
        end
      join
      // PACKET checking
      case (num_of_frames)
      0, 3, 5, 7, 8, 10: // correct packet received
      begin
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        check_rx_bd(num_of_bd, data);
        // check RX buffer descriptor of a packet
        if (((data[15:0] !== 16'h4000) && (num_of_bd != 127)) || // without wrap bit
            ((data[15:0] !== 16'h6000) && (num_of_bd == 127)))
        begin
          `TIME; 
          if (num_of_bd != 127)
            $display("*E RX buffer descriptor status is not correct: %0h instead of 4000", data[15:0]);
          else
            $display("*E RX buffer descriptor status is not correct: %0h instead of 6000", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check length of a PACKET
        if (data[31:16] != (i_length + 4))
        begin
          `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                          data[31:16], (i_length + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        check_rx_packet(0, `MEMORY_BASE, (i_length + 4), 1'b0, 1'b0, tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the received packet");
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      1: // correct packet stayed in RX FIFO
      begin
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        check_rx_bd(num_of_bd, data);
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'hC000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h instead of C000", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end
      end
      2: // RX FIFO overrun & previous packet written
      begin
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        check_rx_bd(num_of_bd, data);
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'hC000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h instead of C000", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end

        // Release packet
        #1 wb_slave.cycle_response(`ACK_RESPONSE, 3'h0, 8'h0);
        repeat(128) @(posedge wb_clk);
          $display("    ->previous packet written into MEM");
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        check_rx_bd(num_of_bd, data);
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'h4000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h instead of 4000", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer Error was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer Error was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer Error) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer Error) were set");
          fail = fail + 1;
        end

      end
      4, 6: // RX FIFO overrun
      begin
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        check_rx_bd(num_of_bd, data);
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'hC000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h instead of C000", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end

        // Release packet
        #1 wb_slave.cycle_response(`ACK_RESPONSE, 3'h0, 8'h0);
        repeat(128) @(posedge wb_clk);
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        check_rx_bd(num_of_bd, data);
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'h4040)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h instead of 4040", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_RXE) !== `ETH_INT_RXE)
        begin
          `TIME; $display("*E Interrupt Receive Buffer Error was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer Error was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXE)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer Error) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer Error) were set");
          fail = fail + 1;
        end

      end
      9: // RX BD overrun
      begin
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        check_rx_bd(num_of_bd, data);
        // check RX buffer descriptor of a packet
          // NOT checked since BD value is from first packet - RX BD overrun
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_BUSY) !== `ETH_INT_BUSY)
        begin
          `TIME; $display("*E Interrupt BUSY was not set, interrupt reg: %0h", data);
          test_fail("Interrupt BUSY was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_BUSY)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except BUSY) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except BUSY) were set");
          fail = fail + 1;
        end
      end
      default:
      begin
      end
      endcase
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      num_of_frames = num_of_frames + 1;
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG |
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end



  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test receive packets at one RX BD and                     ////
  ////  check addresses ( 10Mbps ).                               ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 14) //
  begin
    // TEST 14: RECEIVE PACKETS (DELAYED CRC) AT ONE RX BD AND CHECK ADDRESSES ( 10Mbps )
    test_name   = "TEST 14: RECEIVE PACKETS (DELAYED CRC) AT ONE RX BD AND CHECK ADDRESSES ( 10Mbps )";
    `TIME; $display("  TEST 14: RECEIVE PACKETS (DELAYED CRC) AT ONE RX BD AND CHECK ADDRESSES ( 10Mbps )");

    // set 1 RX buffer descriptor (8'h80 - 1) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h7F, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;

    num_of_frames = 0;
    i_length = 64;
    while (num_of_frames < 8)
    begin
      // not detect carrier sense in FD and no collision
      eth_phy.no_carrier_sense_rx_fd_detect(0);
      eth_phy.collision(0);
      case (num_of_frames)
      0: // unicast + PRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h0F;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Unicast packet (delayed CRC) is going to be received with PRO bit (wrap at 1st BD)");
      end
      1: // unicast
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                                   `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h12;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Unicast packet (delayed CRC) is going to be received without PRO bit (wrap at 1st BD)");
      end
      2: // wrong unicast + PRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h31;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hAA02_0304_0507, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    non Unicast packet (delayed CRC) is going to be received with PRO bit (wrap at 1st BD)");
      end
      3: // wrong unicast
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                                   `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h0F;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hAA02_0304_0507, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    non Unicast packet (delayed CRC) is NOT going to be received without PRO bit (wrap at 1st BD)");
      end
      4: // broadcast + PRO + ~BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h84;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet (delayed CRC) is going to be received with PRO & without Reject_BRO bit (wrap at 1st BD)");
      end
      5: // broadcast       + ~BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | `ETH_MODER_DLYCRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h48;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet (delayed CRC) is going to be received without Reject_BRO bit (wrap at 1st BD)");
      end
      6: // broadcast + PRO + BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h30;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet (delayed CRC) is going to be received with PRO & with Reject_BRO bit (wrap at 1st BD)");
      end
      7: // broadcast       + BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG |
                                   `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h04;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet (delayed CRC) is NOT going to be received with Reject_BRO bit (wrap at 1st BD)");
      end
      default:
      begin
      end
      endcase
      // set wrap bit
      set_rx_bd_wrap(127);
      set_rx_bd_empty(127, 127);
      fork
        begin
          #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, (i_length + 4), 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin: wait_for_rece0
          wait (MRxDV === 1'b1); // start transmit
          #1 check_rx_bd(127, data);
          if (data[15] !== 1)
          begin
            test_fail("Wrong buffer descriptor's ready bit read out from MAC");
            fail = fail + 1;
          end
          wait (MRxDV === 1'b0); // end transmit
          while (data[15] === 1)
          begin
            #1 check_rx_bd(127, data);
            @(posedge wb_clk);
          end
          disable check_wait_for_rece0;
          $display("    ->packet received");
          repeat (1) @(posedge wb_clk);
        end
        begin: check_wait_for_rece0
          wait (MRxDV === 1'b1); // start transmit
          wait (MRxDV === 1'b0); // end transmit
          repeat(10) @(posedge mrx_clk);
          repeat(50) @(posedge wb_clk);
          wait (wbm_working == 0);
          disable wait_for_rece0;
          $display("    ->packet NOT received");
        end
      join
      // PACKET checking
      wait (wbm_working == 0);
      check_rx_bd(127, data);
      case (num_of_frames)
      0, 1, 4, 5:
      begin
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'h6000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check length of a PACKET
        if (data[31:16] != (i_length + 4))
        begin
          `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                          data[31:16], (i_length + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        check_rx_packet(0, `MEMORY_BASE, (i_length + 4), 1'b0, 1'b0, tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the received packet");
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      2, 6:
      begin
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'h6080)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check length of a PACKET
        if (data[31:16] != (i_length + 4))
        begin
          `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                          data[31:16], (i_length + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        check_rx_packet(0, `MEMORY_BASE, (i_length + 4), 1'b0, 1'b0, tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the received packet");
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      3, 7:
      begin
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'hE000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end
      end
      default:
      begin
      end
      endcase
      // clear RX buffer descriptor
      clear_rx_bd(127, 127);
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      num_of_frames = num_of_frames + 1;
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test receive packets (delayed CRC) at one RX BD and       ////
  ////  check addresses ( 100Mbps ).                              ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 15) //
  begin
    // TEST 15: RECEIVE PACKETS (DELAYED CRC) AT ONE RX BD AND CHECK ADDRESSES ( 100Mbps )
    test_name   = "TEST 15: RECEIVE PACKETS (DELAYED CRC) AT ONE RX BD AND CHECK ADDRESSES ( 100Mbps )";
    `TIME; $display("  TEST 15: RECEIVE PACKETS (DELAYED CRC) AT ONE RX BD AND CHECK ADDRESSES ( 100Mbps )");

    // set 1 RX buffer descriptor (8'h80 - 1) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h7F, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;

    num_of_frames = 0;
    i_length = 64;
    while (num_of_frames < 8)
    begin
      // not detect carrier sense in FD and no collision
      eth_phy.no_carrier_sense_rx_fd_detect(0);
      eth_phy.collision(0);
      case (num_of_frames)
      0: // unicast + PRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h0F;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Unicast packet (delayed CRC) is going to be received with PRO bit (wrap at 1st BD)");
      end
      1: // unicast + delayed CRC
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG, set delayed CRC
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                                   `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h12;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hAA02_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Unicast packet (delayed CRC) is going to be received without PRO bit (wrap at 1st BD)");
      end
      2: // wrong unicast + PRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h31;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hAA02_0304_0507, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    non Unicast packet (delayed CRC) is going to be received with PRO bit (wrap at 1st BD)");
      end
      3: // wrong unicast
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                                   `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h0F;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hAA02_0304_0507, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    non Unicast packet (delayed CRC) is NOT going to be received without PRO bit (wrap at 1st BD)");
      end
      4: // broadcast + PRO + ~BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h84;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet (delayed CRC) is going to be received with PRO & without Reject_BRO bit (wrap at 1st BD)");
      end
      5: // broadcast       + ~BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | `ETH_MODER_DLYCRCEN,
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h48;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet (delayed CRC) is going to be received without Reject_BRO bit (wrap at 1st BD)");
      end
      6: // broadcast + PRO + BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h30;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet (delayed CRC) is going to be received with PRO & with Reject_BRO bit (wrap at 1st BD)");
      end
      7: // broadcast       + BRO
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // disable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, 32'h0, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // enable RX, set full-duplex mode, NO receive small, NO correct IFG
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG |
                                   `ETH_MODER_BRO | `ETH_MODER_DLYCRCEN, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // set Destination address - Byte 0 sent first
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR1, 32'h0000_AA02, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte /, /, 0, 1 of Dest. addr.
        wait (wbm_working == 0);
        wbm_write(`ETH_MAC_ADDR0, 32'h0304_0506, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Byte 2, 3, 4. 5 of Dest. addr.
        // prepare packet
        st_data = 8'h04;
        set_rx_packet_delayed(0, i_length, 1'b1, 1'b0, 32'hDEAD_BEEF, 48'hFFFF_FFFF_FFFF, 48'h0708_090A_0B0C, 16'hA56A, st_data); // length without CRC
        append_rx_crc_delayed(0, i_length, 1'b0, 1'b0);
        $display("    Broadcast packet (delayed CRC) is NOT going to be received with Reject_BRO bit (wrap at 1st BD)");
      end
      default:
      begin
      end
      endcase
      // set wrap bit
      set_rx_bd_wrap(127);
      set_rx_bd_empty(127, 127);
      fork
        begin
          #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, (i_length + 4), 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin: wait_for_rece1
          wait (MRxDV === 1'b1); // start transmit
          #1 check_rx_bd(127, data);
          if (data[15] !== 1)
          begin
            test_fail("Wrong buffer descriptor's ready bit read out from MAC");
            fail = fail + 1;
          end
          wait (MRxDV === 1'b0); // end transmit
          while (data[15] === 1)
          begin
            #1 check_rx_bd(127, data);
            @(posedge wb_clk);
          end
          disable check_wait_for_rece1;
          $display("    ->packet received");
          repeat (1) @(posedge wb_clk);
        end
        begin: check_wait_for_rece1
          wait (MRxDV === 1'b1); // start transmit
          wait (MRxDV === 1'b0); // end transmit
          repeat(10) @(posedge mrx_clk);
          repeat(50) @(posedge wb_clk);
          wait (wbm_working == 0);
          disable wait_for_rece1;
          $display("    ->packet NOT received");
        end
      join
      // PACKET checking
      wait (wbm_working == 0);
      check_rx_bd(127, data);
      case (num_of_frames)
      0, 1, 4, 5:
      begin
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'h6000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check length of a PACKET
        if (data[31:16] != (i_length + 4))
        begin
          `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                          data[31:16], (i_length + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        check_rx_packet(0, `MEMORY_BASE, (i_length + 4), 1'b0, 1'b0, tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the received packet");
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      2, 6:
      begin
        // check WB INT signal
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'h6080)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check length of a PACKET
        if (data[31:16] != (i_length + 4))
        begin
          `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                          data[31:16], (i_length + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        check_rx_packet(0, `MEMORY_BASE, (i_length + 4), 1'b0, 1'b0, tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the received packet");
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      3, 7:
      begin
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
        if (data[15:0] !== 16'hE000)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
        wait (wbm_working == 0);
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end
      end
      default:
      begin
      end
      endcase
      // clear RX buffer descriptor
      clear_rx_bd(127, 127);
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      num_of_frames = num_of_frames + 1;
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


end   //  for (test_num=start_task; test_num <= end_task; test_num=test_num+1)

end
endtask // test_mac_full_duplex_receive


task test_mac_full_duplex_flow_control;
  input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        bit_start_1;
  integer        bit_end_1;
  integer        bit_start_2;
  integer        bit_end_2;
  integer        num_of_reg;
  integer        num_of_frames;
  integer        num_of_rx_frames;
  integer        num_of_bd;
  integer        i_addr;
  integer        i_data;
  integer        i_length;
  integer        tmp_len;
  integer        tmp_bd;
  integer        tmp_bd_num;
  integer        tmp_data;
  integer        tmp_ipgt;
  integer        test_num;
  integer        rx_len;
  integer        tx_len;
  reg    [31:0]  tx_bd_num;
  reg    [31:0]  rx_bd_num;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_data;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_tmp_data;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        fail;
  integer        speed;
  integer        mac_hi_addr;
  integer        mac_lo_addr;
  reg            frame_started;
  reg            frame_ended;
  reg            wait_for_frame;
  reg    [31:0]  addr;
  reg    [31:0]  data;
  reg    [31:0]  tmp;
  reg    [ 7:0]  st_data;
  reg    [15:0]  max_tmp;
  reg    [15:0]  min_tmp;
  reg            PassAll;
  reg            RxFlow;
  reg            enable_irq_in_rxbd;
  reg    [15:0]  pause_value;
  
begin
// MAC FULL DUPLEX FLOW CONTROL TEST
test_heading("MAC FULL DUPLEX FLOW CONTROL TEST");
$display(" ");
$display("MAC FULL DUPLEX FLOW CONTROL TEST");
fail = 0;

// reset MAC registers
hard_reset;
// set wb slave response
wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

  /*
  TASKS for set and control TX buffer descriptors (also send packet - set_tx_bd_ready):
  -------------------------------------------------------------------------------------
  set_tx_bd 
    (tx_bd_num_start[6:0], tx_bd_num_end[6:0], len[15:0], irq, pad, crc, txpnt[31:0]);
  set_tx_bd_wrap 
    (tx_bd_num_end[6:0]);
  set_tx_bd_ready 
    (tx_bd_num_start[6:0], tx_bd_num_end[6:0]);
  check_tx_bd 
    (tx_bd_num_start[6:0], tx_bd_status[31:0]);
  clear_tx_bd 
    (tx_bd_num_start[6:0], tx_bd_num_end[6:0]);

  TASKS for set and control RX buffer descriptors:
  ------------------------------------------------
  set_rx_bd 
    (rx_bd_num_strat[6:0], rx_bd_num_end[6:0], irq, rxpnt[31:0]);
  set_rx_bd_wrap 
    (rx_bd_num_end[6:0]);
  set_rx_bd_empty 
    (rx_bd_num_strat[6:0], rx_bd_num_end[6:0]);
  check_rx_bd 
    (rx_bd_num_end[6:0], rx_bd_status);
  clear_rx_bd 
    (rx_bd_num_strat[6:0], rx_bd_num_end[6:0]);

  TASKS for set and check TX packets:
  -----------------------------------
  set_tx_packet 
    (txpnt[31:0], len[15:0], eth_start_data[7:0]);
  check_tx_packet 
    (txpnt_wb[31:0], txpnt_phy[31:0], len[15:0], failure[31:0]);

  TASKS for set and check RX packets:
  -----------------------------------
  set_rx_packet 
    (rxpnt[31:0], len[15:0], plus_nibble, d_addr[47:0], s_addr[47:0], type_len[15:0], start_data[7:0]);
  check_rx_packet 
    (rxpnt_phy[31:0], rxpnt_wb[31:0], len[15:0], plus_nibble, successful_nibble, failure[31:0]);

  TASKS for append and check CRC to/of TX packet:
  -----------------------------------------------
  append_tx_crc 
    (txpnt_wb[31:0], len[15:0], negated_crc);
  check_tx_crc 
    (txpnt_phy[31:0], len[15:0], negated_crc, failure[31:0]); 

  TASK for append CRC to RX packet (CRC is checked together with check_rx_packet):
  --------------------------------------------------------------------------------
  append_rx_crc 
    (rxpnt_phy[31:0], len[15:0], plus_nibble, negated_crc);
  */

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  test_mac_full_duplex_flow_control:                          ////
////                                                              ////
////  0: Test                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin

  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test inserts control frames while transmitting normal     ////
  ////  frames. Using 4 TX buffer decriptors ( 10Mbps ).          ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 0) // 
  begin
    // TEST 0: INSERT CONTROL FRM. WHILE TRANSMITTING NORMAL FRM. AT 4 TX BD ( 10Mbps )
    test_name = "TEST 0: INSERT CONTROL FRM. WHILE TRANSMITTING NORMAL FRM. AT 4 TX BD ( 10Mbps )";
    `TIME; $display("  TEST 0: INSERT CONTROL FRM. WHILE TRANSMITTING NORMAL FRM. AT 4 TX BD ( 10Mbps )");

    // reset MAC completely
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);
    max_tmp = 0;
    min_tmp = 0;
    // set 4 TX buffer descriptors - must be set before TX enable
    wbm_write(`ETH_TX_BD_NUM, 32'h4, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, padding and CRC appending
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_PAD | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX flow control
    wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_TXFLOW, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // Set MAC address
    mac_hi_addr = 32'h00000001;
    mac_lo_addr = 32'h02030405;
    wbm_write(`ETH_MAC_ADDR1, mac_hi_addr, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    wbm_write(`ETH_MAC_ADDR0, mac_lo_addr, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h34;
    set_tx_packet(`MEMORY_BASE, (max_tmp - 4), st_data); // length without CRC. Writing data to the memory
    st_data = 8'h56;
    set_tx_packet((`MEMORY_BASE + max_tmp), (max_tmp - 4), st_data); // length without CRC. Writing data to the memory
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;
  
    frame_started = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    i_length = 0; // 0;
    // Initialize one part of memory with data of control packet
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h0), 32'h0180c200, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h4), {16'h0001, mac_hi_addr[15:0]}, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h8), mac_lo_addr, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'hc), 32'h88080001, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h10), 32'h11110000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h14), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h18), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h1c), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h20), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h24), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h28), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h2c), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h30), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h34), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h38), 32'h00000000, 4'hF);
//    append_tx_crc(`MEMORY_BASE + 2 * max_tmp, 60, 0);       // CRC is appended after the data
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // In the following section, control frame will be sent while no other transmission is in progress.//
    // TXC interrupt won't be unmasked.                                                                //
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // check interrupts
    wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(data)
      begin
        test_fail("IRQ already pending!");
        fail = fail + 1;
        `TIME; $display("*E IRQ already pending!");
      end
    if (wb_int)
    begin
      test_fail("WB INT signal should not be set!");
      fail = fail + 1;
      `TIME; $display("*E WB INT signal should not be set!");
    end
    // first destination address on ethernet PHY
    eth_phy.set_tx_mem_addr(0);
    // Request sending the control frame with pause value = 0x1111
    wbm_write(`ETH_TX_CTRL, `ETH_TX_CTRL_TXPAUSERQ | 32'h1111, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // wait for transmission to come over
    wait (MTxEn === 1'b1); // start transmit
    wait (MTxEn === 1'b0); // end transmit
    repeat(10) @ (posedge wb_clk);  // wait some time
    repeat(10) @ (posedge mtx_clk); // wait some time
    // check interrupt
    wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(data !== `ETH_INT_TXC)
      begin
        test_fail("TXC IRQ should be set!");
        fail = fail + 1;
        `TIME; $display("*E TXC IRQ should be set!");
      end
    if (wb_int)
    begin
      test_fail("WB INT signal should not be set because TXC irq is masked!");
      fail = fail + 1;
      `TIME; $display("*E WB INT signal should not be set because TXC irq is masked!");
    end
    // Clear TXC interrupt
    wbm_write(`ETH_INT, `ETH_INT_TXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (wb_int)
    begin
      test_fail("WB INT signal should not be set!");
      fail = fail + 1;
      `TIME; $display("*E WB INT signal should not be set!");
    end
    // check transmited TX packet
    check_tx_packet((`MEMORY_BASE + 2 * max_tmp), 0, 60, tmp);
    if (tmp > 0)
    begin
      $display("Wrong data of the transmitted packet");
      test_fail("Wrong data of the transmitted packet");
      fail = fail + 1;
    end
    // check transmited TX packet CRC
    #1 check_tx_crc(0, 60, 1'b0, tmp); // length without CRC
    if (tmp > 0)
    begin
      $display("Wrong CRC of the transmitted packet");
      test_fail("Wrong CRC of the transmitted packet");
      fail = fail + 1;
    end
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // In the following section, control frame will be sent while no other transmission is in progress.//
    // TXC interrupt is unmasked.                                                                      //
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // unmask all interrupts
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check interrupts
    wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(data)
      begin
        test_fail("IRQ already pending!");
        fail = fail + 1;
        `TIME; $display("*E IRQ already pending!");
      end
    if (wb_int)
    begin
      test_fail("WB INT signal should not be set!");
      fail = fail + 1;
      `TIME; $display("*E WB INT signal should not be set!");
    end
    // unmask only TXC interrupts
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // first destination address on ethernet PHY
    eth_phy.set_tx_mem_addr(0);
    // Request sending the control frame with pause value = 0x2222
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h10), 32'h22220000, 4'hF);  // Just for data test
    wbm_write(`ETH_TX_CTRL, `ETH_TX_CTRL_TXPAUSERQ | 32'h2222, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // wait for transmit to come over
    wait (MTxEn === 1'b1); // start transmit
    wait (MTxEn === 1'b0); // end transmit
    repeat(10) @ (posedge wb_clk);  // wait some time
    repeat(10) @ (posedge mtx_clk); // wait some time
    // check INT
    wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(data !== `ETH_INT_TXC)
      begin
        test_fail("TXC IRQ should be set!");
        fail = fail + 1;
        `TIME; $display("*E TXC IRQ should be set!");
      end
    if (!wb_int)
    begin
      test_fail("WB INT signal should be set!");
      fail = fail + 1;
      `TIME; $display("*E WB INT signal should be set!");
    end
    // Clear TXC interrupt
    wbm_write(`ETH_INT, `ETH_INT_TXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (wb_int)
    begin
      test_fail("WB INT signal should not be set!");
      fail = fail + 1;
      `TIME; $display("*E WB INT signal should not be set!");
    end
    // check transmited TX packet
    check_tx_packet((`MEMORY_BASE + 2 * max_tmp), 0, 60, tmp);
    if (tmp > 0)
    begin
      $display("Wrong data of the transmitted packet");
      test_fail("Wrong data of the transmitted packet");
      fail = fail + 1;
    end
    // check transmited TX packet CRC
    #1 check_tx_crc(0, 60, 1'b0, tmp); // length without CRC
    if (tmp > 0)
    begin
      $display("Wrong CRC of the transmitted packet");
      test_fail("Wrong CRC of the transmitted packet");
      fail = fail + 1;
    end
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // In the following section, control frame sending is requested while no other transmission        //
    // is in progress. TXC interrupt is unmasked.                                                      //
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // unmask all interrupts
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(data)
      begin
        test_fail("IRQ already pending!");
        fail = fail + 1;
        `TIME; $display("*E IRQ already pending!");
      end
    if (wb_int)
    begin
      test_fail("WB INT signal should not be set!");
      fail = fail + 1;
      `TIME; $display("*E WB INT signal should not be set!");
    end
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // In the following section, control frame request and data send request are both set. At the      //
    // beginning control frame request will be faster than data send request, later the opposite.      //
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    for (i=0; i<32; i=i+1)
    begin
      // Request sending the control frame with pause value = 0x5678
      set_tx_bd(0, 0, 16'h100, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE)); // irq, pad, crc
      set_tx_bd_wrap(0);
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      set_tx_bd_ready(0, 0);
      // wait for transmission to start  
      wait (MTxEn === 1'b1); // start transmit
      repeat(i) @ (posedge mtx_clk);  // We need to wait some time until TX module starts using the data (preamble stage is over)
      // Send control frame request
      wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h10), {i[3:0], i[3:0], i[3:0], i[3:0], 16'h0}, 4'hF);  // Just for data test
      wbm_write(`ETH_TX_CTRL, `ETH_TX_CTRL_TXPAUSERQ | {16'h0, i[3:0], i[3:0], i[3:0], i[3:0]}, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // wait until transmission is over  
      wait (MTxEn === 1'b0); // Wait until data frame transmission is over
      repeat(10) @ (posedge mtx_clk); // wait some time so status is written
      tmp_len = eth_phy.tx_len; // the length of a packet which was sent out first!!!
      repeat(10) @ (posedge wb_clk);  // wait some time so status is written
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      // check interrupt depending on which packet was sent
      if(tmp_len == 64)  // Control frame
      begin
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if(data !== `ETH_INT_TXC)
        begin
          test_fail("TXC IRQ should be set!");
          fail = fail + 1;
          `TIME; $display("*E TXC IRQ should be set!");
          `TIME; $display("ETH_INT = 0x%0x", data);
        end
      end
      else
      begin
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if(data !== `ETH_INT_TXB)
        begin
          test_fail("TXB IRQ should be set!");
          fail = fail + 1;
          `TIME; $display("*E TXB IRQ should be set!");
          `TIME; $display("ETH_INT = 0x%0x", data);
        end
      end
      // check transmited TX packet
      if(tmp_len == 64)  // Control frame
        check_tx_packet((`MEMORY_BASE + 2 * max_tmp), 0, 60, tmp);
      else
        check_tx_packet((`MEMORY_BASE), 0, 32'h100, tmp);
      if (tmp > 0)
      begin
        $display("Wrong data of the transmitted packet");
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end
      // check transmited TX packet CRC
      if(tmp_len == 64)  // Control frame
        #1 check_tx_crc(0, 60, 1'b0, tmp); // length without CRC
      else
        #1 check_tx_crc(0, 32'h100, 1'b0, tmp); // length without CRC
  
      if (tmp > 0)
      begin
        $display("Wrong CRC of the transmitted packet");
        test_fail("Wrong CRC of the transmitted packet");
        fail = fail + 1;
      end
      // wait for control frame to transmit
      wait (MTxEn === 1'b1); // start transmit of the control frame
      wait (MTxEn === 1'b0); // end transmit of the control frame
      repeat(10) @ (posedge wb_clk);  // wait some time
      repeat(10) @ (posedge mtx_clk); // wait some time so status is written
      // check interrupts  
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if(data !== (`ETH_INT_TXC | `ETH_INT_TXB))
      begin
        test_fail("TXC and TXB IRQ should be set!");
        fail = fail + 1;
        `TIME; $display("*E TXC and TXB IRQ should be set! (ETH_INT=0x%0x)", data);
      end
      if (!wb_int)
      begin
        test_fail("WB INT signal should be set!");
        fail = fail + 1;
        `TIME; $display("*E WB INT signal should be set!");
      end
      // Clear TXC and TXB interrupt
      wbm_write(`ETH_INT, `ETH_INT_TXC | `ETH_INT_TXB, 4'hF, 1, 4'h0, 4'h0);
      if (wb_int)
      begin
        test_fail("WB INT signal should not be set!");
        fail = fail + 1;
        `TIME; $display("*E WB INT signal should not be set!");
      end
      if(tmp_len == 64)  // Control frame
        check_tx_packet((`MEMORY_BASE), 0, 32'h100, tmp);
      else
        check_tx_packet((`MEMORY_BASE + 2 * max_tmp), 0, 60, tmp);
      if (tmp > 0)
      begin
        $display("Wrong data of the transmitted packet");
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end
      // check transmited TX packet CRC
      if(tmp_len == 64)  // Control frame
        #1 check_tx_crc(0, 32'h100, 1'b0, tmp); // length without CRC
      else
        #1 check_tx_crc(0, 60, 1'b0, tmp); // length without CRC
      if (tmp > 0)
      begin
        $display("Wrong CRC of the transmitted packet");
        test_fail("Wrong CRC of the transmitted packet");
        fail = fail + 1;
      end
    end // for loop
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test inserts control frames while transmitting normal     ////
  ////  frames. Using 4 TX buffer decriptors ( 100Mbps ).         ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 1) // 
  begin
    // TEST 1: INSERT CONTROL FRM. WHILE TRANSMITTING NORMAL FRM. AT 4 TX BD ( 100Mbps )
    test_name = "TEST 1: INSERT CONTROL FRM. WHILE TRANSMITTING NORMAL FRM. AT 4 TX BD ( 100Mbps )";
    `TIME; $display("  TEST 1: INSERT CONTROL FRM. WHILE TRANSMITTING NORMAL FRM. AT 4 TX BD ( 100Mbps )");

    // reset MAC completely
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);
    max_tmp = 0;
    min_tmp = 0;
    // set 4 TX buffer descriptors - must be set before TX enable
    wbm_write(`ETH_TX_BD_NUM, 32'h4, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX, set full-duplex mode, padding and CRC appending
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_PAD | `ETH_MODER_FULLD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX flow control
    wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_TXFLOW, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // Set MAC address
    mac_hi_addr = 32'h00000001;
    mac_lo_addr = 32'h02030405;
    wbm_write(`ETH_MAC_ADDR1, mac_hi_addr, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    wbm_write(`ETH_MAC_ADDR0, mac_lo_addr, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h34;
    set_tx_packet(`MEMORY_BASE, (max_tmp - 4), st_data); // length without CRC. Writing data to the memory
    st_data = 8'h56;
    set_tx_packet((`MEMORY_BASE + max_tmp), (max_tmp - 4), st_data); // length without CRC. Writing data to the memory
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;
  
    frame_started = 0;
    num_of_frames = 0;
    num_of_bd = 0;
    i_length = 0; // 0;
    // Initialize one part of memory with data of control packet
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h0), 32'h0180c200, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h4), {16'h0001, mac_hi_addr[15:0]}, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h8), mac_lo_addr, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'hc), 32'h88080001, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h10), 32'h11110000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h14), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h18), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h1c), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h20), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h24), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h28), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h2c), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h30), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h34), 32'h00000000, 4'hF);
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h38), 32'h00000000, 4'hF);
//    append_tx_crc(`MEMORY_BASE + 2 * max_tmp, 60, 0);       // CRC is appended after the data
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // In the following section, control frame will be sent while no other transmission is in progress.//
    // TXC interrupt won't be unmasked.                                                                //
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // check interrupts
    wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(data)
      begin
        test_fail("IRQ already pending!");
        fail = fail + 1;
        `TIME; $display("*E IRQ already pending!");
      end
    if (wb_int)
    begin
      test_fail("WB INT signal should not be set!");
      fail = fail + 1;
      `TIME; $display("*E WB INT signal should not be set!");
    end
    // first destination address on ethernet PHY
    eth_phy.set_tx_mem_addr(0);
    // Request sending the control frame with pause value = 0x1111
    wbm_write(`ETH_TX_CTRL, `ETH_TX_CTRL_TXPAUSERQ | 32'h1111, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // wait for transmission to come over
    wait (MTxEn === 1'b1); // start transmit
    wait (MTxEn === 1'b0); // end transmit
    repeat(10) @ (posedge wb_clk);  // wait some time
    repeat(10) @ (posedge mtx_clk); // wait some time
    // check interrupt
    wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(data !== `ETH_INT_TXC)
      begin
        test_fail("TXC IRQ should be set!");
        fail = fail + 1;
        `TIME; $display("*E TXC IRQ should be set!");
      end
    if (wb_int)
    begin
      test_fail("WB INT signal should not be set because TXC irq is masked!");
      fail = fail + 1;
      `TIME; $display("*E WB INT signal should not be set because TXC irq is masked!");
    end
    // Clear TXC interrupt
    wbm_write(`ETH_INT, `ETH_INT_TXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (wb_int)
    begin
      test_fail("WB INT signal should not be set!");
      fail = fail + 1;
      `TIME; $display("*E WB INT signal should not be set!");
    end
    // check transmited TX packet
    check_tx_packet((`MEMORY_BASE + 2 * max_tmp), 0, 60, tmp);
    if (tmp > 0)
    begin
      $display("Wrong data of the transmitted packet");
      test_fail("Wrong data of the transmitted packet");
      fail = fail + 1;
    end
    // check transmited TX packet CRC
    #1 check_tx_crc(0, 60, 1'b0, tmp); // length without CRC
    if (tmp > 0)
    begin
      $display("Wrong CRC of the transmitted packet");
      test_fail("Wrong CRC of the transmitted packet");
      fail = fail + 1;
    end
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // In the following section, control frame will be sent while no other transmission is in progress.//
    // TXC interrupt is unmasked.                                                                      //
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // unmask all interrupts
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // check interrupts
    wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(data)
      begin
        test_fail("IRQ already pending!");
        fail = fail + 1;
        `TIME; $display("*E IRQ already pending!");
      end
    if (wb_int)
    begin
      test_fail("WB INT signal should not be set!");
      fail = fail + 1;
      `TIME; $display("*E WB INT signal should not be set!");
    end
    // unmask only TXC interrupts
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // first destination address on ethernet PHY
    eth_phy.set_tx_mem_addr(0);
    // Request sending the control frame with pause value = 0x2222
    wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h10), 32'h22220000, 4'hF);  // Just for data test
    wbm_write(`ETH_TX_CTRL, `ETH_TX_CTRL_TXPAUSERQ | 32'h2222, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // wait for transmit to come over
    wait (MTxEn === 1'b1); // start transmit
    wait (MTxEn === 1'b0); // end transmit
    repeat(10) @ (posedge wb_clk);  // wait some time
    repeat(10) @ (posedge mtx_clk); // wait some time
    // check INT
    wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(data !== `ETH_INT_TXC)
      begin
        test_fail("TXC IRQ should be set!");
        fail = fail + 1;
        `TIME; $display("*E TXC IRQ should be set!");
      end
    if (!wb_int)
    begin
      test_fail("WB INT signal should be set!");
      fail = fail + 1;
      `TIME; $display("*E WB INT signal should be set!");
    end
    // Clear TXC interrupt
    wbm_write(`ETH_INT, `ETH_INT_TXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if (wb_int)
    begin
      test_fail("WB INT signal should not be set!");
      fail = fail + 1;
      `TIME; $display("*E WB INT signal should not be set!");
    end
    // check transmited TX packet
    check_tx_packet((`MEMORY_BASE + 2 * max_tmp), 0, 60, tmp);
    if (tmp > 0)
    begin
      $display("Wrong data of the transmitted packet");
      test_fail("Wrong data of the transmitted packet");
      fail = fail + 1;
    end
    // check transmited TX packet CRC
    #1 check_tx_crc(0, 60, 1'b0, tmp); // length without CRC
    if (tmp > 0)
    begin
      $display("Wrong CRC of the transmitted packet");
      test_fail("Wrong CRC of the transmitted packet");
      fail = fail + 1;
    end
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // In the following section, control frame sending is requested while no other transmission        //
    // is in progress. TXC interrupt is unmasked.                                                      //
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // unmask all interrupts
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(data)
      begin
        test_fail("IRQ already pending!");
        fail = fail + 1;
        `TIME; $display("*E IRQ already pending!");
      end
    if (wb_int)
    begin
      test_fail("WB INT signal should not be set!");
      fail = fail + 1;
      `TIME; $display("*E WB INT signal should not be set!");
    end

    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // In the following section, control frame request and data send request are both set. At the      //
    // beginning control frame request will be faster than data send request, later the opposite.      //
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    for (i=0; i<32; i=i+1)
    begin
      // Request sending the control frame with pause value = 0x5678
      set_tx_bd(0, 0, 16'h100, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE)); // irq, pad, crc
      set_tx_bd_wrap(0);
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      set_tx_bd_ready(0, 0);
      // wait for transmission to start  
      wait (MTxEn === 1'b1); // start transmit
      repeat(i) @ (posedge mtx_clk);  // We need to wait some time until TX module starts using the data (preamble stage is over)
      // Send control frame request
      wb_slave.wr_mem((`MEMORY_BASE + 2 * max_tmp + 8'h10), {i[3:0], i[3:0], i[3:0], i[3:0], 16'h0}, 4'hF);  // Just for data test
      wbm_write(`ETH_TX_CTRL, `ETH_TX_CTRL_TXPAUSERQ | {16'h0, i[3:0], i[3:0], i[3:0], i[3:0]}, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // wait until transmission is over  
      wait (MTxEn === 1'b0); // Wait until data frame transmission is over
      repeat(10) @ (posedge mtx_clk); // wait some time so status is written
      tmp_len = eth_phy.tx_len; // the length of a packet which was sent out first!!!
      repeat(10) @ (posedge wb_clk);  // wait some time so status is written
      // first destination address on ethernet PHY
      eth_phy.set_tx_mem_addr(0);
      // check interrupt depending on which packet was sent

      if(tmp_len == 64)  // Control frame
      begin
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if(data !== `ETH_INT_TXC)
        begin
          test_fail("TXC IRQ should be set!");
          fail = fail + 1;
          `TIME; $display("*E TXC IRQ should be set!");
          `TIME; $display("ETH_INT = 0x%0x", data);
        end
      end
      else
      begin
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if(data !== `ETH_INT_TXB)
        begin
          test_fail("TXB IRQ should be set!");
          fail = fail + 1;
          `TIME; $display("*E TXB IRQ should be set!");
          `TIME; $display("ETH_INT = 0x%0x", data);
        end
      end
      // check transmited TX packet
      if(tmp_len == 64)  // Control frame
        check_tx_packet((`MEMORY_BASE + 2 * max_tmp), 0, 60, tmp);
      else
        check_tx_packet((`MEMORY_BASE), 0, 32'h100, tmp);
      if (tmp > 0)
      begin
        $display("Wrong data of the transmitted packet");
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end
      // check transmited TX packet CRC
      if(tmp_len == 64)  // Control frame
        #1 check_tx_crc(0, 60, 1'b0, tmp); // length without CRC
      else
        #1 check_tx_crc(0, 32'h100, 1'b0, tmp); // length without CRC
  
      if (tmp > 0)
      begin
        $display("Wrong CRC of the transmitted packet");
        test_fail("Wrong CRC of the transmitted packet");
        fail = fail + 1;
      end
      // wait for control frame to transmit
      wait (MTxEn === 1'b1); // start transmit of the control frame
      wait (MTxEn === 1'b0); // end transmit of the control frame
      repeat(10) @ (posedge wb_clk);  // wait some time
      repeat(10) @ (posedge mtx_clk); // wait some time so status is written
      // check interrupts  
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if(data !== (`ETH_INT_TXC | `ETH_INT_TXB))
      begin
        test_fail("TXC and TXB IRQ should be set!");
        fail = fail + 1;
        `TIME; $display("*E TXC and TXB IRQ should be set! (ETH_INT=0x%0x)", data);
      end
      if (!wb_int)
      begin
        test_fail("WB INT signal should be set!");
        fail = fail + 1;
        `TIME; $display("*E WB INT signal should be set!");
      end
      // Clear TXC and TXB interrupt
      wbm_write(`ETH_INT, `ETH_INT_TXC | `ETH_INT_TXB, 4'hF, 1, 4'h0, 4'h0);
      if (wb_int)
      begin
        test_fail("WB INT signal should not be set!");
        fail = fail + 1;
        `TIME; $display("*E WB INT signal should not be set!");
      end
      if(tmp_len == 64)  // Control frame
        check_tx_packet((`MEMORY_BASE), 0, 32'h100, tmp);
      else
        check_tx_packet((`MEMORY_BASE + 2 * max_tmp), 0, 60, tmp);
      if (tmp > 0)
      begin
        $display("Wrong data of the transmitted packet");
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end
      // check transmited TX packet CRC
      if(tmp_len == 64)  // Control frame
        #1 check_tx_crc(0, 32'h100, 1'b0, tmp); // length without CRC
      else
        #1 check_tx_crc(0, 60, 1'b0, tmp); // length without CRC
      if (tmp > 0)
      begin
        $display("Wrong CRC of the transmitted packet");
        test_fail("Wrong CRC of the transmitted packet");
        fail = fail + 1;
      end
    end // for loop
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Receive control frames with PASSALL option turned on and  ////
  ////  off. Using only one RX buffer decriptor ( 10Mbps ).       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 2) // 
  begin
    // TEST 2: RECEIVE CONTROL FRAMES WITH PASSALL OPTION TURNED ON AND OFF AT ONE RX BD ( 10Mbps )
    test_name   = "TEST 2: RECEIVE CONTROL FRAMES WITH PASSALL OPTION TURNED ON AND OFF AT ONE RX BD ( 10Mbps )";
    `TIME; $display("  TEST 2: RECEIVE CONTROL FRAMES WITH PASSALL OPTION TURNED ON AND OFF AT ONE RX BD ( 10Mbps )");

    // unmask interrupts
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set 1 RX buffer descriptor (8'h80 - 1) - must be set before RX enable
    wbm_write(`ETH_TX_BD_NUM, 32'h7F, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, NO receive small, NO correct IFG
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX_FLOW control
    wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_RXFLOW, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare one packet of 100 bytes long
//    st_data = 8'h1A;
//    set_rx_packet(64, 100, 1'b0, 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E, st_data); 
//    append_rx_crc (64, 100, 1'b0, 1'b0); // CRC for data packet
    st_data = 8'h01;
    set_tx_packet(`MEMORY_BASE + 64, 100, 8'h01); // length without CRC
    set_tx_bd(0, 0, 100, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + 64));
    set_tx_bd_wrap(0);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end

    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;

    // RXB and RXC interrupts masked
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // Test irq logic while RXB and RXC interrupts are masked. IRQ in RxBD is cleared
    for (i=0; i<3; i=i+1)
    begin
      pause_value = i+2;
      set_rx_control_packet(0, pause_value);  // CRC already appended
      case (i)
      0: // PASSALL = 0, RXFLOW = 1, IRQ in RxBD = 1
      begin
        PassAll=0; RxFlow=1; enable_irq_in_rxbd=1;
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // Set PASSALL = 0 and RXFLOW = 0
        wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_RXFLOW, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      1: // PASSALL = 1, RXFLOW = 0, IRQ in RxBD = 1
      begin
        PassAll=1; RxFlow=0; enable_irq_in_rxbd=1;
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // Set PASSALL = 0 and RXFLOW = 0
        wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_PASSALL, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      2: // PASSALL = 1, RXFLOW = 0, IRQ in RxBD = 0
      begin
        PassAll=1; RxFlow=0; enable_irq_in_rxbd=0;
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b0, `MEMORY_BASE);
        // Set PASSALL = 0 and RXFLOW = 0
        wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_PASSALL, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      default: 
      begin
        $display("*E We should never get here !!!");
        test_fail("We should never get here !!!");
        fail = fail + 1;
      end
      endcase
      // not detect carrier sense in FD and no collision
      eth_phy.no_carrier_sense_rx_fd_detect(0);
      eth_phy.collision(0);
      // set wrap bit and empty bit
      set_rx_bd_wrap(127);
      set_rx_bd_empty(127, 127);
      // transmit
      fork
        begin
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, 64, 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin
          wait (MRxDV === 1'b1); // start transmit
          #1 check_rx_bd(127, data);          
          if (data[15] !== 1)
          begin
            $display("*E Wrong buffer descriptor's ready bit read out from MAC");
            test_fail("Wrong buffer descriptor's ready bit read out from MAC");
            fail = fail + 1;
          end
          wait (MRxDV === 1'b0); // received pause frame
          repeat(5) @(posedge mrx_clk);  // Wait some time so pause is activated.
          repeat(5) @(posedge mtx_clk);  // Wait some time so pause is activated.
          set_tx_bd_ready(0, 0); // Request sending the data. Data should not be sent when pause frame was received
                                 // and RxFlow enabled.
          // When we exit the while loop, status frame is received
          repeat(`ETH_TX_FIFO_DEPTH) @(eth_ma_wb_ack_i);  // Waiting until TX fifo is filled.
          repeat(10) @(posedge mtx_clk);  // Wait some time for tx start.
        end
      join
      #1 check_rx_bd(127, data);
      // Checking buffer descriptor
      if(PassAll)
      begin
        if(enable_irq_in_rxbd)
        begin
          if(data !== 32'h406100)    // Rx BD must not be marked as EMPTY (control frame is received)
          begin
            $display("*E Rx BD is not OK. Control frame should be received because PASSALL bit is 1");
            $display("RxBD = 0x%0x", data);
            test_fail("Rx BD is not OK. Control frame should be received because PASSALL bit is 1");
            fail = fail + 1;
          end
        end
        else
        begin
          if(data !== 32'h402100)    // Rx BD must not be marked as EMPTY (control frame is received)
          begin
            $display("*E Rx BD is not OK. Control frame should be received because PASSALL bit is 1");
            $display("RxBD = 0x%0x", data);
            test_fail("Rx BD is not OK. Control frame should be received because PASSALL bit is 1");
            fail = fail + 1;
          end
        end
      end
      else
      begin
        if(data !== 32'he000)    // Rx BD must be marked as EMPTY (no packet received)
        begin
          $display("*E Rx BD should be marked as EMPTY because a control frame was received while PASSALL bit is 0");
          $display("RxBD = 0x%0x", data);
          test_fail("Rx BD should be marked as EMPTY because a control frame was received while PASSALL bit is 0");
          fail = fail + 1;
        end
      end
      // Checking if interrupt was generated
      if (wb_int)
      begin
        `TIME; $display("*E WB INT signal should not be set because both RXB and RXC interrupts are masked");
        test_fail("WB INT signal should not be set because both RXB and RXC interrupts are masked");
        fail = fail + 1;
      end
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if(RxFlow)
      begin
        if(data !== (`ETH_INT_RXC))
        begin
          test_fail("RXC is not set or multiple IRQs active!");
          fail = fail + 1;
          `TIME; $display("*E RXC is not set or multiple IRQs active! (ETH_INT=0x%0x)", data);
        end
        // Clear RXC interrupt
        wbm_write(`ETH_INT, `ETH_INT_RXC, 4'hF, 1, 4'h0, 4'h0);
      end
      else if(enable_irq_in_rxbd)
      begin
        if(data !== (`ETH_INT_RXB))
        begin
          test_fail("RXB is not set or multiple IRQs active!");
          fail = fail + 1;
          `TIME; $display("*E RXB is not set or multiple IRQs active! (ETH_INT=0x%0x)", data);
        end
        // Clear RXC interrupt
        wbm_write(`ETH_INT, `ETH_INT_RXB, 4'hF, 1, 4'h0, 4'h0);
      end
      else
      begin
        if(data !== 0)
        begin
          test_fail("Some IRQs is active!");
          fail = fail + 1;
          `TIME; $display("*E Some IRQs is active! (ETH_INT=0x%0x)", data);
        end
      end
      if(RxFlow)
        begin
          if(MTxEn)   // If pause frame was received OK, transmission of the data packet should not start
            begin
              `TIME; $display("*E Transmission should not be started because pause frame was received.");
              test_fail("Transmission should not be started because pause frame was received.");
              fail = fail + 1;
            end
          while(pause_value)
            begin
              pause_value=pause_value-1;
              repeat(2*64) @(posedge mtx_clk);  // Wait for the time needed for the pause (1 slot).
              if((!pause_value) && (!MTxEn))        // Transmission should be enabled now.
                begin
                  `TIME; $display("*E Transmission should be started because pause passed.");
                  test_fail("Transmission should be started because pause passed.");
                  fail = fail + 1;
                end
              else if((pause_value) && (MTxEn))     // Transmission should not be enabled now.
                begin
                  `TIME; $display("*E Transmission should still be paused.");
                  test_fail("Transmission should still be paused.");
                  fail = fail + 1;
                end
            end
        end
      else
        begin
          if(!MTxEn)   // Pause frame was not received because RxFlow is turned off.
            begin
              `TIME; $display("*E Transmission should be started because pause frame was not received (RxFlow=0).");
              test_fail("Transmission should be started because pause frame was not received (RxFlow=0).");
              fail = fail + 1;
            end
        end
      wait(wb_int);   // Wait antil frame transmission is over and irq generated
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if(data !== (`ETH_INT_TXB))
        begin
          test_fail("TXB is not set or multiple IRQs active!");
          fail = fail + 1;
          `TIME; $display("*E TXB is not set or multiple IRQs active! (ETH_INT=0x%0x)", data);
        end
        // Clear TXB interrupt
        wbm_write(`ETH_INT, `ETH_INT_TXB, 4'hF, 1, 4'h0, 4'h0);
    end
    // End: Test is irq is set while RXB and RXC interrupts are masked.

    // Now all interrupts are unmasked. Performing tests again.
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    for (i=0; i<4; i=i+1)
    begin
      pause_value = i+1;
      set_rx_control_packet(0, pause_value);  // CRC already appended
      case (i)
      0: // PASSALL = 0, RXFLOW = 0
      begin
        PassAll=0; RxFlow=0;
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // Set PASSALL = 0 and RXFLOW = 0
        wbm_write(`ETH_CTRLMODER, 0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      1: // PASSALL = 0, RXFLOW = 1
      begin
        PassAll=0; RxFlow=1;
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // Set PASSALL = 0 and RXFLOW = 0
        wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_RXFLOW, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      2: // PASSALL = 1, RXFLOW = 0
      begin
        PassAll=1; RxFlow=0;
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // Set PASSALL = 0 and RXFLOW = 0
        wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_PASSALL, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      default: // 3: PASSALL = 1, RXFLOW = 1
      begin
        PassAll=1; RxFlow=1;
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // Set PASSALL = 1 and RXFLOW = 1
        wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_PASSALL | `ETH_CTRLMODER_RXFLOW, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      endcase
      // not detect carrier sense in FD and no collision
      eth_phy.no_carrier_sense_rx_fd_detect(0);
      eth_phy.collision(0);
      // set wrap bit and empty bit
      set_rx_bd_wrap(127);
      set_rx_bd_empty(127, 127);
      // transmit
      fork
        begin
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, 64, 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin
          #1 check_rx_bd(127, data);
          wait (MRxDV === 1'b1); // start transmit
          #1 check_rx_bd(127, data);          
          if (data[15] !== 1)
          begin
            $display("*E Wrong buffer descriptor's ready bit read out from MAC");
            test_fail("Wrong buffer descriptor's ready bit read out from MAC");
            fail = fail + 1;
          end
          wait (MRxDV === 1'b0); // end transmit
          repeat(50) @(posedge mrx_clk);  // Wait some time so frame is received and
          repeat (100) @(posedge wb_clk); // status/irq is written.

          if(RxFlow)    // Waiting x slot times before continuing so pause is deactivated.
            repeat(64 * 2 * pause_value) @(posedge mrx_clk);
        end
      join
      #1 check_rx_bd(127, data);
      // Checking buffer descriptor
      if(PassAll)
      begin
        if(data !== 32'h406100)    // Rx BD must not be marked as EMPTY (control frame is received)
        begin
          $display("*E Rx BD is not OK. Control frame should be received because PASSALL bit is 1");
          $display("RxBD = 0x%0x", data);
          test_fail("Rx BD is not OK. Control frame should be received because PASSALL bit is 1");
          fail = fail + 1;
        end
      end
      else
      begin
        if(data !== 32'he000)    // Rx BD must be marked as EMPTY (no packet received)
        begin
          $display("*E Rx BD should be marked as EMPTY because a control frame was received while PASSALL bit is 0");
          $display("RxBD = 0x%0x", data);
          test_fail("Rx BD should be marked as EMPTY because a control frame was received while PASSALL bit is 0");
          fail = fail + 1;
        end
      end
      // Checking if interrupt was generated
      if(RxFlow || PassAll)
      begin
        if (!wb_int)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if(RxFlow)
      begin
        if(data !== (`ETH_INT_RXC))
        begin
          test_fail("RXC is not set or multiple IRQs active!");
          fail = fail + 1;
          `TIME; $display("*E RXC is not set or multiple IRQs active! (ETH_INT=0x%0x)", data);
        end
        // Clear RXC interrupt
        wbm_write(`ETH_INT, `ETH_INT_RXC, 4'hF, 1, 4'h0, 4'h0);
      end
      else if(PassAll)
      begin
        if(data !== (`ETH_INT_RXB))
        begin
          test_fail("RXB is not set or multiple IRQs active!");
          fail = fail + 1;
          `TIME; $display("*E RXB is not set or multiple IRQs active! (ETH_INT=0x%0x)", data);
        end
        // Clear RXB interrupt
        wbm_write(`ETH_INT, `ETH_INT_RXB, 4'hF, 1, 4'h0, 4'h0);
      end
      else
      begin
        if(data !== 0)
        begin
          test_fail("No interrupt should be set!");
          fail = fail + 1;
          `TIME; $display("*E No interrupt should be set! (ETH_INT=0x%0x)", data);
        end
      end
    end
    // disable RX
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Receive control frames with PASSALL option turned on and  ////
  ////  off. Using only one RX buffer decriptor ( 100Mbps ).      ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 3) // 
  begin
    // TEST 3: RECEIVE CONTROL FRAMES WITH PASSALL OPTION TURNED ON AND OFF AT ONE RX BD ( 100Mbps )
    test_name   = "TEST 3: RECEIVE CONTROL FRAMES WITH PASSALL OPTION TURNED ON AND OFF AT ONE RX BD ( 100Mbps )";
    `TIME; $display("  TEST 3: RECEIVE CONTROL FRAMES WITH PASSALL OPTION TURNED ON AND OFF AT ONE RX BD ( 100Mbps )");

    // unmask interrupts
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set 1 RX buffer descriptor (8'h80 - 1) - must be set before RX enable
    wbm_write(`ETH_TX_BD_NUM, 32'h7F, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, NO receive small, NO correct IFG
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX_FLOW control
    wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_RXFLOW, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare one packet of 100 bytes long
//    st_data = 8'h1A;
//    set_rx_packet(64, 100, 1'b0, 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E, st_data); 
//    append_rx_crc (64, 100, 1'b0, 1'b0); // CRC for data packet
    st_data = 8'h01;
    set_tx_packet(`MEMORY_BASE + 64, 100, 8'h01); // length without CRC
    set_tx_bd(0, 0, 100, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + 64));
    set_tx_bd_wrap(0);
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end

    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;

    // RXB and RXC interrupts masked
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // Test irq logic while RXB and RXC interrupts are masked. IRQ in RxBD is cleared
    for (i=0; i<3; i=i+1)
    begin
      pause_value = i+2;
      set_rx_control_packet(0, pause_value);  // CRC already appended
      // choose generating carrier sense and collision for first and last 64 lengths of frames
      case (i)
      0: // PASSALL = 0, RXFLOW = 1, IRQ in RxBD = 1
      begin
        PassAll=0; RxFlow=1; enable_irq_in_rxbd=1;
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // Set PASSALL = 0 and RXFLOW = 0
        wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_RXFLOW, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      1: // PASSALL = 1, RXFLOW = 0, IRQ in RxBD = 1
      begin
        PassAll=1; RxFlow=0; enable_irq_in_rxbd=1;
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // Set PASSALL = 0 and RXFLOW = 0
        wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_PASSALL, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      2: // PASSALL = 1, RXFLOW = 0, IRQ in RxBD = 0
      begin
        PassAll=1; RxFlow=0; enable_irq_in_rxbd=0;
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b0, `MEMORY_BASE);
        // Set PASSALL = 0 and RXFLOW = 0
        wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_PASSALL, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      default: 
      begin
        `TIME; $display("*E We should never get here !!!");
        test_fail("We should never get here !!!");
        fail = fail + 1;
      end
      endcase
      // not detect carrier sense in FD and no collision
      eth_phy.no_carrier_sense_rx_fd_detect(0);
      eth_phy.collision(0);
      // set wrap bit and empty bit
      set_rx_bd_wrap(127);
      set_rx_bd_empty(127, 127);
      // transmit
      fork
        begin
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, 64, 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin
          wait (MRxDV === 1'b1); // start transmit
          #1 check_rx_bd(127, data);          
          if (data[15] !== 1)
          begin
            `TIME; $display("*E Wrong buffer descriptor's ready bit read out from MAC");
            test_fail("Wrong buffer descriptor's ready bit read out from MAC");
            fail = fail + 1;
          end
          wait (MRxDV === 1'b0); // received pause frame
          repeat(5) @(posedge mrx_clk);  // Wait some time so pause is activated.
          repeat(5) @(posedge mtx_clk);  // Wait some time so pause is activated.
          set_tx_bd_ready(0, 0); // Request sending the data. Data should not be sent when pause frame was received
                                 // and RxFlow enabled.
          // When we exit the while loop, status frame is received
          repeat(`ETH_TX_FIFO_DEPTH) @(eth_ma_wb_ack_i);  // Waiting until TX fifo is filled.
          repeat(10) @(posedge mtx_clk);  // Wait some time for tx start.
        end
      join
      #1 check_rx_bd(127, data);
      // Checking buffer descriptor
      if(PassAll)
      begin
        if(enable_irq_in_rxbd)
        begin
          if(data !== 32'h406100)    // Rx BD must not be marked as EMPTY (control frame is received)
          begin
            `TIME; $display("*E Rx BD is not OK. Control frame should be received because PASSALL bit is 1");
            $display("RxBD = 0x%0x", data);
            test_fail("Rx BD is not OK. Control frame should be received because PASSALL bit is 1");
            fail = fail + 1;
          end
        end
        else
        begin
          if(data !== 32'h402100)    // Rx BD must not be marked as EMPTY (control frame is received)
          begin
            `TIME; $display("*E Rx BD is not OK. Control frame should be received because PASSALL bit is 1");
            $display("RxBD = 0x%0x", data);
            test_fail("Rx BD is not OK. Control frame should be received because PASSALL bit is 1");
            fail = fail + 1;
          end
        end
      end
      else
      begin
        if(data !== 32'he000)    // Rx BD must be marked as EMPTY (no packet received)
        begin
          `TIME; $display("*E Rx BD should be marked as EMPTY because a control frame was received while PASSALL bit is 0");
          $display("RxBD = 0x%0x", data);
          test_fail("Rx BD should be marked as EMPTY because a control frame was received while PASSALL bit is 0");
          fail = fail + 1;
        end
      end
      // Checking if interrupt was generated
      if (wb_int)
      begin
        `TIME; $display("*E WB INT signal should not be set because both RXB and RXC interrupts are masked");
        test_fail("WB INT signal should not be set because both RXB and RXC interrupts are masked");
        fail = fail + 1;
      end
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if(RxFlow)
      begin
        if(data !== (`ETH_INT_RXC))
        begin
          test_fail("RXC is not set or multiple IRQs active!");
          fail = fail + 1;
          `TIME; $display("*E RXC is not set or multiple IRQs active! (ETH_INT=0x%0x)", data);
        end
        // Clear RXC interrupt
        wbm_write(`ETH_INT, `ETH_INT_RXC, 4'hF, 1, 4'h0, 4'h0);
      end
      else if(enable_irq_in_rxbd)
      begin
        if(data !== (`ETH_INT_RXB))
        begin
          test_fail("RXB is not set or multiple IRQs active!");
          fail = fail + 1;
          `TIME; $display("*E RXB is not set or multiple IRQs active! (ETH_INT=0x%0x)", data);
        end
        // Clear RXC interrupt
        wbm_write(`ETH_INT, `ETH_INT_RXB, 4'hF, 1, 4'h0, 4'h0);
      end
      else
      begin
        if(data !== 0)
        begin
          test_fail("Some IRQs is active!");
          fail = fail + 1;
          `TIME; $display("*E Some IRQs is active! (ETH_INT=0x%0x)", data);
        end
      end
      if(RxFlow)
        begin
          if(MTxEn)   // If pause frame was received OK, transmission of the data packet should not start
            begin
              `TIME; $display("*E Transmission should not be started because pause frame was received.");
              test_fail("Transmission should not be started because pause frame was received.");
              fail = fail + 1;
            end
          while(pause_value)
            begin
              pause_value=pause_value-1;
              repeat(2*64) @(posedge mtx_clk);  // Wait for the time needed for the pause (1 slot).
              if((!pause_value) && (!MTxEn))        // Transmission should be enabled now.
                begin
                  `TIME; $display("*E Transmission should be started because pause passed.");
                  test_fail("Transmission should be started because pause passed.");
                  fail = fail + 1;
                end
              else if((pause_value) && (MTxEn))     // Transmission should not be enabled now.
                begin
                  `TIME; $display("*E Transmission should still be paused.");
                  test_fail("Transmission should still be paused.");
                  fail = fail + 1;
                end
            end
        end
      else
        begin
          #200; 
          if(!MTxEn)   // Pause frame was not received because RxFlow is turned off.
            begin
              `TIME; $display("*E Transmission should be started because pause frame was not received (RxFlow=0).");
              test_fail("Transmission should be started because pause frame was not received (RxFlow=0).");
              fail = fail + 1;
            end
        end
      wait(wb_int);   // Wait antil frame transmission is over and irq generated
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if(data !== (`ETH_INT_TXB))
        begin
          test_fail("TXB is not set or multiple IRQs active!");
          fail = fail + 1;
          `TIME; $display("*E TXB is not set or multiple IRQs active! (ETH_INT=0x%0x)", data);
        end
        // Clear TXB interrupt
        wbm_write(`ETH_INT, `ETH_INT_TXB, 4'hF, 1, 4'h0, 4'h0);
    end
    // End: Test is irq is set while RXB and RXC interrupts are masked.

    // Now all interrupts are unmasked. Performing tests again.
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    for (i=0; i<4; i=i+1)
    begin
      pause_value = i+1;
      set_rx_control_packet(0, pause_value);  // CRC already appended
      // choose generating carrier sense and collision for first and last 64 lengths of frames
      case (i)
      0: // PASSALL = 0, RXFLOW = 0
      begin
        PassAll=0; RxFlow=0;
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // Set PASSALL = 0 and RXFLOW = 0
        wbm_write(`ETH_CTRLMODER, 0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      1: // PASSALL = 0, RXFLOW = 1
      begin
        PassAll=0; RxFlow=1;
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // Set PASSALL = 0 and RXFLOW = 0
        wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_RXFLOW, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      2: // PASSALL = 1, RXFLOW = 0
      begin
        PassAll=1; RxFlow=0;
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // Set PASSALL = 0 and RXFLOW = 0
        wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_PASSALL, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      default: // 3: PASSALL = 1, RXFLOW = 1
      begin
        PassAll=1; RxFlow=1;
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, `MEMORY_BASE);
        // Set PASSALL = 1 and RXFLOW = 1
        wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_PASSALL | `ETH_CTRLMODER_RXFLOW, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      endcase
      // not detect carrier sense in FD and no collision
      eth_phy.no_carrier_sense_rx_fd_detect(0);
      eth_phy.collision(0);
      // set wrap bit and empty bit
      set_rx_bd_wrap(127);
      set_rx_bd_empty(127, 127);
      // transmit
      fork
        begin
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, 64, 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin
          #1 check_rx_bd(127, data);
          wait (MRxDV === 1'b1); // start transmit
          #1 check_rx_bd(127, data);          
          if (data[15] !== 1)
          begin
            $display("*E Wrong buffer descriptor's ready bit read out from MAC");
            test_fail("Wrong buffer descriptor's ready bit read out from MAC");
            fail = fail + 1;
          end
          wait (MRxDV === 1'b0); // end transmit
          repeat(50) @(posedge mrx_clk);  // Wait some time so frame is received and
          repeat (100) @(posedge wb_clk); // status/irq is written.

          if(RxFlow)    // Waiting x slot times before continuing so pause is deactivated.
            repeat(64 * 2 * pause_value) @(posedge mrx_clk);
        end
      join
      #1 check_rx_bd(127, data);
      // Checking buffer descriptor
      if(PassAll)
      begin
        if(data !== 32'h406100)    // Rx BD must not be marked as EMPTY (control frame is received)
        begin
          `TIME; $display("*E Rx BD is not OK. Control frame should be received because PASSALL bit is 1");
          $display("RxBD = 0x%0x", data);
          test_fail("Rx BD is not OK. Control frame should be received because PASSALL bit is 1");
          fail = fail + 1;
        end
      end
      else
      begin
        if(data !== 32'he000)    // Rx BD must be marked as EMPTY (no packet received)
        begin
          `TIME; $display("*E Rx BD should be marked as EMPTY because a control frame was received while PASSALL bit is 0");
          $display("RxBD = 0x%0x", data);
          test_fail("Rx BD should be marked as EMPTY because a control frame was received while PASSALL bit is 0");
          fail = fail + 1;
        end
      end
      // Checking if interrupt was generated

      if(RxFlow | PassAll)
      begin
        if (!wb_int)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if(RxFlow)
      begin
        if(data !== (`ETH_INT_RXC))
        begin
          test_fail("RXC is not set or multiple IRQs active!");
          fail = fail + 1;
          `TIME; $display("*E RXC is not set or multiple IRQs active! (ETH_INT=0x%0x)", data);
        end
        // Clear RXC interrupt
        wbm_write(`ETH_INT, `ETH_INT_RXC, 4'hF, 1, 4'h0, 4'h0);
      end
      else if(PassAll)
      begin
        if(data !== (`ETH_INT_RXB))
        begin
          test_fail("RXB is not set or multiple IRQs active!");
          fail = fail + 1;
          `TIME; $display("*E RXB is not set or multiple IRQs active! (ETH_INT=0x%0x)", data);
        end
        // Clear RXB interrupt
        wbm_write(`ETH_INT, `ETH_INT_RXB, 4'hF, 1, 4'h0, 4'h0);
      end
      else
      begin
        if(data !== 0)
        begin
          test_fail("No interrupt should be set!");
          fail = fail + 1;
          `TIME; $display("*E No interrupt should be set! (ETH_INT=0x%0x)", data);
        end
      end
    end
    // disable RX
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Random receive and transmit frames at one TX and          ////
  ////  one RX buffer decriptor ( 10Mbps ).                       ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 4) // 
  begin
    // TEST 4: RANDOM RECEIVE AND TRANSMIT FRAMES AT ONE TX AND ONE RX BD ( 10Mbps )
    test_name   = "TEST 4: RANDOM RECEIVE AND TRANSMIT FRAMES AT ONE TX AND ONE RX BD ( 10Mbps )";
    `TIME; $display("  TEST 4: RANDOM RECEIVE AND TRANSMIT FRAMES AT ONE TX AND ONE RX BD ( 10Mbps )");

    // unmask interrupts
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set 1 TX and 1 RX buffer descriptor (8'h01) - must be set before RX enable
    wbm_write(`ETH_TX_BD_NUM, 32'h01, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, NO receive small, NO correct IFG
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable flow control

    wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_PASSALL | `ETH_CTRLMODER_RXFLOW | `ETH_CTRLMODER_TXFLOW, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare one RX and one TX packet of 100 bytes long
    rx_len = 100; // length of frame without CRC
    st_data = 8'h1A;
    set_rx_packet(200, rx_len, 1'b0, 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E, st_data); 
    append_rx_crc (200, rx_len, 1'b0, 1'b0); // CRC for data packet
    tx_len = 64; // length of frame without CRC
    st_data = 8'h01;
    set_tx_packet(`MEMORY_BASE + 64, tx_len, st_data); // length without CRC
    // set TX and RX Buffer Descriptors 
    tx_bd_num = 0; // tx BDs go from 0 to 0
    rx_bd_num = 1; // rx BDs go from 1 to 1
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end

    // set EQUAL mrx_clk to mtx_clk!
//    eth_phy.set_mrx_equal_mtx = 1'b1;
    
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;

    // TXB and RXB interrupts masked
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXE | `ETH_INT_RXE | `ETH_INT_BUSY | `ETH_INT_TXC | `ETH_INT_RXC, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);

    tmp_len = 0;
    num_of_frames = 0;
    num_of_rx_frames = 0;
//    num_of_iter = 0;
    // TX frame loop & RX frame loop work independently


    fork
      // TX frame loop
      while (num_of_frames < 400)
      begin
        eth_phy.set_tx_mem_addr(64 + num_of_frames);
        // set tx bd
          // wait for WB master if it is working
          @(posedge wb_clk);
          while (wbm_working)
          begin
            @(posedge wb_clk);
          end
        set_tx_bd(0, 0, tx_len, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + 64));
        set_tx_bd_wrap(0);
        set_tx_bd_ready(0, 0);
        check_tx_bd(0, data);
        // check frame
        i = 0;
        while((i < 100) && (MTxEn === 1'b0)) // wait for start of TX frame!
        begin
          @(posedge mtx_clk);
          i = i + 1;
        end
        if (MTxEn != 1'b1)
        begin
          `TIME; $display("*E Tx Frame %0d: MAC TX didn't start transmitting the packet", num_of_frames);
          test_fail("MAC TX didn't start transmitting the packet");
          fail = fail + 1;
          #10000 $stop;
        end

        repeat (30) @(posedge mtx_clk); // waiting some time so PHY clears the tx_len

        wait ((MTxEn === 1'b0) || (eth_phy.tx_len > (tx_len + 4))) // wait for end of TX frame
        if (MTxEn != 1'b0)
        begin
          `TIME; $display("*E Tx Frame %0d: MAC TX didn't stop transmitting the packet", num_of_frames);
          test_fail("MAC TX didn't stop transmitting the packet");
          fail = fail + 1;
          #10000 $stop;
        end
        tmp_len = eth_phy.tx_len;
          // wait for WB master if it is working
          @(posedge wb_clk);
          while (wbm_working)
          begin
            @(posedge wb_clk);
          end
        check_tx_bd(0, data);
        while (data[15] === 1)
        begin
            // wait for WB master if it is working
            @(posedge wb_clk);
            while (wbm_working)
            begin
              @(posedge wb_clk);
            end
          check_tx_bd(0, data);
        end
        repeat (1) @(posedge wb_clk);
        // check length of a PACKET
        if (tmp_len != (tx_len + 4))
        begin
          `TIME; $display("*E Tx Frame %0d: Wrong length of the packet out from MAC (%0d instead of %0d)", num_of_frames, 
                          tmp_len, (tx_len + 4));
          test_fail("Wrong length of the packet out from MAC");
          fail = fail + 1;
        end
        // check transmitted TX packet data
        check_tx_packet((`MEMORY_BASE + 64), (64 + num_of_frames), (tx_len), tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Tx Frame %0d: Wrong data of the transmitted packet", num_of_frames);
          test_fail("Wrong data of the transmitted packet");
          fail = fail + 1;
        end
        // check transmited TX packet CRC
        check_tx_crc((64 + num_of_frames), (tx_len), 1'b0, tmp); // length without CRC
        if (tmp > 0)
        begin
          `TIME; $display("*E Tx Frame %0d: Wrong CRC of the transmitted packet", num_of_frames);
          test_fail("Wrong CRC of the transmitted packet");
          fail = fail + 1;
        end
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E Tx Frame %0d: WB INT signal should not be set", num_of_frames);
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // check TX buffer descriptor of a packet
          // wait for WB master if it is working
          @(posedge wb_clk);
          while (wbm_working)
          begin
            @(posedge wb_clk);
          end
        check_tx_bd(0, data);
        if (data[15:0] !== 16'h7800)
        begin
          `TIME; $display("*E Tx Frame %0d: TX buffer descriptor status is not correct: %0h", num_of_frames, data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
          // wait for WB master if it is working
          @(posedge wb_clk);
          while (wbm_working)
          begin
            @(posedge wb_clk);
          end
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_TXB) !== `ETH_INT_TXB)
        begin
          `TIME; $display("*E Tx Frame %0d: Interrupt Transmit Buffer was not set, interrupt reg: %0h", num_of_frames, data);
          test_fail("Interrupt Transmit Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~(`ETH_INT_TXB | `ETH_INT_RXB))) !== 0) // RXB might occur at the same time - not error
        begin
          `TIME; $display("*E Tx Frame %0d: Other interrupts (except Tx and Rx Buffer) were set, interrupt reg: %0h", 
                          num_of_frames, data);
          test_fail("Other interrupts (except Transmit Buffer) were set");
          fail = fail + 1;
        end
        // clear interrupts (except RXB)
          // wait for WB master if it is working
          @(posedge wb_clk);
          while (wbm_working)
          begin
            @(posedge wb_clk);
          end
        wbm_write(`ETH_INT, (data & (~`ETH_INT_RXB)), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E Tx Frame %0d: WB INT signal should not be set", num_of_frames);
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // Displays
        if (num_of_frames[2:0] == 3'b111)
        begin
          $display("   ->8 frames transmitted");
        end
        // set length (loop variable)
        num_of_frames = num_of_frames + 1;
      end // TX frame loop
      // RX frame loop
      while (num_of_rx_frames < 400)
      begin
        // set rx bd
          // wait for WB master if it is working
          @(posedge wb_clk);
          #1;
          while (wbm_working)
          begin
            @(posedge wb_clk);
            #1;
          end
        set_rx_bd(1, 1, 1'b1, (`MEMORY_BASE + 200 + num_of_rx_frames));
        set_rx_bd_wrap(1);
        set_rx_bd_empty(1, 1);
        // check frame
        fork
          begin
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 200, (rx_len + 4), 1'b0);
            repeat(10) @(posedge mrx_clk);
          end
          begin
            wait (MRxDV === 1'b1); // start receive
              // wait for WB master if it is working
              @(posedge wb_clk);
              #1;
              while (wbm_working)
              begin
                @(posedge wb_clk);
                #1;
              end
            check_rx_bd(1, data);
            if (data[15] !== 1)
            begin
              `TIME; $display("*E Rx Frame %0d: Wrong buffer descriptor's ready bit read out from MAC", num_of_rx_frames);
              test_fail("Wrong buffer descriptor's ready bit read out from MAC");
              fail = fail + 1;
            end
            wait (MRxDV === 1'b0); // end receive

            while (data[15] === 1)
            begin
                // wait for WB master if it is working
                @(posedge wb_clk);
                #1;
                while (wbm_working)
                begin
                  @(posedge wb_clk);
                  #1;
                end
              check_rx_bd(1, data);
            end
            repeat (1) @(posedge wb_clk);
          end
        join
        // check length of a PACKET

        // Additional read because simulator was not working OK.
        // wait for WB master if it is working
        @(posedge wb_clk);
        #1;
        while (wbm_working)
        begin
          @(posedge wb_clk);
          #1;
        end
        check_rx_bd(1, data);

        if (data[31:16] != (rx_len + 4))
        begin
          `TIME; $display("*E Rx Frame %0d: Wrong length of the packet written to MAC's register (%0d instead of %0d)", 
                          num_of_rx_frames, data[31:16], (rx_len + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        check_rx_packet(200, (`MEMORY_BASE + 200 + num_of_rx_frames), (rx_len + 4), 1'b0, 1'b0, tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Rx Frame %0d: Wrong data of the received packet", num_of_rx_frames);
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E Rx Frame %0d: WB INT signal should not be set", num_of_rx_frames);
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
          // wait for WB master if it is working
          @(posedge wb_clk);
          #1;
          while (wbm_working)
          begin
            @(posedge wb_clk);
            #1;
          end
        check_rx_bd(1, data);
        if (data[15:0] !== 16'h6080)
        begin
          `TIME; $display("*E Rx Frame %0d: RX buffer descriptor status is not correct: %0h", num_of_rx_frames, data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
          // wait for WB master if it is working
          @(posedge wb_clk);
          #1;
          while (wbm_working)
          begin
            @(posedge wb_clk);
            #1;
          end
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);

        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Rx Frame %0d: Interrupt Receive Buffer was not set, interrupt reg: %0h", 
                          num_of_rx_frames, data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~(`ETH_INT_RXB | `ETH_INT_TXB))) !== 0) // TXB might occur at the same time - not error
        begin
          `TIME; $display("*E Rx Frame %0d: Other interrupts (except Rx and Tx Buffer) were set, interrupt reg: %0h", 
                          num_of_rx_frames, data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
        // clear interrupts (except TXB)
          // wait for WB master if it is working
          @(posedge wb_clk);
          #1;
          while (wbm_working)
          begin
            @(posedge wb_clk);
            #1;
          end
        wbm_write(`ETH_INT, (data & (~`ETH_INT_TXB)), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E Rx Frame %0d: WB INT signal should not be set", num_of_rx_frames);
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // Displays
        if (num_of_rx_frames[2:0] == 3'b111)
        begin
          $display("   ->8 frames received");
        end
        // set length (loop variable)
        num_of_rx_frames = num_of_rx_frames + 1;
      end // RX frame loop
    join
    // disable TX & RX
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_PAD | `ETH_MODER_CRCEN | 
              `ETH_MODER_IFG | `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set DIFFERENT mrx_clk to mtx_clk!
//    eth_phy.set_mrx_equal_mtx = 1'b0;
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end
  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Random receive and transmit frames at one TX and          ////
  ////  one RX buffer decriptor ( 100Mbps ).                      ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 5) // 
  begin
    // TEST 5: RANDOM RECEIVE AND TRANSMIT FRAMES AT ONE TX AND ONE RX BD ( 100Mbps )
    test_name   = "TEST 5: RANDOM RECEIVE AND TRANSMIT FRAMES AT ONE TX AND ONE RX BD ( 100Mbps )";
    `TIME; $display("  TEST 5: RANDOM RECEIVE AND TRANSMIT FRAMES AT ONE TX AND ONE RX BD ( 100Mbps )");

    // unmask interrupts
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set 1 TX and 1 RX buffer descriptor (8'h01) - must be set before RX enable
    wbm_write(`ETH_TX_BD_NUM, 32'h01, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, NO receive small, NO correct IFG
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_TXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable flow control

    wbm_write(`ETH_CTRLMODER, `ETH_CTRLMODER_PASSALL | `ETH_CTRLMODER_RXFLOW | `ETH_CTRLMODER_TXFLOW, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare one RX and one TX packet of 100 bytes long
    rx_len = 100; // length of frame without CRC
    st_data = 8'h1A;
    set_rx_packet(200, rx_len, 1'b0, 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E, st_data); 
    append_rx_crc (200, rx_len, 1'b0, 1'b0); // CRC for data packet
    tx_len = 64; // length of frame without CRC
    st_data = 8'h01;
    set_tx_packet(`MEMORY_BASE + 64, tx_len, st_data); // length without CRC
    // set TX and RX Buffer Descriptors 
    tx_bd_num = 0; // tx BDs go from 0 to 0
    rx_bd_num = 1; // rx BDs go from 1 to 1
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end

    // set EQUAL mrx_clk to mtx_clk!
//    eth_phy.set_mrx_equal_mtx = 1'b1;

    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;

    // TXB and RXB interrupts masked
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXE | `ETH_INT_RXE | `ETH_INT_BUSY | `ETH_INT_TXC | `ETH_INT_RXC, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);

    tmp_len = 0;
    num_of_frames = 0;
    num_of_rx_frames = 0;
//    num_of_iter = 0;
    // TX frame loop & RX frame loop work independently


    fork
      // TX frame loop
      while (num_of_frames < 400)
      begin
        eth_phy.set_tx_mem_addr(64 + num_of_frames);
        // set tx bd
          // wait for WB master if it is working
          @(posedge wb_clk);
          while (wbm_working)
          begin
            @(posedge wb_clk);
          end
        set_tx_bd(0, 0, tx_len, 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + 64));
        set_tx_bd_wrap(0);
        set_tx_bd_ready(0, 0);
        check_tx_bd(0, data);
        // check frame
        i = 0;
        while((i < 100) && (MTxEn === 1'b0)) // wait for start of TX frame!
        begin
          @(posedge mtx_clk);
          i = i + 1;
        end
        if (MTxEn != 1'b1)
        begin
          `TIME; $display("*E Tx Frame %0d: MAC TX didn't start transmitting the packet", num_of_frames);
          test_fail("MAC TX didn't start transmitting the packet");
          fail = fail + 1;
          #10000 $stop;
        end

        repeat (30) @(posedge mtx_clk); // waiting some time so PHY clears the tx_len

        wait ((MTxEn === 1'b0) || (eth_phy.tx_len > (tx_len + 4))) // wait for end of TX frame
        if (MTxEn != 1'b0)
        begin
          `TIME; $display("*E Tx Frame %0d: MAC TX didn't stop transmitting the packet", num_of_frames);
          test_fail("MAC TX didn't stop transmitting the packet");
          fail = fail + 1;
          #10000 $stop;
        end
        tmp_len = eth_phy.tx_len;
          // wait for WB master if it is working
          @(posedge wb_clk);
          while (wbm_working)
          begin
            @(posedge wb_clk);
          end
        check_tx_bd(0, data);
        while (data[15] === 1)
        begin
            // wait for WB master if it is working
            @(posedge wb_clk);
            while (wbm_working)
            begin
              @(posedge wb_clk);
            end
          check_tx_bd(0, data);
        end
        repeat (1) @(posedge wb_clk);
        // check length of a PACKET
        if (tmp_len != (tx_len + 4))
        begin
          `TIME; $display("*E Tx Frame %0d: Wrong length of the packet out from MAC (%0d instead of %0d)", num_of_frames, 
                          tmp_len, (tx_len + 4));
          test_fail("Wrong length of the packet out from MAC");
          fail = fail + 1;
        end
        // check transmitted TX packet data
        check_tx_packet((`MEMORY_BASE + 64), (64 + num_of_frames), (tx_len), tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Tx Frame %0d: Wrong data of the transmitted packet", num_of_frames);
          test_fail("Wrong data of the transmitted packet");
          fail = fail + 1;
        end
        // check transmited TX packet CRC
        check_tx_crc((64 + num_of_frames), (tx_len), 1'b0, tmp); // length without CRC
        if (tmp > 0)
        begin
          `TIME; $display("*E Tx Frame %0d: Wrong CRC of the transmitted packet", num_of_frames);
          test_fail("Wrong CRC of the transmitted packet");
          fail = fail + 1;
        end
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E Tx Frame %0d: WB INT signal should not be set", num_of_frames);
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // check TX buffer descriptor of a packet
          // wait for WB master if it is working
          @(posedge wb_clk);
          while (wbm_working)
          begin
            @(posedge wb_clk);
          end
        check_tx_bd(0, data);
        if (data[15:0] !== 16'h7800)
        begin
          `TIME; $display("*E Tx Frame %0d: TX buffer descriptor status is not correct: %0h", num_of_frames, data[15:0]);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
          // wait for WB master if it is working
          @(posedge wb_clk);
          while (wbm_working)
          begin
            @(posedge wb_clk);
          end
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        if ((data & `ETH_INT_TXB) !== `ETH_INT_TXB)
        begin
          `TIME; $display("*E Tx Frame %0d: Interrupt Transmit Buffer was not set, interrupt reg: %0h", num_of_frames, data);
          test_fail("Interrupt Transmit Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~(`ETH_INT_TXB | `ETH_INT_RXB))) !== 0) // RXB might occur at the same time - not error
        begin
          `TIME; $display("*E Tx Frame %0d: Other interrupts (except Tx and Rx Buffer) were set, interrupt reg: %0h", 
                          num_of_frames, data);
          test_fail("Other interrupts (except Transmit Buffer) were set");
          fail = fail + 1;
        end
        // clear interrupts (except RXB)
          // wait for WB master if it is working
          @(posedge wb_clk);
          while (wbm_working)
          begin
            @(posedge wb_clk);
          end
        wbm_write(`ETH_INT, (data & (~`ETH_INT_RXB)), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E Tx Frame %0d: WB INT signal should not be set", num_of_frames);
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // Displays
        if (num_of_frames[2:0] == 3'b111)
        begin
          $display("   ->8 frames transmitted");
        end
        // set length (loop variable)
        num_of_frames = num_of_frames + 1;
      end // TX frame loop
      // RX frame loop
      while (num_of_rx_frames < 400)
      begin
        // set rx bd
          // wait for WB master if it is working
          @(posedge wb_clk);
          #1;
          while (wbm_working)
          begin
            @(posedge wb_clk);
            #1;
          end
        set_rx_bd(1, 1, 1'b1, (`MEMORY_BASE + 200 + num_of_rx_frames));
        set_rx_bd_wrap(1);
        set_rx_bd_empty(1, 1);
        // check frame
        fork
          begin
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 200, (rx_len + 4), 1'b0);
            repeat(10) @(posedge mrx_clk);
          end
          begin
            wait (MRxDV === 1'b1); // start receive
              // wait for WB master if it is working
              @(posedge wb_clk);
              #1;
              while (wbm_working)
              begin
                @(posedge wb_clk);
                #1;
              end
            check_rx_bd(1, data);
            if (data[15] !== 1)
            begin
              `TIME; $display("*E Rx Frame %0d: Wrong buffer descriptor's ready bit read out from MAC", num_of_rx_frames);
              test_fail("Wrong buffer descriptor's ready bit read out from MAC");
              fail = fail + 1;
            end
            wait (MRxDV === 1'b0); // end receive

            while (data[15] === 1)
            begin
                // wait for WB master if it is working
                @(posedge wb_clk);
                #1;
                while (wbm_working)
                begin
                  @(posedge wb_clk);
                  #1;
                end
              check_rx_bd(1, data);
            end
            repeat (1) @(posedge wb_clk);
          end
        join
        // check length of a PACKET

        // Additional read because simulator was not working OK.
        // wait for WB master if it is working
        @(posedge wb_clk);
        #1;
        while (wbm_working)
        begin
          @(posedge wb_clk);
          #1;
        end
        check_rx_bd(1, data);

        if (data[31:16] != (rx_len + 4))
        begin
          `TIME; $display("*E Rx Frame %0d: Wrong length of the packet written to MAC's register (%0d instead of %0d)", 
                          num_of_rx_frames, data[31:16], (rx_len + 4));
          test_fail("Wrong length of the packet out from PHY");
          fail = fail + 1;
        end
        // check received RX packet data and CRC
        check_rx_packet(200, (`MEMORY_BASE + 200 + num_of_rx_frames), (rx_len + 4), 1'b0, 1'b0, tmp);
        if (tmp > 0)
        begin
          `TIME; $display("*E Rx Frame %0d: Wrong data of the received packet", num_of_rx_frames);
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E Rx Frame %0d: WB INT signal should not be set", num_of_rx_frames);
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // check RX buffer descriptor of a packet
          // wait for WB master if it is working
          @(posedge wb_clk);
          #1;
          while (wbm_working)
          begin
            @(posedge wb_clk);
            #1;
          end
        check_rx_bd(1, data);
        if (data[15:0] !== 16'h6080)
        begin
          `TIME; $display("*E Rx Frame %0d: RX buffer descriptor status is not correct: %0h", num_of_rx_frames, data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
        // check interrupts
          // wait for WB master if it is working
          @(posedge wb_clk);
          #1;
          while (wbm_working)
          begin
            @(posedge wb_clk);
            #1;
          end
        wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);

        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Rx Frame %0d: Interrupt Receive Buffer was not set, interrupt reg: %0h", 
                          num_of_rx_frames, data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~(`ETH_INT_RXB | `ETH_INT_TXB))) !== 0) // TXB might occur at the same time - not error
        begin
          `TIME; $display("*E Rx Frame %0d: Other interrupts (except Rx and Tx Buffer) were set, interrupt reg: %0h", 
                          num_of_rx_frames, data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
        // clear interrupts (except TXB)
          // wait for WB master if it is working
          @(posedge wb_clk);
          #1;
          while (wbm_working)
          begin
            @(posedge wb_clk);
            #1;
          end
        wbm_write(`ETH_INT, (data & (~`ETH_INT_TXB)), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // check WB INT signal
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E Rx Frame %0d: WB INT signal should not be set", num_of_rx_frames);
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
        // Displays
        if (num_of_rx_frames[2:0] == 3'b111)
        begin
          $display("   ->8 frames received");
        end
        // set length (loop variable)
        num_of_rx_frames = num_of_rx_frames + 1;
      end // RX frame loop
    join
    // disable TX & RX
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_PAD | `ETH_MODER_CRCEN | 
              `ETH_MODER_IFG | `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set DIFFERENT mrx_clk to mtx_clk!
//    eth_phy.set_mrx_equal_mtx = 1'b0;
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end

end   //  for (test_num=start_task; test_num <= end_task; test_num=test_num+1)

end
endtask // test_mac_full_duplex_flow_control


task test_mac_half_duplex_flow;
  input  [31:0]  start_task;
  input  [31:0]  end_task;
  integer        bit_start_1;
  integer        bit_end_1;
  integer        bit_start_2;
  integer        bit_end_2;
  integer        num_of_reg;
  integer        num_of_frames;
  integer        num_of_bd;
  integer        num_of_iter;
  integer        i_addr;
  integer        i_data;
  integer        i_length;
  integer        tmp_len;
  integer        tmp_bd;
  integer        tmp_bd_num;
  integer        tmp_data;
  integer        tmp_ipgt;
  integer        test_num;
  reg    [31:0]  tx_bd_num;
  reg    [31:0]  rx_bd_num;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_data;
  reg    [((`MAX_BLK_SIZE * 32) - 1):0] burst_tmp_data;
  integer        i;
  integer        i1;
  integer        i2;
  integer        i3;
  integer        ipgr1;
  integer        ipgr2;
  reg            coll;
  integer        fail;
  integer        speed;
  integer        mac_hi_addr;
  integer        mac_lo_addr;
  reg            frame_started;
  reg            frame_ended;
  reg            check_rx_frame;
  reg            check_tx_frame;
  reg            wait_for_tx_frame;
  reg    [31:0]  addr;
  reg    [31:0]  data;
  reg    [31:0]  tmp;
  reg    [ 7:0]  st_data;
  reg    [15:0]  max_tmp;
  reg    [15:0]  min_tmp;
begin
// MAC HALF DUPLEX FLOW TEST
test_heading("MAC HALF DUPLEX FLOW TEST");
$display(" ");
$display("MAC HALF DUPLEX FLOW TEST");
fail = 0;

// reset MAC registers
hard_reset;
// set wb slave response
wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

  /*
  TASKS for set and control TX buffer descriptors (also send packet - set_tx_bd_ready):
  -------------------------------------------------------------------------------------
  set_tx_bd 
    (tx_bd_num_start[6:0], tx_bd_num_end[6:0], len[15:0], irq, pad, crc, txpnt[31:0]);
  set_tx_bd_wrap 
    (tx_bd_num_end[6:0]);
  set_tx_bd_ready 
    (tx_bd_num_start[6:0], tx_bd_num_end[6:0]);
  check_tx_bd 
    (tx_bd_num_start[6:0], tx_bd_status[31:0]);
  clear_tx_bd 
    (tx_bd_num_start[6:0], tx_bd_num_end[6:0]);

  TASKS for set and control RX buffer descriptors:
  ------------------------------------------------
  set_rx_bd 
    (rx_bd_num_strat[6:0], rx_bd_num_end[6:0], irq, rxpnt[31:0]);
  set_rx_bd_wrap 
    (rx_bd_num_end[6:0]);
  set_rx_bd_empty 
    (rx_bd_num_strat[6:0], rx_bd_num_end[6:0]);
  check_rx_bd 
    (rx_bd_num_end[6:0], rx_bd_status);
  clear_rx_bd 
    (rx_bd_num_strat[6:0], rx_bd_num_end[6:0]);

  TASKS for set and check TX packets:
  -----------------------------------
  set_tx_packet 
    (txpnt[31:0], len[15:0], eth_start_data[7:0]);
  check_tx_packet 
    (txpnt_wb[31:0], txpnt_phy[31:0], len[15:0], failure[31:0]);

  TASKS for set and check RX packets:
  -----------------------------------
  set_rx_packet 
    (rxpnt[31:0], len[15:0], plus_nibble, d_addr[47:0], s_addr[47:0], type_len[15:0], start_data[7:0]);
  check_rx_packet 
    (rxpnt_phy[31:0], rxpnt_wb[31:0], len[15:0], plus_nibble, successful_nibble, failure[31:0]);

  TASKS for append and check CRC to/of TX packet:
  -----------------------------------------------
  append_tx_crc 
    (txpnt_wb[31:0], len[15:0], negated_crc);
  check_tx_crc 
    (txpnt_phy[31:0], len[15:0], negated_crc, failure[31:0]); 

  TASK for append CRC to RX packet (CRC is checked together with check_rx_packet):
  --------------------------------------------------------------------------------
  append_rx_crc 
    (rxpnt_phy[31:0], len[15:0], plus_nibble, negated_crc);
  */

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  test_mac_half_duplex_flow:                                  ////
////                                                              ////
////  0: Test                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
begin

  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test defer and collision with IPGR2 while transmitting    ////
  ////  and receiving normal frames. Using 4 TX and RX buffer     ////
  ////  decriptors ( 10Mbps ).                                    ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 0) // 
  begin
    // TEST 0: DEFER, COLL. AND LATE COLL. WHILE TRANSMITTING AND RECEIVING FRM. AT 4 TX/RX BD ( 10Mbps )
    //         
    test_name = "TEST 0: DEFER, COLL. AND LATE COLL. WHILE TRANSMITTING AND RECEIVING FRM. AT 4 TX/RX BD ( 10Mbps )";
    `TIME; $display("  TEST 0: DEFER, COLL. AND LATE COLL. WHILE TRANSMITTING AND RECEIVING FRM. AT 4 TX/RX BD ( 10Mbps )");

    // reset MAC completely
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    // set 4 TX buffer descriptors (4 TX and 4 RX BDs will be used) - must be set before TX/RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h4, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX and RX, set half-duplex mode, receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_RXEN | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets for TX and RX
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h17;
    set_rx_packet(0, (min_tmp), 1'b0, 48'h0102_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
    append_rx_crc (0, (min_tmp), 1'b0, 1'b0);
    st_data = 8'h92;
    set_tx_packet(`MEMORY_BASE, (min_tmp), st_data); // length without CRC
    append_tx_crc (`MEMORY_BASE, (min_tmp), 1'b0);

    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);

    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h0_00;  // bit 6 reset  - (10/100), bit 8 set - HD
    speed = 10;
  
    // set TX and RX Buffer Descriptors 
    tx_bd_num = 0; // tx BDs go from 0 to 3
    rx_bd_num = 4; // rx BDs go from 4 to 7
    ipgr2 = 0;
    i_length = min_tmp + 4;
    set_tx_bd(0, 3, i_length[15:0], 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
    set_tx_bd_wrap(3);
    set_rx_bd(4, 7, 1'b1, `MEMORY_BASE);
    set_rx_bd_wrap(7);
    set_rx_bd_empty(4, 7);
    repeat(10) @(posedge mrx_clk);
    repeat(10) @(posedge wb_clk);
    
    num_of_frames = 0;// 0; // 10;
    while (num_of_frames <= 35)
    begin
      st_data = 8'h2 + num_of_frames;
      set_rx_packet(0, (min_tmp), 1'b0, 48'h0102_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
      append_rx_crc (0, (min_tmp), 1'b0, 1'b0);
      eth_phy.set_tx_mem_addr(num_of_frames);
      // CHECK END OF RECEIVE WHILE TRANSMITTING
      if (num_of_frames == 0)
      begin
        ipgr2 = 7'h0;
        wait (wbm_working == 0);
        wbm_write(`ETH_IPGR2, ipgr2, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      if (num_of_frames == 1)
      begin
        ipgr2 = 7'h1;
        wait (wbm_working == 0);
        wbm_write(`ETH_IPGR2, ipgr2, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      if (num_of_frames == 2)
      begin
        ipgr2 = 7'h12;
        wait (wbm_working == 0);
        wbm_write(`ETH_IPGR2, ipgr2, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      frame_ended = 0;
      check_rx_frame = 0;
      check_tx_frame = 0;
      i = 0;
      coll = 0;
      fork
        // send frames
        begin // start with RX frame
          repeat(num_of_frames) @(posedge mrx_clk);
          #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, i_length, 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin // start with TX frame 
          repeat(4) @(posedge mrx_clk);
          repeat(2) @(posedge wb_clk); 
          #1 set_tx_bd_ready(tx_bd_num, tx_bd_num);
        end
        // observe TX Enable, Carrier Sense and Collision - TX frame is not repeated after Late Collision
        begin: collision0
          wait (MCrs || MTxEn);
          if ((MCrs == 1'b1) && (MTxEn == 1'b0)) // defer TX due to Carrier Sense
          begin
            @(posedge mrx_clk);
            #2;
            if (MTxEn == 1'b0)
            begin
              wait (MColl);
              `TIME; $display("*E Transmit should NOT start more than 1 CLK after CarrierSense and causing Collision");
              test_fail("Transmit should NOT start more than 1 CLK after CarrierSense and causing Collision");
              fail = fail + 1;
              coll = 1;
            end
          end
        end
        begin
          wait (MCrs || MTxEn); 
          #1;
          if ((MCrs == 1'b1) && (MTxEn == 1'b0)) // defer TX due to Carrier Sense
          begin
            @(posedge mrx_clk);
            #2;
            if (MTxEn == 1'b0)
              $display("    ->TX Defer occured");
            else
            begin
              $display("    ->Collision occured due to registered inputs");
              coll = 1;
            end
          end
          else
          begin
            wait (MColl);
            $display("    ->Collision occured - last checking");
            num_of_frames = 35; // this was last transmission
            coll = 1;
            tmp_len = eth_phy.tx_len; // without preamble and SFD (bytes)
          end
          repeat(10) @(posedge mrx_clk);
          repeat(8) @(posedge wb_clk); 
          #1 check_tx_bd(tx_bd_num, data);
          if (data[15] === 0) // transmit should not be aborted aborted
          begin
            `TIME; $display("*E Transmit should not be aborted due to TX Defer or Collision");
            test_fail("Transmit should not be aborted due to TX Defer or Collision");
            fail = fail + 1;
            disable retransmit0;
          end
          // check if RX frame is accepted
          wait (MRxDV === 1'b0); // end receive
          repeat(10) @(posedge mrx_clk);
          repeat(8) @(posedge wb_clk);
          disable collision0;
          #1 check_rx_bd(rx_bd_num, data);
          if (data[15] === 1)
          begin
            `TIME; $display("*E Receive packet should be accepted");
            test_fail("Receive packet should be accepted");
            fail = fail + 1;
          end
          else
            check_rx_frame = 1'b1; // RX frame accepted and must be checked
          repeat(1) @(posedge wb_clk);
        end
        begin: retransmit0
          // check for retransmission of packet
          wait (MRxDV === 1'b1); // start receive
          wait (MRxDV === 1'b0); // end receive
          while (MTxEn == 0) // start of retransmission, IPGR2 counting
          begin
            i = i + 1;
            @(posedge mrx_clk);
            #2;
          end
          $display("    ->IPGR2 timing checking");
          wait (MTxEn === 1'b0); // end of retransmission
          if (i < (ipgr2 + 6))
          begin
            `TIME; $display("*E Wrong IPGR2 timing when retransmitting: %0d instead of %0d", i, (ipgr2 + 6));
            test_fail("Wrong IPGR2 timing when retransmitting");
            fail = fail + 1;
          end
          repeat(10) @(posedge mrx_clk);
          repeat(8) @(posedge wb_clk); 
          #1 check_tx_bd(tx_bd_num, data);
          if (data[15] === 1)
          begin
            `TIME; $display("*E Re-Transmit should be transmitted");
            test_fail("Re-Transmit should be transmitted");
            fail = fail + 1;
          end
          else
            check_tx_frame = 1;
          repeat(1) @(posedge wb_clk);
        end
      join
      repeat(10) @(posedge mrx_clk);
      repeat(10) @(posedge wb_clk);
      // check RX packet
      check_rx_bd(rx_bd_num, data);
      // check length of a PACKET
      if (data[31:16] != (i_length))
      begin
        `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                        data[31:16], (i_length));
        test_fail("Wrong length of the packet out from PHY");
        fail = fail + 1;
      end
      // check received RX packet data and CRC
      check_rx_packet(0, (`MEMORY_BASE), (i_length), 1'b0, 1'b0, tmp);
      if (tmp > 0)
      begin
        `TIME; $display("*E Wrong data of the received packet");
        test_fail("Wrong data of the received packet");
        fail = fail + 1;
      end
      // check RX buffer descriptor of a packet
      if (~coll) // if no collision
      begin
        if ( (data[15:0] !== 16'h6080) && // wrap bit
             (data[15:0] !== 16'h4080) ) // without wrap bit
        begin
          `TIME;
          if (num_of_frames[1:0] == 2'h3)
            $display("*E RX buffer descriptor status is not correct: %0h instead of %0h", data[15:0], 'h6080);
          else
            $display("*E RX buffer descriptor status is not correct: %0h instead of %0h", data[15:0], 'h4080);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else
      begin
        if ( (data[15:0] !== 16'h6081) && // wrap bit
             (data[15:0] !== 16'h4081) ) // without wrap bit
        begin
          `TIME;
          if (num_of_frames[1:0] == 2'h3)
            $display("*E RX buffer descriptor status is not correct: %0h instead of %0h", data[15:0], 'h6081);
          else
            $display("*E RX buffer descriptor status is not correct: %0h instead of %0h", data[15:0], 'h4081);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end

      // check TX packet
      check_tx_bd(tx_bd_num, data);
      // check length of a PACKET
      if (eth_phy.tx_len != (i_length + 4))
      begin
        `TIME; $display("*E Wrong length of the packet out from MAC: %0d instead of %0d",
                        eth_phy.tx_len, (i_length + 4));
        test_fail("Wrong length of the packet out from MAC");
        fail = fail + 1;
      end
      // check transmitted TX packet data and CRC
      check_tx_packet((`MEMORY_BASE + max_tmp), (num_of_frames), (i_length), tmp);
      if (tmp > 0)
      begin
        `TIME; $display("*E Wrong data of the transmitted packet");
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end
      // check TX buffer descriptor of a packet
      if (~coll) // if no collision
      begin
        if ( (data[15:0] !== 16'h7802) && // wrap bit
             (data[15:0] !== 16'h5802) ) // without wrap bit
        begin
          `TIME;
          if (num_of_frames[1:0] == 2'h3)
            $display("*E TX buffer descriptor status is not correct: %0h instead of %0h", data[15:0], 'h7802);
          else
            $display("*E TX buffer descriptor status is not correct: %0h instead of %0h", data[15:0], 'h5802);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else
      begin
        if ( (data[15:0] !== 16'h7810) && // wrap bit
             (data[15:0] !== 16'h5810) ) // without wrap bit
        begin
          `TIME;
          if (num_of_frames[1:0] == 2'h3)
            $display("*E TX buffer descriptor status is not correct: %0h instead of %0h", data[15:0], 'h7810);
          else
            $display("*E TX buffer descriptor status is not correct: %0h instead of %0h", data[15:0], 'h5810);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end

      // check RX & TX
      // check WB INT signal
      if (wb_int !== 1'b1)
      begin
        `TIME; $display("*E WB INT signal should be set");
        test_fail("WB INT signal should be set");
        fail = fail + 1;
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (~coll)
      begin
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
      end
      else
      begin
        if ((data & `ETH_INT_RXE) !== `ETH_INT_RXE)
        begin
          `TIME; $display("*E Interrupt Receive Error was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Error was not set");
          fail = fail + 1;
        end
      end
      if ((data & `ETH_INT_TXB) !== `ETH_INT_TXB)
      begin
        `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
        test_fail("Interrupt Transmit Buffer was not set");
        fail = fail + 1;
      end
      if (~coll)
      begin
        if ((data & (~(`ETH_INT_RXB | `ETH_INT_TXB))) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive & Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive & Transmit Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if ((data & (~(`ETH_INT_RXE | `ETH_INT_TXB))) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Error & Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Error & Transmit Buffer) were set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      //// corrupt RX data in RX BD memory
      //wait (wbm_working == 0);
      //wbm_write(`MEMORY_BASE,     32'hDEAD_BEEF, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //wbm_write(`MEMORY_BASE + 4, 32'hBEEF_DEAD, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // the number of frame transmitted
      if ((num_of_frames == 3)  || (num_of_frames == 7)  || (num_of_frames == 11) || (num_of_frames == 15) || 
          (num_of_frames == 19) || (num_of_frames == 23) || (num_of_frames == 27) || (num_of_frames == 31))
      begin
        tx_bd_num = 0; // tx BDs go from 0 to 3
        rx_bd_num = 4; // rx BDs go from 4 to 7
        set_tx_bd(0, 3, i_length[15:0], 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
        set_tx_bd_wrap(3);
        set_rx_bd(4, 7, 1'b1, `MEMORY_BASE);
        set_rx_bd_wrap(7);
        set_rx_bd_empty(4, 7);
        repeat(10) @(posedge mrx_clk);
        repeat(10) @(posedge wb_clk);
      end
      else
      begin
        tx_bd_num = tx_bd_num + 1; // tx BDs go from 0 to 3
        rx_bd_num = rx_bd_num + 1; // rx BDs go from 4 to 7
      end
      num_of_frames = num_of_frames + 1;
      repeat(50) @(posedge mrx_clk);
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test defer and collision with IPGR2 while transmitting    ////
  ////  and receiving normal frames. Using 4 TX and RX buffer     ////
  ////  decriptors ( 100Mbps ).                                   ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 1) // 
  begin
    // TEST 1: DEFER, COLL. AND LATE COLL. WHILE TRANSMITTING AND RECEIVING FRM. AT 4 TX/RX BD ( 100Mbps )
    //         
    test_name = "TEST 1: DEFER, COLL. AND LATE COLL. WHILE TRANSMITTING AND RECEIVING FRM. AT 4 TX/RX BD ( 100Mbps )";
    `TIME; $display("  TEST 1: DEFER, COLL. AND LATE COLL. WHILE TRANSMITTING AND RECEIVING FRM. AT 4 TX/RX BD ( 100Mbps )");

    // reset MAC completely
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    // set 4 TX buffer descriptors (4 TX and 4 RX BDs will be used) - must be set before TX/RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h4, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX and RX, set half-duplex mode, receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_RXEN | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets for TX and RX
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h17;
    set_rx_packet(0, (min_tmp), 1'b0, 48'h0102_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
    append_rx_crc (0, (min_tmp), 1'b0, 1'b0);
    st_data = 8'h92;
    set_tx_packet(`MEMORY_BASE, (min_tmp), st_data); // length without CRC
    append_tx_crc (`MEMORY_BASE, (min_tmp), 1'b0);

    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);

    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h0_00;  // bit 6 reset  - (10/100), bit 8 set - HD
    speed = 100;
  
    // set TX and RX Buffer Descriptors 
    tx_bd_num = 0; // tx BDs go from 0 to 3
    rx_bd_num = 4; // rx BDs go from 4 to 7
    ipgr2 = 0;
    i_length = min_tmp + 4;
    set_tx_bd(0, 3, i_length[15:0], 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
    set_tx_bd_wrap(3);
    set_rx_bd(4, 7, 1'b1, `MEMORY_BASE);
    set_rx_bd_wrap(7);
    set_rx_bd_empty(4, 7);
    repeat(10) @(posedge mrx_clk);
    repeat(10) @(posedge wb_clk);
    
    num_of_frames = 0;// 0; // 10;
    while (num_of_frames <= 83)
    begin
      st_data = 8'h2 + num_of_frames;
      set_rx_packet(0, (min_tmp), 1'b0, 48'h0102_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
      append_rx_crc (0, (min_tmp), 1'b0, 1'b0);
      eth_phy.set_tx_mem_addr(num_of_frames);
      // CHECK END OF RECEIVE WHILE TRANSMITTING
      if (num_of_frames == 0)
      begin
        ipgr2 = 7'h0;
        wait (wbm_working == 0);
        wbm_write(`ETH_IPGR2, ipgr2, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      if (num_of_frames == 1)
      begin
        ipgr2 = 7'h1;
        wait (wbm_working == 0);
        wbm_write(`ETH_IPGR2, ipgr2, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      if (num_of_frames == 2)
      begin
        ipgr2 = 7'h12;
        wait (wbm_working == 0);
        wbm_write(`ETH_IPGR2, ipgr2, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      frame_ended = 0;
      check_rx_frame = 0;
      check_tx_frame = 0;
      i = 0;
      coll = 0;
      fork
        // send frames
        begin // start with RX frame
          repeat(num_of_frames) @(posedge mrx_clk);
          #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, i_length, 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin // start with TX frame 
          repeat(4) @(posedge mrx_clk);
          repeat(2) @(posedge wb_clk); 
          #1 set_tx_bd_ready(tx_bd_num, tx_bd_num);
        end
        // observe TX Enable, Carrier Sense and Collision - TX frame is not repeated after Late Collision
        begin: collision1
          wait (MCrs || MTxEn);
          if ((MCrs == 1'b1) && (MTxEn == 1'b0)) // defer TX due to Carrier Sense
          begin
            @(posedge mrx_clk);
            #2;
            if (MTxEn == 1'b0)
            begin
              wait (MColl);
              `TIME; $display("*E Transmit should NOT start more than 1 CLK after CarrierSense and causing Collision");
              test_fail("Transmit should NOT start more than 1 CLK after CarrierSense and causing Collision");
              fail = fail + 1;
              coll = 1;
            end
          end
        end
        begin
          wait (MCrs || MTxEn); 
          #1;
          if ((MCrs == 1'b1) && (MTxEn == 1'b0)) // defer TX due to Carrier Sense
          begin
            @(posedge mrx_clk);
            #2;
            if (MTxEn == 1'b0)
              $display("    ->TX Defer occured");
            else
            begin
              $display("    ->Collision occured due to registered inputs");
              coll = 1;
            end
          end
          else
          begin
            wait (MColl);
            $display("    ->Collision occured - last checking");
            num_of_frames = 83; // this was last transmission
            coll = 1;
            tmp_len = eth_phy.tx_len; // without preamble and SFD (bytes)
          end
          repeat(10) @(posedge mrx_clk);
          repeat(8) @(posedge wb_clk); 
          #1 check_tx_bd(tx_bd_num, data);
          if (data[15] === 0) // transmit should not be aborted aborted
          begin
            `TIME; $display("*E Transmit should not be aborted due to TX Defer or Collision");
            test_fail("Transmit should not be aborted due to TX Defer or Collision");
            fail = fail + 1;
            disable retransmit1;
          end
          // check if RX frame is accepted
          wait (MRxDV === 1'b0); // end receive
          repeat(10) @(posedge mrx_clk);
          repeat(8) @(posedge wb_clk);
          disable collision1;
          #1 check_rx_bd(rx_bd_num, data);
          if (data[15] === 1)
          begin
            `TIME; $display("*E Receive packet should be accepted");
            test_fail("Receive packet should be accepted");
            fail = fail + 1;
          end
          else
            check_rx_frame = 1'b1; // RX frame accepted and must be checked
          repeat(1) @(posedge wb_clk);
        end
        begin: retransmit1
          // check for retransmission of packet
          wait (MRxDV === 1'b1); // start receive
          wait (MRxDV === 1'b0); // end receive
          while (MTxEn == 0) // start of retransmission, IPGR2 counting
          begin
            i = i + 1;
            @(posedge mrx_clk);
            #2;
          end
          $display("    ->IPGR2 timing checking");
          wait (MTxEn === 1'b0); // end of retransmission
          if (i < (ipgr2 + 6))
          begin
            `TIME; $display("*E Wrong IPGR2 timing when retransmitting: %0d instead of %0d", i, (ipgr2 + 6));
            test_fail("Wrong IPGR2 timing when retransmitting");
            fail = fail + 1;
          end
          repeat(10) @(posedge mrx_clk);
          repeat(8) @(posedge wb_clk); 
          #1 check_tx_bd(tx_bd_num, data);
          if (data[15] === 1)
          begin
            `TIME; $display("*E Re-Transmit should be transmitted");
            test_fail("Re-Transmit should be transmitted");
            fail = fail + 1;
          end
          else
            check_tx_frame = 1;
          repeat(1) @(posedge wb_clk);
        end
      join
      repeat(10) @(posedge mrx_clk);
      repeat(10) @(posedge wb_clk);
      // check RX packet
      check_rx_bd(rx_bd_num, data);
      // check length of a PACKET
      if (data[31:16] != (i_length))
      begin
        `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                        data[31:16], (i_length));
        test_fail("Wrong length of the packet out from PHY");
        fail = fail + 1;
      end
      // check received RX packet data and CRC
      check_rx_packet(0, (`MEMORY_BASE), (i_length), 1'b0, 1'b0, tmp);
      if (tmp > 0)
      begin
        `TIME; $display("*E Wrong data of the received packet");
        test_fail("Wrong data of the received packet");
        fail = fail + 1;
      end
      // check RX buffer descriptor of a packet
      if (~coll) // if no collision
      begin
        if ( (data[15:0] !== 16'h6080) && // wrap bit
             (data[15:0] !== 16'h4080) ) // without wrap bit
        begin
          `TIME;
          if (num_of_frames[1:0] == 2'h3)
            $display("*E RX buffer descriptor status is not correct: %0h instead of %0h", data[15:0], 'h6080);
          else
            $display("*E RX buffer descriptor status is not correct: %0h instead of %0h", data[15:0], 'h4080);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else
      begin
        if ( (data[15:0] !== 16'h6081) && // wrap bit
             (data[15:0] !== 16'h4081) ) // without wrap bit
        begin
          `TIME;
          if (num_of_frames[1:0] == 2'h3)
            $display("*E RX buffer descriptor status is not correct: %0h instead of %0h", data[15:0], 'h6081);
          else
            $display("*E RX buffer descriptor status is not correct: %0h instead of %0h", data[15:0], 'h4081);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end

      // check TX packet
      check_tx_bd(tx_bd_num, data);
      // check length of a PACKET
      if (eth_phy.tx_len != (i_length + 4))
      begin
        `TIME; $display("*E Wrong length of the packet out from MAC %0d instead of %0d",
                        eth_phy.tx_len, (i_length + 4));
        test_fail("Wrong length of the packet out from MAC");
        fail = fail + 1;
      end
      // check transmitted TX packet data and CRC
      check_tx_packet((`MEMORY_BASE + max_tmp), (num_of_frames), (i_length), tmp);
      if (tmp > 0)
      begin
        `TIME; $display("*E Wrong data of the transmitted packet");
        test_fail("Wrong data of the transmitted packet");
        fail = fail + 1;
      end
      // check TX buffer descriptor of a packet
      if (~coll) // if no collision
      begin
        if ( (data[15:0] !== 16'h7802) && // wrap bit
             (data[15:0] !== 16'h5802) ) // without wrap bit
        begin
          `TIME;
          if (num_of_frames[1:0] == 2'h3)
            $display("*E TX buffer descriptor status is not correct: %0h instead of %0h", data[15:0], 'h7802);
          else
            $display("*E TX buffer descriptor status is not correct: %0h instead of %0h", data[15:0], 'h5802);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else
      begin
        if ( (data[15:0] !== 16'h7810) && // wrap bit
             (data[15:0] !== 16'h5810) ) // without wrap bit
        begin
          `TIME;
          if (num_of_frames[1:0] == 2'h3)
            $display("*E TX buffer descriptor status is not correct: %0h instead of %0h", data[15:0], 'h7810);
          else
            $display("*E TX buffer descriptor status is not correct: %0h instead of %0h", data[15:0], 'h5810);
          test_fail("TX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end

      // check RX & TX
      // check WB INT signal
      if (wb_int !== 1'b1)
      begin
        `TIME; $display("*E WB INT signal should be set");
        test_fail("WB INT signal should be set");
        fail = fail + 1;
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (~coll)
      begin
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
      end
      else
      begin
        if ((data & `ETH_INT_RXE) !== `ETH_INT_RXE)
        begin
          `TIME; $display("*E Interrupt Receive Error was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Error was not set");
          fail = fail + 1;
        end
      end
      if ((data & `ETH_INT_TXB) !== `ETH_INT_TXB)
      begin
        `TIME; $display("*E Interrupt Transmit Buffer was not set, interrupt reg: %0h", data);
        test_fail("Interrupt Transmit Buffer was not set");
        fail = fail + 1;
      end
      if (~coll)
      begin
        if ((data & (~(`ETH_INT_RXB | `ETH_INT_TXB))) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive & Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive & Transmit Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if ((data & (~(`ETH_INT_RXE | `ETH_INT_TXB))) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Error & Transmit Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Error & Transmit Buffer) were set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      //// corrupt RX data in RX BD memory
      //wait (wbm_working == 0);
      //wbm_write(`MEMORY_BASE,     32'hDEAD_BEEF, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      //wbm_write(`MEMORY_BASE + 4, 32'hBEEF_DEAD, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // the number of frame transmitted
      if ((num_of_frames == 3)  || (num_of_frames == 7)  || (num_of_frames == 11) || (num_of_frames == 15) || 
          (num_of_frames == 19) || (num_of_frames == 23) || (num_of_frames == 27) || (num_of_frames == 31) || 
          (num_of_frames == 35) || (num_of_frames == 39) || (num_of_frames == 43) || (num_of_frames == 47) || 
          (num_of_frames == 51) || (num_of_frames == 55) || (num_of_frames == 59) || (num_of_frames == 63) || 
          (num_of_frames == 67) || (num_of_frames == 71) || (num_of_frames == 75) || (num_of_frames == 79))
      begin
        tx_bd_num = 0; // tx BDs go from 0 to 3
        rx_bd_num = 4; // rx BDs go from 4 to 7
        set_tx_bd(0, 3, i_length[15:0], 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
        set_tx_bd_wrap(3);
        set_rx_bd(4, 7, 1'b1, `MEMORY_BASE);
        set_rx_bd_wrap(7);
        set_rx_bd_empty(4, 7);
        repeat(10) @(posedge mrx_clk);
        repeat(10) @(posedge wb_clk);
      end
      else
      begin
        tx_bd_num = tx_bd_num + 1; // tx BDs go from 0 to 3
        rx_bd_num = rx_bd_num + 1; // rx BDs go from 4 to 7
      end
      num_of_frames = num_of_frames + 1;
      repeat(50) @(posedge mrx_clk);
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Test collision and late collision while transmitting and  ////
  ////  receiving normal frames. Using 4 TX and RX buffer         ////
  ////  decriptors ( 10Mbps ).                                    ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 2) // 
  begin
    // TEST 2: DEFER, COLL. AND LATE COLL. WHILE TRANSMITTING AND RECEIVING FRM. AT 4 TX/RX BD ( 10Mbps )
    //         
    test_name = "TEST 2: DEFER, COLL. AND LATE COLL. WHILE TRANSMITTING AND RECEIVING FRM. AT 4 TX/RX BD ( 10Mbps )";
    `TIME; $display("  TEST 2: DEFER, COLL. AND LATE COLL. WHILE TRANSMITTING AND RECEIVING FRM. AT 4 TX/RX BD ( 10Mbps )");

    // reset MAC completely
    hard_reset;
    // set wb slave response
    wb_slave.cycle_response(`ACK_RESPONSE, wbs_waits, wbs_retries);

    max_tmp = 0;
    min_tmp = 0;
    // set 4 TX buffer descriptors (4 TX and 4 RX BDs will be used) - must be set before TX/RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h4, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable TX and RX, set half-duplex mode, receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_TXEN | `ETH_MODER_RXEN | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare two packets of MAXFL length for TX and RX
    wait (wbm_working == 0);
    wbm_read(`ETH_PACKETLEN, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    max_tmp = tmp[15:0]; // 18 bytes consists of 6B dest addr, 6B source addr, 2B type/len, 4B CRC
    min_tmp = tmp[31:16];
    st_data = 8'h17;
    set_rx_packet(0, (min_tmp), 1'b0, 48'h0102_0304_0506, 48'h0708_090A_0B0C, 16'h0D0E, st_data); // length without CRC
    append_rx_crc (0, (min_tmp), 1'b0, 1'b0);
    st_data = 8'h92;
    set_tx_packet(`MEMORY_BASE, (min_tmp), st_data); // length without CRC
    append_tx_crc (`MEMORY_BASE, (min_tmp), 1'b0);

    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);

    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - HD
    speed = 10;
  
    // set TX and RX Buffer Descriptors 
    tx_bd_num = 0; // tx BDs go from 0 to 3
    rx_bd_num = 4; // rx BDs go from 4 to 7
    set_tx_bd(0, 3, i_length[15:0], 1'b1, 1'b1, 1'b1, (`MEMORY_BASE + max_tmp));
    set_tx_bd_wrap(3);
    set_rx_bd(4, 7, 1'b1, `MEMORY_BASE);
    set_rx_bd_wrap(7);
    set_rx_bd_empty(4, 7);
    
//    frame_ended = 0;
    tmp_len = 0;
    num_of_frames = 0;// 0; // 10;
    num_of_iter = 0;
//    num_of_bd = 0;
//    i_length = 0;// (0 - 4); // 6; // 4 less due to CRC
    while (num_of_frames < 80)
    begin
      // change COLLVALID bits in COLLCONF register
      if ((num_of_frames == 0) && (num_of_iter == 0))
      begin
        wait (wbm_working == 0);
        wbm_read(`ETH_COLLCONF, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        tmp[5:0] = 6'h00; // 6'b00_0000 ->  0 + 1 =  1 byte from preamble
        wait (wbm_working == 0);
        wbm_write(`ETH_COLLCONF, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        $display("    Collision window is set to 1 byte after preamble and SFD");
      end
      else if ((num_of_frames == 0) && (num_of_iter == 1))
      begin
        wait (wbm_working == 0);
        wbm_read(`ETH_COLLCONF, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        tmp[5:0] = 6'h15; // 6'b01_0101 -> 21 + 1 = 22 bytes from preamble
        wait (wbm_working == 0);
        wbm_write(`ETH_COLLCONF, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        $display("    Collision window is set to 22 bytes after preamble and SFD");
      end
      else if ((num_of_frames == 0) && (num_of_iter == 2))
      begin
        wait (wbm_working == 0);
        wbm_read(`ETH_COLLCONF, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        tmp[5:0] = 6'h2A; // 6'b10_1010 -> 42 + 1 = 43 bytes from preamble
        wait (wbm_working == 0);
        wbm_write(`ETH_COLLCONF, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        $display("    Collision window is set to 43 bytes after preamble and SFD");
      end
      else if ((num_of_frames == 0) && (num_of_iter == 3))
      begin
        wait (wbm_working == 0);
        wbm_read(`ETH_COLLCONF, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        tmp[5:0] = 6'h3F; // 6'b11_1111 -> 63 + 1 = 64 bytes from preamble
        wait (wbm_working == 0);
        wbm_write(`ETH_COLLCONF, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        $display("    Collision window is set to 64 bytes after preamble and SFD");
      end


//wire          MRxDV;    // This goes to PHY
//wire          MRxErr;   // This goes to PHY
//wire          MColl;    // This goes to PHY
//wire          MCrs;     // This goes to PHY
//wire          MTxEn;
//wire          MTxErr;
      // CHECK END OF RECEIVE WHILE TRANSMITTING
      frame_ended = 0;
      check_rx_frame = 0;
      fork
        // send frames
        begin // start with RX frame
          repeat(num_of_frames) @(posedge mrx_clk);
          #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, (min_tmp + 4), 1'b0);
          repeat(10) @(posedge mrx_clk);
        end
        begin // start with TX frame 
          repeat(2) @(posedge mrx_clk);
          repeat(2) @(posedge wb_clk); 
          #1 set_tx_bd_ready(tx_bd_num, tx_bd_num);
        end
        // observe TX Enable, Carrier Sense and Collision - TX frame is not repeated after Late Collision
        begin
          wait (MCrs || MTxEn); 
          #1;
          if ((MCrs == 1'b1) && (MTxEn == 1'b0)) // defer TX due to Carrier Sense
            wait_for_tx_frame = 1'b1; // wait for retransmission of TX frame
          else
          begin
            i = 0;
            while (MColl == 1'b0) // wait for Collision to occure
            begin
              repeat(2) @(posedge mtx_clk); // counting bytes
              #1 i = i + 1'b1;
            end
            i = i - 8; // subtract preamble and SFD (bytes) - Late Collision is measured from SFD!
            tmp_len = eth_phy.tx_len; // without preamble and SFD (bytes)
            //wait (MTxEn == 1'b0); // wait for TX frame to end
            repeat(10) @(posedge mrx_clk);
            repeat(8) @(posedge wb_clk); 
            #1 check_tx_bd(tx_bd_num, data);
            if (data[15] === 0) // if transmit is aborted, then it was Late Collision
            begin
              wait_for_tx_frame = 1'b0; // don't wait for retransmission of TX frame
              $display("    ->Late Collision occured on %0d. byte after frame and SFD", i);
            end
            else
              wait_for_tx_frame = 1'b1; // wait for retransmission of TX frame
          end
        end
        // check if RX frame is accepted
        begin
          wait (MRxDV === 1'b1); // start receive
          wait (MRxDV === 1'b0); // end receive
          repeat(10) @(posedge mrx_clk);
          repeat(8) @(posedge wb_clk); 
          #1 check_rx_bd(rx_bd_num, data);
          if (data[15] === 0)
          begin
            check_rx_frame = 1'b1; // RX frame accepted and must be checked
            if ((i + 8) == 0) // add preamble and SFD length (bytes)
              $display("    ->RX frame, which started before or at beginning of TX frame, was accepted");
            else
              $display("    ->RX frame, which started %0d byte(s) after beginning of TX frame, was accepted", (i + 8));
          end
          else
            check_rx_frame = 1'b0; // RX frame rejected
          repeat(1) @(posedge wb_clk);
        end
      join



      // check length of a PACKET
      if ( ((data[31:16] != (i_length + 4)) && (num_of_frames >= 3)) ||
           ((data[31:16] != 0) && (num_of_frames < 3)) )
      begin
        `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                        data[31:16], (i_length + 4));
        test_fail("Wrong length of the packet out from PHY");
        fail = fail + 1;
      end
      // check received RX packet data and CRC
//if ((num_of_frames == 5))
//begin                                           // CRC has 4 bytes for itself
//  if (i_length[0] == 1'b1)
//  begin
//    check_rx_packet(0, (`MEMORY_BASE + i_length[1:0]), (i_length + 4), 1'b0, 1'b0, tmp);
//  end
//  else
//  begin
//    check_rx_packet(max_tmp, ((`MEMORY_BASE + i_length[1:0]) + max_tmp), (i_length + 4), 1'b0, 1'b0, tmp);
//  end
//  if (tmp > 0)
//  begin
//    `TIME; $display("*E Wrong data of the received packet");
//    test_fail("Wrong data of the received packet");
//    fail = fail + 1;
//  end
//end
//else
//if ((num_of_frames == 10))
//begin                                           // CRC has 4 bytes for itself
//  if (i_length[0] == 1'b1)
//  begin
//    check_rx_packet(0, (`MEMORY_BASE + i_length[1:0]), (i_length + 4), 1'b0, 1'b0, tmp);
//  end
//  else
//  begin
//    check_rx_packet(max_tmp, ((`MEMORY_BASE + i_length[1:0]) + max_tmp), (i_length + 4), 1'b0, 1'b0, tmp);
//  end
//  if (tmp > 0)
//  begin
//    `TIME; $display("*E Wrong data of the received packet");
//    test_fail("Wrong data of the received packet");
//    fail = fail + 1;
//  end
//end
//else
      if ((frame_ended == 1) && (num_of_frames >= 5)) // 5 bytes is minimum size without CRC error, since
      begin                                           // CRC has 4 bytes for itself
        if (i_length[0] == 1'b0)
        begin
          check_rx_packet(0, (`MEMORY_BASE + i_length[1:0]), (i_length + 4), 1'b0, 1'b0, tmp);
        end
        else
        begin
          check_rx_packet(max_tmp, ((`MEMORY_BASE + i_length[1:0]) + max_tmp), (i_length + 4), 1'b0, 1'b0, tmp);
        end
        if (tmp > 0)
        begin
          `TIME; $display("*E Wrong data of the received packet");
          test_fail("Wrong data of the received packet");
          fail = fail + 1;
        end
      end

      // check WB INT signal
      if (num_of_frames >= 3) // Frames smaller than 3 are not received.
      begin                   // Frames greater then 5 always cause an interrupt (Frame received)
        if (wb_int !== 1'b1)  // Frames with length 3 or 4 always cause an interrupt (CRC error)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else 
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end

      // check RX buffer descriptor of a packet
      if (num_of_frames >= min_tmp)
      begin
        if ( (data[15:0] !== 16'h6000) && // wrap bit
             (data[15:0] !== 16'h4000) ) // without wrap bit
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h - len: %0d", data[15:0], num_of_frames);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else if (num_of_frames > 4)
      begin
        if ( (data[15:0] !== 16'h6004) && // wrap bit
             (data[15:0] !== 16'h4004) ) // without wrap bit
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h - len: %0d", data[15:0], num_of_frames);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else if (num_of_frames > 2)
      begin
        if ( (data[15:0] !== 16'h6006) && // wrap bit
             (data[15:0] !== 16'h4006) ) // without wrap bit
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h - len: %0d", data[15:0], num_of_frames);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data[15] !== 1'b1)
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h - len: %0d", data[15:0], num_of_frames);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if (num_of_frames >= 5)
      begin
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      else if ((num_of_frames < 3)) // Frames smaller than 3 are not received.
      begin
        if (data) // Checking if any interrupt is pending)
        begin
          `TIME; $display("*E Interrupt(s) is(are) pending although frame was ignored, interrupt reg: %0h", data);
          test_fail("Interrupts were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if ((data & `ETH_INT_RXE) !== `ETH_INT_RXE)
        begin
          `TIME; $display("*E Interrupt Receive Buffer Error was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer Error was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXE)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer Error) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer Error) were set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if (num_of_frames == 3)
      begin
        $display("    using 1 BD out of 8 BDs (120..127) assigned to RX (wrap at 1st BD - RX BD 120)");
        $display("    ->packets with lengths from %0d to %0d are not received (length increasing by 1 byte)",
                 0, 3);
      end
      else if (num_of_frames == 9)
      begin
        $display("    using 1 BD out of 8 BDs (120..127) assigned to RX (wrap at 1st BD - RX BD 120)");
        $display("    ->packet with length 4 is not received (length increasing by 1 byte)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 5, 9);
      end
      else if (num_of_frames == 17)
      begin
        $display("    using 4 BDs out of 8 BDs (120..127) assigned to RX (wrap at 4th BD - RX BD 123)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 10, 17);
      end
      else if (num_of_frames == 27)
      begin
        $display("    using 5 BDs out of 8 BDs (120..127) assigned to RX (wrap at 5th BD - RX BD 124)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 18, 27);
      end
      else if (num_of_frames == 40)
      begin
        $display("    using 6 BDs out of 8 BDs (120..127) assigned to RX (wrap at 6th BD - RX BD 125)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 28, 40);
      end
      else if (num_of_frames == 54)
      begin
        $display("    using 7 BDs out of 8 BDs (120..127) assigned to RX (wrap at 7th BD - RX BD 126)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 41, 54);
      end
      else if (num_of_frames == 69)
      begin
        $display("    using 8 BDs out of 8 BDs (120..127) assigned to RX (wrap at 8th BD - RX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 55, 69);
      end
      else if (num_of_frames == 69)
      begin
        $display("    using 8 BDs out of 8 BDs (120..127) assigned to RX (wrap at 8th BD - RX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 55, 69);
      end
      else if (num_of_frames == 77)
      begin
        $display("    using 8 BDs out of 8 BDs (120..127) assigned to RX (wrap at 8th BD - RX BD 127)");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 1 byte)",
                 70, 77);
      end
      // set length (loop variable)
      i_length = i_length + 1;
      // the number of frame transmitted
      num_of_frames = num_of_frames + 1;
      if (/*(num_of_frames == 2) || (num_of_frames == 4) || (num_of_frames == 7) ||*/ (num_of_frames <= 10) || 
          (num_of_frames == 14) || (num_of_frames == 18) || (num_of_frames == 23) || (num_of_frames == 28) ||
          (num_of_frames == 34) || (num_of_frames == 40) || (num_of_frames == 47) ||
          (num_of_frames == 54) || (num_of_frames == 62) || (num_of_frames == 70))
        num_of_bd = 120;
      else
        num_of_bd = num_of_bd + 1;
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_PAD | `ETH_MODER_CRCEN,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    @(posedge wb_clk);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Receive control frames with PASSALL option turned off     ////
  ////  Using only one RX buffer decriptor ( 10Mbps ).            ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 4) // 
  begin
    // TEST 4: RECEIVE CONTROL FRAMES WITH PASSALL OPTION TURNED OFF AT ONE RX BD ( 10Mbps )
    test_name   = "TEST 4: RECEIVE CONTROL FRAMES WITH PASSALL OPTION TURNED OFF AT ONE RX BD ( 10Mbps )";
    `TIME; $display("  TEST 4: RECEIVE CONTROL FRAMES WITH PASSALL OPTION TURNED OFF AT ONE RX BD ( 10Mbps )");

    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set 1 RX buffer descriptor (8'h80 - 1) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h7F, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, NO receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare one control (PAUSE)packet
    st_data = 8'h00;
    set_rx_packet(0, 60, 1'b0, 48'h0180_c200_0001, 48'h0708_090A_0B0C, 16'h8808, st_data); // length without CRC
    // prepare one packet of 100 bytes long
    st_data = 8'h1A;
    set_rx_packet(64, 100, 1'b0, 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E, st_data); 
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end
  
    // write to phy's control register for 10Mbps
    #Tp eth_phy.control_bit14_10 = 5'b00000; // bit 13 reset - speed 10
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset  - (10/100), bit 8 set - FD
    speed = 10;

    for (i=0; i<4; i=i+1)
    begin
      // choose generating carrier sense and collision for first and last 64 lengths of frames
      case (i)
      0: // Interrupt is generated
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, (`MEMORY_BASE + i));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(0);
      end
      1: // Interrupt is not generated
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, ((`MEMORY_BASE + i) + 64));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(0);
      end
      2: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_rx_bd(127, 127, 1'b0, (`MEMORY_BASE + i));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 3: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_rx_bd(127, 127, 1'b0, ((`MEMORY_BASE + i) + 64));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase

      append_rx_crc (64, 100, 1'b0, 1'b0); // To the second (data) packet
      // set wrap bit
      set_rx_bd_wrap(127);
      set_rx_bd_empty(127, 127);
      fork
        begin
          if (i[0] == 1'b0)
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, 64, 1'b0);
          else
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 64, 104, 1'b0);
          repeat(10) @(posedge mrx_clk);
$display("1111");
        end
        begin
          #1 check_rx_bd(127, data);
$display("aaaa");
          wait (MRxDV === 1'b1); // start transmit
$display("bbbb");
          #1 check_rx_bd(127, data);
          if (data[15] !== 1)
          begin
            test_fail("Wrong buffer descriptor's ready bit read out from MAC");
            fail = fail + 1;
          end
          wait (MRxDV === 1'b0); // end transmit
$display("cccc");
          while (data[15] === 1)
          begin
            #1 check_rx_bd(127, data);
            @(posedge wb_clk);
          end
          repeat (1) @(posedge wb_clk);
$display("2222");
        end
      join
$display("dddd");
      // check length of a PACKET
      if (data[31:16] != (i_length + 4))
      begin
        `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                        data[31:16], (i_length + 4));
        test_fail("Wrong length of the packet out from PHY");
        fail = fail + 1;
      end
      // checking in the following if statement is performed only for first and last 64 lengths
      // check received RX packet data and CRC
      if (i_length[0] == 1'b0)
      begin
        check_rx_packet(0, (`MEMORY_BASE + i_length[1:0]), (i_length + 4), 1'b0, 1'b0, tmp);
      end
      else
      begin
        check_rx_packet(max_tmp, ((`MEMORY_BASE + i_length[1:0]) + max_tmp), (i_length + 4), 1'b0, 1'b0, tmp);
      end
      if (tmp > 0)
      begin
        `TIME; $display("*E Wrong data of the received packet");
        test_fail("Wrong data of the received packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (i_length[1:0] == 2'h0)
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check RX buffer descriptor of a packet
      check_rx_bd(127, data);
      if (i_length[1] == 1'b0) // interrupt enabled no_carrier_sense_rx_fd_detect
      begin
        if ( ((data[15:0] !== 16'h6000) && (i_length[0] == 1'b0)) ||
             ((data[15:0] !== 16'h6000) && (i_length[0] == 1'b1)) )
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else // interrupt not enabled
      begin
        if ( ((data[15:0] !== 16'h2000) && (i_length[0] == 1'b0)) ||
             ((data[15:0] !== 16'h2000) && (i_length[0] == 1'b1)) )
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear RX buffer descriptor for first 4 frames
      if (i_length < min_tmp)
        clear_rx_bd(127, 127);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1))
      begin
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Receive Buffer) was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if ((i_length + 4) == (min_tmp + 64))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 64)
        $display("    receive small packets is NOT selected");
        $display("    ->packets with lengths from %0d (MINFL) to %0d are checked (length increasing by 1 byte)",
                 min_tmp, (min_tmp + 64));
        // set receive small, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (max_tmp - 16))
      begin
        // starting length is for +128 longer than previous ending length, while ending length is tmp_data
        $display("    receive small packets is selected");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 128 bytes)",
                 (min_tmp + 64 + 128), tmp_data); 
        // reset receive small, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == max_tmp)
      begin
        $display("    receive small packets is NOT selected");
        $display("    ->packets with lengths from %0d to %0d (MAXFL) are checked (length increasing by 1 byte)",
                 (max_tmp - (4 + 16)), max_tmp);
      end
      // set length (loop variable)
      if ((i_length + 4) < (min_tmp + 64))
        i_length = i_length + 1;
      else if ( ((i_length + 4) >= (min_tmp + 64)) && ((i_length + 4) <= (max_tmp - 256)) )
      begin
        i_length = i_length + 128;
        tmp_data = i_length + 4; // last tmp_data is ending length
      end
      else if ( ((i_length + 4) > (max_tmp - 256)) && ((i_length + 4) < (max_tmp - 16)) )
        i_length = max_tmp - (4 + 16);
      else if ((i_length + 4) >= (max_tmp - 16))
        i_length = i_length + 1;
      else
      begin
        $display("*E TESTBENCH ERROR - WRONG PARAMETERS IN TESTBENCH");
        #10 $stop;
      end
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


  ////////////////////////////////////////////////////////////////////
  ////                                                            ////
  ////  Receive control frames with PASSALL option turned off     ////
  ////  Using only one RX buffer decriptor ( 100Mbps ).           ////
  ////                                                            ////
  ////////////////////////////////////////////////////////////////////
  if (test_num == 5) // 
  begin
    // TEST 5: RECEIVE CONTROL FRAMES WITH PASSALL OPTION TURNED OFF AT ONE RX BD ( 100Mbps )
    test_name   = "TEST 5: RECEIVE CONTROL FRAMES WITH PASSALL OPTION TURNED OFF AT ONE RX BD ( 100Mbps )";
    `TIME; $display("  TEST 5: RECEIVE CONTROL FRAMES WITH PASSALL OPTION TURNED OFF AT ONE RX BD ( 100Mbps )");

    // unmask interrupts
    wait (wbm_working == 0);
    wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                             `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set 1 RX buffer descriptor (8'h80 - 1) - must be set before RX enable
    wait (wbm_working == 0);
    wbm_write(`ETH_TX_BD_NUM, 32'h7F, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // enable RX, set full-duplex mode, NO receive small, NO correct IFG
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // prepare one control (PAUSE)packet
    st_data = 8'h00;
    set_rx_packet(0, 60, 1'b0, 48'h0180_c200_0001, 48'h0708_090A_0B0C, 16'h8808, st_data); // length without CRC
    // prepare one packet of 100 bytes long
    st_data = 8'h1A;
    set_rx_packet(64, 100, 1'b0, 48'h1234_5678_8765, 48'hA1B2_C3D4_E5F6, 16'hE77E, st_data); 
    // check WB INT signal
    if (wb_int !== 1'b0)
    begin
      test_fail("WB INT signal should not be set");
      fail = fail + 1;
    end

    // write to phy's control register for 100Mbps
    #Tp eth_phy.control_bit14_10 = 5'b01000; // bit 13 set - speed 100
    #Tp eth_phy.control_bit8_0   = 9'h1_00;  // bit 6 reset - (10/100), bit 8 set - FD
    speed = 100;

    for (i=0; i<4; i=i+1)
    begin
      // choose generating carrier sense and collision for first and last 64 lengths of frames
      case (i)
      0: // Interrupt is generated
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, (`MEMORY_BASE + i));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(0);
      end
      1: // Interrupt is not generated
      begin
        // enable interrupt generation
        set_rx_bd(127, 127, 1'b1, ((`MEMORY_BASE + i) + 64));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and no collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(0);
      end
      2: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_rx_bd(127, 127, 1'b0, (`MEMORY_BASE + i));
        // unmask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, `ETH_INT_TXB | `ETH_INT_TXE | `ETH_INT_RXB | `ETH_INT_RXE | `ETH_INT_BUSY |
                                 `ETH_INT_TXC | `ETH_INT_RXC, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // not detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(0);
        eth_phy.collision(1);
      end
      default: // 3: // Interrupt is not generated
      begin
        // disable interrupt generation
        set_rx_bd(127, 127, 1'b0, ((`MEMORY_BASE + i) + 64));
        // mask interrupts
        wait (wbm_working == 0);
        wbm_write(`ETH_INT_MASK, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
        // detect carrier sense in FD and set collision
        eth_phy.no_carrier_sense_rx_fd_detect(1);
        eth_phy.collision(1);
      end
      endcase

      append_rx_crc (64, 100, 1'b0, 1'b0); // To the second (data) packet
      // set wrap bit
      set_rx_bd_wrap(127);
      set_rx_bd_empty(127, 127);
      fork
        begin
          if (i[0] == 1'b0)
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, 64, 1'b0);
          else
            #1 eth_phy.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 64, 104, 1'b0);
          repeat(10) @(posedge mrx_clk);
$display("1111");
        end
        begin
          #1 check_rx_bd(127, data);
$display("aaaa");
          wait (MRxDV === 1'b1); // start transmit
$display("bbbb");
          #1 check_rx_bd(127, data);
          if (data[15] !== 1)
          begin
            test_fail("Wrong buffer descriptor's ready bit read out from MAC");
            fail = fail + 1;
          end
          wait (MRxDV === 1'b0); // end transmit
$display("cccc");
          while (data[15] === 1)
          begin
            #1 check_rx_bd(127, data);
            @(posedge wb_clk);
          end
          repeat (1) @(posedge wb_clk);
$display("2222");
        end
      join
$display("dddd");
      // check length of a PACKET
      if (data[31:16] != (i_length + 4))
      begin
        `TIME; $display("*E Wrong length of the packet out from PHY (%0d instead of %0d)", 
                        data[31:16], (i_length + 4));
        test_fail("Wrong length of the packet out from PHY");
        fail = fail + 1;
      end
      // checking in the following if statement is performed only for first and last 64 lengths
      // check received RX packet data and CRC
      if (i_length[0] == 1'b0)
      begin
        check_rx_packet(0, (`MEMORY_BASE + i_length[1:0]), (i_length + 4), 1'b0, 1'b0, tmp);
      end
      else
      begin
        check_rx_packet(max_tmp, ((`MEMORY_BASE + i_length[1:0]) + max_tmp), (i_length + 4), 1'b0, 1'b0, tmp);
      end
      if (tmp > 0)
      begin
        `TIME; $display("*E Wrong data of the received packet");
        test_fail("Wrong data of the received packet");
        fail = fail + 1;
      end
      // check WB INT signal
      if (i_length[1:0] == 2'h0)
      begin
        if (wb_int !== 1'b1)
        begin
          `TIME; $display("*E WB INT signal should be set");
          test_fail("WB INT signal should be set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (wb_int !== 1'b0)
        begin
          `TIME; $display("*E WB INT signal should not be set");
          test_fail("WB INT signal should not be set");
          fail = fail + 1;
        end
      end
      // check RX buffer descriptor of a packet
      check_rx_bd(127, data);
      if (i_length[1] == 1'b0) // interrupt enabled no_carrier_sense_rx_fd_detect
      begin
        if ( ((data[15:0] !== 16'h6000) && (i_length[0] == 1'b0)) ||
             ((data[15:0] !== 16'h6000) && (i_length[0] == 1'b1)) )
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      else // interrupt not enabled
      begin
        if ( ((data[15:0] !== 16'h2000) && (i_length[0] == 1'b0)) ||
             ((data[15:0] !== 16'h2000) && (i_length[0] == 1'b1)) )
        begin
          `TIME; $display("*E RX buffer descriptor status is not correct: %0h", data[15:0]);
          test_fail("RX buffer descriptor status is not correct");
          fail = fail + 1;
        end
      end
      // clear RX buffer descriptor for first 4 frames
      if (i_length < min_tmp)
        clear_rx_bd(127, 127);
      // check interrupts
      wait (wbm_working == 0);
      wbm_read(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      if ((i_length[1:0] == 2'h0) || (i_length[1:0] == 2'h1))
      begin
        if ((data & `ETH_INT_RXB) !== `ETH_INT_RXB)
        begin
          `TIME; $display("*E Interrupt Receive Buffer was not set, interrupt reg: %0h", data);
          test_fail("Interrupt Receive Buffer was not set");
          fail = fail + 1;
        end
        if ((data & (~`ETH_INT_RXB)) !== 0)
        begin
          `TIME; $display("*E Other interrupts (except Receive Buffer) were set, interrupt reg: %0h", data);
          test_fail("Other interrupts (except Receive Buffer) were set");
          fail = fail + 1;
        end
      end
      else
      begin
        if (data !== 0)
        begin
          `TIME; $display("*E Any of interrupts (except Receive Buffer) was set, interrupt reg: %0h, len: %0h", data, i_length[1:0]);
          test_fail("Any of interrupts (except Receive Buffer) was set");
          fail = fail + 1;
        end
      end
      // clear interrupts
      wait (wbm_working == 0);
      wbm_write(`ETH_INT, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      // check WB INT signal
      if (wb_int !== 1'b0)
      begin
        test_fail("WB INT signal should not be set");
        fail = fail + 1;
      end
      // INTERMEDIATE DISPLAYS
      if ((i_length + 4) == (min_tmp + 64))
      begin
        // starting length is min_tmp, ending length is (min_tmp + 64)
        $display("    receive small packets is NOT selected");
        $display("    ->packets with lengths from %0d (MINFL) to %0d are checked (length increasing by 1 byte)",
                 min_tmp, (min_tmp + 64));
        // set receive small, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == (max_tmp - 16))
      begin
        // starting length is for +128 longer than previous ending length, while ending length is tmp_data
        $display("    receive small packets is selected");
        $display("    ->packets with lengths from %0d to %0d are checked (length increasing by 128 bytes)",
                 (min_tmp + 64 + 128), tmp_data); 
        // reset receive small, remain the rest
        wait (wbm_working == 0);
        wbm_write(`ETH_MODER, `ETH_MODER_RXEN | `ETH_MODER_FULLD | `ETH_MODER_IFG | 
                  `ETH_MODER_PRO | `ETH_MODER_BRO, 
                  4'hF, 1, wbm_init_waits, wbm_subseq_waits);
      end
      else if ((i_length + 4) == max_tmp)
      begin
        $display("    receive small packets is NOT selected");
        $display("    ->packets with lengths from %0d to %0d (MAXFL) are checked (length increasing by 1 byte)",
                 (max_tmp - (4 + 16)), max_tmp);
      end
      // set length (loop variable)
      if ((i_length + 4) < (min_tmp + 64))
        i_length = i_length + 1;
      else if ( ((i_length + 4) >= (min_tmp + 64)) && ((i_length + 4) <= (max_tmp - 256)) )
      begin
        i_length = i_length + 128;
        tmp_data = i_length + 4; // last tmp_data is ending length
      end
      else if ( ((i_length + 4) > (max_tmp - 256)) && ((i_length + 4) < (max_tmp - 16)) )
        i_length = max_tmp - (4 + 16);
      else if ((i_length + 4) >= (max_tmp - 16))
        i_length = i_length + 1;
      else
      begin
        $display("*E TESTBENCH ERROR - WRONG PARAMETERS IN TESTBENCH");
        #10 $stop;
      end
    end
    // disable RX
    wait (wbm_working == 0);
    wbm_write(`ETH_MODER, `ETH_MODER_FULLD | `ETH_MODER_RECSMALL | `ETH_MODER_IFG | 
              `ETH_MODER_PRO | `ETH_MODER_BRO,
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    if(fail == 0)
      test_ok;
    else
      fail = 0;
  end


end

end
endtask // test_mac_half_duplex_flow


//////////////////////////////////////////////////////////////
// WB Behavioral Models Basic tasks
//////////////////////////////////////////////////////////////

task wbm_write;
  input  [31:0] address_i;
  input  [((`MAX_BLK_SIZE * 32) - 1):0] data_i;
  input  [3:0]  sel_i;
  input  [31:0] size_i;
  input  [3:0]  init_waits_i;
  input  [3:0]  subseq_waits_i;

  reg `WRITE_STIM_TYPE write_data;
  reg `WB_TRANSFER_FLAGS flags;
  reg `WRITE_RETURN_TYPE write_status;
  integer i;
begin
  wbm_working = 1;
  
  write_status = 0;

  flags                    = 0;
  flags`WB_TRANSFER_SIZE   = size_i;
  flags`INIT_WAITS         = init_waits_i;
  flags`SUBSEQ_WAITS       = subseq_waits_i;

  write_data               = 0;
  write_data`WRITE_DATA    = data_i[31:0];
  write_data`WRITE_ADDRESS = address_i;
  write_data`WRITE_SEL     = sel_i;

  for (i = 0; i < size_i; i = i + 1)
  begin
    wb_master.blk_write_data[i] = write_data;
    data_i                      = data_i >> 32;
    write_data`WRITE_DATA       = data_i[31:0];
    write_data`WRITE_ADDRESS    = write_data`WRITE_ADDRESS + 4;
  end

  wb_master.wb_block_write(flags, write_status);

  if (write_status`CYC_ACTUAL_TRANSFER !== size_i)
  begin
    `TIME;
    $display("*E WISHBONE Master was unable to complete the requested write operation to MAC!");
  end

  @(posedge wb_clk);
  #3;
  wbm_working = 0;
  #1;
end
endtask // wbm_write

task wbm_read;
  input  [31:0] address_i;
  output [((`MAX_BLK_SIZE * 32) - 1):0] data_o;
  input  [3:0]  sel_i;
  input  [31:0] size_i;
  input  [3:0]  init_waits_i;
  input  [3:0]  subseq_waits_i;

  reg `READ_RETURN_TYPE read_data;
  reg `WB_TRANSFER_FLAGS flags;
  reg `READ_RETURN_TYPE read_status;
  integer i;
begin
  wbm_working = 1;

  read_status = 0;
  data_o      = 0;

  flags                  = 0;
  flags`WB_TRANSFER_SIZE = size_i;
  flags`INIT_WAITS       = init_waits_i;
  flags`SUBSEQ_WAITS     = subseq_waits_i;

  read_data              = 0;
  read_data`READ_ADDRESS = address_i;
  read_data`READ_SEL     = sel_i;

  for (i = 0; i < size_i; i = i + 1)
  begin
    wb_master.blk_read_data_in[i] = read_data;
    read_data`READ_ADDRESS        = read_data`READ_ADDRESS + 4;
  end

  wb_master.wb_block_read(flags, read_status);

  if (read_status`CYC_ACTUAL_TRANSFER !== size_i)
  begin
    `TIME;
    $display("*E WISHBONE Master was unable to complete the requested read operation from MAC!");
  end

  for (i = 0; i < size_i; i = i + 1)
  begin
    data_o       = data_o << 32;
    read_data    = wb_master.blk_read_data_out[(size_i - 1) - i]; // [31 - i];
    data_o[31:0] = read_data`READ_DATA;
  end

  @(posedge wb_clk);
  #3;
  wbm_working = 0;
  #1;
end
endtask // wbm_read


//////////////////////////////////////////////////////////////
// Ethernet Basic tasks
//////////////////////////////////////////////////////////////

task hard_reset; //  MAC registers
begin
  // reset MAC registers
  @(posedge wb_clk);
  #2 wb_rst = 1'b1;
  repeat(2) @(posedge wb_clk);
  #2 wb_rst = 1'b0;
end
endtask // hard_reset

task set_tx_bd;
  input  [6:0]  tx_bd_num_start;
  input  [6:0]  tx_bd_num_end;
  input  [15:0] len;
  input         irq;
  input         pad;
  input         crc;
  input  [31:0] txpnt;

  integer       i;
  integer       bd_status_addr, bd_ptr_addr;
//  integer       buf_addr;
begin
  for(i = tx_bd_num_start; i <= tx_bd_num_end; i = i + 1) 
  begin
//    buf_addr = `TX_BUF_BASE + i * 32'h600;
    bd_status_addr = `TX_BD_BASE + i * 8;
    bd_ptr_addr = bd_status_addr + 4;
    // initialize BD - status
    wait (wbm_working == 0);
    wbm_write(bd_status_addr, {len, 1'b0, irq, 1'b0, pad, crc, 11'h0}, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits); // IRQ + PAD + CRC
    // initialize BD - pointer
    wait (wbm_working == 0);
    wbm_write(bd_ptr_addr, txpnt, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Initializing BD-pointer
  end
end
endtask // set_tx_bd

task set_tx_bd_wrap;
  input  [6:0]  tx_bd_num_end;
  integer       bd_status_addr, tmp;
begin
  bd_status_addr = `TX_BD_BASE + tx_bd_num_end * 8;
  wait (wbm_working == 0);
  wbm_read(bd_status_addr, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  // set wrap bit to this BD - this BD should be last-one
  wait (wbm_working == 0);
  wbm_write(bd_status_addr, (`ETH_TX_BD_WRAP | tmp), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
end
endtask // set_tx_bd_wrap

task set_tx_bd_ready;
  input  [6:0]  tx_nd_num_strat;
  input  [6:0]  tx_bd_num_end;
  integer       i;
  integer       bd_status_addr, tmp;
begin
  for(i = tx_nd_num_strat; i <= tx_bd_num_end; i = i + 1)
  begin
    bd_status_addr = `TX_BD_BASE + i * 8;
    wait (wbm_working == 0);
    wbm_read(bd_status_addr, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set empty bit to this BD - this BD should be ready
    wait (wbm_working == 0);
    wbm_write(bd_status_addr, (`ETH_TX_BD_READY | tmp), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  end
end
endtask // set_tx_bd_ready

task check_tx_bd;
  input  [6:0]  tx_bd_num_end;
  output [31:0] tx_bd_status;
  integer       bd_status_addr, tmp;
begin
  bd_status_addr = `TX_BD_BASE + tx_bd_num_end * 8;
  wait (wbm_working == 0);
  wbm_read(bd_status_addr, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  tx_bd_status = tmp;
end
endtask // check_tx_bd

task clear_tx_bd;
  input  [6:0]  tx_nd_num_strat;
  input  [6:0]  tx_bd_num_end;
  integer       i;
  integer       bd_status_addr, bd_ptr_addr;
begin
  for(i = tx_nd_num_strat; i <= tx_bd_num_end; i = i + 1)
  begin
    bd_status_addr = `TX_BD_BASE + i * 8;
    bd_ptr_addr = bd_status_addr + 4;
    // clear BD - status
    wait (wbm_working == 0);
    wbm_write(bd_status_addr, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // clear BD - pointer
    wait (wbm_working == 0);
    wbm_write(bd_ptr_addr, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  end
end
endtask // clear_tx_bd

task set_rx_bd;
  input  [6:0]  rx_bd_num_strat;
  input  [6:0]  rx_bd_num_end;
  input         irq;
  input  [31:0] rxpnt;
//  input  [6:0]  rxbd_num;
  integer       i;
  integer       bd_status_addr, bd_ptr_addr;
//  integer       buf_addr;
begin
  for(i = rx_bd_num_strat; i <= rx_bd_num_end; i = i + 1) 
  begin
//    buf_addr = `RX_BUF_BASE + i * 32'h600;
//    bd_status_addr = `RX_BD_BASE + i * 8;
//    bd_ptr_addr = bd_status_addr + 4; 
    bd_status_addr = `TX_BD_BASE + i * 8;
    bd_ptr_addr = bd_status_addr + 4;
    
    // initialize BD - status
    wait (wbm_working == 0);
//    wbm_write(bd_status_addr, 32'h0000c000, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // IRQ + PAD + CRC
    wbm_write(bd_status_addr, {17'h0, irq, 14'h0}, 
              4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // initialize BD - pointer
    wait (wbm_working == 0);
//    wbm_write(bd_ptr_addr, buf_addr, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Initializing BD-pointer
    wbm_write(bd_ptr_addr, rxpnt, 4'hF, 1, wbm_init_waits, wbm_subseq_waits); // Initializing BD-pointer
  end
end
endtask // set_rx_bd

task set_rx_bd_wrap;
  input  [6:0]  rx_bd_num_end;
  integer       bd_status_addr, tmp;
begin
//  bd_status_addr = `RX_BD_BASE + rx_bd_num_end * 8;
  bd_status_addr = `TX_BD_BASE + rx_bd_num_end * 8;
  wait (wbm_working == 0);
  wbm_read(bd_status_addr, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  // set wrap bit to this BD - this BD should be last-one
  wait (wbm_working == 0);
  wbm_write(bd_status_addr, (`ETH_RX_BD_WRAP | tmp), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
end
endtask // set_rx_bd_wrap

task set_rx_bd_empty;
  input  [6:0]  rx_bd_num_strat;
  input  [6:0]  rx_bd_num_end;
  integer       i;
  integer       bd_status_addr, tmp;
begin
  for(i = rx_bd_num_strat; i <= rx_bd_num_end; i = i + 1)
  begin
//    bd_status_addr = `RX_BD_BASE + i * 8;
    bd_status_addr = `TX_BD_BASE + i * 8;
    wait (wbm_working == 0);
    wbm_read(bd_status_addr, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // set empty bit to this BD - this BD should be ready
    wait (wbm_working == 0);
    wbm_write(bd_status_addr, (`ETH_RX_BD_EMPTY | tmp), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  end
end
endtask // set_rx_bd_empty

task check_rx_bd;
  input  [6:0]  rx_bd_num_end;
  output [31:0] rx_bd_status;
  integer       bd_status_addr, tmp;
begin
//  bd_status_addr = `RX_BD_BASE + rx_bd_num_end * 8;
  bd_status_addr = `TX_BD_BASE + rx_bd_num_end * 8;
  wait (wbm_working == 0);
  wbm_read(bd_status_addr, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  rx_bd_status = tmp;
end
endtask // check_rx_bd

task clear_rx_bd;
  input  [6:0]  rx_bd_num_strat;
  input  [6:0]  rx_bd_num_end;
  integer       i;
  integer       bd_status_addr, bd_ptr_addr;
begin
  for(i = rx_bd_num_strat; i <= rx_bd_num_end; i = i + 1)
  begin
//    bd_status_addr = `RX_BD_BASE + i * 8;
    bd_status_addr = `TX_BD_BASE + i * 8;
    bd_ptr_addr = bd_status_addr + 4;
    // clear BD - status
    wait (wbm_working == 0);
    wbm_write(bd_status_addr, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
    // clear BD - pointer
    wait (wbm_working == 0);
    wbm_write(bd_ptr_addr, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  end
end
endtask // clear_rx_bd

task set_tx_packet;
  input  [31:0] txpnt;
  input  [15:0] len;
  input  [7:0]  eth_start_data;
  integer       i, sd;
  integer       buffer;
  reg           delta_t;
begin
  buffer = txpnt;
  sd = eth_start_data;
  delta_t = 0;

  // First write might not be word allign.
  if(buffer[1:0] == 1)  
  begin
    wb_slave.wr_mem(buffer - 1, {8'h0, sd[7:0], sd[7:0] + 3'h1, sd[7:0] + 3'h2}, 4'h7);
    sd = sd + 3;
    i = 3;
  end
  else if(buffer[1:0] == 2)  
  begin
    wb_slave.wr_mem(buffer - 2, {16'h0, sd[7:0], sd[7:0] + 3'h1}, 4'h3);
    sd = sd + 2;
    i = 2;
  end      
  else if(buffer[1:0] == 3)
  begin
    wb_slave.wr_mem(buffer - 3, {24'h0, sd[7:0]}, 4'h1);
    sd = sd + 1;
    i = 1;
  end
  else
    i = 0;
  delta_t = !delta_t;

  for(i = i; i < (len - 4); i = i + 4) // Last 0-3 bytes are not written
  begin  
    wb_slave.wr_mem(buffer + i, {sd[7:0], sd[7:0] + 3'h1, sd[7:0] + 3'h2, sd[7:0] + 3'h3}, 4'hF);
    sd = sd + 4;
  end
  delta_t = !delta_t;
  
  // Last word
  if((len - i) == 3)
  begin
    wb_slave.wr_mem(buffer + i, {sd[7:0], sd[7:0] + 3'h1, sd[7:0] + 3'h2, 8'h0}, 4'hE);
  end
  else if((len - i) == 2)
  begin
    wb_slave.wr_mem(buffer + i, {sd[7:0], sd[7:0] + 3'h1, 16'h0}, 4'hC);
  end
  else if((len - i) == 1)
  begin
    wb_slave.wr_mem(buffer + i, {sd[7:0], 24'h0}, 4'h8);
  end
  else if((len - i) == 4)
  begin
    wb_slave.wr_mem(buffer + i, {sd[7:0], sd[7:0] + 3'h1, sd[7:0] + 3'h2, sd[7:0] + 3'h3}, 4'hF);
  end
  else
    $display("(%0t)(%m) ERROR", $time);
  delta_t = !delta_t;
end
endtask // set_tx_packet

task check_tx_packet;
  input  [31:0] txpnt_wb;  // source
  input  [31:0] txpnt_phy; // destination
  input  [15:0] len;
  output [31:0] failure;
  integer       i, data_wb, data_phy;
  reg    [31:0] addr_wb, addr_phy;
  reg    [31:0] failure;
  reg           delta_t;
begin
  addr_wb = txpnt_wb;
  addr_phy = txpnt_phy;
  delta_t = 0;
  failure = 0;
  #1;
  // First write might not be word allign.
  if(addr_wb[1:0] == 1)
  begin
    wb_slave.rd_mem(addr_wb - 1, data_wb, 4'h7);
    data_phy[31:24] = 0;
    data_phy[23:16] = eth_phy.tx_mem[addr_phy[21:0]];
    data_phy[15: 8] = eth_phy.tx_mem[addr_phy[21:0] + 1];
    data_phy[ 7: 0] = eth_phy.tx_mem[addr_phy[21:0] + 2];
    i = 3;
    if (data_phy[23:0] !== data_wb[23:0])
    begin
      //`TIME;
      //$display("*E Wrong 1. word (3 bytes) of TX packet! phy: %0h, wb: %0h", data_phy[23:0], data_wb[23:0]);
      //$display("     address phy: %0h, address wb: %0h", addr_phy, addr_wb);
      failure = 1;
    end
  end
  else if (addr_wb[1:0] == 2)
  begin
    wb_slave.rd_mem(addr_wb - 2, data_wb, 4'h3);
    data_phy[31:16] = 0;
    data_phy[15: 8] = eth_phy.tx_mem[addr_phy[21:0]];
    data_phy[ 7: 0] = eth_phy.tx_mem[addr_phy[21:0] + 1];
    i = 2;
    if (data_phy[15:0] !== data_wb[15:0])
    begin
      //`TIME;
      //$display("*E Wrong 1. word (2 bytes) of TX packet! phy: %0h, wb: %0h", data_phy[15:0], data_wb[15:0]);
      //$display("     address phy: %0h, address wb: %0h", addr_phy, addr_wb);
      failure = 1;
    end
  end
  else if (addr_wb[1:0] == 3)
  begin
    wb_slave.rd_mem(addr_wb - 3, data_wb, 4'h1);
    data_phy[31: 8] = 0;
    data_phy[ 7: 0] = eth_phy.tx_mem[addr_phy[21:0]];
    i = 1;
    if (data_phy[7:0] !== data_wb[7:0])
    begin
      //`TIME;
      //$display("*E Wrong 1. word (1 byte) of TX packet! phy: %0h, wb: %0h", data_phy[7:0], data_wb[7:0]);
      //$display("     address phy: %0h, address wb: %0h", addr_phy, addr_wb);
      failure = 1;
    end
  end
  else
    i = 0;
  delta_t = !delta_t;
  #1;
  for(i = i; i < (len - 4); i = i + 4) // Last 0-3 bytes are not checked
  begin
    wb_slave.rd_mem(addr_wb + i, data_wb, 4'hF);
    data_phy[31:24] = eth_phy.tx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = eth_phy.tx_mem[addr_phy[21:0] + i + 1];
    data_phy[15: 8] = eth_phy.tx_mem[addr_phy[21:0] + i + 2];
    data_phy[ 7: 0] = eth_phy.tx_mem[addr_phy[21:0] + i + 3];

    if (data_phy[31:0] !== data_wb[31:0])
    begin
      //`TIME;
      //$display("*E Wrong %d. word (4 bytes) of TX packet! phy: %0h, wb: %0h", ((i/4)+1), data_phy[31:0], data_wb[31:0]);
      //$display("     address phy: %0h, address wb: %0h", addr_phy, addr_wb);
      failure = failure + 1;
    end
  end
  delta_t = !delta_t;
  #1;
  // Last word
  if((len - i) == 3)
  begin
    wb_slave.rd_mem(addr_wb + i, data_wb, 4'hE);
    data_phy[31:24] = eth_phy.tx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = eth_phy.tx_mem[addr_phy[21:0] + i + 1];
    data_phy[15: 8] = eth_phy.tx_mem[addr_phy[21:0] + i + 2];
    data_phy[ 7: 0] = 0;
    if (data_phy[31:8] !== data_wb[31:8])
    begin
      //`TIME;
      //$display("*E Wrong %d. word (3 bytes) of TX packet! phy: %0h, wb: %0h", ((i/4)+1), data_phy[31:8], data_wb[31:8]);
      //$display("     address phy: %0h, address wb: %0h", addr_phy, addr_wb);
      failure = failure + 1;
    end
  end
  else if((len - i) == 2)
  begin
    wb_slave.rd_mem(addr_wb + i, data_wb, 4'hC);
    data_phy[31:24] = eth_phy.tx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = eth_phy.tx_mem[addr_phy[21:0] + i + 1];
    data_phy[15: 8] = 0;
    data_phy[ 7: 0] = 0;
    if (data_phy[31:16] !== data_wb[31:16])
    begin
      //`TIME;
      //$display("*E Wrong %d. word (2 bytes) of TX packet! phy: %0h, wb: %0h", ((i/4)+1), data_phy[31:16], data_wb[31:16]);
      //$display("     address phy: %0h, address wb: %0h", addr_phy, addr_wb);
      failure = failure + 1;
    end
  end
  else if((len - i) == 1)
  begin
    wb_slave.rd_mem(addr_wb + i, data_wb, 4'h8);
    data_phy[31:24] = eth_phy.tx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = 0;
    data_phy[15: 8] = 0;
    data_phy[ 7: 0] = 0;
    if (data_phy[31:24] !== data_wb[31:24])
    begin
      //`TIME;
      //$display("*E Wrong %d. word (1 byte) of TX packet! phy: %0h, wb: %0h", ((i/4)+1), data_phy[31:24], data_wb[31:24]);
      //$display("     address phy: %0h, address wb: %0h", addr_phy, addr_wb);
      failure = failure + 1;
    end
  end
  else if((len - i) == 4)
  begin
    wb_slave.rd_mem(addr_wb + i, data_wb, 4'hF);
    data_phy[31:24] = eth_phy.tx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = eth_phy.tx_mem[addr_phy[21:0] + i + 1];
    data_phy[15: 8] = eth_phy.tx_mem[addr_phy[21:0] + i + 2];
    data_phy[ 7: 0] = eth_phy.tx_mem[addr_phy[21:0] + i + 3];
    if (data_phy[31:0] !== data_wb[31:0])
    begin
      //`TIME;
      //$display("*E Wrong %d. word (4 bytes) of TX packet! phy: %0h, wb: %0h", ((i/4)+1), data_phy[31:0], data_wb[31:0]);
      //$display("     address phy: %0h, address wb: %0h", addr_phy, addr_wb);
      failure = failure + 1;
    end
  end
  else
    $display("(%0t)(%m) ERROR", $time);
  delta_t = !delta_t;
end
endtask // check_tx_packet

task set_rx_packet;
  input  [31:0] rxpnt;
  input  [15:0] len;
  input         plus_dribble_nibble; // if length is longer for one nibble
  input  [47:0] eth_dest_addr;
  input  [47:0] eth_source_addr;
  input  [15:0] eth_type_len;
  input  [7:0]  eth_start_data;
  integer       i, sd;
  reg    [47:0] dest_addr;
  reg    [47:0] source_addr;
  reg    [15:0] type_len;
  reg    [21:0] buffer;
  reg           delta_t;
begin
  buffer = rxpnt[21:0];
  dest_addr = eth_dest_addr;
  source_addr = eth_source_addr;
  type_len = eth_type_len;
  sd = eth_start_data;
  delta_t = 0;
  for(i = 0; i < len; i = i + 1) 
  begin
    if (i < 6)
    begin
      eth_phy.rx_mem[buffer] = dest_addr[47:40];
      dest_addr = dest_addr << 8;
    end
    else if (i < 12)
    begin
      eth_phy.rx_mem[buffer] = source_addr[47:40];
      source_addr = source_addr << 8;
    end
    else if (i < 14)
    begin
      eth_phy.rx_mem[buffer] = type_len[15:8];
      type_len = type_len << 8;
    end
    else
    begin
      eth_phy.rx_mem[buffer] = sd[7:0];
      sd = sd + 1;
    end
    buffer = buffer + 1;
  end
  delta_t = !delta_t;
  if (plus_dribble_nibble)
    eth_phy.rx_mem[buffer] = {4'h0, 4'hD /*sd[3:0]*/};
  delta_t = !delta_t;
end
endtask // set_rx_packet

task set_rx_packet_delayed;
  input  [31:0] rxpnt;
  input  [15:0] len;
  input         delayed_crc;
  input         plus_dribble_nibble; // if length is longer for one nibble
  input  [31:0] eth_data_preamble;
  input  [47:0] eth_dest_addr;
  input  [47:0] eth_source_addr;
  input  [15:0] eth_type_len;
  input  [7:0]  eth_start_data;
  integer       i, sd, start;
  reg    [16:0] tmp_len;
  reg    [47:0] dest_addr;
  reg    [47:0] source_addr;
  reg    [15:0] type_len;
  reg    [21:0] buffer;
  reg           delta_t;
begin
  buffer = rxpnt[21:0];
  dest_addr = eth_dest_addr;
  source_addr = eth_source_addr;
  type_len = eth_type_len;
  sd = eth_start_data;
  delta_t = 0;

  if (delayed_crc)
    begin
      tmp_len = len;
      start = 0;
    end
  else
    begin
      tmp_len = len+4;
      start = 4;
    end

  for(i = start; i < tmp_len; i = i + 1) 
  begin
    if (i < 4)
    begin
      eth_phy.rx_mem[buffer] = eth_data_preamble[31:24];
      eth_data_preamble = eth_data_preamble << 8;
    end
    else if (i < 10)
    begin
      eth_phy.rx_mem[buffer] = dest_addr[47:40];
      dest_addr = dest_addr << 8;
    end
    else if (i < 16)
    begin
      eth_phy.rx_mem[buffer] = source_addr[47:40];
      source_addr = source_addr << 8;
    end
    else if (i < 18)
    begin
      eth_phy.rx_mem[buffer] = type_len[15:8];
      type_len = type_len << 8;
    end
    else
    begin
      eth_phy.rx_mem[buffer] = sd[7:0];
      sd = sd + 1;
    end
    buffer = buffer + 1;
  end
  delta_t = !delta_t;
  if (plus_dribble_nibble)
    eth_phy.rx_mem[buffer] = {4'h0, 4'hD /*sd[3:0]*/};
  delta_t = !delta_t;
end
endtask // set_rx_packet_delayed

task set_rx_control_packet;
  input  [31:0] rxpnt;
  input  [15:0] PauseTV;
  integer       i;
  reg    [47:0] dest_addr;
  reg    [47:0] source_addr;
  reg    [15:0] type_len;
  reg    [21:0] buffer;
  reg           delta_t;
  reg    [15:0] PTV;
  reg    [15:0] opcode;
begin
  buffer = rxpnt[21:0];
  dest_addr = 48'h0180_c200_0001;
  source_addr = 48'h0708_090A_0B0C;
  type_len = 16'h8808;
  opcode = 16'h0001;
  PTV = PauseTV;
  delta_t = 0;
  for(i = 0; i < 60; i = i + 1) 
  begin
    if (i < 6)
    begin
      eth_phy.rx_mem[buffer] = dest_addr[47:40];
      dest_addr = dest_addr << 8;
    end
    else if (i < 12)
    begin
      eth_phy.rx_mem[buffer] = source_addr[47:40];
      source_addr = source_addr << 8;
    end
    else if (i < 14)
    begin
      eth_phy.rx_mem[buffer] = type_len[15:8];
      type_len = type_len << 8;
    end
    else if (i < 16)
    begin
      eth_phy.rx_mem[buffer] = opcode[15:8];
      opcode = opcode << 8;
    end
    else if (i < 18)
    begin
      eth_phy.rx_mem[buffer] = PTV[15:8];
      PTV = PTV << 8;
    end
    else
    begin
      eth_phy.rx_mem[buffer] = 0;
    end
    buffer = buffer + 1;
  end
  delta_t = !delta_t;
  append_rx_crc (rxpnt, 60, 1'b0, 1'b0); // CRC for control packet
end
endtask // set_rx_control_packet

task set_rx_addr_type;
  input  [31:0] rxpnt;
  input  [47:0] eth_dest_addr;
  input  [47:0] eth_source_addr;
  input  [15:0] eth_type_len;
  integer       i;
  reg    [47:0] dest_addr;
  reg    [47:0] source_addr;
  reg    [15:0] type_len;
  reg    [21:0] buffer;
  reg           delta_t;
begin
  buffer = rxpnt[21:0];
  dest_addr = eth_dest_addr;
  source_addr = eth_source_addr;
  type_len = eth_type_len;
  delta_t = 0;
  for(i = 0; i < 14; i = i + 1) 
  begin
    if (i < 6)
    begin
      eth_phy.rx_mem[buffer] = dest_addr[47:40];
      dest_addr = dest_addr << 8;
    end
    else if (i < 12)
    begin
      eth_phy.rx_mem[buffer] = source_addr[47:40];
      source_addr = source_addr << 8;
    end
    else // if (i < 14)
    begin
      eth_phy.rx_mem[buffer] = type_len[15:8];
      type_len = type_len << 8;
    end
    buffer = buffer + 1;
  end
  delta_t = !delta_t;
end
endtask // set_rx_addr_type

task check_rx_packet;
  input  [31:0] rxpnt_phy; // source
  input  [31:0] rxpnt_wb;  // destination
  input  [15:0] len;
  input         plus_dribble_nibble; // if length is longer for one nibble
  input         successful_dribble_nibble; // if additional nibble is stored into memory
  output [31:0] failure;
  integer       i, data_wb, data_phy;
  reg    [31:0] addr_wb, addr_phy;
  reg    [31:0] failure;
  reg    [21:0] buffer;
  reg           delta_t;
begin
  addr_phy = rxpnt_phy;
  addr_wb = rxpnt_wb;
  delta_t = 0;
  failure = 0;

  // First write might not be word allign.
  if(addr_wb[1:0] == 1)
  begin
    wb_slave.rd_mem(addr_wb[21:0] - 1, data_wb, 4'h7);
    data_phy[31:24] = 0;
    data_phy[23:16] = eth_phy.rx_mem[addr_phy[21:0]];
    data_phy[15: 8] = eth_phy.rx_mem[addr_phy[21:0] + 1];
    data_phy[ 7: 0] = eth_phy.rx_mem[addr_phy[21:0] + 2];
    i = 3;
    if (data_phy[23:0] !== data_wb[23:0])
    begin
      //`TIME;
      //$display("   addr_phy = %h, addr_wb = %h", rxpnt_phy, rxpnt_wb);
      //$display("*E Wrong 1. word (3 bytes) of RX packet! phy = %h, wb = %h", data_phy[23:0], data_wb[23:0]);
      failure = 1;
    end
  end
  else if (addr_wb[1:0] == 2)
  begin
    wb_slave.rd_mem(addr_wb[21:0] - 2, data_wb, 4'h3);
    data_phy[31:16] = 0;
    data_phy[15: 8] = eth_phy.rx_mem[addr_phy[21:0]];
    data_phy[ 7: 0] = eth_phy.rx_mem[addr_phy[21:0] + 1];
    i = 2;
    if (data_phy[15:0] !== data_wb[15:0])
    begin
      //`TIME;
      //$display("   addr_phy = %h, addr_wb = %h", rxpnt_phy, rxpnt_wb);
      //$display("*E Wrong 1. word (2 bytes) of RX packet! phy = %h, wb = %h", data_phy[15:0], data_wb[15:0]);
      failure = 1;
    end
  end
  else if (addr_wb[1:0] == 3)
  begin
    wb_slave.rd_mem(addr_wb[21:0] - 3, data_wb, 4'h1);
    data_phy[31: 8] = 0;
    data_phy[ 7: 0] = eth_phy.rx_mem[addr_phy[21:0]];
    i = 1;
    if (data_phy[7:0] !== data_wb[7:0])
    begin
      //`TIME;
      //$display("   addr_phy = %h, addr_wb = %h", rxpnt_phy, rxpnt_wb);
      //$display("*E Wrong 1. word (1 byte) of RX packet! phy = %h, wb = %h", data_phy[7:0], data_wb[7:0]);
      failure = 1;
    end
  end
  else
    i = 0;
  delta_t = !delta_t;

  for(i = i; i < (len - 4); i = i + 4) // Last 0-3 bytes are not checked
  begin
    wb_slave.rd_mem(addr_wb[21:0] + i, data_wb, 4'hF);
    data_phy[31:24] = eth_phy.rx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = eth_phy.rx_mem[addr_phy[21:0] + i + 1];
    data_phy[15: 8] = eth_phy.rx_mem[addr_phy[21:0] + i + 2];
    data_phy[ 7: 0] = eth_phy.rx_mem[addr_phy[21:0] + i + 3];
    if (data_phy[31:0] !== data_wb[31:0])
    begin
      //`TIME;
      //if (i == 0)
      //  $display("   addr_phy = %h, addr_wb = %h", rxpnt_phy, rxpnt_wb);
      //$display("*E Wrong %0d. word (4 bytes) of RX packet! phy = %h, wb = %h", ((i/4)+1), data_phy[31:0], data_wb[31:0]);
      failure = failure + 1;
    end
  end
  delta_t = !delta_t;

  // Last word
  if((len - i) == 3)
  begin
    wb_slave.rd_mem(addr_wb[21:0] + i, data_wb, 4'hF);
    data_phy[31:24] = eth_phy.rx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = eth_phy.rx_mem[addr_phy[21:0] + i + 1];
    data_phy[15: 8] = eth_phy.rx_mem[addr_phy[21:0] + i + 2];
    if (plus_dribble_nibble)
      data_phy[ 7: 0] = eth_phy.rx_mem[addr_phy[21:0] + i + 3];
    else
      data_phy[ 7: 0] = 0;
    if (data_phy[31:8] !== data_wb[31:8])
    begin
      //`TIME;
      //$display("*E Wrong %0d. word (3 bytes) of RX packet! phy = %h, wb = %h", ((i/4)+1), data_phy[31:8], data_wb[31:8]);
      failure = failure + 1;
    end
    if (plus_dribble_nibble && successful_dribble_nibble)
    begin
      if (data_phy[3:0] !== data_wb[3:0])
      begin
        //`TIME;
        //$display("*E Wrong dribble nibble in %0d. word (3 bytes) of RX packet!", ((i/4)+1));
        failure = failure + 1;
      end
    end
    else if (plus_dribble_nibble && !successful_dribble_nibble)
    begin
      if (data_phy[3:0] === data_wb[3:0])
      begin
        //`TIME;
        //$display("*E Wrong dribble nibble in %0d. word (3 bytes) of RX packet!", ((i/4)+1));
        failure = failure + 1;
      end
    end
  end
  else if((len - i) == 2)
  begin
    wb_slave.rd_mem(addr_wb[21:0] + i, data_wb, 4'hE);
    data_phy[31:24] = eth_phy.rx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = eth_phy.rx_mem[addr_phy[21:0] + i + 1];
    if (plus_dribble_nibble)
      data_phy[15: 8] = eth_phy.rx_mem[addr_phy[21:0] + i + 2];
    else
      data_phy[15: 8] = 0;
    data_phy[ 7: 0] = 0;
    if (data_phy[31:16] !== data_wb[31:16])
    begin
      //`TIME;
      //$display("*E Wrong %0d. word (2 bytes) of RX packet! phy = %h, wb = %h", ((i/4)+1), data_phy[31:16], data_wb[31:16]);
      failure = failure + 1;
    end
    if (plus_dribble_nibble && successful_dribble_nibble)
    begin
      if (data_phy[11:8] !== data_wb[11:8])
      begin
        //`TIME;
        //$display("*E Wrong dribble nibble in %0d. word (2 bytes) of RX packet!", ((i/4)+1));
        failure = failure + 1;
      end
    end
    else if (plus_dribble_nibble && !successful_dribble_nibble)
    begin
      if (data_phy[11:8] === data_wb[11:8])
      begin
        //`TIME;
        //$display("*E Wrong dribble nibble in %0d. word (2 bytes) of RX packet!", ((i/4)+1));
        failure = failure + 1;
      end
    end
  end
  else if((len - i) == 1)
  begin
    wb_slave.rd_mem(addr_wb[21:0] + i, data_wb, 4'hC);
    data_phy[31:24] = eth_phy.rx_mem[addr_phy[21:0] + i];
    if (plus_dribble_nibble)
      data_phy[23:16] = eth_phy.rx_mem[addr_phy[21:0] + i + 1];
    else
      data_phy[23:16] = 0;
    data_phy[15: 8] = 0;
    data_phy[ 7: 0] = 0;
    if (data_phy[31:24] !== data_wb[31:24])
    begin
      //`TIME;
      //$display("*E Wrong %0d. word (1 byte) of RX packet! phy = %h, wb = %h", ((i/4)+1), data_phy[31:24], data_wb[31:24]);
      failure = failure + 1;
    end
    if (plus_dribble_nibble && successful_dribble_nibble)
    begin
      if (data_phy[19:16] !== data_wb[19:16])
      begin
        //`TIME;
        //$display("*E Wrong dribble nibble in %0d. word (1 byte) of RX packet!", ((i/4)+1));
        failure = failure + 1;
      end
    end
    else if (plus_dribble_nibble && !successful_dribble_nibble)
    begin
      if (data_phy[19:16] === data_wb[19:16])
      begin
        //`TIME;
        //$display("*E Wrong dribble nibble in %0d. word (1 byte) of RX packet!", ((i/4)+1));
        failure = failure + 1;
      end
    end
  end
  else if((len - i) == 4)
  begin
    wb_slave.rd_mem(addr_wb[21:0] + i, data_wb, 4'hF);
    data_phy[31:24] = eth_phy.rx_mem[addr_phy[21:0] + i];
    data_phy[23:16] = eth_phy.rx_mem[addr_phy[21:0] + i + 1];
    data_phy[15: 8] = eth_phy.rx_mem[addr_phy[21:0] + i + 2];
    data_phy[ 7: 0] = eth_phy.rx_mem[addr_phy[21:0] + i + 3];
    if (data_phy[31:0] !== data_wb[31:0])
    begin
      //`TIME;
      //$display("*E Wrong %0d. word (4 bytes) of RX packet! phy = %h, wb = %h", ((i/4)+1), data_phy[31:0], data_wb[31:0]);
      failure = failure + 1;
    end
    if (plus_dribble_nibble)
    begin
      wb_slave.rd_mem(addr_wb[21:0] + i + 4, data_wb, 4'h8);
      data_phy[31:24] = eth_phy.rx_mem[addr_phy[21:0] + i + 4];
      if (successful_dribble_nibble)
      begin
        if (data_phy[27:24] !== data_wb[27:24])
        begin
          //`TIME;
          //$display("*E Wrong dribble nibble in %0d. word (0 bytes) of RX packet!", ((i/4)+2));
          failure = failure + 1;
        end
      end
      else
      begin
        if (data_phy[27:24] === data_wb[27:24])
        begin
          //`TIME;
          //$display("*E Wrong dribble nibble in %0d. word (0 bytes) of RX packet!", ((i/4)+2));
          failure = failure + 1;
        end
      end
    end
  end
  else
    $display("(%0t)(%m) ERROR", $time);
  delta_t = !delta_t;
end
endtask // check_rx_packet

//////////////////////////////////////////////////////////////
// Ethernet CRC Basic tasks
//////////////////////////////////////////////////////////////

task append_tx_crc;
  input  [31:0] txpnt_wb;  // source
  input  [15:0] len; // length in bytes without CRC
  input         negated_crc; // if appended CRC is correct or not
  reg    [31:0] crc;
  reg    [31:0] addr_wb;
  reg           delta_t;
begin
  addr_wb = txpnt_wb + {16'h0, len};
  delta_t = 0;
  // calculate CRC from prepared packet
  paralel_crc_mac(txpnt_wb, {16'h0, len}, 1'b0, crc);
  if (negated_crc)
    crc = ~crc;
  delta_t = !delta_t;

  // Write might not be word allign.
  if (addr_wb[1:0] == 1)
  begin
    wb_slave.wr_mem(addr_wb - 1, {8'h0, crc[7:0], crc[15:8], crc[23:16]}, 4'h7);
    wb_slave.wr_mem(addr_wb + 3, {crc[31:24], 24'h0}, 4'h8);
  end
  else if (addr_wb[1:0] == 2)
  begin
    wb_slave.wr_mem(addr_wb - 2, {16'h0, crc[7:0], crc[15:8]}, 4'h3);
    wb_slave.wr_mem(addr_wb + 2, {crc[23:16], crc[31:24], 16'h0}, 4'hC);
  end
  else if (addr_wb[1:0] == 3)
  begin
    wb_slave.wr_mem(addr_wb - 3, {24'h0, crc[7:0]}, 4'h1);
    wb_slave.wr_mem(addr_wb + 1, {crc[15:8], crc[23:16], crc[31:24], 8'h0}, 4'hE);
  end
  else
  begin
//    wb_slave.wr_mem(addr_wb, {crc[7:0], crc[15:8], crc[23:16], crc[31:24]}, 4'hF);
    wb_slave.wr_mem(addr_wb, crc[31:0], 4'hF);
  end
  delta_t = !delta_t;
end
endtask // append_tx_crc

task check_tx_crc; // used to check crc added to TX packets by MAC
  input  [31:0] txpnt_phy; // destination
  input  [15:0] len; // length in bytes without CRC
  input         negated_crc; // if appended CRC is correct or not
  output [31:0] failure;
  reg    [31:0] failure;
  reg    [31:0] crc_calc;
  reg    [31:0] crc;
  reg    [31:0] addr_phy;
  reg           delta_t;
begin
  addr_phy = txpnt_phy;
  failure = 0;
  // calculate CRC from sent packet
//  serial_crc_phy_tx(addr_phy, {16'h0, len}, 1'b0, crc_calc);
//#10;
  paralel_crc_phy_tx(addr_phy, {16'h0, len}, 1'b0, crc_calc);
  #1;
  addr_phy = addr_phy + len;
  // Read CRC - BIG endian
  crc[31:24] = eth_phy.tx_mem[addr_phy[21:0]];
  crc[23:16] = eth_phy.tx_mem[addr_phy[21:0] + 1];
  crc[15: 8] = eth_phy.tx_mem[addr_phy[21:0] + 2];
  crc[ 7: 0] = eth_phy.tx_mem[addr_phy[21:0] + 3];

  delta_t = !delta_t;
  if (negated_crc)
  begin
    if ((~crc_calc) !== crc)
    begin
      `TIME;
      $display("*E Negated CRC was not successfuly transmitted!");
      failure = failure + 1;
    end
  end
  else
  begin
    if (crc_calc !== crc)
    begin
      `TIME;
      $display("*E Transmitted CRC was not correct; crc_calc: %0h, crc_mem: %0h", crc_calc, crc);
      failure = failure + 1;
    end
  end
  delta_t = !delta_t;
end
endtask // check_tx_crc

task check_tx_crc_delayed; // used to check crc added to TX packets by MAC
  input  [31:0] txpnt_phy; // destination
  input  [15:0] len; // length in bytes without CRC
  input         negated_crc; // if appended CRC is correct or not
  output [31:0] failure;
  reg    [31:0] failure;
  reg    [31:0] crc_calc;
  reg    [31:0] crc;
  reg    [31:0] addr_phy;
  reg           delta_t;
begin
  addr_phy = txpnt_phy;
  failure = 0;
  // calculate CRC from sent packet
//  serial_crc_phy_tx(addr_phy, {16'h0, len}, 1'b0, crc_calc);
//#10;
  paralel_crc_phy_tx(addr_phy+4, {16'h0, len}-4, 1'b0, crc_calc);
  #1;
  addr_phy = addr_phy + len;
  // Read CRC - BIG endian
  crc[31:24] = eth_phy.tx_mem[addr_phy[21:0]];
  crc[23:16] = eth_phy.tx_mem[addr_phy[21:0] + 1];
  crc[15: 8] = eth_phy.tx_mem[addr_phy[21:0] + 2];
  crc[ 7: 0] = eth_phy.tx_mem[addr_phy[21:0] + 3];

  delta_t = !delta_t;
  if (negated_crc)
  begin
    if ((~crc_calc) !== crc)
    begin
      `TIME;
      $display("*E Negated CRC was not successfuly transmitted!");
      failure = failure + 1;
    end
  end
  else
  begin
    if (crc_calc !== crc)
    begin
      `TIME;
      $display("*E Transmitted CRC was not correct; crc_calc: %0h, crc_mem: %0h", crc_calc, crc);
      failure = failure + 1;
    end
  end
  delta_t = !delta_t;
end
endtask // check_tx_crc_delayed

task append_rx_crc;
  input  [31:0] rxpnt_phy; // source
  input  [15:0] len; // length in bytes without CRC
  input         plus_dribble_nibble; // if length is longer for one nibble
  input         negated_crc; // if appended CRC is correct or not
  reg    [31:0] crc;
  reg    [7:0]  tmp;
  reg    [31:0] addr_phy;
  reg           delta_t;
begin
  addr_phy = rxpnt_phy + len;
  delta_t = 0;
  // calculate CRC from prepared packet
  paralel_crc_phy_rx(rxpnt_phy, {16'h0, len}, plus_dribble_nibble, crc);
  if (negated_crc)
    crc = ~crc;
  delta_t = !delta_t;

  if (plus_dribble_nibble)
  begin
    tmp = eth_phy.rx_mem[addr_phy];
    eth_phy.rx_mem[addr_phy]     = {crc[27:24], tmp[3:0]};
    eth_phy.rx_mem[addr_phy + 1] = {crc[19:16], crc[31:28]};
    eth_phy.rx_mem[addr_phy + 2] = {crc[11:8], crc[23:20]};
    eth_phy.rx_mem[addr_phy + 3] = {crc[3:0], crc[15:12]};
    eth_phy.rx_mem[addr_phy + 4] = {4'h0, crc[7:4]};
  end
  else
  begin
    eth_phy.rx_mem[addr_phy]     = crc[31:24];
    eth_phy.rx_mem[addr_phy + 1] = crc[23:16];
    eth_phy.rx_mem[addr_phy + 2] = crc[15:8];
    eth_phy.rx_mem[addr_phy + 3] = crc[7:0];
  end
end
endtask // append_rx_crc

task append_rx_crc_delayed;
  input  [31:0] rxpnt_phy; // source
  input  [15:0] len; // length in bytes without CRC
  input         plus_dribble_nibble; // if length is longer for one nibble
  input         negated_crc; // if appended CRC is correct or not
  reg    [31:0] crc;
  reg    [7:0]  tmp;
  reg    [31:0] addr_phy;
  reg           delta_t;
begin
  addr_phy = rxpnt_phy + len;
  delta_t = 0;
  // calculate CRC from prepared packet
  paralel_crc_phy_rx(rxpnt_phy+4, {16'h0, len}-4, plus_dribble_nibble, crc);
  if (negated_crc)
    crc = ~crc;
  delta_t = !delta_t;

  if (plus_dribble_nibble)
  begin
    tmp = eth_phy.rx_mem[addr_phy];
    eth_phy.rx_mem[addr_phy]     = {crc[27:24], tmp[3:0]};
    eth_phy.rx_mem[addr_phy + 1] = {crc[19:16], crc[31:28]};
    eth_phy.rx_mem[addr_phy + 2] = {crc[11:8], crc[23:20]};
    eth_phy.rx_mem[addr_phy + 3] = {crc[3:0], crc[15:12]};
    eth_phy.rx_mem[addr_phy + 4] = {4'h0, crc[7:4]};
  end
  else
  begin
    eth_phy.rx_mem[addr_phy]     = crc[31:24];
    eth_phy.rx_mem[addr_phy + 1] = crc[23:16];
    eth_phy.rx_mem[addr_phy + 2] = crc[15:8];
    eth_phy.rx_mem[addr_phy + 3] = crc[7:0];
  end
end
endtask // append_rx_crc_delayed

// paralel CRC checking for PHY TX
task paralel_crc_phy_tx;
  input  [31:0] start_addr; // start address
  input  [31:0] len; // length of frame in Bytes without CRC length
  input         plus_dribble_nibble; // if length is longer for one nibble
  output [31:0] crc_out;
  reg    [21:0] addr_cnt; // only 22 address lines
  integer       word_cnt;
  integer       nibble_cnt;
  reg    [31:0] load_reg;
  reg           delta_t;
  reg    [31:0] crc_next;
  reg    [31:0] crc;
  reg           crc_error;
  reg     [3:0] data_in;
  integer       i;
begin
  #1 addr_cnt = start_addr[21:0];
  word_cnt = 24; // 27; // start of the frame - nibble granularity (MSbit first)
  crc = 32'hFFFF_FFFF; // INITIAL value
  delta_t = 0;
  // length must include 4 bytes of ZEROs, to generate CRC
  // get number of nibbles from Byte length (2^1 = 2)
  if (plus_dribble_nibble)
    nibble_cnt = ((len + 4) << 1) + 1'b1; // one nibble longer
  else
    nibble_cnt = ((len + 4) << 1);
  // because of MAGIC NUMBER nibbles are swapped [3:0] -> [0:3]
  load_reg[31:24] = eth_phy.tx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[23:16] = eth_phy.tx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[15: 8] = eth_phy.tx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[ 7: 0] = eth_phy.tx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  while (nibble_cnt > 0)
  begin
    // wait for delta time
    delta_t = !delta_t;
    // shift data in

    if(nibble_cnt <= 8) // for additional 8 nibbles shift ZEROs in!
      data_in[3:0] = 4'h0;
    else

      data_in[3:0] = {load_reg[word_cnt], load_reg[word_cnt+1], load_reg[word_cnt+2], load_reg[word_cnt+3]};
    crc_next[0]  = (data_in[0] ^ crc[28]);
    crc_next[1]  = (data_in[1] ^ data_in[0] ^ crc[28]    ^ crc[29]);
    crc_next[2]  = (data_in[2] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[30]);
    crc_next[3]  = (data_in[3] ^ data_in[2] ^ data_in[1] ^ crc[29]  ^ crc[30] ^ crc[31]);
    crc_next[4]  = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[0];
    crc_next[5]  = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[1];
    crc_next[6]  = (data_in[2] ^ data_in[1] ^ crc[29]    ^ crc[30]) ^ crc[ 2];
    crc_next[7]  = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[3];
    crc_next[8]  = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[4];
    crc_next[9]  = (data_in[2] ^ data_in[1] ^ crc[29]    ^ crc[30]) ^ crc[5];
    crc_next[10] = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[6];
    crc_next[11] = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[7];
    crc_next[12] = (data_in[2] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[30]) ^ crc[8];
    crc_next[13] = (data_in[3] ^ data_in[2] ^ data_in[1] ^ crc[29]  ^ crc[30] ^ crc[31]) ^ crc[9];
    crc_next[14] = (data_in[3] ^ data_in[2] ^ crc[30]    ^ crc[31]) ^ crc[10];
    crc_next[15] = (data_in[3] ^ crc[31])   ^ crc[11];
    crc_next[16] = (data_in[0] ^ crc[28])   ^ crc[12];
    crc_next[17] = (data_in[1] ^ crc[29])   ^ crc[13];
    crc_next[18] = (data_in[2] ^ crc[30])   ^ crc[14];
    crc_next[19] = (data_in[3] ^ crc[31])   ^ crc[15];
    crc_next[20] =  crc[16];
    crc_next[21] =  crc[17];
    crc_next[22] = (data_in[0] ^ crc[28])   ^ crc[18];
    crc_next[23] = (data_in[1] ^ data_in[0] ^ crc[29]    ^ crc[28]) ^ crc[19];
    crc_next[24] = (data_in[2] ^ data_in[1] ^ crc[30]    ^ crc[29]) ^ crc[20];
    crc_next[25] = (data_in[3] ^ data_in[2] ^ crc[31]    ^ crc[30]) ^ crc[21];
    crc_next[26] = (data_in[3] ^ data_in[0] ^ crc[31]    ^ crc[28]) ^ crc[22];
    crc_next[27] = (data_in[1] ^ crc[29])   ^ crc[23];
    crc_next[28] = (data_in[2] ^ crc[30])   ^ crc[24];
    crc_next[29] = (data_in[3] ^ crc[31])   ^ crc[25];
    crc_next[30] =  crc[26];
    crc_next[31] =  crc[27];

    crc = crc_next;
    crc_error = crc[31:0] != 32'hc704dd7b;  // CRC not equal to magic number
    case (nibble_cnt)
    9: crc_out = {!crc[24], !crc[25], !crc[26], !crc[27], !crc[28], !crc[29], !crc[30], !crc[31],
                  !crc[16], !crc[17], !crc[18], !crc[19], !crc[20], !crc[21], !crc[22], !crc[23],
                  !crc[ 8], !crc[ 9], !crc[10], !crc[11], !crc[12], !crc[13], !crc[14], !crc[15],
                  !crc[ 0], !crc[ 1], !crc[ 2], !crc[ 3], !crc[ 4], !crc[ 5], !crc[ 6], !crc[ 7]};
    default: crc_out = crc_out;
    endcase
    // wait for delta time
    delta_t = !delta_t;
    // increment address and load new data
    if ((word_cnt+3) == 7)//4)
    begin
      // because of MAGIC NUMBER nibbles are swapped [3:0] -> [0:3]
      load_reg[31:24] = eth_phy.tx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[23:16] = eth_phy.tx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[15: 8] = eth_phy.tx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[ 7: 0] = eth_phy.tx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
    end
    // set new load bit position
    if((word_cnt+3) == 31)
      word_cnt = 16;
    else if ((word_cnt+3) == 23)
      word_cnt = 8;
    else if ((word_cnt+3) == 15)
      word_cnt = 0;
    else if ((word_cnt+3) == 7)
      word_cnt = 24;
    else
      word_cnt = word_cnt + 4;// - 4;
    // decrement nibble counter
    nibble_cnt = nibble_cnt - 1;
    // wait for delta time
    delta_t = !delta_t;
  end // while
  #1;
end
endtask // paralel_crc_phy_tx

// paralel CRC calculating for PHY RX
task paralel_crc_phy_rx;
  input  [31:0] start_addr; // start address
  input  [31:0] len; // length of frame in Bytes without CRC length
  input         plus_dribble_nibble; // if length is longer for one nibble
  output [31:0] crc_out;
  reg    [21:0] addr_cnt; // only 22 address lines
  integer       word_cnt;
  integer       nibble_cnt;
  reg    [31:0] load_reg;
  reg           delta_t;
  reg    [31:0] crc_next;
  reg    [31:0] crc;
  reg           crc_error;
  reg     [3:0] data_in;
  integer       i;
begin
  #1 addr_cnt = start_addr[21:0];
  word_cnt = 24; // 27; // start of the frame - nibble granularity (MSbit first)
  crc = 32'hFFFF_FFFF; // INITIAL value
  delta_t = 0;
  // length must include 4 bytes of ZEROs, to generate CRC
  // get number of nibbles from Byte length (2^1 = 2)
  if (plus_dribble_nibble)
    nibble_cnt = ((len + 4) << 1) + 1'b1; // one nibble longer
  else
    nibble_cnt = ((len + 4) << 1);
  // because of MAGIC NUMBER nibbles are swapped [3:0] -> [0:3]
  load_reg[31:24] = eth_phy.rx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[23:16] = eth_phy.rx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[15: 8] = eth_phy.rx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[ 7: 0] = eth_phy.rx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  while (nibble_cnt > 0)
  begin
    // wait for delta time
    delta_t = !delta_t;
    // shift data in

    if(nibble_cnt <= 8) // for additional 8 nibbles shift ZEROs in!
      data_in[3:0] = 4'h0;
    else

      data_in[3:0] = {load_reg[word_cnt], load_reg[word_cnt+1], load_reg[word_cnt+2], load_reg[word_cnt+3]};
    crc_next[0]  = (data_in[0] ^ crc[28]);
    crc_next[1]  = (data_in[1] ^ data_in[0] ^ crc[28]    ^ crc[29]);
    crc_next[2]  = (data_in[2] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[30]);
    crc_next[3]  = (data_in[3] ^ data_in[2] ^ data_in[1] ^ crc[29]  ^ crc[30] ^ crc[31]);
    crc_next[4]  = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[0];
    crc_next[5]  = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[1];
    crc_next[6]  = (data_in[2] ^ data_in[1] ^ crc[29]    ^ crc[30]) ^ crc[ 2];
    crc_next[7]  = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[3];
    crc_next[8]  = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[4];
    crc_next[9]  = (data_in[2] ^ data_in[1] ^ crc[29]    ^ crc[30]) ^ crc[5];
    crc_next[10] = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[6];
    crc_next[11] = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[7];
    crc_next[12] = (data_in[2] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[30]) ^ crc[8];
    crc_next[13] = (data_in[3] ^ data_in[2] ^ data_in[1] ^ crc[29]  ^ crc[30] ^ crc[31]) ^ crc[9];
    crc_next[14] = (data_in[3] ^ data_in[2] ^ crc[30]    ^ crc[31]) ^ crc[10];
    crc_next[15] = (data_in[3] ^ crc[31])   ^ crc[11];
    crc_next[16] = (data_in[0] ^ crc[28])   ^ crc[12];
    crc_next[17] = (data_in[1] ^ crc[29])   ^ crc[13];
    crc_next[18] = (data_in[2] ^ crc[30])   ^ crc[14];
    crc_next[19] = (data_in[3] ^ crc[31])   ^ crc[15];
    crc_next[20] =  crc[16];
    crc_next[21] =  crc[17];
    crc_next[22] = (data_in[0] ^ crc[28])   ^ crc[18];
    crc_next[23] = (data_in[1] ^ data_in[0] ^ crc[29]    ^ crc[28]) ^ crc[19];
    crc_next[24] = (data_in[2] ^ data_in[1] ^ crc[30]    ^ crc[29]) ^ crc[20];
    crc_next[25] = (data_in[3] ^ data_in[2] ^ crc[31]    ^ crc[30]) ^ crc[21];
    crc_next[26] = (data_in[3] ^ data_in[0] ^ crc[31]    ^ crc[28]) ^ crc[22];
    crc_next[27] = (data_in[1] ^ crc[29])   ^ crc[23];
    crc_next[28] = (data_in[2] ^ crc[30])   ^ crc[24];
    crc_next[29] = (data_in[3] ^ crc[31])   ^ crc[25];
    crc_next[30] =  crc[26];
    crc_next[31] =  crc[27];

    crc = crc_next;
    crc_error = crc[31:0] != 32'hc704dd7b;  // CRC not equal to magic number
    case (nibble_cnt)
    9: crc_out = {!crc[24], !crc[25], !crc[26], !crc[27], !crc[28], !crc[29], !crc[30], !crc[31],
                  !crc[16], !crc[17], !crc[18], !crc[19], !crc[20], !crc[21], !crc[22], !crc[23],
                  !crc[ 8], !crc[ 9], !crc[10], !crc[11], !crc[12], !crc[13], !crc[14], !crc[15],
                  !crc[ 0], !crc[ 1], !crc[ 2], !crc[ 3], !crc[ 4], !crc[ 5], !crc[ 6], !crc[ 7]};
    default: crc_out = crc_out;
    endcase
    // wait for delta time
    delta_t = !delta_t;
    // increment address and load new data
    if ((word_cnt+3) == 7)//4)
    begin
      // because of MAGIC NUMBER nibbles are swapped [3:0] -> [0:3]
      load_reg[31:24] = eth_phy.rx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[23:16] = eth_phy.rx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[15: 8] = eth_phy.rx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[ 7: 0] = eth_phy.rx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
    end
    // set new load bit position
    if((word_cnt+3) == 31)
      word_cnt = 16;
    else if ((word_cnt+3) == 23)
      word_cnt = 8;
    else if ((word_cnt+3) == 15)
      word_cnt = 0;
    else if ((word_cnt+3) == 7)
      word_cnt = 24;
    else
      word_cnt = word_cnt + 4;// - 4;
    // decrement nibble counter
    nibble_cnt = nibble_cnt - 1;
    // wait for delta time
    delta_t = !delta_t;
  end // while
  #1;
end
endtask // paralel_crc_phy_rx

// paralel CRC checking for MAC
task paralel_crc_mac;
  input  [31:0] start_addr; // start address
  input  [31:0] len; // length of frame in Bytes without CRC length
  input         plus_dribble_nibble; // if length is longer for one nibble
  output [31:0] crc_out;

  reg    [21:0] addr_cnt; // only 22 address lines
  integer       word_cnt;
  integer       nibble_cnt;
  reg    [31:0] load_reg;
  reg           delta_t;
  reg    [31:0] crc_next;
  reg    [31:0] crc;
  reg           crc_error;
  reg     [3:0] data_in;
  integer       i;
begin
  #1 addr_cnt = start_addr[19:0];
  // set starting point depending with which byte frame starts (e.g. if addr_cnt[1:0] == 0, then
  //   MSB of the packet must be written to the LSB of Big ENDIAN Word [31:24])
  if (addr_cnt[1:0] == 2'h1)
    word_cnt = 16; // start of the frame for Big ENDIAN Bytes (Litle ENDIAN bits)
  else if (addr_cnt[1:0] == 2'h2)
    word_cnt = 8; // start of the frame for Big ENDIAN Bytes (Litle ENDIAN bits)
  else if (addr_cnt[1:0] == 2'h3)
    word_cnt = 0; // start of the frame for Big ENDIAN Bytes (Litle ENDIAN bits)
  else 
    word_cnt = 24; // start of the frame for Big ENDIAN Bytes (Litle ENDIAN bits)
  crc = 32'hFFFF_FFFF; // INITIAL value
  delta_t = 0;
  // length must include 4 bytes of ZEROs, to generate CRC
  // get number of nibbles from Byte length (2^1 = 2)
  if (plus_dribble_nibble)
    nibble_cnt = ((len + 4) << 1) + 1'b1; // one nibble longer
  else
    nibble_cnt = ((len + 4) << 1);
  load_reg = wb_slave.wb_memory[{12'h0, addr_cnt[21:2]}];
  addr_cnt = addr_cnt + 4;
  while (nibble_cnt > 0)
  begin
    // wait for delta time
    delta_t = !delta_t;
    // shift data in

    if(nibble_cnt <= 8) // for additional 8 nibbles shift ZEROs in!
      data_in[3:0] = 4'h0;
    else

      data_in[3:0] = {load_reg[word_cnt], load_reg[word_cnt+1], load_reg[word_cnt+2], load_reg[word_cnt+3]};
    crc_next[0]  = (data_in[0] ^ crc[28]);
    crc_next[1]  = (data_in[1] ^ data_in[0] ^ crc[28]    ^ crc[29]);
    crc_next[2]  = (data_in[2] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[30]);
    crc_next[3]  = (data_in[3] ^ data_in[2] ^ data_in[1] ^ crc[29]  ^ crc[30] ^ crc[31]);
    crc_next[4]  = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[0];
    crc_next[5]  = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[1];
    crc_next[6]  = (data_in[2] ^ data_in[1] ^ crc[29]    ^ crc[30]) ^ crc[ 2];
    crc_next[7]  = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[3];
    crc_next[8]  = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[4];
    crc_next[9]  = (data_in[2] ^ data_in[1] ^ crc[29]    ^ crc[30]) ^ crc[5];
    crc_next[10] = (data_in[3] ^ data_in[2] ^ data_in[0] ^ crc[28]  ^ crc[30] ^ crc[31]) ^ crc[6];
    crc_next[11] = (data_in[3] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[31]) ^ crc[7];
    crc_next[12] = (data_in[2] ^ data_in[1] ^ data_in[0] ^ crc[28]  ^ crc[29] ^ crc[30]) ^ crc[8];
    crc_next[13] = (data_in[3] ^ data_in[2] ^ data_in[1] ^ crc[29]  ^ crc[30] ^ crc[31]) ^ crc[9];
    crc_next[14] = (data_in[3] ^ data_in[2] ^ crc[30]    ^ crc[31]) ^ crc[10];
    crc_next[15] = (data_in[3] ^ crc[31])   ^ crc[11];
    crc_next[16] = (data_in[0] ^ crc[28])   ^ crc[12];
    crc_next[17] = (data_in[1] ^ crc[29])   ^ crc[13];
    crc_next[18] = (data_in[2] ^ crc[30])   ^ crc[14];
    crc_next[19] = (data_in[3] ^ crc[31])   ^ crc[15];
    crc_next[20] =  crc[16];
    crc_next[21] =  crc[17];
    crc_next[22] = (data_in[0] ^ crc[28])   ^ crc[18];
    crc_next[23] = (data_in[1] ^ data_in[0] ^ crc[29]    ^ crc[28]) ^ crc[19];
    crc_next[24] = (data_in[2] ^ data_in[1] ^ crc[30]    ^ crc[29]) ^ crc[20];
    crc_next[25] = (data_in[3] ^ data_in[2] ^ crc[31]    ^ crc[30]) ^ crc[21];
    crc_next[26] = (data_in[3] ^ data_in[0] ^ crc[31]    ^ crc[28]) ^ crc[22];
    crc_next[27] = (data_in[1] ^ crc[29])   ^ crc[23];
    crc_next[28] = (data_in[2] ^ crc[30])   ^ crc[24];
    crc_next[29] = (data_in[3] ^ crc[31])   ^ crc[25];
    crc_next[30] =  crc[26];
    crc_next[31] =  crc[27];

    crc = crc_next;
    crc_error = crc[31:0] != 32'hc704dd7b;  // CRC not equal to magic number
    case (nibble_cnt)
    9: crc_out = {!crc[24], !crc[25], !crc[26], !crc[27], !crc[28], !crc[29], !crc[30], !crc[31],
                  !crc[16], !crc[17], !crc[18], !crc[19], !crc[20], !crc[21], !crc[22], !crc[23],
                  !crc[ 8], !crc[ 9], !crc[10], !crc[11], !crc[12], !crc[13], !crc[14], !crc[15],
                  !crc[ 0], !crc[ 1], !crc[ 2], !crc[ 3], !crc[ 4], !crc[ 5], !crc[ 6], !crc[ 7]};
    default: crc_out = crc_out;
    endcase
    // wait for delta time
    delta_t = !delta_t;
    // increment address and load new data
    if ((word_cnt+3) == 7)//4)
    begin
      // because of MAGIC NUMBER nibbles are swapped [3:0] -> [0:3]
      load_reg = wb_slave.wb_memory[{12'h0, addr_cnt[21:2]}];
      addr_cnt = addr_cnt + 4;
    end
    // set new load bit position
    if((word_cnt+3) == 31)
      word_cnt = 16;
    else if ((word_cnt+3) == 23)
      word_cnt = 8;
    else if ((word_cnt+3) == 15)
      word_cnt = 0;
    else if ((word_cnt+3) == 7)
      word_cnt = 24;
    else
      word_cnt = word_cnt + 4;// - 4;
    // decrement nibble counter
    nibble_cnt = nibble_cnt - 1;
    // wait for delta time
    delta_t = !delta_t;
  end // while
  #1;
end
endtask // paralel_crc_mac

// serial CRC checking for PHY TX
task serial_crc_phy_tx;
  input  [31:0] start_addr; // start address
  input  [31:0] len; // length of frame in Bytes without CRC length
  input         plus_dribble_nibble; // if length is longer for one nibble
  output [31:0] crc;
  reg    [21:0] addr_cnt; // only 22 address lines
  integer       word_cnt;
  integer       bit_cnt;
  reg    [31:0] load_reg;
  reg    [31:0] crc_shift_reg;
  reg    [31:0] crc_store_reg;
  reg           delta_t;
begin
  #1 addr_cnt = start_addr[21:0];
  word_cnt = 24; // 27; // start of the frame - nibble granularity (MSbit first)
  crc_store_reg = 32'hFFFF_FFFF; // INITIAL value
  delta_t = 0;
  // length must include 4 bytes of ZEROs, to generate CRC
  // get number of bits from Byte length (2^3 = 8)
  if (plus_dribble_nibble)
    bit_cnt = ((len + 4) << 3) + 3'h4; // one nibble longer
  else
    bit_cnt = ((len + 4) << 3);
  // because of MAGIC NUMBER nibbles are swapped [3:0] -> [0:3]
  load_reg[31:24] = eth_phy.tx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[23:16] = eth_phy.tx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[15: 8] = eth_phy.tx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[ 7: 0] = eth_phy.tx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
#1;
  while (bit_cnt > 0)
  begin
    // wait for delta time
    delta_t = !delta_t;
#1;
    // shift data in

    if(bit_cnt <= 32) // for additional 32 bits shift ZEROs in!
     crc_shift_reg[0] = 1'b0               ^ crc_store_reg[31];
    else

     crc_shift_reg[0] = load_reg[word_cnt] ^ crc_store_reg[31];
    crc_shift_reg[1]  = crc_store_reg[0]   ^ crc_store_reg[31];
    crc_shift_reg[2]  = crc_store_reg[1]   ^ crc_store_reg[31];
    crc_shift_reg[3]  = crc_store_reg[2];
    crc_shift_reg[4]  = crc_store_reg[3]   ^ crc_store_reg[31];
    crc_shift_reg[5]  = crc_store_reg[4]   ^ crc_store_reg[31];
    crc_shift_reg[6]  = crc_store_reg[5];
    crc_shift_reg[7]  = crc_store_reg[6]   ^ crc_store_reg[31];
    crc_shift_reg[8]  = crc_store_reg[7]   ^ crc_store_reg[31];
    crc_shift_reg[9]  = crc_store_reg[8];
    crc_shift_reg[10] = crc_store_reg[9]   ^ crc_store_reg[31];
    crc_shift_reg[11] = crc_store_reg[10]  ^ crc_store_reg[31];
    crc_shift_reg[12] = crc_store_reg[11]  ^ crc_store_reg[31];
    crc_shift_reg[13] = crc_store_reg[12];
    crc_shift_reg[14] = crc_store_reg[13];
    crc_shift_reg[15] = crc_store_reg[14];
    crc_shift_reg[16] = crc_store_reg[15]  ^ crc_store_reg[31];
    crc_shift_reg[17] = crc_store_reg[16];
    crc_shift_reg[18] = crc_store_reg[17];
    crc_shift_reg[19] = crc_store_reg[18];
    crc_shift_reg[20] = crc_store_reg[19];
    crc_shift_reg[21] = crc_store_reg[20];
    crc_shift_reg[22] = crc_store_reg[21]  ^ crc_store_reg[31];
    crc_shift_reg[23] = crc_store_reg[22]  ^ crc_store_reg[31];
    crc_shift_reg[24] = crc_store_reg[23];
    crc_shift_reg[25] = crc_store_reg[24];
    crc_shift_reg[26] = crc_store_reg[25]  ^ crc_store_reg[31];
    crc_shift_reg[27] = crc_store_reg[26];
    crc_shift_reg[28] = crc_store_reg[27];
    crc_shift_reg[29] = crc_store_reg[28];
    crc_shift_reg[30] = crc_store_reg[29];
    crc_shift_reg[31] = crc_store_reg[30];
    // wait for delta time
    delta_t = !delta_t;

    // store previous data
    crc_store_reg = crc_shift_reg;

    // put CRC out
    case (bit_cnt)
    33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 1:
    begin
      crc = crc_store_reg;
      crc = {!crc[24], !crc[25], !crc[26], !crc[27], !crc[28], !crc[29], !crc[30], !crc[31],
             !crc[16], !crc[17], !crc[18], !crc[19], !crc[20], !crc[21], !crc[22], !crc[23],
             !crc[ 8], !crc[ 9], !crc[10], !crc[11], !crc[12], !crc[13], !crc[14], !crc[15],
             !crc[ 0], !crc[ 1], !crc[ 2], !crc[ 3], !crc[ 4], !crc[ 5], !crc[ 6], !crc[ 7]};
    end
    default: crc = crc;
    endcase

    // increment address and load new data
#1;
    if (word_cnt == 7)//4)
    begin
      // because of MAGIC NUMBER nibbles are swapped [3:0] -> [0:3]
      load_reg[31:24] = eth_phy.tx_mem[addr_cnt];
//      load_reg[31:24] = {load_reg[28], load_reg[29], load_reg[30], load_reg[31], 
//                         load_reg[24], load_reg[25], load_reg[26], load_reg[27]};
      addr_cnt = addr_cnt + 1;
      load_reg[23:16] = eth_phy.tx_mem[addr_cnt];
//      load_reg[23:16] = {load_reg[20], load_reg[21], load_reg[22], load_reg[23], 
//                         load_reg[16], load_reg[17], load_reg[18], load_reg[19]};
      addr_cnt = addr_cnt + 1;
      load_reg[15: 8] = eth_phy.tx_mem[addr_cnt];
//      load_reg[15: 8] = {load_reg[12], load_reg[13], load_reg[14], load_reg[15], 
//                         load_reg[ 8], load_reg[ 9], load_reg[10], load_reg[11]};
      addr_cnt = addr_cnt + 1;
      load_reg[ 7: 0] = eth_phy.tx_mem[addr_cnt];
//      load_reg[ 7: 0] = {load_reg[ 4], load_reg[ 5], load_reg[ 6], load_reg[ 7], 
//                         load_reg[ 0], load_reg[ 1], load_reg[ 2], load_reg[ 3]};
      addr_cnt = addr_cnt + 1;
    end
#1;
    // set new load bit position
    if(word_cnt == 31)
      word_cnt = 16;
    else if (word_cnt == 23)
      word_cnt = 8;
    else if (word_cnt == 15)
      word_cnt = 0;
    else if (word_cnt == 7)
      word_cnt = 24;

//   if(word_cnt == 24)
//     word_cnt = 31;
//   else if (word_cnt == 28)
//     word_cnt = 19;
//   else if (word_cnt == 16)
//     word_cnt = 23;
//   else if (word_cnt == 20)
//     word_cnt = 11;
//   else if(word_cnt == 8)
//     word_cnt = 15;
//   else if (word_cnt == 12)
//     word_cnt = 3;
//   else if (word_cnt == 0)
//     word_cnt = 7;
//   else if (word_cnt == 4)
//     word_cnt = 27;
    else
      word_cnt = word_cnt + 1;// - 1;
#1;
    // decrement bit counter
    bit_cnt = bit_cnt - 1;
#1;
    // wait for delta time
    delta_t = !delta_t;
  end // while

  #1;
end
endtask // serial_crc_phy_tx

// serial CRC calculating for PHY RX
task serial_crc_phy_rx;
  input  [31:0] start_addr; // start address
  input  [31:0] len; // length of frame in Bytes without CRC length
  input         plus_dribble_nibble; // if length is longer for one nibble
  output [31:0] crc;
  reg    [21:0] addr_cnt; // only 22 address lines
  integer       word_cnt;
  integer       bit_cnt;
  reg    [31:0] load_reg;
  reg    [31:0] crc_shift_reg;
  reg    [31:0] crc_store_reg;
  reg           delta_t;
begin
  #1 addr_cnt = start_addr[21:0];
  word_cnt = 24; // start of the frame
  crc_shift_reg = 0;
  delta_t = 0;
  // length must include 4 bytes of ZEROs, to generate CRC
  // get number of bits from Byte length (2^3 = 8)
  if (plus_dribble_nibble)
    bit_cnt = ((len + 4) << 3) + 3'h4; // one nibble longer
  else
    bit_cnt = ((len + 4) << 3);
  load_reg[31:24] = eth_phy.rx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[23:16] = eth_phy.rx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[15:8]  = eth_phy.rx_mem[addr_cnt];
  addr_cnt = addr_cnt + 1;
  load_reg[7:0]   = eth_phy.rx_mem[addr_cnt];

  while (bit_cnt > 0)
  begin
    // wait for delta time
    delta_t = !delta_t;
    // store previous data
    crc_store_reg = crc_shift_reg;
    // shift data in
    if(bit_cnt <= 32) // for additional 32 bits shift ZEROs in!
     crc_shift_reg[0] = 1'b0               ^ crc_store_reg[31];
    else
     crc_shift_reg[0] = load_reg[word_cnt] ^ crc_store_reg[31];
    crc_shift_reg[1]  = crc_store_reg[0]   ^ crc_store_reg[31];
    crc_shift_reg[2]  = crc_store_reg[1]   ^ crc_store_reg[31];
    crc_shift_reg[3]  = crc_store_reg[2];
    crc_shift_reg[4]  = crc_store_reg[3]   ^ crc_store_reg[31];
    crc_shift_reg[5]  = crc_store_reg[4]   ^ crc_store_reg[31];
    crc_shift_reg[6]  = crc_store_reg[5];
    crc_shift_reg[7]  = crc_store_reg[6]   ^ crc_store_reg[31];
    crc_shift_reg[8]  = crc_store_reg[7]   ^ crc_store_reg[31];
    crc_shift_reg[9]  = crc_store_reg[8];
    crc_shift_reg[10] = crc_store_reg[9]   ^ crc_store_reg[31];
    crc_shift_reg[11] = crc_store_reg[10]  ^ crc_store_reg[31];
    crc_shift_reg[12] = crc_store_reg[11]  ^ crc_store_reg[31];
    crc_shift_reg[13] = crc_store_reg[12];
    crc_shift_reg[14] = crc_store_reg[13];
    crc_shift_reg[15] = crc_store_reg[14];
    crc_shift_reg[16] = crc_store_reg[15]  ^ crc_store_reg[31];
    crc_shift_reg[17] = crc_store_reg[16];
    crc_shift_reg[18] = crc_store_reg[17];
    crc_shift_reg[19] = crc_store_reg[18];
    crc_shift_reg[20] = crc_store_reg[19];
    crc_shift_reg[21] = crc_store_reg[20];
    crc_shift_reg[22] = crc_store_reg[21]  ^ crc_store_reg[31];
    crc_shift_reg[23] = crc_store_reg[22]  ^ crc_store_reg[31];
    crc_shift_reg[24] = crc_store_reg[23];
    crc_shift_reg[25] = crc_store_reg[24];
    crc_shift_reg[26] = crc_store_reg[25]  ^ crc_store_reg[31];
    crc_shift_reg[27] = crc_store_reg[26];
    crc_shift_reg[28] = crc_store_reg[27];
    crc_shift_reg[29] = crc_store_reg[28];
    crc_shift_reg[30] = crc_store_reg[29];
    crc_shift_reg[31] = crc_store_reg[30];
    // wait for delta time
    delta_t = !delta_t;
    // increment address and load new data
    if (word_cnt == 7)
    begin
      addr_cnt = addr_cnt + 1;
      load_reg[31:24] = eth_phy.rx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[23:16] = eth_phy.rx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[15:8]  = eth_phy.rx_mem[addr_cnt];
      addr_cnt = addr_cnt + 1;
      load_reg[7:0]   = eth_phy.rx_mem[addr_cnt];
    end
    // set new load bit position
    if(word_cnt == 31)
      word_cnt = 16;
    else if (word_cnt == 23)
      word_cnt = 8;
    else if (word_cnt == 15)
      word_cnt = 0;
    else if (word_cnt == 7)
      word_cnt = 24;
    else
      word_cnt = word_cnt + 1;
    // decrement bit counter
    bit_cnt = bit_cnt - 1;
    // wait for delta time
    delta_t = !delta_t;
  end // while

  // put CRC out
  crc = crc_shift_reg;
  #1;
end
endtask // serial_crc_phy_rx

// serial CRC checking for MAC
task serial_crc_mac;
  input  [31:0] start_addr; // start address
  input  [31:0] len; // length of frame in Bytes without CRC length
  input         plus_dribble_nibble; // if length is longer for one nibble
  output [31:0] crc;
  reg    [19:0] addr_cnt; // only 20 address lines
  integer       word_cnt;
  integer       bit_cnt;
  reg    [31:0] load_reg;
  reg    [31:0] crc_shift_reg;
  reg    [31:0] crc_store_reg;
  reg           delta_t;
begin
  #1 addr_cnt = start_addr[19:0];
  // set starting point depending with which byte frame starts (e.g. if addr_cnt[1:0] == 0, then
  //   MSB of the packet must be written to the LSB of Big ENDIAN Word [31:24])
  if (addr_cnt[1:0] == 2'h1)
    word_cnt = 16; // start of the frame for Big ENDIAN Bytes (Litle ENDIAN bits)
  else if (addr_cnt[1:0] == 2'h2)
    word_cnt = 8; // start of the frame for Big ENDIAN Bytes (Litle ENDIAN bits)
  else if (addr_cnt[1:0] == 2'h3)
    word_cnt = 0; // start of the frame for Big ENDIAN Bytes (Litle ENDIAN bits)
  else 
    word_cnt = 24; // start of the frame for Big ENDIAN Bytes (Litle ENDIAN bits)

  crc_shift_reg = 0;
  delta_t = 0;
  // length must include 4 bytes of ZEROs, to generate CRC
  // get number of bits from Byte length (2^3 = 8)
  if (plus_dribble_nibble)
    bit_cnt = ((len + 4) << 3) + 3'h4; // one nibble longer
  else
    bit_cnt = ((len + 4) << 3);
  load_reg = wb_slave.wb_memory[{12'h0, addr_cnt}];

  while (bit_cnt > 0)
  begin
    // wait for delta time
    delta_t = !delta_t;
    // store previous data
    crc_store_reg = crc_shift_reg;
    // shift data in
    if(bit_cnt <= 32) // for additional 32 bits shift ZEROs in!
     crc_shift_reg[0] = 1'b0               ^ crc_store_reg[31];
    else
     crc_shift_reg[0] = load_reg[word_cnt] ^ crc_store_reg[31];
    crc_shift_reg[1]  = crc_store_reg[0]   ^ crc_store_reg[31];
    crc_shift_reg[2]  = crc_store_reg[1]   ^ crc_store_reg[31];
    crc_shift_reg[3]  = crc_store_reg[2];
    crc_shift_reg[4]  = crc_store_reg[3]   ^ crc_store_reg[31];
    crc_shift_reg[5]  = crc_store_reg[4]   ^ crc_store_reg[31];
    crc_shift_reg[6]  = crc_store_reg[5];
    crc_shift_reg[7]  = crc_store_reg[6]   ^ crc_store_reg[31];
    crc_shift_reg[8]  = crc_store_reg[7]   ^ crc_store_reg[31];
    crc_shift_reg[9]  = crc_store_reg[8];
    crc_shift_reg[10] = crc_store_reg[9]   ^ crc_store_reg[31];
    crc_shift_reg[11] = crc_store_reg[10]  ^ crc_store_reg[31];
    crc_shift_reg[12] = crc_store_reg[11]  ^ crc_store_reg[31];
    crc_shift_reg[13] = crc_store_reg[12];
    crc_shift_reg[14] = crc_store_reg[13];
    crc_shift_reg[15] = crc_store_reg[14];
    crc_shift_reg[16] = crc_store_reg[15]  ^ crc_store_reg[31];
    crc_shift_reg[17] = crc_store_reg[16];
    crc_shift_reg[18] = crc_store_reg[17];
    crc_shift_reg[19] = crc_store_reg[18];
    crc_shift_reg[20] = crc_store_reg[19];
    crc_shift_reg[21] = crc_store_reg[20];
    crc_shift_reg[22] = crc_store_reg[21]  ^ crc_store_reg[31];
    crc_shift_reg[23] = crc_store_reg[22]  ^ crc_store_reg[31];
    crc_shift_reg[24] = crc_store_reg[23];
    crc_shift_reg[25] = crc_store_reg[24];
    crc_shift_reg[26] = crc_store_reg[25]  ^ crc_store_reg[31];
    crc_shift_reg[27] = crc_store_reg[26];
    crc_shift_reg[28] = crc_store_reg[27];
    crc_shift_reg[29] = crc_store_reg[28];
    crc_shift_reg[30] = crc_store_reg[29];
    crc_shift_reg[31] = crc_store_reg[30];
    // wait for delta time
    delta_t = !delta_t;
    // increment address and load new data for Big ENDIAN Bytes (Litle ENDIAN bits)
    if (word_cnt == 7)
    begin
      addr_cnt = addr_cnt + 4;
      load_reg = wb_slave.wb_memory[{12'h0, addr_cnt}];
    end
    // set new load bit position for Big ENDIAN Bytes (Litle ENDIAN bits)
    if(word_cnt == 31)
      word_cnt = 16;
    else if (word_cnt == 23)
      word_cnt = 8;
    else if (word_cnt == 15)
      word_cnt = 0;
    else if (word_cnt == 7)
      word_cnt = 24;
    else
      word_cnt = word_cnt + 1;
    // decrement bit counter
    bit_cnt = bit_cnt - 1;
    // wait for delta time
    delta_t = !delta_t;
  end // while

  // put CRC out
  crc = crc_shift_reg;
  #1;
end
endtask // serial_crc_mac

//////////////////////////////////////////////////////////////
// MIIM Basic tasks
//////////////////////////////////////////////////////////////

task mii_set_clk_div; // set clock divider for MII clock
  input [7:0]  clk_div;
begin
  // MII mode register
  wbm_write(`ETH_MIIMODER, (`ETH_MIIMODER_CLKDIV & clk_div), 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
end
endtask // mii_set_clk_div


task check_mii_busy; // MII - check if BUSY
  reg [31:0] tmp;
begin
  @(posedge wb_clk);                                                                  
  // MII read status register
  wbm_read(`ETH_MIISTATUS, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  while(tmp[`ETH_MIISTATUS_BUSY] !== 1'b0) //`ETH_MIISTATUS_BUSY
  begin
    @(posedge wb_clk);
    wbm_read(`ETH_MIISTATUS, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  end
end
endtask // check_mii_busy


task check_mii_scan_valid; // MII - check if SCAN data are valid
  reg [31:0] tmp;
begin
  @(posedge wb_clk);
  // MII read status register
  wbm_read(`ETH_MIISTATUS, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  while(tmp[`ETH_MIISTATUS_NVALID] !== 1'b0) //`ETH_MIISTATUS_NVALID
  begin
    @(posedge wb_clk);
    wbm_read(`ETH_MIISTATUS, tmp, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  end
end
endtask // check_mii_scan_valid


task mii_write_req; // requests write to MII
  input [4:0]  phy_addr;
  input [4:0]  reg_addr;
  input [15:0] data_in;
begin
  // MII address, PHY address = 1, command register address = 0
  wbm_write(`ETH_MIIADDRESS, (`ETH_MIIADDRESS_FIAD & phy_addr) | (`ETH_MIIADDRESS_RGAD & (reg_addr << 8)), 
            4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  // MII TX data
  wbm_write(`ETH_MIITX_DATA, {16'h0000, data_in}, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  // MII command
  wbm_write(`ETH_MIICOMMAND, `ETH_MIICOMMAND_WCTRLDATA, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  @(posedge wb_clk);                                                                  
end
endtask // mii_write_req


task mii_read_req; // requests read from MII
  input [4:0]  phy_addr;
  input [4:0]  reg_addr;
begin
  // MII address, PHY address = 1, command register address = 0
  wbm_write(`ETH_MIIADDRESS, (`ETH_MIIADDRESS_FIAD & phy_addr) | (`ETH_MIIADDRESS_RGAD & (reg_addr << 8)), 
            4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  // MII command
  wbm_write(`ETH_MIICOMMAND, `ETH_MIICOMMAND_RSTAT, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  @(posedge wb_clk);
end
endtask // mii_read_req


task mii_scan_req; // requests scan from MII
  input [4:0]  phy_addr;
  input [4:0]  reg_addr;
begin
  // MII address, PHY address = 1, command register address = 0
  wbm_write(`ETH_MIIADDRESS, (`ETH_MIIADDRESS_FIAD & phy_addr) | (`ETH_MIIADDRESS_RGAD & (reg_addr << 8)), 
            4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  // MII command
  wbm_write(`ETH_MIICOMMAND, `ETH_MIICOMMAND_SCANSTAT, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  @(posedge wb_clk);
end
endtask // mii_scan_req


task mii_scan_finish; // finish scan from MII
begin
  // MII command
  wbm_write(`ETH_MIICOMMAND, 32'h0, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
  @(posedge wb_clk);
end
endtask // mii_scan_finish

//////////////////////////////////////////////////////////////
// Log files and memory tasks
//////////////////////////////////////////////////////////////

task clear_memories;
  reg    [22:0]  adr_i;
  reg            delta_t;
begin
  for (adr_i = 0; adr_i < 4194304; adr_i = adr_i + 1)
  begin
    eth_phy.rx_mem[adr_i[21:0]] = 0;
    eth_phy.tx_mem[adr_i[21:0]] = 0;
    wb_slave.wb_memory[adr_i[21:2]] = 0;
  end
end
endtask // clear_memories

task clear_buffer_descriptors;
  reg    [8:0]  adr_i;
  reg            delta_t;
begin
  delta_t = 0;
  for (adr_i = 0; adr_i < 256; adr_i = adr_i + 1)
  begin
    wbm_write((`TX_BD_BASE + {adr_i[7:0], 2'b0}), 32'h0, 4'hF, 1, 4'h1, 4'h1);
    delta_t = !delta_t;
  end
end
endtask // clear_buffer_descriptors

task test_note;
  input [799:0] test_note ;
  reg   [799:0] display_note ;
begin
  display_note = test_note;
  while ( display_note[799:792] == 0 )
    display_note = display_note << 8 ;
  $fdisplay( tb_log_file, " " ) ;
  $fdisplay( tb_log_file, "NOTE: %s", display_note ) ;
  $fdisplay( tb_log_file, " " ) ;
end
endtask // test_note

task test_heading;
  input [799:0] test_heading ;
  reg   [799:0] display_test ;
begin
  display_test = test_heading;
  while ( display_test[799:792] == 0 )
    display_test = display_test << 8 ;
  $fdisplay( tb_log_file, "  ***************************************************************************************" ) ;
  $fdisplay( tb_log_file, "  ***************************************************************************************" ) ;
  $fdisplay( tb_log_file, "  Heading: %s", display_test ) ;
  $fdisplay( tb_log_file, "  ***************************************************************************************" ) ;
  $fdisplay( tb_log_file, "  ***************************************************************************************" ) ;
  $fdisplay( tb_log_file, " " ) ;
end
endtask // test_heading


task test_fail ;
  input [7999:0] failure_reason ;
//  reg   [8007:0] display_failure ;
  reg   [7999:0] display_failure ;
  reg   [799:0] display_test ;
begin
  tests_failed = tests_failed + 1 ;

  display_failure = failure_reason; // {failure_reason, "!"} ;
  while ( display_failure[7999:7992] == 0 )
    display_failure = display_failure << 8 ;

  display_test = test_name ;
  while ( display_test[799:792] == 0 )
    display_test = display_test << 8 ;

  $fdisplay( tb_log_file, "    *************************************************************************************" ) ;
  $fdisplay( tb_log_file, "    At time: %t ", $time ) ;
  $fdisplay( tb_log_file, "    Test: %s", display_test ) ;
  $fdisplay( tb_log_file, "    *FAILED* because") ;
  $fdisplay( tb_log_file, "    %s", display_failure ) ;
  $fdisplay( tb_log_file, "    *************************************************************************************" ) ;
  $fdisplay( tb_log_file, " " ) ;

 `ifdef STOP_ON_FAILURE
    #20 $stop ;
 `endif
end
endtask // test_fail


task test_fail_num ;
  input [7999:0] failure_reason ;
  input [31:0]   number ;
//  reg   [8007:0] display_failure ;
  reg   [7999:0] display_failure ;
  reg   [799:0] display_test ;
begin
  tests_failed = tests_failed + 1 ;

  display_failure = failure_reason; // {failure_reason, "!"} ;
  while ( display_failure[7999:7992] == 0 )
    display_failure = display_failure << 8 ;

  display_test = test_name ;
  while ( display_test[799:792] == 0 )
    display_test = display_test << 8 ;

  $fdisplay( tb_log_file, "    *************************************************************************************" ) ;
  $fdisplay( tb_log_file, "    At time: %t ", $time ) ;
  $fdisplay( tb_log_file, "    Test: %s", display_test ) ;
  $fdisplay( tb_log_file, "    *FAILED* because") ;
  $fdisplay( tb_log_file, "    %s; %d", display_failure, number ) ;
  $fdisplay( tb_log_file, "    *************************************************************************************" ) ;
  $fdisplay( tb_log_file, " " ) ;

 `ifdef STOP_ON_FAILURE
    #20 $stop ;
 `endif
end
endtask // test_fail_num


task test_ok ;
  reg [799:0] display_test ;
begin
  tests_successfull = tests_successfull + 1 ;

  display_test = test_name ;
  while ( display_test[799:792] == 0 )
    display_test = display_test << 8 ;

  $fdisplay( tb_log_file, "    *************************************************************************************" ) ;
  $fdisplay( tb_log_file, "    At time: %t ", $time ) ;
  $fdisplay( tb_log_file, "    Test: %s", display_test ) ;
  $fdisplay( tb_log_file, "    reported *SUCCESSFULL*! ") ;
  $fdisplay( tb_log_file, "    *************************************************************************************" ) ;
  $fdisplay( tb_log_file, " " ) ;
end
endtask // test_ok


task test_summary;
begin
  $fdisplay(tb_log_file, "**************************** Ethernet MAC test summary **********************************") ;
  $fdisplay(tb_log_file, "Tests performed:   %d", tests_successfull + tests_failed) ;
  $fdisplay(tb_log_file, "Failed tests   :   %d", tests_failed) ;
  $fdisplay(tb_log_file, "Successfull tests: %d", tests_successfull) ;
  $fdisplay(tb_log_file, "**************************** Ethernet MAC test summary **********************************") ;
  $fclose(tb_log_file) ;
end
endtask // test_summary


endmodule
