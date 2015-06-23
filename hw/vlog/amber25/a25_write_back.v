//////////////////////////////////////////////////////////////////
//                                                              //
//  Write Back - Instantiates the write back stage              //
//  sub-modules of the Amber 25 Core                            //
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
// Copyright (C) 2011 Authors and OPENCORES.ORG                 //
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


module a25_write_back
(
input                       i_clk,
input                       i_mem_stall,                // Mem stage asserting stall

input       [31:0]          i_mem_read_data,            // data reads
input                       i_mem_read_data_valid,      // read data is valid
input       [10:0]          i_mem_load_rd,              // Rd for data reads

output      [31:0]          o_wb_read_data,             // data reads
output                      o_wb_read_data_valid,       // read data is valid
output      [10:0]          o_wb_load_rd,               // Rd for data reads

input       [31:0]          i_daddress,
input                       i_daddress_valid
);

reg  [31:0]         mem_read_data_r = 'd0;          // Register read data from Data Cache
reg                 mem_read_data_valid_r = 'd0;    // Register read data from Data Cache
reg  [10:0]         mem_load_rd_r = 'd0;            // Register the Rd value for loads

assign o_wb_read_data       = mem_read_data_r;
assign o_wb_read_data_valid = mem_read_data_valid_r;
assign o_wb_load_rd         = mem_load_rd_r;


always @( posedge i_clk )
    if ( !i_mem_stall )
        begin                                                                                                             
        mem_read_data_r         <= i_mem_read_data;
        mem_read_data_valid_r   <= i_mem_read_data_valid;
        mem_load_rd_r           <= i_mem_load_rd;
        end


// Used by a25_decompile.v, so simulation only
//synopsys translate_off    
reg  [31:0]         daddress_r = 'd0;               // Register read data from Data Cache
always @( posedge i_clk )
    if ( !i_mem_stall )
        daddress_r              <= i_daddress;
//synopsys translate_on    

endmodule

