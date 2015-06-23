//////////////////////////////////////////////////////////////////////
////                                                              ////
//// MODULE NAME: receive engine                                  ////
////                                                              ////
//// DESCRIPTION: Receive Engine Top Level for the 10 Gigabit     ////
////     Ethernet MAC.                                            ////
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
// Revision 1.6  2006/06/16 06:39:59  fisher5090
// no message
//
// Revision 1.5  2006/06/16 06:36:28  Zheng Cao
// no message
//
// Revision 1.4  2006/06/12 10:02:19  Zheng Cao
// change rxd_in, rxc_in and rxclk_in signals'name to xgmii_rxd, xgmii_rxc and xgmii_rxclk
//
// Revision 1.3  2006/06/11 12:15:11  Zheng Cao
// no message
//
// Revision 1.1  2005/12/25 16:43:10  Zheng Cao
// No flow control included
// 
//
//////////////////////////////////////////////////////////////////////

`include "timescale.v"
`include "xgiga_define.v"

module rxReceiveEngine(xgmii_rxclk, rxclk_2x, reset_in, xgmii_rxd, xgmii_rxc, rxStatRegPlus,
                       cfgRxRegData_in, rx_data, rx_data_valid, rx_good_frame, rxclk_out,
                       rx_bad_frame, rxCfgofRS, rxTxLinkFault);//, fcTxPauseData, fcTxPauseValid);
    input xgmii_rxclk; //Input clock of receive engine
    input rxclk_2x;
    input reset_in; //Globle reset of receive engine
    input [31:0] xgmii_rxd; //XGMII RXD
    input [3:0] xgmii_rxc;  //XGMII RXC
    output [17:0] rxStatRegPlus; //Signals for statistics	
    input [64:0] cfgRxRegData_in; //Signals for configuration
    output [63:0] rx_data; //Received data sent to upper layer
    output [7:0] rx_data_valid; //Receive data valid indicator
    output rx_good_frame; //Indicate that a good frame has been received
    output rx_bad_frame; //Indicate that a bad frame has been received
    output[2:0] rxCfgofRS; //
    output [1:0] rxTxLinkFault;
    output rxclk_out;
//  output [31:0] fcTxPauseData;
//  output fcTxPauseValid;

    parameter TP =1;

    wire rxclk;
    wire rxclk_180;
    wire locked;
    wire reset_dcm;
    wire reset;

    reg [47:0]MAC_Addr;	//MAC Address used in receiving control frame.
    reg      vlan_enable; //VLAN Enable
    reg      recv_enable; //Receiver Enable
    reg      inband_fcs;	//In-band FCS Enable, when this bit is '1', the MAC will pass FCS up to client
    reg      jumbo_enable;//Jumbo Frame Enable
    reg      recv_rst;		//Receiver reset

    wire start_da, start_lt;
    wire tagged_frame;
    wire pause_frame;
    wire [47:0] da_addr;
//  wire [15:0] lt_data;
    wire [`COUNTER_WIDTH-1:0] frame_cnt;
    wire [2:0]  terminator_location;
    wire get_sfd,get_error_code,get_terminator, get_terminator_d1;
    wire receiving;
    wire receiving_d1,receiving_d2;

 
    wire length_error;
    wire large_error;
    wire small_error;
    wire padded_frame;
    wire length_65_127;
    wire length_128_255;
    wire length_256_511;
    wire length_512_1023;
    wire length_1024_max;
    wire jumbo_frame;

    wire local_invalid;
    wire broad_valid;
    wire multi_valid;

    wire good_frame_get, bad_frame_get;
    wire wait_crc_check;

    wire crc_check_valid;
    wire crc_check_invalid;
    wire check_reset;

    wire [1:0]link_fault;

    //////////////////////////////////////////
    // Input Registers
    //////////////////////////////////////////
 
    wire [63:0] rxd64;
    wire [63:0] CRC_DATA;
    wire [7:0] rxc8;

    assign rxTxLinkFault = link_fault;
    // assign fcTxPauseValid = pause_frame;
 
 
    //////////////////////////////////////////
    // Read Receiver Configuration Word
    //////////////////////////////////////////
 
    reg[52:0] cfgRxRegData;
    always@(posedge rxclk or posedge reset)begin
          if(reset) 
            cfgRxRegData <=#TP 0;
          else
            cfgRxRegData<=#TP cfgRxRegData_in;
    end
 
    always@(posedge rxclk or posedge reset)begin
          if(reset) begin
            MAC_Addr <= 0;
            vlan_enable <= 0;
            recv_enable <= 0;
            inband_fcs  <= 0;
            jumbo_enable <= 0;
            recv_rst <= 0;
          end
          else begin
            MAC_Addr <= cfgRxRegData[47:0];
            vlan_enable <= cfgRxRegData[48];
            recv_enable <= cfgRxRegData[49];
            inband_fcs  <= cfgRxRegData[50];
            jumbo_enable <= cfgRxRegData[51];
            recv_rst <= cfgRxRegData[52];
          end
    end 
    //////////////////////////////////////////////////
    // Used to count number of received frames(G&B)
    //////////////////////////////////////////////////
    reg[7:0] cnt;
    reg cnt_en;
    always@(posedge rxclk or posedge reset) begin
         if (reset) 
           cnt_en <=0;
         else if(get_sfd)			 
           cnt_en <=1;
         else if(rx_bad_frame|rx_good_frame)
           cnt_en <=0;
         else
           cnt_en <=cnt_en;
    end

    always@(posedge rxclk or posedge reset) begin
          if (reset)
             cnt <=0;
          else if(cnt_en)
             cnt<=cnt + 1;
          else 
             cnt <=0;
    end 
   
   /////////////////////////////////////////
   // Reset signals
   /////////////////////////////////////////
   assign  reset_dcm = reset_in | recv_rst;
   assign  reset = ~locked;
  
   /////////////////////////////////////////
   // Write Configuration Words	of RS 
   /////////////////////////////////////////

   assign rxCfgofRS[0] = ~link_fault[0] & link_fault[1]; //get local fault
   assign rxCfgofRS[1] = link_fault[0] & link_fault[1];  //get remote fault
   assign rxCfgofRS[2] = locked;  //Receive DCM locked
   
   ////////////////////////////////////////
   // Signals for Pause Operation
   ////////////////////////////////////////
   assign fcTxPauseValid = pause_frame;
// assign fcTxPauseData = {16{1'b0},rxd64[15:0]};

   ////////////////////////////////////////
   // Receive Clock Generator
   //////////////////////////////////////// 
   assign rxclk_out = rxclk;
   rxClkgen rxclk_gen(.rxclk_in(xgmii_rxclk),
                .reset(reset_dcm),
                .rxclk(rxclk),    // system clock
                .rxclk_180(rxclk_180), //reversed clock
                .locked(locked)
                 );
 
   //////////////////////////////////////
   // Rx Engine DataPath
   //////////////////////////////////////
   rxDataPath datapath_main(.rxclk(rxclk), .reset(reset), .rxd64(rxd64), .rxc8(rxc8), .inband_fcs(inband_fcs), .receiving(receiving), 
                            .start_da(start_da), .start_lt(start_lt), .wait_crc_check(wait_crc_check), .get_sfd(get_sfd), 
                             .get_terminator(get_terminator), .get_error_code(get_error_code), .tagged_frame(tagged_frame), .pause_frame(pause_frame),
                    .da_addr(da_addr), .terminator_location(terminator_location), .CRC_DATA(CRC_DATA), .rx_data_valid(rx_data_valid), 
                    .rx_data(rx_data), .get_terminator_d1(get_terminator_d1),.bad_frame_get(bad_frame_get),.good_frame_get(good_frame_get),
                    .check_reset(check_reset),.rx_good_frame(rx_good_frame),.rx_bad_frame(rx_bad_frame));//,.fcTxPauseData(fcTxPauseData));
 
   //////////////////////////////////////
   // Destination Address Checker
   //////////////////////////////////////

   rxDAchecker  dachecker(.rxclk(rxclk), .reset(reset), .local_invalid(local_invalid), .broad_valid(broad_valid), .multi_valid(multi_valid), .MAC_Addr(MAC_Addr),
                          .da_addr(da_addr));

   /////////////////////////////////////
   // Length/Type field checker
   /////////////////////////////////////

   rxLenTypChecker lenchecker(.rxclk(rxclk), .reset(reset), .get_terminator(get_terminator), .terminator_location(terminator_location), 
                     .jumbo_enable(jumbo_enable), .tagged_frame(tagged_frame), .frame_cnt(frame_cnt), .vlan_enable(vlan_enable),
                     .length_error(length_error), .large_error(large_error),.small_error(small_error), .padded_frame(padded_frame),
                     .length_65_127(length_65_127), .length_128_255(length_128_255), .length_256_511(length_256_511), .length_512_1023(length_512_1023), 
                          .length_1024_max(length_1024_max), .jumbo_frame(jumbo_frame)
 ); 

   /////////////////////////////////////
   // Counters used in Receive Engine
   /////////////////////////////////////

    rxNumCounter counters(.rxclk(rxclk), .reset(reset), .receiving(receiving), .frame_cnt(frame_cnt));
 
   /////////////////////////////////////
   // State Machine in Receive Process
   /////////////////////////////////////

    rxStateMachine statemachine(.rxclk(rxclk), .reset(reset), .recv_enable(recv_enable), .get_sfd(get_sfd), .local_invalid(local_invalid), 
                                .length_error(length_error), .crc_check_valid(crc_check_valid), .crc_check_invalid(crc_check_invalid), 
                               .start_da(start_da), .start_lt(start_lt), .receiving(receiving),.good_frame_get(good_frame_get),
                               .bad_frame_get(bad_frame_get), .get_error_code(get_error_code), .wait_crc_check(wait_crc_check), .get_terminator(get_terminator),
                               .receiving_d1(receiving_d1),.check_reset(check_reset));

   /////////////////////////////////////
   // CRC Check module
   /////////////////////////////////////
   rxCRC crcmodule(.rxclk(rxclk), .reset(reset), .CRC_DATA(CRC_DATA), .get_terminator(get_terminator), .terminator_location(terminator_location),
                   .crc_check_invalid(crc_check_invalid), .crc_check_valid(crc_check_valid),.receiving(receiving),.receiving_d1(receiving_d1),
                   .get_terminator_d1(get_terminator_d1), .wait_crc_check(wait_crc_check),.get_error_code(get_error_code));
   /////////////////////////////////////
   // RS Layer
   /////////////////////////////////////
    rxRSLayer rx_rs(.rxclk(rxclk), .rxclk_180(rxclk_180), .rxclk_2x(rxclk_2x), .reset(reset), .link_fault(link_fault), .rxd64(rxd64), .rxc8(rxc8), .rxd_in(xgmii_rxd), .rxc_in(xgmii_rxc));
    
   /////////////////////////////////////
   // Statistic module
   /////////////////////////////////////
   rxStatModule rx_stat(.rxclk(rxclk),.reset(reset),.good_frame_get(good_frame_get), .large_error(large_error),.small_error(small_error), .crc_check_invalid(crc_check_invalid),
                 .receiving(receiving), .padded_frame(padded_frame), .pause_frame(pause_frame), .broad_valid(broad_valid), .multi_valid(multi_valid),
                 .length_65_127(length_65_127), .length_128_255(length_128_255), .length_256_511(length_256_511), .length_512_1023(length_512_1023), 
                 .length_1024_max(length_1024_max), .jumbo_frame(jumbo_frame),.get_error_code(get_error_code), .rxStatRegPlus(rxStatRegPlus));				   
endmodule
