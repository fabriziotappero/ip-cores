//////////////////////////////////////////////////////////////////
//                                                              //
//  Wrapper for SRAM buffer module                              //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////

`include "timescale.v"

module eth_spram_256x32(
	//
	// Generic synchronous single-port RAM interface
	//
	input           clk,  // Clock, rising edge
	input           rst,  // Reset, active high
	input           ce,   // Chip enable input, active high
	input  [3:0]    we,   // Write enable input, active high
	input           oe,   // Output enable input, active high
	input  [7:0]    addr, // address bus inputs
	input  [31:0]   di,   // input data bus
	output [31:0]   do    // output data bus

);

wire write_enable;
assign write_enable = ce & (|we);

`ifdef XILINX_SPARTAN6_FPGA
    xs6_sram_256x32_byte_en 
`endif

`ifdef XILINX_VIRTEX6_FPGA
    xv6_sram_256x32_byte_en 
`endif

`ifndef XILINX_FPGA
    generic_sram_byte_en
`endif

    #(
    .DATA_WIDTH     ( 32            ) ,
    .ADDRESS_WIDTH  ( 8             )
) u_ram (
    .i_clk          ( clk           ),
    .i_write_data   ( di            ),
    .i_write_enable ( write_enable  ),
    .i_address      ( addr          ),
    .i_byte_enable  ( we            ),
    .o_read_data    ( do            )
);


endmodule
