//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 top level test bench                                   ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   top level test bench.                                      ////
////                                                              ////
////  To Do:                                                      ////
////   nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Teran, simont@opencores.org                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
// Revision 1.15  2003/06/05 17:14:27  simont
// Change test monitor from ports to external data memory.
//
// Revision 1.14  2003/06/05 12:54:38  simont
// remove dumpvars.
//
// Revision 1.13  2003/06/05 11:13:39  simont
// add FREQ paremeter.
//
// Revision 1.12  2003/04/16 09:55:56  simont
// add support for external rom from xilinx ramb4
//
// Revision 1.11  2003/04/10 12:45:06  simont
// defines for pherypherals added
//
// Revision 1.10  2003/04/03 19:20:55  simont
// Remove instruction cache and wb_interface
//
// Revision 1.9  2003/04/02 15:08:59  simont
// rename signals
//
// Revision 1.8  2003/01/13 14:35:25  simont
// remove wb_bus_mon
//
// Revision 1.7  2002/10/28 16:43:12  simont
// add module oc8051_wb_iinterface
//
// Revision 1.6  2002/10/24 13:36:53  simont
// add instruction cache and DELAY parameters for external ram, rom
//
// Revision 1.5  2002/10/17 19:00:50  simont
// add external rom
//
// Revision 1.4  2002/09/30 17:33:58  simont
// prepared header
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"


module oc8051_tb;


//parameter FREQ  = 20000; // frequency in kHz
parameter FREQ  = 12000; // frequency in kHz

parameter DELAY = 500000/FREQ;

reg  rst, clk;
reg  [7:0] p0_in, p1_in, p2_in;
wire [15:0] ext_addr, iadr_o;
wire write, write_xram, write_uart, txd, rxd, int_uart, int0, int1, t0, t1, bit_out, stb_o, ack_i;
wire ack_xram, ack_uart, cyc_o, iack_i, istb_o, icyc_o, t2, t2ex;
wire [7:0] data_in, data_out, p0_out, p1_out, p2_out, p3_out, data_out_uart, data_out_xram, p3_in;
wire wbi_err_i, wbd_err_i;

`ifdef OC8051_XILINX_RAMB
  reg  [31:0] idat_i;
`else
  wire [31:0] idat_i;
`endif

///
/// buffer for test vectors
///
//
// buffer
reg [23:0] buff [0:255];
reg ea [0:1];

integer num;

assign wbd_err_i = 1'b0;
assign wbi_err_i = 1'b0;

//
// oc8051 controller
//
oc8051_top oc8051_top_1(.wb_rst_i(rst), .wb_clk_i(clk),
         .int0_i(int0), .int1_i(int1),

         .wbd_dat_i(data_in), .wbd_we_o(write), .wbd_dat_o(data_out),
         .wbd_adr_o(ext_addr), .wbd_err_i(wbd_err_i),
         .wbd_ack_i(ack_i), .wbd_stb_o(stb_o), .wbd_cyc_o(cyc_o),

	 .wbi_adr_o(iadr_o), .wbi_stb_o(istb_o), .wbi_ack_i(iack_i),
         .wbi_cyc_o(icyc_o), .wbi_dat_i(idat_i), .wbi_err_i(wbi_err_i),

  `ifdef OC8051_PORTS

   `ifdef OC8051_PORT0
	 .p0_i(p0_in),
	 .p0_o(p0_out),
   `endif

   `ifdef OC8051_PORT1
	 .p1_i(p1_in),
	 .p1_o(p1_out),
   `endif

   `ifdef OC8051_PORT2
	 .p2_i(p2_in),
	 .p2_o(p2_out),
   `endif

   `ifdef OC8051_PORT3
	 .p3_i(p3_in),
	 .p3_o(p3_out),
   `endif
  `endif


   `ifdef OC8051_UART
	 .rxd_i(rxd), .txd_o(txd),
   `endif

   `ifdef OC8051_TC01
	 .t0_i(t0), .t1_i(t1),
   `endif

   `ifdef OC8051_TC2
	 .t2_i(t2), .t2ex_i(t2ex),
   `endif

	 .ea_in(ea[0]));


//
// external data ram
//
oc8051_xram oc8051_xram1 (.clk(clk), .rst(rst), .wr(write_xram), .addr(ext_addr), .data_in(data_out), .data_out(data_out_xram), .ack(ack_xram), .stb(stb_o));


defparam oc8051_xram1.DELAY = 2;

`ifdef OC8051_SERIAL

//
// test programs with serial interface
//
oc8051_serial oc8051_serial1(.clk(clk), .rst(rst), .rxd(txd), .txd(rxd));

defparam oc8051_serial1.FREQ  = FREQ;
//defparam oc8051_serial1.BRATE = 9.6;
defparam oc8051_serial1.BRATE = 4.8;


`else

//
// external uart
//
oc8051_uart_test oc8051_uart_test1(.clk(clk), .rst(rst), .addr(ext_addr[7:0]), .wr(write_uart),
                  .wr_bit(p3_out[0]), .data_in(data_out), .data_out(data_out_uart), .bit_out(bit_out), .rxd(txd),
		  .txd(rxd), .ow(p3_out[1]), .intr(int_uart), .stb(stb_o), .ack(ack_uart));


`endif


`ifdef OC8051_XILINX_RAMB

`include "oc8051_rom_values.v"

//
// exteranl program rom
//
//
// rom 0
//
wire [11:0] adr0, adr1;
wire [15:0] dat0, dat1;

assign adr0 = iadr_o[13:2] + {11'h0, iadr_o[1]};
assign adr1 = iadr_o[13:2];

rom_8kx16_top rom_8kx16_top_0
(
  // WISHBONE slave
  .wb_clk_i(clk),
  .wb_rst_i(rst),
  .wb_dat_i(16'h0),
  .wb_dat_o(dat0),

  .wb_adr_i(adr0),
  .wb_sel_i(2'b11),
  .wb_we_i(1'b0),
  .wb_cyc_i(icyc_o),
  .wb_stb_i(istb_o),
  .wb_ack_o(iack_i),
  .wb_err_o(wbi_err_i)
);

rom_8kx16_top rom_8kx16_top_1
(
  // WISHBONE slave
  .wb_clk_i(clk),
  .wb_rst_i(rst),
  .wb_dat_i(16'h0),
  .wb_dat_o(dat1),

  .wb_adr_i(adr1),
  .wb_sel_i(2'b11),
  .wb_we_i(1'b0),
  .wb_cyc_i(icyc_o),
  .wb_stb_i(istb_o),
  .wb_ack_o(iack_i),
  .wb_err_o(wbi_err_i)
);

defparam  rom_8kx16_top_0.awidth = 12;
defparam  rom_8kx16_top_1.awidth = 12;

always @(iadr_o[1:0] or dat0 or dat1)
begin
  case (iadr_o[1:0])
    2'b00: idat_i = {8'h0, dat1[7:0], dat0};
    2'b01: idat_i = {8'h0, dat1, dat0[15:8]};
    2'b10: idat_i = {8'h0, dat0[7:0], dat1};
    default: idat_i = {8'h0, dat0, dat1[15:8]};
  endcase
end

`else

  oc8051_xrom oc8051_xrom1(.rst(rst), .clk(clk), .addr(iadr_o), .data(idat_i),
               .stb_i(istb_o), .cyc_i(icyc_o), .ack_o(iack_i));

   defparam oc8051_xrom1.DELAY = 0;

`endif
//
//
//



assign write_xram = p3_out[7] & write;
assign write_uart = !p3_out[7] & write;
assign data_in = p3_out[7] ? data_out_xram : data_out_uart;
assign ack_i = p3_out[7] ? ack_xram : ack_uart;
assign p3_in = {6'h0, bit_out, int_uart};
assign t0 = p3_out[5];
assign t1 = p3_out[6];

assign int0 = p3_out[3];
assign int1 = p3_out[4];
assign t2 = p3_out[5];
assign t2ex = p3_out[2];

initial begin
  rst= 1'b1;
  p0_in = 8'h00;
  p1_in = 8'h00;
  p2_in = 8'h00;
#220
  rst = 1'b0;

#80000000
  $display("time ",$time, "\n faulire: end of time\n \n");
  $display("");
  $finish;
end


initial
begin
  clk = 0;
  forever #DELAY clk <= ~clk;
end


always @(ext_addr or write or stb_o or data_out)
begin
  if ((ext_addr==16'h0010) & write & stb_o) begin
    if (data_out==8'h7f) begin
      $display("");
      $display("time ",$time, " Passed");
      $display("");
      $finish;

    end else begin
      $display("");
      $display("time ",$time," Error: %h", data_out);
      $display("");
      $finish;
    end
  end
end


initial
  $readmemb("../oc8051_ea.in", ea);




endmodule
