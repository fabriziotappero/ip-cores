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
module crc_ip
(
	//OUTPUTS
	output [31:0] HRDATA,
	output HREADYOUT,
	output HRESP,
	//INPUTS
	input [31:0] HWDATA,
	input [31:0] HADDR,
	input [ 2:0] HSIZE,
	input [ 1:0] HTRANS,
	input HWRITE,
	input HSElx,
	input HREADY,
	input HRESETn,
	input HCLK
);

//Internal Signals
wire [31:0] crc_poly_out;
wire [31:0] crc_out;
wire [31:0] crc_init_out;
wire [ 7:0] crc_idr_out;
wire buffer_full;
wire read_wait;
wire [31:0] bus_wr;
wire [ 1:0] crc_poly_size;
wire [ 1:0] bus_size;
wire [ 1:0] rev_in_type;
wire rev_out_type;
wire crc_init_en;
wire crc_idr_en;
wire crc_poly_en;
wire buffer_write_en;
wire reset_chain;

//Instanciation of Host Interface
host_interface HOST_INTERFACE
(
	.HRDATA          ( HRDATA          ),
	.HREADYOUT       ( HREADYOUT       ),
	.HRESP           ( HRESP           ),
	.bus_wr          ( bus_wr          ),
	.crc_poly_size   ( crc_poly_size   ),
	.bus_size        ( bus_size        ),
	.rev_in_type     ( rev_in_type     ),
	.rev_out_type    ( rev_out_type    ),
	.crc_init_en     ( crc_init_en     ),
	.crc_idr_en      ( crc_idr_en      ),
	.crc_poly_en     ( crc_poly_en     ),
	.buffer_write_en ( buffer_write_en ),
	.reset_chain     ( reset_chain     ),
	.reset_pending   ( reset_pending   ),
	.HWDATA          ( HWDATA          ),
	.HADDR           ( HADDR           ),
	.HSIZE           ( HSIZE           ),
	.HTRANS          ( HTRANS          ),
	.HWRITE          ( HWRITE          ),
	.HSElx           ( HSElx           ),
	.HREADY          ( HREADY          ),
	.HRESETn         ( HRESETn         ),
	.HCLK            ( HCLK            ),
	.crc_poly_out    ( crc_poly_out    ),
	.crc_out         ( crc_out         ),
	.crc_init_out    ( crc_init_out    ),
	.crc_idr_out     ( crc_idr_out     ),
	.buffer_full     ( buffer_full     ),
	.read_wait       ( read_wait       )
);

//Instantiation of crc_unit
crc_unit CRC_UNIT
(
	.crc_poly_out    ( crc_poly_out    ),
	.crc_out         ( crc_out         ),
	.crc_init_out    ( crc_init_out    ),
	.crc_idr_out     ( crc_idr_out     ),
	.buffer_full     ( buffer_full     ),
	.read_wait       ( read_wait       ),
	.bus_wr          ( bus_wr          ),
	.crc_poly_size   ( crc_poly_size   ),
	.bus_size        ( bus_size        ),
	.rev_in_type     ( rev_in_type     ),
	.rev_out_type    ( rev_out_type    ),
	.crc_init_en     ( crc_init_en     ),
	.crc_idr_en      ( crc_idr_en      ),
	.crc_poly_en     ( crc_poly_en     ),
	.buffer_write_en ( buffer_write_en ),
	.reset_chain     ( reset_chain     ),
	.reset_pending   ( reset_pending   ),
	.clk             ( HCLK            ),
	.rst_n           ( HRESETn         )
);
endmodule
