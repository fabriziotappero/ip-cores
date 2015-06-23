////////////////////////////////////////////////////////////////// ////
//// 																////
//// AES Decryption Core for FPGA									////
//// 																////
//// This file is part of the AES Decryption Core for FPGA project 	////
//// http://www.opencores.org/cores/xxx/ 							////
//// 																////
//// Description 													////
//// Implementation of  AES Decryption Core for FPGA according to 	////
//// core specification document.		 							////
//// 																////
//// To Do: 														////
//// - 																////
//// 																////
//// Author(s): 													////
//// - scheng, schengopencores@opencores.org 						////
//// 																////
//////////////////////////////////////////////////////////////////////
//// 																////
//// Copyright (C) 2009 Authors and OPENCORES.ORG 					////
//// 																////
//// This source file may be used and distributed without 			////
//// restriction provided that this copyright statement is not 		////
//// removed from the file and that any derivative work contains 	////
//// the original copyright notice and the associated disclaimer. 	////
//// 																////
//// This source file is free software; you can redistribute it 	////
//// and/or modify it under the terms of the GNU Lesser General 	////
//// Public License as published by the Free Software Foundation; 	////
//// either version 2.1 of the License, or (at your option) any 	////
//// later version. 												////
//// 																////
//// This source is distributed in the hope that it will be 		////
//// useful, but WITHOUT ANY WARRANTY; without even the implied 	////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 		////
//// PURPOSE. See the GNU Lesser General Public License for more 	////
//// details. 														////
//// 																////
//// You should have received a copy of the GNU Lesser General 		////
//// Public License along with this source; if not, download it 	////
//// from http://www.opencores.org/lgpl.shtml 						////
//// 																//// ///
///////////////////////////////////////////////////////////////////
////																////
//// 128-bit key expander											////
////																////
//// The key expansion algorithm is described in section 5.2 of the	////
//// FIPS-197 spec. This file implements the case for 128-bit key	////
//// only.															////
////																////
////////////////////////////////////////////////////////////////////////

module KeyExpand128(
	// 128-bit key expander
	
	input	[0:127] kt,
	input	kt_vld,		// Active high input informing key expander that a valid new key is present at kt.
	output	kt_rdy,		// Active high output indicates key expander ready to accept new key
	
	output	[0:127] rkey,
	output	rkey_vld,	// Active high output indicates valid roundkey available at rkey[0:127]
	output	rkey_last,	// High for 1 clock cycle, indicates last roundkey available at rkey[0:127].
	
	input	clk,
	input	rst
	);
	
	// Registers holding the current roundkey
	logic	[0:31]	w0;
	logic	[0:31]	w1;
	logic	[0:31]	w2;
	logic	[0:31]	w3;
	
	logic	[0:3]	keyexp_state;	// Key expansion state machine.
	logic	[0:7]	Rcon;			// Round constant. See FIPS-197 section 5.3.
	
	wire	[0:31]	subword_out;
	wire	[0:31]	rotword_out;
	wire	[0:31]	w0_feed;
	wire	[0:31]	w1_feed;
	wire	[0:31]	w2_feed;
	wire	[0:31]	w3_feed;

	wire	keyexp_state_0;		// '1' indicates key expansion state machine at state 0 (initial state)
	wire	keyexp_state_10;	// '1' indicates key expansion state machine at state 10 (last state)
	
	// Do not remove the "keep" and "max_fanout" attribute. They are there to force the synthesizer
	// to infer independent logic for next_w0-3, instead of deriving next_w1 from next_w0, ...and
	// so on. See the definitions of next_w* below. This is to avoid getting a chain of LUTs, which reduces Fmax.
	(* keep = "true", max_fanout = 1 *) wire	[0:31]	next_w0;
	(* keep = "true", max_fanout = 1 *) wire	[0:31]	next_w1;
	(* keep = "true", max_fanout = 1 *) wire	[0:31]	next_w2;
	(* keep = "true", max_fanout = 1 *) wire	[0:31]	next_w3;

	assign w0_feed = (keyexp_state_0)? kt[0+:32] : w0;
	assign w1_feed = (keyexp_state_0)? kt[32+:32] : w1;
	assign w2_feed = (keyexp_state_0)? kt[64+:32] : w2;
	assign w3_feed = (keyexp_state_0)? kt[96+:32] : w3;
	
	RotWord RotWord_u(.din(w3_feed), .dout(rotword_out));
	SubWord SubWord_u(.din(rotword_out), .dout(subword_out));
	
	assign next_w0 = subword_out ^ {Rcon,24'h000000} ^ w0_feed;
	assign next_w1 = subword_out ^ {Rcon,24'h000000} ^ w0_feed ^ w1_feed;
	assign next_w2 = subword_out ^ {Rcon,24'h000000} ^ w0_feed ^ w1_feed ^ w2_feed;
	assign next_w3 = subword_out ^ {Rcon,24'h000000} ^ w0_feed ^ w1_feed ^ w2_feed ^ w3_feed;

	assign rkey = (keyexp_state_0)? kt : {w0,w1,w2,w3};
	assign kt_rdy = keyexp_state_0;	// Only accept new key in initial state.
	assign rkey_vld = ~keyexp_state_0 | kt_vld;
	assign rkey_last = keyexp_state_10;
	assign keyexp_state_0 = (keyexp_state == 0);
	assign keyexp_state_10 = (keyexp_state == 10);

	// Key Expansion state machine	
	always_ff @(posedge clk)
	begin
		if (rst)
		begin
			keyexp_state <= 0;	// Reset to initial state
			Rcon <= 8'h01;
		end
		else
			unique case (keyexp_state)
				0 :	// If valid key present, load key into roundkey register and proceed to next state
					if (kt_vld)
					begin
						keyexp_state <= keyexp_state + 1;
						{w0,w1,w2,w3} <= {next_w0, next_w1, next_w2, next_w3};
						Rcon <= (Rcon[0])? (Rcon << 1) ^ 8'h1b : (Rcon << 1);	// Advance to next Rcon value.
					end
				1,2,3,4,5,6,7,8,9 :
					// Proceed to next state and update roundkey register
					begin
						keyexp_state <= keyexp_state + 1;
						{w0,w1,w2,w3} <= {next_w0, next_w1, next_w2, next_w3};
						Rcon <= (Rcon[0])? (Rcon << 1) ^ 8'h1b : (Rcon << 1);	// Advance to next Rcon value.
					end
				10:	// Wrap back to initial state and update roundkey register
					begin
						keyexp_state <= 0;
						{w0,w1,w2,w3} <= {next_w0, next_w1, next_w2, next_w3};
						Rcon <= 8'h01;
					end
			endcase
	end

endmodule
