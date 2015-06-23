////////////////////////////////////////////////////////////////////////
////																////
//// This file is part of the AES SystemVerilog Behavioral			////
//// Model project													////
//// http://www.opencores.org/cores/aes_beh_model/					////
////																////
//// Description													////
//// Implementation of AES SystemVerilog Behavioral					////
//// Model according to AES Behavioral Model specification document.////
////																////
//// To Do:															////
//// -																////
////																////
//// Author(s):														////
//// - scheng, schengopencores@opencores.org						////
////																////
////////////////////////////////////////////////////////////////////////
////																////
//// Copyright (C) 2009 Authors and OPENCORES.ORG					////
////																////
//// This source file may be used and distributed without			////
//// restriction provided that this copyright statement is not		////
//// removed from the file and that any derivative work contains	////
//// the original copyright notice and the associated disclaimer.	////
////																////
//// This source file is free software; you can redistribute it		////
//// and/or modify it under the terms of the GNU Lesser General		////
//// Public License as published by the Free Software Foundation;	////
//// either version 2.1 of the License, or (at your option) any		////
//// later version.													////
////																////
//// This source is distributed in the hope that it will be			////
//// useful, but WITHOUT ANY WARRANTY; without even the implied		////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR		////
//// PURPOSE. See the GNU Lesser General Public License for more	////
//// details.														////
////																////
//// You should have received a copy of the GNU Lesser General		////
//// Public License along with this source; if not, download it		////
//// from http://www.opencores.org/lgpl.shtml 						////
//// 																////
////////////////////////////////////////////////////////////////////////

// This is a SystemVerilog implementation of the AES encryption/decryption
// algorithm described in FIPS-197. The model is implemented as a SystemVerilog
// class which can be instantiated in a testbench to generate known good
// results for verification of AES IPs. 
// 
// You are encouraged to use the typdefs at the end of this file instead of the
// class below while declaring variables for the aes model in your testbench.
//
// Refer to the specification document on how to use the model in your
// testbench.

typedef enum {encrypt, decrypt} aes_func;

class aes_beh_model #(int Nk=4, int Nr=10, aes_func func=decrypt);
	// Refer to section 5 fig.4 of FIPS-197 spec for definitions of Nk and Nr
	//				
	// Key length	Nk		Nr
	//		128		 4		10
	//		192		 6		12
	//		256		 8		14
	
	byte unsigned state[0:3][0:3];
	byte unsigned keysch[0:4*(Nr+1)-1][0:3];
	protected int unsigned curr_round;
	bit done;	// done=1 -> decryption done, valid plaintext available for read.
	bit loaded;	// Ciphertext loaded, ready to start decryption.

	function new();	// Constructor
		done = 0;
		loaded = 0;
	endfunction

	function int unsigned GetCurrRound;
		// Returns which round we are at in the decryption process. For AES decryption
		// round counts down from Nr to 0.
		GetCurrRound = curr_round;
	endfunction
	
	task LoadCt(bit [0:127] ct);
	// Populate state array with ciphertext and set loaded flag
		if (func == decrypt)
		begin
			for (int j=0; j<=3; j++)
				for (int k=0; k<=3; k++) state[k][j] = ct[(32*j+8*k)+:8];
			loaded = 1;
			done = 0;
			curr_round = Nr;	// Inverse cipher round counts down from Nr
		end
		else
			$display("#Info : aes_beh_model::LoadCt() cannot load ciphertext to encryptor.");
	endtask
	
	task LoadPt(bit [0:127] pt);
	// Populate state array with plaintext and set loaded flag
		if (func == encrypt)
		begin
			for (int j=0; j<=3; j++)
				for (int k=0; k<=3; k++) state[k][j] = pt[(32*j+8*k)+:8];
			loaded = 1;
			done = 0;
			curr_round = 0;	// Cipher round counts up from 0
		end
		else
			$display("#Info : aes_beh_model::LoadPt() cannot load plaintext to decryptor.");
	endtask
	
	function bit [0:127] GetState;
	// Returns current state as a 128-bit vector.
	// Once all rounds are completed, state contains the decrypted plaintext.
	   for (int j=0; j<=3; j++)
	       for (int k=0; k<=3; k++) GetState[(32*j+8*k)+:8] = state[k][j];
	endfunction

	function bit [0:127] GetCurrKsch;
	// Get key schedule of the current round.
	// Note that for decryption, round counts down from Nr.
		for (int j=0; j<=3; j++)
			for (int k=0; k<=3; k++) GetCurrKsch[(32*j+8*k)+:8] = keysch[curr_round*4+j][k];
	endfunction

	function bit [0:127] LookupKsch(int unsigned r);
	// Lookup key schedule for any round.
		for (int j=0; j<=3; j++)
			for (int k=0; k<=3; k++) LookupKsch[(32*j+8*k)+:8] = keysch[r*4+j][k];
	endfunction
	
	task KeyExpand(bit [0:4*8*Nk-1] key);
	// Load key to model and compute key_schedule

		int j=0;
		byte unsigned temp[0:3];
		byte unsigned Rcon[1:11] = {8'h01,8'h02,8'h04,8'h08,8'h10,8'h20,8'h40,8'h80,8'h1b,8'h36,8'h6c};
		byte unsigned kt[0:4*Nk-1];	// Array holding the key

		// Populate kt array		
		for (int i=0; i<=4*Nk-1; i++) kt[i] = key[i*8+:8];

		while (j < Nk)
		begin
			keysch[j][0] = kt[4*j];
			keysch[j][1] = kt[4*j+1];
			keysch[j][2] = kt[4*j+2];
			keysch[j][3] = kt[4*j+3];
			j++;
		end

		// Now j = Nk
		while (j < 4*(Nr+1))
		begin
			temp[0] = keysch[j-1][0];
			temp[1] = keysch[j-1][1];
			temp[2] = keysch[j-1][2];
			temp[3] = keysch[j-1][3];

			if ((j % Nk) == 0) // When j is a multiple of key length
			begin
				RotWord(temp);
				SubWord(temp);
				temp[0] ^= Rcon[j/Nk];
			end
			else if ((Nk > 6) && ((j % Nk) == 4)) // Only Nk=8 (AES256) will hit this case
				SubWord(temp);
			
			keysch[j][0] = keysch[j-Nk][0] ^ temp[0];
			keysch[j][1] = keysch[j-Nk][1] ^ temp[1];
			keysch[j][2] = keysch[j-Nk][2] ^ temp[2];
			keysch[j][3] = keysch[j-Nk][3] ^ temp[3];
			
			j++;
		end
			
	endtask
	
	protected task RotWord(inout byte unsigned x[0:3]);
		byte unsigned tmp;

		tmp = x[0];
		x[0] = x[1];
		x[1] = x[2];
		x[2] = x[3];
		x[3] = tmp;
	endtask
	
	protected function byte unsigned inv_sbox_transform(byte unsigned x);
    // Inverse Sbox transform matrix
    const byte unsigned inv_sbox[0:255] = {
    //        0     1     2     3     4     5     6     7     8     9     a     b     c     d     e     f
	//	    ===============================================================================================
	/*0*/	8'h52,8'h09,8'h6a,8'hd5,8'h30,8'h36,8'ha5,8'h38,8'hbf,8'h40,8'ha3,8'h9e,8'h81,8'hf3,8'hd7,8'hfb,
	/*1*/	8'h7c,8'he3,8'h39,8'h82,8'h9b,8'h2f,8'hff,8'h87,8'h34,8'h8e,8'h43,8'h44,8'hc4,8'hde,8'he9,8'hcb,
	/*2*/	8'h54,8'h7b,8'h94,8'h32,8'ha6,8'hc2,8'h23,8'h3d,8'hee,8'h4c,8'h95,8'h0b,8'h42,8'hfa,8'hc3,8'h4e,
	/*3*/	8'h08,8'h2e,8'ha1,8'h66,8'h28,8'hd9,8'h24,8'hb2,8'h76,8'h5b,8'ha2,8'h49,8'h6d,8'h8b,8'hd1,8'h25,
	/*4*/	8'h72,8'hf8,8'hf6,8'h64,8'h86,8'h68,8'h98,8'h16,8'hd4,8'ha4,8'h5c,8'hcc,8'h5d,8'h65,8'hb6,8'h92,
	/*5*/	8'h6c,8'h70,8'h48,8'h50,8'hfd,8'hed,8'hb9,8'hda,8'h5e,8'h15,8'h46,8'h57,8'ha7,8'h8d,8'h9d,8'h84,
	/*6*/	8'h90,8'hd8,8'hab,8'h00,8'h8c,8'hbc,8'hd3,8'h0a,8'hf7,8'he4,8'h58,8'h05,8'hb8,8'hb3,8'h45,8'h06,
	/*7*/	8'hd0,8'h2c,8'h1e,8'h8f,8'hca,8'h3f,8'h0f,8'h02,8'hc1,8'haf,8'hbd,8'h03,8'h01,8'h13,8'h8a,8'h6b,
	/*8*/	8'h3a,8'h91,8'h11,8'h41,8'h4f,8'h67,8'hdc,8'hea,8'h97,8'hf2,8'hcf,8'hce,8'hf0,8'hb4,8'he6,8'h73,
	/*9*/	8'h96,8'hac,8'h74,8'h22,8'he7,8'had,8'h35,8'h85,8'he2,8'hf9,8'h37,8'he8,8'h1c,8'h75,8'hdf,8'h6e,
	/*a*/	8'h47,8'hf1,8'h1a,8'h71,8'h1d,8'h29,8'hc5,8'h89,8'h6f,8'hb7,8'h62,8'h0e,8'haa,8'h18,8'hbe,8'h1b,
	/*b*/	8'hfc,8'h56,8'h3e,8'h4b,8'hc6,8'hd2,8'h79,8'h20,8'h9a,8'hdb,8'hc0,8'hfe,8'h78,8'hcd,8'h5a,8'hf4,
	/*c*/	8'h1f,8'hdd,8'ha8,8'h33,8'h88,8'h07,8'hc7,8'h31,8'hb1,8'h12,8'h10,8'h59,8'h27,8'h80,8'hec,8'h5f,
	/*d*/	8'h60,8'h51,8'h7f,8'ha9,8'h19,8'hb5,8'h4a,8'h0d,8'h2d,8'he5,8'h7a,8'h9f,8'h93,8'hc9,8'h9c,8'hef,
	/*e*/	8'ha0,8'he0,8'h3b,8'h4d,8'hae,8'h2a,8'hf5,8'hb0,8'hc8,8'heb,8'hbb,8'h3c,8'h83,8'h53,8'h99,8'h61,
	/*f*/	8'h17,8'h2b,8'h04,8'h7e,8'hba,8'h77,8'hd6,8'h26,8'he1,8'h69,8'h14,8'h63,8'h55,8'h21,8'h0c,8'h7d	
	};
		inv_sbox_transform = inv_sbox[x];
	endfunction

	protected function byte unsigned sbox_transform(byte unsigned x);
	// Sbox transform matrix
	const byte unsigned sbox[0:255] = {
    //        0     1     2     3     4     5     6     7     8     9     a     b     c     d     e     f
	//	    ===============================================================================================	
	/*0*/	8'h63,8'h7c,8'h77,8'h7b,8'hf2,8'h6b,8'h6f,8'hc5,8'h30,8'h01,8'h67,8'h2b,8'hfe,8'hd7,8'hab,8'h76,
    /*1*/	8'hca,8'h82,8'hc9,8'h7d,8'hfa,8'h59,8'h47,8'hf0,8'had,8'hd4,8'ha2,8'haf,8'h9c,8'ha4,8'h72,8'hc0,
    /*2*/	8'hb7,8'hfd,8'h93,8'h26,8'h36,8'h3f,8'hf7,8'hcc,8'h34,8'ha5,8'he5,8'hf1,8'h71,8'hd8,8'h31,8'h15,
	/*3*/	8'h04,8'hc7,8'h23,8'hc3,8'h18,8'h96,8'h05,8'h9a,8'h07,8'h12,8'h80,8'he2,8'heb,8'h27,8'hb2,8'h75,
    /*4*/	8'h09,8'h83,8'h2c,8'h1a,8'h1b,8'h6e,8'h5a,8'ha0,8'h52,8'h3b,8'hd6,8'hb3,8'h29,8'he3,8'h2f,8'h84,
    /*5*/	8'h53,8'hd1,8'h00,8'hed,8'h20,8'hfc,8'hb1,8'h5b,8'h6a,8'hcb,8'hbe,8'h39,8'h4a,8'h4c,8'h58,8'hcf,
    /*6*/	8'hd0,8'hef,8'haa,8'hfb,8'h43,8'h4d,8'h33,8'h85,8'h45,8'hf9,8'h02,8'h7f,8'h50,8'h3c,8'h9f,8'ha8,
    /*7*/	8'h51,8'ha3,8'h40,8'h8f,8'h92,8'h9d,8'h38,8'hf5,8'hbc,8'hb6,8'hda,8'h21,8'h10,8'hff,8'hf3,8'hd2,
    /*8*/	8'hcd,8'h0c,8'h13,8'hec,8'h5f,8'h97,8'h44,8'h17,8'hc4,8'ha7,8'h7e,8'h3d,8'h64,8'h5d,8'h19,8'h73,
    /*9*/	8'h60,8'h81,8'h4f,8'hdc,8'h22,8'h2a,8'h90,8'h88,8'h46,8'hee,8'hb8,8'h14,8'hde,8'h5e,8'h0b,8'hdb,
    /*a*/	8'he0,8'h32,8'h3a,8'h0a,8'h49,8'h06,8'h24,8'h5c,8'hc2,8'hd3,8'hac,8'h62,8'h91,8'h95,8'he4,8'h79,
    /*b*/	8'he7,8'hc8,8'h37,8'h6d,8'h8d,8'hd5,8'h4e,8'ha9,8'h6c,8'h56,8'hf4,8'hea,8'h65,8'h7a,8'hae,8'h08,
    /*c*/	8'hba,8'h78,8'h25,8'h2e,8'h1c,8'ha6,8'hb4,8'hc6,8'he8,8'hdd,8'h74,8'h1f,8'h4b,8'hbd,8'h8b,8'h8a,
    /*d*/	8'h70,8'h3e,8'hb5,8'h66,8'h48,8'h03,8'hf6,8'h0e,8'h61,8'h35,8'h57,8'hb9,8'h86,8'hc1,8'h1d,8'h9e,
    /*e*/	8'he1,8'hf8,8'h98,8'h11,8'h69,8'hd9,8'h8e,8'h94,8'h9b,8'h1e,8'h87,8'he9,8'hce,8'h55,8'h28,8'hdf,
    /*f*/	8'h8c,8'ha1,8'h89,8'h0d,8'hbf,8'he6,8'h42,8'h68,8'h41,8'h99,8'h2d,8'h0f,8'hb0,8'h54,8'hbb,8'h16
  	};
		sbox_transform = sbox[x];
	endfunction

	protected task SubBytes;
		for (int j=0; j<=3; j++)
			for (int k=0; k<=3; k++) state[j][k] = sbox_transform(state[j][k]);
	endtask

	protected task InvSubBytes;
		for (int j=0; j<=3; j++)
			for (int k=0; k<=3; k++) state[j][k] = inv_sbox_transform(state[j][k]);
	endtask

	protected task SubWord(inout byte unsigned x[0:3]);
		x[0] = sbox_transform(x[0]);
		x[1] = sbox_transform(x[1]);
		x[2] = sbox_transform(x[2]);
		x[3] = sbox_transform(x[3]);
	endtask

	protected task InvShiftRows;
		byte unsigned tmp_state[1:3][0:3];	// Row 0 of state is not shifted
		
		for (int j=1; j<=3; j++)
			for (int k=0; k<=3; k++) tmp_state[j][k] = state[j][(k+4-j)%4];
	
		for (int j=1; j<=3; j++)
			for (int k=0; k<=3; k++) state[j][k] = tmp_state[j][k];
	endtask

	protected task ShiftRows;
		byte unsigned tmp_state[1:3][0:3];	// Row 0 of state is not shifted
		
		for (int j=1; j<=3; j++)
			for (int k=0; k<=3; k++) tmp_state[j][k] = state[j][(k+j)%4];
	
		for (int j=1; j<=3; j++)
			for (int k=0; k<=3; k++) state[j][k] = tmp_state[j][k];
	endtask
	
	protected function byte unsigned xtime(byte unsigned x);
	// Multiplication by 2 over GF(256)
	// Refer to FIPS-197 spec section 4.2.1 on definition of GF(256) multiplication
		xtime = (x[7])? (x<<1) ^ 8'h1b : x<<1;
	endfunction

	protected function byte unsigned GFmul2(byte unsigned x);
	// Same as xtime(). For improved readibility only.
		GFmul2 = xtime(x);
	endfunction
	
	protected function byte unsigned GFmul3(byte unsigned x);
	// Multiply by 3 over GF(256)
	// 3*x = 2*x + x
	// Addition over GF(256) is xor
		GFmul3 = xtime(x) ^ x;
	endfunction
	
	protected function byte unsigned GFmul4(byte unsigned x);
	// Multiply by 4 over GF(256)
	// 4*x = 2*(2*x)
		GFmul4 = xtime(xtime(x));
	endfunction

	protected function byte unsigned GFmul8(byte unsigned x);
	// Multiply by 8 over GF(256)
	// 8*x = 2*(4*x)
		GFmul8 = xtime(GFmul4(x));
	endfunction

	protected function byte unsigned GFmul9(byte unsigned x);
	// Multiply by 9 over GF(256)
	// 9*x = 8*x + x
	// Addition over GF(256) is xor
		GFmul9 = GFmul8(x) ^ x;
	endfunction

	protected function byte unsigned GFmulb(byte unsigned x);
	// Multiply by 0xb over GF(256)
	// b*x = 8*x + 2*x +x
		GFmulb = GFmul8(x) ^ xtime(x) ^ x;
	endfunction

	protected function byte unsigned GFmuld(byte unsigned x);
	// Multiply by 0xd over GF(256)
	// d*x = 8*x + 4*x + x
		GFmuld = GFmul8(x) ^ GFmul4(x) ^ x;
	endfunction

	protected function byte unsigned GFmule(byte unsigned x);
	// Multiply by 0xe over GF(256)
	// e*x = 8*x + 4*x +2*x
		GFmule = GFmul8(x) ^ GFmul4(x) ^ xtime(x);
	endfunction

	protected task MixColumns;
		byte unsigned tmp_col[0:3];

		for (int j=0; j<=3; j++)
		begin
			tmp_col[0] = GFmul2(state[0][j]) ^ GFmul3(state[1][j]) ^ state[2][j] ^ state[3][j];
			tmp_col[1] = state[0][j] ^ GFmul2(state[1][j]) ^ GFmul3(state[2][j]) ^ state[3][j];
			tmp_col[2] = state[0][j] ^ state[1][j] ^ GFmul2(state[2][j]) ^ GFmul3(state[3][j]);
			tmp_col[3] = GFmul3(state[0][j]) ^ state[1][j] ^ state[2][j] ^ GFmul2(state[3][j]);
		
			state[0][j] = tmp_col[0];
			state[1][j] = tmp_col[1];
			state[2][j] = tmp_col[2];
			state[3][j] = tmp_col[3];
		end
	endtask

	protected task InvMixColumns;
		byte unsigned tmp_col[0:3];

		for (int j=0; j<=3; j++)
		begin
			tmp_col[0] = GFmule(state[0][j]) ^ GFmulb(state[1][j]) ^ GFmuld(state[2][j]) ^ GFmul9(state[3][j]);
			tmp_col[1] = GFmul9(state[0][j]) ^ GFmule(state[1][j]) ^ GFmulb(state[2][j]) ^ GFmuld(state[3][j]);
			tmp_col[2] = GFmuld(state[0][j]) ^ GFmul9(state[1][j]) ^ GFmule(state[2][j]) ^ GFmulb(state[3][j]);
			tmp_col[3] = GFmulb(state[0][j]) ^ GFmuld(state[1][j]) ^ GFmul9(state[2][j]) ^ GFmule(state[3][j]);
		
			state[0][j] = tmp_col[0];
			state[1][j] = tmp_col[1];
			state[2][j] = tmp_col[2];
			state[3][j] = tmp_col[3];
		end
	endtask
	
	protected task AddRoundKey;
		for (int j=0; j<=3; j++)
			for (int k=0; k<=3; k++) state[k][j] ^= keysch[curr_round*4+j][k];
	endtask

	task run(int mode);
	// Run cipher / inverse cipher rounds as defined in section 5.1 / 5.3 of FIPS-197 spec.
	// Model functions as cipher / inverse cipher depending on the value of the parameter func.
	//
	// Two run modes are supported
	// mode=0 -> Run from current round to completion
	// mode=1 -> Run 1 round only
	//
	// For encryption both the LoadPt() and KeyExpand() must be called first before calling run().
	// For dncryption both the LoadPt() and KeyExpand() must be called first before calling run().
	// This is to ensure the cipher / inverse cipher doesn't work on garbage.
	
		// Only continue if model is loaded and there are unfinished round(s)
		if (loaded & ~done)
		begin
			if (func == decrypt) // Model configured as decryptor
			do
			begin
				unique if (curr_round == Nr)
				begin
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].istart\t%h",Nr-curr_round,GetState);
					$display("round[%2d].ik_sch\t%h",Nr-curr_round,GetCurrKsch);
					`endif
					
					done = 0;
					AddRoundKey;
					curr_round--;
				end
				else if ((curr_round <= Nr-1) && (curr_round >= 1))
				begin
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].istart\t%h",Nr-curr_round,GetState);
					`endif
					
					InvShiftRows;
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].is_row\t%h",Nr-curr_round,GetState);
					`endif
					
					InvSubBytes;
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].is_box\t%h",Nr-curr_round,GetState);
					$display("round[%2d].ik_sch\t%h",Nr-curr_round,GetCurrKsch);
					`endif
					
					AddRoundKey;
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].ik_add\t%h",Nr-curr_round,GetState);
					`endif
					
					InvMixColumns;
					curr_round--;
				end
				else if (curr_round == 0)
				begin
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].istart\t%h",Nr-curr_round,GetState);
					`endif
					
					InvShiftRows;
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].is_row\t%h",Nr-curr_round,GetState);
					`endif
					
					InvSubBytes;
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].is_box\t%h",Nr-curr_round,GetState);
					$display("round[%2d].ik_sch\t%h",Nr-curr_round,GetCurrKsch);
					`endif
					
					AddRoundKey;
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].ioutput\t%h",Nr-curr_round,GetState);
					`endif
					
					done = 1;	// Last round completed
					loaded = 0;
				end

				if (mode == 1) break;
			end
			while (done == 0);
			
			else
			// Model configured as encryptor
			do
			begin
				unique if (curr_round == 0)
				begin
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].input\t%h",curr_round,GetState);
					$display("round[%2d].k_sch\t%h",curr_round,GetCurrKsch);
					`endif
					
					done = 0;
					AddRoundKey;
					curr_round++;
				end
				else if ((curr_round <= Nr-1) && (curr_round >= 1))
				begin
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].start\t%h",curr_round,GetState);
					`endif
					
					SubBytes;
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].s_box\t%h",curr_round,GetState);
					`endif
					
					ShiftRows;
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].s_row\t%h",curr_round,GetState);
					`endif
					
					MixColumns;
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].m_col\t%h",curr_round,GetState);
					`endif
					
					AddRoundKey;
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].k_sch\t%h",curr_round,GetCurrKsch);
					`endif
					
					curr_round++;
				end
				else if (curr_round == Nr)
				begin
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].start\t%h",curr_round,GetState);
					`endif
					
					SubBytes;
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].s_box\t%h",curr_round,GetState);
					`endif
					
					ShiftRows;
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].s_row\t%h",curr_round,GetState);
					`endif
					
					AddRoundKey;
					`ifdef INTERNAL_DEBUG
					$display("round[%2d].k_sch\t%h",curr_round,GetCurrKsch);
					$display("round[%2d].output\t%h",curr_round,GetState);
					`endif
					
					done = 1;	// Last round completed
					loaded = 0;
				end

				if (mode == 1) break;
			end
			while (done == 0);
		
		end
		// Either ciphertext is not loaded or decryption has already completed	
		else $display("#Info : aes_beh_model::run() has nothing to do");
	endtask
endclass	// aes_decrypt_model

// The following types should be used for declaration of aes class objects in your source code.
// e.g. ....
//		aes256_decrypt_t my_aes_decryptor;
//		bit [0:127] pt;
//		....
//		my_aes_decryptor = new;
//		my_aes_decryptor.KeyExpand(256'h.......);
//		my_aes_decryptor.LoadCt(128'h.........);
//		my_aes_descryptor.run(0);
//		pt = my_aes_descryptor.GetState();

typedef aes_beh_model #(.Nk(8),.Nr(14),.func(decrypt)) aes256_decrypt_t;
typedef aes_beh_model #(.Nk(6),.Nr(12),.func(decrypt)) aes192_decrypt_t;
typedef aes_beh_model #(.Nk(4),.Nr(10),.func(decrypt)) aes128_decrypt_t;

typedef aes_beh_model #(.Nk(8),.Nr(14),.func(encrypt)) aes256_encrypt_t;
typedef aes_beh_model #(.Nk(6),.Nr(12),.func(encrypt)) aes192_encrypt_t;
typedef aes_beh_model #(.Nk(4),.Nr(10),.func(encrypt)) aes128_encrypt_t;
