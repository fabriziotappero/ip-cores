//////////////////////////////////////////////////////////////////////
////                                                              ////
//// wishboneArb.v                                                 ////
////                                                              ////
//// This file is part of the usbHostSlave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
//// Arbitrate between 3 wishbone bus controllers
//// Uses Round Robin access controller
//// 
////
////                                                              ////
//// To Do:                                                       ////
//// 
////                                                              ////
//// Author(s):                                                   ////
//// - Steve Fielding, sfielding@base2designs.com                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Steve Fielding and OPENCORES.ORG          ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
module wishboneArb (
  clk,
  rst,

  addr0_i,
  data0_i,
  stb0_i,
  we0_i,
  req0,
  gnt0,

  addr1_i,
  data1_i,
  stb1_i,
  we1_i,
  req1,
  gnt1,

  addr2_i,
  data2_i,
  stb2_i,
  we2_i,
  req2,
  gnt2,


  addr_o,
  data_o,
  stb_o,
  we_o
);

input clk;
input rst;

input [7:0] addr0_i;
input [7:0] data0_i;
input stb0_i;
input we0_i;
input req0;
output gnt0;
reg gnt0;

input [7:0] addr1_i;
input [7:0] data1_i;
input stb1_i;
input we1_i;
input req1;
output gnt1;
reg gnt1;

input [7:0] addr2_i;
input [7:0] data2_i;
input stb2_i;
input we2_i;
input req2;
output gnt2;
reg gnt2;


output [7:0] addr_o;
reg [7:0] addr_o;
output [7:0] data_o;
reg [7:0] data_o;
output stb_o;
reg stb_o;
output we_o;
reg we_o;

//local wires and regs
reg [1:0] muxSel;
reg [2:0] arbSt;

`define REQ_0 3'b000
`define REQ_1 3'b001
`define REQ_2 3'b010
`define GNT_0 3'b011
`define GNT_1 3'b100
`define GNT_2 3'b101


//arb
always @(posedge clk) begin
  if (rst == 1'b1) begin
    gnt0 <= 1'b0;
    gnt1 <= 1'b0;
    gnt2 <= 1'b0;
    muxSel <= 2'b00;
    arbSt <= `REQ_0;
  end
  else begin
    case (arbSt)
      `REQ_0: begin
        if (req0 == 1'b1)
          arbSt <= `GNT_0;
        else
          arbSt <= `REQ_1;
      end
      `REQ_1: begin
        if (req1 == 1'b1)
          arbSt <= `GNT_1;
        else
          arbSt <= `REQ_2;
      end
      `REQ_2: begin
        if (req2 == 1'b1)
          arbSt <= `GNT_2;
        else
          arbSt <= `REQ_0;
      end
      `GNT_0: begin
        gnt0 <= 1'b1;
        muxSel <= 2'b00;
        if (req0 == 1'b0) begin
          arbSt <= `REQ_1;
          gnt0 <= 1'b0;
        end
      end
      `GNT_1: begin
        gnt1 <= 1'b1;
        muxSel <= 2'b01;
        if (req1 == 1'b0) begin
          arbSt <= `REQ_2;
          gnt1 <= 1'b0;
        end
      end
      `GNT_2: begin
        gnt2 <= 1'b1;
        muxSel <= 2'b10;
        if (req2 == 1'b0) begin
          arbSt <= `REQ_0;
          gnt2 <= 1'b0;
        end
      end
    endcase
  end
end


//mux
always @(*) begin
  case (muxSel)
    2'b00: begin
      addr_o <= addr0_i;
      data_o <= data0_i;
      stb_o <= stb0_i;
      we_o <= we0_i;
    end
    2'b01: begin
      addr_o <= addr1_i;
      data_o <= data1_i;
      stb_o <= stb1_i;
      we_o <= we1_i;
    end
    2'b10: begin
      addr_o <= addr2_i;
      data_o <= data2_i;
      stb_o <= stb2_i;
      we_o <= we2_i;
    end
    default: begin
      addr_o <= addr0_i;
      data_o <= data0_i;
      stb_o <= stb0_i;
      we_o <= we0_i;
    end
  endcase
end


endmodule

