//////////////////////////////////////////////////////////////////
//                                                              //
//  Asynchronous FIFO set for Wishbone to Xilinx Virtex-6       //
//  DDR3 Bridge                                                 //
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


module ddr3_afifo
#( 
parameter ADDR_WIDTH = 30,
parameter DATA_WIDTH = 32
)
(
input                          i_sys_clk,
input                          i_ddr_clk,

// Write-Side Ports
input                          i_cmd_en,               // Command Enable
input     [2:0]                i_cmd_instr,            // write = 000, read = 001
input     [ADDR_WIDTH-1:0]     i_cmd_byte_addr,        // Memory address
output                         o_cmd_full,             // DDR3 I/F Command FIFO is full

output                         o_wr_full,              // DDR3 I/F Write Data FIFO is full
input                          i_wr_en,                // Write data enable
input     [DATA_WIDTH/8-1:0]   i_wr_mask,              // 1 bit per byte
input     [DATA_WIDTH-1:0]     i_wr_data,              // 16 bytes write data
input     [1:0]                i_wr_addr_32,           // address bits [3:2]
output    [DATA_WIDTH-1:0]     o_rd_data,              // 16 bytes of read data
output                         o_rd_valid,             // low when read data is valid

// Read-Side Ports
output                         o_ddr_cmd_en,           // Command Enable
output     [2:0]               o_ddr_cmd_instr,        // write = 000, read = 001
output     [ADDR_WIDTH-1:0]    o_ddr_cmd_byte_addr,    // Memory address
input                          i_ddr_cmd_full,         // DDR3 I/F Command FIFO is full

input                          i_ddr_wr_full,          // DDR3 I/F Write Data FIFO is full
output                         o_ddr_wr_en,            // Write data enable
output     [DATA_WIDTH/8-1:0]  o_ddr_wr_mask,          // 1 bit per byte
output     [DATA_WIDTH-1:0]    o_ddr_wr_data,          // 16 bytes write data
output     [1:0]               o_ddr_wr_addr_32,       // address bits [3:2]
input      [DATA_WIDTH-1:0]    i_ddr_rd_data,          // 16 bytes of read data
input                          i_ddr_rd_valid          // low when read data is valid

);
                 
wire cmd_empty, wr_empty, rd_empty;

assign o_ddr_cmd_en = !cmd_empty;
assign o_ddr_wr_en  = !wr_empty;
assign o_rd_valid   = !rd_empty;


afifo #(.D_WIDTH(ADDR_WIDTH+3)) u_afifo_cmd (
    .wr_clk     ( i_sys_clk                                 ),
    .rd_clk     ( i_ddr_clk                                 ),

    .i_data     ( {i_cmd_instr, i_cmd_byte_addr}            ),
    .o_data     ( {o_ddr_cmd_instr, o_ddr_cmd_byte_addr}    ),
    .i_push     ( i_cmd_en                                  ),
    .i_pop      ( o_ddr_cmd_en && !i_ddr_cmd_full           ),

    .o_full     ( o_cmd_full                                ),
    .o_empty    ( cmd_empty                                 )
);


afifo #(.D_WIDTH(DATA_WIDTH+DATA_WIDTH/8+2)) u_afifo_wr (
    .wr_clk     ( i_sys_clk                                 ),
    .rd_clk     ( i_ddr_clk                                 ),

    .i_data     ( {i_wr_addr_32, i_wr_mask, i_wr_data }     ),
    .o_data     ( {o_ddr_wr_addr_32, o_ddr_wr_mask, o_ddr_wr_data} ),
    .i_push     ( i_wr_en                                   ),
    .i_pop      ( o_ddr_wr_en && !i_ddr_wr_full             ),

    .o_full     ( o_wr_full                                 ),
    .o_empty    ( wr_empty                                  )
);


afifo #(.D_WIDTH(DATA_WIDTH)) u_afifo_rd (
    .wr_clk     ( i_ddr_clk                                 ),
    .rd_clk     ( i_sys_clk                                 ),

    .i_data     ( i_ddr_rd_data                             ),
    .o_data     ( o_rd_data                                 ),
    .i_push     ( i_ddr_rd_valid                            ),
    .i_pop      ( o_rd_valid                                ),

    .o_full     (                                           ),
    .o_empty    ( rd_empty                                  )
);
   
endmodule

