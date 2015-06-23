//////////////////////////////////////////////////////////////////////
////                                                              ////
//// MODULE NAME: rxCRC                                           ////
////                                                              ////
//// DESCRIPTION: CRC Checker, by using magic word c704dd7b.      ////
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
// Revision 1.1.1.1  2006/05/31 05:59:41  Zheng Cao
// first version
//
// Revision 1.1  2005/12/25 16:43:10  Zheng Cao
// 
// 
//
//////////////////////////////////////////////////////////////////////

`include "timescale.v"
`include "xgiga_define.v"

module rxCRC(rxclk, reset, receiving, receiving_d1, CRC_DATA, get_terminator,
 get_terminator_d1, wait_crc_check,crc_check_invalid, crc_check_valid, terminator_location,get_error_code);
    input rxclk;
    input reset;
    input get_terminator;
    input [63:0] CRC_DATA;
    input receiving;
    input receiving_d1;
    input [2:0] terminator_location;
    input wait_crc_check;

    output crc_check_invalid;
    output crc_check_valid;
    output get_terminator_d1;
    input get_error_code;

    parameter TP = 1;

   ///////////////////////////////////////////////////
   // Input registers
   ///////////////////////////////////////////////////

   reg get_terminator_d1, get_terminator_d2,get_terminator_d3;
   always@(posedge rxclk or posedge reset) begin
        if(reset)begin
          get_terminator_d1 <=#TP 0;
          get_terminator_d2 <=#TP 0;
          get_terminator_d3 <=#TP 0;
        end   
        else begin
          get_terminator_d1 <=#TP get_terminator;
          get_terminator_d2 <=#TP get_terminator_d1;
          get_terminator_d3 <=#TP get_terminator_d2;
        end   
   end

   reg[2:0] bytes_cnt;
   reg crc_8_en;//enable 8bit CRC
   always@(posedge rxclk or posedge reset) begin
        if (reset)
           bytes_cnt <=#TP 0;
        else if (get_terminator)
           bytes_cnt <=#TP terminator_location;
        else if (crc_8_en)
           bytes_cnt <=#TP bytes_cnt-1;
   end

   reg[63:0] terminator_data;
   always@(posedge rxclk or posedge reset) begin  
        if(reset)
           terminator_data <=#TP 0;
        else if (get_terminator_d2)
           terminator_data <=#TP CRC_DATA;
        else
           terminator_data <=#TP terminator_data<<8;
   end

   /////////////////////////////////////////////////////////////////////////////////////////////
   // 64bits CRC 
   // start: crc_valid = 8'hff and receiving_frame = 1
   // end  : crc_valid != 8'hff or receiving_frame = 0
   // if bits_more is 0, then CRC check will happen when end happens.
   // else 8bits CRC should begin
   /////////////////////////////////////////////////////////////////////////////////////////////

   wire [31:0] crc_from_64;

   reg crc_64_en; // 64bit CRC Enable
   always@(posedge rxclk or posedge reset) begin
        if(reset)
          crc_64_en <= #TP 1'b0;
        else if(get_error_code) //if error, stop crc checking
          crc_64_en <= #TP 1'b0;
        else if(receiving_d1 & receiving) 
          crc_64_en <= #TP 1'b1;
        else
          crc_64_en <= #TP 1'b0;
   end

   CRC32_D64 crc64(.DATA_IN(CRC_DATA), .CLK(rxclk), .RESET(reset), .START(crc_64_en), .CRC_OUT(crc_from_64), .init(get_terminator_d3|get_error_code));
     
   /////////////////////////////////////////////////////////////////////////////////////////////
   // 8bits CRC
   /////////////////////////////////////////////////////////////////////////////////////////////
   
   reg[7:0] CRC_DATA_TMP;
   always@(posedge rxclk or posedge reset) begin
        if(reset)
          CRC_DATA_TMP <=#TP 0;
        else 
          CRC_DATA_TMP <=#TP terminator_data[63:56];
        end
    
   always@(posedge rxclk or posedge reset) begin
        if(reset)
          crc_8_en <=#TP 0;
        else if (get_terminator_d3)
          crc_8_en <=#TP 1'b1;
        else if(bytes_cnt==1)
           crc_8_en <=#TP 1'b0;
   end  
 
   reg do_crc_check;
   always@(posedge rxclk or posedge reset) begin
        if (reset)
          do_crc_check <=#TP 0;
        else if(terminator_location == 0)
          do_crc_check <=#TP get_terminator_d2;
        else 
          do_crc_check <=#TP wait_crc_check & (bytes_cnt==1);
   end
 
   wire[31:0] crc_from_8;
   CRC32_D8  crc8(.DATA_IN(CRC_DATA_TMP), .CLK(rxclk), .RESET(reset), .START(crc_8_en), .LOAD(~crc_8_en), .CRC_IN(crc_from_64), .CRC_OUT(crc_from_8)); 

   ////////////////////////////////////////////////////////////////////////////////////////////
   // CRC check
   ////////////////////////////////////////////////////////////////////////////////////////////
   wire crc_check_valid, crc_check_invalid;

   assign crc_check_valid  = wait_crc_check & do_crc_check & (crc_from_8==32'hc704dd7b);
   assign crc_check_invalid = wait_crc_check & do_crc_check  & (crc_from_8!=32'hc704dd7b);

endmodule
