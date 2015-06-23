//////////////////////////////////////////////////////////////////
////
////
//// 	CRCAHB CORE BLOCK
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
//// crcahb IP core specification document.
////
////
////
//// To Do: Things are right here but always all block can suffer changes
////
////
////
////
////
//// Author(s): -  Julio Cesar 
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

`define size ((DATA_SIZE/4) * (2 ** (type - 1)))

module bit_reversal
#(
	parameter DATA_SIZE = 32
)
(
	//OUTPUTS
	output [DATA_SIZE - 1 : 0] data_out,
	//INPUTS
	input  [DATA_SIZE - 1 : 0] data_in,
	input  [1 : 0] rev_type
);


//Bit reversing types
localparam NO_REVERSE = 2'b00; 
localparam BYTE       = 2'b01;
localparam HALF_WORD  = 2'b10;
localparam WORD       = 2'b11;

localparam TYPES = 4;

wire [DATA_SIZE - 1 : 0] data_reversed[0 : 3];


assign data_reversed[NO_REVERSE] = data_in; //bit order not affected

generate
	genvar i, type;
	for(type = 1 ; type < TYPES; type = type + 1)
		for(i = 0; i < DATA_SIZE; i = i + 1)
			begin
				if(i < `size)
					assign data_reversed[type][i] = data_in[`size*((i/`size) + 1) - 1 - i];
				else
					assign data_reversed[type][i] = data_in[`size*((i/`size) + 1) - 1 - (i%(`size*(i/`size)))];
			end
endgenerate

//Output Mux
assign data_out = data_reversed[rev_type];

endmodule
