/* --------------------------------------------------------------------------------
 This file is part of FPGA Median Filter.

    FPGA Median Filter is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FPGA Median Filter is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FPGA Median Filter.  If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------- */
//*******************************************************************//
//-------------------------------------------------------------------//
// File name            : dual_port_ram.v
// File contents        : Parameterized memory for syncronous fifo     
//
// Design Engineer      : Igor Dantas
// Last Changed         : 10/27/2008 09:00
//-------------------------------------------------------------------//
//*******************************************************************//

`timescale 1ns/10ps

module dual_port_ram 
#(
   parameter MEMFILE = "",
   parameter DATA_WIDTH = 'd32,
   parameter ADDR_WIDTH = 14
)
(
   input clk, 
   input r_ena,
   input w_ena, 
   input [DATA_WIDTH-1:0] w_data, 
   input [ADDR_WIDTH-1:0] w_addr, 
   input [ADDR_WIDTH-1:0] r_addr,
   output reg [DATA_WIDTH-1:0] r_data 
);

//The Register memory
reg [DATA_WIDTH-1:0] mem[0:2**ADDR_WIDTH-1];
// synchronous read and write when enabled
always @ (posedge clk) begin
   if (w_ena)  mem[w_addr] <=  w_data;
   if (r_ena) r_data <= mem[r_addr];
end

initial $readmemh(MEMFILE, mem);


endmodule

