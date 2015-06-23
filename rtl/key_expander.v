//////////////////////////////////////////////////////////////////
////
////
//// 	AES CORE BLOCK
////
////
////
//// This file is part of the APB to I2C project
////
//// http://www.opencores.org/cores/apbi2c/
////
////
////
//// Description
////
//// Implementation of APB IP core according to
////
//// aes128_spec IP core specification document.
////
////
////
//// To Do: Things are right here but always all block can suffer changes
////
////
////
////
////
//// Author(s): - Felipe Fernandes Da Costa, fefe2560@gmail.com
////		  Julio Cesar 
////
///////////////////////////////////////////////////////////////// 
////
////
//// Copyright (C) 2009 Authors and OPENCORES.ORG
////
////
////
//// This source file may be used and distributed without
////
//// restriction provided that this copyright statement is not
////
//// removed from the file and that any derivative work contains
//// the original copyright notice and the associated disclaimer.
////
////
//// This source file is free software; you can redistribute it
////
//// and/or modify it under the terms of the GNU Lesser General
////
//// Public License as published by the Free Software Foundation;
//// either version 2.1 of the License, or (at your option) any
////
//// later version.
////
////
////
//// This source is distributed in the hope that it will be
////
//// useful, but WITHOUT ANY WARRANTY; without even the implied
////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
////
//// PURPOSE. See the GNU Lesser General Public License for more
//// details.
////
////
////
//// You should have received a copy of the GNU Lesser General
////
//// Public License along with this source; if not, download it
////
//// from http://www.opencores.org/lgpl.shtml
////
////
///////////////////////////////////////////////////////////////////
module key_expander
(
	// OUTPUTS
	output  [127:0] key_out,
	output  [ 31:0] g_in,
	// INPUTS
	input  [ 31:0] g_out,
	input  [127:0] key_in,
	input  [  3:0] round,
	input add_w_out,
	input enc_dec
);

localparam integer KEY_WIDTH = 32;
localparam integer KEY_NUM   = 4;
localparam integer WORD      = 8;
localparam integer ROUNDS    = 10;

wire  [KEY_WIDTH - 1 : 0] key   [0 : KEY_NUM - 1];
wire  [     WORD - 1 : 0] rot_in[0 : KEY_NUM - 1];
wire  [KEY_WIDTH - 1 : 0] g_func;
reg   [     WORD - 1 : 0] rc_dir, rc_inv;
wire  [     WORD - 1 : 0] rc;

//=====================================================================================
// Key Generation
//=====================================================================================
generate
	genvar i;
	for(i = 0; i < KEY_NUM; i = i + 1)
	begin:KG
			assign key[KEY_NUM - 1 - i] = key_in[KEY_WIDTH*(i + 1) - 1 : KEY_WIDTH*i];
	end
endgenerate

//=====================================================================================
// Key Out Generation
//=====================================================================================
generate
	genvar j;
	for(j = 0; j < KEY_NUM; j = j + 1)
	begin:KGO
			if(j == 0)
				assign key_out[KEY_WIDTH*(KEY_NUM - j) - 1 : KEY_WIDTH*(KEY_NUM - j - 1)] = key[j] ^ g_func;
			else
				if(j == 1)
					assign key_out[KEY_WIDTH*(KEY_NUM - j) - 1 : KEY_WIDTH*(KEY_NUM - j - 1)] = (add_w_out) ? key[j] ^ key[j - 1] ^ g_func : key[j] ^ key[j - 1];
				else
					assign key_out[KEY_WIDTH*(KEY_NUM - j) - 1 : KEY_WIDTH*(KEY_NUM - j - 1)] = key[j] ^ key[j - 1];
	end
endgenerate

//=====================================================================================
// G Function Input Generation
//=====================================================================================
generate
	genvar k;
	for(k = 0; k < KEY_NUM; k = k + 1)
	begin:GFIG
		assign rot_in[k] = (enc_dec) ? key[KEY_NUM - 1][WORD*(k + 1) - 1 : WORD*k] : key[KEY_NUM - 1][WORD*(k + 1) - 1 : WORD*k] ^ key[KEY_NUM - 2][WORD*(k + 1) - 1 : WORD*k];
	end
endgenerate

generate
	genvar l;
	for(l = 0; l < KEY_NUM; l = l + 1)
	begin:GFIG1
		assign g_in[WORD*(l + 1) - 1 : WORD*l] = rot_in[(KEY_NUM + l - 1)%KEY_NUM];
	end
endgenerate

//=====================================================================================
// G Functin Output Processsing
//=====================================================================================
assign g_func = {g_out[KEY_WIDTH - 1 : KEY_WIDTH - WORD] ^ rc, g_out[KEY_WIDTH - WORD - 1 : 0]};

assign rc = (enc_dec) ? rc_dir : rc_inv;

always @(*)
	begin: RC_DIR
		integer i;
		for(i = 0; i < ROUNDS; i = i + 1)
			if(round == 8)
				rc_dir = 8'h1b;
			else 
			if(round == 9)
				rc_dir = 8'h36;
			else
				rc_dir = 8'h01 << round;
	end

always @(*)
	begin: RC_INV
		integer i;
		for(i = 0; i < ROUNDS; i = i + 1)
			if(round == 1)
				rc_inv = 8'h1b;
			else 
			if(round == 0)
				rc_inv = 8'h36;
			else
				rc_inv = 8'h80 >> (round - 2);
	end
endmodule
