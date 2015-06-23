//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores timer/counter2 control                           ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   timers and counters 2 8051 core                            ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
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
// Revision 1.2  2003/04/04 10:34:13  simont
// change timers to meet timing specifications (add divider with 12)
//
// Revision 1.1  2003/01/13 14:13:12  simont
// initial import
//
//
//

`include "oc8051_defines.v"

//synopsys translate_off
`include "oc8051_timescale.v"
//synopsys translate_on



module oc8051_tc2 (clk, rst,
            wr_addr,
	    data_in, bit_in,
	    wr, wr_bit,
	    t2, t2ex,
            rclk, tclk,
	    brate2, tc2_int,
	    pres_ow,
//registers
	    t2con, tl2, th2, rcap2l, rcap2h);

input [7:0]  wr_addr,
             data_in;
input        clk,
             rst,
	     wr,
	     wr_bit,
	     t2,
	     t2ex,
	     bit_in,
	     pres_ow;	//prescalre owerflov
output [7:0] t2con,
             tl2,
	     th2,
	     rcap2l,
	     rcap2h;
output       tc2_int,
	     rclk,
	     tclk,
	     brate2;


reg brate2;
reg [7:0] t2con, tl2, th2, rcap2l, rcap2h;

reg neg_trans, t2ex_r, t2_r, tc2_event, tf2_set;

wire run;

//
// t2con
wire tf2, exf2, exen2, tr2, ct2, cprl2;

assign tc2_int = tf2 | exf2;
assign tf2   = t2con[7];
assign exf2  = t2con[6];
assign rclk  = t2con[5];
assign tclk  = t2con[4];
assign exen2 = t2con[3];
assign tr2   = t2con[2];
assign ct2   = t2con[1];
assign cprl2 = t2con[0];

always @(posedge clk or posedge rst)
begin
  if (rst) begin
    t2con <= #1 `OC8051_RST_T2CON;
  end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_T2CON)) begin
    t2con <= #1 data_in;
  end else if ((wr) & (wr_bit) & (wr_addr[7:3]==`OC8051_SFR_B_T2CON)) begin
    t2con[wr_addr[2:0]] <= #1 bit_in;
  end else if (tf2_set) begin
    t2con[7] <= #1 1'b1;
  end else if (exen2 & neg_trans) begin
    t2con[6] <= #1 1'b1;
  end
end


//
//th2, tl2
assign run = tr2 & ((!ct2 & pres_ow) | (ct2 & tc2_event));

always @(posedge clk or posedge rst)
begin
  if (rst) begin
//
// reset
//
    tl2 <= #1 `OC8051_RST_TL2;
    th2 <= #1 `OC8051_RST_TH2;
    brate2 <= #1 1'b0;
    tf2_set <= #1 1'b0;
  end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_TH2)) begin
//
// write to timer 2 high
//
    th2 <= #1 data_in;
  end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_TL2)) begin
//
// write to timer 2 low
//
    tl2 <= #1 data_in;
  end else if (!(rclk | tclk) & !cprl2 & exen2 & neg_trans) begin
//
// avto reload mode, exen2=1, 0-1 transition on t2ex pin
//
    th2 <= #1 rcap2h;
    tl2 <= #1 rcap2l;
    tf2_set <= #1 1'b0;
  end else if (run) begin
    if (rclk | tclk) begin
//
// boud rate generator mode
//
      if (&{th2, tl2}) begin
        th2 <= #1 rcap2h;
        tl2 <= #1 rcap2l;
        brate2 <= #1 1'b1;
      end else begin
        {brate2, th2, tl2}  <= #1 {1'b0, th2, tl2} + 17'h1;
      end
      tf2_set <= #1 1'b0;
    end else if (cprl2) begin
//
// capture mode
//
      {tf2_set, th2, tl2}  <= #1 {1'b0, th2, tl2} + 17'h1;
    end else begin
//
// auto reload mode
//
      if (&{th2, tl2}) begin
        th2 <= #1 rcap2h;
        tl2 <= #1 rcap2l;
        tf2_set <= #1 1'b1;
      end else begin
        {tf2_set, th2, tl2} <= #1 {1'b0, th2, tl2} + 17'h1;
      end
    end
  end else tf2_set <= #1 1'b0;
end


//
// rcap2l, rcap2h
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    rcap2l <= #1 `OC8051_RST_RCAP2L;
    rcap2h <= #1 `OC8051_RST_RCAP2H;
  end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_RCAP2H)) begin
    rcap2h <= #1 data_in;
  end else if ((wr) & !(wr_bit) & (wr_addr==`OC8051_SFR_RCAP2L)) begin
    rcap2l <= #1 data_in;
  end else if (!(rclk | tclk) & exen2 & cprl2 & neg_trans) begin
    rcap2l <= #1 tl2;
    rcap2h <= #1 th2;
  end
end


//
//
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    neg_trans <= #1 1'b0;
    t2ex_r <= #1 1'b0;
  end else if (t2ex) begin
    neg_trans <= #1 1'b0;
    t2ex_r <= #1 1'b1;
  end else if (t2ex_r) begin
    neg_trans <= #1 1'b1;
    t2ex_r <= #1 1'b0;
  end else begin
    neg_trans <= #1 1'b0;
    t2ex_r <= #1 t2ex_r;
  end
end

//
//
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    tc2_event <= #1 1'b0;
    t2_r <= #1 1'b0;
  end else if (t2) begin
    tc2_event <= #1 1'b0;
    t2_r <= #1 1'b1;
  end else if (!t2 & t2_r) begin
    tc2_event <= #1 1'b1;
    t2_r <= #1 1'b0;
  end else begin
    tc2_event <= #1 1'b0;
  end
end

endmodule
