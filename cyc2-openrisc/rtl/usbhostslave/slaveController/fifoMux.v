//////////////////////////////////////////////////////////////////////
////                                                              ////
//// fifoMux.v                                                    ////
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
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
//// Copyright (C) 2004 Steve Fielding and OPENCORES.ORG          ////
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
`include "timescale.v"

module fifoMux (
  currEndP,
  //TxFifo
  TxFifoREn,
  TxFifoEP0REn,
  TxFifoEP1REn,
  TxFifoEP2REn,
  TxFifoEP3REn,
  TxFifoData,
  TxFifoEP0Data,
  TxFifoEP1Data,
  TxFifoEP2Data,
  TxFifoEP3Data,
  TxFifoEmpty,
  TxFifoEP0Empty,
  TxFifoEP1Empty,
  TxFifoEP2Empty,
  TxFifoEP3Empty,
  //RxFifo
  RxFifoWEn,
  RxFifoEP0WEn,
  RxFifoEP1WEn,
  RxFifoEP2WEn,
  RxFifoEP3WEn,
  RxFifoFull,
  RxFifoEP0Full,
  RxFifoEP1Full,
  RxFifoEP2Full,
  RxFifoEP3Full
    );


input [3:0] currEndP;
//TxFifo
input TxFifoREn;
output TxFifoEP0REn;
output TxFifoEP1REn;
output TxFifoEP2REn;
output TxFifoEP3REn;
output [7:0] TxFifoData;
input [7:0] TxFifoEP0Data;
input [7:0] TxFifoEP1Data;
input [7:0] TxFifoEP2Data;
input [7:0] TxFifoEP3Data;
output TxFifoEmpty;
input TxFifoEP0Empty;
input TxFifoEP1Empty;
input TxFifoEP2Empty;
input TxFifoEP3Empty;
  //RxFifo
input RxFifoWEn;
output RxFifoEP0WEn;
output RxFifoEP1WEn;
output RxFifoEP2WEn;
output RxFifoEP3WEn;
output RxFifoFull;
input RxFifoEP0Full;
input RxFifoEP1Full;
input RxFifoEP2Full;
input RxFifoEP3Full;

wire [3:0] currEndP;
//TxFifo
wire TxFifoREn;
reg TxFifoEP0REn;
reg TxFifoEP1REn;
reg TxFifoEP2REn;
reg TxFifoEP3REn;
reg [7:0] TxFifoData;
wire [7:0] TxFifoEP0Data;
wire [7:0] TxFifoEP1Data;
wire [7:0] TxFifoEP2Data;
wire [7:0] TxFifoEP3Data;
reg TxFifoEmpty;
wire TxFifoEP0Empty;
wire TxFifoEP1Empty;
wire TxFifoEP2Empty;
wire TxFifoEP3Empty;
  //RxFifo
wire RxFifoWEn;
reg RxFifoEP0WEn;
reg RxFifoEP1WEn;
reg RxFifoEP2WEn;
reg RxFifoEP3WEn;
reg RxFifoFull;
wire RxFifoEP0Full;
wire RxFifoEP1Full;
wire RxFifoEP2Full;
wire RxFifoEP3Full;

//internal wires and regs

//combinatorially mux TX and RX fifos for end points 0 through 3
always @(currEndP or
  TxFifoREn or
  RxFifoWEn or
  TxFifoEP0Data or
  TxFifoEP1Data or
  TxFifoEP2Data or
  TxFifoEP3Data or
  TxFifoEP0Empty or
  TxFifoEP1Empty or
  TxFifoEP2Empty or
  TxFifoEP3Empty or
  RxFifoEP0Full or
  RxFifoEP1Full or
  RxFifoEP2Full or
  RxFifoEP3Full)
begin
  case (currEndP[1:0])
    2'b00: begin
      TxFifoEP0REn <= TxFifoREn;
      TxFifoEP1REn <= 1'b0;
      TxFifoEP2REn <= 1'b0;
      TxFifoEP3REn <= 1'b0;
      TxFifoData <= TxFifoEP0Data;
      TxFifoEmpty <= TxFifoEP0Empty;
      RxFifoEP0WEn <= RxFifoWEn;
      RxFifoEP1WEn <= 1'b0;
      RxFifoEP2WEn <= 1'b0;
      RxFifoEP3WEn <= 1'b0;
      RxFifoFull <= RxFifoEP0Full;
    end
    2'b01: begin
      TxFifoEP0REn <= 1'b0;
      TxFifoEP1REn <= TxFifoREn;
      TxFifoEP2REn <= 1'b0;
      TxFifoEP3REn <= 1'b0;
      TxFifoData <= TxFifoEP1Data;
      TxFifoEmpty <= TxFifoEP1Empty;
      RxFifoEP0WEn <= 1'b0;
      RxFifoEP1WEn <= RxFifoWEn;
      RxFifoEP2WEn <= 1'b0;
      RxFifoEP3WEn <= 1'b0;
      RxFifoFull <= RxFifoEP1Full;
    end
    2'b10: begin
      TxFifoEP0REn <= 1'b0;
      TxFifoEP1REn <= 1'b0;
      TxFifoEP2REn <= TxFifoREn;
      TxFifoEP3REn <= 1'b0;
      TxFifoData <= TxFifoEP2Data;
      TxFifoEmpty <= TxFifoEP2Empty;
      RxFifoEP0WEn <= 1'b0;
      RxFifoEP1WEn <= 1'b0;
      RxFifoEP2WEn <= RxFifoWEn;
      RxFifoEP3WEn <= 1'b0;
      RxFifoFull <= RxFifoEP2Full;
    end
    2'b11: begin
      TxFifoEP0REn <= 1'b0;
      TxFifoEP1REn <= 1'b0;
      TxFifoEP2REn <= 1'b0;
      TxFifoEP3REn <= TxFifoREn;
      TxFifoData <= TxFifoEP3Data;
      TxFifoEmpty <= TxFifoEP3Empty;
      RxFifoEP0WEn <= 1'b0;
      RxFifoEP1WEn <= 1'b0;
      RxFifoEP2WEn <= 1'b0;
      RxFifoEP3WEn <= RxFifoWEn;
      RxFifoFull <= RxFifoEP3Full;
    end
  endcase  
end      


endmodule
