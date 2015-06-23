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

module tx_dequeue(
  // Outputs
	input wire		clk,
	input wire		res_n,
	input wire [63:0]	txdfifo_rdata,
	input wire [7:0]	txdfifo_rstatus,
	
	output reg [63:0]	xgmii_txd,
	output reg [7:0]	xgmii_txc);



reg [63:0]	xgxs_txd;
reg [7:0]	xgxs_txc;

reg [63:0]	next_xgxs_txd;
reg [7:0]	next_xgxs_txc;

reg [2:0]	curr_state_enc;
reg [2:0]	next_state_enc;

reg [0:0]	curr_state_pad;
reg[0:0]	next_state_pad;




reg [7:0]	eop;
reg [7:0]	next_eop;



reg [63:0]	txhfifo_wdata_d1;

reg [13:0]	byte_cnt;

reg [31:0]	crc32_d64;
reg [31:0]	crc32_tx;

reg [31:0]	crc_data;




reg [63:0]	next_txhfifo_wdata;
reg [7:0]	next_txhfifo_wstatus;
reg		next_txhfifo_wen;


reg [63:0]	txhfifo_wdata;
reg [7:0]	txhfifo_wstatus;

reg		status_local_fault_ctx; // for later implementations
reg		status_remote_fault_ctx;



parameter [2:0]
	//SM_IDLE      = 3'd0,
	SM_PREAMBLE  = 3'd0,
	SM_TX        = 3'd2,
	SM_EOP       = 3'd3,
	SM_TERM      = 3'd4,
	SM_TERM_FAIL = 3'd5;

parameter [0:0]
	SM_PAD_EQ    = 1'd0,
	SM_PAD_PAD   = 1'd1;


//---
// RC layer

`ifdef ASYNC_RES
always @(posedge clk or negedge res_n) `else
always @(posedge clk) `endif
begin

	if (res_n == 1'b0) begin

		xgmii_txd <= {8{`IDLE}};
		xgmii_txc <= 8'hff;
		status_remote_fault_ctx <= 1'b0;
		status_local_fault_ctx <= 1'b0;

		curr_state_enc <= SM_PREAMBLE;


		eop <= 8'b0;

		txhfifo_wdata_d1 <= 64'b0;





		xgxs_txd <= {8{`IDLE}};
		xgxs_txc <= 8'hff;

		curr_state_pad <= SM_PAD_EQ;


		txhfifo_wdata <= 64'b0;
		txhfifo_wstatus <= 8'b0; 

		byte_cnt <= 14'b0;


	end
	else begin
		// no faults expected.
		status_remote_fault_ctx <= 1'b0;
		status_local_fault_ctx <= 1'b0;
		//---
		// RC Layer, insert local or remote fault messages based on status
		// of fault state-machine

		if (status_local_fault_ctx) begin

		// If local fault detected, send remote fault message to
		// link partner
			xgmii_txd <= {`REMOTE_FAULT, 8'h0, 8'h0, `SEQUENCE,
					`REMOTE_FAULT, 8'h0, 8'h0, `SEQUENCE};
			xgmii_txc <= {4'b0001, 4'b0001};
		end
		else if (status_remote_fault_ctx) begin

		// If remote fault detected, inhibit transmission and send
		// idle codes
			xgmii_txd <= {8{`IDLE}};
			xgmii_txc <= 8'hff;
		end
		else begin
			xgmii_txd <= xgxs_txd;
			xgmii_txc <= xgxs_txc;
		end

		curr_state_enc <= next_state_enc;


		eop <= next_eop;

		txhfifo_wdata_d1 <= txhfifo_wdata;



		xgxs_txd <= next_xgxs_txd;
		xgxs_txc <= next_xgxs_txc;

		curr_state_pad <= next_state_pad;


		txhfifo_wdata <= next_txhfifo_wdata;
		txhfifo_wstatus <= next_txhfifo_wstatus;


		//---
		// Reset byte count on SOP
		


		if (next_txhfifo_wstatus[`TXSTATUS_SOP]) begin
			byte_cnt <= 14'd8;
		end
		else if (next_txhfifo_wstatus[`TXSTATUS_VALID]) begin
			byte_cnt <= byte_cnt + 14'd8; 
		end


		// ========================================
		// ============CRC_CALC====================
		// ========================================


		if (txhfifo_wstatus[`TXSTATUS_VALID]) begin

			crc32_d64 <= next_crc32_data64_be(reverse_64b(txhfifo_wdata), crc_data, 3'b000);

		end

		if (txhfifo_wstatus[`TXSTATUS_VALID] && txhfifo_wstatus[`TXSTATUS_EOP]) begin

			
			crc32_tx <= ~reverse_32b(next_crc32_data64_be(reverse_64b(txhfifo_wdata), crc32_d64, txhfifo_wstatus[2:0]));


		end


	end

end


	always @(crc32_tx or curr_state_enc or eop
		or txhfifo_wdata_d1
		or txhfifo_wstatus) begin

	next_state_enc = curr_state_enc;


	next_eop = eop;

	next_xgxs_txd = {8{`IDLE}};
	next_xgxs_txc = 8'hff;

	


	case (curr_state_enc)

		SM_PREAMBLE: begin

			// On reading SOP 

			if (txhfifo_wstatus[`TXSTATUS_SOP] && txhfifo_wstatus[`TXSTATUS_VALID]) begin

				next_xgxs_txd = {`SFD, {6{`PREAMBLE}}, `START};
				next_xgxs_txc = 8'h01;

				next_state_enc = SM_TX;

			end
			else begin
				next_state_enc = SM_PREAMBLE;

			end



		end

		SM_TX: begin

			next_xgxs_txd = txhfifo_wdata_d1;
			next_xgxs_txc = 8'h00;



			// Wait for EOP indication to be read from the fifo, then
			// transition to next state.

			if (txhfifo_wstatus[`TXSTATUS_EOP]) begin
				
				next_state_enc = SM_EOP;

			end
			else if (txhfifo_wstatus[`TXSTATUS_SOP]) begin

				// Failure condition, we did not see EOP and there
				// is no more data in fifo or SOP, force end of packet transmit.
				next_state_enc = SM_TERM_FAIL;

			end

			next_eop[0] = txhfifo_wstatus[2:0] == 3'd1;
			next_eop[1] = txhfifo_wstatus[2:0] == 3'd2;
			next_eop[2] = txhfifo_wstatus[2:0] == 3'd3;
			next_eop[3] = txhfifo_wstatus[2:0] == 3'd4;
			next_eop[4] = txhfifo_wstatus[2:0] == 3'd5;
			next_eop[5] = txhfifo_wstatus[2:0] == 3'd6;
			next_eop[6] = txhfifo_wstatus[2:0] == 3'd7;
			next_eop[7] = txhfifo_wstatus[2:0] == 3'd0;
				
		end

		SM_EOP:
			begin

			// Insert TERMINATE character in correct lane depending on position
			// of EOP read from fifo. Also insert CRC read from control fifo.

			if (eop[0]) begin
				next_xgxs_txd = {{2{`IDLE}}, `TERMINATE, 
						crc32_tx[31:0], txhfifo_wdata_d1[7:0]};
				next_xgxs_txc = 8'b11100000;
			end

			else if (eop[1]) begin
				next_xgxs_txd = {`IDLE, `TERMINATE,
						crc32_tx[31:0], txhfifo_wdata_d1[15:0]};
				next_xgxs_txc = 8'b11000000;
			end

			else if (eop[2]) begin
				next_xgxs_txd = {`TERMINATE, crc32_tx[31:0], txhfifo_wdata_d1[23:0]};
				next_xgxs_txc = 8'b10000000;
			end

			else if (eop[3]) begin
				next_xgxs_txd = {crc32_tx[31:0], txhfifo_wdata_d1[31:0]};
				next_xgxs_txc = 8'b00000000;
			end

			else if (eop[4]) begin
				next_xgxs_txd = {crc32_tx[23:0], txhfifo_wdata_d1[39:0]};
				next_xgxs_txc = 8'b00000000;
			end

			else if (eop[5]) begin
				next_xgxs_txd = {crc32_tx[15:0], txhfifo_wdata_d1[47:0]};
				next_xgxs_txc = 8'b00000000;
			end

			else if (eop[6]) begin
				next_xgxs_txd = {crc32_tx[7:0], txhfifo_wdata_d1[55:0]};
				next_xgxs_txc = 8'b00000000;
			end

			else if (eop[7]) begin
				next_xgxs_txd = {txhfifo_wdata_d1[63:0]};
				next_xgxs_txc = 8'b00000000;
			end



			if (|eop[2:0]) begin

				if (!txhfifo_wstatus[`TXSTATUS_VALID]) begin

					next_state_enc = SM_PREAMBLE;

				end
			end

			if (|eop[7:3]) begin
				next_state_enc = SM_TERM;
			end

		end

		SM_TERM: begin

		// Insert TERMINATE character in correct lane depending on position
		// of EOP read from fifo. Also insert CRC read from control fifo.

			if (eop[3]) begin
				next_xgxs_txd = {{7{`IDLE}}, `TERMINATE};
				next_xgxs_txc = 8'b11111111;
			end

			else if (eop[4]) begin
				next_xgxs_txd = {{6{`IDLE}}, `TERMINATE, crc32_tx[31:24]};
				next_xgxs_txc = 8'b11111110;
			end

			else if (eop[5]) begin
				next_xgxs_txd = {{5{`IDLE}}, `TERMINATE, crc32_tx[31:16]};
				next_xgxs_txc = 8'b11111100;
			end

			else if (eop[6]) begin
				next_xgxs_txd = {{4{`IDLE}}, `TERMINATE, crc32_tx[31:8]};
				next_xgxs_txc = 8'b11111000;
			end

			else if (eop[7]) begin
				next_xgxs_txd = {{3{`IDLE}}, `TERMINATE, crc32_tx[31:0]};
				next_xgxs_txc = 8'b11110000;
			end

			next_state_enc = SM_PREAMBLE;


		end

		SM_TERM_FAIL: begin

			next_xgxs_txd = {{7{`IDLE}}, `TERMINATE};
			next_xgxs_txc = 8'b11111111;
			next_state_enc = SM_PREAMBLE;
		end


		default: begin

			next_state_enc = SM_PREAMBLE;
		end

	endcase

	end


always @(/*AS*//*crc32_d64 or txhfifo_wen or txhfifo_wstatus*/ *) begin

    if (txhfifo_wstatus[`TXSTATUS_SOP]) begin
        crc_data = 32'hffffffff;
    end
    else begin
        crc_data = crc32_d64;
    end
    
end



// ==================================== STATE_MACHINE FOR PADDING =========================


always @(/*AS*//*byte_cnt or curr_state_pad or txdfifo_rdata
         or txdfifo_rempty or txdfifo_ren_d1 or txdfifo_rstatus
         or txhfifo_walmost_full*/ *) begin

	next_state_pad = curr_state_pad;

	next_txhfifo_wdata = txdfifo_rdata;
	next_txhfifo_wstatus = txdfifo_rstatus;
	

	case (curr_state_pad)

	SM_PAD_EQ: begin


		if (txdfifo_rstatus[`TXSTATUS_VALID]) begin


              // On EOP, decide if padding is required for this packet.

			if (txdfifo_rstatus[`TXSTATUS_EOP]) begin
		
				if (byte_cnt < 14'd56) begin
					next_txhfifo_wstatus = `TXSTATUS_NONE;
					next_state_pad = SM_PAD_PAD;
				end
				else if (	byte_cnt == 14'd56 &&
					(txdfifo_rstatus[2:0] == 3'd1 ||
					txdfifo_rstatus[2:0] == 3'd2 ||
					txdfifo_rstatus[2:0] == 3'd3))
				begin

					// Pad up to LANE3, keep the other 4 bytes for crc that will
					// be inserted by dequeue engine.
					
					next_txhfifo_wstatus[2:0] = 3'd4;

					// Pad end bytes with zeros.

					if (txdfifo_rstatus[2:0] == 3'd1)
						next_txhfifo_wdata[31:8] = 24'b0;
					if (txdfifo_rstatus[2:0] == 3'd2)
						next_txhfifo_wdata[31:16] = 16'b0;
					if (txdfifo_rstatus[2:0] == 3'd3)
						next_txhfifo_wdata[31:24] = 8'b0;
				end
                  

			end
        
		end

	end

	SM_PAD_PAD: begin

          //---
          // Pad packet to 64 bytes by writting zeros to holding fifo.

         

		next_txhfifo_wdata = 64'b0;
		next_txhfifo_wstatus = `TXSTATUS_NONE;
		
		if (byte_cnt == 14'd56) begin

			// Pad up to LANE3, keep the other 4 bytes for crc that will
			// be inserted by dequeue engine.

			next_txhfifo_wstatus[`TXSTATUS_EOP] = 1'b1;
			next_txhfifo_wstatus[2:0] = 3'd4;

			next_state_pad = SM_PAD_EQ;

		end

	end

	default: begin

		next_state_pad = SM_PAD_EQ;
	end

	endcase

end


endmodule

