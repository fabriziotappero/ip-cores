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
module crc_unit
(
 //OUTPUTS
 output [31:0] crc_poly_out,
 output [31:0] crc_out,
 output [31:0] crc_init_out,
 output [7:0] crc_idr_out,
 output buffer_full,
 output read_wait,
 output reset_pending,
 //INPUTS
 input [31:0] bus_wr,
 input [ 1:0] crc_poly_size,
 input [ 1:0] bus_size,
 input [ 1:0] rev_in_type,
 input rev_out_type,
 input crc_init_en,
 input crc_idr_en,
 input crc_poly_en,
 input buffer_write_en,
 input reset_chain,
 input clk,
 input rst_n
);

//Interconection signals
wire [ 1:0] size_in;
wire [ 1:0] byte_sel;
wire clear_crc_init;
wire set_crc_init;
wire bypass_byte0;
wire bypass_size;
wire crc_out_en;
wire byte_en;
wire buffer_en;

//The write in the buffer only occur if there is free space
assign buffer_en = buffer_write_en && !buffer_full;

//Instance of the Datapath
crc_datapath DATAPATH
(
 .crc_out            ( crc_out        ),
 .size_out           ( size_in        ),
 .crc_idr_out        ( crc_idr_out    ),
 .crc_poly_out       ( crc_poly_out   ),
 .crc_init_out       ( crc_init_out   ),
 .bus_wr             ( bus_wr         ), 
 .rev_in_type        ( rev_in_type    ),
 .rev_out_type       ( rev_out_type   ),
 .buffer_en          ( buffer_en      ),
 .byte_en            ( byte_en        ),
 .crc_init_en        ( crc_init_en    ),
 .crc_out_en         ( crc_out_en     ),
 .crc_idr_en         ( crc_idr_en     ),
 .crc_poly_en        ( crc_poly_en    ),
 .buffer_rst         ( clear_crc_init ),
 .bypass_byte0       ( bypass_byte0   ),
 .bypass_size        ( bypass_size    ),
 .byte_sel           ( byte_sel       ),
 .size_in            ( bus_size       ),
 .clear_crc_init_sel ( clear_crc_init ),
 .set_crc_init_sel   ( set_crc_init   ),
 .crc_poly_size      ( crc_poly_size  ),
 .clk                ( clk            ),
 .rst_n              ( rst_n          )
);

//Instance of the Control unit
crc_control_unit CONTROL_UNIT
(
 .byte_en            ( byte_en          ),
 .crc_out_en         ( crc_out_en       ),
 .byte_sel           ( byte_sel         ),
 .bypass_byte0       ( bypass_byte0     ),
 .buffer_full        ( buffer_full      ),
 .read_wait          ( read_wait        ),
 .bypass_size        ( bypass_size      ),
 .set_crc_init_sel   ( set_crc_init     ),
 .clear_crc_init_sel ( clear_crc_init   ),
 .size_in            ( size_in          ),
 .write              ( buffer_write_en  ),
 .reset_chain        ( reset_chain      ),
 .reset_pending      ( reset_pending    ),
 .clk                ( clk              ),
 .rst_n              ( rst_n            )
);
endmodule
