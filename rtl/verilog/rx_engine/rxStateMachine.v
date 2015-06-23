//////////////////////////////////////////////////////////////////////
////                                                              ////
//// MODULE NAME: rxStateMachine                                  ////
////                                                              ////
//// DESCRIPTION: State Machine of Receive Engine.                ////
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

module rxStateMachine(rxclk, reset, recv_enable, get_sfd, local_invalid, length_error, crc_check_valid, crc_check_invalid, 
       start_da, start_lt, receiving, receiving_d1, good_frame_get, bad_frame_get, get_error_code, wait_crc_check,
       get_terminator,check_reset);
   
    input rxclk;
    input reset;
   
    input recv_enable;
 
    //PRE & SFD
    input get_sfd; // SFD has been received;
 
    //DA field 
    input local_invalid;// The Frame's DA field is not Local MAC;
 
    //Length/Type field
    input length_error;//
 
    //FCS field
   input get_terminator;//Indicate end of receiving FCS field;
   input crc_check_valid;//Indicate the frame passed CRC Check;
   input crc_check_invalid;//Indicate the frame failed in CRC Check;
   input get_error_code;
   
   input check_reset;
 
   //DA field
   output start_da;// Start to receive Destination Address;
   
   //Length/Type field
   output start_lt;// Start to receive Length/Type field;
 
    //Receive process control
   output receiving; //Rx Engine is working, not in IDLE state and Check state.
   output receiving_d1;
   output good_frame_get;// A good frame has been received;
   output bad_frame_get; // A bad frame has been received; 
   output wait_crc_check;// 
 
   parameter IDLE = 0, rxReceiveDA = 1, rxReceiveLT = 2, rxReceiveData = 4;
   parameter rxGetError = 8,	rxIFGWait = 16;
   parameter TP =1;

   wire    start_da;
   wire    start_lt;
   wire    receiving;
   reg     good_frame_get;
   reg     bad_frame_get;
   
   reg[4:0] rxstate, rxstate_next;

   always@(rxstate, get_sfd, local_invalid, recv_enable,
           get_error_code, length_error, get_terminator, reset)begin
         if (reset) begin
            rxstate_next <=#TP IDLE;
         end
         else begin	 
             case (rxstate)
                 IDLE: begin //5'b00000;
                     if (get_sfd && recv_enable)
                       rxstate_next <=#TP rxReceiveDA;
                     else
                       rxstate_next <=#TP IDLE;
                 end
                 rxReceiveDA: begin //5'b00001  
                     rxstate_next <=#TP rxReceiveLT;
                 end
                 rxReceiveLT: begin //5'b00010
                     rxstate_next <=#TP rxReceiveData;
                 end
                 rxReceiveData: begin //5'b00100
                     if (local_invalid |length_error| get_error_code) 
                       rxstate_next <=#TP rxGetError;
                     else if (get_terminator)
                       rxstate_next <=#TP rxIFGWait;
                     else
                       rxstate_next <=#TP rxReceiveData;
                 end
                 rxGetError: begin //5'b01000
                     if (get_sfd && recv_enable)
                       rxstate_next <=#TP rxReceiveDA;
                     else
                       rxstate_next <=#TP IDLE;
                 end
                 rxIFGWait : begin //5'b10000;
                     if (get_sfd && recv_enable)
                       rxstate_next <=#TP rxReceiveDA;
                     else
                       rxstate_next <=#TP IDLE;
                 end
             endcase
         end
    end

    always@(posedge rxclk or posedge reset) begin
         if (reset)
           rxstate <=#TP IDLE;
         else
           rxstate <=#TP rxstate_next;
    end

    assign start_da = rxstate[0];
    assign start_lt = rxstate[1];
    assign receiving = rxstate[2] | rxstate[1] | rxstate[0]; // in DA,LT,DATA status
 
    reg receiving_d1;
    always@(posedge rxclk or posedge reset) begin
         if (reset) begin
           receiving_d1<=#TP 0;
         end
         else begin
           receiving_d1<=#TP receiving;
         end
    end
 
    reg  wait_crc_check; 
    always@(posedge rxclk or posedge reset) begin
         if (reset)
           wait_crc_check <=#TP 0;
         else if (rxstate[4])
           wait_crc_check <=#TP 1'b1;
         else if (crc_check_valid || crc_check_invalid||length_error)
           wait_crc_check <=#TP 1'b0;
         else
           wait_crc_check <=#TP wait_crc_check;
    end

    always@(posedge rxclk or posedge reset)begin
         if (reset)	begin
           bad_frame_get <=#TP 0;
           good_frame_get <=#TP 0;
         end
         else if(rxstate[3] || crc_check_invalid || length_error)begin
           bad_frame_get <=#TP 1'b1;
           good_frame_get <=#TP 1'b0;
         end
         else if (crc_check_valid)begin 
           good_frame_get <=#TP 1'b1;
           bad_frame_get <=#TP 1'b0;
         end 
         else if (check_reset)begin
           good_frame_get <=#TP 1'b0;
           bad_frame_get <=#TP 1'b0;
         end 
    end
endmodule
