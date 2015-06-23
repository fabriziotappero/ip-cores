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
//// This module implements the Galois field multipliers			////
//// for x2, x3, x9, xb, xd, xe. Used in InvMixCol_slice.			////
//// See section 4.2 of FIPS-197 specification for details.			////
////																////
////////////////////////////////////////////////////////////////////////
module gfmul_inv(
	input	[7:0]	d,
	output	[7:0]	x2,
	output	[7:0]	x3,
	output	[7:0]	x9,
	output	[7:0]	xb,
	output	[7:0]	xd,
	output	[7:0]	xe
	);
	// Multiplier over GF(256)
	// Generates -	x2, 3 for cipher
	//			 -	x9, xb, xd, xe for inverse cipher
	
	function byte unsigned xtime(byte unsigned x);
	// Multiplication by 2 over GF(256)
	// Refer to FIPS-197 spec section 4.2.1 on definition of GF(256) multiplication
		xtime = (x[7])? (x<<1) ^ 8'h1b : x<<1;
	endfunction

	function byte unsigned GFmul3(byte unsigned x);
	// Multiply by 3 over GF(256)
	// 3*x = 2*x +x
		GFmul3 = xtime(x) ^ x;
	endfunction
	
	function byte unsigned GFmul4(byte unsigned x);
	// Multiply by 4 over GF(256)
	// 4*x = 2*(2*x)
		GFmul4 = xtime(xtime(x));
	endfunction

	function byte unsigned GFmul8(byte unsigned x);
	// Multiply by 8 over GF(256)
	// 8*x = 2*(4*x)
		GFmul8 = xtime(GFmul4(x));
	endfunction

	function byte unsigned GFmul9(byte unsigned x);
	// Multiply by 9 over GF(256)
	// 9*x = 8*x + x
	// Addition over GF(256) is xor
		GFmul9 = GFmul8(x) ^ x;
	endfunction

	function byte unsigned GFmulb(byte unsigned x);
	// Multiply by 0xb over GF(256)
	// b*x = 8*x + 2*x +x
		GFmulb = GFmul8(x) ^ xtime(x) ^ x;
	endfunction

	function byte unsigned GFmuld(byte unsigned x);
	// Multiply by 0xd over GF(256)
	// d*x = 8*x + 4*x + x
		GFmuld = GFmul8(x) ^ GFmul4(x) ^ x;
	endfunction

	function byte unsigned GFmule(byte unsigned x);
	// Multiply by 0xe over GF(256)
	// e*x = 8*x + 4*x +2*x
		GFmule = GFmul8(x) ^ GFmul4(x) ^ xtime(x);
	endfunction
	
	assign x2 = xtime(d);
	assign x3 = GFmul3(d);
	assign x9 = GFmul9(d);
	assign xb = GFmulb(d);
	assign xd = GFmuld(d);
	assign xe = GFmule(d);
	
endmodule