//////////////////////////////////////////////////////////////////////
////                                                              ////
////  can_testbench.v                                             ////
////                                                              ////
////                                                              ////
////  This file is part of the CAN Protocol Controller            ////
////  http://www.opencores.org/projects/can/                      ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor                                             ////
////       igorm@opencores.org                                    ////
////                                                              ////
////                                                              ////
////  All additional information is available in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2002, 2003 Authors                             ////
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
//// The CAN protocol is developed by Robert Bosch GmbH and       ////
//// protected by patents. Anybody who wants to implement this    ////
//// CAN IP core on silicon has to obtain a CAN protocol license  ////
//// from Bosch.                                                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.41  2005/07/11 10:25:13  igorm
// Fixing overrun problems.
//
// Revision 1.40  2004/03/18 17:39:17  igorm
// I forgot to thange one signal name.
//
// Revision 1.39  2004/03/18 17:15:26  igorm
// Signal bus_off_on added.
//
// Revision 1.38  2003/10/17 05:55:18  markom
// mbist signals updated according to newest convention
//
// Revision 1.37  2003/09/30 20:53:58  mohor
// Fixing the core to be Bosch VHDL Reference compatible.
//
// Revision 1.36  2003/08/20 10:03:20  mohor
// Artisan RAMs added.
//
// Revision 1.35  2003/06/17 15:14:48  mohor
// cs_can_i is used only when WISHBONE interface is not used.
//
// Revision 1.34  2003/03/26 11:25:39  mohor
// CAN inturrupt is active low.
//
// Revision 1.33  2003/03/14 19:37:30  mohor
// ALE changes on negedge of clk.
//
// Revision 1.32  2003/03/12 05:57:36  mohor
// Bidirectional port_0_i changed to port_0_io.
// input cs_can changed to cs_can_i.
//
// Revision 1.31  2003/03/12 04:40:00  mohor
// rd_i and wr_i are active high signals. If 8051 is connected, these two signals
// need to be negated one level higher.
//
// Revision 1.30  2003/03/12 04:16:40  mohor
// 8051 interface added (besides WISHBONE interface). Selection is made in
// can_defines.v file.
//
// Revision 1.29  2003/03/05 15:33:37  mohor
// tx_o is now tristated signal. tx_oen and tx_o combined together.
//
// Revision 1.28  2003/03/05 15:00:49  mohor
// Top level signal names changed.
//
// Revision 1.27  2003/03/01 22:48:26  mohor
// Actel APA ram supported.
//
// Revision 1.26  2003/02/19 14:43:17  mohor
// CAN core finished. Host interface added. Registers finished.
// Synchronization to the wishbone finished.
//
// Revision 1.25  2003/02/18 00:19:39  mohor
// Temporary backup version (still fully operable).
//
// Revision 1.24  2003/02/14 20:16:53  mohor
// Several registers added. Not finished, yet.
//
// Revision 1.23  2003/02/12 14:28:30  mohor
// Errors monitoring improved. arbitration_lost improved.
//
// Revision 1.22  2003/02/11 00:57:19  mohor
// Wishbone interface added.
//
// Revision 1.21  2003/02/09 18:40:23  mohor
// Overload fixed. Hard synchronization also enabled at the last bit of
// interframe.
//
// Revision 1.20  2003/02/09 02:24:11  mohor
// Bosch license warning added. Error counters finished. Overload frames
// still need to be fixed.
//
// Revision 1.19  2003/02/04 17:24:33  mohor
// Backup.
//
// Revision 1.18  2003/02/04 14:34:45  mohor
// *** empty log message ***
//
// Revision 1.17  2003/01/31 01:13:31  mohor
// backup.
//
// Revision 1.16  2003/01/16 13:36:14  mohor
// Form error supported. When receiving messages, last bit of the end-of-frame
// does not generate form error. Receiver goes to the idle mode one bit sooner.
// (CAN specification ver 2.0, part B, page 57).
//
// Revision 1.15  2003/01/15 21:05:06  mohor
// CRC checking fixed (when bitstuff occurs at the end of a CRC sequence).
//
// Revision 1.14  2003/01/15 14:40:16  mohor
// RX state machine fixed to receive "remote request" frames correctly. No
// data bytes are written to fifo when such frames are received.
//
// Revision 1.13  2003/01/15 13:16:42  mohor
// When a frame with "remote request" is received, no data is stored to
// fifo, just the frame information (identifier, ...). Data length that
// is stored is the received data length and not the actual data length
// that is stored to fifo.
//
// Revision 1.12  2003/01/14 17:25:03  mohor
// Addresses corrected to decimal values (previously hex).
//
// Revision 1.11  2003/01/14 12:19:29  mohor
// rx_fifo is now working.
//
// Revision 1.10  2003/01/10 17:51:28  mohor
// Temporary version (backup).
//
// Revision 1.9  2003/01/09 21:54:39  mohor
// rx fifo added. Not 100 % verified, yet.
//
// Revision 1.8  2003/01/08 02:09:43  mohor
// Acceptance filter added.
//
// Revision 1.7  2002/12/28 04:13:53  mohor
// Backup version.
//
// Revision 1.6  2002/12/27 00:12:48  mohor
// Header changed, testbench improved to send a frame (crc still missing).
//
// Revision 1.5  2002/12/26 16:00:29  mohor
// Testbench define file added. Clock divider register added.
//
// Revision 1.4  2002/12/26 01:33:01  mohor
// Tripple sampling supported.
//
// Revision 1.3  2002/12/25 23:44:12  mohor
// Commented lines removed.
//
// Revision 1.2  2002/12/25 14:16:54  mohor
// Synchronization working.
//
// Revision 1.1.1.1  2002/12/20 16:39:21  mohor
// Initial
//
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "can_defines.v"
`include "can_testbench_defines.v"

module can_testbench();



parameter Tp = 1;
parameter BRP = 2*(`CAN_TIMING0_BRP + 1);


`ifdef CAN_WISHBONE_IF
  reg         wb_clk_i;
  reg         wb_rst_i;
  reg   [7:0] wb_dat_i;
  wire  [7:0] wb_dat_o;
  reg         wb_cyc_i;
  reg         wb_stb_i;
  reg         wb_we_i;
  reg   [7:0] wb_adr_i;
  wire        wb_ack_o;
  reg         wb_free;
`else
  reg         rst_i;
  reg         ale_i;
  reg         rd_i;
  reg         wr_i;
  reg         ale2_i;
  reg         rd2_i;
  reg         wr2_i;
  wire  [7:0] port_0;
  wire  [7:0] port_0_i;
  reg   [7:0] port_0_o;
  reg         port_0_en;
  reg         port_free;
`endif


reg         cs_can;
reg         cs_can2;
reg         clk;
reg         rx;
wire        tx;
wire        tx_i;
wire        bus_off_on;
wire        irq;
wire        clkout;

wire        rx_and_tx;

integer     start_tb;
reg   [7:0] tmp_data;
reg         delayed_tx;
reg         tx_bypassed;
reg         extended_mode;

event       igor;

// Instantiate can_top module
can_top i_can_top
( 
`ifdef CAN_WISHBONE_IF
  .wb_clk_i(wb_clk_i),
  .wb_rst_i(wb_rst_i),
  .wb_dat_i(wb_dat_i),
  .wb_dat_o(wb_dat_o),
  .wb_cyc_i(wb_cyc_i),
  .wb_stb_i(wb_stb_i),
  .wb_we_i(wb_we_i),
  .wb_adr_i(wb_adr_i),
  .wb_ack_o(wb_ack_o),
`else
  .cs_can_i(cs_can),
  .rst_i(rst_i),
  .ale_i(ale_i),
  .rd_i(rd_i),
  .wr_i(wr_i),
  .port_0_io(port_0),
`endif
  .clk_i(clk),
  .rx_i(rx_and_tx),
  .tx_o(tx_i),
  .bus_off_on(bus_off_on),
  .irq_on(irq),
  .clkout_o(clkout)

  // Bist
`ifdef CAN_BIST
  ,
  // debug chain signals
  .mbist_si_i(1'b0),       // bist scan serial in
  .mbist_so_o(),           // bist scan serial out
  .mbist_ctrl_i(3'b001)    // mbist scan {enable, clock, reset}
`endif
);


// Instantiate can_top module 2
can_top i_can_top2
( 
`ifdef CAN_WISHBONE_IF
  .wb_clk_i(wb_clk_i),
  .wb_rst_i(wb_rst_i),
  .wb_dat_i(wb_dat_i),
  .wb_dat_o(wb_dat_o),
  .wb_cyc_i(wb_cyc_i),
  .wb_stb_i(wb_stb_i),
  .wb_we_i(wb_we_i),
  .wb_adr_i(wb_adr_i),
  .wb_ack_o(wb_ack_o),
`else
  .cs_can_i(cs_can2),
  .rst_i(rst_i),
  .ale_i(ale2_i),
  .rd_i(rd2_i),
  .wr_i(wr2_i),
  .port_0_io(port_0),
`endif
  .clk_i(clk),
  .rx_i(rx_and_tx),
  .tx_o(tx2_i),
  .bus_off_on(bus_off2_on),
  .irq_on(),
  .clkout_o(clkout)

  // Bist
`ifdef CAN_BIST
  ,
  // debug chain signals
  .mbist_si_i(1'b0),       // bist scan serial in
  .mbist_so_o(),           // bist scan serial out
  .mbist_ctrl_i(3'b001)    // mbist scan {enable, clock, reset}
`endif
);


// Combining tx with the output enable signal.
wire tx_tmp1;
wire tx_tmp2;

assign tx_tmp1 = bus_off_on?  tx_i  : 1'b1;
assign tx_tmp2 = bus_off2_on? tx2_i : 1'b1;

assign tx = tx_tmp1 & tx_tmp2;



`ifdef CAN_WISHBONE_IF
  // Generate wishbone clock signal 10 MHz
  initial
  begin
    wb_clk_i=0;
    forever #50 wb_clk_i = ~wb_clk_i;
  end
`endif


`ifdef CAN_WISHBONE_IF
`else
  assign port_0_i = port_0;
  assign port_0 = port_0_en? port_0_o : 8'hz;
`endif


// Generate clock signal 25 MHz
// Generate clock signal 16 MHz
initial
begin
  clk=0;
  //forever #20 clk = ~clk;
  forever #31.25 clk = ~clk;
end


initial
begin
  start_tb = 0;
  cs_can = 0;
  cs_can2 = 0;
  rx = 1;
  extended_mode = 0;
  tx_bypassed = 0;

  `ifdef CAN_WISHBONE_IF
    wb_dat_i = 'hz;
    wb_cyc_i = 0;
    wb_stb_i = 0;
    wb_we_i = 'hz;
    wb_adr_i = 'hz;
    wb_free = 1;
    wb_rst_i = 1;
    #200 wb_rst_i = 0;
    #200 start_tb = 1;
  `else
    rst_i = 1'b0;
    ale_i = 1'b0;
    rd_i  = 1'b0;
    wr_i  = 1'b0;
    ale2_i = 1'b0;
    rd2_i  = 1'b0;
    wr2_i  = 1'b0;
    port_0_o = 8'h0;
    port_0_en = 0;
    port_free = 1;
    rst_i = 1;
    #200 rst_i = 0;
    #200 start_tb = 1;
  `endif
end




// Generating delayed tx signal (CAN transciever delay)
always
begin
  wait (tx);
  repeat (2*BRP) @ (posedge clk);   // 4 time quants delay
  #1 delayed_tx = tx;
  wait (~tx);
  repeat (2*BRP) @ (posedge clk);   // 4 time quants delay
  #1 delayed_tx = tx;
end

//assign rx_and_tx = rx & delayed_tx;   FIX ME !!!
assign rx_and_tx = rx & (delayed_tx | tx_bypassed);   // When this signal is on, tx is not looped back to the rx.


// Main testbench
initial
begin
  wait(start_tb);

  // Set bus timing register 0
  write_register(8'd6, {`CAN_TIMING0_SJW, `CAN_TIMING0_BRP});
  write_register2(8'd6, {`CAN_TIMING0_SJW, `CAN_TIMING0_BRP});

  // Set bus timing register 1
  write_register(8'd7, {`CAN_TIMING1_SAM, `CAN_TIMING1_TSEG2, `CAN_TIMING1_TSEG1});
  write_register2(8'd7, {`CAN_TIMING1_SAM, `CAN_TIMING1_TSEG2, `CAN_TIMING1_TSEG1});


  // Set Clock Divider register
//  extended_mode = 1'b1;
//  write_register(8'd31, {extended_mode, 3'h0, 1'b0, 3'h0});   // Setting the normal mode (not extended)
  write_register2(8'd31, {extended_mode, 3'h0, 1'b0, 3'h0});   // Setting the normal mode (not extended)


  // Set Acceptance Code and Acceptance Mask registers (their address differs for basic and extended mode

  /* Set Acceptance Code and Acceptance Mask registers
  write_register(8'd16, 8'ha6); // acceptance code 0
  write_register(8'd17, 8'hb0); // acceptance code 1
  write_register(8'd18, 8'h12); // acceptance code 2
  write_register(8'd19, 8'h30); // acceptance code 3
  write_register(8'd20, 8'hff); // acceptance mask 0
  write_register(8'd21, 8'hff); // acceptance mask 1
  write_register(8'd22, 8'hff); // acceptance mask 2
  write_register(8'd23, 8'hff); // acceptance mask 3

  write_register2(8'd16, 8'ha6); // acceptance code 0
  write_register2(8'd17, 8'hb0); // acceptance code 1
  write_register2(8'd18, 8'h12); // acceptance code 2
  write_register2(8'd19, 8'h30); // acceptance code 3
  write_register2(8'd20, 8'hff); // acceptance mask 0
  write_register2(8'd21, 8'hff); // acceptance mask 1
  write_register2(8'd22, 8'hff); // acceptance mask 2
  write_register2(8'd23, 8'hff); // acceptance mask 3
*/

  // Set Acceptance Code and Acceptance Mask registers
  write_register(8'd4, 8'he8); // acceptance code
  write_register(8'd5, 8'h0f); // acceptance mask
  
  #10;
  repeat (1000) @ (posedge clk);
  
  // Switch-off reset mode
  write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});
  write_register2(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

  repeat (BRP) @ (posedge clk);   // At least BRP clocks needed before bus goes to dominant level. Otherwise 1 quant difference is possible
                                  // This difference is resynchronized later.

  // After exiting the reset mode sending bus free
  repeat (11) send_bit(1);

//  test_synchronization;       // test currently switched off
//  test_empty_fifo_ext;        // test currently switched off
//  test_full_fifo_ext;         // test currently switched off
//  send_frame_ext;             // test currently switched off
//  test_empty_fifo;            // test currently switched off
//  test_full_fifo;             // test currently switched off
//  test_reset_mode;              // test currently switched off
//  bus_off_test;               // test currently switched off
//  forced_bus_off;             // test currently switched off
//  send_frame_basic;           // test currently switched on
//  send_frame_extended;        // test currently switched off
//  self_reception_request;       // test currently switched off
//  manual_frame_basic;         // test currently switched off
//  manual_frame_ext;           // test currently switched off
//    error_test;
//    register_test;
    bus_off_recovery_test;


/*
  #5000;
  $display("\n\nStart rx/tx err cnt\n");
  -> igor;
 
  // Switch-off reset mode
  $display("Rest mode ON");
  write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});

  $display("Set extended mode");
  extended_mode = 1'b1;
  write_register(8'd31, {extended_mode, 3'h0, 1'b0, 3'h0});   // Setting the extended mode

  $display("Rest mode OFF");
  write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

  write_register(8'd14, 8'hde); // rx err cnt
  write_register(8'd15, 8'had); // tx err cnt

  read_register(8'd14, tmp_data); // rx err cnt
  read_register(8'd15, tmp_data); // tx err cnt

  // Switch-on reset mode
  $display("Switch-on reset mode");
  write_register(8'd0, {7'h0, `CAN_MODE_RESET});

  write_register(8'd14, 8'h12); // rx err cnt
  write_register(8'd15, 8'h34); // tx err cnt

  read_register(8'd14, tmp_data); // rx err cnt
  read_register(8'd15, tmp_data); // tx err cnt

  // Switch-off reset mode
  $display("Switch-off reset mode");
  write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

  read_register(8'd14, tmp_data); // rx err cnt
  read_register(8'd15, tmp_data); // tx err cnt

  // Switch-on reset mode
  $display("Switch-on reset mode");
  write_register(8'd0, {7'h0, `CAN_MODE_RESET});

  write_register(8'd14, 8'h56); // rx err cnt
  write_register(8'd15, 8'h78); // tx err cnt

  // Switch-off reset mode
  $display("Switch-off reset mode");
  write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

  read_register(8'd14, tmp_data); // rx err cnt
  read_register(8'd15, tmp_data); // tx err cnt
*/
  #1000;
  $display("CAN Testbench finished !");
  $stop;
end


task bus_off_recovery_test;
  begin
    -> igor;

    // Switch-on reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, (`CAN_MODE_RESET)});

    // Set Clock Divider register
    extended_mode = 1'b1;
    write_register(8'd31, {extended_mode, 3'h0, 1'b0, 3'h0});   // Setting the normal mode (not extended)
    write_register2(8'd31, {extended_mode, 3'h0, 1'b0, 3'h0});   // Setting the normal mode (not extended)

    write_register(8'd16, 8'h00); // acceptance code 0
    write_register(8'd17, 8'h00); // acceptance code 1
    write_register(8'd18, 8'h00); // acceptance code 2
    write_register(8'd19, 8'h00); // acceptance code 3
    write_register(8'd20, 8'hff); // acceptance mask 0
    write_register(8'd21, 8'hff); // acceptance mask 1
    write_register(8'd22, 8'hff); // acceptance mask 2
    write_register(8'd23, 8'hff); // acceptance mask 3

    write_register2(8'd16, 8'h00); // acceptance code 0
    write_register2(8'd17, 8'h00); // acceptance code 1
    write_register2(8'd18, 8'h00); // acceptance code 2
    write_register2(8'd19, 8'h00); // acceptance code 3
    write_register2(8'd20, 8'hff); // acceptance mask 0
    write_register2(8'd21, 8'hff); // acceptance mask 1
    write_register2(8'd22, 8'hff); // acceptance mask 2
    write_register2(8'd23, 8'hff); // acceptance mask 3

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    // Enable all interrupts
    write_register(8'd4, 8'hff); // irq enable register

    repeat (30) send_bit(1);
    -> igor;
    $display("(%0t) CAN should be idle now", $time);

    // Node 2 sends a message
    write_register2(8'd16, 8'h83); // tx registers
    write_register2(8'd17, 8'h12); // tx registers
    write_register2(8'd18, 8'h34); // tx registers
    write_register2(8'd19, 8'h45); // tx registers
    write_register2(8'd20, 8'h56); // tx registers
    write_register2(8'd21, 8'hde); // tx registers
    write_register2(8'd22, 8'had); // tx registers
    write_register2(8'd23, 8'hbe); // tx registers

    write_register2(8'd1, 8'h1);  // tx request

    // Wait until node 1 receives rx irq
    read_register(8'd3, tmp_data);
    while (!(tmp_data & 8'h01)) begin
      read_register(8'd3, tmp_data);
    end

    $display("Frame received by node 1.");

    // Node 1 will send a message and will receive many errors
    write_register(8'd16, 8'haa); // tx registers
    write_register(8'd17, 8'haa); // tx registers
    write_register(8'd18, 8'haa); // tx registers
    write_register(8'd19, 8'haa); // tx registers
    write_register(8'd20, 8'haa); // tx registers
    write_register(8'd21, 8'haa); // tx registers
    write_register(8'd22, 8'haa); // tx registers
    write_register(8'd23, 8'haa); // tx registers

    fork 
      begin
        write_register(8'd1, 8'h1);  // tx request
      end

      begin
        // Waiting until node 1 starts transmitting
        wait (!tx_i);
        repeat (33) send_bit(1);
        repeat (330) send_bit(0);
        repeat (1) send_bit(1);
      end

    join

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    repeat (1999) send_bit(1);

    // Switch-on reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, (`CAN_MODE_RESET)});

    write_register(8'd14, 8'h0); // rx err cnt

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, ~(`CAN_MODE_RESET)});


    // Wait some time before simulation ends
    repeat (10000) @ (posedge clk);
  end
endtask // bus_off_recovery_test


task error_test;
  begin
    // Switch-off reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, (`CAN_MODE_RESET)});

    // Set Clock Divider register
    extended_mode = 1'b1;
    write_register(8'd31, {extended_mode, 3'h0, 1'b0, 3'h0});   // Setting the normal mode (not extended)
    write_register2(8'd31, {extended_mode, 3'h0, 1'b0, 3'h0});   // Setting the normal mode (not extended)

    // Set error warning limit register
    write_register(8'd13, 8'h56); // error warning limit

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    // Enable all interrupts
    write_register(8'd4, 8'hff); // irq enable register

    repeat (300) send_bit(0);

    $display("Kr neki");

  end
endtask


task register_test;
  integer i, j, tmp;
  begin
    $display("Change mode to extended mode and test registers");
    // Switch-off reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, (`CAN_MODE_RESET)});

    // Set Clock Divider register
    extended_mode = 1'b1;
    write_register(8'd31, {extended_mode, 3'h0, 1'b0, 3'h0});   // Setting the normal mode (not extended)
    write_register2(8'd31, {extended_mode, 3'h0, 1'b0, 3'h0});   // Setting the normal mode (not extended)

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    for (i=1; i<128; i=i+1) begin
      for (j=0; j<8; j=j+1) begin
        read_register(i, tmp_data);
        write_register(i, tmp_data | (1 << j));
      end
    end

  end
endtask

task forced_bus_off;    // Forcing bus-off by writinf to tx_err_cnt register
  begin

    // Switch-on reset mode
    write_register(8'd0, {7'h0, `CAN_MODE_RESET});

    // Set Clock Divider register
    write_register(8'd31, {1'b1, 7'h0});    // Setting the extended mode (not normal)

    // Write 255 to tx_err_cnt register - Forcing bus-off
    write_register(8'd15, 255);

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

//    #1000000;
    #2500000;


    // Switch-on reset mode
    write_register(8'd0, {7'h0, `CAN_MODE_RESET});

    // Write 245 to tx_err_cnt register
    write_register(8'd15, 245);

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    #1000000;


  end
endtask   // forced_bus_off


task manual_frame_basic;    // Testbench sends a basic format frame
  begin


    // Switch-on reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});
  
    // Set Acceptance Code and Acceptance Mask registers
    write_register(8'd4, 8'h28); // acceptance code
    write_register(8'd5, 8'hff); // acceptance mask
    
    repeat (100) @ (posedge clk);
    
    // Switch-off reset mode
//    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});
    write_register(8'd0, 8'h1e);  // reset_off, all irqs enabled.

    // After exiting the reset mode sending bus free
    repeat (11) send_bit(1);

    write_register(8'd10, 8'h55); // Writing ID[10:3] = 0x55
    write_register(8'd11, 8'h77); // Writing ID[2:0] = 0x3, rtr = 1, length = 7
    write_register(8'd12, 8'h00); // data byte 1
    write_register(8'd13, 8'h00); // data byte 2
    write_register(8'd14, 8'h00); // data byte 3
    write_register(8'd15, 8'h00); // data byte 4
    write_register(8'd16, 8'h00); // data byte 5
    write_register(8'd17, 8'h00); // data byte 6
    write_register(8'd18, 8'h00); // data byte 7
    write_register(8'd19, 8'h00); // data byte 8

    tx_bypassed = 0;    // When this signal is on, tx is not looped back to the rx.
    

    fork
      begin
        tx_request_command;
//        self_reception_request_command;
      end

      begin
        #931;


        repeat (1)
        begin
          send_bit(0);  // SOF
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID arbi lost
          send_bit(1);  // RTR
          send_bit(0);  // IDE
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC stuff
          send_bit(0);  // CRC 6
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC  stuff
          send_bit(0);  // CRC 0
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC 5
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC b
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
#400;

          send_bit(0);  // SOF
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(1);  // RTR
          send_bit(0);  // IDE
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 6
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC 0
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 5
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC b
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
        end // repeat



      end
    
    
    join



    read_receive_buffer;
    release_rx_buffer_command;

    #1000 read_register(8'd3, tmp_data);
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;

// First we receive a msg
          send_bit(0);  // SOF
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(1);  // RTR
          send_bit(0);  // IDE
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 6
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC 0
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 5
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC b
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER





    fork
      begin
        tx_request_command;
//        self_reception_request_command;
      end

      begin
        #931;


        repeat (1)
        begin
          send_bit(0);  // SOF
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID arbi lost
          send_bit(1);  // RTR
          send_bit(0);  // IDE
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 6
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC 0
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 5
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC b
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
#6000;

          send_bit(0);  // SOF
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(1);  // RTR
          send_bit(0);  // IDE
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 6
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC 0
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 5
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC b
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
        end // repeat



      end
    
    
    join



    read_receive_buffer;
    release_rx_buffer_command;

    #1000 read_register(8'd3, tmp_data);
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;

    #4000000;

  end
endtask   //  manual_frame_basic



task manual_frame_ext;    // Testbench sends an extended format frame
  begin


    // Switch-on reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});

    // Set Clock Divider register
    extended_mode = 1'b1;
    write_register(8'd31, {extended_mode, 7'h0});    // Setting the extended mode
  
    // Set Acceptance Code and Acceptance Mask registers
    write_register(8'd16, 8'ha6); // acceptance code 0
    write_register(8'd17, 8'h00); // acceptance code 1
    write_register(8'd18, 8'h5a); // acceptance code 2
    write_register(8'd19, 8'hac); // acceptance code 3
    write_register(8'd20, 8'h00); // acceptance mask 0
    write_register(8'd21, 8'h00); // acceptance mask 1
    write_register(8'd22, 8'h00); // acceptance mask 2
    write_register(8'd23, 8'h00); // acceptance mask 3
    
//write_register(8'd14, 8'h7a); // rx err cnt
//write_register(8'd15, 8'h7a); // tx err cnt

//read_register(8'd14, tmp_data); // rx err cnt
//read_register(8'd15, tmp_data); // tx err cnt

    repeat (100) @ (posedge clk);
    
    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    // After exiting the reset mode sending bus free
    repeat (11) send_bit(1);


    // Extended frame format
    // Writing TX frame information + identifier + data
    write_register(8'd16, 8'hc5);   // Frame format = 1, Remote transmision request = 1, DLC = 5
    write_register(8'd17, 8'ha6);   // ID[28:21] = a6
    write_register(8'd18, 8'h00);   // ID[20:13] = 00
    write_register(8'd19, 8'h5a);   // ID[12:5]  = 5a
    write_register(8'd20, 8'ha8);   // ID[4:0]   = 15
    // write_register(8'd21, 8'h78); RTR does not send any data
    // write_register(8'd22, 8'h9a);
    // write_register(8'd23, 8'hbc);
    // write_register(8'd24, 8'hde);
    // write_register(8'd25, 8'hf0);
    // write_register(8'd26, 8'h0f);
    // write_register(8'd27, 8'hed);
    // write_register(8'd28, 8'hcb);


    // Enabling IRQ's (extended mode)
    write_register(8'd4, 8'hff);

    // tx_bypassed = 1;    // When this signal is on, tx is not looped back to the rx.
    
    fork
      begin
        tx_request_command;
//        self_reception_request_command;
      end

      begin
        #771;

        repeat (1)
        begin
          send_bit(0);  // SOF
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID a
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID 6
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID 
          send_bit(1);  // RTR
          send_bit(1);  // IDE
          send_bit(0);  // ID 0
          send_bit(0);  // ID 
          send_bit(0);  // ID 
          send_bit(0);  // ID 
          send_bit(0);  // ID 0
          send_bit(1);  // ID stuff
          send_bit(0);  // ID 
          send_bit(1);  // ID 
          send_bit(0);  // ID 
          send_bit(1);  // ID 6
          send_bit(1);  // ID 
          send_bit(0);  // ID 
          send_bit(1);  // ID 
          send_bit(0);  // ID a
          send_bit(1);  // ID 1
          send_bit(0);  // ID 
          send_bit(1);  // ID
          send_bit(0);  // ID 
          send_bit(0);  // ID 5   // Force arbitration lost
          send_bit(1);  // RTR
          send_bit(0);  // r1
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(1);  // CRC 
          send_bit(0);  // CRC 6
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC  
          send_bit(1);  // CRC f
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC  
          send_bit(0);  // CRC 2
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC a
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
#80;
          send_bit(0);  // SOF
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID a
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID 6
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID 
          send_bit(1);  // RTR
          send_bit(1);  // IDE
          send_bit(0);  // ID 0
          send_bit(0);  // ID 
          send_bit(0);  // ID 
          send_bit(0);  // ID 
          send_bit(0);  // ID 0
          send_bit(1);  // ID stuff
          send_bit(0);  // ID 
          send_bit(1);  // ID 
          send_bit(0);  // ID 
          send_bit(1);  // ID 6
          send_bit(1);  // ID 
          send_bit(0);  // ID 
          send_bit(1);  // ID 
          send_bit(0);  // ID a
          send_bit(1);  // ID 1
          send_bit(0);  // ID 
          send_bit(0);  // ID     // Force arbitration lost 
          send_bit(0);  // ID 
          send_bit(1);  // ID 5
          send_bit(1);  // RTR
          send_bit(0);  // r1
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 
          send_bit(0);  // CRC 0
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC stuff 
          send_bit(0);  // CRC  
          send_bit(0);  // CRC 0
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC  
          send_bit(0);  // CRC e
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC c
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER

#80;
          send_bit(0);  // SOF
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID a
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID 6
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID 
          send_bit(1);  // RTR
          send_bit(1);  // IDE
          send_bit(0);  // ID 0
          send_bit(0);  // ID 
          send_bit(0);  // ID 
          send_bit(0);  // ID 
          send_bit(0);  // ID 0
          send_bit(1);  // ID stuff
          send_bit(0);  // ID 
          send_bit(1);  // ID 
          send_bit(0);  // ID 
          send_bit(1);  // ID 6
          send_bit(1);  // ID 
          send_bit(0);  // ID 
          send_bit(1);  // ID 
          send_bit(0);  // ID a
          send_bit(1);  // ID 1
          send_bit(0);  // ID 
          send_bit(1);  // ID 
          send_bit(0);  // ID 
          send_bit(1);  // ID 5
          send_bit(1);  // RTR
          send_bit(0);  // r1
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 4
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC d
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC 3
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC 9
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
        end // repeat


      end
    
    join



    read_receive_buffer;
    release_rx_buffer_command;

    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;

    // Read irq register
    #1 read_register(8'd3, tmp_data);

    // Read error code capture register
    read_register(8'd12, tmp_data);

    // Read error capture code register
//    read_register(8'd12, tmp_data);

read_register(8'd14, tmp_data); // rx err cnt
read_register(8'd15, tmp_data); // tx err cnt

    #4000000;

  end
endtask   //  manual_frame_ext



task bus_off_test;    // Testbench sends a frame
  begin

    write_register(8'd10, 8'he8); // Writing ID[10:3] = 0xe8
    write_register(8'd11, 8'hb7); // Writing ID[2:0] = 0x5, rtr = 1, length = 7
    write_register(8'd12, 8'h00); // data byte 1
    write_register(8'd13, 8'h00); // data byte 2
    write_register(8'd14, 8'h00); // data byte 3
    write_register(8'd15, 8'h00); // data byte 4
    write_register(8'd16, 8'h00); // data byte 5
    write_register(8'd17, 8'h00); // data byte 6
    write_register(8'd18, 8'h00); // data byte 7
    write_register(8'd19, 8'h00); // data byte 8

    fork
      begin
        tx_request_command;
      end

      begin
        #2000;

        repeat (16)
        begin
          send_bit(0);  // SOF
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // RTR
          send_bit(0);  // IDE
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC DELIM
          send_bit(1);  // ACK            ack error
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
        end // repeat

        // Node is error passive now.

        // Read irq register (error interrupt should be cleared now.
        read_register(8'd3, tmp_data);

->igor;

        repeat (34)
        
        begin
          send_bit(0);  // SOF
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // RTR
          send_bit(0);  // IDE
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC DELIM
          send_bit(1);  // ACK            ack error
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // SUSPEND
          send_bit(1);  // SUSPEND
          send_bit(1);  // SUSPEND
          send_bit(1);  // SUSPEND
          send_bit(1);  // SUSPEND
          send_bit(1);  // SUSPEND
          send_bit(1);  // SUSPEND
          send_bit(1);  // SUSPEND
        end // repeat

->igor;

        // Node is bus-off now


        // Read irq register (error interrupt should be cleared now.
        read_register(8'd3, tmp_data);



        #100000;

        // Switch-off reset mode
        write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

        repeat (64 * 11)
        begin
          send_bit(1);
        end // repeat

        // Read irq register (error interrupt should be cleared now.
        read_register(8'd3, tmp_data);

        repeat (64 * 11)
        begin
          send_bit(1);
        end // repeat



        // Read irq register (error interrupt should be cleared now.
        read_register(8'd3, tmp_data);

      end
     


    join



    fork
      begin
        tx_request_command;
      end

      begin
        #1100;

        send_bit(1);    // To spend some time before transmitter is ready.

        repeat (1)
        begin
          send_bit(0);  // SOF
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // RTR
          send_bit(0);  // IDE
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
        end // repeat
      end

    join

    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;

    #4000000;

    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h1, 15'h30bb); // mode, rtr, id, length, crc

    #1000000;

  end
endtask   // bus_off_test



task send_frame_basic;    // CAN IP core sends frames
  begin

    write_register(8'd10, 8'hea); // Writing ID[10:3] = 0xea
    write_register(8'd11, 8'h28); // Writing ID[2:0] = 0x1, rtr = 0, length = 8
    write_register(8'd12, 8'h56); // data byte 1
    write_register(8'd13, 8'h78); // data byte 2
    write_register(8'd14, 8'h9a); // data byte 3
    write_register(8'd15, 8'hbc); // data byte 4
    write_register(8'd16, 8'hde); // data byte 5
    write_register(8'd17, 8'hf0); // data byte 6
    write_register(8'd18, 8'h0f); // data byte 7
    write_register(8'd19, 8'hed); // data byte 8


    // Enable irqs (basic mode)
    write_register(8'd0, 8'h1e);


  
    fork

      begin
        #1100;
        $display("\n\nStart receiving data from CAN bus");
        receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h1, 15'h30bb); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h2, 15'h2da1); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000ee, 3'h1}, 4'h0, 15'h6cea); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h2, 15'h2da1); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000ee, 3'h1}, 4'h2, 15'h7b4a); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000ee, 3'h1}, 4'h1, 15'h00c5); // mode, rtr, id, length, crc
      end

      begin
        tx_request_command;
      end

      begin
        wait (can_testbench.i_can_top.i_can_bsp.go_tx)        // waiting for tx to start
        wait (~can_testbench.i_can_top.i_can_bsp.need_to_tx)  // waiting for tx to finish
        tx_request_command;                                   // start another tx
      end

      begin
        // Transmitting acknowledge (for first packet)
        wait (can_testbench.i_can_top.i_can_bsp.tx_state & can_testbench.i_can_top.i_can_bsp.rx_ack & can_testbench.i_can_top.i_can_bsp.tx_point);
        #1 rx = 0;
        wait (can_testbench.i_can_top.i_can_bsp.rx_ack_lim & can_testbench.i_can_top.i_can_bsp.tx_point);
        #1 rx = 1;

        // Transmitting acknowledge (for second packet)
        wait (can_testbench.i_can_top.i_can_bsp.tx_state & can_testbench.i_can_top.i_can_bsp.rx_ack & can_testbench.i_can_top.i_can_bsp.tx_point);
        #1 rx = 0;
        wait (can_testbench.i_can_top.i_can_bsp.rx_ack_lim & can_testbench.i_can_top.i_can_bsp.tx_point);
        #1 rx = 1;
      end


    join

    read_receive_buffer;
    release_rx_buffer_command;
    release_rx_buffer_command;
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;

    #200000;

    read_receive_buffer;

    // Read irq register
    read_register(8'd3, tmp_data);
    #1000;

  end
endtask   // send_frame_basic



task send_frame_extended;    // CAN IP core sends basic or extended frames in extended mode
  begin

    // Switch-on reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, (`CAN_MODE_RESET)});
    
    // Set Clock Divider register
    extended_mode = 1'b1;
    write_register(8'd31, {extended_mode, 7'h0});    // Setting the extended mode
    write_register2(8'd31, {extended_mode, 7'h0});    // Setting the extended mode
 
    // Set Acceptance Code and Acceptance Mask registers
    write_register(8'd16, 8'ha6); // acceptance code 0
    write_register(8'd17, 8'hb0); // acceptance code 1
    write_register(8'd18, 8'h12); // acceptance code 2
    write_register(8'd19, 8'h30); // acceptance code 3
    write_register(8'd20, 8'h00); // acceptance mask 0
    write_register(8'd21, 8'h00); // acceptance mask 1
    write_register(8'd22, 8'h00); // acceptance mask 2
    write_register(8'd23, 8'h00); // acceptance mask 3

    write_register2(8'd16, 8'ha6); // acceptance code 0
    write_register2(8'd17, 8'hb0); // acceptance code 1
    write_register2(8'd18, 8'h12); // acceptance code 2
    write_register2(8'd19, 8'h30); // acceptance code 3
    write_register2(8'd20, 8'h00); // acceptance mask 0
    write_register2(8'd21, 8'h00); // acceptance mask 1
    write_register2(8'd22, 8'h00); // acceptance mask 2
    write_register2(8'd23, 8'h00); // acceptance mask 3

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    // After exiting the reset mode sending bus free
    repeat (11) send_bit(1);


/*  Basic frame format
    // Writing TX frame information + identifier + data
    write_register(8'd16, 8'h45);   // Frame format = 0, Remote transmision request = 1, DLC = 5
    write_register(8'd17, 8'ha6);   // ID[28:21] = a6
    write_register(8'd18, 8'ha0);   // ID[20:18] = 5
    // write_register(8'd19, 8'h78); RTR does not send any data
    // write_register(8'd20, 8'h9a);
    // write_register(8'd21, 8'hbc);
    // write_register(8'd22, 8'hde);
    // write_register(8'd23, 8'hf0);
    // write_register(8'd24, 8'h0f);
    // write_register(8'd25, 8'hed);
    // write_register(8'd26, 8'hcb);
    // write_register(8'd27, 8'ha9);
    // write_register(8'd28, 8'h87);
*/

    // Extended frame format
    // Writing TX frame information + identifier + data
    write_register(8'd16, 8'hc5);   // Frame format = 1, Remote transmision request = 1, DLC = 5
    write_register(8'd17, 8'ha6);   // ID[28:21] = a6
    write_register(8'd18, 8'h00);   // ID[20:13] = 00
    write_register(8'd19, 8'h5a);   // ID[12:5]  = 5a
    write_register(8'd20, 8'ha8);   // ID[4:0]   = 15
    write_register2(8'd16, 8'hc5);   // Frame format = 1, Remote transmision request = 1, DLC = 5
    write_register2(8'd17, 8'ha6);   // ID[28:21] = a6
    write_register2(8'd18, 8'h00);   // ID[20:13] = 00
    write_register2(8'd19, 8'h5a);   // ID[12:5]  = 5a
    write_register2(8'd20, 8'ha8);   // ID[4:0]   = 15
    // write_register(8'd21, 8'h78); RTR does not send any data
    // write_register(8'd22, 8'h9a);
    // write_register(8'd23, 8'hbc);
    // write_register(8'd24, 8'hde);
    // write_register(8'd25, 8'hf0);
    // write_register(8'd26, 8'h0f);
    // write_register(8'd27, 8'hed);
    // write_register(8'd28, 8'hcb);


    // Enabling IRQ's (extended mode)
    write_register(8'd4, 8'hff);
    write_register2(8'd4, 8'hff);


    fork
      begin
        #1251;
        $display("\n\nStart receiving data from CAN bus");
        /* Standard frame format
        receive_frame(0, 0, {26'h00000a0, 3'h1}, 4'h1, 15'h2d9c); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000a0, 3'h1}, 4'h2, 15'h46b4); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000af, 3'h1}, 4'h0, 15'h42cd); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000af, 3'h1}, 4'h1, 15'h555f); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000af, 3'h1}, 4'h2, 15'h6742); // mode, rtr, id, length, crc
        */

        // Extended frame format
        receive_frame(1, 0, {8'ha6, 8'h00, 8'h5a, 5'h14}, 4'h1, 15'h1528); // mode, rtr, id, length, crc
        receive_frame(1, 0, {8'ha6, 8'h00, 8'h5a, 5'h15}, 4'h2, 15'h3d2d); // mode, rtr, id, length, crc
        receive_frame(1, 0, {8'ha6, 8'h00, 8'h5a, 5'h15}, 4'h0, 15'h23aa); // mode, rtr, id, length, crc
        receive_frame(1, 0, {8'ha6, 8'h00, 8'h5a, 5'h15}, 4'h1, 15'h2d22); // mode, rtr, id, length, crc
        receive_frame(1, 0, {8'ha6, 8'h00, 8'h5a, 5'h15}, 4'h2, 15'h3d2d); // mode, rtr, id, length, crc

      end

      begin
        tx_request_command;
      end

      begin
        // Transmitting acknowledge
        wait (can_testbench.i_can_top.i_can_bsp.tx_state & can_testbench.i_can_top.i_can_bsp.rx_ack & can_testbench.i_can_top.i_can_bsp.tx_point);
        #1 rx = 0;
        wait (can_testbench.i_can_top.i_can_bsp.rx_ack_lim & can_testbench.i_can_top.i_can_bsp.tx_point);
        #1 rx = 1;
      end

      begin   // Reading irq and arbitration lost capture register

        repeat(1)
          begin
            while (~(can_testbench.i_can_top.i_can_bsp.rx_crc_lim & can_testbench.i_can_top.i_can_bsp.sample_point))
              begin
                @ (posedge clk);
              end

            // Read irq register
            #1 read_register(8'd3, tmp_data);
    
            // Read arbitration lost capture register
            read_register(8'd11, tmp_data);
          end


        repeat(1)
          begin
            while (~(can_testbench.i_can_top.i_can_bsp.rx_crc_lim & can_testbench.i_can_top.i_can_bsp.sample_point))
              begin
                @ (posedge clk);
              end

            // Read irq register
            #1 read_register(8'd3, tmp_data);
          end

        repeat(1)
          begin
            while (~(can_testbench.i_can_top.i_can_bsp.rx_crc_lim & can_testbench.i_can_top.i_can_bsp.sample_point))
              begin
                @ (posedge clk);
              end

            // Read arbitration lost capture register
            read_register(8'd11, tmp_data);
          end

      end

      begin
        # 344000;

        // Switch-on reset mode
        $display("expect: SW reset ON\n");
        write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});

        #40000;
        // Switch-off reset mode
        $display("expect: SW reset OFF\n");
        write_register(8'd0, {7'h0, (~`CAN_MODE_RESET)});
      end

    join

    read_receive_buffer;
    release_rx_buffer_command;
    release_rx_buffer_command;
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;

    #200000;

    read_receive_buffer;

    // Read irq register
    read_register(8'd3, tmp_data);
    #1000;

  end
endtask   // send_frame_extended



task self_reception_request;    // CAN IP core sends sets self reception mode and transmits a msg. This test runs in EXTENDED mode
  begin

    // Switch-on reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});
    
    // Set Clock Divider register
    extended_mode = 1'b1;
    write_register(8'd31, {extended_mode, 7'h0});    // Setting the extended mode
 
    // Set Acceptance Code and Acceptance Mask registers
    write_register(8'd16, 8'ha6); // acceptance code 0
    write_register(8'd17, 8'hb0); // acceptance code 1
    write_register(8'd18, 8'h12); // acceptance code 2
    write_register(8'd19, 8'h30); // acceptance code 3
    write_register(8'd20, 8'h00); // acceptance mask 0
    write_register(8'd21, 8'h00); // acceptance mask 1
    write_register(8'd22, 8'h00); // acceptance mask 2
    write_register(8'd23, 8'h00); // acceptance mask 3

    // Setting the "self test mode"
    write_register(8'd0, 8'h4);

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    // After exiting the reset mode sending bus free
    repeat (11) send_bit(1);


    // Writing TX frame information + identifier + data
    write_register(8'd16, 8'h45);   // Frame format = 0, Remote transmision request = 1, DLC = 5
    write_register(8'd17, 8'ha6);   // ID[28:21] = a6
    write_register(8'd18, 8'ha0);   // ID[20:18] = 5
    // write_register(8'd19, 8'h78); RTR does not send any data
    // write_register(8'd20, 8'h9a);
    // write_register(8'd21, 8'hbc);
    // write_register(8'd22, 8'hde);
    // write_register(8'd23, 8'hf0);
    // write_register(8'd24, 8'h0f);
    // write_register(8'd25, 8'hed);
    // write_register(8'd26, 8'hcb);
    // write_register(8'd27, 8'ha9);
    // write_register(8'd28, 8'h87);


    // Enabling IRQ's (extended mode)
    write_register(8'd4, 8'hff);

    self_reception_request_command;

    #400000;

    read_receive_buffer;
    release_rx_buffer_command;
    release_rx_buffer_command;
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;


    read_receive_buffer;

    // Read irq register
    read_register(8'd3, tmp_data);
    #1000;

  end
endtask   // self_reception_request



task test_empty_fifo;
  begin

    // Enable irqs (basic mode)
    write_register(8'd0, 8'h1e);

    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h3, 15'h56a9); // mode, rtr, id, length, crc
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h7, 15'h391d); // mode, rtr, id, length, crc

    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h8, 15'h70e0); // mode, rtr, id, length, crc

    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;
  end
endtask



task test_empty_fifo_ext;
  begin
    receive_frame(1, 0, 29'h14d60246, 4'h3, 15'h5262); // mode, rtr, id, length, crc
    receive_frame(1, 0, 29'h14d60246, 4'h7, 15'h1730); // mode, rtr, id, length, crc
    
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    receive_frame(1, 0, 29'h14d60246, 4'h8, 15'h2f7a); // mode, rtr, id, length, crc

    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;
  end
endtask



task test_full_fifo;
  begin

    // Enable irqs (basic mode)
    // write_register(8'd0, 8'h1e);
    write_register(8'd0, 8'h10); // enable only overrun irq

    $display("\n\n");

    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h0, 15'h2372); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h1, 15'h30bb); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h2, 15'h2da1); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h3, 15'h56a9); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h4, 15'h3124); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h5, 15'h6944); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h6, 15'h5182); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h7, 15'h391d); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h8, 15'h70e0); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h8, 15'h70e0); // mode, rtr, id, length, crc
    fifo_info;
    $display("FIFO should be full now");
    $display("2 packets won't be received because of the overrun. IRQ should be set");

    // Following one is accepted with overrun
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h8, 15'h70e0); // mode, rtr, id, length, crc
    fifo_info;

    // Following one is accepted with overrun
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h8, 15'h70e0); // mode, rtr, id, length, crc
    fifo_info;

    $display("Now we'll release 1 packet.");
    release_rx_buffer_command;
    fifo_info;

    // Space just enough for the following frame.
    $display("Getting 1 small packet (just big enough). Fifo is full again");
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h0, 15'h2372); // mode, rtr, id, length, crc
    fifo_info;

    // Following accepted with overrun
    $display("1 packets won't be received because of the overrun. IRQ should be set");
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h8, 15'h70e0); // mode, rtr, id, length, crc
    fifo_info;

    // Following accepted with overrun
    $display("1 packets won't be received because of the overrun. IRQ should be set");
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h8, 15'h70e0); // mode, rtr, id, length, crc
    fifo_info;
//    read_overrun_info(0, 15);

    $display("Releasing 3 packets.");
    release_rx_buffer_command;
    release_rx_buffer_command;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h8, 15'h70e0); // mode, rtr, id, length, crc
    fifo_info;
//    read_overrun_info(0, 15);
    $display("\n\n");

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    clear_data_overrun_command;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    clear_data_overrun_command;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    // Read irq register
    read_register(8'd3, tmp_data);

    // Read irq register
    read_register(8'd3, tmp_data);
    #1000;

  end
endtask



task test_full_fifo_ext;
  begin
    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    receive_frame(1, 0, 29'h14d60246, 4'h0, 15'h6f54); // mode, rtr, id, length, crc
    read_receive_buffer;
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h1, 15'h6d38); // mode, rtr, id, length, crc
    read_receive_buffer;
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h2, 15'h053e); // mode, rtr, id, length, crc
    fifo_info;
    read_receive_buffer;
    receive_frame(1, 0, 29'h14d60246, 4'h3, 15'h5262); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h4, 15'h4bba); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h5, 15'h4d7d); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h6, 15'h6f40); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h7, 15'h1730); // mode, rtr, id, length, crc
    fifo_info;
//    read_overrun_info(0, 10);

    release_rx_buffer_command;
    release_rx_buffer_command;
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h8, 15'h2f7a); // mode, rtr, id, length, crc
    fifo_info;
//    read_overrun_info(0, 15);
    $display("\n\n");

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

  end
endtask


task test_reset_mode;
  begin
    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;
    $display("expect: Until now no data was received\n");

    receive_frame(1, 0, 29'h14d60246, 4'h0, 15'h6f54); // mode, rtr, id, length, crc
    receive_frame(1, 0, 29'h14d60246, 4'h1, 15'h6d38); // mode, rtr, id, length, crc
    receive_frame(1, 0, 29'h14d60246, 4'h2, 15'h053e); // mode, rtr, id, length, crc

    fifo_info;
    read_receive_buffer;
    $display("expect: 3 packets should be received (totally 18 bytes)\n");

    release_rx_buffer_command;
    fifo_info;
    read_receive_buffer;
    $display("expect: 2 packets should be received (totally 13 bytes)\n");


    $display("expect: SW reset performed\n");

    // Switch-on reset mode
    write_register(8'd0, {7'h0, `CAN_MODE_RESET});

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    fifo_info;
    read_receive_buffer;
    $display("expect: The above read was after the SW reset.\n");

    receive_frame(1, 0, 29'h14d60246, 4'h3, 15'h5262); // mode, rtr, id, length, crc
    fifo_info;
    read_receive_buffer;
    $display("expect: 1 packets should be received (totally 8 bytes). See above.\n");

    // Switch-on reset mode
    $display("expect: SW reset ON\n");
    write_register(8'd0, {7'h0, `CAN_MODE_RESET});

    receive_frame(1, 0, 29'h14d60246, 4'h5, 15'h4d7d); // mode, rtr, id, length, crc

    fifo_info;
    read_receive_buffer;
    $display("expect: 0 packets should be received because we are in reset. (totally 0 bytes). See above.\n");

/*
    fork
      begin
      receive_frame(1, 0, 29'h14d60246, 4'h4, 15'h4bba); // mode, rtr, id, length, crc
      end
      begin
        // Switch-on reset mode
        write_register(8'd0, {7'h0, `CAN_MODE_RESET});

        // Switch-off reset mode
        write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});


      end
    
    join
*/




    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h5, 15'h4d7d); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h6, 15'h6f40); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h7, 15'h1730); // mode, rtr, id, length, crc
    fifo_info;
//    read_overrun_info(0, 10);

    release_rx_buffer_command;
    release_rx_buffer_command;
    fifo_info;



    // Switch-off reset mode
    $display("expect: SW reset OFF\n");
    write_register(8'd0, {7'h0, (~`CAN_MODE_RESET)});

    receive_frame(1, 0, 29'h14d60246, 4'h8, 15'h2f7a); // mode, rtr, id, length, crc
    fifo_info;
    read_receive_buffer;
    $display("expect: 1 packets should be received (totally 13 bytes). See above.\n");

    release_rx_buffer_command;
    fifo_info;
    read_receive_buffer;
    $display("expect: 0 packets should be received (totally 0 bytes). See above.\n");
    $display("\n\n");


    fork 
      receive_frame(1, 0, 29'h14d60246, 4'h5, 15'h4d7d); // mode, rtr, id, length, crc

      begin
        #8000;
        // Switch-off reset mode
        $display("expect: SW reset ON while receiving a packet\n");
        write_register(8'd0, {7'h0, `CAN_MODE_RESET});
      end
    join


    read_receive_buffer;
    fifo_info;
    $display("expect: 0 packets should be received (totally 0 bytes) because CAN was in reset. See above.\n");

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

  end
endtask   // test_reset_mode


/*
task initialize_fifo;
  integer i;
  begin
    for (i=0; i<32; i=i+1)
      begin
        can_testbench.i_can_top.i_can_bsp.i_can_fifo.length_info[i] = 0;
        can_testbench.i_can_top.i_can_bsp.i_can_fifo.overrun_info[i] = 0;
      end

    for (i=0; i<64; i=i+1)
      begin
        can_testbench.i_can_top.i_can_bsp.i_can_fifo.fifo[i] = 0;
      end

    $display("(%0t) Fifo initialized", $time);
  end
endtask
*/
/*
task read_overrun_info;
  input [4:0] start_addr;
  input [4:0] end_addr;
  integer i;
  begin
    for (i=start_addr; i<=end_addr; i=i+1)
      begin
        $display("len[0x%0x]=0x%0x", i, can_testbench.i_can_top.i_can_bsp.i_can_fifo.length_info[i]);
        $display("overrun[0x%0x]=0x%0x\n", i, can_testbench.i_can_top.i_can_bsp.i_can_fifo.overrun_info[i]);
      end
  end
endtask
*/

task fifo_info;   // Displaying how many packets and how many bytes are in fifo. Not working when wr_info_pointer is smaller than rd_info_pointer.
  begin
      $display("(%0t) Currently %0d bytes in fifo (%0d packets)", $time, can_testbench.i_can_top.i_can_bsp.i_can_fifo.fifo_cnt, 
      (can_testbench.i_can_top.i_can_bsp.i_can_fifo.wr_info_pointer - can_testbench.i_can_top.i_can_bsp.i_can_fifo.rd_info_pointer));
end
endtask


task read_register;
  input [7:0] reg_addr;
  output [7:0] data;

  `ifdef CAN_WISHBONE_IF
    begin
      wait (wb_free);
      wb_free = 0;
      @ (posedge wb_clk_i);
      #1; 
      cs_can = 1;
      wb_adr_i = reg_addr;
      wb_cyc_i = 1;
      wb_stb_i = 1;
      wb_we_i = 0;
      wait (wb_ack_o);
      $display("(%0t) Reading register [%0d] = 0x%0x", $time, wb_adr_i, wb_dat_o);
      data = wb_dat_o;
      @ (posedge wb_clk_i);
      #1; 
      wb_adr_i = 'hz;
      wb_cyc_i = 0;
      wb_stb_i = 0;
      wb_we_i = 'hz;
      cs_can = 0;
      wb_free = 1;
    end
  `else
    begin
      wait (port_free);
      port_free = 0;
      @ (posedge clk);
      #1;
      cs_can = 1;
      @ (negedge clk);
      #1;
      ale_i = 1;
      port_0_en = 1;
      port_0_o = reg_addr;
      @ (negedge clk);
      #1;
      ale_i = 0;
      #90;            // 73 - 103 ns
      port_0_en = 0;
      rd_i = 1;
      #158;
      $display("(%0t) Reading register [%0d] = 0x%0x", $time, can_testbench.i_can_top.addr_latched, port_0_i);
      data = port_0_i;
      #1;
      rd_i = 0;
      cs_can = 0;
      port_free = 1;
    end
  `endif
endtask


task write_register;
  input [7:0] reg_addr;
  input [7:0] reg_data;

  `ifdef CAN_WISHBONE_IF
    begin
      wait (wb_free);
      wb_free = 0;
      @ (posedge wb_clk_i);
      #1; 
      cs_can = 1;
      wb_adr_i = reg_addr;
      wb_dat_i = reg_data;
      wb_cyc_i = 1;
      wb_stb_i = 1;
      wb_we_i = 1;
      wait (wb_ack_o);
      @ (posedge wb_clk_i);
      #1; 
      wb_adr_i = 'hz;
      wb_dat_i = 'hz;
      wb_cyc_i = 0;
      wb_stb_i = 0;
      wb_we_i = 'hz;
      cs_can = 0;
      wb_free = 1;
    end
  `else
    begin
      $display("(%0t) Writing register [%0d] with 0x%0x", $time, reg_addr, reg_data);
      wait (port_free);
      port_free = 0;
      @ (posedge clk);
      #1;
      cs_can = 1;
      @ (negedge clk);
      #1;
      ale_i = 1;
      port_0_en = 1;
      port_0_o = reg_addr;
      @ (negedge clk);
      #1;
      ale_i = 0;
      #90;            // 73 - 103 ns
      port_0_o = reg_data;
      wr_i = 1;
      #158;
      wr_i = 0;
      port_0_en = 0;
      cs_can = 0;
      port_free = 1;
    end
  `endif
endtask


task read_register2;
  input [7:0] reg_addr;
  output [7:0] data;

  `ifdef CAN_WISHBONE_IF
    begin
      wait (wb_free);
      wb_free = 0;
      @ (posedge wb_clk_i);
      #1; 
      cs_can = 1;
      wb_adr_i = reg_addr;
      wb_cyc_i = 1;
      wb_stb_i = 1;
      wb_we_i = 0;
      wait (wb_ack_o);
      $display("(%0t) Reading register [%0d] = 0x%0x", $time, wb_adr_i, wb_dat_o);
      data = wb_dat_o;
      @ (posedge wb_clk_i);
      #1; 
      wb_adr_i = 'hz;
      wb_cyc_i = 0;
      wb_stb_i = 0;
      wb_we_i = 'hz;
      cs_can = 0;
      wb_free = 1;
    end
  `else
    begin
      wait (port_free);
      port_free = 0;
      @ (posedge clk);
      #1;
      cs_can2 = 1;
      @ (negedge clk);
      #1;
      ale2_i = 1;
      port_0_en = 1;
      port_0_o = reg_addr;
      @ (negedge clk);
      #1;
      ale2_i = 0;
      #90;            // 73 - 103 ns
      port_0_en = 0;
      rd2_i = 1;
      #158;
      $display("(%0t) Reading register [%0d] = 0x%0x", $time, can_testbench.i_can_top.addr_latched, port_0_i);
      data = port_0_i;
      #1;
      rd2_i = 0;
      cs_can2 = 0;
      port_free = 1;
    end
  `endif
endtask


task write_register2;
  input [7:0] reg_addr;
  input [7:0] reg_data;

  `ifdef CAN_WISHBONE_IF
    begin
      wait (wb_free);
      wb_free = 0;
      @ (posedge wb_clk_i);
      #1; 
      cs_can = 1;
      wb_adr_i = reg_addr;
      wb_dat_i = reg_data;
      wb_cyc_i = 1;
      wb_stb_i = 1;
      wb_we_i = 1;
      wait (wb_ack_o);
      @ (posedge wb_clk_i);
      #1; 
      wb_adr_i = 'hz;
      wb_dat_i = 'hz;
      wb_cyc_i = 0;
      wb_stb_i = 0;
      wb_we_i = 'hz;
      cs_can = 0;
      wb_free = 1;
    end
  `else
    begin
      wait (port_free);
      port_free = 0;
      @ (posedge clk);
      #1;
      cs_can2 = 1;
      @ (negedge clk);
      #1;
      ale2_i = 1;
      port_0_en = 1;
      port_0_o = reg_addr;
      @ (negedge clk);
      #1;
      ale2_i = 0;
      #90;            // 73 - 103 ns
      port_0_o = reg_data;
      wr2_i = 1;
      #158;
      wr2_i = 0;
      port_0_en = 0;
      cs_can2 = 0;
      port_free = 1;
    end
  `endif
endtask


task read_receive_buffer;
  integer i;
  begin
    $display("\n\n(%0t)", $time);
    if(extended_mode)   // Extended mode
      begin
        for (i=8'd16; i<=8'd28; i=i+1)
          read_register(i, tmp_data);
        //if (can_testbench.i_can_top.i_can_bsp.i_can_fifo.overrun)
        //  $display("\nWARNING: Above packet was received with overrun.");
      end
    else
      begin
        for (i=8'd20; i<=8'd29; i=i+1)
          read_register(i, tmp_data);
        //if (can_testbench.i_can_top.i_can_bsp.i_can_fifo.overrun)
        //  $display("\nWARNING: Above packet was received with overrun.");
      end
  end
endtask


task release_rx_buffer_command;
  begin
    write_register(8'd1, 8'h4);
    $display("(%0t) Rx buffer released.", $time);
  end
endtask


task tx_request_command;
  begin
    write_register(8'd1, 8'h1);
    $display("(%0t) Tx requested.", $time);
  end
endtask


task tx_abort_command;
  begin
    write_register(8'd1, 8'h2);
    $display("(%0t) Tx abort requested.", $time);
  end
endtask


task clear_data_overrun_command;
  begin
    write_register(8'd1, 8'h8);
    $display("(%0t) Data overrun cleared.", $time);
  end
endtask


task self_reception_request_command;
  begin
    write_register(8'd1, 8'h10);
    $display("(%0t) Self reception requested.", $time);
  end
endtask


task test_synchronization;
  begin
    // Hard synchronization
    #1 rx=0;
    repeat (2*BRP) @ (posedge clk);
    repeat (8*BRP) @ (posedge clk);
    #1 rx=1;
    repeat (10*BRP) @ (posedge clk);
  
    // Resynchronization on time
    #1 rx=0;
    repeat (10*BRP) @ (posedge clk);
    #1 rx=1;
    repeat (10*BRP) @ (posedge clk);
  
    // Resynchronization late
    repeat (BRP) @ (posedge clk);
    repeat (BRP) @ (posedge clk);
    #1 rx=0;
    repeat (10*BRP) @ (posedge clk);
    #1 rx=1;
  
    // Resynchronization early
    repeat (8*BRP) @ (posedge clk);   // two frames too early
    #1 rx=0;
    repeat (10*BRP) @ (posedge clk);
    #1 rx=1;
    // Resynchronization early
    repeat (11*BRP) @ (posedge clk);   // one frames too late
    #1 rx=0;
    repeat (10*BRP) @ (posedge clk);
    #1 rx=1;

    repeat (10*BRP) @ (posedge clk);
    #1 rx=0;
    repeat (10*BRP) @ (posedge clk);
  end
endtask


task send_bit;
  input bit;
  integer cnt;
  begin
    #1 rx=bit;
    repeat ((`CAN_TIMING1_TSEG1 + `CAN_TIMING1_TSEG2 + 3)*BRP) @ (posedge clk);
  end
endtask


task receive_frame;           // CAN IP core receives frames
  input mode;
  input remote_trans_req;
  input [28:0] id;
  input  [3:0] length;
  input [14:0] crc;

  reg [117:0] data;
  reg         previous_bit;
  reg         stuff;
  reg         tmp;
  reg         arbitration_lost;
  integer     pointer;
  integer     cnt;
  integer     total_bits;
  integer     stuff_cnt;

  begin

    stuff_cnt = 1;
    stuff = 0;

    if(mode)          // Extended format
      data = {id[28:18], 1'b1, 1'b1, id[17:0], remote_trans_req, 2'h0, length};
    else              // Standard format
      data = {id[10:0], remote_trans_req, 1'b0, 1'b0, length};

    if (~remote_trans_req)
      begin
        if(length)    // Send data if length is > 0
          begin
            for (cnt=1; cnt<=(2*length); cnt=cnt+1)  // data   (we are sending nibbles)
              data = {data[113:0], cnt[3:0]};
          end
      end

    // Adding CRC
    data = {data[104:0], crc[14:0]};


    // Calculating pointer that points to the bit that will be send
    if (remote_trans_req)
      begin
        if(mode)          // Extended format
          pointer = 52;
        else              // Standard format
          pointer = 32;
      end
    else
      begin
        if(mode)          // Extended format
          pointer = 52 + 8 * length;
        else              // Standard format
          pointer = 32 + 8 * length;
      end

    // This is how many bits we need to shift
    total_bits = pointer;

    // Waiting until previous msg is finished before sending another one
    if (arbitration_lost)           //  Arbitration lost. Another node is transmitting. We have to wait until it is finished.
      wait ( (~can_testbench.i_can_top.i_can_bsp.error_frame) & 
             (~can_testbench.i_can_top.i_can_bsp.rx_inter   ) & 
             (~can_testbench.i_can_top.i_can_bsp.tx_state   )
           );
    else                            // We were transmitter of the previous frame. No need to wait for another node to finish transmission.
      wait ( (~can_testbench.i_can_top.i_can_bsp.error_frame) & 
             (~can_testbench.i_can_top.i_can_bsp.rx_inter   )
           );
    arbitration_lost = 0;
    
    send_bit(0);                        // SOF
    previous_bit = 0;

    fork 

    begin
      for (cnt=0; cnt<=total_bits; cnt=cnt+1)
        begin
          if (stuff_cnt == 5)
            begin
              stuff_cnt = 1;
              total_bits = total_bits + 1;
              stuff = 1;
              tmp = ~data[pointer+1];
              send_bit(~data[pointer+1]);
              previous_bit = ~data[pointer+1];
            end
          else
            begin
              if (data[pointer] == previous_bit)
                stuff_cnt <= stuff_cnt + 1;
              else
                stuff_cnt <= 1;
              
              stuff = 0;
              tmp = data[pointer];
              send_bit(data[pointer]);
              previous_bit = data[pointer];
              pointer = pointer - 1;
            end
          if (arbitration_lost)
            cnt=total_bits+1;         // Exit the for loop
        end

        // Nothing send after the data (just recessive bit)
        repeat (13) send_bit(1);         // CRC delimiter + ack + ack delimiter + EOF + intermission= 1 + 1 + 1 + 7 + 3
    end

    begin
      while (mode ? (cnt<32) : (cnt<12))
        begin
          #1 wait (can_testbench.i_can_top.sample_point);
          if (mode)
            begin
              if (cnt<32 & tmp & (~rx_and_tx))
                begin
                  arbitration_lost = 1;
                  rx = 1;       // Only recessive is send from now on.
                end
            end
          else
            begin
              if (cnt<12 & tmp & (~rx_and_tx))
                begin
                  arbitration_lost = 1;
                  rx = 1;       // Only recessive is send from now on.
                end
            end
        end
    end

    join

  end
endtask



// State machine monitor (btl)
always @ (posedge clk)
begin
  if(can_testbench.i_can_top.i_can_btl.go_sync & can_testbench.i_can_top.i_can_btl.go_seg1 | can_testbench.i_can_top.i_can_btl.go_sync & can_testbench.i_can_top.i_can_btl.go_seg2 | 
     can_testbench.i_can_top.i_can_btl.go_seg1 & can_testbench.i_can_top.i_can_btl.go_seg2)
    begin
      $display("(%0t) ERROR multiple go_sync, go_seg1 or go_seg2 occurance\n\n", $time);
      #1000;
      $stop;
    end

  if(can_testbench.i_can_top.i_can_btl.sync & can_testbench.i_can_top.i_can_btl.seg1 | can_testbench.i_can_top.i_can_btl.sync & can_testbench.i_can_top.i_can_btl.seg2 | 
     can_testbench.i_can_top.i_can_btl.seg1 & can_testbench.i_can_top.i_can_btl.seg2)
    begin
      $display("(%0t) ERROR multiple sync, seg1 or seg2 occurance\n\n", $time);
      #1000;
      $stop;
    end
end

/* stuff_error monitor (bsp)
always @ (posedge clk)
begin
  if(can_testbench.i_can_top.i_can_bsp.stuff_error)
    begin
      $display("\n\n(%0t) Stuff error occured in can_bsp.v file\n\n", $time);
      $stop;                                      After everything is finished add another condition (something like & (~idle)) and enable stop
    end
end
*/

//
// CRC monitor (used until proper CRC generation is used in testbench
always @ (posedge clk)
begin
  if (can_testbench.i_can_top.i_can_bsp.rx_ack       &
      can_testbench.i_can_top.i_can_bsp.sample_point & 
      can_testbench.i_can_top.i_can_bsp.crc_err
     )
    $display("*E (%0t) ERROR: CRC error (Calculated crc = 0x%0x, crc_in = 0x%0x)", $time, can_testbench.i_can_top.i_can_bsp.calculated_crc, can_testbench.i_can_top.i_can_bsp.crc_in);
end





/*
// overrun monitor
always @ (posedge clk)
begin
  if (can_testbench.i_can_top.i_can_bsp.i_can_fifo.wr & can_testbench.i_can_top.i_can_bsp.i_can_fifo.fifo_full)
    $display("(%0t)overrun", $time);
end
*/


// form error monitor
always @ (posedge clk)
begin
  if (can_testbench.i_can_top.i_can_bsp.form_err)
    $display("*E (%0t) ERROR: form_error", $time);
end



// acknowledge error monitor
always @ (posedge clk)
begin
  if (can_testbench.i_can_top.i_can_bsp.ack_err)
    $display("*E (%0t) ERROR: acknowledge_error", $time);
end

/*
// bit error monitor
always @ (posedge clk)
begin
  if (can_testbench.i_can_top.i_can_bsp.bit_err)
    $display("*E (%0t) ERROR: bit_error", $time);
end
*/

endmodule

