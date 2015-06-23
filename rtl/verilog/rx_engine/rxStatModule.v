//////////////////////////////////////////////////////////////////////
////                                                              ////
//// MODULE NAME: rxStatModule                                    ////
////                                                              ////
//// DESCRIPTION: Generate signals for statistics. These signals  ////
////            will be used in Management Module.                ////
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
// Revision 1.3  2006/06/11 12:15:23  Zheng Cao
// no message
//
// Revision 1.1  2005/12/25 16:43:10  Zheng Cao
// 
// 
//
//////////////////////////////////////////////////////////////////////


`include "timescale.v"
`include "xgiga_define.v"

module rxStatModule(rxclk, reset, good_frame_get,crc_check_invalid, large_error, small_error,
                    receiving, padded_frame, pause_frame, broad_valid, multi_valid,
                    length_65_127, length_128_255, length_256_511, length_512_1023, length_1024_max,
                    jumbo_frame, get_error_code, rxStatRegPlus);

   input rxclk;
   input reset;
   input good_frame_get; 
   input large_error;
   input small_error;
   input crc_check_invalid;
   input receiving;
   input padded_frame;
   input pause_frame;
   input broad_valid;
   input multi_valid;
   input length_65_127;
   input length_128_255;
   input length_256_511;
   input length_512_1023;
   input length_1024_max;
   input jumbo_frame;
   input get_error_code;
   output [17:0] rxStatRegPlus;

   parameter TP =1;

   wire[17:0] rxStatRegPlus_tmp;

   ////////////////////////////////////////////
   // Count for Frames Received OK
   ////////////////////////////////////////////
   assign rxStatRegPlus_tmp[0] = good_frame_get;

   ////////////////////////////////////////////
   // Count for FCS check error
   ////////////////////////////////////////////
   assign rxStatRegPlus_tmp[1] = crc_check_invalid;

   ////////////////////////////////////////////
   // Count for BroadCast Frame Received OK
   ////////////////////////////////////////////
   assign rxStatRegPlus_tmp[2] = broad_valid & good_frame_get;

   /////////////////////////////////////////////
   // Count for Multicast Frame Received OK
   /////////////////////////////////////////////
   assign rxStatRegPlus_tmp[3] = multi_valid & good_frame_get;

   ////////////////////////////////////////////
   // Count for 64 byte Frame Received OK
   ////////////////////////////////////////////
   assign rxStatRegPlus_tmp[4] = padded_frame & good_frame_get;

   ////////////////////////////////////////////
   // Count for 65-127 byte Frames Received OK
   ////////////////////////////////////////////
   assign rxStatRegPlus_tmp[5] = length_65_127 & good_frame_get;

   ////////////////////////////////////////////
   // Count for 128-255 byte Frames Received OK
   ////////////////////////////////////////////
   assign rxStatRegPlus_tmp[6] = length_128_255 & good_frame_get;

   ////////////////////////////////////////////
   // Count for 256-511 byte Frames Received OK
   ////////////////////////////////////////////
   assign rxStatRegPlus_tmp[7] = length_256_511 & good_frame_get;

   //////////////////////////////////////////////
   // Count for 512-1023 byte Frames Received OK
   //////////////////////////////////////////////
   assign rxStatRegPlus_tmp[8] = length_512_1023 & good_frame_get;

   //////////////////////////////////////////////
   // Count for 1024-1518 byte Frames Received OK
   //////////////////////////////////////////////
   assign rxStatRegPlus_tmp[9] = length_1024_max & good_frame_get;

   //////////////////////////////////////////////
   // Count for Control Frames Received OK
   //////////////////////////////////////////////
   assign rxStatRegPlus_tmp[10] = pause_frame & good_frame_get;

   //////////////////////////////////////////////
   // Count for Length/Type Out of Range
   //////////////////////////////////////////////
   assign rxStatRegPlus_tmp[11] = large_error;

   //////////////////////////////////////////////
   // Count for Pause Frames Received OK
   //////////////////////////////////////////////
   assign rxStatRegPlus_tmp[12] = pause_frame & good_frame_get;

   /////////////////////////////////////////////////////////////
   // Count for Control Frames Received with Unsupported Opcode.
   /////////////////////////////////////////////////////////////
    assign rxStatRegPlus_tmp[13] = 0;//pause_frame & good_frame_get;

   ///////////////////////////////////////////////
   // Count for Oversize Frames Received OK
   ///////////////////////////////////////////////
   assign rxStatRegPlus_tmp[14] = jumbo_frame & good_frame_get;

   ///////////////////////////////////////////////
   // Count for Undersized Frames Received
   ///////////////////////////////////////////////
   assign rxStatRegPlus_tmp[15] = small_error;

   ///////////////////////////////////////////////
   // Count for Fragment Frames Received
   ///////////////////////////////////////////////
   assign rxStatRegPlus_tmp[16] = receiving & get_error_code;

   ///////////////////////////////////////////////
   // Count for Number of Bytes Received
   ///////////////////////////////////////////////
   assign rxStatRegPlus_tmp[17] = receiving;

   reg[17:0] rxStatRegPlus;
   always@(posedge rxclk or posedge reset) begin
         if(reset)
           rxStatRegPlus <=#TP 0;
         else
           rxStatRegPlus <=#TP rxStatRegPlus_tmp;
   end

endmodule
