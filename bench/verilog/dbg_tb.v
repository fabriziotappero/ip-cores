//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_tb.v                                                    ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC Debug Interface.               ////
////  http://www.opencores.org/projects/DebugInterface/           ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor (igorm@opencores.org)                       ////
////                                                              ////
////                                                              ////
////  All additional information is avaliable in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 - 2004 Authors                            ////
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
// Revision 1.44  2004/04/01 09:33:26  igorm
// Typo fixed.
//
// Revision 1.43  2004/03/31 14:34:13  igorm
// data_cnt_lim length changed to reduce number of warnings.
//
// Revision 1.42  2004/03/30 23:10:39  igorm
// CRC checking of incoming CRC added to all tasks.
//
// Revision 1.41  2004/03/28 20:27:40  igorm
// New release of the debug interface (3rd. release).
//
// Revision 1.40  2004/03/22 16:36:06  igorm
// Temp version before changing dbg interface.
//
// Revision 1.39  2004/03/15 16:17:07  igorm
// 'hz changed to 1'hz because Icarus complains.
//
// Revision 1.38  2004/01/30 10:24:02  mohor
// Defines WISHBONE_SUPPORTED and CPU_SUPPORTED added. By default both are
// turned on.
//
// Revision 1.37  2004/01/25 14:10:25  mohor
// Display for VATS added.
//
// Revision 1.36  2004/01/22 13:58:51  mohor
// Port signals are all set to zero after reset.
//
// Revision 1.35  2004/01/22 11:07:28  mohor
// test stall_test added.
//
// Revision 1.34  2004/01/20 14:24:08  mohor
// Define name changed.
//
// Revision 1.33  2004/01/20 14:05:26  mohor
// Data latching changed when testing WB.
//
// Revision 1.32  2004/01/20 10:23:21  mohor
// More debug data added.
//
// Revision 1.31  2004/01/20 09:07:44  mohor
// CRC generation iand verification in bench changed.
//
// Revision 1.30  2004/01/20 08:03:35  mohor
// IDCODE test improved.
//
// Revision 1.29  2004/01/19 13:13:18  mohor
// Define tap_defines.v added to test bench.
//
// Revision 1.28  2004/01/19 12:38:10  mohor
// Waiting for "ready" improved.
//
// Revision 1.27  2004/01/17 18:01:31  mohor
// New version.
//
// Revision 1.26  2004/01/17 17:01:25  mohor
// Almost finished.
//
// Revision 1.25  2004/01/16 14:51:24  mohor
// cpu registers added.
//
// Revision 1.24  2004/01/15 10:47:13  mohor
// Working.
//
// Revision 1.23  2004/01/14 22:59:01  mohor
// Temp version.
//
// Revision 1.22  2004/01/13 11:28:30  mohor
// tmp version.
//
// Revision 1.21  2004/01/10 07:50:41  mohor
// temp version.
//
// Revision 1.20  2004/01/09 12:49:23  mohor
// tmp version.
//
// Revision 1.19  2004/01/08 17:53:12  mohor
// tmp version.
//
// Revision 1.18  2004/01/07 11:59:48  mohor
// temp4 version.
//
// Revision 1.17  2004/01/06 17:14:59  mohor
// temp3 version.
//
// Revision 1.16  2004/01/05 12:16:50  mohor
// tmp2 version.
//
// Revision 1.15  2003/12/23 14:26:01  mohor
// New version of the debug interface. Not finished, yet.
//
// Revision 1.14  2003/10/23 16:16:30  mohor
// CRC logic changed.
//
// Revision 1.13  2003/08/28 13:54:33  simons
// Three more chains added for cpu debug access.
//
// Revision 1.12  2002/05/07 14:44:52  mohor
// mon_cntl_o signals that controls monitor mux added.
//
// Revision 1.11  2002/03/12 14:32:26  mohor
// Few outputs for boundary scan chain added.
//
// Revision 1.10  2002/03/08 15:27:08  mohor
// Structure changed. Hooks for jtag chain added.
//
// Revision 1.9  2001/10/19 11:39:20  mohor
// dbg_timescale.v changed to timescale.v This is done for the simulation of
// few different cores in a single project.
//
// Revision 1.8  2001/10/17 10:39:17  mohor
// bs_chain_o added.
//
// Revision 1.7  2001/10/16 10:10:18  mohor
// Signal names changed to lowercase.
//
// Revision 1.6  2001/10/15 09:52:50  mohor
// Wishbone interface added, few fixes for better performance,
// hooks for boundary scan testing added.
//
// Revision 1.5  2001/09/24 14:06:12  mohor
// Changes connected to the OpenRISC access (SPR read, SPR write).
//
// Revision 1.4  2001/09/20 10:10:29  mohor
// Working version. Few bugs fixed, comments added.
//
// Revision 1.3  2001/09/19 11:54:03  mohor
// Minor changes for simulation.
//
// Revision 1.2  2001/09/18 14:12:43  mohor
// Trace fixed. Some registers changed, trace simplified.
//
// Revision 1.1.1.1  2001/09/13 13:49:19  mohor
// Initial official release.
//
// Revision 1.3  2001/06/01 22:23:40  mohor
// This is a backup. It is not a fully working version. Not for use, yet.
//
// Revision 1.2  2001/05/18 13:10:05  mohor
// Headers changed. All additional information is now avaliable in the README.txt file.
//
// Revision 1.1.1.1  2001/05/18 06:35:15  mohor
// Initial release
//
//


`include "timescale.v"
`include "tap_defines.v"
`include "dbg_defines.v"
`include "dbg_wb_defines.v"
`include "dbg_cpu_defines.v"

`define DBG_TEXT(TEXT)   $display("%0s", TEXT);
//  `DBG_TEXT("Bla bla bla") 
//  $sformat(dbg_text, "\n\nbla 0x%0x 0x%0x\n\n", 32'h12345678, 16'h543);
//  `DBG_TEXT(dbg_text) 

// For common cpu routines
`ifdef DBG_CPU0_SUPPORTED
  `define DBG_CPU_SUPPORTED
`else
  `ifdef DBG_CPU1_SUPPORTED
    `define DBG_CPU_SUPPORTED
  `endif
`endif

// Test bench
module dbg_tb;

parameter TCLK = 50;   // Clock half period (Clok period = 100 ns => 10 MHz)

reg   [999:0] dbg_text;
reg   tms_pad_i;
reg   tck_pad_i;
reg   trst_pad_i;
reg   tdi_pad_i;
wire  tdo_pad_o;
wire  tdo_padoe_o;

wire  shift_dr_o;
wire  pause_dr_o;
wire  update_dr_o;
wire  capture_dr_o;

wire  extest_select_o;
wire  sample_preload_select_o;
wire  mbist_select_o;
wire  debug_select_o;

reg   rst_i;

`ifdef DBG_WISHBONE_SUPPORTED
// WISHBONE common signals
reg   wb_clk_i;
                                                                                                                                                             
// WISHBONE master interface
wire [31:0] wb_adr_o;
wire [31:0] wb_dat_o;
wire [31:0] wb_dat_i;
wire        wb_cyc_o;
wire        wb_stb_o;
wire  [3:0] wb_sel_o;
wire        wb_we_o;
wire        wb_ack_i;
wire        wb_cab_o;
wire        wb_err_i;
wire  [2:0] wb_cti_o;
wire  [1:0] wb_bte_o;
`endif

`ifdef DBG_CPU0_SUPPORTED
// CPU signals
wire        cpu0_clk_i;
wire [31:0] cpu0_addr_o;
wire [31:0] cpu0_data_i;
wire [31:0] cpu0_data_o;
wire        cpu0_bp_i;
wire        cpu0_stall_o;
wire        cpu0_stb_o;
wire        cpu0_we_o;
wire        cpu0_ack_i;
wire        cpu0_rst_o;
`endif

`ifdef DBG_CPU1_SUPPORTED
// CPU signals
wire        cpu1_clk_i;
wire [31:0] cpu1_addr_o;
wire [31:0] cpu1_data_i;
wire [31:0] cpu1_data_o;
wire        cpu1_bp_i;
wire        cpu1_stall_o;
wire        cpu1_stb_o;
wire        cpu1_we_o;
wire        cpu1_ack_i;
wire        cpu1_rst_o;
`endif

// Text used for easier debugging
reg [199:0] test_text;
reg [`DBG_WB_CMD_LEN -1:0]  last_wb_cmd;
reg [`DBG_CPU_CMD_LEN -1:0] last_cpu_cmd;
reg [199:0] last_wb_cmd_text;
reg [199:0] last_cpu_cmd_text;

reg  [31:0] wb_data [0:4095];   // Data that is written to (read from) wishbone is stored here. 



wire  tdo_o;

wire  debug_tdi_i;
wire  bs_chain_tdi_i;
wire  mbist_tdi_i;

reg   test_enabled;

reg [31:0] result;
reg [31:0] in_data_le, in_data_be;
reg [31:0] id;

wire crc_match_in;
reg [31:0] crc_in;
reg [31:0] crc_out;
reg [`DBG_TOP_STATUS_LEN -1:0] status;
reg [`DBG_WB_STATUS_LEN -1:0]  status_wb;
reg [`DBG_CPU_STATUS_LEN -1:0] status_cpu;

reg [`DBG_WB_ACC_TYPE_LEN -1:0]  read_acc_type;
reg [`DBG_WB_ADR_LEN -1:0]       read_addr;
reg [`DBG_WB_LEN_LEN -1:0]       read_length;
reg [`DBG_CPU_CTRL_LEN -1:0]     read_ctrl_reg;

integer length_global;
wire tdo;

assign tdo = tdo_padoe_o? tdo_pad_o : 1'hz;



// Connecting TAP module
tap_top i_tap_top (
                    .tms_pad_i        (tms_pad_i), 
                    .tck_pad_i        (tck_pad_i), 
                    .trst_pad_i       (!trst_pad_i), 
                    .tdi_pad_i        (tdi_pad_i), 
                    .tdo_pad_o        (tdo_pad_o), 
                    .tdo_padoe_o      (tdo_padoe_o), 
                
                    // TAP states
                    .shift_dr_o       (shift_dr_o),
                    .pause_dr_o       (pause_dr_o),
                    .update_dr_o      (update_dr_o),
                    .capture_dr_o     (capture_dr_o),
                
                    // Select signals for boundary scan or mbist
                    .extest_select_o  (extest_select_o),
                    .sample_preload_select_o(sample_preload_select_o),
                    .mbist_select_o   (mbist_select_o),
                    .debug_select_o   (debug_select_o),

                    // TDO signal that is connected to TDI of sub-modules.
                    .tdo_o            (tdo_o),

                    // TDI signals from sub-modules
                    .debug_tdi_i      (debug_tdi_i),        // from debug module
                    .bs_chain_tdi_i   (bs_chain_tdi_i),  // from Boundary Scan Chain
                    .mbist_tdi_i      (mbist_tdi_i)         // from Mbist Chain

               );


// Connecting debug top module
dbg_top i_dbg_top  (
                    .tck_i            (tck_pad_i),
                    .tdi_i            (tdo_o),
                    .tdo_o            (debug_tdi_i),
                    .rst_i            (rst_i),
    
                    // TAP states
                    .shift_dr_i       (shift_dr_o),
                    .pause_dr_i       (pause_dr_o),
                    .update_dr_i      (update_dr_o),
    
                    // Instructions
                    .debug_select_i   (debug_select_o)

                    `ifdef DBG_WISHBONE_SUPPORTED
                    // WISHBONE common signals
                    ,
                    .wb_clk_i         (wb_clk_i),
                                                                                                                                                               
                    // WISHBONE master interface
                    .wb_adr_o         (wb_adr_o),
                    .wb_dat_o         (wb_dat_o),
                    .wb_dat_i         (wb_dat_i),
                    .wb_cyc_o         (wb_cyc_o),
                    .wb_stb_o         (wb_stb_o),
                    .wb_sel_o         (wb_sel_o),
                    .wb_we_o          (wb_we_o),
                    .wb_ack_i         (wb_ack_i),
                    .wb_cab_o         (wb_cab_o),
                    .wb_err_i         (wb_err_i),
                    .wb_cti_o         (wb_cti_o),
                    .wb_bte_o         (wb_bte_o)
                    `endif

                    `ifdef DBG_CPU0_SUPPORTED
                    // CPU signals
                    ,
                    .cpu0_clk_i        (cpu0_clk_i),
                    .cpu0_addr_o       (cpu0_addr_o),
                    .cpu0_data_i       (cpu0_data_i),
                    .cpu0_data_o       (cpu0_data_o),
                    .cpu0_bp_i         (cpu0_bp_i),
                    .cpu0_stall_o      (cpu0_stall_o),
                    .cpu0_stb_o        (cpu0_stb_o),
                    .cpu0_we_o         (cpu0_we_o),
                    .cpu0_ack_i        (cpu0_ack_i),
                    .cpu0_rst_o        (cpu0_rst_o)
                    `endif

                    `ifdef DBG_CPU1_SUPPORTED
                    // CPU signals
                    ,
                    .cpu1_clk_i        (cpu1_clk_i),
                    .cpu1_addr_o       (cpu1_addr_o),
                    .cpu1_data_i       (cpu1_data_i),
                    .cpu1_data_o       (cpu1_data_o),
                    .cpu1_bp_i         (cpu1_bp_i),
                    .cpu1_stall_o      (cpu1_stall_o),
                    .cpu1_stb_o        (cpu1_stb_o),
                    .cpu1_we_o         (cpu1_we_o),
                    .cpu1_ack_i        (cpu1_ack_i),
                    .cpu1_rst_o        (cpu1_rst_o)
                    `endif



                   );


`ifdef DBG_WISHBONE_SUPPORTED
wb_slave_behavioral wb_slave
                   (
                    .CLK_I            (wb_clk_i),
                    .RST_I            (rst_i),
                    .ACK_O            (wb_ack_i),
                    .ADR_I            (wb_adr_o),
                    .CYC_I            (wb_cyc_o),
                    .DAT_O            (wb_dat_i),
                    .DAT_I            (wb_dat_o),
                    .ERR_O            (wb_err_i),
                    .RTY_O            (),      // NOT USED for now!
                    .SEL_I            (wb_sel_o),
                    .STB_I            (wb_stb_o),
                    .WE_I             (wb_we_o),
                    .CAB_I            (1'b0)
                   );
`endif


`ifdef DBG_CPU0_SUPPORTED
cpu_behavioral i_cpu0_behavioral
                   (
                    // CPU signals
                    .cpu_rst_i        (rst_i),
                    .cpu_clk_o        (cpu0_clk_i),
                    .cpu_addr_i       (cpu0_addr_o),
                    .cpu_data_o       (cpu0_data_i),
                    .cpu_data_i       (cpu0_data_o),
                    .cpu_bp_o         (cpu0_bp_i),
                    .cpu_stall_i      (cpu0_stall_o),
                    .cpu_stb_i        (cpu0_stb_o),
                    .cpu_we_i         (cpu0_we_o),
                    .cpu_ack_o        (cpu0_ack_i),
                    .cpu_rst_o        (cpu0_rst_o)
                   );
`endif



`ifdef DBG_CPU1_SUPPORTED
cpu_behavioral i_cpu1_behavioral
                   (
                    // CPU signals
                    .cpu_rst_i        (rst_i),
                    .cpu_clk_o        (cpu1_clk_i),
                    .cpu_addr_i       (cpu1_addr_o),
                    .cpu_data_o       (cpu1_data_i),
                    .cpu_data_i       (cpu1_data_o),
                    .cpu_bp_o         (cpu1_bp_i),
                    .cpu_stall_i      (cpu1_stall_o),
                    .cpu_stb_i        (cpu1_stb_o),
                    .cpu_we_i         (cpu1_we_o),
                    .cpu_ack_o        (cpu1_ack_i),
                    .cpu_rst_o        (cpu1_rst_o)
                   );
`endif



// Initial values
initial
begin
  trst_pad_i = 1'b1;
  tms_pad_i = 1'hz;
  tck_pad_i = 1'hz;
  tdi_pad_i = 1'hz;

  #100;
  trst_pad_i = 1'b0;
  #100;
  trst_pad_i = 1'b1;
end

initial
begin
  test_enabled = 1'b0;
  rst_i = 1'b0;
  #1000;
  rst_i = 1'b1;
  #1000;
  rst_i = 1'b0;

  // Initial values for wishbone slave model
  `ifdef DBG_WISHBONE_SUPPORTED
//  wb_slave.cycle_response(`ACK_RESPONSE, 9'h55, 8'h2);   // (`ACK_RESPONSE, wbs_waits, wbs_retries);
  wb_slave.cycle_response(`ACK_RESPONSE, 9'h35, 8'h2);   // (`ACK_RESPONSE, wbs_waits, wbs_retries);
  `endif
  #1 test_enabled<=#1 1'b1;
end

`ifdef DBG_WISHBONE_SUPPORTED
initial
begin
  wb_clk_i = 1'b0;
  forever #5 wb_clk_i = ~wb_clk_i;
end
`endif

always @ (posedge test_enabled)
begin
  $display("//////////////////////////////////////////////////////////////////");
  $display("//                                                              //");
  $display("//  (%0t) dbg_tb starting                                     //", $time);
  $display("//                                                              //");
  $display("//////////////////////////////////////////////////////////////////");

  $display("TEST: DBG_TEST");


  initialize_memory(32'h12340000, 32'h00100000);  // Initialize 0x100000 bytes starting from address 0x12340000

  reset_tap;

  #500;
  goto_run_test_idle;

//  `ifdef DBG_CPU0_SUPPORTED
//  // Test stall signal
//  stall_test_cpu0;
//  `endif

  // Testing read and write to internal registers
  #10000;
  
  id_test;

  set_instruction(`DEBUG);
  #10000;









  #100000;
  `ifdef DBG_WISHBONE_SUPPORTED
  module_select(`DBG_TOP_WISHBONE_DEBUG_MODULE, 1'b0);   // {module_id, gen_crc_err}

  #10000;
  debug_wishbone(`DBG_WB_READ32, 1'b0, 32'h12345678, 16'h3, 1'b0, "read32 1"); // {command, ready, addr, length, gen_crc_err, text}
//  debug_wishbone(`DBG_WB_WRITE8, 1'b0, 32'h23456788, 16'h7, 1'b0, "write32 1"); // {command, ready, addr, length, gen_crc_err, text}
  debug_wishbone(`DBG_WB_WRITE32, 1'b0, 32'h23456788, 16'h7, 1'b0, "write32 1"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
  test_text = "debug_wishbone_rd_comm";
  debug_wishbone_rd_comm(read_acc_type, read_addr, read_length);
  $display("debug_wishbone_rd_comm returns: acc_type = 0x%0x, addr = 0x%0x, length = 0x%0x", read_acc_type, read_addr, read_length);
  debug_wishbone_go(1'b0, 1'b0);
  debug_wishbone_rd_comm(read_acc_type, read_addr, read_length);
  $display("debug_wishbone_rd_comm returns: acc_type = 0x%0x, addr = 0x%0x, length = 0x%0x", read_acc_type, read_addr, read_length);

  debug_wishbone_go(1'b0, 1'b0);

  #100000;
//  debug_wishbone(`DBG_WB_READ32, 1'b0, 32'h12345224, 16'h7, 1'b0, "read32 1"); // {command, ready, addr, length, gen_crc_err, text}
  debug_wishbone(`DBG_WB_READ8, 1'b0, 32'h12345223, 16'h8, 1'b0, "read8 1"); // {command, ready, addr, length, gen_crc_err, text}
  #100000;
  debug_wishbone_go(1'b0, 1'b0);


/*
//  debug_wishbone(`DBG_WB_READ8, 1'b0, 32'h12345678, 16'h4, 1'b0, "abc 1"); // {command, ready, addr, length, gen_crc_err, text}
//  debug_wishbone(`DBG_WB_READ8, 1'b0, 32'h12345679, 16'h4, 1'b0, "abc 2"); // {command, ready, addr, length, gen_crc_err, text}
//  debug_wishbone(`DBG_WB_READ8, 1'b0, 32'h1234567a, 16'h4, 1'b0, "abc 3"); // {command, ready, addr, length, gen_crc_err, text}
//
//  debug_wishbone(`DBG_WB_READ16, 1'b0, 32'h12345678, 16'h4, 1'b0, "abc 4"); // {command, ready, addr, length, gen_crc_err, text}
//  debug_wishbone(`DBG_WB_READ16, 1'b0, 32'h1234567a, 16'h4, 1'b0, "abc 5"); // {command, ready, addr, length, gen_crc_err, text}
//
  debug_wishbone(`DBG_WB_READ32, 1'b0, 32'h12345678, 16'h4, 1'b0, "read32 1"); // {command, ready, addr, length, gen_crc_err, text}
//
//  debug_wishbone(`DBG_WB_READ16, 1'b0, 32'h12345679, 16'h4, 1'b0, "abc 6"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;

  debug_wishbone(`DBG_WB_READ32, 1'b1, 32'h12345678, 16'h4, 1'b0, "read32 2"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
  wb_slave.cycle_response(`ACK_RESPONSE, 9'h55, 8'h2);   // (`ACK_RESPONSE, wbs_waits, wbs_retries);
  debug_wishbone(`DBG_WB_READ32, 1'b1, 32'h12346668, 16'h4, 1'b0, "read32 3"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
  wb_slave.cycle_response(`ERR_RESPONSE, 9'h03, 8'h2);   // (`ERR_RESPONSE, wbs_waits, wbs_retries);
  debug_wishbone(`DBG_WB_READ32, 1'b1, 32'h12346668, 16'h4, 1'b0, "read32 4"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
  debug_wishbone(`WB_STATUS, 1'b0, 32'h0, 16'h0, 1'b0, "status 1"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
  debug_wishbone(`WB_STATUS, 1'b0, 32'h0, 16'h0, 1'b0, "status 2"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
  wb_slave.cycle_response(`ACK_RESPONSE, 9'h012, 8'h2);   // (`ACK_RESPONSE, wbs_waits, wbs_retries);
  debug_wishbone(`DBG_WB_READ32, 1'b1, 32'h12347778, 16'hc, 1'b0, "read32 5"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
  debug_wishbone(`DBG_WB_WRITE32, 1'b0, 32'h12346668, 16'h8, 1'b0, "wr32 len8"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
  debug_wishbone(`DBG_WB_WRITE16, 1'b0, 32'h12344446, 16'h8, 1'b0, "wr16 len8"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
  debug_wishbone(`DBG_WB_WRITE8, 1'b0, 32'h1234010e, 16'h8, 1'b0, "wr8 len8"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
  debug_wishbone(`WB_GO, 1'b0, 32'h0, 16'h0, 1'b0, "go 1"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
  debug_wishbone(`DBG_WB_READ32, 1'b1, 32'h12340100, 16'hc, 1'b0, "read32 6"); // {command, ready, addr, length, gen_crc_err, text}
//  debug_wishbone(`DBG_WB_READ32, 1'b1, 32'h12340100, 16'hfffc, 1'b0, "read32 6"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
//  debug_wishbone(`DBG_WB_READ16, 1'b1, 32'h12340102, 16'he, 1'b0, "read16 7"); // {command, ready, addr, length, gen_crc_err, text}
//  debug_wishbone(`DBG_WB_READ16, 1'b1, 32'h12340102, 16'hfffe, 1'b0, "read16 7"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
//  debug_wishbone(`DBG_WB_READ8, 1'b1, 32'h12348804, 16'h6, 1'b0, "read8 8"); // {command, ready, addr, length, gen_crc_err, text}  
//  debug_wishbone(`DBG_WB_READ8, 1'b1, 32'h12348804, 16'hfffc, 1'b0, "read8 8"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
  debug_wishbone(`WB_GO, 1'b0, 32'h0, 16'h0, 1'b0, "go 2"); // {command, ready, addr, length, gen_crc_err, text}
*/
  `endif  // DBG_WISHBONE_SUPPORTED

  `ifdef DBG_CPU0_SUPPORTED
  #10000;
  module_select(`DBG_TOP_CPU0_DEBUG_MODULE, 1'b0);   // {module_id, gen_crc_err}




  // Select cpu0

  #10000;
  debug_cpu(`DBG_CPU_WRITE, 1'b0, 32'h23456788, 16'h3, 1'b0, "cpu write 1"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
  debug_cpu(`DBG_CPU_READ, 1'b0, 32'h23456788, 16'h3, 1'b0, "cpu read 1"); // {command, ready, addr, length, gen_crc_err, text}
  // Read register
  #10000;

  debug_cpu(`DBG_CPU_WRITE, 1'b0, 32'h32323232, 16'h3, 1'b0, "cpu write 1"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
  debug_cpu(`DBG_CPU_READ, 1'b0, 32'h77665544, 16'h3, 1'b0, "cpu read 1"); // {command, ready, addr, length, gen_crc_err, text}
  // Read register
  #10000;

  // Reset cpu on
  debug_cpu_wr_ctrl(`DBG_CPU_CTRL_LEN'b10, "rst cpu on"); // {data, text}
  #10000;

  // Reset cpu off
  debug_cpu_wr_ctrl(`DBG_CPU_CTRL_LEN'b00, "rst cpu off"); // {data, text}
  #10000;

  // Stall cpu
  debug_cpu_wr_ctrl(`DBG_CPU_CTRL_LEN'b01, "stall on"); // {data, text}
  #10000;

  debug_cpu_wr_ctrl(`DBG_CPU_CTRL_LEN'b00, "stall off"); // {data, text}
  #10000;

  // Stall cpu0
  debug_cpu_rd_ctrl(read_ctrl_reg, "read ctrl");
  $display("debug_cpu_rd_ctrl returns: read_ctrl_reg = 0x%0x", read_ctrl_reg);
  #10000;

  debug_cpu(`DBG_CPU_READ, 1'b0, 32'h23456788, 16'h3, 1'b0, "cpu read 2"); // {command, ready, addr, length, gen_crc_err, text}
  // write to cpu 32-bit
  #10000;

  debug_cpu(`DBG_CPU_WRITE, 1'b0, 32'h32323232, 16'hf, 1'b0, "cpu write 2"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;

  // read from cpu 32-bit
  #10000;

  #10000;

  `endif  // DBG_CPU0_SUPPORTED


  `ifdef DBG_CPU1_SUPPORTED
  #10000;
  module_select(`DBG_TOP_CPU1_DEBUG_MODULE, 1'b0);   // {module_id, gen_crc_err}




  // Select cpu1

  #10000;
  debug_cpu(`DBG_CPU_WRITE, 1'b0, 32'h23456788, 16'h3, 1'b0, "cpu write 1"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
  debug_cpu(`DBG_CPU_READ, 1'b0, 32'h23456788, 16'h3, 1'b0, "cpu read 1"); // {command, ready, addr, length, gen_crc_err, text}
  // Read register
  #10000;

  debug_cpu(`DBG_CPU_WRITE, 1'b0, 32'h32323232, 16'h3, 1'b0, "cpu write 1"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;
  debug_cpu(`DBG_CPU_READ, 1'b0, 32'h77665544, 16'h3, 1'b0, "cpu read 1"); // {command, ready, addr, length, gen_crc_err, text}
  // Read register
  #10000;

  // Reset cpu on
  debug_cpu_wr_ctrl(`DBG_CPU_CTRL_LEN'b10, "rst cpu on"); // {data, text}
  #10000;

  // Reset cpu off
  debug_cpu_wr_ctrl(`DBG_CPU_CTRL_LEN'b00, "rst cpu off"); // {data, text}
  #10000;

  // Stall cpu
  debug_cpu_wr_ctrl(`DBG_CPU_CTRL_LEN'b01, "stall on"); // {data, text}
  #10000;

  debug_cpu_wr_ctrl(`DBG_CPU_CTRL_LEN'b00, "stall off"); // {data, text}
  #10000;

  // Stall cpu1
  debug_cpu_rd_ctrl(read_ctrl_reg, "read ctrl");
  $display("debug_cpu_rd_ctrl returns: read_ctrl_reg = 0x%0x", read_ctrl_reg);
  #10000;

  debug_cpu(`DBG_CPU_READ, 1'b0, 32'h23456788, 16'h3, 1'b0, "cpu read 2"); // {command, ready, addr, length, gen_crc_err, text}
  // write to cpu 32-bit
  #10000;

  debug_cpu(`DBG_CPU_WRITE, 1'b0, 32'h32323232, 16'hf, 1'b0, "cpu write 2"); // {command, ready, addr, length, gen_crc_err, text}

  #10000;

  // read from cpu 32-bit
  #10000;

  #10000;

  `endif  // DBG_CPU1_SUPPORTED









  #5000 gen_clk(1);            // One extra TCLK for debugging purposes
  $display("STATUS: passed");
  $display("\n\nSimulation end.");
  #1000 $stop;

end


`ifdef DBG_CPU0_SUPPORTED
task stall_test_cpu0;
  integer i;

  begin
    test_text = "stall_test_cpu0";
    $display("\n\n(%0t) stall_test_cpu0 started", $time);

    // Set bp_i active for 1 clock cycle and check is stall is set or not
    check_stall_cpu0(0); // Should not be set at the beginning
    @ (posedge cpu0_clk_i);
    #1 dbg_tb.i_cpu0_behavioral.cpu_bp_o = 1'b1;
    #1 check_stall_cpu0(1); // set?
    @ (posedge cpu0_clk_i);
    #1 dbg_tb.i_cpu0_behavioral.cpu_bp_o = 1'b0;
    #1 check_stall_cpu0(1); // set?

    gen_clk(1);
    #1 check_stall_cpu0(1); // set?

    // Unstall with register
    set_instruction(`DEBUG);
    module_select(`DBG_TOP_CPU0_DEBUG_MODULE, 1'b0);   // {module_id, gen_crc_err}
    #1 check_stall_cpu0(1); // set?
// igor !!!    debug_cpu(`CPU_WRITE_REG, `CPU_OP_ADR, 32'h0, 1'b0, result, "clr unstall"); // {command, addr, data, gen_crc_err, result, text}
    #1 check_stall_cpu0(1); // set?
    debug_cpu(`DBG_CPU_WR_COMM, 32'h0, 32'h0, 1'b0, result, "go cpu"); // {command, addr, data, gen_crc_err, result, text}
    #1 check_stall_cpu0(0); // reset?

    // Set stall with register
// igor !!!    debug_cpu(`CPU_WRITE_REG, `CPU_OP_ADR, 32'h0, 1'b0, result, "clr stall"); // {command, addr, data, gen_crc_err, result, text}
    #1 check_stall_cpu0(0); // reset?
    debug_cpu(`DBG_CPU_WR_COMM, 32'h0, 32'h1, 1'b0, result, "go cpu"); // {command, addr, data, gen_crc_err, result, text}
    #1 check_stall_cpu0(1); // set?

    // Unstall with register
// igor !!!    debug_cpu(`CPU_WRITE_REG, `CPU_OP_ADR, 32'h0, 1'b0, result, "clr unstall"); // {command, addr, data, gen_crc_err, result, text}
    #1 check_stall_cpu0(1); // set?
    debug_cpu(`DBG_CPU_WR_COMM, 32'h0, 32'h0, 1'b0, result, "go cpu"); // {command, addr, data, gen_crc_err, result, text}
    #1 check_stall_cpu0(0); // reset?

    $display("\n\n(%0t) stall_test_cpu0 passed\n\n", $time);
  end
endtask   // stall_test_cpu0


task check_stall_cpu0;
  input should_be_set;
  begin
    if (should_be_set && (!cpu0_stall_o))
      begin
        $display ("\t\t(%0t) ERROR: cpu0_stall_o is not set but should be.", $time);
        $stop;
      end
    if ((!should_be_set) && cpu0_stall_o)
      begin
        $display ("\t\t(%0t) ERROR: cpu0_stall_o set but shouldn't be.", $time);
        $stop;
      end
  end
endtask   // check_stall_cpu0
`endif  // DBG_CPU0_SUPPORTED


task initialize_memory;
  input [31:0] start_addr;
  input [31:0] length;
  integer i;
  reg [31:0] addr;
  begin
    for (i=0; i<length; i=i+4)  // This data will be return from wb slave
      begin
        addr = start_addr + i;
        `ifdef DBG_WISHBONE_SUPPORTED
        wb_slave.wr_mem(addr, {addr[7:0], addr[7:0]+2'd1, addr[7:0]+2'd2, addr[7:0]+2'd3}, 4'hf);    // adr, data, sel
        `endif
      end
    for (i=0; i<4096; i=i+1)  // This data will be written to wb slave
      begin
        wb_data[i] <= {i[7:0], i[7:0]+2'd1, i[7:0]+2'd2, i[7:0]+2'd3};
      end
  end
endtask


task id_test;
  begin
    test_text = "id_test";
    $display("\n\n(%0t) TEST: id_test", $time);

    set_instruction(`IDCODE);
    read_id_code(id);

    `ifdef DBG_MORE_INFO
      $display("\tRead ID     = 0x%0x", id);
      $display("\tExpected ID = 0x%0x", `IDCODE_VALUE);
    `endif

    if (id==`IDCODE_VALUE)
      $display("(%0t) STATUS: passed\n", $time);
    else
      $display("(%0t) STATUS: failed (Read ID = 0x%0x, Expected ID = 0x%0x\n", $time, id, `IDCODE_VALUE);
  end
endtask // id_test


// Generation of the TCLK signal
task gen_clk;
  input [7:0] num;
  integer i;
  begin
    for(i=0; i<num; i=i+1)
      begin
        #TCLK tck_pad_i<=1;
        #TCLK tck_pad_i<=0;
      end
  end
endtask


// TAP reset
task reset_tap;
  begin
    $display("(%0t) Task reset_tap", $time);
    tms_pad_i<=#1 1'b1;
    gen_clk(5);
  end
endtask


// Goes to RunTestIdle state
task goto_run_test_idle;
  begin
    $display("(%0t) Task goto_run_test_idle", $time);
    tms_pad_i<=#1 1'b0;
    gen_clk(1);
  end
endtask



// sets the instruction to the IR register and goes to the RunTestIdle state
task set_instruction;
  input [3:0] instr;
  integer i;
  
  begin
    case (instr)
      `ifdef DBG_MORE_INFO
        `EXTEST          : $display("(%0t) Task set_instruction (EXTEST)", $time); 
        `SAMPLE_PRELOAD  : $display("(%0t) Task set_instruction (SAMPLE_PRELOAD)", $time); 
        `IDCODE          : $display("(%0t) Task set_instruction (IDCODE)", $time);
        `DEBUG           : $display("(%0t) Task set_instruction (DEBUG)", $time);
        `MBIST           : $display("(%0t) Task set_instruction (MBIST)", $time);
        `BYPASS          : $display("(%0t) Task set_instruction (BYPASS)", $time);
      `else
        `EXTEST          : ; 
        `SAMPLE_PRELOAD  : ; 
        `IDCODE          : ; 
        `DEBUG           : ; 
        `MBIST           : ; 
        `BYPASS          : ; 
      `endif
        default
                         begin
                           $display("(*E) (%0t) Task set_instruction: Unsupported instruction !!!", $time);
                           $stop;
                         end
    endcase

    tms_pad_i<=#1 1;
    gen_clk(2);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftIR

    for(i=0; i<`IR_LENGTH-1; i=i+1)
    begin
      tdi_pad_i<=#1 instr[i];
      gen_clk(1);
    end
    
    tdi_pad_i<=#1 instr[i]; // last shift
    tms_pad_i<=#1 1;        // going out of shiftIR
    gen_clk(1);
    tdi_pad_i<=#1 1'hz;    // tri-state
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(1);       // we are in RunTestIdle
  end
endtask


// Reads the ID code
task read_id_code;
  output [31:0] code;
  reg    [31:0] code;
  begin
    `ifdef DBG_MORE_INFO
      $display("(%0t) Task read_id_code", $time);
    `endif
    tms_pad_i<=#1 1;
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftDR

    tdi_pad_i<=#1 0;
    gen_clk(31);

    tms_pad_i<=#1 1;        // going out of shiftIR
    gen_clk(1);

    code = in_data_le;

    tdi_pad_i<=#1 1'hz; // tri-state
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(1);       // we are in RunTestIdle
  end
endtask


// sets the selected module and goes to the RunTestIdle state
task module_select;
  input [`DBG_TOP_MODULE_ID_LENGTH -1:0]  data;
  input                           gen_crc_err;
  integer                         i;

  begin
    case (data)
      `DBG_TOP_CPU0_DEBUG_MODULE      : $display("(%0t) Task module_select (DBG_TOP_CPU0_DEBUG_MODULE, gen_crc_err=%0d)", $time, gen_crc_err);
      `DBG_TOP_CPU1_DEBUG_MODULE      : $display("(%0t) Task module_select (DBG_TOP_CPU1_DEBUG_MODULE, gen_crc_err=%0d)", $time, gen_crc_err);
      `DBG_TOP_WISHBONE_DEBUG_MODULE : $display("(%0t) Task module_select (DBG_TOP_WISHBONE_DEBUG_MODULE, gen_crc_err=%0d)", $time, gen_crc_err);
      default                : $display("(%0t) Task module_select (ERROR!!! Unknown module selected)", $time);
    endcase

    tms_pad_i<=#1 1'b1;
    gen_clk(1);
    tms_pad_i<=#1 1'b0;
    gen_clk(2);  // we are in shiftDR

    status = {`DBG_TOP_STATUS_LEN{1'b0}};    // Initialize status to all 0's
    crc_out = {`DBG_TOP_CRC_LEN{1'b1}}; // Initialize outgoing CRC to all ff
    tdi_pad_i<=#1 1'b1; // module_select bit
    calculate_crc(1'b1);
    gen_clk(1);

    for(i=`DBG_TOP_MODULE_ID_LENGTH -1; i>=0; i=i-1) // Shifting module ID
    begin
      tdi_pad_i<=#1 data[i];
      calculate_crc(data[i]);
      gen_clk(1);
    end

    for(i=`DBG_TOP_CRC_LEN -1; i>=0; i=i-1)
    begin
      if (gen_crc_err & (i==0))  // Generate crc error at last crc bit
        tdi_pad_i<=#1 ~crc_out[i];   // error crc
      else
        tdi_pad_i<=#1 crc_out[i];    // ok crc

      gen_clk(1);
    end

    tdi_pad_i<=#1 1'hz;  // tri-state

    crc_in = {`DBG_TOP_CRC_LEN{1'b1}};  // Initialize incoming CRC to all ff

    for(i=`DBG_TOP_STATUS_LEN -1; i>=0; i=i-1)
      begin
        gen_clk(1);     // Generating 1 clock to read out a status bit.
        status[i] = tdo;
      end

    for(i=0; i<`DBG_TOP_CRC_LEN -1; i=i+1)
      gen_clk(1);

    tms_pad_i<=#1 1'b1;
    gen_clk(1);         // to exit1_dr

    if (~crc_match_in)
      begin
        $display("(%0t) Incoming CRC failed !!!", $time);
        $stop;
      end

    tms_pad_i<=#1 1'b1;
    gen_clk(1);         // to update_dr
    tms_pad_i<=#1 1'b0;
    gen_clk(1);         // to run_test_idle

    if (|status)
      begin
        $write("(*E) (%0t) Module select error: ", $time);
        casex (status)
          4'b1xxx : $display("CRC error !!!\n\n", $time);
          4'bx1xx : $display("Non-existing module selected !!!\n\n", $time);
          4'bxx1x : $display("Status[1] should be 1'b0 !!!\n\n", $time);
          4'bxxx1 : $display("Status[0] should be 1'b0 !!!\n\n", $time);
        endcase
        $stop;
      end
  end
endtask   // module_select




`ifdef DBG_WISHBONE_SUPPORTED
task debug_wishbone;
  input [`DBG_WB_CMD_LEN -1:0]   command;
  input         ready;
  input [`DBG_WB_ADR_LEN -1:0]  addr;
  input [`DBG_WB_LEN_LEN -1:0]  length;
  input         gen_crc_err;
  input [99:0]  text;
  integer i;
  
  begin
   $write("(%0t) Task debug_wishbone: ", $time);

    test_text = text;

    case (command)
      `DBG_WB_READ8    :  
        begin
          $display("wb_read8 (adr=0x%0x, length=0x%0x, gen_crc_err=%0d (%0s))", addr, length, gen_crc_err, text);
          debug_wishbone_wr_comm(`DBG_WB_READ8, addr, length, gen_crc_err);
          last_wb_cmd = `DBG_WB_READ8;  last_wb_cmd_text = "DBG_WB_READ8";
#10000;
          length_global = length + 1;
          debug_wishbone_go(ready, gen_crc_err);
        end
      `DBG_WB_READ16   :  
        begin
          $display("wb_read16 (adr=0x%0x, length=0x%0x, gen_crc_err=%0d (%0s))", addr, length, gen_crc_err, text);
          debug_wishbone_wr_comm(`DBG_WB_READ16, addr, length, gen_crc_err);
          last_wb_cmd = `DBG_WB_READ16;  last_wb_cmd_text = "DBG_WB_READ16";
#10000;
          length_global = length + 1;
          debug_wishbone_go(ready, gen_crc_err);
        end
      `DBG_WB_READ32   :  
        begin
          $display("wb_read32 (adr=0x%0x, length=0x%0x, gen_crc_err=%0d (%0s))", addr, length, gen_crc_err, text);
          debug_wishbone_wr_comm(`DBG_WB_READ32, addr, length, gen_crc_err);
          last_wb_cmd = `DBG_WB_READ32;  last_wb_cmd_text = "DBG_WB_READ32";
#10000;
          length_global = length + 1;
          debug_wishbone_go(ready, gen_crc_err);
        end
      `DBG_WB_WRITE8   :  
        begin
          $display("wb_write8 (adr=0x%0x, length=0x%0x, gen_crc_err=%0d (%0s))", addr, length, gen_crc_err, text);
          debug_wishbone_wr_comm(`DBG_WB_WRITE8, addr, length, gen_crc_err);
          last_wb_cmd = `DBG_WB_WRITE8;  last_wb_cmd_text = "DBG_WB_WRITE8";
#10000;
          length_global = length + 1;
          debug_wishbone_go(ready, gen_crc_err);
        end
      `DBG_WB_WRITE16  :  
        begin
          $display("wb_write16 (adr=0x%0x, length=0x%0x, gen_crc_err=%0d (%0s))", addr, length, gen_crc_err, text);
          debug_wishbone_wr_comm(`DBG_WB_WRITE16, addr, length, gen_crc_err);
          last_wb_cmd = `DBG_WB_WRITE16;  last_wb_cmd_text = "DBG_WB_WRITE16";
#10000;
          length_global = length + 1;
          debug_wishbone_go(ready, gen_crc_err);
        end
      `DBG_WB_WRITE32  :  
        begin
          $display("wb_write32 (adr=0x%0x, length=0x%0x, gen_crc_err=%0d (%0s))", addr, length, gen_crc_err, text);
          debug_wishbone_wr_comm(`DBG_WB_WRITE32, addr, length, gen_crc_err);
          last_wb_cmd = `DBG_WB_WRITE32;  last_wb_cmd_text = "DBG_WB_WRITE32";
#10000;
          length_global = length + 1;
          debug_wishbone_go(ready, gen_crc_err);
        end
      default:
        begin
          $display("(*E) debug_wishbone : Unsupported instruction !!!");
          $stop;
        end
    endcase
  end
endtask       // debug_wishbone






task debug_wishbone_wr_comm;
  input [`DBG_WB_ACC_TYPE_LEN -1:0]   acc_type;
  input [`DBG_WB_ADR_LEN -1:0]        addr;
  input [`DBG_WB_LEN_LEN -1:0]        length;
  input                               gen_crc_err;
  integer                             i;
  reg   [`DBG_WB_CMD_LEN -1:0]        command;
  
  begin
    $display("(%0t) Task debug_wishbone_wr_comm: ", $time);

    command = `DBG_WB_WR_COMM;
    tms_pad_i<=#1 1'b1;
    gen_clk(1);
    tms_pad_i<=#1 1'b0;
    gen_clk(2);  // we are in shiftDR

    crc_out = {`DBG_WB_CRC_LEN{1'b1}}; // Initialize outgoing CRC to all ff

    tdi_pad_i<=#1 1'b0; // module_select bit = 0
    calculate_crc(1'b0);
    gen_clk(1);

    for(i=`DBG_WB_CMD_LEN -1; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 command[i]; // command
      calculate_crc(command[i]);
      gen_clk(1);
    end

    for(i=`DBG_WB_ACC_TYPE_LEN -1; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 acc_type[i]; // command
      calculate_crc(acc_type[i]);
      gen_clk(1);
    end

    for(i=`DBG_WB_ADR_LEN -1; i>=0; i=i-1)       // address
    begin
      tdi_pad_i<=#1 addr[i];
      calculate_crc(addr[i]);
      gen_clk(1);
    end
 
    for(i=`DBG_WB_LEN_LEN -1; i>=0; i=i-1)       // length
    begin
      tdi_pad_i<=#1 length[i];
      calculate_crc(length[i]);
      gen_clk(1);
    end

    for(i=`DBG_WB_CRC_LEN -1; i>=0; i=i-1)
    begin
      if (gen_crc_err & (i==0))  // Generate crc error at last crc bit
        tdi_pad_i<=#1 ~crc_out[i];   // error crc
      else
        tdi_pad_i<=#1 crc_out[i];    // ok crc

      gen_clk(1);
    end

    tdi_pad_i<=#1 1'hz;

    crc_in = {`DBG_WB_CRC_LEN{1'b1}};  // Initialize incoming CRC to all ff

    for(i=`DBG_WB_STATUS_LEN -1; i>=0; i=i-1)
      begin
        gen_clk(1);     // Generating clock to read out a status bit.
        status_wb[i] = tdo;
      end

    if (|status_wb)
      begin
        $write("(*E) (%0t) debug_wishbone_wr_comm error: ", $time);
        casex (status_wb)
          4'b1xxx : $display("CRC error !!!\n\n", $time);
          4'bx1xx : $display("Unknown command !!!\n\n", $time);
          4'bxx1x : $display("WISHBONE error !!!\n\n", $time);
          4'bxxx1 : $display("Overrun/Underrun !!!\n\n", $time);
        endcase
        $stop;
      end


    for(i=0; i<`DBG_WB_CRC_LEN -1; i=i+1)  // Getting in the CRC
    begin
      gen_clk(1);
    end

    tms_pad_i<=#1 1'b1;
    gen_clk(1);         // to exit1_dr

    if (~crc_match_in)
      begin
        $display("(%0t) Incoming CRC failed !!!", $time);
        $stop;
      end

    tms_pad_i<=#1 1'b1;
    gen_clk(1);         // to update_dr
    tms_pad_i<=#1 1'b0;
    gen_clk(1);         // to run_test_idle
  end
endtask       // debug_wishbone_wr_comm





task debug_wishbone_rd_comm;
  output [`DBG_WB_ACC_TYPE_LEN -1:0]  acc_type;
  output [`DBG_WB_ADR_LEN -1:0]       addr;
  output [`DBG_WB_LEN_LEN -1:0]       length;
  integer                             i;
  reg   [`DBG_WB_CMD_LEN -1:0]        command;
  
  begin
    $display("(%0t) Task debug_wishbone_rd_comm: ", $time);

    command = `DBG_WB_RD_COMM;
    tms_pad_i<=#1 1'b1;
    gen_clk(1);
    tms_pad_i<=#1 1'b0;
    gen_clk(2);  // we are in shiftDR

    crc_out = {`DBG_WB_CRC_LEN{1'b1}}; // Initialize outgoing CRC to all ff

    tdi_pad_i<=#1 1'b0; // module_select bit = 0
    calculate_crc(1'b0);
    gen_clk(1);

    for(i=`DBG_WB_CMD_LEN -1; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 command[i]; // command
      calculate_crc(command[i]);
      gen_clk(1);
    end

    for(i=`DBG_WB_CRC_LEN -1; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 crc_out[i];
      gen_clk(1);
    end

    tdi_pad_i<=#1 1'hz;

    crc_in = {`DBG_WB_CRC_LEN{1'b1}};  // Initialize incoming CRC to all ff

    for(i=`DBG_WB_ACC_TYPE_LEN -1; i>=0; i=i-1)
    begin
      gen_clk(1);
      acc_type[i] = tdo;
    end

    for(i=`DBG_WB_ADR_LEN -1; i>=0; i=i-1)       // address
    begin
      gen_clk(1);
      addr[i] = tdo;
    end
 
    for(i=`DBG_WB_LEN_LEN -1; i>=0; i=i-1)       // length
    begin
      gen_clk(1);
      length[i] = tdo;
    end

    for(i=`DBG_WB_STATUS_LEN -1; i>=0; i=i-1)
      begin
        gen_clk(1);     // Generating clock to read out a status bit.
        status_wb[i] = tdo;
      end

    if (|status_wb)
      begin
        $write("(*E) (%0t) debug_wishbone_rd_comm: ", $time);
        casex (status_wb)
          4'b1xxx : $display("CRC error !!!\n\n", $time);
          4'bx1xx : $display("Unknown command !!!\n\n", $time);
          4'bxx1x : $display("Unknown command !!!\n\n", $time);
          4'bxxx1 : $display("Unknown command !!!\n\n", $time);
        endcase
        $stop;
      end


    for(i=0; i<`DBG_WB_CRC_LEN -1; i=i+1)  // Getting in the CRC
    begin
      gen_clk(1);
    end

    tms_pad_i<=#1 1'b1;
    gen_clk(1);         // to exit1_dr

    if (~crc_match_in)
      begin
        $display("(%0t) Incoming CRC failed !!!", $time);
        $stop;
      end

    tms_pad_i<=#1 1'b1;
    gen_clk(1);         // to update_dr
    tms_pad_i<=#1 1'b0;
    gen_clk(1);         // to run_test_idle
  end
endtask       // debug_wishbone_rd_comm





task debug_wishbone_go;
  input         wait_for_wb_ready;
  input         gen_crc_err;
  integer i;
  reg   [4:0]   bit_pointer;
  integer       word_pointer;
  reg  [31:0]   tmp_data;
  reg [`DBG_WB_CMD_LEN -1:0]        command;

 
  begin
    $display("(%0t) Task debug_wishbone_go (previous command was %0s): ", $time, last_wb_cmd_text);
    command = `DBG_WB_GO;
    word_pointer = 0;

    tms_pad_i<=#1 1'b1;
    gen_clk(1);
    tms_pad_i<=#1 1'b0;
    gen_clk(2);  // we are in shiftDR

    crc_out = {`DBG_WB_CRC_LEN{1'b1}}; // Initialize outgoing CRC to all ff

    tdi_pad_i<=#1 1'b0; // module_select bit = 0
    calculate_crc(1'b0);
    gen_clk(1);

    for(i=`DBG_WB_CMD_LEN -1; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 command[i]; // command
      calculate_crc(command[i]);
      gen_clk(1);
    end


    if ((last_wb_cmd == `DBG_WB_WRITE8) | (last_wb_cmd == `DBG_WB_WRITE16) | (last_wb_cmd == `DBG_WB_WRITE32))  // When WB_WRITEx was previously activated, data needs to be shifted.
      begin
        for (i=0; i<((length_global) << 3); i=i+1)
          begin
            tmp_data = wb_data[word_pointer];
            if ((!(i%32)) && (i>0))
              begin
                word_pointer = word_pointer + 1;
              end
            bit_pointer = 31-i[4:0];
            tdi_pad_i<=#1 tmp_data[bit_pointer];
            calculate_crc(tmp_data[bit_pointer]);
            gen_clk(1);

          end
      end

    for(i=`DBG_WB_CRC_LEN -1; i>=1; i=i-1)
    begin
      tdi_pad_i<=#1 crc_out[i];
      gen_clk(1);
    end

    if (gen_crc_err)  // Generate crc error at last crc bit
      tdi_pad_i<=#1 ~crc_out[0];   // error crc
    else
      tdi_pad_i<=#1 crc_out[0];    // ok crc

    if (wait_for_wb_ready)
      begin
        tms_pad_i<=#1 1'b1;
        gen_clk(1);       // to exit1_dr. Last CRC is shifted on this clk
        tms_pad_i<=#1 1'b0;
        gen_clk(1);       // to pause_dr

        #2;             // wait a bit for tdo to activate
        while (tdo)     // waiting for wb to send "ready"
        begin
          gen_clk(1);       // staying in pause_dr
        end
 
        tms_pad_i<=#1 1'b1;
        gen_clk(1);       // to exit2_dr
        tms_pad_i<=#1 1'b0;
        gen_clk(1);       // to shift_dr
      end
    else
      begin
        gen_clk(1);       // Last CRC is shifted on this clk
      end


    tdi_pad_i<=#1 1'hz;
    crc_in = {`DBG_WB_CRC_LEN{1'b1}};  // Initialize incoming CRC to all ff

    if ((last_wb_cmd == `DBG_WB_READ8) | (last_wb_cmd == `DBG_WB_READ16) | (last_wb_cmd == `DBG_WB_READ32))  // When WB_READx was previously activated, data needs to be shifted.
      begin
        $display("\t\tGenerating %0d clocks to read %0d data bytes.", length_global<<3, length_global);
        word_pointer = 0; // Reset pointer
        for (i=0; i<(length_global<<3); i=i+1)
          begin
            gen_clk(1);
            if (i[4:0] == 31)   // Latching data
              begin
                wb_data[word_pointer] = in_data_be;
                $display("\t\tin_data_be = 0x%x", in_data_be);
                word_pointer = word_pointer + 1;
              end
          end
      end


    for(i=`DBG_WB_STATUS_LEN -1; i>=0; i=i-1)
      begin
        gen_clk(1);     // Generating clock to read out a status bit.
        status_wb[i] = tdo;
      end

    if (|status_wb)
      begin
        $write("(*E) (%0t) debug_wishbone_go error: ", $time);
        casex (status_wb)
          4'b1xxx : $display("CRC error !!!\n\n", $time);
          4'bx1xx : $display("Unknown command !!!\n\n", $time);
          4'bxx1x : $display("WISHBONE error !!!\n\n", $time);
          4'bxxx1 : $display("Overrun/Underrun !!!\n\n", $time);
        endcase
        $stop;
      end


    for(i=0; i<`DBG_WB_CRC_LEN -1; i=i+1)  // Getting in the CRC
    begin
      gen_clk(1);
    end

    tms_pad_i<=#1 1'b1;
    gen_clk(1);         // to exit1_dr

    if (~crc_match_in)
      begin
        $display("(%0t) Incoming CRC failed !!!", $time);
        $stop;
      end

    tms_pad_i<=#1 1'b1;
    gen_clk(1);         // to update_dr
    tms_pad_i<=#1 1'b0;
    gen_clk(1);         // to run_test_idle
  end
endtask       // debug_wishbone_go


`endif // DBG_WISHBONE_SUPPORTED


`ifdef DBG_CPU_SUPPORTED
task debug_cpu;
  input [`DBG_CPU_CMD_LEN -1:0]   command;
  input                           ready;
  input [`DBG_CPU_ADR_LEN -1:0]   addr;
  input [`DBG_CPU_LEN_LEN -1:0]   length;
  input                           gen_crc_err;
  input [99:0]                    text;
  integer i;
  
  begin
   $write("(%0t) Task debug_cpu: ", $time);

    test_text = text;

    case (command)
      `DBG_CPU_READ   :  
        begin
          $display("cpu_read (adr=0x%0x, length=0x%0x, gen_crc_err=%0d (%0s))", addr, length, gen_crc_err, text);
          debug_cpu_wr_comm(`DBG_CPU_READ, addr, length, gen_crc_err);
          last_cpu_cmd = `DBG_CPU_READ;  last_cpu_cmd_text = "DBG_CPU_READ";
          length_global = length + 1;
#10000;
          debug_cpu_go(ready, gen_crc_err);
        end
      `DBG_CPU_WRITE  :  
        begin
          $display("cpu_write (adr=0x%0x, length=0x%0x, gen_crc_err=%0d (%0s))", addr, length, gen_crc_err, text);
          debug_cpu_wr_comm(`DBG_CPU_WRITE, addr, length, gen_crc_err);
          last_cpu_cmd = `DBG_CPU_WRITE;  last_cpu_cmd_text = "DBG_CPU_WRITE";
#10000;
          length_global = length + 1;
          debug_cpu_go(ready, gen_crc_err);
        end
      default:
        begin
          $display("(*E) debug_cpu : Unsupported instruction !!!");
          $stop;
        end
    endcase
  end
endtask       // debug_cpu



task debug_cpu_wr_comm;
  input [`DBG_CPU_ACC_TYPE_LEN -1:0]  acc_type;
  input [`DBG_CPU_ADR_LEN -1:0]       addr;
  input [`DBG_CPU_LEN_LEN -1:0]       length;
  input                               gen_crc_err;
  integer                             i;
  reg   [`DBG_CPU_CMD_LEN -1:0]       command;
  
  begin
    $display("(%0t) Task debug_cpu_wr_comm: ", $time);

    command = `DBG_CPU_WR_COMM;
    tms_pad_i<=#1 1'b1;
    gen_clk(1);
    tms_pad_i<=#1 1'b0;
    gen_clk(2);  // we are in shiftDR

    crc_out = {`DBG_CPU_CRC_LEN{1'b1}}; // Initialize outgoing CRC to all ff

    tdi_pad_i<=#1 1'b0; // module_select bit = 0
    calculate_crc(1'b0);
    gen_clk(1);

    for(i=`DBG_CPU_CMD_LEN -1; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 command[i]; // command
      calculate_crc(command[i]);
      gen_clk(1);
    end

    for(i=`DBG_CPU_ACC_TYPE_LEN -1; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 acc_type[i]; // command
      calculate_crc(acc_type[i]);
      gen_clk(1);
    end

    for(i=`DBG_CPU_ADR_LEN -1; i>=0; i=i-1)       // address
    begin
      tdi_pad_i<=#1 addr[i];
      calculate_crc(addr[i]);
      gen_clk(1);
    end
 
    for(i=`DBG_CPU_LEN_LEN -1; i>=0; i=i-1)       // length
    begin
      tdi_pad_i<=#1 length[i];
      calculate_crc(length[i]);
      gen_clk(1);
    end

    for(i=`DBG_CPU_CRC_LEN -1; i>=0; i=i-1)
    begin
      if (gen_crc_err & (i==0))      // Generate crc error at last crc bit
        tdi_pad_i<=#1 ~crc_out[i];   // error crc
      else
        tdi_pad_i<=#1 crc_out[i];    // ok crc

      gen_clk(1);
    end

    tdi_pad_i<=#1 1'hz;

    crc_in = {`DBG_CPU_CRC_LEN{1'b1}};  // Initialize incoming CRC to all ff

    for(i=`DBG_CPU_STATUS_LEN -1; i>=0; i=i-1)
      begin
        gen_clk(1);     // Generating clock to read out a status bit.
        status_cpu[i] = tdo;
      end

    if (|status_cpu)
      begin
        $write("(*E) (%0t) debug_cpu_wr_comm error: ", $time);
        casex (status_cpu)
          4'b1xxx : $display("CRC error !!!\n\n", $time);
          4'bx1xx : $display("Unknown command !!!\n\n", $time);
          4'bxx1x : $display("??? error !!!\n\n", $time);
          4'bxxx1 : $display("Overrun/Underrun !!!\n\n", $time);
        endcase
        $stop;
      end


    for(i=0; i<`DBG_CPU_CRC_LEN -1; i=i+1)  // Getting in the CRC
    begin
      gen_clk(1);
    end

    tms_pad_i<=#1 1'b1;
    gen_clk(1);         // to exit1_dr

    if (~crc_match_in)
      begin
        $display("(%0t) Incoming CRC failed !!!", $time);
        $stop;
      end

    tms_pad_i<=#1 1'b1;
    gen_clk(1);         // to update_dr
    tms_pad_i<=#1 1'b0;
    gen_clk(1);         // to run_test_idle
  end
endtask       // debug_cpu_wr_comm



task debug_cpu_wr_ctrl;
  input [`DBG_CPU_CTRL_LEN -1:0]  data;
  input [99:0]                    text;
  integer                         i;
  reg   [`DBG_CPU_CMD_LEN -1:0]   command;
  
  begin
    test_text = text;

    $display("(%0t) Task debug_cpu_wr_ctrl (data=0x%0x (%0s))", $time, data, text);

    command = `DBG_CPU_WR_CTRL;
    tms_pad_i<=#1 1'b1;
    gen_clk(1);
    tms_pad_i<=#1 1'b0;
    gen_clk(2);  // we are in shiftDR

    crc_out = {`DBG_CPU_CRC_LEN{1'b1}}; // Initialize outgoing CRC to all ff

    tdi_pad_i<=#1 1'b0; // module_select bit = 0
    calculate_crc(1'b0);
    gen_clk(1);

    for(i=`DBG_CPU_CMD_LEN -1; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 command[i]; // command
      calculate_crc(command[i]);
      gen_clk(1);
    end

    for(i=`DBG_CPU_CTRL_LEN -1; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 data[i];                                    // data (used cotrol bits
      calculate_crc(data[i]);
      gen_clk(1);
    end

    for(i=`DBG_CPU_DR_LEN - `DBG_CPU_CTRL_LEN -1; i>=0; i=i-1)  // unused control bits
    begin
      tdi_pad_i<=#1 1'b0;
      calculate_crc(1'b0);
      gen_clk(1);
    end

    for(i=`DBG_CPU_CRC_LEN -1; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 crc_out[i];    // ok crc
      gen_clk(1);
    end

    tdi_pad_i<=#1 1'hz;

    crc_in = {`DBG_CPU_CRC_LEN{1'b1}};  // Initialize incoming CRC to all ff

    for(i=`DBG_CPU_STATUS_LEN -1; i>=0; i=i-1)
      begin
        gen_clk(1);     // Generating clock to read out a status bit.
        status_cpu[i] = tdo;
      end

    if (|status_cpu)
      begin
        $write("(*E) (%0t) debug_cpu_wr_ctrl error: ", $time);
        casex (status_cpu)
          4'b1xxx : $display("CRC error !!!\n\n", $time);
          4'bx1xx : $display("??? error !!!\n\n", $time);
          4'bxx1x : $display("??? error !!!\n\n", $time);
          4'bxxx1 : $display("??? error !!!\n\n", $time);
        endcase
        $stop;
      end


    for(i=0; i<`DBG_CPU_CRC_LEN -1; i=i+1)  // Getting in the CRC
    begin
      gen_clk(1);
    end

    tms_pad_i<=#1 1'b1;
    gen_clk(1);         // to exit1_dr

    if (~crc_match_in)
      begin
        $display("(%0t) Incoming CRC failed !!!", $time);
        $stop;
      end

    tms_pad_i<=#1 1'b1;
    gen_clk(1);         // to update_dr
    tms_pad_i<=#1 1'b0;
    gen_clk(1);         // to run_test_idle
  end
endtask       // debug_cpu_wr_ctrl



task debug_cpu_rd_ctrl;
  output [`DBG_CPU_CTRL_LEN -1:0] data;
  input  [99:0] text;
  integer                         i;
  reg   [`DBG_CPU_CMD_LEN -1:0]   command;
  
  begin
    test_text = text;
    $display("(%0t) Task debug_cpu_rd_ctrl: ", $time);

    command = `DBG_CPU_RD_CTRL;
    tms_pad_i<=#1 1'b1;
    gen_clk(1);
    tms_pad_i<=#1 1'b0;
    gen_clk(2);  // we are in shiftDR

    crc_out = {`DBG_CPU_CRC_LEN{1'b1}}; // Initialize outgoing CRC to all ff

    tdi_pad_i<=#1 1'b0; // module_select bit = 0
    calculate_crc(1'b0);
    gen_clk(1);

    for(i=`DBG_CPU_CMD_LEN -1; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 command[i]; // command
      calculate_crc(command[i]);
      gen_clk(1);
    end

    for(i=`DBG_CPU_CRC_LEN -1; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 crc_out[i];
      gen_clk(1);
    end

    tdi_pad_i<=#1 1'hz;

    crc_in = {`DBG_CPU_CRC_LEN{1'b1}};  // Initialize incoming CRC to all ff

    for(i=`DBG_CPU_CTRL_LEN -1; i>=0; i=i-1)     // data (used control bits)
    begin
      gen_clk(1);
      data[i] = tdo;
    end
 
    for(i=`DBG_CPU_DR_LEN - `DBG_CPU_CTRL_LEN -1; i>=0; i=i-1)       // unused control bits
    begin
      gen_clk(1);
    end

    for(i=`DBG_CPU_STATUS_LEN -1; i>=0; i=i-1)
      begin
        gen_clk(1);     // Generating clock to read out a status bit.
        status_cpu[i] = tdo;
      end

    if (|status_cpu)
      begin
        $write("(*E) (%0t) debug_cpu_rd_ctrl: ", $time);
        casex (status_cpu)
          4'b1xxx : $display("CRC error !!!\n\n", $time);
          4'bx1xx : $display("Unknown command !!!\n\n", $time);
          4'bxx1x : $display("Unknown command !!!\n\n", $time);
          4'bxxx1 : $display("Unknown command !!!\n\n", $time);
        endcase
        $stop;
      end


    for(i=0; i<`DBG_CPU_CRC_LEN -1; i=i+1)  // Getting in the CRC
    begin
      gen_clk(1);
    end

    tms_pad_i<=#1 1'b1;
    gen_clk(1);         // to exit1_dr

    if (~crc_match_in)
      begin
        $display("(%0t) Incoming CRC failed !!!", $time);
        $stop;
      end

    tms_pad_i<=#1 1'b1;
    gen_clk(1);         // to update_dr
    tms_pad_i<=#1 1'b0;
    gen_clk(1);         // to run_test_idle
  end
endtask       // debug_cpu_rd_ctrl



task debug_cpu_go;
  input         wait_for_cpu_ready;
  input         gen_crc_err;
  integer i;
  reg   [4:0]   bit_pointer;
  integer       word_pointer;
  reg  [31:0]   tmp_data;
  reg [`DBG_CPU_CMD_LEN -1:0]       command;

 
  begin
    $display("(%0t) Task debug_cpu_go (previous command was %0s): ", $time, last_cpu_cmd_text);
    command = `DBG_CPU_GO;
    word_pointer = 0;

    tms_pad_i<=#1 1'b1;
    gen_clk(1);
    tms_pad_i<=#1 1'b0;
    gen_clk(2);  // we are in shiftDR

    crc_out = {`DBG_CPU_CRC_LEN{1'b1}}; // Initialize outgoing CRC to all ff

    tdi_pad_i<=#1 1'b0; // module_select bit = 0
    calculate_crc(1'b0);
    gen_clk(1);

    for(i=`DBG_CPU_CMD_LEN -1; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 command[i]; // command
      calculate_crc(command[i]);
      gen_clk(1);
    end


    if (last_cpu_cmd == `DBG_CPU_WRITE)  // When DBG_CPU_WRITE was previously activated, data needs to be shifted.
      begin
        for (i=0; i<((length_global) << 3); i=i+1)
          begin
            tmp_data = wb_data[word_pointer];
            if ((!(i%32)) && (i>0))
              begin
                word_pointer = word_pointer + 1;
              end
            bit_pointer = 31-i[4:0];
            tdi_pad_i<=#1 tmp_data[bit_pointer];
            calculate_crc(tmp_data[bit_pointer]);
            gen_clk(1);

          end
      end

    for(i=`DBG_CPU_CRC_LEN -1; i>=1; i=i-1)
    begin
      tdi_pad_i<=#1 crc_out[i];
      gen_clk(1);
    end

    if (gen_crc_err)  // Generate crc error at last crc bit
      tdi_pad_i<=#1 ~crc_out[0];   // error crc
    else
      tdi_pad_i<=#1 crc_out[0];    // ok crc

    if (wait_for_cpu_ready)
      begin
        tms_pad_i<=#1 1'b1;
        gen_clk(1);       // to exit1_dr. Last CRC is shifted on this clk
        tms_pad_i<=#1 1'b0;
        gen_clk(1);       // to pause_dr

        #2;             // wait a bit for tdo to activate
        while (tdo)     // waiting for wb to send "ready"
        begin
          gen_clk(1);       // staying in pause_dr
        end
 
        tms_pad_i<=#1 1'b1;
        gen_clk(1);       // to exit2_dr
        tms_pad_i<=#1 1'b0;
        gen_clk(1);       // to shift_dr
      end
    else
      begin
        gen_clk(1);       // Last CRC is shifted on this clk
      end


    tdi_pad_i<=#1 1'hz;
    crc_in = {`DBG_CPU_CRC_LEN{1'b1}};  // Initialize incoming CRC to all ff

    if (last_cpu_cmd == `DBG_CPU_READ)  // When DBG_CPU_READ was previously activated, data needs to be shifted.
      begin
        $display("\t\tGenerating %0d clocks to read %0d data bytes.", length_global<<3, length_global);
        word_pointer = 0; // Reset pointer
        for (i=0; i<(length_global<<3); i=i+1)
          begin
            gen_clk(1);
            if (i[4:0] == 31)   // Latching data
              begin
                wb_data[word_pointer] = in_data_be;
                $display("\t\tin_data_be = 0x%x", in_data_be);
                word_pointer = word_pointer + 1;
              end
          end
      end


    for(i=`DBG_CPU_STATUS_LEN -1; i>=0; i=i-1)
      begin
        gen_clk(1);     // Generating clock to read out a status bit.
        status_cpu[i] = tdo;
      end

    if (|status_cpu)
      begin
        $write("(*E) (%0t) debug_cpu_go error: ", $time);
        casex (status_cpu)
          4'b1xxx : $display("CRC error !!!\n\n", $time);
          4'bx1xx : $display("Unknown command !!!\n\n", $time);
          4'bxx1x : $display("??? error !!!\n\n", $time);
          4'bxxx1 : $display("Overrun/Underrun !!!\n\n", $time);
        endcase
        $stop;
      end


    for(i=0; i<`DBG_CPU_CRC_LEN -1; i=i+1)  // Getting in the CRC
    begin
      gen_clk(1);
    end

    tms_pad_i<=#1 1'b1;
    gen_clk(1);         // to exit1_dr

    if (~crc_match_in)
      begin
        $display("(%0t) Incoming CRC failed !!!", $time);
        $stop;
      end

    tms_pad_i<=#1 1'b1;
    gen_clk(1);         // to update_dr
    tms_pad_i<=#1 1'b0;
    gen_clk(1);         // to run_test_idle
  end
endtask       // debug_cpu_go
`endif  // DBG_CPU_SUPPORTED



always @ (posedge tck_pad_i)
begin
  in_data_be[31:1] <= #1 in_data_be[30:0];
  in_data_be[0]    <= #1 tdo;

  in_data_le[31]   <= #1 tdo;
  in_data_le[30:0] <= #1 in_data_le[31:1];
end



// Calculating outgoing CRC
task calculate_crc;
  input data;
 
  begin
    crc_out[0]  <= #1 data          ^ crc_out[31];
    crc_out[1]  <= #1 data          ^ crc_out[0]  ^ crc_out[31];
    crc_out[2]  <= #1 data          ^ crc_out[1]  ^ crc_out[31];
    crc_out[3]  <= #1 crc_out[2];
    crc_out[4]  <= #1 data          ^ crc_out[3]  ^ crc_out[31];
    crc_out[5]  <= #1 data          ^ crc_out[4]  ^ crc_out[31];
    crc_out[6]  <= #1 crc_out[5];
    crc_out[7]  <= #1 data          ^ crc_out[6]  ^ crc_out[31];
    crc_out[8]  <= #1 data          ^ crc_out[7]  ^ crc_out[31];
    crc_out[9]  <= #1 crc_out[8];
    crc_out[10] <= #1 data         ^ crc_out[9]  ^ crc_out[31];
    crc_out[11] <= #1 data         ^ crc_out[10] ^ crc_out[31];
    crc_out[12] <= #1 data         ^ crc_out[11] ^ crc_out[31];
    crc_out[13] <= #1 crc_out[12];
    crc_out[14] <= #1 crc_out[13];
    crc_out[15] <= #1 crc_out[14];
    crc_out[16] <= #1 data         ^ crc_out[15] ^ crc_out[31];
    crc_out[17] <= #1 crc_out[16];
    crc_out[18] <= #1 crc_out[17];
    crc_out[19] <= #1 crc_out[18];
    crc_out[20] <= #1 crc_out[19];
    crc_out[21] <= #1 crc_out[20];
    crc_out[22] <= #1 data         ^ crc_out[21] ^ crc_out[31];
    crc_out[23] <= #1 data         ^ crc_out[22] ^ crc_out[31];
    crc_out[24] <= #1 crc_out[23];
    crc_out[25] <= #1 crc_out[24];
    crc_out[26] <= #1 data         ^ crc_out[25] ^ crc_out[31];
    crc_out[27] <= #1 crc_out[26];
    crc_out[28] <= #1 crc_out[27];
    crc_out[29] <= #1 crc_out[28];
    crc_out[30] <= #1 crc_out[29];
    crc_out[31] <= #1 crc_out[30];
  end
endtask // calculate_crc


// Calculating and checking input CRC
always @(posedge tck_pad_i)
begin
  crc_in[0]  <= #1 tdo           ^ crc_in[31];
  crc_in[1]  <= #1 tdo           ^ crc_in[0]  ^ crc_in[31];
  crc_in[2]  <= #1 tdo           ^ crc_in[1]  ^ crc_in[31];
  crc_in[3]  <= #1 crc_in[2];
  crc_in[4]  <= #1 tdo           ^ crc_in[3]  ^ crc_in[31];
  crc_in[5]  <= #1 tdo           ^ crc_in[4]  ^ crc_in[31];
  crc_in[6]  <= #1 crc_in[5];
  crc_in[7]  <= #1 tdo           ^ crc_in[6]  ^ crc_in[31];
  crc_in[8]  <= #1 tdo           ^ crc_in[7]  ^ crc_in[31];
  crc_in[9]  <= #1 crc_in[8];
  crc_in[10] <= #1 tdo          ^ crc_in[9]  ^ crc_in[31];
  crc_in[11] <= #1 tdo          ^ crc_in[10] ^ crc_in[31];
  crc_in[12] <= #1 tdo          ^ crc_in[11] ^ crc_in[31];
  crc_in[13] <= #1 crc_in[12];
  crc_in[14] <= #1 crc_in[13];
  crc_in[15] <= #1 crc_in[14];
  crc_in[16] <= #1 tdo          ^ crc_in[15] ^ crc_in[31];
  crc_in[17] <= #1 crc_in[16];
  crc_in[18] <= #1 crc_in[17];
  crc_in[19] <= #1 crc_in[18];
  crc_in[20] <= #1 crc_in[19];
  crc_in[21] <= #1 crc_in[20];
  crc_in[22] <= #1 tdo          ^ crc_in[21] ^ crc_in[31];
  crc_in[23] <= #1 tdo          ^ crc_in[22] ^ crc_in[31];
  crc_in[24] <= #1 crc_in[23];
  crc_in[25] <= #1 crc_in[24];
  crc_in[26] <= #1 tdo          ^ crc_in[25] ^ crc_in[31];
  crc_in[27] <= #1 crc_in[26];
  crc_in[28] <= #1 crc_in[27];
  crc_in[29] <= #1 crc_in[28];
  crc_in[30] <= #1 crc_in[29];
  crc_in[31] <= #1 crc_in[30];
end

assign crc_match_in = crc_in == 32'h0;



/**********************************************************************************
*                                                                                 *
*   Printing the information to the screen                                        *
*                                                                                 *
**********************************************************************************/

`ifdef DBG_MORE_INFO
always @ (posedge tck_pad_i)
begin
  if(dbg_tb.i_tap_top.update_ir)
    case(dbg_tb.i_tap_top.jtag_ir[`IR_LENGTH-1:0])
      `EXTEST         : $display("\tInstruction EXTEST entered");
      `SAMPLE_PRELOAD : $display("\tInstruction SAMPLE_PRELOAD entered");
      `IDCODE         : $display("\tInstruction IDCODE entered");
      `MBIST          : $display("\tInstruction MBIST entered");
      `DEBUG          : $display("\tInstruction DEBUG entered");
      `BYPASS         : $display("\tInstruction BYPASS entered");
		default           :	$display("\n\tInstruction not valid. Instruction BYPASS activated !!!");
    endcase
end
`endif


// We never use following states: exit2_ir,  exit2_dr,  pause_ir or pause_dr
always @ (posedge tck_pad_i)
begin
  if(dbg_tb.i_tap_top.pause_ir | dbg_tb.i_tap_top.exit2_ir)
    begin
      $display("\n(%0t) ERROR: State pause_ir or exit2_ir detected.", $time);
      $display("(%0t) Simulation stopped !!!", $time);
      $stop;
    end
end




endmodule // dbg_tb


