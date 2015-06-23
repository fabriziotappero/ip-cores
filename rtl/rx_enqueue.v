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

`include "oc_mac.h"
`include "oc_mac_crc_func.h"

module rx_enqueue(
		input wire		clk,
		input wire		res_n,
		
		input wire [63:0]	xgmii_rxd,
		input wire [7:0]	xgmii_rxc,

		

		output reg [63:0]	xgmii_data_in,
		output reg [7:0]	xgmii_data_status,


		output reg [1:0]	local_fault_msg_det,
		output reg [1:0]	remote_fault_msg_det,

		output reg		status_fragment_error_tog,
		output reg		status_pause_frame_rx_tog);


reg [63:32]	xgmii_rxd_d1;
reg [7:4]	xgmii_rxc_d1;

reg [63:0]	xgxs_rxd_barrel;
reg [7:0]	xgxs_rxc_barrel;

reg [63:0]	xgxs_rxd_barrel_d1;
reg [7:0]	xgxs_rxc_barrel_d1;

reg [63:0]	rx_inc_data;
reg [7:0]	rx_inc_status;

reg		barrel_shift;

reg [31:0]	crc32_d64;

`ifdef SIMULATION 
reg		crc_good; 
`endif
reg		crc_clear;

reg [31:0]	crc_rx;
reg [31:0]	next_crc_rx;

reg [2:0]	curr_state;
reg [2:0]	next_state;

reg [13:0]	curr_byte_cnt;
reg [13:0]	next_byte_cnt;

reg		fragment_error;



reg [7:0]	addmask;
reg [7:0]	datamask;

reg		pause_frame;
reg		next_pause_frame;







parameter [2:0]
	SM_IDLE = 3'd0,
	SM_RX = 3'd1;



	
`ifdef ASYNC_RES
always @(posedge clk or negedge res_n) `else
always @(posedge clk) `endif
begin
	if (res_n == 1'b0) begin

	
		xgmii_data_in <= 64'b0;
		xgmii_data_status <= 8'b0;
		xgmii_rxd_d1 <= 32'b0;
		xgmii_rxc_d1 <= 4'b0;

		xgxs_rxd_barrel <= 64'b0;
		xgxs_rxc_barrel <= 8'b0;

		xgxs_rxd_barrel_d1 <= 64'b0;
		xgxs_rxc_barrel_d1 <= 8'b0;

		barrel_shift <= 1'b0;

		local_fault_msg_det <= 2'b0;
		remote_fault_msg_det <= 2'b0;

		crc32_d64 <= 32'b0;

		crc_rx <= 32'b0;

		status_fragment_error_tog <= 1'b0;

		status_pause_frame_rx_tog <= 1'b0;


		//sm
		curr_state <= SM_IDLE;
		curr_byte_cnt <= 14'b0;
		pause_frame <= 1'b0;

		
	end
	else begin
		//sm

		xgmii_data_in <= rx_inc_data;
		xgmii_data_status <= rx_inc_status;
		

		curr_state <= next_state;
		curr_byte_cnt <= next_byte_cnt;
		pause_frame <= next_pause_frame;


		//---
		// Link status RC layer
		// Look for local/remote messages on lower 4 lanes and upper
		// 4 lanes. This is a 64-bit interface but look at each 32-bit
		// independantly.
		
		local_fault_msg_det[1] <= (xgmii_rxd[63:32] ==
					{`LOCAL_FAULT, 8'h0, 8'h0, `SEQUENCE} &&
					xgmii_rxc[7:4] == 4'b0001);

		local_fault_msg_det[0] <= (xgmii_rxd[31:0] ==
					{`LOCAL_FAULT, 8'h0, 8'h0, `SEQUENCE} &&
					xgmii_rxc[3:0] == 4'b0001);

		remote_fault_msg_det[1] <= (xgmii_rxd[63:32] ==
					{`REMOTE_FAULT, 8'h0, 8'h0, `SEQUENCE} &&
					xgmii_rxc[7:4] == 4'b0001);

		remote_fault_msg_det[0] <= (xgmii_rxd[31:0] ==
					{`REMOTE_FAULT, 8'h0, 8'h0, `SEQUENCE} &&
					xgmii_rxc[3:0] == 4'b0001);



		
		
		//---
		// Rotating barrel. This function allow us to always align the start of
		// a frame with LANE0. If frame starts in LANE4, it will be shifted 4 bytes
		// to LANE0, thus reducing the amount of logic needed at the next stage.

		xgmii_rxd_d1[63:32] <= xgmii_rxd[63:32];
		xgmii_rxc_d1[7:4] <= xgmii_rxc[7:4];

		if (xgmii_rxd[`LANE0] == `START && xgmii_rxc[0]) begin
			
			xgxs_rxd_barrel <= xgmii_rxd;
			xgxs_rxc_barrel <= xgmii_rxc;

			barrel_shift <= 1'b0;

		end
		else if (xgmii_rxd[`LANE4] == `START && xgmii_rxc[4]) begin

			xgxs_rxd_barrel <= {xgmii_rxd[31:0], xgmii_rxd_d1[63:32]};
			xgxs_rxc_barrel <= {xgmii_rxc[3:0], xgmii_rxc_d1[7:4]};

			barrel_shift <= 1'b1;

		end
		else if (barrel_shift) begin

			xgxs_rxd_barrel <= {xgmii_rxd[31:0], xgmii_rxd_d1[63:32]};
			xgxs_rxc_barrel <= {xgmii_rxc[3:0], xgmii_rxc_d1[7:4]};

		end
		else begin

			xgxs_rxd_barrel <= xgmii_rxd;
			xgxs_rxc_barrel <= xgmii_rxc;

		end

		xgxs_rxd_barrel_d1 <= xgxs_rxd_barrel;
		xgxs_rxc_barrel_d1 <= xgxs_rxc_barrel;


		crc_rx <= next_crc_rx;

		if (crc_clear) begin

		// CRC is cleared at the beginning of the frame, calculate
		// 64-bit at a time otherwise

			crc32_d64 <= 32'hffffffff;

		end
		else begin

			crc32_d64 <= next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b0);			

		end
		
		//---
		// Error detection


		if (fragment_error) begin
			status_fragment_error_tog <= ~status_fragment_error_tog;
		end


		//---
		// Frame receive indication

// 		if (good_pause_frame) begin
// 		status_pause_frame_rx_tog <= ~status_pause_frame_rx_tog;
// 		end

	end

	end
		


always @(/*AS*/crc_rx or curr_byte_cnt or curr_state
	or pause_frame or xgxs_rxc_barrel or xgxs_rxc_barrel_d1
	or xgxs_rxd_barrel or xgxs_rxd_barrel_d1) 
begin

	next_state = curr_state;

	rx_inc_data = xgxs_rxd_barrel_d1;
	rx_inc_status = `RXSTATUS_NONE;


	addmask[0] = !(xgxs_rxd_barrel_d1[`LANE0] == `TERMINATE && xgxs_rxc_barrel_d1[0]);
	addmask[1] = !(xgxs_rxd_barrel_d1[`LANE1] == `TERMINATE && xgxs_rxc_barrel_d1[1]);
	addmask[2] = !(xgxs_rxd_barrel_d1[`LANE2] == `TERMINATE && xgxs_rxc_barrel_d1[2]);
	addmask[3] = !(xgxs_rxd_barrel_d1[`LANE3] == `TERMINATE && xgxs_rxc_barrel_d1[3]);
	addmask[4] = !(xgxs_rxd_barrel_d1[`LANE4] == `TERMINATE && xgxs_rxc_barrel_d1[4]);
	addmask[5] = !(xgxs_rxd_barrel_d1[`LANE5] == `TERMINATE && xgxs_rxc_barrel_d1[5]);
	addmask[6] = !(xgxs_rxd_barrel_d1[`LANE6] == `TERMINATE && xgxs_rxc_barrel_d1[6]);
	addmask[7] = !(xgxs_rxd_barrel_d1[`LANE7] == `TERMINATE && xgxs_rxc_barrel_d1[7]);

	datamask[0] = addmask[0];
	datamask[1] = &addmask[1:0];
	datamask[2] = &addmask[2:0];
	datamask[3] = &addmask[3:0];
	datamask[4] = &addmask[4:0];
	datamask[5] = &addmask[5:0];
	datamask[6] = &addmask[6:0];
	datamask[7] = &addmask[7:0];


	next_crc_rx = crc_rx;
	crc_clear = 1'b0;
	`ifdef SIMULATION 
	crc_good = 1'b0;
	`endif
	

	next_byte_cnt = curr_byte_cnt;

	fragment_error = 1'b0;

	next_pause_frame = pause_frame;

	case (curr_state)

		SM_IDLE: begin
			next_byte_cnt = 14'b0;
			crc_clear = 1'b1;
			next_pause_frame = 1'b0;
		

			// Detect the start of a frame
			
			if (xgxs_rxd_barrel_d1[`LANE0] == `START && xgxs_rxc_barrel_d1[0] &&
				xgxs_rxd_barrel_d1[`LANE1] == `PREAMBLE && !xgxs_rxc_barrel_d1[1] &&
				xgxs_rxd_barrel_d1[`LANE2] == `PREAMBLE && !xgxs_rxc_barrel_d1[2] &&
				xgxs_rxd_barrel_d1[`LANE3] == `PREAMBLE && !xgxs_rxc_barrel_d1[3] &&
				xgxs_rxd_barrel_d1[`LANE4] == `PREAMBLE && !xgxs_rxc_barrel_d1[4] &&
				xgxs_rxd_barrel_d1[`LANE5] == `PREAMBLE && !xgxs_rxc_barrel_d1[5] &&
				xgxs_rxd_barrel_d1[`LANE6] == `PREAMBLE && !xgxs_rxc_barrel_d1[6] &&
				xgxs_rxd_barrel_d1[`LANE7] == `SFD && !xgxs_rxc_barrel_d1[7])
			begin
				next_state = SM_RX;
			end

		end

		SM_RX:	begin

			rx_inc_status[`RXSTATUS_VALID] = 1'b1;

			if (xgxs_rxd_barrel_d1[`LANE0] == `START && xgxs_rxc_barrel_d1[0] &&
				xgxs_rxd_barrel_d1[`LANE7] == `SFD && !xgxs_rxc_barrel_d1[7]) begin

				// Fragment received, if we are still at SOP stage don't store
				// the frame. If not, write a fake EOP and flag frame as bad.

				next_byte_cnt = 14'b0;
				crc_clear = 1'b1;

				fragment_error = 1'b1;
				rx_inc_status[`RXSTATUS_ERR] = 1'b1;

				if (curr_byte_cnt == 14'b0) begin
					//rxhfifo_wen = 1'b0;
				end
				else begin
					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
				end

			end
			else if (curr_byte_cnt +datamask[0] + datamask[1] + datamask[2] + datamask[3] +
						datamask[4] + datamask[5] + datamask[6] + datamask[7] > 14'd1518) begin //6 da + 6 sa +2 typelength, +1500 payload +4 crc

				// Frame too long, TERMMINATE must have been corrupted.
				// Abort transfer, write a fake EOP, report as fragment.

				fragment_error = 1'b1;
				rx_inc_status[`RXSTATUS_ERR] = 1'b1;

				rx_inc_status[`RXSTATUS_EOP] = 1'b1;
				next_state = SM_IDLE;

			end
			else begin

				// Pause frame receive, these frame will be filtered
				//- TODO
				if (curr_byte_cnt == 14'd0 && xgxs_rxd_barrel_d1[47:0] == `PAUSE_FRAME) begin

				//rxhfifo_wen = 1'b0; 
					next_pause_frame = 1'b1;
				end



				// Write SOP to status bits during first byte

				if (curr_byte_cnt == 14'b0) begin
					rx_inc_status[`RXSTATUS_SOP] = 1'b1;
				end
				
				next_byte_cnt = curr_byte_cnt +
						addmask[0] + addmask[1] + addmask[2] + addmask[3] +
						addmask[4] + addmask[5] + addmask[6] + addmask[7];
				
				




				// Look one cycle ahead for TERMINATE in lanes 0 to 4
				if (curr_byte_cnt + datamask[0] + datamask[1] + datamask[2] + datamask[3] +
						datamask[4] + datamask[5] + datamask[6] + datamask[7] < 14'd64 && |(xgxs_rxc_barrel_d1 & datamask) ) begin // ethernet min. 64 byte check
					
					next_state = SM_IDLE;
					rx_inc_status[`RXSTATUS_ERR] = 1'b1;
					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					
					
					
				end
				else if (xgxs_rxd_barrel[`LANE4] == `TERMINATE && xgxs_rxc_barrel[4]) begin
		
					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					rx_inc_status[2:0] = 3'd0;

					if (  xgxs_rxd_barrel[31:0] !=  ~reverse_32b(next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b000))) begin
						rx_inc_status[`RXSTATUS_ERR] = 1'b1;
						`ifdef SIMULATION
						crc_good = 1'b0;
						`endif
					end
					`ifdef SIMULATION
					else begin
						crc_good = 1'b1;
					end
					`endif
					next_state = SM_IDLE;

				end

				else if (xgxs_rxd_barrel[`LANE3] == `TERMINATE && xgxs_rxc_barrel[3]) begin

					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					rx_inc_status[2:0] = 3'd7;

					if (  {xgxs_rxd_barrel[23:0], xgxs_rxd_barrel_d1[63:56]} !=  ~reverse_32b(next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b111))) begin
						rx_inc_status[`RXSTATUS_ERR] = 1'b1;						
						`ifdef SIMULATION
						crc_good = 1'b0;
						`endif
					end
					`ifdef SIMULATION
					else begin
						crc_good = 1'b1;
					end
					`endif
					next_state = SM_IDLE;

				end
			
				else if (xgxs_rxd_barrel[`LANE2] == `TERMINATE && xgxs_rxc_barrel[2]) begin

					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					rx_inc_status[2:0] = 3'd6;

					if (  {xgxs_rxd_barrel[15:0], xgxs_rxd_barrel_d1[63:48]} !=  ~reverse_32b(next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b110))) begin
						rx_inc_status[`RXSTATUS_ERR] = 1'b1;
						`ifdef SIMULATION
						crc_good = 1'b0;
						`endif
					end
					`ifdef SIMULATION
					else begin
						crc_good = 1'b1;
					end
					`endif
					next_state = SM_IDLE;

				end

				else if (xgxs_rxd_barrel[`LANE1] == `TERMINATE && xgxs_rxc_barrel[1]) begin

					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					rx_inc_status[2:0] = 3'd5;

					if ( {xgxs_rxd_barrel[7:0], xgxs_rxd_barrel_d1[63:40]} !=  ~reverse_32b(next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b101))) begin
						rx_inc_status[`RXSTATUS_ERR] = 1'b1;
						`ifdef SIMULATION
						crc_good = 1'b0;
						`endif
					end
					`ifdef SIMULATION
					else begin
						crc_good = 1'b1;
					end
					`endif
					next_state = SM_IDLE;

				end
			
				else if (xgxs_rxd_barrel[`LANE0] == `TERMINATE && xgxs_rxc_barrel[0]) begin

					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					rx_inc_status[2:0] = 3'd4;

					if ( xgxs_rxd_barrel_d1[63:32] !=  ~reverse_32b(next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b100))) begin
						rx_inc_status[`RXSTATUS_ERR] = 1'b1;
						`ifdef SIMULATION
						crc_good = 1'b0;
						`endif						
					end
					`ifdef SIMULATION
					else begin
						crc_good = 1'b1;
					end
					`endif
					next_state = SM_IDLE;

				end

				// Look at current cycle for TERMINATE in lanes 5 to 7

				else if (xgxs_rxd_barrel_d1[`LANE7] == `TERMINATE &&
					xgxs_rxc_barrel_d1[7]) begin

					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					rx_inc_status[2:0] = 3'd3;

					if ( xgxs_rxd_barrel_d1[55:24] !=  ~reverse_32b(next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b011))) begin
						rx_inc_status[`RXSTATUS_ERR] = 1'b1;
						`ifdef SIMULATION
						crc_good = 1'b0;
						`endif
					end
					`ifdef SIMULATION
					else begin
						crc_good = 1'b1;
					end
					`endif
					next_state = SM_IDLE;

				end
			
				else if (xgxs_rxd_barrel_d1[`LANE6] == `TERMINATE &&
					xgxs_rxc_barrel_d1[6]) begin

					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					rx_inc_status[2:0] = 3'd2;

					if ( xgxs_rxd_barrel_d1[47:16] != ~reverse_32b(next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b010))) begin
						rx_inc_status[`RXSTATUS_ERR] = 1'b1;
						`ifdef SIMULATION
						crc_good = 1'b0;
						`endif
					end
					`ifdef SIMULATION
					else begin
						crc_good = 1'b1;
					end
					`endif
					next_state = SM_IDLE;

				end
			
				else if (xgxs_rxd_barrel_d1[`LANE5] == `TERMINATE &&
					xgxs_rxc_barrel_d1[5]) begin

					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					rx_inc_status[2:0] = 3'd1;
					if ( xgxs_rxd_barrel_d1[39:8] != ~reverse_32b(next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b001))) begin
						rx_inc_status[`RXSTATUS_ERR] = 1'b1;
						`ifdef SIMULATION
						crc_good = 1'b0;
						`endif
					end
					`ifdef SIMULATION
					else begin
						crc_good = 1'b1;
					end
					`endif

					next_state = SM_IDLE;

				end
				else if(|(xgxs_rxc_barrel_d1 & datamask)) begin // no terminate signal, but cmd != 0
					`ifdef SIMULATION
					crc_good = 1'b0;
					`endif
					rx_inc_status[`RXSTATUS_ERR] = 1'b1;
					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					next_state = SM_IDLE;
					
				
				end
				`ifdef SIMULATION
				else begin
					crc_good = 1'b0;
				end
				`endif
			
			end
		end

		default: begin
			next_state = SM_IDLE;
		end

	endcase

end


endmodule

