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

module aes_core
(
	//OUTPUTS
	output [31:0] col_out,
	output [31:0] key_out,
	output [31:0] iv_out,
	output end_aes,
	//INPUTS
	input  [31:0] bus_in,
	input  [ 3:0] iv_en,
	input  [ 3:0] iv_sel_rd,
	input  [ 3:0] key_en,
	input  [ 1:0] key_sel_rd,
	input  [ 1:0] data_type,
	input  [ 1:0] addr,
	input  [ 1:0] op_mode,
	input  [ 1:0] aes_mode,
	input start,
	input disable_core,
	input write_en,
	input read_en,
	input first_block,
	input rst_n,
	input clk
);

wire [ 1:0] rk_sel;
wire [ 1:0] key_out_sel;
wire [ 3:0] round;
wire [ 2:0] sbox_sel;
wire [ 3:0] col_en_host;
wire [ 3:0] iv_en_host;
wire [ 3:0] col_en_cnt_unit;
wire [ 3:0] key_en_host;
wire [ 3:0] key_en_cnt_unit;
wire [ 1:0] col_sel;
wire        key_sel;
wire bypass_rk;
wire bypass_key_en;
wire last_round;
wire iv_cnt_en;
wire iv_cnt_sel;
wire mode_ctr;
wire mode_cbc;
wire key_init;
wire key_gen;
wire [1:0] col_addr_host;

assign col_en_host = (4'b0001 << addr) & {4{write_en}};
assign col_addr_host = addr & {2{read_en}};
assign iv_en_host  = iv_en;
assign key_en_host = key_en;

datapath AES_CORE_DATAPATH
(
	.col_bus           ( col_out           ),
	.key_bus           ( key_out           ),
	.iv_bus            ( iv_out            ),   
	.bus_in 	   ( bus_in            ),
	.end_aes           ( end_aes           ),
	.data_type         ( data_type 	       ),
	.rk_sel 	   ( rk_sel            ),
	.key_out_sel       ( key_out_sel       ),
	.round		   ( round             ),
	.sbox_sel	   ( sbox_sel          ),
	.iv_en		   ( iv_en_host        ),
	.iv_sel_rd         ( iv_sel_rd         ),
	.col_en_host       ( col_en_host       ),
	.col_en_cnt_unit   ( col_en_cnt_unit   ),
	.key_host_en	   ( key_en_host       ),
	.key_en		   ( key_en_cnt_unit   ),
	.key_sel_rd        ( key_sel_rd        ),
	.col_sel_host	   ( col_addr_host     ),
	.col_sel           ( col_sel           ),
	.key_sel	   ( key_sel           ),
	.bypass_rk	   ( bypass_rk         ),
	.bypass_key_en     ( bypass_key_en     ),
	.first_block       ( first_block       ),
	.last_round        ( last_round        ),
	.iv_cnt_en         ( iv_cnt_en         ),
	.iv_cnt_sel	   ( iv_cnt_sel        ),
	.enc_dec	   ( enc_dec           ),
	.mode_ctr	   ( mode_ctr          ),
	.mode_cbc	   ( mode_cbc          ),
	.key_init          ( key_init          ),
	.key_gen           ( key_gen           ),
	.key_derivation_en ( key_derivation_en ),
	.end_comp          ( end_comp          ),
	.rst_n		   ( rst_n             ),
	.clk		   ( clk	       )
);

control_unit AES_CORE_CONTROL_UNIT
(  
	.end_comp          ( end_comp          ),
	.sbox_sel          ( sbox_sel          ),
	.rk_sel            ( rk_sel            ),
	.key_out_sel       ( key_out_sel       ),
	.col_sel           ( col_sel           ),
	.key_en            ( key_en_cnt_unit   ),
	.col_en            ( col_en_cnt_unit   ),
	.round      	   ( round             ),
	.bypass_rk         ( bypass_rk         ),
	.bypass_key_en     ( bypass_key_en     ),
	.key_sel           ( key_sel           ),
	.last_round        ( last_round        ),
	.iv_cnt_en         ( iv_cnt_en         ),
	.iv_cnt_sel        ( iv_cnt_sel        ),
	.mode_ctr          ( mode_ctr          ),
	.mode_cbc          ( mode_cbc          ),
	.key_init          ( key_init          ),
	.encrypt_decrypt   ( enc_dec	       ),
	.key_gen           ( key_gen           ),
	.operation_mode    ( op_mode 	       ),
	.aes_mode	   ( aes_mode          ),
	.start		   ( start 	       ),
	.key_derivation_en ( key_derivation_en ),
	.disable_core      ( disable_core      ),
	.clk		   ( clk               ),
	.rst_n		   ( rst_n             )
);

endmodule
