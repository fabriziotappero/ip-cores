//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_host_testbench.v                                        ////
////                                                              ////
////  Description                                                 ////
////  Testbench to verify core correctness                        ////
////                                                              ////
////  Author:                                                     ////
////      - Piotr Foltyn, piotr.foltyn@gmail.com                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2011 Author                                    ////
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

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "ps2_host.v"

`define SYS_PERIOD 1
`define PS2_PERIOD (`SYS_PERIOD*4)

module ps2_host_testbench;

reg sys_clk;
reg sys_rst;

reg ps2_clk_r;
reg ps2_data_r;
tri1 ps2_clk  = (ps2_clk_r)  ? 1'bz : 1'b0;
tri1 ps2_data = (ps2_data_r) ? 1'bz : 1'b0;

reg [7:0] tx_data;
reg send_req;
wire busy;

wire [7:0] rx_data;
wire ready;
wire error;

// System clock
always #`SYS_PERIOD sys_clk = ~sys_clk;

// System reset
initial begin
  sys_clk = 0;
  ps2_clk_r = 1;
  ps2_data_r = 1;
  send_req = 0;
  
  sys_rst = 1;
  sys_rst = #(`SYS_PERIOD*2) 0;
end

// Receiver test
task receiver_test;
  input start_bit;
  input [7:0] bits;
  input parity_bit;
  input stop_bit;
  input expect_error;
  reg [10:0] frame;
  integer bit_cnt;
begin
  frame = {start_bit,bits[0],bits[1],bits[2],bits[3],
                     bits[4],bits[5],bits[6],bits[7],parity_bit,stop_bit};
  for (bit_cnt = 0; bit_cnt < 11; bit_cnt = bit_cnt + 1) begin
    ps2_data_r = frame[10 - bit_cnt];
    ps2_clk_r = #`PS2_PERIOD 0;
    ps2_clk_r = #`PS2_PERIOD 1;
  end
  wait (ready);
  if ((bits != rx_data) | (error != expect_error)) begin
    $display("Failed: Frame:0x%x Rx:0x%x Err:%b", frame, rx_data, error);
  end
  ps2_data_r = 1;
end endtask

// Transmitter test
task transmitter_test;
  input [7:0] bits;
  integer bit_cnt;
  reg [10:0] frame;
begin
  frame = 0;
  tx_data = bits;
  send_req = #(`SYS_PERIOD*2) 1;
  send_req = #(`SYS_PERIOD*2) 0;
  wait (~ps2_data);
  for (bit_cnt = 0; bit_cnt < 11; bit_cnt = bit_cnt + 1) begin
    ps2_clk_r = #`PS2_PERIOD 0;
    frame = {frame[9:0], ps2_data};
    ps2_clk_r = #`PS2_PERIOD 1;
  end
  wait (~busy);
  if (({bits[0],bits[1],bits[2],bits[3],bits[4],bits[5],bits[6],bits[7]} != frame[9:2]) |
      frame[10] | (~^frame[9:2] != frame[1]) | ~frame[0]) begin
    $display("Failed: Frame:0x%x Tx:0x%x", frame, bits);
  end
end endtask

// Test runner
integer byte;
always @(negedge sys_rst) begin
  for (byte = 0; byte < 256; byte = byte + 1) begin
    // Transmitter test
    transmitter_test(byte);
    
    // Correct case - data ok and error low
    receiver_test(0, byte, ~^byte, 1, 0);
    // Invalid start bit case - data ok and error high
    receiver_test(1, byte, ~^byte, 1, 1);
    // Invalid parity bit case - data ok and error high
    receiver_test(0, byte, ^byte, 1, 1);
    // Invalid stop bit case - data ok and error high
    receiver_test(0, byte, ~^byte, 0, 1);
  end
  #`PS2_PERIOD $finish();
end

// Dump data for GTKWave
initial begin
  $dumpfile("ps2_host_testbench.lxt");
  $dumpvars(0, ps2_host_testbench);
end

// Device Under Test
ps2_host ps2_host(
  .sys_clk(sys_clk),
  .sys_rst(sys_rst),
  .ps2_clk(ps2_clk),
  .ps2_data(ps2_data),

  .tx_data(tx_data),
  .send_req(send_req),
  .busy(busy),

  .rx_data(rx_data),
  .ready(ready),
  .error(error)
);

endmodule
