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
module data_swap
#(
	parameter WIDTH = 32
)(
	//OUTPUTS
	output [WIDTH - 1:0] data_swap,
	//INPUTS
	input  [WIDTH - 1:0] data_in,
	input  [ 1:0] swap_type
);

//=====================================================================================
// Swap Types
//=====================================================================================
localparam NO_SWAP        = 2'b00;
localparam HALF_WORD_SWAP = 2'b01;
localparam BYTE_SWAP      = 2'b10;
localparam BIT_SWAP       = 2'b11;

localparam TYPES = 4;

wire [WIDTH - 1 : 0] words[0 : TYPES - 1];

generate
	genvar i, j;
	for(i = 0; i < TYPES; i = i + 1)
	begin:BLOCK
		for(j = 0; j < WIDTH; j = j + 1)
			begin: SUB_BLOCK
				if(i != 3)
					assign words[i][j] = data_in[(WIDTH - (WIDTH/2**i)) - 2*(WIDTH/2**i)*(j/(WIDTH/2**i)) + j];
				else
					assign words[i][j] = data_in[WIDTH - 1 - j];
			end
	end
endgenerate

assign data_swap = words[swap_type];

endmodule
