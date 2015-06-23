//////////////////////////////////////////////////////////////////////
////                                                              ////
//// MODULE NAME: Data Path of Receive Module                     ////
////                                                              ////
//// DESCRIPTION: Data path of Receive Engine of 10 Gigabit       ////
////     Ethernet MAC. Used to recognize every field of a         ////
////     frame, including SOF, EOF, Length, Destination Addr      ////
////     , Source Addr and Data field.                            ////
////                                                              ////
//// This file is part of the 10 Gigabit Ethernet IP core project ////
//// http://www.opencores.org/projects/ethmac10g/                 ////
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
// Revision 1.6  2006/06/16 06:36:28  fisher5090
// no message
//
// Revision 1.5  2006/06/12 18:58:36  Zheng Cao
// no message
//
// Revision 1.4  2006/06/12 18:53:02  Zheng Cao
// remove pad function added, using xilinx vp20 -6 as target FPGA, passes post place and route simulation
// 
// Revision 1.3  2006/06/12 04:11:19  Zheng Cao
// both inband fcs and no inband fcs are OK, no remove PAD function
// 
// Revision 1.1  2005/12/25 16:43:10  Zheng Cao
// 
// 
//
//////////////////////////////////////////////////////////////////////

`include "timescale.v"
`include "xgiga_define.v"

module rxDataPath(rxclk, reset, rxd64, rxc8, inband_fcs, receiving, start_da, start_lt, wait_crc_check, get_sfd, 
                  get_terminator, get_error_code, tagged_frame, pause_frame, da_addr, terminator_location, CRC_DATA, 
                  rx_data_valid, rx_data,get_terminator_d1, bad_frame_get, good_frame_get,check_reset,rx_good_frame,rx_bad_frame);
//                fcTxPauseData);
    input rxclk;
    input reset;
    input [63:0] rxd64;
    input [7:0] rxc8;
    input inband_fcs;
    input receiving;
    input start_da;
    input start_lt;
    input wait_crc_check;	 
    input get_terminator_d1;
    input bad_frame_get;
    input good_frame_get;
 
    output get_sfd;
    output get_terminator; //get T indicator
    output get_error_code; //get Error indicator
    output tagged_frame;
    output pause_frame;
    output[47:0] da_addr;
    output[2:0] terminator_location;
    output[63:0] CRC_DATA;
    output[7:0] rx_data_valid;
    output[63:0] rx_data;
    output check_reset;
    output rx_good_frame;
    output rx_bad_frame;
//  output [31:0]fcTxPauseData;
 
    parameter TP = 1;
    parameter IDLE = 0, READ = 2, WAIT_TMP = 3, WAIT = 1;
 
    //////////////////////////////////////////////
    // Pipe Line Stage
    //////////////////////////////////////////////
    reg [63:0] rxd64_d1,rxd64_d2,rxd64_d3,CRC_DATA;
    reg [7:0] rxc8_d1, rxc8_d2, rxc8_d3;
    reg receiving_d1, receiving_d2;
    reg wait_crc_check_d1;
 
 // assign fcTxPauseData = rxd64_d1[31:0];
 // Data pipeline
    always@(posedge rxclk or posedge reset) begin
         if (reset) begin
            rxd64_d1<=#TP 0;
            rxd64_d2<=#TP 0;
            rxd64_d3<=#TP 0;
            CRC_DATA<=0;
         end
         else begin
            rxd64_d1<=#TP rxd64;
            rxd64_d2<=#TP rxd64_d1;
            rxd64_d3<=#TP rxd64_d2;
            CRC_DATA <={rxd64_d2[0],rxd64_d2[1],rxd64_d2[2],rxd64_d2[3],rxd64_d2[4],rxd64_d2[5],rxd64_d2[6],rxd64_d2[7],
                        rxd64_d2[8],rxd64_d2[9],rxd64_d2[10],rxd64_d2[11],rxd64_d2[12],rxd64_d2[13],rxd64_d2[14],rxd64_d2[15],
                        rxd64_d2[16],rxd64_d2[17],rxd64_d2[18],rxd64_d2[19],rxd64_d2[20],rxd64_d2[21],rxd64_d2[22],rxd64_d2[23],
                        rxd64_d2[24],rxd64_d2[25],rxd64_d2[26],rxd64_d2[27],rxd64_d2[28],rxd64_d2[29],rxd64_d2[30],rxd64_d2[31],
                        rxd64_d2[32],rxd64_d2[33],rxd64_d2[34],rxd64_d2[35],rxd64_d2[36],rxd64_d2[37],rxd64_d2[38],rxd64_d2[39],
                        rxd64_d2[40],rxd64_d2[41],rxd64_d2[42],rxd64_d2[43],rxd64_d2[44],rxd64_d2[45],rxd64_d2[46],rxd64_d2[47],
                        rxd64_d2[48],rxd64_d2[49],rxd64_d2[50],rxd64_d2[51],rxd64_d2[52],rxd64_d2[53],rxd64_d2[54],rxd64_d2[55],
                        rxd64_d2[56],rxd64_d2[57],rxd64_d2[58],rxd64_d2[59],rxd64_d2[60],rxd64_d2[61],rxd64_d2[62],rxd64_d2[63]};
         end
    end
    //control pipeline
    always@(posedge rxclk or posedge reset)begin
         if (reset)	begin		
            rxc8_d1<=#TP 0;
            rxc8_d2<=#TP 0;
            rxc8_d3<=#TP 0;      
         end
         else begin
            rxc8_d1<=#TP rxc8;
            rxc8_d2<=#TP rxc8_d1;
            rxc8_d3<=#TP rxc8_d2;
         end
    end

    always @(posedge rxclk or posedge reset)begin
         if (reset) begin
            receiving_d1 <=#TP 0;
            receiving_d2 <=#TP 0;
            wait_crc_check_d1 <=#TP 0;
         end
         else	begin
            receiving_d1 <=#TP receiving;
            receiving_d2 <=#TP receiving_d1;
            wait_crc_check_d1 <=#TP wait_crc_check;
         end
    end
 
    ////////////////////////////////////////////
    // Frame analysis
    ////////////////////////////////////////////
    reg get_sfd; //get sfd indicator
    reg get_terminator; //get T indicator
    reg get_error_code; //get Error indicator
    reg[7:0] get_e_chk;
    reg[7:0] rxc_end_data; //seperate DATA with FCS
    reg [2:0]terminator_location; //for n*8bits(n<8), get n
    reg[47:0] da_addr; //get Desetination Address
    reg tagged_frame;  //Tagged frame indicator(type interpret)
    reg pause_frame;   //Pause frame indicator(type interpret)
 
    //1. SFD 
    always@(posedge rxclk or posedge reset) begin
         if (reset) 
           get_sfd <=#TP 0; 
         else
           get_sfd <=#TP (rxd64[7:0] ==`START) & (rxd64[63:56]== `SFD) & (rxc8 == 8'h01);
    end

    //2. EFD
    reg this_cycle; 
    // -----------------------------------------------
    //|  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  | 
    // -----------------------------------------------
    //|<-------- EFD -------->|<-------- EFD -------->|
    //|<-- this_cycle = '1' ->|<-- this_cycle = '0' ->|
 
    always@(posedge rxclk or posedge reset) begin
         if (reset) begin
            get_terminator <=#TP 0;
            terminator_location <=#TP 0; 
            this_cycle <=#TP 1'b0;
            rxc_end_data <=#TP 0;
         end
         else begin
            if (rxc8[0] & (rxd64[7:0]  ==`TERMINATE)) begin
               get_terminator <=#TP 1'b1;
               terminator_location <=#TP 0; 
               this_cycle <=#TP 1'b1;
               rxc_end_data <=#TP 8'b00001111;
            end   
            else if (rxc8[1] & (rxd64[15:8] ==`TERMINATE)) begin
               get_terminator <=#TP 1'b1;
               terminator_location <=#TP 1;
               this_cycle <=#TP 1'b1;
               rxc_end_data <=#TP 8'b00011111;
            end
            else if (rxc8[2] & (rxd64[23:16]==`TERMINATE)) begin
               get_terminator <=#TP 1'b1;	
               terminator_location <=#TP 2;
               this_cycle <=#TP 1'b1; 
               rxc_end_data <=#TP 8'b00111111;
            end
            else if (rxc8[3] & (rxd64[31:24]==`TERMINATE)) begin
               get_terminator <=#TP 1'b1;
               terminator_location <=#TP 3;
               this_cycle <=#TP 1'b1;
               rxc_end_data <=#TP 8'b01111111;
            end
            else if (rxc8[4] & (rxd64[39:32]==`TERMINATE)) begin
               get_terminator <=#TP 1'b1; 
               terminator_location <=#TP 4;	
               this_cycle <=#TP 1'b1;
               rxc_end_data <=#TP 8'b11111111;
            end
            else if (rxc8[5] & (rxd64[47:40]==`TERMINATE)) begin
               get_terminator <=#TP 1'b1; 
               terminator_location <=#TP 5;
               this_cycle <=#TP 1'b0;
               rxc_end_data <=#TP 8'b00000001;
            end
            else if (rxc8[6] & (rxd64[55:48]==`TERMINATE)) begin
               get_terminator <=#TP 1'b1;
               terminator_location <=#TP 6; 
               this_cycle <=#TP 1'b0;
               rxc_end_data <=#TP 8'b00000011;
            end
            else if (rxc8[7] & (rxd64[63:56]==`TERMINATE))begin
               get_terminator <=#TP 1'b1;
               terminator_location <=#TP 7;
               this_cycle <=#TP 1'b0;
               rxc_end_data <=#TP 8'b00000111;
            end
            else begin
               get_terminator <=#TP 1'b0;
               terminator_location <=#TP terminator_location; 
               this_cycle <=#TP this_cycle;
               rxc_end_data <=#TP rxc_end_data;
            end
        end
    end
 
    //3. Error Character
    always@(posedge rxclk or posedge reset) begin
          if (reset)
             get_e_chk <=#TP 0;
          else begin
             get_e_chk[0] <=#TP rxc8[0] & (rxd64[7:0]  ==`ERROR); 
             get_e_chk[1] <=#TP rxc8[1] & (rxd64[15:8] ==`ERROR);
             get_e_chk[2] <=#TP rxc8[2] & (rxd64[23:16]==`ERROR);
             get_e_chk[3] <=#TP rxc8[3] & (rxd64[31:24]==`ERROR);
             get_e_chk[4] <=#TP rxc8[4] & (rxd64[39:32]==`ERROR);
             get_e_chk[5] <=#TP rxc8[5] & (rxd64[47:40]==`ERROR);
             get_e_chk[6] <=#TP rxc8[6] & (rxd64[55:48]==`ERROR);
             get_e_chk[7] <=#TP rxc8[7] & (rxd64[63:56]==`ERROR);
          end
    end
 
    always@(posedge rxclk or posedge reset) begin
          if (reset) 
            get_error_code <=#TP 0;
          else
            get_error_code <=#TP receiving & (| get_e_chk);
    end
    
    //////////////////////////////////////
    // Get Destination Address
    //////////////////////////////////////
 
    always@(posedge rxclk or posedge reset)begin
         if (reset) 
           da_addr <=#TP 0;
         else if (start_da) 
           da_addr <=#TP rxd64_d1[47:0];
         else
           da_addr <=#TP da_addr;
    end

    //////////////////////////////////////
    // Get Length/Type Field
    //////////////////////////////////////

    reg[15:0] lt_data; 
    always@(posedge rxclk or posedge reset)begin
         if (reset) 
           lt_data <=#TP 0;
         else if (start_lt) 
           lt_data <=#TP {rxd64_d1[39:32], rxd64_d1[47:40]};
         else
           lt_data <=#TP lt_data;
    end
 
    reg[5:0] pad_integer;
    reg[5:0] pad_remain;
    always@(posedge rxclk or posedge reset) begin
         if (reset) begin
           pad_integer <=#TP 0;
           pad_remain <=#TP 0;
         end
         else begin
           pad_integer <=#TP (lt_data[5:0] - 2)>>3;
           pad_remain <=#TP lt_data[5:0] - 2;
         end
    end
    //Remove PAD counter
    reg[2:0] pad_cnt;
    always@(posedge rxclk or posedge reset) begin
         if (reset)
           pad_cnt <=#TP 0;
         else if(lt_data[5:0] == 1)
           pad_cnt <=#TP 1;
         else 
           pad_cnt <=#TP pad_integer[2:0] + 2;
    end

    reg [7:0] pad_last_rxc;   
    always@(posedge rxclk or posedge reset) begin
         if (reset)
           pad_last_rxc <=#TP 0;
         else if(lt_data[5:0] == 1)
           pad_last_rxc <=#TP 8'h7f;
         else begin
             case (pad_remain[2:0])
                0: pad_last_rxc <=#TP 8'h00;
                1: pad_last_rxc <=#TP 8'h01;
                2: pad_last_rxc <=#TP 8'h03;
                3: pad_last_rxc <=#TP 8'h07;
                4: pad_last_rxc <=#TP 8'h0f;
                5: pad_last_rxc <=#TP 8'h1f;
                6: pad_last_rxc <=#TP 8'h3f;
                7: pad_last_rxc <=#TP 8'h7f;
             endcase
       end
    end 
    
    reg pad_frame;
    always@(posedge rxclk or posedge reset) begin
          if (reset)
            pad_frame <=#TP 0;
          else if(~(lt_data[0]|lt_data[1]|lt_data[2]|lt_data[3]|lt_data[4]|lt_data[5]))
            pad_frame <=#TP 1'b0;
          else if(lt_data<46)
            pad_frame <=#TP 1'b1;
          else
            pad_frame <=#TP 1'b0;
    end 
 
    //tagged frame indicator
    always@(posedge rxclk or posedge reset) begin
          if (reset)
            tagged_frame <=#TP 1'b0;
          else if (start_lt)
            tagged_frame <=#TP (rxd64[63:32] == `TAG_SIGN); 
          else
            tagged_frame <=#TP tagged_frame;
    end
    //pause frame indicator
    always@(posedge rxclk or posedge reset) begin
          if (reset)
            pause_frame <=#TP 1'b0;
          else if (start_lt)
            pause_frame <=#TP (rxd64[47:32] == `PAUSE_SIGN); 
          else 
            pause_frame <=#TP 1'b0;
    end

    /////////////////////////////////////////////
    // Generate proper rxc to FIFO						
    /////////////////////////////////////////////

    reg [7:0]rxc_final;
    wire [7:0]rxc_fifo; //rxc send to fifo
    
    always@(posedge rxclk or posedge reset) begin
         if (reset)
           rxc_final <=#TP 0;
         else if (get_terminator & this_cycle)
           rxc_final <=#TP rxc_end_data;
         else if (get_terminator_d1 & ~this_cycle)
           rxc_final <=#TP rxc_end_data;
         else if (get_error_code)
           rxc_final <=#TP 0; 
         else if (receiving)
             rxc_final <=#TP `ALLONES8;
         else
             rxc_final <=#TP 0; 
    end 

    assign rxc_fifo = inband_fcs? ~rxc8_d3:rxc_final;
  
    ////////////////////////////////////////////////////////////////
    // FIFO management, to generate rx_good_frame/rx_bad_frame
    // after a frame has been totally received.
    ////////////////////////////////////////////////////////////////
    wire rxfifo_full;
    wire rxfifo_empty;
    wire fifo_wr_en;
    wire [63:0] rx_data_tmp;
    wire [7:0] rx_data_valid_tmp;  
 
    reg fifo_rd_en;
    reg[1:0] fifo_state;
    wire rx_good_frame;
    wire rx_bad_frame;
    reg check_reset;
    always@(posedge rxclk or posedge reset) begin
         if(reset) begin
           fifo_rd_en <=#TP 1'b0;
           fifo_state <=#TP IDLE;
           check_reset <=#TP 1'b0;
         end
         else
             case (fifo_state) 
                 IDLE: begin
                      check_reset <=#TP 1'b0;
                      fifo_state <=#TP IDLE;
                      fifo_rd_en <=#TP 1'b0;
                      if(~rxfifo_empty) begin  
                         fifo_rd_en <=#TP 1'b1;
                         fifo_state <=#TP WAIT_TMP;
                      end  
                 end
                 READ: begin
                      check_reset <=#TP 1'b0;
                      fifo_rd_en <=#TP 1'b1;
                      fifo_state <=#TP READ;
                      if(rx_data_valid_tmp!=8'hff) begin
                         fifo_state <=#TP WAIT;
                         fifo_rd_en <=#TP 1'b0;
                      end
                 end  
                 WAIT_TMP: begin
                      if(rx_data_valid_tmp == 8'hff)
                         fifo_state <=#TP READ;
                      else 
                         fifo_state <=#TP WAIT_TMP;
                 end  
                 WAIT: begin
                      fifo_state <=#TP WAIT;
                      check_reset <=#TP 1'b0;
                      fifo_rd_en <=#TP 1'b0;
                      if(bad_frame_get | good_frame_get)begin
                         fifo_state <=#TP IDLE;
                         check_reset <=#TP 1'b1;
                      end  
                 end
             endcase
    end
 
    reg[2:0] pad_cnt_reg;
    always@(posedge rxclk or posedge reset) begin
         if(reset)
           pad_cnt_reg <=#TP 0;
         else if((fifo_state == WAIT_TMP)& pad_frame & ~rxfifo_empty)
           pad_cnt_reg <=#TP pad_cnt;
         else if(pad_cnt_reg ==0)
           pad_cnt_reg <=#TP 0;
         else if(fifo_state[1])
           pad_cnt_reg <=#TP pad_cnt_reg-1;
         else
           pad_cnt_reg <=#TP 0;
    end
 
    reg[7:0] pad_rxc_reg;
    always@(posedge rxclk or posedge reset)begin
         if(reset)
           pad_rxc_reg <=#TP 0;
         else if((fifo_state == WAIT_TMP)& pad_frame & ~rxfifo_empty)
           pad_rxc_reg <=#TP pad_last_rxc;
         else
           pad_rxc_reg <=#TP pad_rxc_reg;
    end
 
    reg pad_frame_d1;
    always@(posedge rxclk or posedge reset) begin
         if(reset)
           pad_frame_d1<=#TP 1'b0;
         else if((fifo_state == WAIT_TMP)& pad_frame & ~rxfifo_empty)
           pad_frame_d1<=#TP 1'b1;
         else if(fifo_state == WAIT) 
           pad_frame_d1 <=#TP 1'b0;
         else
           pad_frame_d1 <=#TP pad_frame_d1; 
    end 
    
    assign rx_good_frame = good_frame_get & (fifo_state == WAIT);
    assign rx_bad_frame = bad_frame_get & (fifo_state == WAIT);
    
    assign fifo_wr_en = receiving_d2;
    
    defparam rxdatain.pWordWidth = 64;
    defparam rxdatain.pDepthWidth = 7;

    SwitchSyncFIFO rxdatain(
	.nReset(!reset),
	.iClk(rxclk),
	.iWEn(fifo_wr_en),
	.ivDataIn(rxd64_d3),
	.iREn(fifo_rd_en),
	.ovDataOut(rx_data_tmp),
	.qEmpty(rxfifo_empty),
	.qFull(rxfifo_full),
	.qvCount()
    );
    defparam rxcntrlin.pWordWidth = 8;
    defparam rxcntrlin.pDepthWidth = 7;

    SwitchSyncFIFO rxcntrlin(
	.nReset(!reset),
	.iClk(rxclk),
	.iWEn(fifo_wr_en),
	.ivDataIn(rxc_fifo),
	.iREn(fifo_rd_en),
	.ovDataOut(rx_data_valid_tmp),
	.qEmpty(),
	.qFull(),
	.qvCount()
    );
    reg [63:0] rx_data;
    always@(posedge rxclk or posedge reset) begin
         if (reset) begin
            rx_data <=#TP 0;
         end
         else begin
            rx_data <=#TP rx_data_tmp;
         end
    end
 
    reg [7:0] rx_data_valid;
    always@(posedge rxclk or posedge reset) begin
         if (reset)
            rx_data_valid <=#TP 0;
         else if(fifo_state[1] & pad_frame_d1)
            if(pad_cnt_reg==1)
               rx_data_valid <=#TP pad_rxc_reg;
            else if(pad_cnt_reg==0)
               rx_data_valid <=#TP 0;
            else
               rx_data_valid <=#TP rx_data_valid_tmp;  
         else if(fifo_state[1] & ~pad_frame_d1) 
            rx_data_valid <=#TP rx_data_valid_tmp;  
         else
            rx_data_valid <=#TP 0;
    end
 
endmodule
