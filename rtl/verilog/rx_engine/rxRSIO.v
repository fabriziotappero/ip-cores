//////////////////////////////////////////////////////////////////////
////                                                              ////
//// MODULE NAME: rxRSIO                                          ////
////                                                              ////
//// DESCRIPTION: Datapath of Reconciliation Sublayer.            ////
////                                                              ////
////                                                              ////
//// This file is part of the 10 Gigabit Ethernet IP core project ////
////  http://www.opencores.org/projects/ethmac10g/                ////
////                                                              ////
//// AUTHOR(S):                                                   ////
//// Zheng Cao                                                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (c) 2005 AUTHORS.  All rights reserved.            ////
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
// CVS REVISION HISTORY:
//
// $Log: not supported by cvs2svn $
// Revision 1.2  2006/06/16 06:36:28  fisher5090
// no message
//
// Revision 1.1.1.1  2006/05/31 05:59:43  Zheng Cao
// first version
//
// Revision 1.1  2005/12/25 16:43:10  Zheng Cao
// 
// 
//
//////////////////////////////////////////////////////////////////////

`include "timescale.v"
`include "xgiga_define.v"

module rxRSIO(rxclk, rxclk_180, rxclk_2x, reset, rxd_in, rxc_in, rxd64, rxc8, local_fault, remote_fault);
    input rxclk;
    input rxclk_180;
    input rxclk_2x;
    input reset;
    input [31:0] rxd_in;
    input [3:0] rxc_in;
    output [63:0] rxd64;
    output [7:0] rxc8;
    output local_fault;
    output remote_fault;

    parameter TP =1;

    reg local_fault, remote_fault;
//  wire get_align, get_seq;
      
    always@(posedge rxclk or posedge reset) begin
          if(reset) begin
            local_fault <=#TP 0;
            remote_fault <=#TP 0;
          end
          else begin
            local_fault <=#TP (rxd_in[7:0] == `SEQUENCE) & (rxd_in[29:8] == 0) & (rxc_in[3:0]== 4'h8) & ~rxd_in[30] & rxd_in[31]; 
            remote_fault<=#TP (rxd_in[7:0] == `SEQUENCE) & (rxd_in[29:8] == 0) & (rxc_in[3:0]== 4'h8) & rxd_in[30] & rxd_in[31];   
          end
    end 
//    assign get_align = ((rxd_in[7:0]==`START) & rxc_in[0]);
//  assign get_seq = (rxd_in[7:0] == `SEQUENCE) & (rxd_in[29:8] == 0) & (rxc_in[3:0]== 4'h8) & rxd_in[31];
//  assign local_fault = get_seq & ~rxd_in[30];
//  assign remote_fault = get_seq & rxd_in[30];
 
    reg[7:0] rxc8_in_tmp;
    reg[63:0]rxd64_in_tmp;
    reg[3:0] rxc4_in_tmp;
    reg[31:0]rxd32_in_tmp;
    reg[31:0]rxd32_in_tmp_d1;
    reg[3:0] rxc4_in_tmp_d1;
    
    always@(posedge rxclk_2x or posedge reset) begin
         if (reset) begin
           rxc4_in_tmp  <= #TP 0;
           rxd32_in_tmp <= #TP 0;
           rxc4_in_tmp_d1  <= #TP 0;
           rxd32_in_tmp_d1 <= #TP 0;
         end
         else begin
           rxc4_in_tmp  <= #TP rxc_in;
           rxd32_in_tmp <= #TP rxd_in;
           rxc4_in_tmp_d1  <= #TP rxc4_in_tmp;
           rxd32_in_tmp_d1 <= #TP rxd32_in_tmp;
         end
    end
    
    reg get_align_reg;
    always@(posedge rxclk_2x or posedge reset) begin
         if (reset)
           get_align_reg <=#TP 0;
         else if((rxd32_in_tmp[7:0]==`START) & rxc4_in_tmp[0])      
           get_align_reg <=#TP 1'b1;
         else if((&rxc4_in_tmp)&(rxd32_in_tmp==32'h07070707))
           get_align_reg <=#TP 1'b0;
    end
    
    reg [1:0] qvWriteCntrl;
    always@(posedge rxclk_2x or posedge reset) begin
         if (reset)
            qvWriteCntrl <= 2'b01;
         else if(get_align_reg) begin
            qvWriteCntrl[1] <= qvWriteCntrl[0];
            qvWriteCntrl[0] <= qvWriteCntrl[1];
         end
         else
            qvWriteCntrl <= 2'b01;
    end
    
    always@(posedge rxclk_2x or posedge reset) begin
         if (reset)begin
           rxd64_in_tmp <= #TP 0;
           rxc8_in_tmp  <= #TP 0;
         end
         else if(qvWriteCntrl[1]) begin
           rxd64_in_tmp[63:32] <= #TP rxd32_in_tmp_d1;
           rxc8_in_tmp[7:4] <= #TP rxc4_in_tmp_d1;      
         end 
         else begin
           rxd64_in_tmp[31:0] <= #TP rxd32_in_tmp_d1;
           rxc8_in_tmp[3:0] <= #TP rxc4_in_tmp_d1;
         end
    end
  
  wire [71:0] rxdata;
  
  assign rxd64 = rxdata[63:0];
  assign rxc8  = rxdata[71:64]; 
  
  defparam RealignInst.pDepthWidth = 5;
  defparam RealignInst.pWordWidth = 72;
  SwitchAsyncFIFO RealignInst(
                  .inReset(!reset),
                  .iWClk(rxclk_2x),
                  .iWEn(qvWriteCntrl[0]),
                  .ivDataIn({rxc8_in_tmp,rxd64_in_tmp}),
                  .qWFull(),
                  .qvWCount(),
                  .iRClk(rxclk),
                  .iREn(1'b1),
                  .ovDataOut(rxdata),
                  .qREmpty(),
                  .qvRNumberLeft()
  );
           
endmodule
