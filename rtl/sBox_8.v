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

//Reference: A Very Compact Rijndael S-box, D. Canright

module sBox_8
(
  //OUTPUTS
  output [7:0] sbox_out_enc, // Direct SBOX
	output [7:0] sbox_out_dec, // Inverse SBOX
  //INPUTS
  input  [7:0] sbox_in,
	input enc_dec,
	input clk
);
//`include "include/sbox_functions.vf"

// Functions used by SBOX Logic
// For more detail, see "A Very Compact Rijndael  S-Box" by D. Canright
localparam ENC = 1;
localparam DEC = 0;

function [1:0] gf_sq_2;
	input [1:0] in;
	begin
  	gf_sq_2 = {in[0], in[1]};
	end
endfunction

function [1:0] gf_sclw_2;
	input [1:0] in;
	begin
  	gf_sclw_2 = {^in, in[1]};
  end
endfunction

function [1:0] gf_sclw2_2;
	input [1:0] in;
	begin
  	gf_sclw2_2 = {in[0], ^in};
  end
endfunction

function [1:0] gf_muls_2;
	input [1:0] in1, in2;
  input in3, in4;
	begin
  	gf_muls_2 = ( ~(in1 & in2) ) ^ ( {2{~(in3 & in4)}} );
  end
endfunction

function [1:0] gf_muls_scl_2;
  input [1:0] in1, in2;
  input in3, in4;
	reg [1:0] nand_in1_in2;
  reg nand_in3_in4;
	begin
  	nand_in1_in2 = ~(in1 & in2);
  	nand_in3_in4 = ~(in3 & in4);
  	gf_muls_scl_2 = {nand_in3_in4 ^ nand_in1_in2[0], ^nand_in1_in2};
  end
endfunction

function [3:0] gf_inv_4;
  input [3:0] in;
	reg [1:0] in_hg;
	reg [1:0] in_lw;
	reg [1:0] out_gf_mul_2;
	reg [1:0] out_gf_mul_3;
	reg [1:0] out_gf_sq2_3;
	reg [1:0] in_sq2_3;
	reg xor_in_hg, xor_in_lw;
	begin
		in_hg = in[3:2];
		in_lw = in[1:0];
		xor_in_hg = ^in_hg;
		xor_in_lw = ^in_lw;
		in_sq2_3 = {~(in_hg[1] | in_lw[1]) ^ (~(xor_in_hg & xor_in_lw)), ~(xor_in_hg | xor_in_lw) ^ (~(in_hg[0] & in_lw[0]))};
 
  	out_gf_sq2_3 = gf_sq_2(in_sq2_3);
 		out_gf_mul_2 = gf_muls_2(out_gf_sq2_3, in_lw, ^out_gf_sq2_3, xor_in_lw);
		out_gf_mul_3 = gf_muls_2(out_gf_sq2_3, in_hg, ^out_gf_sq2_3, xor_in_hg);
 		
		gf_inv_4 = {out_gf_mul_2, out_gf_mul_3};
 end
endfunction


function [3:0] gf_sq_scl_4;
  input [3:0] in;
	reg [1:0] in_hg;
	reg [1:0] in_lw;
	reg [1:0] out_gf_sq2_1;
	reg [1:0] out_gf_sq2_2;
	reg [1:0] out_gf_sclw2_1;
	begin
		in_hg = in[3:2];
		in_lw = in[1:0];
		
		out_gf_sq2_1 = gf_sq_2(in_hg ^ in_lw );
 		out_gf_sq2_2 = gf_sq_2(in_lw);
 		out_gf_sclw2_1 = gf_sclw_2(out_gf_sq2_2);
 
 		gf_sq_scl_4 = {out_gf_sq2_1, out_gf_sclw2_1};
	end
endfunction


function [3:0] gf_muls_4;
  input [3:0] in1;
  input [3:0] in2;	
	reg [1:0] in1_hg;
	reg [1:0] in1_lw;
	reg [1:0] in2_hg;
	reg [1:0] in2_lw;
	reg [1:0] xor_in1_hl;
	reg [1:0] xor_in2_hl;
	reg [1:0] out_gf_mul_1;
	reg [1:0] out_gf_mul_2;
	reg [1:0] out_gf_mul_scl_1;
	begin
 		in1_hg = in1[3:2];
		in1_lw = in1[1:0];
 		in2_hg = in2[3:2];
 		in2_lw = in2[1:0];
 		xor_in1_hl = in1_hg ^ in1_lw;
 		xor_in2_hl = in2_hg ^ in2_lw;

		out_gf_mul_1 = gf_muls_2(in1_hg, in2_hg, in1[3] ^ in1[2], in2[3] ^ in2[2]);
 		out_gf_mul_2 = gf_muls_2(in1_lw, in2_lw, in1[1] ^ in1[0], in2[1] ^ in2[0]);
		out_gf_mul_scl_1 = gf_muls_scl_2(xor_in1_hl, xor_in2_hl, ^xor_in1_hl, ^xor_in2_hl);
 
  	gf_muls_4 = {out_gf_mul_1 ^ out_gf_mul_scl_1,  out_gf_mul_2 ^ out_gf_mul_scl_1};
	end
endfunction

function [3:0] gf_inv_8_stage1;
  input [7:0] in;
	reg [3:0] in_hg;
	reg [3:0] in_lw;
	reg [3:0] out_gf_mul4_2;
	reg [3:0] out_gf_mul4_3;
	reg [3:0] out_gf_inv4_2;
	reg c1, c2, c3;
	begin
		in_hg = in[7:4];
		in_lw = in[3:0];
          
 		c1 = ~((in_hg[3] ^ in_hg[2]) & (in_lw[3] ^ in_lw[2]));
 		c2 = ~((in_hg[2] ^ in_hg[0]) & (in_lw[2] ^ in_lw[0]));
 		c3 = ~((^in_hg) & (^in_lw));

 		gf_inv_8_stage1 = 
				 {(~((in_hg[2] ^ in_hg[0]) | (in_lw[2] ^ in_lw[0])) ^ (~(in_hg[3] & in_lw[3]))) ^ c1 ^ c3, 
          (~((in_hg[3] ^ in_hg[1]) | (in_lw[3] ^ in_lw[1])) ^ (~(in_hg[2] & in_lw[2]))) ^ c1 ^ c2, 
          (~((in_hg[1] ^ in_hg[0]) | (in_lw[1] ^ in_lw[0])) ^ (~(in_hg[1] & in_lw[1]))) ^ c2 ^ c3, 
          ((~(in_hg[0] | in_lw[0])) ^ (~((in_hg[1] ^ in_hg[0]) & (in_lw[1] ^ in_lw[0])))) ^ (~((in_hg[3] ^ in_hg[1]) & (in_lw[3] ^ in_lw[1]))) ^ c2}; 
	end
endfunction

function [7:0] gf_inv_8_stage2;
  input [7:0] in;
	input [3:0] c;
	reg [3:0] in_hg;
	reg [3:0] in_lw;
	reg [3:0] out_gf_mul4_2;
	reg [3:0] out_gf_mul4_3;
	reg [3:0] out_gf_inv4_2;
	reg c1, c2, c3;
	begin
		in_hg = in[7:4];
		in_lw = in[3:0];
          
		out_gf_inv4_2 = gf_inv_4(c);
		out_gf_mul4_2 = gf_muls_4(out_gf_inv4_2, in_lw);
		out_gf_mul4_3 = gf_muls_4(out_gf_inv4_2, in_hg);

 		gf_inv_8_stage2 = {out_gf_mul4_2, out_gf_mul4_3};
	end
endfunction

function [15:0] isomorphism;
  input [7:0] in;
  reg r1, r2, r3, r4, r5, r6, r7, r8, r9;
  reg [7:0] enc, dec;
  begin
    r1 = in[7]  ^ in[5];
    r2 = in[7] ~^ in[4];
    r3 = in[6]  ^ in[0];
    r4 = in[5] ~^ r3;
    r5 = in[4]  ^ r4;
    r6 = in[3]  ^ in[0];
    r7 = in[2]  ^ r1;
    r8 = in[1]  ^ r3;
    r9 = in[3]  ^ r8;
    
    enc = {r7 ~^ r8, r5, in[1] ^ r4, r1 ~^ r3, in[1] ^ r2 ^ r6, ~in[0], r4, in[2] ~^ r9};
    dec = {r2, in[4] ^ r8, in[6] ^ in[4], r9, in[6] ~^ r2, r7, in[4] ^ r6, in[1] ^ r5};
    
    isomorphism = {enc, dec};
  end
endfunction

function [7:0] isomorphism_inv;
  input [7:0] in;
	input op_type;
  reg r1, r2, r3, r4, r5, r6, r7, r8, r9, r10;
  begin
    r1  = in[7]  ^ in[3];
    r2  = in[6]  ^ in[4];
    r3  = in[6]  ^ in[0];
    r4  = in[5] ~^ in[3];
    r5  = in[5] ~^ r1;
    r6  = in[5] ~^ in[1];
    r7  = in[4] ~^ r6;
    r8  = in[2]  ^ r4;
    r9  = in[1]  ^ r2;
    r10 = r3     ^ r5;
    
		if(op_type == ENC)
    	isomorphism_inv = {r4, r1, r3, r5, r2 ^ r5, r3 ^ r8, r7, r9};
		else
    	isomorphism_inv = {in[4] ~^ in[1], in[1] ^ r10, in[2] ^ r10, in[6] ~^ in[1], r8 ^ r9, in[7] ~^ r7, r6, ~in[2]};
    
  end
endfunction




wire [7:0] base_new_enc, base_new_dec, base_new;
//wire [7:0] base_enc, base_dec;
wire [3:0] out_gf_inv8_stage1;
wire [7:0] out_gf_inv8_1;
//wire [7:0] out_gf_inv8_2;

reg [3:0] out_gf_pp;
reg [7:0] base_new_pp;

assign {base_new_enc, base_new_dec} = isomorphism(sbox_in);

assign base_new = ~(enc_dec ? base_new_enc : base_new_dec);
assign out_gf_inv8_stage1 = gf_inv_8_stage1(base_new);

always @(posedge clk)
	begin
		out_gf_pp <= out_gf_inv8_stage1;
		base_new_pp <= base_new;
	end

assign out_gf_inv8_1 = gf_inv_8_stage2(base_new_pp, out_gf_pp);				
	
assign sbox_out_enc = ~isomorphism_inv(out_gf_inv8_1, ENC);
assign sbox_out_dec = ~isomorphism_inv(out_gf_inv8_1, DEC);

endmodule
