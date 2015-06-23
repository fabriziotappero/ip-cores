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
//// Decryption engine												////
////																////
//// This module implements the inverse cipher algorithm in			////
//// fig. 12 of FIPS-179 specification.								////
////																////
////////////////////////////////////////////////////////////////////////
module decrypt(
	input	[0:127]	ct,
	input	ct_vld,
	output	ct_rdy,
	
	input	[0:127]	rkey,
	input	rkey_vld,
	output	next_rkey,
	
	output	[0:127]	pt,
	output	pt_vld,
	
	input	[0:1]	klen_sel,	// Key length select. 00->128-bit, 01->192-bit, 10->256-bit, 11->invalid
	
	input	clk,
	input	rst
	);
	
	logic	[0:127]	State;
	logic	[14:0]	decrypt_state;
		
	wire	[0:127]	inv_shiftrows_out;
	wire	[0:127]	inv_subbytes_out;
	wire	[0:127]	inv_addrkey_out;
	wire	[0:127]	inv_mixcol_out;
	wire	bypass_inv_mixcol;
	wire	load_new_ct;
	wire	last_round;
	
	logic	pt_vld_reg;
	
	InvShiftRows InvShiftRows_u(.din(State), .dout(inv_shiftrows_out));
	(* KEEP_HIERARCHY = "yes" *) InvSubBytes InvSubBytes_u(.din(inv_shiftrows_out), .dout(inv_subbytes_out));
	(* KEEP_HIERARCHY = "yes" *) InvAddRoundKey InvAddRoundKey_u(.din0(inv_subbytes_out), .din1(ct), .rkey(rkey), .S(load_new_ct), .dout(inv_addrkey_out));
	(* KEEP_HIERARCHY = "yes" *) InvMixColumns InvMixColumns_u(.din(inv_addrkey_out), .dout(inv_mixcol_out), .bypass(bypass_inv_mixcol));
	
	// Decryption state machine, one-hot encoded.
	always_ff @(posedge clk)
	begin
		if (rst) decrypt_state <= 15'b00000000000001; // Reset to state0
		else
			if (decrypt_state[0])
			begin
				// If both valid roundkey and ciphertext are present, start decryption.
				if (rkey_vld & ct_vld) decrypt_state <= decrypt_state << 1;
			end
			else
				// For all other states, always proceed to next state. Wrap back to
				// state0 at final state
				decrypt_state <= (last_round)? 15'b00000000000001 : decrypt_state << 1;
	end

	assign last_round = ((klen_sel==2'b00) & decrypt_state[10]) | ((klen_sel==2'b01) & decrypt_state[12]) | ((klen_sel==2'b10) & decrypt_state[14]);
	
	// Plaintext is valid right after last round, and stays valid until the start of next decryption.
	always_ff @(posedge clk)
	begin
		if (rst) pt_vld_reg <= 0;
		else
			case (pt_vld_reg)
				1'b0 :	if (last_round) pt_vld_reg <= 1;
				1'b1 :	if (ct_vld & rkey_vld) pt_vld_reg <= 0;
			endcase
	end
	
	assign pt_vld = pt_vld_reg;
	
	always_ff @(posedge clk)
	// The output of InvMixColumns() is the intermediate result after each round.
		if (~(decrypt_state[0] & ~(ct_vld & rkey_vld))) State <= inv_mixcol_out;
		
	assign pt = State;
	
	// Load new ciphertext when state machine in state0 and both
	// valid roundkey and ciphetext are present.
	assign load_new_ct = decrypt_state[0] & rkey_vld & ct_vld;
	
	// Bypass InvMixColumns while loading new ciphertext or computing the result for
	// last round.
	assign bypass_inv_mixcol = load_new_ct | last_round;
	
	// Ready to accept new ciphertext only when valid round key is present and state machine
	// in state0
	assign ct_rdy = decrypt_state[0] & rkey_vld;
	
	// Consume one roundkey if
	// 1). Initial ciphertext and roundkey is present, or
	// 2). state machine not in state0 (decryption in progress already)
	assign next_rkey = ~decrypt_state[0] | (ct_vld & rkey_vld);
	
endmodule
