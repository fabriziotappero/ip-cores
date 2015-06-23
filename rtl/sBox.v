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
module sBox
#(
  parameter SBOX_NUM = 4
)(
  //OUTPUTS
  output [8*SBOX_NUM - 1:0] sbox_out_enc,
  output [8*SBOX_NUM - 1:0] sbox_out_dec,
	//INPUTS
  input  [8*SBOX_NUM - 1:0] sbox_in,
	input enc_dec,
	input clk
);
  sBox_8 SBOX[SBOX_NUM - 1:0]
  (
    .sbox_out_enc ( sbox_out_enc ),
		.sbox_out_dec ( sbox_out_dec ),
    .sbox_in      ( sbox_in      ),
		.enc_dec      ( enc_dec      ),
		.clk          ( clk          )
  );
  
endmodule
