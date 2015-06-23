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
module crc_parallel
#(
	parameter CRC_SIZE      = 8,         // Define the size of CRC Code
	parameter FRAME_SIZE    = 8          // Number of bits in the data block
)(
	//OUTPUTS
	output [CRC_SIZE   - 1 : 0] crc_out,
	//INPUTS
	input  [FRAME_SIZE - 1 : 0] data_in,
	input  [CRC_SIZE   - 1 : 0] crc_init,
	input  [CRC_SIZE   - 1 : 0] crc_poly,
	input  [CRC_SIZE   - 1 : 0] crc_poly_size
);
localparam ENABLE  = {CRC_SIZE{1'b1}};
localparam DISABLE = {CRC_SIZE{1'b0}};

wire [CRC_SIZE - 1 : 0] crc_comb_out[0 : FRAME_SIZE];
wire [CRC_SIZE - 1 : 0] poly_sel    [1 : CRC_SIZE - 1];
wire [CRC_SIZE - 1 : 0] sel_out     [0 : CRC_SIZE - 1];
wire [CRC_SIZE - 1 : 0] crc_init_sel[0 : CRC_SIZE - 1];
wire [CRC_SIZE - 1 : 0] poly_mux;
wire [CRC_SIZE - 1 : 0] crc_poly_size_reversed;
wire [CRC_SIZE - 1 : 0] crc_init_justified;

assign poly_mux[0] = crc_poly[0];
generate
  genvar k;
	for(k = 1; k < CRC_SIZE; k = k + 1)
		begin
			assign poly_sel[CRC_SIZE - k] = crc_poly_size >> (k - 1);
			assign poly_mux[k] = |(crc_poly & poly_sel[k]);
		end
endgenerate

generate
	genvar l;
	for(l = 0; l < CRC_SIZE; l = l + 1)
		begin
			assign crc_poly_size_reversed[l] = crc_poly_size[CRC_SIZE - 1 - l];
			assign sel_out[l] = crc_poly_size_reversed << l;
			assign crc_out[l] = |(sel_out[l] & crc_comb_out[FRAME_SIZE]);
		end
endgenerate

generate
	genvar m;
	for(m = CRC_SIZE - 1; m >= 0; m = m - 1)
		begin
			assign crc_init_sel[m] = crc_poly_size >> (CRC_SIZE - 1 - m);
			assign crc_init_justified[m] = |(crc_init & crc_init_sel[m]);
		end
endgenerate

assign crc_comb_out[0] = crc_init_justified;

generate
	genvar i;
	for(i = 0; i < FRAME_SIZE; i = i + 1)
		begin
			crc_comb 
			#(
				.CRC_SIZE      ( CRC_SIZE      ),
				.MASK          ( ENABLE        )
			) CRC_COMB
			(
				.crc_out       ( crc_comb_out[i + 1]           ),
				.data_in       ( data_in[FRAME_SIZE - 1 - i]   ),
				.crc_in        ( crc_comb_out[i]               ),
				.crc_poly      ( poly_mux                      ),
				.crc_poly_size ( crc_poly_size[CRC_SIZE - 2:0] )
			);
		end
endgenerate

endmodule
