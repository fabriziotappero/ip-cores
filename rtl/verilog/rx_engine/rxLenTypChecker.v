//////////////////////////////////////////////////////////////////////
////                                                              ////
//// MODULE NAME: Frame Length Checker                            ////
////                                                              ////
//// DESCRIPTION: Frame Length Checker of  10 Gigabit             ////
////     Ethernet MAC. Many statistics are implemented            ////
////     here.                                                    ////
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
// Revision 1.1.1.1  2006/05/31 05:59:42  Zheng Cao
// first version
//
// Revision 1.1  2005/12/25 16:43:10  Zheng Cao
// 
// 
//
//////////////////////////////////////////////////////////////////////

`include "timescale.v"
`include "xgiga_define.v"

module rxLenTypChecker(rxclk, reset, get_terminator, terminator_location, jumbo_enable, tagged_frame, 
       frame_cnt, vlan_enable,length_error,large_error, small_error, padded_frame, length_65_127, 
       length_128_255, length_256_511, length_512_1023, length_1024_max,jumbo_frame);
     
    input  rxclk;
    input  reset;
    input  jumbo_enable; //Enable jumbo frame recieving
    input  vlan_enable;  //VLAN mode enable bit
    input  tagged_frame;	 //number of 64bits DATA field of tagged frame contains
    input  get_terminator;
    input[`COUNTER_WIDTH-1:0] frame_cnt; 
    input[2:0] terminator_location;

    output length_error;
    output large_error;
    output small_error;
    output padded_frame;
    output length_65_127;
    output length_128_255;
    output length_256_511;
    output length_512_1023;
    output length_1024_max;
    output jumbo_frame;
 
    parameter TP =1 ;

    reg [2:0]location_reg;
    always@(posedge rxclk or posedge reset)begin
         if (reset) 
           location_reg <=#TP 0;
         else if(get_terminator)
           location_reg <=#TP terminator_location;
         else 
           location_reg <=#TP location_reg;
         end

    reg large_error;
    always@(posedge rxclk or posedge reset)begin
         if(reset) 
           large_error <=#TP 1'b0;
         else if(tagged_frame & vlan_enable) begin
             if ((frame_cnt == `MAX_TAG_LENGTH) & (location_reg > `MAX_TAG_BITS_MORE))
                large_error <=#TP 1'b1;
             else if ((frame_cnt > `MAX_TAG_LENGTH) & ~jumbo_enable)
                large_error <=#TP 1'b1;
             else if(frame_cnt > `MAX_JUMBO_LENGTH)
                large_error <=#TP 1'b1;
             else
                large_error <=#TP 1'b0;
         end
         else begin
             if ((frame_cnt == `MAX_VALID_LENGTH) & (location_reg > `MAX_VALID_BITS_MORE))
               large_error <=#TP 1'b1;
             else if((frame_cnt > `MAX_VALID_LENGTH) & ~jumbo_enable) 
               large_error <=#TP 1'b1;
             else if(frame_cnt > `MAX_JUMBO_LENGTH)
               large_error <=#TP 1'b1;
             else
               large_error <=#TP 1'b0;
         end
    end

    reg small_error;
    always@(posedge rxclk or posedge reset) begin
         if(reset)
           small_error <=#TP 0;
    else 
           small_error <=#TP get_terminator & (frame_cnt< `MIN_VALID_LENGTH);
    end

    wire length_error;
    assign length_error = small_error | large_error;
     
    /////////////////////////////////////////////////
    // Statistic signals
    /////////////////////////////////////////////////    
 
    ///////////////////////////////////
    // 64byte frame received OK
    ///////////////////////////////////

    reg padded_frame;
    always@(posedge rxclk or posedge reset) begin
          if(reset)
            padded_frame <=#TP 0;
          else
            padded_frame <=#TP get_terminator & (frame_cnt==`MIN_VALID_LENGTH);
    end

    ///////////////////////////////////
    // 65-127 byte Frame Received OK
    ///////////////////////////////////

    reg length_65_127;
    always@(posedge rxclk or posedge reset) begin
          if(reset)
            length_65_127 <=#TP 0;
          else
            length_65_127 <=#TP get_terminator & (frame_cnt>`MIN_VALID_LENGTH) & (frame_cnt <=127);
    end

    ///////////////////////////////////
    // 128-255 byte Frame Received OK
    ///////////////////////////////////

    reg length_128_255;
    always@(posedge rxclk or posedge reset) begin
         if(reset)
           length_128_255 <=#TP 0;
         else
           length_128_255 <=#TP get_terminator & (frame_cnt>128) & (frame_cnt <=255);
    end

    ///////////////////////////////////
    // 256-511 byte Frame Received OK
    ///////////////////////////////////

    reg length_256_511;
    always@(posedge rxclk or posedge reset) begin
         if(reset)
           length_256_511 <=#TP 0;
         else
           length_256_511 <=#TP get_terminator & (frame_cnt>256) & (frame_cnt <=511);
    end

    ///////////////////////////////////
    // 512-1023 byte Frame Received OK
    ///////////////////////////////////

    reg length_512_1023;
    always@(posedge rxclk or posedge reset) begin
         if(reset)
           length_512_1023 <=#TP 0;
         else
           length_512_1023 <=#TP get_terminator & (frame_cnt>512) & (frame_cnt <=1023);
    end

    ///////////////////////////////////
    // 1024-max byte Frame Received OK
    ///////////////////////////////////

    reg length_1024_max;
    always@(posedge rxclk or posedge reset) begin
         if(reset)
           length_1024_max <=#TP 0;
         else
           length_1024_max <=#TP get_terminator & (frame_cnt>1024) & (frame_cnt <=`MAX_VALID_LENGTH);
    end

    //////////////////////////////////////////////
    // Count for Control Frames Received OK
    //////////////////////////////////////////////
    //how to indicate a control frame(not clearly specificated in 802.3

    ///////////////////////////////////////////////
    // Count for Oversize Frames Received OK
    ///////////////////////////////////////////////
 
    reg jumbo_frame;
    always@(posedge rxclk or posedge reset) begin
         if(reset)
           jumbo_frame <=#TP 0;
         else
           jumbo_frame <=#TP get_terminator & jumbo_enable & (frame_cnt > `MAX_VALID_LENGTH) & (frame_cnt < `MAX_JUMBO_LENGTH);
    end

endmodule
