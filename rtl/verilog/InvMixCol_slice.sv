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
//// This module computes one column of the InvMixColumns() defined	////
//// in section 5.3.3 in FIPS-197 specification.					////
//// 																////
////////////////////////////////////////////////////////////////////////
module InvMixCol_slice(
	input	[7:0]	S0c,
	input	[7:0]	S1c,
	input	[7:0]	S2c,
	input	[7:0]	S3c,
	input	bypass,
	output	[31:0]	new_S);
	
	wire	[7:0]	S0cx9, S0cxb, S0cxd, S0cxe;
	wire	[7:0]	S1cx9, S1cxb, S1cxd, S1cxe;
	wire	[7:0]	S2cx9, S2cxb, S2cxd, S2cxe;
	wire	[7:0]	S3cx9, S3cxb, S3cxd, S3cxe;
	
	wire	[7:0]	sum0, sum1, sum2, sum3;

	// GF multipliers to generate products for x9, xb, xd, xe
	gfmul_inv gfmul_inv_u0(.d(S0c), .x2(), .x3(), .x9(S0cx9), .xb(S0cxb), .xd(S0cxd), .xe(S0cxe));
	gfmul_inv gfmul_inv_u1(.d(S1c), .x2(), .x3(), .x9(S1cx9), .xb(S1cxb), .xd(S1cxd), .xe(S1cxe));
	gfmul_inv gfmul_inv_u2(.d(S2c), .x2(), .x3(), .x9(S2cx9), .xb(S2cxb), .xd(S2cxd), .xe(S2cxe));
	gfmul_inv gfmul_inv_u3(.d(S3c), .x2(), .x3(), .x9(S3cx9), .xb(S3cxb), .xd(S3cxd), .xe(S3cxe));
	
	// Compute InvMixColumns according to section 5.3.3 of FIPS-197 spec.
	// Feed input through directly when bypass=1.	
	assign sum0 = bypass ? S0c : S0cxe ^ S1cxb ^ S2cxd ^ S3cx9;
	assign sum1 = bypass ? S1c : S0cx9 ^ S1cxe ^ S2cxb ^ S3cxd;
	assign sum2 = bypass ? S2c : S0cxd ^ S1cx9 ^ S2cxe ^ S3cxb;
	assign sum3 = bypass ? S3c : S0cxb ^ S1cxd ^ S2cx9 ^ S3cxe;
	
	assign new_S = {sum0, sum1, sum2, sum3};
endmodule
