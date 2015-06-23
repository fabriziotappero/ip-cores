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
module aes_ip
(
	//OUTPUTS
	output int_ccf,
	output int_err,
	output dma_req_wr,
	output dma_req_rd,
	output PREADY,
	output PSLVERR,
	output [31:0] PRDATA,
	//INPUTS
	input  [ 3:0] PADDR,
	input  [31:0] PWDATA,
	input PWRITE,
	input PENABLE,
	input PSEL,
	input PCLK,
	input PRESETn
);

wire [31:0] col_out;
wire [31:0] key_out;
wire [31:0] iv_out;
wire end_aes;
wire [ 3:0] iv_en;
wire [ 3:0] iv_sel_rd;
wire [ 3:0] key_en;
wire [ 1:0] key_sel_rd;
wire [ 1:0] data_type;
wire [ 1:0] addr;
wire [ 1:0] op_mode;
wire [ 1:0] aes_mode;
wire start;
wire disable_core;
wire write_en;
wire read_en;
wire first_block;
//wire pwdata_host_interface;

assign PREADY = 1'b1;
assign PSLVERR = 1'b0;
//assign pwdata_host_interface = PWDATA[12:0];

host_interface HOST_INTERFACE
(
	.key_en       ( key_en       ),
	.col_addr     ( addr         ),
	.col_wr_en    ( write_en     ),
	.col_rd_en    ( read_en      ),
	.key_sel      ( key_sel_rd   ),
	.iv_en        ( iv_en        ),
	.iv_sel       ( iv_sel_rd    ),
	.int_ccf      ( int_ccf      ),
	.int_err      ( int_err      ),
	.chmod        ( aes_mode     ),
	.mode         ( op_mode      ),
	.data_type    ( data_type    ),
	.disable_core ( disable_core ),
	.first_block  ( first_block  ),
	.dma_req_wr   ( dma_req_wr   ),
	.dma_req_rd   ( dma_req_rd   ),
	.start_core   ( start        ),
	.PRDATA       ( PRDATA       ),
	.PADDR        ( PADDR        ),
	.PWDATA       ( PWDATA[12:0] ),
	.PWRITE       ( PWRITE       ),
	.PENABLE      ( PENABLE      ),
	.PSEL         ( PSEL         ),
	.PCLK         ( PCLK         ),
	.PRESETn      ( PRESETn      ),
	.key_bus      ( key_out      ),
	.col_bus      ( col_out      ),
	.iv_bus       ( iv_out       ),
	.ccf_set      ( end_aes      )
); 

aes_core AES_CORE
(
	.col_out      ( col_out      ),
	.key_out      ( key_out      ),
	.iv_out       ( iv_out       ),
	.end_aes      ( end_aes      ),
	.bus_in       ( PWDATA       ),
	.iv_en        ( iv_en        ),
	.iv_sel_rd    ( iv_sel_rd    ),
	.key_en       ( key_en       ),
	.key_sel_rd   ( key_sel_rd   ),
	.data_type    ( data_type    ),
	.addr         ( addr         ),
	.op_mode      ( op_mode      ),
	.aes_mode     ( aes_mode     ),
	.start        ( start        ),
	.disable_core ( disable_core ),
	.write_en     ( write_en     ),
	.read_en      ( read_en      ),
	.first_block  ( first_block  ),
	.rst_n        ( PRESETn      ),
	.clk          ( PCLK         )
);
endmodule
