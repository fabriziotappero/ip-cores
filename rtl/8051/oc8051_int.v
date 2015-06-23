//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores interrupt control module                         ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   contains sfr's: tcon, ip, ie;                              ////
////   interrupt handling                                         ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Teran, simont@opencores.org                     ////
////      - Jaka Simsic, jakas@opencores.org                      ////
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
// Revision 1.9  2003/06/03 17:12:05  simont
// fix some bugs.
//
// Revision 1.8  2003/04/07 14:58:02  simont
// change sfr's interface.
//
// Revision 1.7  2003/03/28 17:45:57  simont
// change module name.
//
// Revision 1.6  2003/01/13 14:14:41  simont
// replace some modules
//
// Revision 1.5  2002/09/30 17:33:59  simont
// prepared header
//
//


`include "oc8051_defines.v"

//synopsys translate_off
`include "oc8051_timescale.v"
//synopsys translate_on



module oc8051_int (clk, rst, 
        wr_addr,  
	data_in, bit_in, 
	wr, wr_bit,
//timer interrupts
        tf0, tf1, t2_int,
	tr0, tr1,
//external interrupts
        ie0, ie1,
//uart interrupts
        uart_int,
//to cpu
        intr, reti, int_vec, ack,
//registers
	ie, tcon, ip);

input [7:0] wr_addr, data_in;
input wr, tf0, tf1, t2_int, ie0, ie1, clk, rst, reti, wr_bit, bit_in, ack, uart_int;

output tr0, tr1, intr;
output [7:0] int_vec,
             ie,
	     tcon,
	     ip;

reg [7:0] ip, ie, int_vec;

reg [3:0] tcon_s;
reg tcon_tf1, tcon_tf0, tcon_ie1, tcon_ie0;

//
// isrc		processing interrupt sources
// int_dept
wire [2:0] isrc_cur;
reg [2:0] isrc [1:0];
reg [1:0] int_dept;
wire [1:0] int_dept_1;
reg int_proc;
reg [1:0] int_lev [1:0];
wire cur_lev;

assign isrc_cur = int_proc ? isrc[int_dept_1] : 2'h0;
assign int_dept_1 = int_dept - 2'b01;
assign cur_lev = int_lev[int_dept_1];

//
// contains witch level of interrupts is running
//reg [1:0] int_levl, int_levl_w;

//
// int_ln	waiting interrupts on level n
// ip_ln	interrupts on level n
// int_src	interrupt sources
wire [5:0] int_l0, int_l1;
wire [5:0] ip_l0, ip_l1;
wire [5:0] int_src;
wire il0, il1;


reg tf0_buff, tf1_buff, ie0_buff, ie1_buff;

//
//interrupt priority
assign ip_l0 = ~ip[5:0];
assign ip_l1 = ip[5:0];

assign int_src = {t2_int, uart_int, tcon_tf1, tcon_ie1, tcon_tf0, tcon_ie0};

//
// waiting interrupts
assign int_l0 = ip_l0 & {ie[5:0]} & int_src;
assign int_l1 = ip_l1 & {ie[5:0]} & int_src;
assign il0 = |int_l0;
assign il1 = |int_l1;

//
// TCON
assign tcon = {tcon_tf1, tcon_s[3], tcon_tf0, tcon_s[2], tcon_ie1, tcon_s[1], tcon_ie0, tcon_s[0]};
assign tr0 = tcon_s[2];
assign tr1 = tcon_s[3];
assign intr = |int_vec;


//
// IP
always @(posedge clk or posedge rst)
begin
 if (rst) begin
   ip <=#1 `OC8051_RST_IP;
 end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_IP)) begin
   ip <= #1 data_in;
 end else if ((wr) & (wr_bit) & (wr_addr[7:3]==`OC8051_SFR_B_IP))
   ip[wr_addr[2:0]] <= #1 bit_in;
end

//
// IE
always @(posedge clk or posedge rst)
begin
 if (rst) begin
   ie <=#1 `OC8051_RST_IE;
 end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_IE)) begin
   ie <= #1 data_in;
 end else if ((wr) & (wr_bit) & (wr_addr[7:3]==`OC8051_SFR_B_IE))
   ie[wr_addr[2:0]] <= #1 bit_in;
end

//
// tcon_s
//
always @(posedge clk or posedge rst)
begin
 if (rst) begin
   tcon_s <=#1 4'b0000;
 end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_TCON)) begin
   tcon_s <= #1 {data_in[6], data_in[4], data_in[2], data_in[0]};
 end else if ((wr) & (wr_bit) & (wr_addr[7:3]==`OC8051_SFR_B_TCON)) begin
   case (wr_addr[2:0]) /* synopsys full_case parallel_case */
     3'b000: tcon_s[0] <= #1 bit_in;
     3'b010: tcon_s[1] <= #1 bit_in;
     3'b100: tcon_s[2] <= #1 bit_in;
     3'b110: tcon_s[3] <= #1 bit_in;
   endcase
 end
end

//
// tf1 (tmod.7)
//
always @(posedge clk or posedge rst)
begin
 if (rst) begin
   tcon_tf1 <=#1 1'b0;
 end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_TCON)) begin
   tcon_tf1 <= #1 data_in[7];
 end else if ((wr) & (wr_bit) & (wr_addr=={`OC8051_SFR_B_TCON, 3'b111})) begin
   tcon_tf1 <= #1 bit_in;
 end else if (!(tf1_buff) & (tf1)) begin
   tcon_tf1 <= #1 1'b1;
 end else if (ack & (isrc_cur==`OC8051_ISRC_TF1)) begin
   tcon_tf1 <= #1 1'b0;
 end
end

//
// tf0 (tmod.5)
//
always @(posedge clk or posedge rst)
begin
 if (rst) begin
   tcon_tf0 <=#1 1'b0;
 end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_TCON)) begin
   tcon_tf0 <= #1 data_in[5];
 end else if ((wr) & (wr_bit) & (wr_addr=={`OC8051_SFR_B_TCON, 3'b101})) begin
   tcon_tf0 <= #1 bit_in;
 end else if (!(tf0_buff) & (tf0)) begin
   tcon_tf0 <= #1 1'b1;
 end else if (ack & (isrc_cur==`OC8051_ISRC_TF0)) begin
   tcon_tf0 <= #1 1'b0;
 end
end


//
// ie0 (tmod.1)
//
always @(posedge clk or posedge rst)
begin
 if (rst) begin
   tcon_ie0 <=#1 1'b0;
 end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_TCON)) begin
   tcon_ie0 <= #1 data_in[1];
 end else if ((wr) & (wr_bit) & (wr_addr=={`OC8051_SFR_B_TCON, 3'b001})) begin
   tcon_ie0 <= #1 bit_in;
 end else if (((tcon_s[0]) & (ie0_buff) & !(ie0)) | (!(tcon_s[0]) & !(ie0))) begin
   tcon_ie0 <= #1 1'b1;
 end else if (ack & (isrc_cur==`OC8051_ISRC_IE0) & (tcon_s[0])) begin
   tcon_ie0 <= #1 1'b0;
 end else if (!(tcon_s[0]) & (ie0)) begin
   tcon_ie0 <= #1 1'b0;
 end
end


//
// ie1 (tmod.3)
//
always @(posedge clk or posedge rst)
begin
 if (rst) begin
   tcon_ie1 <=#1 1'b0;
 end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_TCON)) begin
   tcon_ie1 <= #1 data_in[3];
 end else if ((wr) & (wr_bit) & (wr_addr=={`OC8051_SFR_B_TCON, 3'b011})) begin
   tcon_ie1 <= #1 bit_in;
 end else if (((tcon_s[1]) & (ie1_buff) & !(ie1)) | (!(tcon_s[1]) & !(ie1))) begin
   tcon_ie1 <= #1 1'b1;
 end else if (ack & (isrc_cur==`OC8051_ISRC_IE1) & (tcon_s[1])) begin
   tcon_ie1 <= #1 1'b0;
 end else if (!(tcon_s[1]) & (ie1)) begin
   tcon_ie1 <= #1 1'b0;
 end
end

//
// interrupt processing
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    int_vec <= #1 8'h00;
    int_dept <= #1 2'b0;
    isrc[0] <= #1 3'h0;
    isrc[1] <= #1 3'h0;
    int_proc <= #1 1'b0;
    int_lev[0] <= #1 1'b0;
    int_lev[1] <= #1 1'b0;
  end else if (reti & int_proc) begin  // return from interrupt
   if (int_dept==2'b01)
     int_proc <= #1 1'b0;
   int_dept <= #1 int_dept - 2'b01;
  end else if (((ie[7]) & (!cur_lev) || !int_proc) & il1) begin  // interrupt on level 1
   int_proc <= #1 1'b1;
   int_lev[int_dept] <= #1 `OC8051_ILEV_L1;
   int_dept <= #1 int_dept + 2'b01;
   if (int_l1[0]) begin
     int_vec <= #1 `OC8051_INT_X0;
     isrc[int_dept] <= #1 `OC8051_ISRC_IE0;
   end else if (int_l1[1]) begin
     int_vec <= #1 `OC8051_INT_T0;
     isrc[int_dept] <= #1 `OC8051_ISRC_TF0;
   end else if (int_l1[2]) begin
     int_vec <= #1 `OC8051_INT_X1;
     isrc[int_dept] <= #1 `OC8051_ISRC_IE1;
   end else if (int_l1[3]) begin
     int_vec <= #1 `OC8051_INT_T1;
     isrc[int_dept] <= #1 `OC8051_ISRC_TF1;
   end else if (int_l1[4]) begin
     int_vec <= #1 `OC8051_INT_UART;
     isrc[int_dept] <= #1 `OC8051_ISRC_UART;
   end else if (int_l1[5]) begin
     int_vec <= #1 `OC8051_INT_T2;
     isrc[int_dept] <= #1 `OC8051_ISRC_T2;
   end

 end else if ((ie[7]) & !int_proc & il0) begin  // interrupt on level 0
   int_proc <= #1 1'b1;
   int_lev[int_dept] <= #1 `OC8051_ILEV_L0;
   int_dept <= #1 2'b01;
   if (int_l0[0]) begin
     int_vec <= #1 `OC8051_INT_X0;
     isrc[int_dept] <= #1 `OC8051_ISRC_IE0;
   end else if (int_l0[1]) begin
     int_vec <= #1 `OC8051_INT_T0;
     isrc[int_dept] <= #1 `OC8051_ISRC_TF0;
   end else if (int_l0[2]) begin
     int_vec <= #1 `OC8051_INT_X1;
     isrc[int_dept] <= #1 `OC8051_ISRC_IE1;
   end else if (int_l0[3]) begin
     int_vec <= #1 `OC8051_INT_T1;
     isrc[int_dept] <= #1 `OC8051_ISRC_TF1;
   end else if (int_l0[4]) begin
     int_vec <= #1 `OC8051_INT_UART;
     isrc[int_dept] <= #1 `OC8051_ISRC_UART;
   end else if (int_l0[5]) begin
     int_vec <= #1 `OC8051_INT_T2;
     isrc[int_dept] <= #1 `OC8051_ISRC_T2;
   end
 end else begin
   int_vec <= #1 8'h00;
 end
end


always @(posedge clk or posedge rst)
  if (rst) begin
    tf0_buff <= #1 1'b0;
    tf1_buff <= #1 1'b0;
    ie0_buff <= #1 1'b0;
    ie1_buff <= #1 1'b0;
  end else begin
    tf0_buff <= #1 tf0;
    tf1_buff <= #1 tf1;
    ie0_buff <= #1 ie0;
    ie1_buff <= #1 ie1;
  end

endmodule
