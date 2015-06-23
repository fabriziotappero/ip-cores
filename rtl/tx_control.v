//////////////////////////////////////////////////////////////////////
////                                                              ////
////  This file is part of the "10GE LL MAC" project              ////
////  http://www.opencores.org/cores/xge_ll_mac/                  ////
////                                                              ////
////  This project is derived from the "10GE MAC" project of      ////
////  A. Tanguay (antanguay@opencores.org) by Andreas Peters      ////
////  for his Diploma Thesis at the University of Heidelberg.     ////
////  The Thesis was supervised by Christian Leber                ////
////                                                              ////
////  Author(s):                                                  ////
////      - Andreas Peters                                        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008-2012 AUTHORS. All rights reserved.        ////
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

//`include "technology.h"
`include "oc_mac.h"

`default_nettype none

module tx_control(
		// Inputs
		input wire		clk,
		input wire		res_n,
		input wire		tx_start,
		input wire [63:0]	tx_data,
		input wire [7:0]	tx_data_valid,
		// Outputs

		output reg [63:0]	txdfifo_wdata,
		output reg [7:0]	txdfifo_wstatus,
		output reg		tx_ack);


reg [3:0]	frame_cnt;

// Shift register for EOP
reg [63:0]	txdfifo_wdata_prev;
reg [7:0]	txdfifo_wstatus_prev;
reg [2:0]	current_state;

parameter [2:0]
		SM_IDLE = 3'd0,
		SM_START = 3'd1,
		SM_TX = 3'd2;

// Full status if data fifo is almost full.
// Current packet can complete transfer since data input rate
// matches output rate. But next packet must wait for more headroom.
// 

//SM!!

`ifdef ASYNC_RES
always @(posedge clk or negedge res_n) `else
always @(posedge clk) `endif
begin
	if (res_n == 1'b0) begin
		txdfifo_wdata <= 64'b0;
		txdfifo_wstatus <= 8'b0;
		frame_cnt <= 4'b0;
		current_state <= 3'b0;
		txdfifo_wdata_prev <= 64'b0;
		txdfifo_wstatus_prev <= 8'b0;
		tx_ack <= 1'b0;
		

	end
	else begin

		txdfifo_wdata <= txdfifo_wdata_prev;
		txdfifo_wdata_prev <= tx_data;
		case (current_state)
			
		SM_IDLE: begin

			txdfifo_wstatus_prev <= 8'b0;
			txdfifo_wstatus <= txdfifo_wstatus_prev;
			if(tx_start == 1'b1) begin
				current_state <= SM_START;
			end
			else begin
				current_state <= SM_IDLE;
				if (frame_cnt != 4'b0)
					frame_cnt <= frame_cnt - 4'b1;
			end

		end
		SM_START: begin

			if (frame_cnt == 4'd0) begin
				tx_ack <= 1'b1;
				current_state <= SM_TX;
				txdfifo_wstatus <= txdfifo_wstatus_prev;
				frame_cnt <= 4'd9;
			end
			else begin
				tx_ack <= 1'b0;
				current_state <= SM_START;
				txdfifo_wstatus_prev <= 8'b0;
				txdfifo_wstatus <= txdfifo_wstatus_prev;
				frame_cnt <= frame_cnt - 4'b1;
			end
		end
		SM_TX: begin
			
			if(frame_cnt != 4'd0) begin
				frame_cnt <= frame_cnt - 4'b1;
			end
			if(tx_ack == 1'b1) begin
				txdfifo_wstatus_prev <= `TXSTATUS_START;
				tx_ack <= 1'b0;
				txdfifo_wstatus <= txdfifo_wstatus_prev;
			end 
			else if (tx_data_valid == 8'hFF) begin
				txdfifo_wstatus <= txdfifo_wstatus_prev;
				txdfifo_wstatus_prev <= `TXSTATUS_NONE;
				txdfifo_wstatus <= txdfifo_wstatus_prev;
				current_state <= SM_TX;
			end
			else if (tx_data_valid == 8'b00) begin	
				txdfifo_wstatus <= `TXSTATUS_END;
				txdfifo_wstatus_prev <= 8'b0;
				current_state <= SM_IDLE;
			end
			else begin
				case (tx_data_valid)
					8'b11111111:	txdfifo_wstatus_prev[2:0]	<= 3'h0; // all lanes with valid data(implementation error, not working)
					8'b01111111:	txdfifo_wstatus_prev[2:0]	<= 3'h7;
					8'b00111111:	txdfifo_wstatus_prev[2:0]	<= 3'h6;
					8'b00011111:	txdfifo_wstatus_prev[2:0]	<= 3'h5;
					8'b00001111:	txdfifo_wstatus_prev[2:0]	<= 3'h4;
					8'b00000111:	txdfifo_wstatus_prev[2:0]	<= 3'h3;
					8'b00000011:	txdfifo_wstatus_prev[2:0]	<= 3'h2;
					8'b00000001:	txdfifo_wstatus_prev[2:0]	<= 3'h1;
					8'b00000000:	txdfifo_wstatus_prev[2:0]	<= 3'h0; // not defined in OC
					default:	txdfifo_wstatus_prev[2:0]	<= 3'h0; // unsure.
				endcase

				txdfifo_wstatus_prev[`TXSTATUS_EOP] <= 1'b1;
				txdfifo_wstatus_prev[`TXSTATUS_VALID] <= 1'b1;
				txdfifo_wstatus_prev[`TXSTATUS_SOP] <= 1'b0;
				txdfifo_wstatus_prev[5] <= 1'b0;
				txdfifo_wstatus_prev[3] <= 1'b0;

				txdfifo_wstatus <= txdfifo_wstatus_prev;
				current_state <= SM_IDLE;
			end
		end
			
		endcase//- SM 
		
	end
end
		
endmodule
`default_nettype wire
