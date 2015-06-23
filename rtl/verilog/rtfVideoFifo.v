`timescale 1ns / 1ps
// ============================================================================
//	(C) 2008-2013  Robert Finch
//	robfinch<remove>@opencores.org
//
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//                                                                          
//
//	Verilog 1995
//
// ============================================================================
//
module rtfVideoFifo(rst, wclk, wr, di, rclk, rd, do, cnt);
input rst;
input wclk;
input wr;
input [31:0] di;
input rclk;
input rd;
output [31:0] do;
output [8:0] cnt;
reg [8:0] cnt;

reg [8:0] wr_ptr;
reg [8:0] rd_ptr,rrd_ptr;
reg [31:0] mem [0:511];

always @(posedge wclk)
	if (rst)
		wr_ptr <= 9'd0;
	else if (wr) begin
		mem[wr_ptr] <= di;
		wr_ptr <= wr_ptr + 9'd1;
	end

always @(posedge rclk)
	if (rst)
		rd_ptr <= 9'd0;
	else if (rd)
		rd_ptr <= rd_ptr + 9'd1;
always @(posedge rclk)
	rrd_ptr <= rd_ptr;

assign do = mem[rrd_ptr];

always @(wr_ptr or rd_ptr)
	if (rd_ptr > wr_ptr)
		cnt <= wr_ptr + (10'd512 - rd_ptr);
	else
		cnt <= wr_ptr - rd_ptr;

endmodule
