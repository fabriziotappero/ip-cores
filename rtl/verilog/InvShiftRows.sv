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
//// The file contains the definition of the InvShiftRows			////
//// transformation in section 5.3.1 of the FIPS-197 specification.	////
////																////
////////////////////////////////////////////////////////////////////////

module InvShiftRows(
	input [0:127] din,
	output [0:127] dout);
	
	wire [0:7] S00, S01, S02, S03;
	wire [0:7] S10, S11, S12, S13;
	wire [0:7] S20, S21, S22, S23;
	wire [0:7] S30, S31, S32, S33;
	
	wire [0:7] S_00, S_01, S_02, S_03;
	wire [0:7] S_10, S_11, S_12, S_13;
	wire [0:7] S_20, S_21, S_22, S_23;
	wire [0:7] S_30, S_31, S_32, S_33;
	
	assign S00 = din[0+:8]; assign S01 = din[32+:8]; assign S02 = din[64+:8]; assign S03 = din[96+:8];
	assign S10 = din[8+:8]; assign S11 = din[40+:8]; assign S12 = din[72+:8]; assign S13 = din[104+:8];
	assign S20 = din[16+:8]; assign S21 = din[48+:8]; assign S22 = din[80+:8]; assign S23 = din[112+:8];
	assign S30 = din[24+:8]; assign S31 = din[56+:8]; assign S32 = din[88+:8]; assign S33 = din[120+:8];
	
	assign S_00 = S00; assign S_01 = S01; assign S_02 = S02; assign S_03 = S03;
	assign S_10 = S13; assign S_11 = S10; assign S_12 = S11; assign S_13 = S12;
	assign S_20 = S22; assign S_21 = S23; assign S_22 = S20; assign S_23 = S21;
	assign S_30 = S31; assign S_31 = S32; assign S_32 = S33; assign S_33 = S30;

	assign dout = {	S_00, S_10, S_20, S_30,	S_01, S_11, S_21, S_31,	S_02, S_12, S_22, S_32,	S_03, S_13, S_23, S_33};
endmodule