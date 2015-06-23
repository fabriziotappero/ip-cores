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
//// InvMixColumns() as defined in section 5.3.3 of FIPS-197 spec,	////
//// or feed input through to output when bypass=1.					////
////																////
//// Feed through is used during the first and last round where		////
//// InvMixColumns() is not needed.									////
////																////
////////////////////////////////////////////////////////////////////////
module InvMixColumns(
	input	[0:127]	din,
	output	[0:127]	dout,
	input	bypass);
	
	wire	[0:31]	newcol [0:3];

	// 4 instances of InvMixCol_slice, each computes one column of InvMixColumns()
	//  as defined in section 5.3.3 of FIPS-197 spec.
	genvar j;
	generate
		for (j=0; j<4; j++)	
			InvMixCol_slice i_mixcol_u
				(
				.S0c(din[(32*j)+:8]),
				.S1c(din[(32*j + 8)+:8]),
				.S2c(din[(32*j + 16)+:8]),
				.S3c(din[(32*j + 24)+:8]),
				.bypass(bypass),
				.new_S(newcol[j])
				);
	endgenerate
				
	assign dout = {newcol[0], newcol[1],newcol[2], newcol[3]};		
endmodule
