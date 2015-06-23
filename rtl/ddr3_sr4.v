/*
Multibits Shift Register
2010-2011 sclai <laikos@yahoo.com>

This library is free software; you can redistribute it and/or modify it 
 under the terms of the GNU Lesser General Public License as published by 
 the Free Software Foundation; either version 2.1 of the License, 
 or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful, but 
 WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 USA
*/
module ddr3_sr4 #(
parameter PIPE_LEN=7
)(
input wire        clk,
input wire [3:0] shift_in,
output wire[3:0] shift_out
);
//register to hold value
reg [PIPE_LEN-1:0] d0;
reg [PIPE_LEN-1:0] d1;
reg [PIPE_LEN-1:0] d2;
reg [PIPE_LEN-1:0] d3;

always @(posedge clk)
begin
  d3  <={shift_in[ 3],d3[PIPE_LEN-1:1]};
  d2  <={shift_in[ 2],d2[PIPE_LEN-1:1]};
  d1  <={shift_in[ 1],d1[PIPE_LEN-1:1]};
  d0  <={shift_in[ 0],d0[PIPE_LEN-1:1]};
end    
  
assign shift_out={d3[0],d2[0],d1[0],d0[0]};
endmodule



