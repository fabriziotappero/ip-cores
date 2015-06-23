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
//// 192-bit key expander											////
////																////
//// The key expansion algorithm is described in section 5.2 of the	////
//// FIPS-197 spec. This file implements the case for 192-bit key	////
//// only.															////
////																////
////////////////////////////////////////////////////////////////////////

module KeyExpand192(
	// 192-bit key expander
	
	input	[0:191] kt,
	input	kt_vld,		// Active high input informing key expander that a valid new key is present at kt.
	output	kt_rdy,		// Active high output indicates key expander ready to accept new key
	
	output	[0:127] rkey,	// Note : rkey is always 128 bit regardless the crypto key length
	output	rkey_vld,	// Active high output indicates valid roundkey available at rkey[0:127]
	output	rkey_last,	// High for 1 clock cycle, indicates last roundkey available at rkey[0:127].
	
	input	clk,
	input	rst
	);
	
	// Registers holding the calculated roundkeys
	logic	[0:31]	w0;
	logic	[0:31]	w1;
	logic	[0:31]	w2;
	logic	[0:31]	w3;
	logic	[0:31]	w4;
	logic	[0:31]	w5;
	logic	[0:31]	w6;
	logic	[0:31]	w7;
	
	logic	[0:127]	mux_rkey;
	
	logic	[0:3]	keyexp_state;	// Key expansion state machine
	logic	[0:7]	Rcon;			// Round constant. See FIPS-197 section 5.3.
	
	wire	[0:31]	subword_out;
	wire	[0:31]	rotword_out;
	wire	[0:31]	rotword_in;
	
	wire	keyexp_state_0;		// '1' indicates key expansion state machine at state 0 (initial state)
	wire	keyexp_state_12;	// '1' indicates key expansion state machine at state 12 (last state)
	
	// Do not remove the "keep" and "max_fanout" attribute. They are there to force the synthesizer
	// to infer independent logic for next_w*, instead of deriving next_w1 from next_w0, ...and
	// so on. See the definitions of next_w* below. This is to avoid getting a chain of LUTs, which reduces Fmax.
	(* keep = "true", max_fanout = 1 *) wire	[0:31]	next_w2;
	(* keep = "true", max_fanout = 1 *) wire	[0:31]	next_w3;
	(* keep = "true", max_fanout = 1 *) wire	[0:31]	next_w4;
	(* keep = "true", max_fanout = 1 *) wire	[0:31]	next_w5;
	(* keep = "true", max_fanout = 1 *) wire	[0:31]	next_w6;
	(* keep = "true", max_fanout = 1 *) wire	[0:31]	next_w7;


	assign rotword_in = (keyexp_state_0)? kt[160:191] : w7;
	RotWord RotWord_u(.din(rotword_in), .dout(rotword_out));
	SubWord SubWord_u(.din(rotword_out), .dout(subword_out));
	
	assign next_w2 = (keyexp_state_0)? (subword_out ^ {Rcon,24'h000000} ^ kt[0+:32]) : (subword_out ^ {Rcon,24'h000000} ^ w2);
	assign next_w3 = (keyexp_state_0)? (subword_out ^ {Rcon,24'h000000} ^ kt[0+:32] ^ kt[32+:32]) : (subword_out ^ {Rcon,24'h000000} ^ w2 ^ w3);
	assign next_w4 = (keyexp_state_0)? (subword_out ^ {Rcon,24'h000000} ^ kt[0+:32] ^ kt[32+:32] ^ kt[64+:32]) : (subword_out ^ {Rcon,24'h000000} ^ w2 ^ w3 ^ w4);
	assign next_w5 = (keyexp_state_0)? (subword_out ^ {Rcon,24'h000000} ^ kt[0+:32] ^ kt[32+:32] ^ kt[64+:32] ^ kt[96+:32]) : (subword_out ^ {Rcon,24'h000000} ^ w2 ^ w3 ^ w4 ^ w5);
	assign next_w6 = (keyexp_state_0)? (subword_out ^ {Rcon,24'h000000} ^ kt[0+:32] ^ kt[32+:32] ^ kt[64+:32] ^ kt[96+:32] ^ kt[128+:32]) : (subword_out ^ {Rcon,24'h000000} ^ w2 ^ w3 ^ w4 ^ w5 ^ w6);
	assign next_w7 = (keyexp_state_0)? (subword_out ^ {Rcon,24'h000000} ^ kt[0+:32] ^ kt[32+:32] ^ kt[64+:32] ^ kt[96+:32] ^ kt[128+:32] ^ kt[160+:32]) : (subword_out ^ {Rcon,24'h000000} ^ w2 ^ w3 ^ w4 ^ w5 ^ w6 ^ w7);

	assign rkey = mux_rkey;
	assign kt_rdy = keyexp_state_0;	// Only accept new key in initial state.
	assign rkey_vld = ~keyexp_state_0 | kt_vld;
	assign rkey_last = keyexp_state_12;
	assign keyexp_state_0 = (keyexp_state == 0);
	assign keyexp_state_12 = (keyexp_state == 12);

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
						{w0,w1} <= kt[128:191];
						{w2,w3,w4,w5,w6,w7} <= {next_w2,next_w3,next_w4,next_w5,next_w6,next_w7};
						Rcon <= (Rcon[0])? (Rcon << 1) ^ 8'h1b : (Rcon << 1);	// Advance to next Rcon value. Rcon[0] is msb.
					end
				2,3,5,6,8,9,11 :
					// Proceed to next state and update roundkey register
					begin
						keyexp_state <= keyexp_state + 1;
						{w0,w1} <= {w6,w7};
						{w2,w3,w4,w5,w6,w7} <= {next_w2,next_w3,next_w4,next_w5,next_w6,next_w7};
						Rcon <= (Rcon[0])? (Rcon << 1) ^ 8'h1b : (Rcon << 1);	// Advance to next Rcon value. Rcon[0] is msb.
					end
				1,4,7,10 :
					// Proceed to next state, no update to roundkey register
					begin
						keyexp_state <= keyexp_state + 1;
					end
				12:	// Wrap back to initial state
					begin
						keyexp_state <= 0;
						Rcon <= 8'h01;
					end
			endcase
	end

	// Pick the right slices from the round key registers w0-w7 to form the current
	// round key.
	always_comb
	begin
		unique case (keyexp_state)
			0		: mux_rkey <= kt[0+:128];
			1,4,7,10: mux_rkey <= {w0,w1,w2,w3};
			2,5,8,11: mux_rkey <= {w4,w5,w6,w7};
			3,6,9,12: mux_rkey <= {w2,w3,w4,w5};
		endcase
	end

endmodule
