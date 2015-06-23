//////////////////////////////////////////////////////////////////////
////                                                              ////
////  This file is part of the "10GE LL MAC" project              ////
////  http://www.opencores.org/cores/xge_ll_mac/                  ////
////                                                              ////
////  This project is derived from the "10GE MAC" project of      ////
////  A. Tanguay (antanguay@opencores.org) by Andreas Peters      ////
////  for his Diploma Thesis at the University of Heidelberg.     ////
////  The Thesis was supervised by Christian Leber                ////
////                                                              ////
////  Author(s):                                                  ////
////      - Andreas Peters                                        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008-2012 AUTHORS. All rights reserved.        ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////


`ifndef OC_MAC_CRC_FUNC
`define OC_MAC_CRC_FUNC


function [31:0] next_crc32_data64_be;
	
	input [63:0] inp;
	input [31:0] crc;	
	input [2:0] be; // 0 for all valid, 1 for data[31:8]
	// (3 valid bytes).
	case (be)
		3'b000: begin
				next_crc32_data64_be =	nextCRC32_D64(inp, crc);
			end
		3'b001: begin
				next_crc32_data64_be =	nextCRC32_D8(inp[63:56], crc);
			end
		3'b010: begin
				next_crc32_data64_be =	nextCRC32_D16(inp[63:48], crc);
			end
		3'b011: begin
				next_crc32_data64_be =	nextCRC32_D24(inp[63:40], crc);
			end
		3'b100: begin
				next_crc32_data64_be =	nextCRC32_D32(inp[63:32], crc);
			end
		3'b101: begin
				next_crc32_data64_be =	nextCRC32_D40(inp[63:24], crc);
			end
		3'b110: begin
				next_crc32_data64_be =	nextCRC32_D48(inp[63:16], crc);
			end
		3'b111: begin
				next_crc32_data64_be =	nextCRC32_D56(inp[63:8], crc);
			end
		default: begin
				next_crc32_data64_be =	nextCRC32_D64(inp, crc);
			end			
	endcase


	
endfunction

function [31:0] nextCRC32_D8;

	input [7:0] Data;
	input [31:0] CRC;

	begin

		nextCRC32_D8[0] = Data[6] ^ Data[0] ^ CRC[24] ^ CRC[30];
		nextCRC32_D8[1] = Data[7] ^ Data[6] ^ Data[1] ^ Data[0] ^ CRC[24] ^ CRC[25] ^ CRC[30] ^ 
			CRC[31];
		nextCRC32_D8[2] = Data[7] ^ Data[6] ^ Data[2] ^ Data[1] ^ Data[0] ^ CRC[24] ^ CRC[25] ^ 
			CRC[26] ^ CRC[30] ^ CRC[31];
		nextCRC32_D8[3] = Data[7] ^ Data[3] ^ Data[2] ^ Data[1] ^ CRC[25] ^ CRC[26] ^ CRC[27] ^ 
			CRC[31];
		nextCRC32_D8[4] = Data[6] ^ Data[4] ^ Data[3] ^ Data[2] ^ Data[0] ^ CRC[24] ^ CRC[26] ^ 
			CRC[27] ^ CRC[28] ^ CRC[30];
		nextCRC32_D8[5] = Data[7] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ CRC[24] ^ 
			CRC[25] ^ CRC[27] ^ CRC[28] ^ CRC[29] ^ CRC[30] ^ CRC[31];
		nextCRC32_D8[6] = Data[7] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ CRC[25] ^ CRC[26] ^ 
			CRC[28] ^ CRC[29] ^ CRC[30] ^ CRC[31];
		nextCRC32_D8[7] = Data[7] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[0] ^ CRC[24] ^ CRC[26] ^ 
			CRC[27] ^ CRC[29] ^ CRC[31];
		nextCRC32_D8[8] = Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ CRC[0] ^ CRC[24] ^ CRC[25] ^ 
			CRC[27] ^ CRC[28];
		nextCRC32_D8[9] = Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ CRC[1] ^ CRC[25] ^ CRC[26] ^ 
			CRC[28] ^ CRC[29];
		nextCRC32_D8[10] = Data[5] ^ Data[3] ^ Data[2] ^ Data[0] ^ CRC[2] ^ CRC[24] ^ CRC[26] ^ 
				CRC[27] ^ CRC[29];
		nextCRC32_D8[11] = Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ CRC[3] ^ CRC[24] ^ CRC[25] ^ 
				CRC[27] ^ CRC[28];
		nextCRC32_D8[12] = Data[6] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ Data[0] ^ CRC[4] ^ CRC[24] ^ 
				CRC[25] ^ CRC[26] ^ CRC[28] ^ CRC[29] ^ CRC[30];
		nextCRC32_D8[13] = Data[7] ^ Data[6] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[1] ^ CRC[5] ^ CRC[25] ^ 
				CRC[26] ^ CRC[27] ^ CRC[29] ^ CRC[30] ^ CRC[31];
		nextCRC32_D8[14] = Data[7] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[2] ^ CRC[6] ^ CRC[26] ^ CRC[27] ^ 
				CRC[28] ^ CRC[30] ^ CRC[31];
		nextCRC32_D8[15] = Data[7] ^ Data[5] ^ Data[4] ^ Data[3] ^ CRC[7] ^ CRC[27] ^ CRC[28] ^ 
				CRC[29] ^ CRC[31];
		nextCRC32_D8[16] = Data[5] ^ Data[4] ^ Data[0] ^ CRC[8] ^ CRC[24] ^ CRC[28] ^ CRC[29];
		nextCRC32_D8[17] = Data[6] ^ Data[5] ^ Data[1] ^ CRC[9] ^ CRC[25] ^ CRC[29] ^ CRC[30];
		nextCRC32_D8[18] = Data[7] ^ Data[6] ^ Data[2] ^ CRC[10] ^ CRC[26] ^ CRC[30] ^ CRC[31];
		nextCRC32_D8[19] = Data[7] ^ Data[3] ^ CRC[11] ^ CRC[27] ^ CRC[31];
		nextCRC32_D8[20] = Data[4] ^ CRC[12] ^ CRC[28];
		nextCRC32_D8[21] = Data[5] ^ CRC[13] ^ CRC[29];
		nextCRC32_D8[22] = Data[0] ^ CRC[14] ^ CRC[24];
		nextCRC32_D8[23] = Data[6] ^ Data[1] ^ Data[0] ^ CRC[15] ^ CRC[24] ^ CRC[25] ^ CRC[30];
		nextCRC32_D8[24] = Data[7] ^ Data[2] ^ Data[1] ^ CRC[16] ^ CRC[25] ^ CRC[26] ^ CRC[31];
		nextCRC32_D8[25] = Data[3] ^ Data[2] ^ CRC[17] ^ CRC[26] ^ CRC[27];
		nextCRC32_D8[26] = Data[6] ^ Data[4] ^ Data[3] ^ Data[0] ^ CRC[18] ^ CRC[24] ^ CRC[27] ^ 
				CRC[28] ^ CRC[30];
		nextCRC32_D8[27] = Data[7] ^ Data[5] ^ Data[4] ^ Data[1] ^ CRC[19] ^ CRC[25] ^ CRC[28] ^ 
				CRC[29] ^ CRC[31];
		nextCRC32_D8[28] = Data[6] ^ Data[5] ^ Data[2] ^ CRC[20] ^ CRC[26] ^ CRC[29] ^ CRC[30];
		nextCRC32_D8[29] = Data[7] ^ Data[6] ^ Data[3] ^ CRC[21] ^ CRC[27] ^ CRC[30] ^ CRC[31];
		nextCRC32_D8[30] = Data[7] ^ Data[4] ^ CRC[22] ^ CRC[28] ^ CRC[31];
		nextCRC32_D8[31] = Data[5] ^ CRC[23] ^ CRC[29];

	end

endfunction

function [31:0] nextCRC32_D16;

	input [15:0] Data;
	input [31:0] crc;

	begin
		nextCRC32_D16[0] = Data[12] ^ Data[10] ^ Data[9] ^ Data[6] ^ Data[0] ^ crc[16] ^ crc[22] ^ crc[25] ^ crc[26] ^ crc[28];
		nextCRC32_D16[1] = Data[13] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[7] ^ Data[6] ^ Data[1] ^ Data[0] ^ crc[16] ^ crc[17] ^ crc[22] ^ crc[23] ^ crc[25] ^ crc[27] ^ crc[28] ^ crc[29];
		nextCRC32_D16[2] = Data[14] ^ Data[13] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[2] ^ Data[1] ^ Data[0] ^ crc[16] ^ crc[17] ^ crc[18] ^ crc[22] ^ crc[23] ^ crc[24] ^ crc[25] ^ crc[29] ^ crc[30];
		nextCRC32_D16[3] = Data[15] ^ Data[14] ^ Data[10] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[3] ^ Data[2] ^ Data[1] ^ crc[17] ^ crc[18] ^ crc[19] ^ crc[23] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[30] ^ crc[31];
		nextCRC32_D16[4] = Data[15] ^ Data[12] ^ Data[11] ^ Data[8] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[16] ^ crc[18] ^ crc[19] ^ crc[20] ^ crc[22] ^ crc[24] ^ crc[27] ^ crc[28] ^ crc[31];
		nextCRC32_D16[5] = Data[13] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[16] ^ crc[17] ^ crc[19] ^ crc[20] ^ crc[21] ^ crc[22] ^ crc[23] ^ crc[26] ^ crc[29];
		nextCRC32_D16[6] = Data[14] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ crc[17] ^ crc[18] ^ crc[20] ^ crc[21] ^ crc[22] ^ crc[23] ^ crc[24] ^ crc[27] ^ crc[30];
		nextCRC32_D16[7] = Data[15] ^ Data[10] ^ Data[8] ^ Data[7] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[16] ^ crc[18] ^ crc[19] ^ crc[21] ^ crc[23] ^ crc[24] ^ crc[26] ^ crc[31];
		nextCRC32_D16[8] = Data[12] ^ Data[11] ^ Data[10] ^ Data[8] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[16] ^ crc[17] ^ crc[19] ^ crc[20] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[28];
		nextCRC32_D16[9] = Data[13] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ crc[17] ^ crc[18] ^ crc[20] ^ crc[21] ^ crc[25] ^ crc[27] ^ crc[28] ^ crc[29];
		nextCRC32_D16[10] = Data[14] ^ Data[13] ^ Data[9] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[16] ^ crc[18] ^ crc[19] ^ crc[21] ^ crc[25] ^ crc[29] ^ crc[30];
		nextCRC32_D16[11] = Data[15] ^ Data[14] ^ Data[12] ^ Data[9] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[16] ^ crc[17] ^ crc[19] ^ crc[20] ^ crc[25] ^ crc[28] ^ crc[30] ^ crc[31];
		nextCRC32_D16[12] = Data[15] ^ Data[13] ^ Data[12] ^ Data[9] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ Data[0] ^ crc[16] ^ crc[17] ^ crc[18] ^ crc[20] ^ crc[21] ^ crc[22] ^ crc[25] ^ crc[28] ^ crc[29] ^ crc[31];
		nextCRC32_D16[13] = Data[14] ^ Data[13] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[1] ^ crc[17] ^ crc[18] ^ crc[19] ^ crc[21] ^ crc[22] ^ crc[23] ^ crc[26] ^ crc[29] ^ crc[30];
		nextCRC32_D16[14] = Data[15] ^ Data[14] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[2] ^ crc[18] ^ crc[19] ^ crc[20] ^ crc[22] ^ crc[23] ^ crc[24] ^ crc[27] ^ crc[30] ^ crc[31];
		nextCRC32_D16[15] = Data[15] ^ Data[12] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[5] ^ Data[4] ^ Data[3] ^ crc[19] ^ crc[20] ^ crc[21] ^ crc[23] ^ crc[24] ^ crc[25] ^ crc[28] ^ crc[31];
		nextCRC32_D16[16] = Data[13] ^ Data[12] ^ Data[8] ^ Data[5] ^ Data[4] ^ Data[0] ^ crc[0] ^ crc[16] ^ crc[20] ^ crc[21] ^ crc[24] ^ crc[28] ^ crc[29];
		nextCRC32_D16[17] = Data[14] ^ Data[13] ^ Data[9] ^ Data[6] ^ Data[5] ^ Data[1] ^ crc[1] ^ crc[17] ^ crc[21] ^ crc[22] ^ crc[25] ^ crc[29] ^ crc[30];
		nextCRC32_D16[18] = Data[15] ^ Data[14] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[2] ^ crc[2] ^ crc[18] ^ crc[22] ^ crc[23] ^ crc[26] ^ crc[30] ^ crc[31];
		nextCRC32_D16[19] = Data[15] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[3] ^ crc[3] ^ crc[19] ^ crc[23] ^ crc[24] ^ crc[27] ^ crc[31];
		nextCRC32_D16[20] = Data[12] ^ Data[9] ^ Data[8] ^ Data[4] ^ crc[4] ^ crc[20] ^ crc[24] ^ crc[25] ^ crc[28];
		nextCRC32_D16[21] = Data[13] ^ Data[10] ^ Data[9] ^ Data[5] ^ crc[5] ^ crc[21] ^ crc[25] ^ crc[26] ^ crc[29];
		nextCRC32_D16[22] = Data[14] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[0] ^ crc[6] ^ crc[16] ^ crc[25] ^ crc[27] ^ crc[28] ^ crc[30];
		nextCRC32_D16[23] = Data[15] ^ Data[13] ^ Data[9] ^ Data[6] ^ Data[1] ^ Data[0] ^ crc[7] ^ crc[16] ^ crc[17] ^ crc[22] ^ crc[25] ^ crc[29] ^ crc[31];
		nextCRC32_D16[24] = Data[14] ^ Data[10] ^ Data[7] ^ Data[2] ^ Data[1] ^ crc[8] ^ crc[17] ^ crc[18] ^ crc[23] ^ crc[26] ^ crc[30];
		nextCRC32_D16[25] = Data[15] ^ Data[11] ^ Data[8] ^ Data[3] ^ Data[2] ^ crc[9] ^ crc[18] ^ crc[19] ^ crc[24] ^ crc[27] ^ crc[31];
		nextCRC32_D16[26] = Data[10] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[0] ^ crc[10] ^ crc[16] ^ crc[19] ^ crc[20] ^ crc[22] ^ crc[26];
		nextCRC32_D16[27] = Data[11] ^ Data[7] ^ Data[5] ^ Data[4] ^ Data[1] ^ crc[11] ^ crc[17] ^ crc[20] ^ crc[21] ^ crc[23] ^ crc[27];
		nextCRC32_D16[28] = Data[12] ^ Data[8] ^ Data[6] ^ Data[5] ^ Data[2] ^ crc[12] ^ crc[18] ^ crc[21] ^ crc[22] ^ crc[24] ^ crc[28];
		nextCRC32_D16[29] = Data[13] ^ Data[9] ^ Data[7] ^ Data[6] ^ Data[3] ^ crc[13] ^ crc[19] ^ crc[22] ^ crc[23] ^ crc[25] ^ crc[29];
		nextCRC32_D16[30] = Data[14] ^ Data[10] ^ Data[8] ^ Data[7] ^ Data[4] ^ crc[14] ^ crc[20] ^ crc[23] ^ crc[24] ^ crc[26] ^ crc[30];
		nextCRC32_D16[31] = Data[15] ^ Data[11] ^ Data[9] ^ Data[8] ^ Data[5] ^ crc[15] ^ crc[21] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[31];
	end
endfunction

function [31:0] nextCRC32_D24;

	input [23:0] Data;
	input [31:0] crc;

	begin


		nextCRC32_D24[0] = Data[16] ^ Data[12] ^ Data[10] ^ Data[9] ^ Data[6] ^ Data[0] ^ crc[8] ^ crc[14] ^ crc[17] ^ crc[18] ^ crc[20] ^ crc[24];
		nextCRC32_D24[1] = Data[17] ^ Data[16] ^ Data[13] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[7] ^ Data[6] ^ Data[1] ^ Data[0] ^ crc[8] ^ crc[9] ^ crc[14] ^ crc[15] ^ crc[17] ^ crc[19] ^ crc[20] ^ crc[21] ^ crc[24] ^ crc[25];
		nextCRC32_D24[2] = Data[18] ^ Data[17] ^ Data[16] ^ Data[14] ^ Data[13] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[2] ^ Data[1] ^ Data[0] ^ crc[8] ^ crc[9] ^ crc[10] ^ crc[14] ^ crc[15] ^ crc[16] ^ crc[17] ^ crc[21] ^ crc[22] ^ crc[24] ^ crc[25] ^ crc[26];
		nextCRC32_D24[3] = Data[19] ^ Data[18] ^ Data[17] ^ Data[15] ^ Data[14] ^ Data[10] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[3] ^ Data[2] ^ Data[1] ^ crc[9] ^ crc[10] ^ crc[11] ^ crc[15] ^ crc[16] ^ crc[17] ^ crc[18] ^ crc[22] ^ crc[23] ^ crc[25] ^ crc[26] ^ crc[27];
		nextCRC32_D24[4] = Data[20] ^ Data[19] ^ Data[18] ^ Data[15] ^ Data[12] ^ Data[11] ^ Data[8] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[8] ^ crc[10] ^ crc[11] ^ crc[12] ^ crc[14] ^ crc[16] ^ crc[19] ^ crc[20] ^ crc[23] ^ crc[26] ^ crc[27] ^ crc[28];
		nextCRC32_D24[5] = Data[21] ^ Data[20] ^ Data[19] ^ Data[13] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[8] ^ crc[9] ^ crc[11] ^ crc[12] ^ crc[13] ^ crc[14] ^ crc[15] ^ crc[18] ^ crc[21] ^ crc[27] ^ crc[28] ^ crc[29];
		nextCRC32_D24[6] = Data[22] ^ Data[21] ^ Data[20] ^ Data[14] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ crc[9] ^ crc[10] ^ crc[12] ^ crc[13] ^ crc[14] ^ crc[15] ^ crc[16] ^ crc[19] ^ crc[22] ^ crc[28] ^ crc[29] ^ crc[30];
		nextCRC32_D24[7] = Data[23] ^ Data[22] ^ Data[21] ^ Data[16] ^ Data[15] ^ Data[10] ^ Data[8] ^ Data[7] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[8] ^ crc[10] ^ crc[11] ^ crc[13] ^ crc[15] ^ crc[16] ^ crc[18] ^ crc[23] ^ crc[24] ^ crc[29] ^ crc[30] ^ crc[31];
		nextCRC32_D24[8] = Data[23] ^ Data[22] ^ Data[17] ^ Data[12] ^ Data[11] ^ Data[10] ^ Data[8] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[8] ^ crc[9] ^ crc[11] ^ crc[12] ^ crc[16] ^ crc[18] ^ crc[19] ^ crc[20] ^ crc[25] ^ crc[30] ^ crc[31];
		nextCRC32_D24[9] = Data[23] ^ Data[18] ^ Data[13] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ crc[9] ^ crc[10] ^ crc[12] ^ crc[13] ^ crc[17] ^ crc[19] ^ crc[20] ^ crc[21] ^ crc[26] ^ crc[31];
		nextCRC32_D24[10] = Data[19] ^ Data[16] ^ Data[14] ^ Data[13] ^ Data[9] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[8] ^ crc[10] ^ crc[11] ^ crc[13] ^ crc[17] ^ crc[21] ^ crc[22] ^ crc[24] ^ crc[27];
		nextCRC32_D24[11] = Data[20] ^ Data[17] ^ Data[16] ^ Data[15] ^ Data[14] ^ Data[12] ^ Data[9] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[8] ^ crc[9] ^ crc[11] ^ crc[12] ^ crc[17] ^ crc[20] ^ crc[22] ^ crc[23] ^ crc[24] ^ crc[25] ^ crc[28];
		nextCRC32_D24[12] = Data[21] ^ Data[18] ^ Data[17] ^ Data[15] ^ Data[13] ^ Data[12] ^ Data[9] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ Data[0] ^ crc[8] ^ crc[9] ^ crc[10] ^ crc[12] ^ crc[13] ^ crc[14] ^ crc[17] ^ crc[20] ^ crc[21] ^ crc[23] ^ crc[25] ^ crc[26] ^ crc[29];
		nextCRC32_D24[13] = Data[22] ^ Data[19] ^ Data[18] ^ Data[16] ^ Data[14] ^ Data[13] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[1] ^ crc[9] ^ crc[10] ^ crc[11] ^ crc[13] ^ crc[14] ^ crc[15] ^ crc[18] ^ crc[21] ^ crc[22] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[30];
		nextCRC32_D24[14] = Data[23] ^ Data[20] ^ Data[19] ^ Data[17] ^ Data[15] ^ Data[14] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[2] ^ crc[10] ^ crc[11] ^ crc[12] ^ crc[14] ^ crc[15] ^ crc[16] ^ crc[19] ^ crc[22] ^ crc[23] ^ crc[25] ^ crc[27] ^ crc[28] ^ crc[31];
		nextCRC32_D24[15] = Data[21] ^ Data[20] ^ Data[18] ^ Data[16] ^ Data[15] ^ Data[12] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[5] ^ Data[4] ^ Data[3] ^ crc[11] ^ crc[12] ^ crc[13] ^ crc[15] ^ crc[16] ^ crc[17] ^ crc[20] ^ crc[23] ^ crc[24] ^ crc[26] ^ crc[28] ^ crc[29];
		nextCRC32_D24[16] = Data[22] ^ Data[21] ^ Data[19] ^ Data[17] ^ Data[13] ^ Data[12] ^ Data[8] ^ Data[5] ^ Data[4] ^ Data[0] ^ crc[8] ^ crc[12] ^ crc[13] ^ crc[16] ^ crc[20] ^ crc[21] ^ crc[25] ^ crc[27] ^ crc[29] ^ crc[30];
		nextCRC32_D24[17] = Data[23] ^ Data[22] ^ Data[20] ^ Data[18] ^ Data[14] ^ Data[13] ^ Data[9] ^ Data[6] ^ Data[5] ^ Data[1] ^ crc[9] ^ crc[13] ^ crc[14] ^ crc[17] ^ crc[21] ^ crc[22] ^ crc[26] ^ crc[28] ^ crc[30] ^ crc[31];
		nextCRC32_D24[18] = Data[23] ^ Data[21] ^ Data[19] ^ Data[15] ^ Data[14] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[2] ^ crc[10] ^ crc[14] ^ crc[15] ^ crc[18] ^ crc[22] ^ crc[23] ^ crc[27] ^ crc[29] ^ crc[31];
		nextCRC32_D24[19] = Data[22] ^ Data[20] ^ Data[16] ^ Data[15] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[3] ^ crc[11] ^ crc[15] ^ crc[16] ^ crc[19] ^ crc[23] ^ crc[24] ^ crc[28] ^ crc[30];
		nextCRC32_D24[20] = Data[23] ^ Data[21] ^ Data[17] ^ Data[16] ^ Data[12] ^ Data[9] ^ Data[8] ^ Data[4] ^ crc[12] ^ crc[16] ^ crc[17] ^ crc[20] ^ crc[24] ^ crc[25] ^ crc[29] ^ crc[31];
		nextCRC32_D24[21] = Data[22] ^ Data[18] ^ Data[17] ^ Data[13] ^ Data[10] ^ Data[9] ^ Data[5] ^ crc[13] ^ crc[17] ^ crc[18] ^ crc[21] ^ crc[25] ^ crc[26] ^ crc[30];
		nextCRC32_D24[22] = Data[23] ^ Data[19] ^ Data[18] ^ Data[16] ^ Data[14] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[0] ^ crc[8] ^ crc[17] ^ crc[19] ^ crc[20] ^ crc[22] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[31];
		nextCRC32_D24[23] = Data[20] ^ Data[19] ^ Data[17] ^ Data[16] ^ Data[15] ^ Data[13] ^ Data[9] ^ Data[6] ^ Data[1] ^ Data[0] ^ crc[8] ^ crc[9] ^ crc[14] ^ crc[17] ^ crc[21] ^ crc[23] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28];
		nextCRC32_D24[24] = Data[21] ^ Data[20] ^ Data[18] ^ Data[17] ^ Data[16] ^ Data[14] ^ Data[10] ^ Data[7] ^ Data[2] ^ Data[1] ^ crc[0] ^ crc[9] ^ crc[10] ^ crc[15] ^ crc[18] ^ crc[22] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[29];
		nextCRC32_D24[25] = Data[22] ^ Data[21] ^ Data[19] ^ Data[18] ^ Data[17] ^ Data[15] ^ Data[11] ^ Data[8] ^ Data[3] ^ Data[2] ^ crc[1] ^ crc[10] ^ crc[11] ^ crc[16] ^ crc[19] ^ crc[23] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[30];
		nextCRC32_D24[26] = Data[23] ^ Data[22] ^ Data[20] ^ Data[19] ^ Data[18] ^ Data[10] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[0] ^ crc[2] ^ crc[8] ^ crc[11] ^ crc[12] ^ crc[14] ^ crc[18] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[30] ^ crc[31];
		nextCRC32_D24[27] = Data[23] ^ Data[21] ^ Data[20] ^ Data[19] ^ Data[11] ^ Data[7] ^ Data[5] ^ Data[4] ^ Data[1] ^ crc[3] ^ crc[9] ^ crc[12] ^ crc[13] ^ crc[15] ^ crc[19] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[31];
		nextCRC32_D24[28] = Data[22] ^ Data[21] ^ Data[20] ^ Data[12] ^ Data[8] ^ Data[6] ^ Data[5] ^ Data[2] ^ crc[4] ^ crc[10] ^ crc[13] ^ crc[14] ^ crc[16] ^ crc[20] ^ crc[28] ^ crc[29] ^ crc[30];
		nextCRC32_D24[29] = Data[23] ^ Data[22] ^ Data[21] ^ Data[13] ^ Data[9] ^ Data[7] ^ Data[6] ^ Data[3] ^ crc[5] ^ crc[11] ^ crc[14] ^ crc[15] ^ crc[17] ^ crc[21] ^ crc[29] ^ crc[30] ^ crc[31];
		nextCRC32_D24[30] = Data[23] ^ Data[22] ^ Data[14] ^ Data[10] ^ Data[8] ^ Data[7] ^ Data[4] ^ crc[6] ^ crc[12] ^ crc[15] ^ crc[16] ^ crc[18] ^ crc[22] ^ crc[30] ^ crc[31];
		nextCRC32_D24[31] = Data[23] ^ Data[15] ^ Data[11] ^ Data[9] ^ Data[8] ^ Data[5] ^ crc[7] ^ crc[13] ^ crc[16] ^ crc[17] ^ crc[19] ^ crc[23] ^ crc[31];

	end
endfunction

function [31:0] nextCRC32_D32;

	input [31:0] Data;
	input [31:0] crc;
	begin

		nextCRC32_D32[0] = Data[31] ^ Data[30] ^ Data[29] ^ Data[28] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[16] ^ Data[12] ^ Data[10] ^ Data[9] ^ Data[6] ^ Data[0] ^ crc[0] ^ crc[6] ^ crc[9] ^ crc[10] ^ crc[12] ^ crc[16] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[29] ^ crc[30] ^ crc[31];
		nextCRC32_D32[1] = Data[28] ^ Data[27] ^ Data[24] ^ Data[17] ^ Data[16] ^ Data[13] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[7] ^ Data[6] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[6] ^ crc[7] ^ crc[9] ^ crc[11] ^ crc[12] ^ crc[13] ^ crc[16] ^ crc[17] ^ crc[24] ^ crc[27] ^ crc[28];
		nextCRC32_D32[2] = Data[31] ^ Data[30] ^ Data[26] ^ Data[24] ^ Data[18] ^ Data[17] ^ Data[16] ^ Data[14] ^ Data[13] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[2] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[2] ^ crc[6] ^ crc[7] ^ crc[8] ^ crc[9] ^ crc[13] ^ crc[14] ^ crc[16] ^ crc[17] ^ crc[18] ^ crc[24] ^ crc[26] ^ crc[30] ^ crc[31];
		nextCRC32_D32[3] = Data[31] ^ Data[27] ^ Data[25] ^ Data[19] ^ Data[18] ^ Data[17] ^ Data[15] ^ Data[14] ^ Data[10] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[3] ^ Data[2] ^ Data[1] ^ crc[1] ^ crc[2] ^ crc[3] ^ crc[7] ^ crc[8] ^ crc[9] ^ crc[10] ^ crc[14] ^ crc[15] ^ crc[17] ^ crc[18] ^ crc[19] ^ crc[25] ^ crc[27] ^ crc[31];
		nextCRC32_D32[4] = Data[31] ^ Data[30] ^ Data[29] ^ Data[25] ^ Data[24] ^ Data[20] ^ Data[19] ^ Data[18] ^ Data[15] ^ Data[12] ^ Data[11] ^ Data[8] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[0] ^ crc[2] ^ crc[3] ^ crc[4] ^ crc[6] ^ crc[8] ^ crc[11] ^ crc[12] ^ crc[15] ^ crc[18] ^ crc[19] ^ crc[20] ^ crc[24] ^ crc[25] ^ crc[29] ^ crc[30] ^ crc[31];
		nextCRC32_D32[5] = Data[29] ^ Data[28] ^ Data[24] ^ Data[21] ^ Data[20] ^ Data[19] ^ Data[13] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[3] ^ crc[4] ^ crc[5] ^ crc[6] ^ crc[7] ^ crc[10] ^ crc[13] ^ crc[19] ^ crc[20] ^ crc[21] ^ crc[24] ^ crc[28] ^ crc[29];
		nextCRC32_D32[6] = Data[30] ^ Data[29] ^ Data[25] ^ Data[22] ^ Data[21] ^ Data[20] ^ Data[14] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ crc[1] ^ crc[2] ^ crc[4] ^ crc[5] ^ crc[6] ^ crc[7] ^ crc[8] ^ crc[11] ^ crc[14] ^ crc[20] ^ crc[21] ^ crc[22] ^ crc[25] ^ crc[29] ^ crc[30];
		nextCRC32_D32[7] = Data[29] ^ Data[28] ^ Data[25] ^ Data[24] ^ Data[23] ^ Data[22] ^ Data[21] ^ Data[16] ^ Data[15] ^ Data[10] ^ Data[8] ^ Data[7] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[0] ^ crc[2] ^ crc[3] ^ crc[5] ^ crc[7] ^ crc[8] ^ crc[10] ^ crc[15] ^ crc[16] ^ crc[21] ^ crc[22] ^ crc[23] ^ crc[24] ^ crc[25] ^ crc[28] ^ crc[29];
		nextCRC32_D32[8] = Data[31] ^ Data[28] ^ Data[23] ^ Data[22] ^ Data[17] ^ Data[12] ^ Data[11] ^ Data[10] ^ Data[8] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[3] ^ crc[4] ^ crc[8] ^ crc[10] ^ crc[11] ^ crc[12] ^ crc[17] ^ crc[22] ^ crc[23] ^ crc[28] ^ crc[31];
		nextCRC32_D32[9] = Data[29] ^ Data[24] ^ Data[23] ^ Data[18] ^ Data[13] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ crc[1] ^ crc[2] ^ crc[4] ^ crc[5] ^ crc[9] ^ crc[11] ^ crc[12] ^ crc[13] ^ crc[18] ^ crc[23] ^ crc[24] ^ crc[29];
		nextCRC32_D32[10] = Data[31] ^ Data[29] ^ Data[28] ^ Data[26] ^ Data[19] ^ Data[16] ^ Data[14] ^ Data[13] ^ Data[9] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[0] ^ crc[2] ^ crc[3] ^ crc[5] ^ crc[9] ^ crc[13] ^ crc[14] ^ crc[16] ^ crc[19] ^ crc[26] ^ crc[28] ^ crc[29] ^ crc[31];
		nextCRC32_D32[11] = Data[31] ^ Data[28] ^ Data[27] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[20] ^ Data[17] ^ Data[16] ^ Data[15] ^ Data[14] ^ Data[12] ^ Data[9] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[3] ^ crc[4] ^ crc[9] ^ crc[12] ^ crc[14] ^ crc[15] ^ crc[16] ^ crc[17] ^ crc[20] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[31];
		nextCRC32_D32[12] = Data[31] ^ Data[30] ^ Data[27] ^ Data[24] ^ Data[21] ^ Data[18] ^ Data[17] ^ Data[15] ^ Data[13] ^ Data[12] ^ Data[9] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[2] ^ crc[4] ^ crc[5] ^ crc[6] ^ crc[9] ^ crc[12] ^ crc[13] ^ crc[15] ^ crc[17] ^ crc[18] ^ crc[21] ^ crc[24] ^ crc[27] ^ crc[30] ^ crc[31];
		nextCRC32_D32[13] = Data[31] ^ Data[28] ^ Data[25] ^ Data[22] ^ Data[19] ^ Data[18] ^ Data[16] ^ Data[14] ^ Data[13] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[1] ^ crc[1] ^ crc[2] ^ crc[3] ^ crc[5] ^ crc[6] ^ crc[7] ^ crc[10] ^ crc[13] ^ crc[14] ^ crc[16] ^ crc[18] ^ crc[19] ^ crc[22] ^ crc[25] ^ crc[28] ^ crc[31];
		nextCRC32_D32[14] = Data[29] ^ Data[26] ^ Data[23] ^ Data[20] ^ Data[19] ^ Data[17] ^ Data[15] ^ Data[14] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[2] ^ crc[2] ^ crc[3] ^ crc[4] ^ crc[6] ^ crc[7] ^ crc[8] ^ crc[11] ^ crc[14] ^ crc[15] ^ crc[17] ^ crc[19] ^ crc[20] ^ crc[23] ^ crc[26] ^ crc[29];
		nextCRC32_D32[15] = Data[30] ^ Data[27] ^ Data[24] ^ Data[21] ^ Data[20] ^ Data[18] ^ Data[16] ^ Data[15] ^ Data[12] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[5] ^ Data[4] ^ Data[3] ^ crc[3] ^ crc[4] ^ crc[5] ^ crc[7] ^ crc[8] ^ crc[9] ^ crc[12] ^ crc[15] ^ crc[16] ^ crc[18] ^ crc[20] ^ crc[21] ^ crc[24] ^ crc[27] ^ crc[30];
		nextCRC32_D32[16] = Data[30] ^ Data[29] ^ Data[26] ^ Data[24] ^ Data[22] ^ Data[21] ^ Data[19] ^ Data[17] ^ Data[13] ^ Data[12] ^ Data[8] ^ Data[5] ^ Data[4] ^ Data[0] ^ crc[0] ^ crc[4] ^ crc[5] ^ crc[8] ^ crc[12] ^ crc[13] ^ crc[17] ^ crc[19] ^ crc[21] ^ crc[22] ^ crc[24] ^ crc[26] ^ crc[29] ^ crc[30];
		nextCRC32_D32[17] = Data[31] ^ Data[30] ^ Data[27] ^ Data[25] ^ Data[23] ^ Data[22] ^ Data[20] ^ Data[18] ^ Data[14] ^ Data[13] ^ Data[9] ^ Data[6] ^ Data[5] ^ Data[1] ^ crc[1] ^ crc[5] ^ crc[6] ^ crc[9] ^ crc[13] ^ crc[14] ^ crc[18] ^ crc[20] ^ crc[22] ^ crc[23] ^ crc[25] ^ crc[27] ^ crc[30] ^ crc[31];
		nextCRC32_D32[18] = Data[31] ^ Data[28] ^ Data[26] ^ Data[24] ^ Data[23] ^ Data[21] ^ Data[19] ^ Data[15] ^ Data[14] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[2] ^ crc[2] ^ crc[6] ^ crc[7] ^ crc[10] ^ crc[14] ^ crc[15] ^ crc[19] ^ crc[21] ^ crc[23] ^ crc[24] ^ crc[26] ^ crc[28] ^ crc[31];
		nextCRC32_D32[19] = Data[29] ^ Data[27] ^ Data[25] ^ Data[24] ^ Data[22] ^ Data[20] ^ Data[16] ^ Data[15] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[3] ^ crc[3] ^ crc[7] ^ crc[8] ^ crc[11] ^ crc[15] ^ crc[16] ^ crc[20] ^ crc[22] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[29];
		nextCRC32_D32[20] = Data[30] ^ Data[28] ^ Data[26] ^ Data[25] ^ Data[23] ^ Data[21] ^ Data[17] ^ Data[16] ^ Data[12] ^ Data[9] ^ Data[8] ^ Data[4] ^ crc[4] ^ crc[8] ^ crc[9] ^ crc[12] ^ crc[16] ^ crc[17] ^ crc[21] ^ crc[23] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[30];
		nextCRC32_D32[21] = Data[31] ^ Data[29] ^ Data[27] ^ Data[26] ^ Data[24] ^ Data[22] ^ Data[18] ^ Data[17] ^ Data[13] ^ Data[10] ^ Data[9] ^ Data[5] ^ crc[5] ^ crc[9] ^ crc[10] ^ crc[13] ^ crc[17] ^ crc[18] ^ crc[22] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[31];
		nextCRC32_D32[22] = Data[31] ^ Data[29] ^ Data[27] ^ Data[26] ^ Data[24] ^ Data[23] ^ Data[19] ^ Data[18] ^ Data[16] ^ Data[14] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[0] ^ crc[0] ^ crc[9] ^ crc[11] ^ crc[12] ^ crc[14] ^ crc[16] ^ crc[18] ^ crc[19] ^ crc[23] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[31];
		nextCRC32_D32[23] = Data[31] ^ Data[29] ^ Data[27] ^ Data[26] ^ Data[20] ^ Data[19] ^ Data[17] ^ Data[16] ^ Data[15] ^ Data[13] ^ Data[9] ^ Data[6] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[6] ^ crc[9] ^ crc[13] ^ crc[15] ^ crc[16] ^ crc[17] ^ crc[19] ^ crc[20] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[31];
		nextCRC32_D32[24] = Data[30] ^ Data[28] ^ Data[27] ^ Data[21] ^ Data[20] ^ Data[18] ^ Data[17] ^ Data[16] ^ Data[14] ^ Data[10] ^ Data[7] ^ Data[2] ^ Data[1] ^ crc[1] ^ crc[2] ^ crc[7] ^ crc[10] ^ crc[14] ^ crc[16] ^ crc[17] ^ crc[18] ^ crc[20] ^ crc[21] ^ crc[27] ^ crc[28] ^ crc[30];
		nextCRC32_D32[25] = Data[31] ^ Data[29] ^ Data[28] ^ Data[22] ^ Data[21] ^ Data[19] ^ Data[18] ^ Data[17] ^ Data[15] ^ Data[11] ^ Data[8] ^ Data[3] ^ Data[2] ^ crc[2] ^ crc[3] ^ crc[8] ^ crc[11] ^ crc[15] ^ crc[17] ^ crc[18] ^ crc[19] ^ crc[21] ^ crc[22] ^ crc[28] ^ crc[29] ^ crc[31];
		nextCRC32_D32[26] = Data[31] ^ Data[28] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[23] ^ Data[22] ^ Data[20] ^ Data[19] ^ Data[18] ^ Data[10] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[0] ^ crc[0] ^ crc[3] ^ crc[4] ^ crc[6] ^ crc[10] ^ crc[18] ^ crc[19] ^ crc[20] ^ crc[22] ^ crc[23] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[31];
		nextCRC32_D32[27] = Data[29] ^ Data[27] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[23] ^ Data[21] ^ Data[20] ^ Data[19] ^ Data[11] ^ Data[7] ^ Data[5] ^ Data[4] ^ Data[1] ^ crc[1] ^ crc[4] ^ crc[5] ^ crc[7] ^ crc[11] ^ crc[19] ^ crc[20] ^ crc[21] ^ crc[23] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[29];
		nextCRC32_D32[28] = Data[30] ^ Data[28] ^ Data[27] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[22] ^ Data[21] ^ Data[20] ^ Data[12] ^ Data[8] ^ Data[6] ^ Data[5] ^ Data[2] ^ crc[2] ^ crc[5] ^ crc[6] ^ crc[8] ^ crc[12] ^ crc[20] ^ crc[21] ^ crc[22] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[30];
		nextCRC32_D32[29] = Data[31] ^ Data[29] ^ Data[28] ^ Data[27] ^ Data[26] ^ Data[25] ^ Data[23] ^ Data[22] ^ Data[21] ^ Data[13] ^ Data[9] ^ Data[7] ^ Data[6] ^ Data[3] ^ crc[3] ^ crc[6] ^ crc[7] ^ crc[9] ^ crc[13] ^ crc[21] ^ crc[22] ^ crc[23] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[31];
		nextCRC32_D32[30] = Data[30] ^ Data[29] ^ Data[28] ^ Data[27] ^ Data[26] ^ Data[24] ^ Data[23] ^ Data[22] ^ Data[14] ^ Data[10] ^ Data[8] ^ Data[7] ^ Data[4] ^ crc[4] ^ crc[7] ^ crc[8] ^ crc[10] ^ crc[14] ^ crc[22] ^ crc[23] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[30];
		nextCRC32_D32[31] = Data[31] ^ Data[30] ^ Data[29] ^ Data[28] ^ Data[27] ^ Data[25] ^ Data[24] ^ Data[23] ^ Data[15] ^ Data[11] ^ Data[9] ^ Data[8] ^ Data[5] ^ crc[5] ^ crc[8] ^ crc[9] ^ crc[11] ^ crc[15] ^ crc[23] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[30] ^ crc[31];

	end
endfunction

function [31:0] nextCRC32_D40;

	input [39:0] Data;
	input [31:0] crc;
	begin

		nextCRC32_D40[0] = Data[37] ^ Data[34] ^ Data[32] ^ Data[31] ^ Data[30] ^ Data[29] ^ Data[28] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[16] ^ Data[12] ^ Data[10] ^ Data[9] ^ Data[6] ^ Data[0] ^ crc[1] ^ crc[2] ^ crc[4] ^ crc[8] ^ crc[16] ^ crc[17] ^ crc[18] ^ crc[20] ^ crc[21] ^ crc[22] ^ crc[23] ^ crc[24] ^ crc[26] ^ crc[29];
		nextCRC32_D40[1] = Data[38] ^ Data[37] ^ Data[35] ^ Data[34] ^ Data[33] ^ Data[28] ^ Data[27] ^ Data[24] ^ Data[17] ^ Data[16] ^ Data[13] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[7] ^ Data[6] ^ Data[1] ^ Data[0] ^ crc[1] ^ crc[3] ^ crc[4] ^ crc[5] ^ crc[8] ^ crc[9] ^ crc[16] ^ crc[19] ^ crc[20] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[30];
		nextCRC32_D40[2] = Data[39] ^ Data[38] ^ Data[37] ^ Data[36] ^ Data[35] ^ Data[32] ^ Data[31] ^ Data[30] ^ Data[26] ^ Data[24] ^ Data[18] ^ Data[17] ^ Data[16] ^ Data[14] ^ Data[13] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[2] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[5] ^ crc[6] ^ crc[8] ^ crc[9] ^ crc[10] ^ crc[16] ^ crc[18] ^ crc[22] ^ crc[23] ^ crc[24] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[30] ^ crc[31];
		nextCRC32_D40[3] = Data[39] ^ Data[38] ^ Data[37] ^ Data[36] ^ Data[33] ^ Data[32] ^ Data[31] ^ Data[27] ^ Data[25] ^ Data[19] ^ Data[18] ^ Data[17] ^ Data[15] ^ Data[14] ^ Data[10] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[3] ^ Data[2] ^ Data[1] ^ crc[0] ^ crc[1] ^ crc[2] ^ crc[6] ^ crc[7] ^ crc[9] ^ crc[10] ^ crc[11] ^ crc[17] ^ crc[19] ^ crc[23] ^ crc[24] ^ crc[25] ^ crc[28] ^ crc[29] ^ crc[30] ^ crc[31];
		nextCRC32_D40[4] = Data[39] ^ Data[38] ^ Data[33] ^ Data[31] ^ Data[30] ^ Data[29] ^ Data[25] ^ Data[24] ^ Data[20] ^ Data[19] ^ Data[18] ^ Data[15] ^ Data[12] ^ Data[11] ^ Data[8] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[0] ^ crc[3] ^ crc[4] ^ crc[7] ^ crc[10] ^ crc[11] ^ crc[12] ^ crc[16] ^ crc[17] ^ crc[21] ^ crc[22] ^ crc[23] ^ crc[25] ^ crc[30] ^ crc[31];
		nextCRC32_D40[5] = Data[39] ^ Data[37] ^ Data[29] ^ Data[28] ^ Data[24] ^ Data[21] ^ Data[20] ^ Data[19] ^ Data[13] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[2] ^ crc[5] ^ crc[11] ^ crc[12] ^ crc[13] ^ crc[16] ^ crc[20] ^ crc[21] ^ crc[29] ^ crc[31];
		nextCRC32_D40[6] = Data[38] ^ Data[30] ^ Data[29] ^ Data[25] ^ Data[22] ^ Data[21] ^ Data[20] ^ Data[14] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ crc[0] ^ crc[3] ^ crc[6] ^ crc[12] ^ crc[13] ^ crc[14] ^ crc[17] ^ crc[21] ^ crc[22] ^ crc[30];
		nextCRC32_D40[7] = Data[39] ^ Data[37] ^ Data[34] ^ Data[32] ^ Data[29] ^ Data[28] ^ Data[25] ^ Data[24] ^ Data[23] ^ Data[22] ^ Data[21] ^ Data[16] ^ Data[15] ^ Data[10] ^ Data[8] ^ Data[7] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[0] ^ crc[2] ^ crc[7] ^ crc[8] ^ crc[13] ^ crc[14] ^ crc[15] ^ crc[16] ^ crc[17] ^ crc[20] ^ crc[21] ^ crc[24] ^ crc[26] ^ crc[29] ^ crc[31];
		nextCRC32_D40[8] = Data[38] ^ Data[37] ^ Data[35] ^ Data[34] ^ Data[33] ^ Data[32] ^ Data[31] ^ Data[28] ^ Data[23] ^ Data[22] ^ Data[17] ^ Data[12] ^ Data[11] ^ Data[10] ^ Data[8] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[2] ^ crc[3] ^ crc[4] ^ crc[9] ^ crc[14] ^ crc[15] ^ crc[20] ^ crc[23] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[30];
		nextCRC32_D40[9] = Data[39] ^ Data[38] ^ Data[36] ^ Data[35] ^ Data[34] ^ Data[33] ^ Data[32] ^ Data[29] ^ Data[24] ^ Data[23] ^ Data[18] ^ Data[13] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ crc[1] ^ crc[3] ^ crc[4] ^ crc[5] ^ crc[10] ^ crc[15] ^ crc[16] ^ crc[21] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[30] ^ crc[31];
		nextCRC32_D40[10] = Data[39] ^ Data[36] ^ Data[35] ^ Data[33] ^ Data[32] ^ Data[31] ^ Data[29] ^ Data[28] ^ Data[26] ^ Data[19] ^ Data[16] ^ Data[14] ^ Data[13] ^ Data[9] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[1] ^ crc[5] ^ crc[6] ^ crc[8] ^ crc[11] ^ crc[18] ^ crc[20] ^ crc[21] ^ crc[23] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28] ^ crc[31];
		nextCRC32_D40[11] = Data[36] ^ Data[33] ^ Data[31] ^ Data[28] ^ Data[27] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[20] ^ Data[17] ^ Data[16] ^ Data[15] ^ Data[14] ^ Data[12] ^ Data[9] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[1] ^ crc[4] ^ crc[6] ^ crc[7] ^ crc[8] ^ crc[9] ^ crc[12] ^ crc[16] ^ crc[17] ^ crc[18] ^ crc[19] ^ crc[20] ^ crc[23] ^ crc[25] ^ crc[28];
		nextCRC32_D40[12] = Data[31] ^ Data[30] ^ Data[27] ^ Data[24] ^ Data[21] ^ Data[18] ^ Data[17] ^ Data[15] ^ Data[13] ^ Data[12] ^ Data[9] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ Data[0] ^ crc[1] ^ crc[4] ^ crc[5] ^ crc[7] ^ crc[9] ^ crc[10] ^ crc[13] ^ crc[16] ^ crc[19] ^ crc[22] ^ crc[23];
		nextCRC32_D40[13] = Data[32] ^ Data[31] ^ Data[28] ^ Data[25] ^ Data[22] ^ Data[19] ^ Data[18] ^ Data[16] ^ Data[14] ^ Data[13] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[1] ^ crc[2] ^ crc[5] ^ crc[6] ^ crc[8] ^ crc[10] ^ crc[11] ^ crc[14] ^ crc[17] ^ crc[20] ^ crc[23] ^ crc[24];
		nextCRC32_D40[14] = Data[33] ^ Data[32] ^ Data[29] ^ Data[26] ^ Data[23] ^ Data[20] ^ Data[19] ^ Data[17] ^ Data[15] ^ Data[14] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[2] ^ crc[0] ^ crc[3] ^ crc[6] ^ crc[7] ^ crc[9] ^ crc[11] ^ crc[12] ^ crc[15] ^ crc[18] ^ crc[21] ^ crc[24] ^ crc[25];
		nextCRC32_D40[15] = Data[34] ^ Data[33] ^ Data[30] ^ Data[27] ^ Data[24] ^ Data[21] ^ Data[20] ^ Data[18] ^ Data[16] ^ Data[15] ^ Data[12] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[5] ^ Data[4] ^ Data[3] ^ crc[0] ^ crc[1] ^ crc[4] ^ crc[7] ^ crc[8] ^ crc[10] ^ crc[12] ^ crc[13] ^ crc[16] ^ crc[19] ^ crc[22] ^ crc[25] ^ crc[26];
		nextCRC32_D40[16] = Data[37] ^ Data[35] ^ Data[32] ^ Data[30] ^ Data[29] ^ Data[26] ^ Data[24] ^ Data[22] ^ Data[21] ^ Data[19] ^ Data[17] ^ Data[13] ^ Data[12] ^ Data[8] ^ Data[5] ^ Data[4] ^ Data[0] ^ crc[0] ^ crc[4] ^ crc[5] ^ crc[9] ^ crc[11] ^ crc[13] ^ crc[14] ^ crc[16] ^ crc[18] ^ crc[21] ^ crc[22] ^ crc[24] ^ crc[27] ^ crc[29];
		nextCRC32_D40[17] = Data[38] ^ Data[36] ^ Data[33] ^ Data[31] ^ Data[30] ^ Data[27] ^ Data[25] ^ Data[23] ^ Data[22] ^ Data[20] ^ Data[18] ^ Data[14] ^ Data[13] ^ Data[9] ^ Data[6] ^ Data[5] ^ Data[1] ^ crc[1] ^ crc[5] ^ crc[6] ^ crc[10] ^ crc[12] ^ crc[14] ^ crc[15] ^ crc[17] ^ crc[19] ^ crc[22] ^ crc[23] ^ crc[25] ^ crc[28] ^ crc[30];
		nextCRC32_D40[18] = Data[39] ^ Data[37] ^ Data[34] ^ Data[32] ^ Data[31] ^ Data[28] ^ Data[26] ^ Data[24] ^ Data[23] ^ Data[21] ^ Data[19] ^ Data[15] ^ Data[14] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[2] ^ crc[2] ^ crc[6] ^ crc[7] ^ crc[11] ^ crc[13] ^ crc[15] ^ crc[16] ^ crc[18] ^ crc[20] ^ crc[23] ^ crc[24] ^ crc[26] ^ crc[29] ^ crc[31];
		nextCRC32_D40[19] = Data[38] ^ Data[35] ^ Data[33] ^ Data[32] ^ Data[29] ^ Data[27] ^ Data[25] ^ Data[24] ^ Data[22] ^ Data[20] ^ Data[16] ^ Data[15] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[3] ^ crc[0] ^ crc[3] ^ crc[7] ^ crc[8] ^ crc[12] ^ crc[14] ^ crc[16] ^ crc[17] ^ crc[19] ^ crc[21] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[30];
		nextCRC32_D40[20] = Data[39] ^ Data[36] ^ Data[34] ^ Data[33] ^ Data[30] ^ Data[28] ^ Data[26] ^ Data[25] ^ Data[23] ^ Data[21] ^ Data[17] ^ Data[16] ^ Data[12] ^ Data[9] ^ Data[8] ^ Data[4] ^ crc[0] ^ crc[1] ^ crc[4] ^ crc[8] ^ crc[9] ^ crc[13] ^ crc[15] ^ crc[17] ^ crc[18] ^ crc[20] ^ crc[22] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[31];
		nextCRC32_D40[21] = Data[37] ^ Data[35] ^ Data[34] ^ Data[31] ^ Data[29] ^ Data[27] ^ Data[26] ^ Data[24] ^ Data[22] ^ Data[18] ^ Data[17] ^ Data[13] ^ Data[10] ^ Data[9] ^ Data[5] ^ crc[1] ^ crc[2] ^ crc[5] ^ crc[9] ^ crc[10] ^ crc[14] ^ crc[16] ^ crc[18] ^ crc[19] ^ crc[21] ^ crc[23] ^ crc[26] ^ crc[27] ^ crc[29];
		nextCRC32_D40[22] = Data[38] ^ Data[37] ^ Data[36] ^ Data[35] ^ Data[34] ^ Data[31] ^ Data[29] ^ Data[27] ^ Data[26] ^ Data[24] ^ Data[23] ^ Data[19] ^ Data[18] ^ Data[16] ^ Data[14] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[0] ^ crc[1] ^ crc[3] ^ crc[4] ^ crc[6] ^ crc[8] ^ crc[10] ^ crc[11] ^ crc[15] ^ crc[16] ^ crc[18] ^ crc[19] ^ crc[21] ^ crc[23] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[30];
		nextCRC32_D40[23] = Data[39] ^ Data[38] ^ Data[36] ^ Data[35] ^ Data[34] ^ Data[31] ^ Data[29] ^ Data[27] ^ Data[26] ^ Data[20] ^ Data[19] ^ Data[17] ^ Data[16] ^ Data[15] ^ Data[13] ^ Data[9] ^ Data[6] ^ Data[1] ^ Data[0] ^ crc[1] ^ crc[5] ^ crc[7] ^ crc[8] ^ crc[9] ^ crc[11] ^ crc[12] ^ crc[18] ^ crc[19] ^ crc[21] ^ crc[23] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[30] ^ crc[31];
		nextCRC32_D40[24] = Data[39] ^ Data[37] ^ Data[36] ^ Data[35] ^ Data[32] ^ Data[30] ^ Data[28] ^ Data[27] ^ Data[21] ^ Data[20] ^ Data[18] ^ Data[17] ^ Data[16] ^ Data[14] ^ Data[10] ^ Data[7] ^ Data[2] ^ Data[1] ^ crc[2] ^ crc[6] ^ crc[8] ^ crc[9] ^ crc[10] ^ crc[12] ^ crc[13] ^ crc[19] ^ crc[20] ^ crc[22] ^ crc[24] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[31];
		nextCRC32_D40[25] = Data[38] ^ Data[37] ^ Data[36] ^ Data[33] ^ Data[31] ^ Data[29] ^ Data[28] ^ Data[22] ^ Data[21] ^ Data[19] ^ Data[18] ^ Data[17] ^ Data[15] ^ Data[11] ^ Data[8] ^ Data[3] ^ Data[2] ^ crc[0] ^ crc[3] ^ crc[7] ^ crc[9] ^ crc[10] ^ crc[11] ^ crc[13] ^ crc[14] ^ crc[20] ^ crc[21] ^ crc[23] ^ crc[25] ^ crc[28] ^ crc[29] ^ crc[30];
		nextCRC32_D40[26] = Data[39] ^ Data[38] ^ Data[31] ^ Data[28] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[23] ^ Data[22] ^ Data[20] ^ Data[19] ^ Data[18] ^ Data[10] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[0] ^ crc[2] ^ crc[10] ^ crc[11] ^ crc[12] ^ crc[14] ^ crc[15] ^ crc[16] ^ crc[17] ^ crc[18] ^ crc[20] ^ crc[23] ^ crc[30] ^ crc[31];
		nextCRC32_D40[27] = Data[39] ^ Data[32] ^ Data[29] ^ Data[27] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[23] ^ Data[21] ^ Data[20] ^ Data[19] ^ Data[11] ^ Data[7] ^ Data[5] ^ Data[4] ^ Data[1] ^ crc[3] ^ crc[11] ^ crc[12] ^ crc[13] ^ crc[15] ^ crc[16] ^ crc[17] ^ crc[18] ^ crc[19] ^ crc[21] ^ crc[24] ^ crc[31];
		nextCRC32_D40[28] = Data[33] ^ Data[30] ^ Data[28] ^ Data[27] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[22] ^ Data[21] ^ Data[20] ^ Data[12] ^ Data[8] ^ Data[6] ^ Data[5] ^ Data[2] ^ crc[0] ^ crc[4] ^ crc[12] ^ crc[13] ^ crc[14] ^ crc[16] ^ crc[17] ^ crc[18] ^ crc[19] ^ crc[20] ^ crc[22] ^ crc[25];
		nextCRC32_D40[29] = Data[34] ^ Data[31] ^ Data[29] ^ Data[28] ^ Data[27] ^ Data[26] ^ Data[25] ^ Data[23] ^ Data[22] ^ Data[21] ^ Data[13] ^ Data[9] ^ Data[7] ^ Data[6] ^ Data[3] ^ crc[1] ^ crc[5] ^ crc[13] ^ crc[14] ^ crc[15] ^ crc[17] ^ crc[18] ^ crc[19] ^ crc[20] ^ crc[21] ^ crc[23] ^ crc[26];
		nextCRC32_D40[30] = Data[35] ^ Data[32] ^ Data[30] ^ Data[29] ^ Data[28] ^ Data[27] ^ Data[26] ^ Data[24] ^ Data[23] ^ Data[22] ^ Data[14] ^ Data[10] ^ Data[8] ^ Data[7] ^ Data[4] ^ crc[0] ^ crc[2] ^ crc[6] ^ crc[14] ^ crc[15] ^ crc[16] ^ crc[18] ^ crc[19] ^ crc[20] ^ crc[21] ^ crc[22] ^ crc[24] ^ crc[27];
		nextCRC32_D40[31] = Data[36] ^ Data[33] ^ Data[31] ^ Data[30] ^ Data[29] ^ Data[28] ^ Data[27] ^ Data[25] ^ Data[24] ^ Data[23] ^ Data[15] ^ Data[11] ^ Data[9] ^ Data[8] ^ Data[5] ^ crc[0] ^ crc[1] ^ crc[3] ^ crc[7] ^ crc[15] ^ crc[16] ^ crc[17] ^ crc[19] ^ crc[20] ^ crc[21] ^ crc[22] ^ crc[23] ^ crc[25] ^ crc[28];
	end
endfunction

function [31:0] nextCRC32_D48;

	input [47:0] Data;
	input [31:0] crc;
	begin

		nextCRC32_D48[0] = Data[47] ^ Data[45] ^ Data[44] ^ Data[37] ^ Data[34] ^ Data[32] ^ Data[31] ^ Data[30] ^ Data[29] ^ Data[28] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[16] ^ Data[12] ^ Data[10] ^ Data[9] ^ Data[6] ^ Data[0] ^ crc[0] ^ crc[8] ^ crc[9] ^ crc[10] ^ crc[12] ^ crc[13] ^ crc[14] ^ crc[15] ^ crc[16] ^ crc[18] ^ crc[21] ^ crc[28] ^ crc[29] ^ crc[31];
		nextCRC32_D48[1] = Data[47] ^ Data[46] ^ Data[44] ^ Data[38] ^ Data[37] ^ Data[35] ^ Data[34] ^ Data[33] ^ Data[28] ^ Data[27] ^ Data[24] ^ Data[17] ^ Data[16] ^ Data[13] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[7] ^ Data[6] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[8] ^ crc[11] ^ crc[12] ^ crc[17] ^ crc[18] ^ crc[19] ^ crc[21] ^ crc[22] ^ crc[28] ^ crc[30] ^ crc[31];
		nextCRC32_D48[2] = Data[44] ^ Data[39] ^ Data[38] ^ Data[37] ^ Data[36] ^ Data[35] ^ Data[32] ^ Data[31] ^ Data[30] ^ Data[26] ^ Data[24] ^ Data[18] ^ Data[17] ^ Data[16] ^ Data[14] ^ Data[13] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[2] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[2] ^ crc[8] ^ crc[10] ^ crc[14] ^ crc[15] ^ crc[16] ^ crc[19] ^ crc[20] ^ crc[21] ^ crc[22] ^ crc[23] ^ crc[28];
		nextCRC32_D48[3] = Data[45] ^ Data[40] ^ Data[39] ^ Data[38] ^ Data[37] ^ Data[36] ^ Data[33] ^ Data[32] ^ Data[31] ^ Data[27] ^ Data[25] ^ Data[19] ^ Data[18] ^ Data[17] ^ Data[15] ^ Data[14] ^ Data[10] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[3] ^ Data[2] ^ Data[1] ^ crc[1] ^ crc[2] ^ crc[3] ^ crc[9] ^ crc[11] ^ crc[15] ^ crc[16] ^ crc[17] ^ crc[20] ^ crc[21] ^ crc[22] ^ crc[23] ^ crc[24] ^ crc[29];
		nextCRC32_D48[4] = Data[47] ^ Data[46] ^ Data[45] ^ Data[44] ^ Data[41] ^ Data[40] ^ Data[39] ^ Data[38] ^ Data[33] ^ Data[31] ^ Data[30] ^ Data[29] ^ Data[25] ^ Data[24] ^ Data[20] ^ Data[19] ^ Data[18] ^ Data[15] ^ Data[12] ^ Data[11] ^ Data[8] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[2] ^ crc[3] ^ crc[4] ^ crc[8] ^ crc[9] ^ crc[13] ^ crc[14] ^ crc[15] ^ crc[17] ^ crc[22] ^ crc[23] ^ crc[24] ^ crc[25] ^ crc[28] ^ crc[29] ^ crc[30] ^ crc[31];
		nextCRC32_D48[5] = Data[46] ^ Data[44] ^ Data[42] ^ Data[41] ^ Data[40] ^ Data[39] ^ Data[37] ^ Data[29] ^ Data[28] ^ Data[24] ^ Data[21] ^ Data[20] ^ Data[19] ^ Data[13] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[3] ^ crc[4] ^ crc[5] ^ crc[8] ^ crc[12] ^ crc[13] ^ crc[21] ^ crc[23] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[30];
		nextCRC32_D48[6] = Data[47] ^ Data[45] ^ Data[43] ^ Data[42] ^ Data[41] ^ Data[40] ^ Data[38] ^ Data[30] ^ Data[29] ^ Data[25] ^ Data[22] ^ Data[21] ^ Data[20] ^ Data[14] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ crc[4] ^ crc[5] ^ crc[6] ^ crc[9] ^ crc[13] ^ crc[14] ^ crc[22] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[31];
		nextCRC32_D48[7] = Data[47] ^ Data[46] ^ Data[45] ^ Data[43] ^ Data[42] ^ Data[41] ^ Data[39] ^ Data[37] ^ Data[34] ^ Data[32] ^ Data[29] ^ Data[28] ^ Data[25] ^ Data[24] ^ Data[23] ^ Data[22] ^ Data[21] ^ Data[16] ^ Data[15] ^ Data[10] ^ Data[8] ^ Data[7] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[0] ^ crc[5] ^ crc[6] ^ crc[7] ^ crc[8] ^ crc[9] ^ crc[12] ^ crc[13] ^ crc[16] ^ crc[18] ^ crc[21] ^ crc[23] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[30] ^ crc[31];
		nextCRC32_D48[8] = Data[46] ^ Data[45] ^ Data[43] ^ Data[42] ^ Data[40] ^ Data[38] ^ Data[37] ^ Data[35] ^ Data[34] ^ Data[33] ^ Data[32] ^ Data[31] ^ Data[28] ^ Data[23] ^ Data[22] ^ Data[17] ^ Data[12] ^ Data[11] ^ Data[10] ^ Data[8] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[1] ^ crc[6] ^ crc[7] ^ crc[12] ^ crc[15] ^ crc[16] ^ crc[17] ^ crc[18] ^ crc[19] ^ crc[21] ^ crc[22] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[30];
		nextCRC32_D48[9] = Data[47] ^ Data[46] ^ Data[44] ^ Data[43] ^ Data[41] ^ Data[39] ^ Data[38] ^ Data[36] ^ Data[35] ^ Data[34] ^ Data[33] ^ Data[32] ^ Data[29] ^ Data[24] ^ Data[23] ^ Data[18] ^ Data[13] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ crc[2] ^ crc[7] ^ crc[8] ^ crc[13] ^ crc[16] ^ crc[17] ^ crc[18] ^ crc[19] ^ crc[20] ^ crc[22] ^ crc[23] ^ crc[25] ^ crc[27] ^ crc[28] ^ crc[30] ^ crc[31];
		nextCRC32_D48[10] = Data[42] ^ Data[40] ^ Data[39] ^ Data[36] ^ Data[35] ^ Data[33] ^ Data[32] ^ Data[31] ^ Data[29] ^ Data[28] ^ Data[26] ^ Data[19] ^ Data[16] ^ Data[14] ^ Data[13] ^ Data[9] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[0] ^ crc[3] ^ crc[10] ^ crc[12] ^ crc[13] ^ crc[15] ^ crc[16] ^ crc[17] ^ crc[19] ^ crc[20] ^ crc[23] ^ crc[24] ^ crc[26];
		nextCRC32_D48[11] = Data[47] ^ Data[45] ^ Data[44] ^ Data[43] ^ Data[41] ^ Data[40] ^ Data[36] ^ Data[33] ^ Data[31] ^ Data[28] ^ Data[27] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[20] ^ Data[17] ^ Data[16] ^ Data[15] ^ Data[14] ^ Data[12] ^ Data[9] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[4] ^ crc[8] ^ crc[9] ^ crc[10] ^ crc[11] ^ crc[12] ^ crc[15] ^ crc[17] ^ crc[20] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[31];
		nextCRC32_D48[12] = Data[47] ^ Data[46] ^ Data[42] ^ Data[41] ^ Data[31] ^ Data[30] ^ Data[27] ^ Data[24] ^ Data[21] ^ Data[18] ^ Data[17] ^ Data[15] ^ Data[13] ^ Data[12] ^ Data[9] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ Data[0] ^ crc[1] ^ crc[2] ^ crc[5] ^ crc[8] ^ crc[11] ^ crc[14] ^ crc[15] ^ crc[25] ^ crc[26] ^ crc[30] ^ crc[31];
		nextCRC32_D48[13] = Data[47] ^ Data[43] ^ Data[42] ^ Data[32] ^ Data[31] ^ Data[28] ^ Data[25] ^ Data[22] ^ Data[19] ^ Data[18] ^ Data[16] ^ Data[14] ^ Data[13] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[1] ^ crc[0] ^ crc[2] ^ crc[3] ^ crc[6] ^ crc[9] ^ crc[12] ^ crc[15] ^ crc[16] ^ crc[26] ^ crc[27] ^ crc[31];
		nextCRC32_D48[14] = Data[44] ^ Data[43] ^ Data[33] ^ Data[32] ^ Data[29] ^ Data[26] ^ Data[23] ^ Data[20] ^ Data[19] ^ Data[17] ^ Data[15] ^ Data[14] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[2] ^ crc[1] ^ crc[3] ^ crc[4] ^ crc[7] ^ crc[10] ^ crc[13] ^ crc[16] ^ crc[17] ^ crc[27] ^ crc[28];
		nextCRC32_D48[15] = Data[45] ^ Data[44] ^ Data[34] ^ Data[33] ^ Data[30] ^ Data[27] ^ Data[24] ^ Data[21] ^ Data[20] ^ Data[18] ^ Data[16] ^ Data[15] ^ Data[12] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[5] ^ Data[4] ^ Data[3] ^ crc[0] ^ crc[2] ^ crc[4] ^ crc[5] ^ crc[8] ^ crc[11] ^ crc[14] ^ crc[17] ^ crc[18] ^ crc[28] ^ crc[29];
		nextCRC32_D48[16] = Data[47] ^ Data[46] ^ Data[44] ^ Data[37] ^ Data[35] ^ Data[32] ^ Data[30] ^ Data[29] ^ Data[26] ^ Data[24] ^ Data[22] ^ Data[21] ^ Data[19] ^ Data[17] ^ Data[13] ^ Data[12] ^ Data[8] ^ Data[5] ^ Data[4] ^ Data[0] ^ crc[1] ^ crc[3] ^ crc[5] ^ crc[6] ^ crc[8] ^ crc[10] ^ crc[13] ^ crc[14] ^ crc[16] ^ crc[19] ^ crc[21] ^ crc[28] ^ crc[30] ^ crc[31];
		nextCRC32_D48[17] = Data[47] ^ Data[45] ^ Data[38] ^ Data[36] ^ Data[33] ^ Data[31] ^ Data[30] ^ Data[27] ^ Data[25] ^ Data[23] ^ Data[22] ^ Data[20] ^ Data[18] ^ Data[14] ^ Data[13] ^ Data[9] ^ Data[6] ^ Data[5] ^ Data[1] ^ crc[2] ^ crc[4] ^ crc[6] ^ crc[7] ^ crc[9] ^ crc[11] ^ crc[14] ^ crc[15] ^ crc[17] ^ crc[20] ^ crc[22] ^ crc[29] ^ crc[31];
		nextCRC32_D48[18] = Data[46] ^ Data[39] ^ Data[37] ^ Data[34] ^ Data[32] ^ Data[31] ^ Data[28] ^ Data[26] ^ Data[24] ^ Data[23] ^ Data[21] ^ Data[19] ^ Data[15] ^ Data[14] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[2] ^ crc[3] ^ crc[5] ^ crc[7] ^ crc[8] ^ crc[10] ^ crc[12] ^ crc[15] ^ crc[16] ^ crc[18] ^ crc[21] ^ crc[23] ^ crc[30];
		nextCRC32_D48[19] = Data[47] ^ Data[40] ^ Data[38] ^ Data[35] ^ Data[33] ^ Data[32] ^ Data[29] ^ Data[27] ^ Data[25] ^ Data[24] ^ Data[22] ^ Data[20] ^ Data[16] ^ Data[15] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[3] ^ crc[0] ^ crc[4] ^ crc[6] ^ crc[8] ^ crc[9] ^ crc[11] ^ crc[13] ^ crc[16] ^ crc[17] ^ crc[19] ^ crc[22] ^ crc[24] ^ crc[31];
		nextCRC32_D48[20] = Data[41] ^ Data[39] ^ Data[36] ^ Data[34] ^ Data[33] ^ Data[30] ^ Data[28] ^ Data[26] ^ Data[25] ^ Data[23] ^ Data[21] ^ Data[17] ^ Data[16] ^ Data[12] ^ Data[9] ^ Data[8] ^ Data[4] ^ crc[0] ^ crc[1] ^ crc[5] ^ crc[7] ^ crc[9] ^ crc[10] ^ crc[12] ^ crc[14] ^ crc[17] ^ crc[18] ^ crc[20] ^ crc[23] ^ crc[25];
		nextCRC32_D48[21] = Data[42] ^ Data[40] ^ Data[37] ^ Data[35] ^ Data[34] ^ Data[31] ^ Data[29] ^ Data[27] ^ Data[26] ^ Data[24] ^ Data[22] ^ Data[18] ^ Data[17] ^ Data[13] ^ Data[10] ^ Data[9] ^ Data[5] ^ crc[1] ^ crc[2] ^ crc[6] ^ crc[8] ^ crc[10] ^ crc[11] ^ crc[13] ^ crc[15] ^ crc[18] ^ crc[19] ^ crc[21] ^ crc[24] ^ crc[26];
		nextCRC32_D48[22] = Data[47] ^ Data[45] ^ Data[44] ^ Data[43] ^ Data[41] ^ Data[38] ^ Data[37] ^ Data[36] ^ Data[35] ^ Data[34] ^ Data[31] ^ Data[29] ^ Data[27] ^ Data[26] ^ Data[24] ^ Data[23] ^ Data[19] ^ Data[18] ^ Data[16] ^ Data[14] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[0] ^ crc[0] ^ crc[2] ^ crc[3] ^ crc[7] ^ crc[8] ^ crc[10] ^ crc[11] ^ crc[13] ^ crc[15] ^ crc[18] ^ crc[19] ^ crc[20] ^ crc[21] ^ crc[22] ^ crc[25] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[31];
		nextCRC32_D48[23] = Data[47] ^ Data[46] ^ Data[42] ^ Data[39] ^ Data[38] ^ Data[36] ^ Data[35] ^ Data[34] ^ Data[31] ^ Data[29] ^ Data[27] ^ Data[26] ^ Data[20] ^ Data[19] ^ Data[17] ^ Data[16] ^ Data[15] ^ Data[13] ^ Data[9] ^ Data[6] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[3] ^ crc[4] ^ crc[10] ^ crc[11] ^ crc[13] ^ crc[15] ^ crc[18] ^ crc[19] ^ crc[20] ^ crc[22] ^ crc[23] ^ crc[26] ^ crc[30] ^ crc[31];
		nextCRC32_D48[24] = Data[47] ^ Data[43] ^ Data[40] ^ Data[39] ^ Data[37] ^ Data[36] ^ Data[35] ^ Data[32] ^ Data[30] ^ Data[28] ^ Data[27] ^ Data[21] ^ Data[20] ^ Data[18] ^ Data[17] ^ Data[16] ^ Data[14] ^ Data[10] ^ Data[7] ^ Data[2] ^ Data[1] ^ crc[0] ^ crc[1] ^ crc[2] ^ crc[4] ^ crc[5] ^ crc[11] ^ crc[12] ^ crc[14] ^ crc[16] ^ crc[19] ^ crc[20] ^ crc[21] ^ crc[23] ^ crc[24] ^ crc[27] ^ crc[31];
		nextCRC32_D48[25] = Data[44] ^ Data[41] ^ Data[40] ^ Data[38] ^ Data[37] ^ Data[36] ^ Data[33] ^ Data[31] ^ Data[29] ^ Data[28] ^ Data[22] ^ Data[21] ^ Data[19] ^ Data[18] ^ Data[17] ^ Data[15] ^ Data[11] ^ Data[8] ^ Data[3] ^ Data[2] ^ crc[1] ^ crc[2] ^ crc[3] ^ crc[5] ^ crc[6] ^ crc[12] ^ crc[13] ^ crc[15] ^ crc[17] ^ crc[20] ^ crc[21] ^ crc[22] ^ crc[24] ^ crc[25] ^ crc[28];
		nextCRC32_D48[26] = Data[47] ^ Data[44] ^ Data[42] ^ Data[41] ^ Data[39] ^ Data[38] ^ Data[31] ^ Data[28] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[23] ^ Data[22] ^ Data[20] ^ Data[19] ^ Data[18] ^ Data[10] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[0] ^ crc[2] ^ crc[3] ^ crc[4] ^ crc[6] ^ crc[7] ^ crc[8] ^ crc[9] ^ crc[10] ^ crc[12] ^ crc[15] ^ crc[22] ^ crc[23] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[31];
		nextCRC32_D48[27] = Data[45] ^ Data[43] ^ Data[42] ^ Data[40] ^ Data[39] ^ Data[32] ^ Data[29] ^ Data[27] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[23] ^ Data[21] ^ Data[20] ^ Data[19] ^ Data[11] ^ Data[7] ^ Data[5] ^ Data[4] ^ Data[1] ^ crc[3] ^ crc[4] ^ crc[5] ^ crc[7] ^ crc[8] ^ crc[9] ^ crc[10] ^ crc[11] ^ crc[13] ^ crc[16] ^ crc[23] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[29];
		nextCRC32_D48[28] = Data[46] ^ Data[44] ^ Data[43] ^ Data[41] ^ Data[40] ^ Data[33] ^ Data[30] ^ Data[28] ^ Data[27] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[22] ^ Data[21] ^ Data[20] ^ Data[12] ^ Data[8] ^ Data[6] ^ Data[5] ^ Data[2] ^ crc[4] ^ crc[5] ^ crc[6] ^ crc[8] ^ crc[9] ^ crc[10] ^ crc[11] ^ crc[12] ^ crc[14] ^ crc[17] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28] ^ crc[30];
		nextCRC32_D48[29] = Data[47] ^ Data[45] ^ Data[44] ^ Data[42] ^ Data[41] ^ Data[34] ^ Data[31] ^ Data[29] ^ Data[28] ^ Data[27] ^ Data[26] ^ Data[25] ^ Data[23] ^ Data[22] ^ Data[21] ^ Data[13] ^ Data[9] ^ Data[7] ^ Data[6] ^ Data[3] ^ crc[5] ^ crc[6] ^ crc[7] ^ crc[9] ^ crc[10] ^ crc[11] ^ crc[12] ^ crc[13] ^ crc[15] ^ crc[18] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[29] ^ crc[31];
		nextCRC32_D48[30] = Data[46] ^ Data[45] ^ Data[43] ^ Data[42] ^ Data[35] ^ Data[32] ^ Data[30] ^ Data[29] ^ Data[28] ^ Data[27] ^ Data[26] ^ Data[24] ^ Data[23] ^ Data[22] ^ Data[14] ^ Data[10] ^ Data[8] ^ Data[7] ^ Data[4] ^ crc[6] ^ crc[7] ^ crc[8] ^ crc[10] ^ crc[11] ^ crc[12] ^ crc[13] ^ crc[14] ^ crc[16] ^ crc[19] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[30];
		nextCRC32_D48[31] = Data[47] ^ Data[46] ^ Data[44] ^ Data[43] ^ Data[36] ^ Data[33] ^ Data[31] ^ Data[30] ^ Data[29] ^ Data[28] ^ Data[27] ^ Data[25] ^ Data[24] ^ Data[23] ^ Data[15] ^ Data[11] ^ Data[9] ^ Data[8] ^ Data[5] ^ crc[7] ^ crc[8] ^ crc[9] ^ crc[11] ^ crc[12] ^ crc[13] ^ crc[14] ^ crc[15] ^ crc[17] ^ crc[20] ^ crc[27] ^ crc[28] ^ crc[30] ^ crc[31];

	end
endfunction


function [31:0] nextCRC32_D56;

	input [55:0] Data;
	input [31:0] crc;
	begin

		nextCRC32_D56[0] = Data[55] ^ Data[54] ^ Data[53] ^ Data[50] ^ Data[48] ^ Data[47] ^ Data[45] ^ Data[44] ^ Data[37] ^ Data[34] ^ Data[32] ^ Data[31] ^ Data[30] ^ Data[29] ^ Data[28] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[16] ^ Data[12] ^ Data[10] ^ Data[9] ^ Data[6] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[2] ^ crc[4] ^ crc[5] ^ crc[6] ^ crc[7] ^ crc[8] ^ crc[10] ^ crc[13] ^ crc[20] ^ crc[21] ^ crc[23] ^ crc[24] ^ crc[26] ^ crc[29] ^ crc[30] ^ crc[31];
		nextCRC32_D56[1] = Data[53] ^ Data[51] ^ Data[50] ^ Data[49] ^ Data[47] ^ Data[46] ^ Data[44] ^ Data[38] ^ Data[37] ^ Data[35] ^ Data[34] ^ Data[33] ^ Data[28] ^ Data[27] ^ Data[24] ^ Data[17] ^ Data[16] ^ Data[13] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[7] ^ Data[6] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[3] ^ crc[4] ^ crc[9] ^ crc[10] ^ crc[11] ^ crc[13] ^ crc[14] ^ crc[20] ^ crc[22] ^ crc[23] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[29];
		nextCRC32_D56[2] = Data[55] ^ Data[53] ^ Data[52] ^ Data[51] ^ Data[44] ^ Data[39] ^ Data[38] ^ Data[37] ^ Data[36] ^ Data[35] ^ Data[32] ^ Data[31] ^ Data[30] ^ Data[26] ^ Data[24] ^ Data[18] ^ Data[17] ^ Data[16] ^ Data[14] ^ Data[13] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[2] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[2] ^ crc[6] ^ crc[7] ^ crc[8] ^ crc[11] ^ crc[12] ^ crc[13] ^ crc[14] ^ crc[15] ^ crc[20] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[31];
		nextCRC32_D56[3] = Data[54] ^ Data[53] ^ Data[52] ^ Data[45] ^ Data[40] ^ Data[39] ^ Data[38] ^ Data[37] ^ Data[36] ^ Data[33] ^ Data[32] ^ Data[31] ^ Data[27] ^ Data[25] ^ Data[19] ^ Data[18] ^ Data[17] ^ Data[15] ^ Data[14] ^ Data[10] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[3] ^ Data[2] ^ Data[1] ^ crc[1] ^ crc[3] ^ crc[7] ^ crc[8] ^ crc[9] ^ crc[12] ^ crc[13] ^ crc[14] ^ crc[15] ^ crc[16] ^ crc[21] ^ crc[28] ^ crc[29] ^ crc[30];
		nextCRC32_D56[4] = Data[50] ^ Data[48] ^ Data[47] ^ Data[46] ^ Data[45] ^ Data[44] ^ Data[41] ^ Data[40] ^ Data[39] ^ Data[38] ^ Data[33] ^ Data[31] ^ Data[30] ^ Data[29] ^ Data[25] ^ Data[24] ^ Data[20] ^ Data[19] ^ Data[18] ^ Data[15] ^ Data[12] ^ Data[11] ^ Data[8] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[5] ^ crc[6] ^ crc[7] ^ crc[9] ^ crc[14] ^ crc[15] ^ crc[16] ^ crc[17] ^ crc[20] ^ crc[21] ^ crc[22] ^ crc[23] ^ crc[24] ^ crc[26];
		nextCRC32_D56[5] = Data[55] ^ Data[54] ^ Data[53] ^ Data[51] ^ Data[50] ^ Data[49] ^ Data[46] ^ Data[44] ^ Data[42] ^ Data[41] ^ Data[40] ^ Data[39] ^ Data[37] ^ Data[29] ^ Data[28] ^ Data[24] ^ Data[21] ^ Data[20] ^ Data[19] ^ Data[13] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[4] ^ crc[5] ^ crc[13] ^ crc[15] ^ crc[16] ^ crc[17] ^ crc[18] ^ crc[20] ^ crc[22] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[30] ^ crc[31];
		nextCRC32_D56[6] = Data[55] ^ Data[54] ^ Data[52] ^ Data[51] ^ Data[50] ^ Data[47] ^ Data[45] ^ Data[43] ^ Data[42] ^ Data[41] ^ Data[40] ^ Data[38] ^ Data[30] ^ Data[29] ^ Data[25] ^ Data[22] ^ Data[21] ^ Data[20] ^ Data[14] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ crc[1] ^ crc[5] ^ crc[6] ^ crc[14] ^ crc[16] ^ crc[17] ^ crc[18] ^ crc[19] ^ crc[21] ^ crc[23] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[30] ^ crc[31];
		nextCRC32_D56[7] = Data[54] ^ Data[52] ^ Data[51] ^ Data[50] ^ Data[47] ^ Data[46] ^ Data[45] ^ Data[43] ^ Data[42] ^ Data[41] ^ Data[39] ^ Data[37] ^ Data[34] ^ Data[32] ^ Data[29] ^ Data[28] ^ Data[25] ^ Data[24] ^ Data[23] ^ Data[22] ^ Data[21] ^ Data[16] ^ Data[15] ^ Data[10] ^ Data[8] ^ Data[7] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[4] ^ crc[5] ^ crc[8] ^ crc[10] ^ crc[13] ^ crc[15] ^ crc[17] ^ crc[18] ^ crc[19] ^ crc[21] ^ crc[22] ^ crc[23] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[30];
		nextCRC32_D56[8] = Data[54] ^ Data[52] ^ Data[51] ^ Data[50] ^ Data[46] ^ Data[45] ^ Data[43] ^ Data[42] ^ Data[40] ^ Data[38] ^ Data[37] ^ Data[35] ^ Data[34] ^ Data[33] ^ Data[32] ^ Data[31] ^ Data[28] ^ Data[23] ^ Data[22] ^ Data[17] ^ Data[12] ^ Data[11] ^ Data[10] ^ Data[8] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[4] ^ crc[7] ^ crc[8] ^ crc[9] ^ crc[10] ^ crc[11] ^ crc[13] ^ crc[14] ^ crc[16] ^ crc[18] ^ crc[19] ^ crc[21] ^ crc[22] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[30];
		nextCRC32_D56[9] = Data[55] ^ Data[53] ^ Data[52] ^ Data[51] ^ Data[47] ^ Data[46] ^ Data[44] ^ Data[43] ^ Data[41] ^ Data[39] ^ Data[38] ^ Data[36] ^ Data[35] ^ Data[34] ^ Data[33] ^ Data[32] ^ Data[29] ^ Data[24] ^ Data[23] ^ Data[18] ^ Data[13] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ crc[0] ^ crc[5] ^ crc[8] ^ crc[9] ^ crc[10] ^ crc[11] ^ crc[12] ^ crc[14] ^ crc[15] ^ crc[17] ^ crc[19] ^ crc[20] ^ crc[22] ^ crc[23] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[31];
		nextCRC32_D56[10] = Data[55] ^ Data[52] ^ Data[50] ^ Data[42] ^ Data[40] ^ Data[39] ^ Data[36] ^ Data[35] ^ Data[33] ^ Data[32] ^ Data[31] ^ Data[29] ^ Data[28] ^ Data[26] ^ Data[19] ^ Data[16] ^ Data[14] ^ Data[13] ^ Data[9] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[0] ^ crc[2] ^ crc[4] ^ crc[5] ^ crc[7] ^ crc[8] ^ crc[9] ^ crc[11] ^ crc[12] ^ crc[15] ^ crc[16] ^ crc[18] ^ crc[26] ^ crc[28] ^ crc[31];
		nextCRC32_D56[11] = Data[55] ^ Data[54] ^ Data[51] ^ Data[50] ^ Data[48] ^ Data[47] ^ Data[45] ^ Data[44] ^ Data[43] ^ Data[41] ^ Data[40] ^ Data[36] ^ Data[33] ^ Data[31] ^ Data[28] ^ Data[27] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[20] ^ Data[17] ^ Data[16] ^ Data[15] ^ Data[14] ^ Data[12] ^ Data[9] ^ Data[4] ^ Data[3] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[2] ^ crc[3] ^ crc[4] ^ crc[7] ^ crc[9] ^ crc[12] ^ crc[16] ^ crc[17] ^ crc[19] ^ crc[20] ^ crc[21] ^ crc[23] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[30] ^ crc[31];
		nextCRC32_D56[12] = Data[54] ^ Data[53] ^ Data[52] ^ Data[51] ^ Data[50] ^ Data[49] ^ Data[47] ^ Data[46] ^ Data[42] ^ Data[41] ^ Data[31] ^ Data[30] ^ Data[27] ^ Data[24] ^ Data[21] ^ Data[18] ^ Data[17] ^ Data[15] ^ Data[13] ^ Data[12] ^ Data[9] ^ Data[6] ^ Data[5] ^ Data[4] ^ Data[2] ^ Data[1] ^ Data[0] ^ crc[0] ^ crc[3] ^ crc[6] ^ crc[7] ^ crc[17] ^ crc[18] ^ crc[22] ^ crc[23] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[30];
		nextCRC32_D56[13] = Data[55] ^ Data[54] ^ Data[53] ^ Data[52] ^ Data[51] ^ Data[50] ^ Data[48] ^ Data[47] ^ Data[43] ^ Data[42] ^ Data[32] ^ Data[31] ^ Data[28] ^ Data[25] ^ Data[22] ^ Data[19] ^ Data[18] ^ Data[16] ^ Data[14] ^ Data[13] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[5] ^ Data[3] ^ Data[2] ^ Data[1] ^ crc[1] ^ crc[4] ^ crc[7] ^ crc[8] ^ crc[18] ^ crc[19] ^ crc[23] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[30] ^ crc[31];
		nextCRC32_D56[14] = Data[55] ^ Data[54] ^ Data[53] ^ Data[52] ^ Data[51] ^ Data[49] ^ Data[48] ^ Data[44] ^ Data[43] ^ Data[33] ^ Data[32] ^ Data[29] ^ Data[26] ^ Data[23] ^ Data[20] ^ Data[19] ^ Data[17] ^ Data[15] ^ Data[14] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[2] ^ crc[2] ^ crc[5] ^ crc[8] ^ crc[9] ^ crc[19] ^ crc[20] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[30] ^ crc[31];
		nextCRC32_D56[15] = Data[55] ^ Data[54] ^ Data[53] ^ Data[52] ^ Data[50] ^ Data[49] ^ Data[45] ^ Data[44] ^ Data[34] ^ Data[33] ^ Data[30] ^ Data[27] ^ Data[24] ^ Data[21] ^ Data[20] ^ Data[18] ^ Data[16] ^ Data[15] ^ Data[12] ^ Data[9] ^ Data[8] ^ Data[7] ^ Data[5] ^ Data[4] ^ Data[3] ^ crc[0] ^ crc[3] ^ crc[6] ^ crc[9] ^ crc[10] ^ crc[20] ^ crc[21] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[29] ^ crc[30] ^ crc[31];
		nextCRC32_D56[16] = Data[51] ^ Data[48] ^ Data[47] ^ Data[46] ^ Data[44] ^ Data[37] ^ Data[35] ^ Data[32] ^ Data[30] ^ Data[29] ^ Data[26] ^ Data[24] ^ Data[22] ^ Data[21] ^ Data[19] ^ Data[17] ^ Data[13] ^ Data[12] ^ Data[8] ^ Data[5] ^ Data[4] ^ Data[0] ^ crc[0] ^ crc[2] ^ crc[5] ^ crc[6] ^ crc[8] ^ crc[11] ^ crc[13] ^ crc[20] ^ crc[22] ^ crc[23] ^ crc[24] ^ crc[27];
		nextCRC32_D56[17] = Data[52] ^ Data[49] ^ Data[48] ^ Data[47] ^ Data[45] ^ Data[38] ^ Data[36] ^ Data[33] ^ Data[31] ^ Data[30] ^ Data[27] ^ Data[25] ^ Data[23] ^ Data[22] ^ Data[20] ^ Data[18] ^ Data[14] ^ Data[13] ^ Data[9] ^ Data[6] ^ Data[5] ^ Data[1] ^ crc[1] ^ crc[3] ^ crc[6] ^ crc[7] ^ crc[9] ^ crc[12] ^ crc[14] ^ crc[21] ^ crc[23] ^ crc[24] ^ crc[25] ^ crc[28];
		nextCRC32_D56[18] = Data[53] ^ Data[50] ^ Data[49] ^ Data[48] ^ Data[46] ^ Data[39] ^ Data[37] ^ Data[34] ^ Data[32] ^ Data[31] ^ Data[28] ^ Data[26] ^ Data[24] ^ Data[23] ^ Data[21] ^ Data[19] ^ Data[15] ^ Data[14] ^ Data[10] ^ Data[7] ^ Data[6] ^ Data[2] ^ crc[0] ^ crc[2] ^ crc[4] ^ crc[7] ^ crc[8] ^ crc[10] ^ crc[13] ^ crc[15] ^ crc[22] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[29];
		nextCRC32_D56[19] = Data[54] ^ Data[51] ^ Data[50] ^ Data[49] ^ Data[47] ^ Data[40] ^ Data[38] ^ Data[35] ^ Data[33] ^ Data[32] ^ Data[29] ^ Data[27] ^ Data[25] ^ Data[24] ^ Data[22] ^ Data[20] ^ Data[16] ^ Data[15] ^ Data[11] ^ Data[8] ^ Data[7] ^ Data[3] ^ crc[0] ^ crc[1] ^ crc[3] ^ crc[5] ^ crc[8] ^ crc[9] ^ crc[11] ^ crc[14] ^ crc[16] ^ crc[23] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[30];
		nextCRC32_D56[20] = Data[55] ^ Data[52] ^ Data[51] ^ Data[50] ^ Data[48] ^ Data[41] ^ Data[39] ^ Data[36] ^ Data[34] ^ Data[33] ^ Data[30] ^ Data[28] ^ Data[26] ^ Data[25] ^ Data[23] ^ Data[21] ^ Data[17] ^ Data[16] ^ Data[12] ^ Data[9] ^ Data[8] ^ Data[4] ^ crc[1] ^ crc[2] ^ crc[4] ^ crc[6] ^ crc[9] ^ crc[10] ^ crc[12] ^ crc[15] ^ crc[17] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[31];
		nextCRC32_D56[21] = Data[53] ^ Data[52] ^ Data[51] ^ Data[49] ^ Data[42] ^ Data[40] ^ Data[37] ^ Data[35] ^ Data[34] ^ Data[31] ^ Data[29] ^ Data[27] ^ Data[26] ^ Data[24] ^ Data[22] ^ Data[18] ^ Data[17] ^ Data[13] ^ Data[10] ^ Data[9] ^ Data[5] ^ crc[0] ^ crc[2] ^ crc[3] ^ crc[5] ^ crc[7] ^ crc[10] ^ crc[11] ^ crc[13] ^ crc[16] ^ crc[18] ^ crc[25] ^ crc[27] ^ crc[28] ^ crc[29];
		nextCRC32_D56[22] = Data[55] ^ Data[52] ^ Data[48] ^ Data[47] ^ Data[45] ^ Data[44] ^ Data[43] ^ Data[41] ^ Data[38] ^ Data[37] ^ Data[36] ^ Data[35] ^ Data[34] ^ Data[31] ^ Data[29] ^ Data[27] ^ Data[26] ^ Data[24] ^ Data[23] ^ Data[19] ^ Data[18] ^ Data[16] ^ Data[14] ^ Data[12] ^ Data[11] ^ Data[9] ^ Data[0] ^ crc[0] ^ crc[2] ^ crc[3] ^ crc[5] ^ crc[7] ^ crc[10] ^ crc[11] ^ crc[12] ^ crc[13] ^ crc[14] ^ crc[17] ^ crc[19] ^ crc[20] ^ crc[21] ^ crc[23] ^ crc[24] ^ crc[28] ^ crc[31];
		nextCRC32_D56[23] = Data[55] ^ Data[54] ^ Data[50] ^ Data[49] ^ Data[47] ^ Data[46] ^ Data[42] ^ Data[39] ^ Data[38] ^ Data[36] ^ Data[35] ^ Data[34] ^ Data[31] ^ Data[29] ^ Data[27] ^ Data[26] ^ Data[20] ^ Data[19] ^ Data[17] ^ Data[16] ^ Data[15] ^ Data[13] ^ Data[9] ^ Data[6] ^ Data[1] ^ Data[0] ^ crc[2] ^ crc[3] ^ crc[5] ^ crc[7] ^ crc[10] ^ crc[11] ^ crc[12] ^ crc[14] ^ crc[15] ^ crc[18] ^ crc[22] ^ crc[23] ^ crc[25] ^ crc[26] ^ crc[30] ^ crc[31];
		nextCRC32_D56[24] = Data[55] ^ Data[51] ^ Data[50] ^ Data[48] ^ Data[47] ^ Data[43] ^ Data[40] ^ Data[39] ^ Data[37] ^ Data[36] ^ Data[35] ^ Data[32] ^ Data[30] ^ Data[28] ^ Data[27] ^ Data[21] ^ Data[20] ^ Data[18] ^ Data[17] ^ Data[16] ^ Data[14] ^ Data[10] ^ Data[7] ^ Data[2] ^ Data[1] ^ crc[3] ^ crc[4] ^ crc[6] ^ crc[8] ^ crc[11] ^ crc[12] ^ crc[13] ^ crc[15] ^ crc[16] ^ crc[19] ^ crc[23] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[31];
		nextCRC32_D56[25] = Data[52] ^ Data[51] ^ Data[49] ^ Data[48] ^ Data[44] ^ Data[41] ^ Data[40] ^ Data[38] ^ Data[37] ^ Data[36] ^ Data[33] ^ Data[31] ^ Data[29] ^ Data[28] ^ Data[22] ^ Data[21] ^ Data[19] ^ Data[18] ^ Data[17] ^ Data[15] ^ Data[11] ^ Data[8] ^ Data[3] ^ Data[2] ^ crc[4] ^ crc[5] ^ crc[7] ^ crc[9] ^ crc[12] ^ crc[13] ^ crc[14] ^ crc[16] ^ crc[17] ^ crc[20] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28];
		nextCRC32_D56[26] = Data[55] ^ Data[54] ^ Data[52] ^ Data[49] ^ Data[48] ^ Data[47] ^ Data[44] ^ Data[42] ^ Data[41] ^ Data[39] ^ Data[38] ^ Data[31] ^ Data[28] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[23] ^ Data[22] ^ Data[20] ^ Data[19] ^ Data[18] ^ Data[10] ^ Data[6] ^ Data[4] ^ Data[3] ^ Data[0] ^ crc[0] ^ crc[1] ^ crc[2] ^ crc[4] ^ crc[7] ^ crc[14] ^ crc[15] ^ crc[17] ^ crc[18] ^ crc[20] ^ crc[23] ^ crc[24] ^ crc[25] ^ crc[28] ^ crc[30] ^ crc[31];
		nextCRC32_D56[27] = Data[55] ^ Data[53] ^ Data[50] ^ Data[49] ^ Data[48] ^ Data[45] ^ Data[43] ^ Data[42] ^ Data[40] ^ Data[39] ^ Data[32] ^ Data[29] ^ Data[27] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[23] ^ Data[21] ^ Data[20] ^ Data[19] ^ Data[11] ^ Data[7] ^ Data[5] ^ Data[4] ^ Data[1] ^ crc[0] ^ crc[1] ^ crc[2] ^ crc[3] ^ crc[5] ^ crc[8] ^ crc[15] ^ crc[16] ^ crc[18] ^ crc[19] ^ crc[21] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[29] ^ crc[31];
		nextCRC32_D56[28] = Data[54] ^ Data[51] ^ Data[50] ^ Data[49] ^ Data[46] ^ Data[44] ^ Data[43] ^ Data[41] ^ Data[40] ^ Data[33] ^ Data[30] ^ Data[28] ^ Data[27] ^ Data[26] ^ Data[25] ^ Data[24] ^ Data[22] ^ Data[21] ^ Data[20] ^ Data[12] ^ Data[8] ^ Data[6] ^ Data[5] ^ Data[2] ^ crc[0] ^ crc[1] ^ crc[2] ^ crc[3] ^ crc[4] ^ crc[6] ^ crc[9] ^ crc[16] ^ crc[17] ^ crc[19] ^ crc[20] ^ crc[22] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[30];
		nextCRC32_D56[29] = Data[55] ^ Data[52] ^ Data[51] ^ Data[50] ^ Data[47] ^ Data[45] ^ Data[44] ^ Data[42] ^ Data[41] ^ Data[34] ^ Data[31] ^ Data[29] ^ Data[28] ^ Data[27] ^ Data[26] ^ Data[25] ^ Data[23] ^ Data[22] ^ Data[21] ^ Data[13] ^ Data[9] ^ Data[7] ^ Data[6] ^ Data[3] ^ crc[1] ^ crc[2] ^ crc[3] ^ crc[4] ^ crc[5] ^ crc[7] ^ crc[10] ^ crc[17] ^ crc[18] ^ crc[20] ^ crc[21] ^ crc[23] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[31];
		nextCRC32_D56[30] = Data[53] ^ Data[52] ^ Data[51] ^ Data[48] ^ Data[46] ^ Data[45] ^ Data[43] ^ Data[42] ^ Data[35] ^ Data[32] ^ Data[30] ^ Data[29] ^ Data[28] ^ Data[27] ^ Data[26] ^ Data[24] ^ Data[23] ^ Data[22] ^ Data[14] ^ Data[10] ^ Data[8] ^ Data[7] ^ Data[4] ^ crc[0] ^ crc[2] ^ crc[3] ^ crc[4] ^ crc[5] ^ crc[6] ^ crc[8] ^ crc[11] ^ crc[18] ^ crc[19] ^ crc[21] ^ crc[22] ^ crc[24] ^ crc[27] ^ crc[28] ^ crc[29];
		nextCRC32_D56[31] = Data[54] ^ Data[53] ^ Data[52] ^ Data[49] ^ Data[47] ^ Data[46] ^ Data[44] ^ Data[43] ^ Data[36] ^ Data[33] ^ Data[31] ^ Data[30] ^ Data[29] ^ Data[28] ^ Data[27] ^ Data[25] ^ Data[24] ^ Data[23] ^ Data[15] ^ Data[11] ^ Data[9] ^ Data[8] ^ Data[5] ^ crc[0] ^ crc[1] ^ crc[3] ^ crc[4] ^ crc[5] ^ crc[6] ^ crc[7] ^ crc[9] ^ crc[12] ^ crc[19] ^ crc[20] ^ crc[22] ^ crc[23] ^ crc[25] ^ crc[28] ^ crc[29] ^ crc[30];
	end
endfunction

function [31:0] nextCRC32_D64;
		
		input [63:0] Data;
		input [31:0] CRC;

	begin
	
	
		nextCRC32_D64[0] = CRC[0] ^ CRC[2] ^ CRC[5] ^ CRC[12] ^ CRC[13] ^ CRC[15] ^ CRC[16] ^ CRC[18] ^ CRC[21] ^ CRC[22] ^ CRC[23] ^ CRC[26] ^ CRC[28] ^ CRC[29] ^ CRC[31] ^ Data[0] ^ Data[6] ^ Data[9] ^ Data[10] ^ Data[12] ^ Data[16] ^ Data[24] ^ Data[25] ^ Data[26] ^ Data[28] ^ Data[29] ^ Data[30] ^ Data[31] ^ Data[32] ^ Data[34] ^ Data[37] ^ Data[44] ^ Data[45] ^ Data[47] ^ Data[48] ^ Data[50] ^ Data[53] ^ Data[54] ^ Data[55] ^ Data[58] ^ Data[60] ^ Data[61] ^ Data[63];
		nextCRC32_D64[1] = CRC[1] ^ CRC[2] ^ CRC[3] ^ CRC[5] ^ CRC[6] ^ CRC[12] ^ CRC[14] ^ CRC[15] ^ CRC[17] ^ CRC[18] ^ CRC[19] ^ CRC[21] ^ CRC[24] ^ CRC[26] ^ CRC[27] ^ CRC[28] ^ CRC[30] ^ CRC[31] ^ Data[0] ^ Data[1] ^ Data[6] ^ Data[7] ^ Data[9] ^ Data[11] ^ Data[12] ^ Data[13] ^ Data[16] ^ Data[17] ^ Data[24] ^ Data[27] ^ Data[28] ^ Data[33] ^ Data[34] ^ Data[35] ^ Data[37] ^ Data[38] ^ Data[44] ^ Data[46] ^ Data[47] ^ Data[49] ^ Data[50] ^ Data[51] ^ Data[53] ^ Data[56] ^ Data[58] ^ Data[59] ^ Data[60] ^ Data[62] ^ Data[63];
		nextCRC32_D64[2] = CRC[0] ^ CRC[3] ^ CRC[4] ^ CRC[5] ^ CRC[6] ^ CRC[7] ^ CRC[12] ^ CRC[19] ^ CRC[20] ^ CRC[21] ^ CRC[23] ^ CRC[25] ^ CRC[26] ^ CRC[27] ^ Data[0] ^ Data[1] ^ Data[2] ^ Data[6] ^ Data[7] ^ Data[8] ^ Data[9] ^ Data[13] ^ Data[14] ^ Data[16] ^ Data[17] ^ Data[18] ^ Data[24] ^ Data[26] ^ Data[30] ^ Data[31] ^ Data[32] ^ Data[35] ^ Data[36] ^ Data[37] ^ Data[38] ^ Data[39] ^ Data[44] ^ Data[51] ^ Data[52] ^ Data[53] ^ Data[55] ^ Data[57] ^ Data[58] ^ Data[59];
		nextCRC32_D64[3] = CRC[0] ^ CRC[1] ^ CRC[4] ^ CRC[5] ^ CRC[6] ^ CRC[7] ^ CRC[8] ^ CRC[13] ^ CRC[20] ^ CRC[21] ^ CRC[22] ^ CRC[24] ^ CRC[26] ^ CRC[27] ^ CRC[28] ^ Data[1] ^ Data[2] ^ Data[3] ^ Data[7] ^ Data[8] ^ Data[9] ^ Data[10] ^ Data[14] ^ Data[15] ^ Data[17] ^ Data[18] ^ Data[19] ^ Data[25] ^ Data[27] ^ Data[31] ^ Data[32] ^ Data[33] ^ Data[36] ^ Data[37] ^ Data[38] ^ Data[39] ^ Data[40] ^ Data[45] ^ Data[52] ^ Data[53] ^ Data[54] ^ Data[56] ^ Data[58] ^ Data[59] ^ Data[60];
		nextCRC32_D64[4] = CRC[1] ^ CRC[6] ^ CRC[7] ^ CRC[8] ^ CRC[9] ^ CRC[12] ^ CRC[13] ^ CRC[14] ^ CRC[15] ^ CRC[16] ^ CRC[18] ^ CRC[25] ^ CRC[26] ^ CRC[27] ^ CRC[31] ^ Data[0] ^ Data[2] ^ Data[3] ^ Data[4] ^ Data[6] ^ Data[8] ^ Data[11] ^ Data[12] ^ Data[15] ^ Data[18] ^ Data[19] ^ Data[20] ^ Data[24] ^ Data[25] ^ Data[29] ^ Data[30] ^ Data[31] ^ Data[33] ^ Data[38] ^ Data[39] ^ Data[40] ^ Data[41] ^ Data[44] ^ Data[45] ^ Data[46] ^ Data[47] ^ Data[48] ^ Data[50] ^ Data[57] ^ Data[58] ^ Data[59] ^ Data[63];
		nextCRC32_D64[5] = CRC[5] ^ CRC[7] ^ CRC[8] ^ CRC[9] ^ CRC[10] ^ CRC[12] ^ CRC[14] ^ CRC[17] ^ CRC[18] ^ CRC[19] ^ CRC[21] ^ CRC[22] ^ CRC[23] ^ CRC[27] ^ CRC[29] ^ CRC[31] ^ Data[0] ^ Data[1] ^ Data[3] ^ Data[4] ^ Data[5] ^ Data[6] ^ Data[7] ^ Data[10] ^ Data[13] ^ Data[19] ^ Data[20] ^ Data[21] ^ Data[24] ^ Data[28] ^ Data[29] ^ Data[37] ^ Data[39] ^ Data[40] ^ Data[41] ^ Data[42] ^ Data[44] ^ Data[46] ^ Data[49] ^ Data[50] ^ Data[51] ^ Data[53] ^ Data[54] ^ Data[55] ^ Data[59] ^ Data[61] ^ Data[63];
		nextCRC32_D64[6] = CRC[6] ^ CRC[8] ^ CRC[9] ^ CRC[10] ^ CRC[11] ^ CRC[13] ^ CRC[15] ^ CRC[18] ^ CRC[19] ^ CRC[20] ^ CRC[22] ^ CRC[23] ^ CRC[24] ^ CRC[28] ^ CRC[30] ^ Data[1] ^ Data[2] ^ Data[4] ^ Data[5] ^ Data[6] ^ Data[7] ^ Data[8] ^ Data[11] ^ Data[14] ^ Data[20] ^ Data[21] ^ Data[22] ^ Data[25] ^ Data[29] ^ Data[30] ^ Data[38] ^ Data[40] ^ Data[41] ^ Data[42] ^ Data[43] ^ Data[45] ^ Data[47] ^ Data[50] ^ Data[51] ^ Data[52] ^ Data[54] ^ Data[55] ^ Data[56] ^ Data[60] ^ Data[62];
		nextCRC32_D64[7] = CRC[0] ^ CRC[2] ^ CRC[5] ^ CRC[7] ^ CRC[9] ^ CRC[10] ^ CRC[11] ^ CRC[13] ^ CRC[14] ^ CRC[15] ^ CRC[18] ^ CRC[19] ^ CRC[20] ^ CRC[22] ^ CRC[24] ^ CRC[25] ^ CRC[26] ^ CRC[28] ^ Data[0] ^ Data[2] ^ Data[3] ^ Data[5] ^ Data[7] ^ Data[8] ^ Data[10] ^ Data[15] ^ Data[16] ^ Data[21] ^ Data[22] ^ Data[23] ^ Data[24] ^ Data[25] ^ Data[28] ^ Data[29] ^ Data[32] ^ Data[34] ^ Data[37] ^ Data[39] ^ Data[41] ^ Data[42] ^ Data[43] ^ Data[45] ^ Data[46] ^ Data[47] ^ Data[50] ^ Data[51] ^ Data[52] ^ Data[54] ^ Data[56] ^ Data[57] ^ Data[58] ^ Data[60];
		nextCRC32_D64[8] = CRC[0] ^ CRC[1] ^ CRC[2] ^ CRC[3] ^ CRC[5] ^ CRC[6] ^ CRC[8] ^ CRC[10] ^ CRC[11] ^ CRC[13] ^ CRC[14] ^ CRC[18] ^ CRC[19] ^ CRC[20] ^ CRC[22] ^ CRC[25] ^ CRC[27] ^ CRC[28] ^ CRC[31] ^ Data[0] ^ Data[1] ^ Data[3] ^ Data[4] ^ Data[8] ^ Data[10] ^ Data[11] ^ Data[12] ^ Data[17] ^ Data[22] ^ Data[23] ^ Data[28] ^ Data[31] ^ Data[32] ^ Data[33] ^ Data[34] ^ Data[35] ^ Data[37] ^ Data[38] ^ Data[40] ^ Data[42] ^ Data[43] ^ Data[45] ^ Data[46] ^ Data[50] ^ Data[51] ^ Data[52] ^ Data[54] ^ Data[57] ^ Data[59] ^ Data[60] ^ Data[63];
		nextCRC32_D64[9] = CRC[0] ^ CRC[1] ^ CRC[2] ^ CRC[3] ^ CRC[4] ^ CRC[6] ^ CRC[7] ^ CRC[9] ^ CRC[11] ^ CRC[12] ^ CRC[14] ^ CRC[15] ^ CRC[19] ^ CRC[20] ^ CRC[21] ^ CRC[23] ^ CRC[26] ^ CRC[28] ^ CRC[29] ^ Data[1] ^ Data[2] ^ Data[4] ^ Data[5] ^ Data[9] ^ Data[11] ^ Data[12] ^ Data[13] ^ Data[18] ^ Data[23] ^ Data[24] ^ Data[29] ^ Data[32] ^ Data[33] ^ Data[34] ^ Data[35] ^ Data[36] ^ Data[38] ^ Data[39] ^ Data[41] ^ Data[43] ^ Data[44] ^ Data[46] ^ Data[47] ^ Data[51] ^ Data[52] ^ Data[53] ^ Data[55] ^ Data[58] ^ Data[60] ^ Data[61];
		nextCRC32_D64[10] = CRC[0] ^ CRC[1] ^ CRC[3] ^ CRC[4] ^ CRC[7] ^ CRC[8] ^ CRC[10] ^ CRC[18] ^ CRC[20] ^ CRC[23] ^ CRC[24] ^ CRC[26] ^ CRC[27] ^ CRC[28] ^ CRC[30] ^ CRC[31] ^ Data[0] ^ Data[2] ^ Data[3] ^ Data[5] ^ Data[9] ^ Data[13] ^ Data[14] ^ Data[16] ^ Data[19] ^ Data[26] ^ Data[28] ^ Data[29] ^ Data[31] ^ Data[32] ^ Data[33] ^ Data[35] ^ Data[36] ^ Data[39] ^ Data[40] ^ Data[42] ^ Data[50] ^ Data[52] ^ Data[55] ^ Data[56] ^ Data[58] ^ Data[59] ^ Data[60] ^ Data[62] ^ Data[63];
		nextCRC32_D64[11] = CRC[1] ^ CRC[4] ^ CRC[8] ^ CRC[9] ^ CRC[11] ^ CRC[12] ^ CRC[13] ^ CRC[15] ^ CRC[16] ^ CRC[18] ^ CRC[19] ^ CRC[22] ^ CRC[23] ^ CRC[24] ^ CRC[25] ^ CRC[26] ^ CRC[27] ^ Data[0] ^ Data[1] ^ Data[3] ^ Data[4] ^ Data[9] ^ Data[12] ^ Data[14] ^ Data[15] ^ Data[16] ^ Data[17] ^ Data[20] ^ Data[24] ^ Data[25] ^ Data[26] ^ Data[27] ^ Data[28] ^ Data[31] ^ Data[33] ^ Data[36] ^ Data[40] ^ Data[41] ^ Data[43] ^ Data[44] ^ Data[45] ^ Data[47] ^ Data[48] ^ Data[50] ^ Data[51] ^ Data[54] ^ Data[55] ^ Data[56] ^ Data[57] ^ Data[58] ^ Data[59];
		nextCRC32_D64[12] = CRC[9] ^ CRC[10] ^ CRC[14] ^ CRC[15] ^ CRC[17] ^ CRC[18] ^ CRC[19] ^ CRC[20] ^ CRC[21] ^ CRC[22] ^ CRC[24] ^ CRC[25] ^ CRC[27] ^ CRC[29] ^ CRC[31] ^ Data[0] ^ Data[1] ^ Data[2] ^ Data[4] ^ Data[5] ^ Data[6] ^ Data[9] ^ Data[12] ^ Data[13] ^ Data[15] ^ Data[17] ^ Data[18] ^ Data[21] ^ Data[24] ^ Data[27] ^ Data[30] ^ Data[31] ^ Data[41] ^ Data[42] ^ Data[46] ^ Data[47] ^ Data[49] ^ Data[50] ^ Data[51] ^ Data[52] ^ Data[53] ^ Data[54] ^ Data[56] ^ Data[57] ^ Data[59] ^ Data[61] ^ Data[63];
		nextCRC32_D64[13] = CRC[0] ^ CRC[10] ^ CRC[11] ^ CRC[15] ^ CRC[16] ^ CRC[18] ^ CRC[19] ^ CRC[20] ^ CRC[21] ^ CRC[22] ^ CRC[23] ^ CRC[25] ^ CRC[26] ^ CRC[28] ^ CRC[30] ^ Data[1] ^ Data[2] ^ Data[3] ^ Data[5] ^ Data[6] ^ Data[7] ^ Data[10] ^ Data[13] ^ Data[14] ^ Data[16] ^ Data[18] ^ Data[19] ^ Data[22] ^ Data[25] ^ Data[28] ^ Data[31] ^ Data[32] ^ Data[42] ^ Data[43] ^ Data[47] ^ Data[48] ^ Data[50] ^ Data[51] ^ Data[52] ^ Data[53] ^ Data[54] ^ Data[55] ^ Data[57] ^ Data[58] ^ Data[60] ^ Data[62];
		nextCRC32_D64[14] = CRC[0] ^ CRC[1] ^ CRC[11] ^ CRC[12] ^ CRC[16] ^ CRC[17] ^ CRC[19] ^ CRC[20] ^ CRC[21] ^ CRC[22] ^ CRC[23] ^ CRC[24] ^ CRC[26] ^ CRC[27] ^ CRC[29] ^ CRC[31] ^ Data[2] ^ Data[3] ^ Data[4] ^ Data[6] ^ Data[7] ^ Data[8] ^ Data[11] ^ Data[14] ^ Data[15] ^ Data[17] ^ Data[19] ^ Data[20] ^ Data[23] ^ Data[26] ^ Data[29] ^ Data[32] ^ Data[33] ^ Data[43] ^ Data[44] ^ Data[48] ^ Data[49] ^ Data[51] ^ Data[52] ^ Data[53] ^ Data[54] ^ Data[55] ^ Data[56] ^ Data[58] ^ Data[59] ^ Data[61] ^ Data[63];
		nextCRC32_D64[15] = CRC[1] ^ CRC[2] ^ CRC[12] ^ CRC[13] ^ CRC[17] ^ CRC[18] ^ CRC[20] ^ CRC[21] ^ CRC[22] ^ CRC[23] ^ CRC[24] ^ CRC[25] ^ CRC[27] ^ CRC[28] ^ CRC[30] ^ Data[3] ^ Data[4] ^ Data[5] ^ Data[7] ^ Data[8] ^ Data[9] ^ Data[12] ^ Data[15] ^ Data[16] ^ Data[18] ^ Data[20] ^ Data[21] ^ Data[24] ^ Data[27] ^ Data[30] ^ Data[33] ^ Data[34] ^ Data[44] ^ Data[45] ^ Data[49] ^ Data[50] ^ Data[52] ^ Data[53] ^ Data[54] ^ Data[55] ^ Data[56] ^ Data[57] ^ Data[59] ^ Data[60] ^ Data[62];
		nextCRC32_D64[16] = CRC[0] ^ CRC[3] ^ CRC[5] ^ CRC[12] ^ CRC[14] ^ CRC[15] ^ CRC[16] ^ CRC[19] ^ CRC[24] ^ CRC[25] ^ Data[0] ^ Data[4] ^ Data[5] ^ Data[8] ^ Data[12] ^ Data[13] ^ Data[17] ^ Data[19] ^ Data[21] ^ Data[22] ^ Data[24] ^ Data[26] ^ Data[29] ^ Data[30] ^ Data[32] ^ Data[35] ^ Data[37] ^ Data[44] ^ Data[46] ^ Data[47] ^ Data[48] ^ Data[51] ^ Data[56] ^ Data[57];
		nextCRC32_D64[17] = CRC[1] ^ CRC[4] ^ CRC[6] ^ CRC[13] ^ CRC[15] ^ CRC[16] ^ CRC[17] ^ CRC[20] ^ CRC[25] ^ CRC[26] ^ Data[1] ^ Data[5] ^ Data[6] ^ Data[9] ^ Data[13] ^ Data[14] ^ Data[18] ^ Data[20] ^ Data[22] ^ Data[23] ^ Data[25] ^ Data[27] ^ Data[30] ^ Data[31] ^ Data[33] ^ Data[36] ^ Data[38] ^ Data[45] ^ Data[47] ^ Data[48] ^ Data[49] ^ Data[52] ^ Data[57] ^ Data[58];
		nextCRC32_D64[18] = CRC[0] ^ CRC[2] ^ CRC[5] ^ CRC[7] ^ CRC[14] ^ CRC[16] ^ CRC[17] ^ CRC[18] ^ CRC[21] ^ CRC[26] ^ CRC[27] ^ Data[2] ^ Data[6] ^ Data[7] ^ Data[10] ^ Data[14] ^ Data[15] ^ Data[19] ^ Data[21] ^ Data[23] ^ Data[24] ^ Data[26] ^ Data[28] ^ Data[31] ^ Data[32] ^ Data[34] ^ Data[37] ^ Data[39] ^ Data[46] ^ Data[48] ^ Data[49] ^ Data[50] ^ Data[53] ^ Data[58] ^ Data[59];
		nextCRC32_D64[19] = CRC[0] ^ CRC[1] ^ CRC[3] ^ CRC[6] ^ CRC[8] ^ CRC[15] ^ CRC[17] ^ CRC[18] ^ CRC[19] ^ CRC[22] ^ CRC[27] ^ CRC[28] ^ Data[3] ^ Data[7] ^ Data[8] ^ Data[11] ^ Data[15] ^ Data[16] ^ Data[20] ^ Data[22] ^ Data[24] ^ Data[25] ^ Data[27] ^ Data[29] ^ Data[32] ^ Data[33] ^ Data[35] ^ Data[38] ^ Data[40] ^ Data[47] ^ Data[49] ^ Data[50] ^ Data[51] ^ Data[54] ^ Data[59] ^ Data[60];
		nextCRC32_D64[20] = CRC[1] ^ CRC[2] ^ CRC[4] ^ CRC[7] ^ CRC[9] ^ CRC[16] ^ CRC[18] ^ CRC[19] ^ CRC[20] ^ CRC[23] ^ CRC[28] ^ CRC[29] ^ Data[4] ^ Data[8] ^ Data[9] ^ Data[12] ^ Data[16] ^ Data[17] ^ Data[21] ^ Data[23] ^ Data[25] ^ Data[26] ^ Data[28] ^ Data[30] ^ Data[33] ^ Data[34] ^ Data[36] ^ Data[39] ^ Data[41] ^ Data[48] ^ Data[50] ^ Data[51] ^ Data[52] ^ Data[55] ^ Data[60] ^ Data[61];
		nextCRC32_D64[21] = CRC[2] ^ CRC[3] ^ CRC[5] ^ CRC[8] ^ CRC[10] ^ CRC[17] ^ CRC[19] ^ CRC[20] ^ CRC[21] ^ CRC[24] ^ CRC[29] ^ CRC[30] ^ Data[5] ^ Data[9] ^ Data[10] ^ Data[13] ^ Data[17] ^ Data[18] ^ Data[22] ^ Data[24] ^ Data[26] ^ Data[27] ^ Data[29] ^ Data[31] ^ Data[34] ^ Data[35] ^ Data[37] ^ Data[40] ^ Data[42] ^ Data[49] ^ Data[51] ^ Data[52] ^ Data[53] ^ Data[56] ^ Data[61] ^ Data[62];
		nextCRC32_D64[22] = CRC[2] ^ CRC[3] ^ CRC[4] ^ CRC[5] ^ CRC[6] ^ CRC[9] ^ CRC[11] ^ CRC[12] ^ CRC[13] ^ CRC[15] ^ CRC[16] ^ CRC[20] ^ CRC[23] ^ CRC[25] ^ CRC[26] ^ CRC[28] ^ CRC[29] ^ CRC[30] ^ Data[0] ^ Data[9] ^ Data[11] ^ Data[12] ^ Data[14] ^ Data[16] ^ Data[18] ^ Data[19] ^ Data[23] ^ Data[24] ^ Data[26] ^ Data[27] ^ Data[29] ^ Data[31] ^ Data[34] ^ Data[35] ^ Data[36] ^ Data[37] ^ Data[38] ^ Data[41] ^ Data[43] ^ Data[44] ^ Data[45] ^ Data[47] ^ Data[48] ^ Data[52] ^ Data[55] ^ Data[57] ^ Data[58] ^ Data[60] ^ Data[61] ^ Data[62];
		nextCRC32_D64[23] = CRC[2] ^ CRC[3] ^ CRC[4] ^ CRC[6] ^ CRC[7] ^ CRC[10] ^ CRC[14] ^ CRC[15] ^ CRC[17] ^ CRC[18] ^ CRC[22] ^ CRC[23] ^ CRC[24] ^ CRC[27] ^ CRC[28] ^ CRC[30] ^ Data[0] ^ Data[1] ^ Data[6] ^ Data[9] ^ Data[13] ^ Data[15] ^ Data[16] ^ Data[17] ^ Data[19] ^ Data[20] ^ Data[26] ^ Data[27] ^ Data[29] ^ Data[31] ^ Data[34] ^ Data[35] ^ Data[36] ^ Data[38] ^ Data[39] ^ Data[42] ^ Data[46] ^ Data[47] ^ Data[49] ^ Data[50] ^ Data[54] ^ Data[55] ^ Data[56] ^ Data[59] ^ Data[60] ^ Data[62];
		nextCRC32_D64[24] = CRC[0] ^ CRC[3] ^ CRC[4] ^ CRC[5] ^ CRC[7] ^ CRC[8] ^ CRC[11] ^ CRC[15] ^ CRC[16] ^ CRC[18] ^ CRC[19] ^ CRC[23] ^ CRC[24] ^ CRC[25] ^ CRC[28] ^ CRC[29] ^ CRC[31] ^ Data[1] ^ Data[2] ^ Data[7] ^ Data[10] ^ Data[14] ^ Data[16] ^ Data[17] ^ Data[18] ^ Data[20] ^ Data[21] ^ Data[27] ^ Data[28] ^ Data[30] ^ Data[32] ^ Data[35] ^ Data[36] ^ Data[37] ^ Data[39] ^ Data[40] ^ Data[43] ^ Data[47] ^ Data[48] ^ Data[50] ^ Data[51] ^ Data[55] ^ Data[56] ^ Data[57] ^ Data[60] ^ Data[61] ^ Data[63];
		nextCRC32_D64[25] = CRC[1] ^ CRC[4] ^ CRC[5] ^ CRC[6] ^ CRC[8] ^ CRC[9] ^ CRC[12] ^ CRC[16] ^ CRC[17] ^ CRC[19] ^ CRC[20] ^ CRC[24] ^ CRC[25] ^ CRC[26] ^ CRC[29] ^ CRC[30] ^ Data[2] ^ Data[3] ^ Data[8] ^ Data[11] ^ Data[15] ^ Data[17] ^ Data[18] ^ Data[19] ^ Data[21] ^ Data[22] ^ Data[28] ^ Data[29] ^ Data[31] ^ Data[33] ^ Data[36] ^ Data[37] ^ Data[38] ^ Data[40] ^ Data[41] ^ Data[44] ^ Data[48] ^ Data[49] ^ Data[51] ^ Data[52] ^ Data[56] ^ Data[57] ^ Data[58] ^ Data[61] ^ Data[62];
		nextCRC32_D64[26] = CRC[6] ^ CRC[7] ^ CRC[9] ^ CRC[10] ^ CRC[12] ^ CRC[15] ^ CRC[16] ^ CRC[17] ^ CRC[20] ^ CRC[22] ^ CRC[23] ^ CRC[25] ^ CRC[27] ^ CRC[28] ^ CRC[29] ^ CRC[30] ^ Data[0] ^ Data[3] ^ Data[4] ^ Data[6] ^ Data[10] ^ Data[18] ^ Data[19] ^ Data[20] ^ Data[22] ^ Data[23] ^ Data[24] ^ Data[25] ^ Data[26] ^ Data[28] ^ Data[31] ^ Data[38] ^ Data[39] ^ Data[41] ^ Data[42] ^ Data[44] ^ Data[47] ^ Data[48] ^ Data[49] ^ Data[52] ^ Data[54] ^ Data[55] ^ Data[57] ^ Data[59] ^ Data[60] ^ Data[61] ^ Data[62];
		nextCRC32_D64[27] = CRC[0] ^ CRC[7] ^ CRC[8] ^ CRC[10] ^ CRC[11] ^ CRC[13] ^ CRC[16] ^ CRC[17] ^ CRC[18] ^ CRC[21] ^ CRC[23] ^ CRC[24] ^ CRC[26] ^ CRC[28] ^ CRC[29] ^ CRC[30] ^ CRC[31] ^ Data[1] ^ Data[4] ^ Data[5] ^ Data[7] ^ Data[11] ^ Data[19] ^ Data[20] ^ Data[21] ^ Data[23] ^ Data[24] ^ Data[25] ^ Data[26] ^ Data[27] ^ Data[29] ^ Data[32] ^ Data[39] ^ Data[40] ^ Data[42] ^ Data[43] ^ Data[45] ^ Data[48] ^ Data[49] ^ Data[50] ^ Data[53] ^ Data[55] ^ Data[56] ^ Data[58] ^ Data[60] ^ Data[61] ^ Data[62] ^ Data[63];
		nextCRC32_D64[28] = CRC[1] ^ CRC[8] ^ CRC[9] ^ CRC[11] ^ CRC[12] ^ CRC[14] ^ CRC[17] ^ CRC[18] ^ CRC[19] ^ CRC[22] ^ CRC[24] ^ CRC[25] ^ CRC[27] ^ CRC[29] ^ CRC[30] ^ CRC[31] ^ Data[2] ^ Data[5] ^ Data[6] ^ Data[8] ^ Data[12] ^ Data[20] ^ Data[21] ^ Data[22] ^ Data[24] ^ Data[25] ^ Data[26] ^ Data[27] ^ Data[28] ^ Data[30] ^ Data[33] ^ Data[40] ^ Data[41] ^ Data[43] ^ Data[44] ^ Data[46] ^ Data[49] ^ Data[50] ^ Data[51] ^ Data[54] ^ Data[56] ^ Data[57] ^ Data[59] ^ Data[61] ^ Data[62] ^ Data[63];
		nextCRC32_D64[29] = CRC[2] ^ CRC[9] ^ CRC[10] ^ CRC[12] ^ CRC[13] ^ CRC[15] ^ CRC[18] ^ CRC[19] ^ CRC[20] ^ CRC[23] ^ CRC[25] ^ CRC[26] ^ CRC[28] ^ CRC[30] ^ CRC[31] ^ Data[3] ^ Data[6] ^ Data[7] ^ Data[9] ^ Data[13] ^ Data[21] ^ Data[22] ^ Data[23] ^ Data[25] ^ Data[26] ^ Data[27] ^ Data[28] ^ Data[29] ^ Data[31] ^ Data[34] ^ Data[41] ^ Data[42] ^ Data[44] ^ Data[45] ^ Data[47] ^ Data[50] ^ Data[51] ^ Data[52] ^ Data[55] ^ Data[57] ^ Data[58] ^ Data[60] ^ Data[62] ^ Data[63];
		nextCRC32_D64[30] = CRC[0] ^ CRC[3] ^ CRC[10] ^ CRC[11] ^ CRC[13] ^ CRC[14] ^ CRC[16] ^ CRC[19] ^ CRC[20] ^ CRC[21] ^ CRC[24] ^ CRC[26] ^ CRC[27] ^ CRC[29] ^ CRC[31] ^ Data[4] ^ Data[7] ^ Data[8] ^ Data[10] ^ Data[14] ^ Data[22] ^ Data[23] ^ Data[24] ^ Data[26] ^ Data[27] ^ Data[28] ^ Data[29] ^ Data[30] ^ Data[32] ^ Data[35] ^ Data[42] ^ Data[43] ^ Data[45] ^ Data[46] ^ Data[48] ^ Data[51] ^ Data[52] ^ Data[53] ^ Data[56] ^ Data[58] ^ Data[59] ^ Data[61] ^ Data[63];
		nextCRC32_D64[31] = CRC[1] ^ CRC[4] ^ CRC[11] ^ CRC[12] ^ CRC[14] ^ CRC[15] ^ CRC[17] ^ CRC[20] ^ CRC[21] ^ CRC[22] ^ CRC[25] ^ CRC[27] ^ CRC[28] ^ CRC[30] ^ Data[5] ^ Data[8] ^ Data[9] ^ Data[11] ^ Data[15] ^ Data[23] ^ Data[24] ^ Data[25] ^ Data[27] ^ Data[28] ^ Data[29] ^ Data[30] ^ Data[31] ^ Data[33] ^ Data[36] ^ Data[43] ^ Data[44] ^ Data[46] ^ Data[47] ^ Data[49] ^ Data[52] ^ Data[53] ^ Data[54] ^ Data[57] ^ Data[59] ^ Data[60] ^ Data[62];

	
	end

endfunction

function [63:0] reverse_64b;
  input [63:0]   data_reverse_64b;
  integer        i;
    begin
        for (i = 0; i < 64; i = i + 1) begin
            reverse_64b[i] = data_reverse_64b[63 - i];
        end
    end
endfunction


function [31:0] reverse_32b;
  input [31:0]   data_reverse_32b;
  integer        i;
    begin
        for (i = 0; i < 32; i = i + 1) begin
            reverse_32b[i] = data_reverse_32b[31 - i];
        end
    end
endfunction


function [7:0] reverse_8b;
  input [7:0]   data_reverse_8b;
  integer        i;
    begin
        for (i = 0; i < 8; i = i + 1) begin
            reverse_8b[i] = data_reverse_8b[7 - i];
        end
    end
endfunction

`endif //OC_MAC_CRC_FUNC