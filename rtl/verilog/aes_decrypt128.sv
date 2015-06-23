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
//// Wrapper for 128-bit AES decryption								////
////																////
////////////////////////////////////////////////////////////////////////
module aes_decrypt128(
	input	[0:127] kt,
	input	kt_vld,		// Active high input informing key expander that a valid new key is present at kt.
	output	kt_rdy,		// Active high output indicates decryptor ready to accept new key.
	
	input	[0:127]	ct,	// Ciphertext input
	input	ct_vld,		// Active high input indicates a valid ciphertext present on ct.
	output	ct_rdy,		// Active high output indicates decryptor ready to accept new ct.
	
	output	[0:127]	pt,	// Plaintext output
	output	pt_vld,		// Active high output indicates valid plaintext available on pt.
	
	input	clk,
	input	rst
	);
	
	// Decryptor side
	wire	[0:127]	rkey_decrypt;
	wire	rkey_vld_decrypt;
	wire	next_rkey_decrypt;
	
	// Key Expander side
	wire	[0:127]	rkey_keyexp;
	wire	rkey_vld_keyexp;
	
	(* KEEP_HIRARACHY = "yes" *) KschBuffer KschBuffer_u(.rkey_in(rkey_keyexp),
							.rkey_vld_in(rkey_vld_keyexp),
							.rkey_out(rkey_decrypt),
							.rkey_vld_out(rkey_vld_decrypt),
							.next_rkey(next_rkey_decrypt),
							.klen_sel(2'b00),
							.clk(clk),
							.rst(rst)
							);
							
	(* KEEP_HIRARACHY = "yes" *) KeyExpand128 KeyExpand128_u(
							.kt(kt),
							.kt_vld(kt_vld),
							.kt_rdy(kt_rdy),
							.rkey(rkey_keyexp),
							.rkey_vld(rkey_vld_keyexp),
							.rkey_last(),
							.clk(clk),
							.rst(rst)
							);
							
	(* KEEP_HIRARACHY = "yes" *) decrypt decrypt_u(	.ct(ct),
					.ct_vld(ct_vld),
					.ct_rdy(ct_rdy),
					.rkey(rkey_decrypt),
					.rkey_vld(rkey_vld_decrypt),
					.next_rkey(next_rkey_decrypt),
					.pt(pt),
					.pt_vld(pt_vld),
					.klen_sel(2'b00),
					.clk(clk),
					.rst(rst)
					);
endmodule
