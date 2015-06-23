/*
Double Data to Single Data Rate Input Register
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
module my_iddrx8(
input wire 			clk,
input wire 	[7:0]	io,
output reg [7:0] d0,
output reg [7:0] d1
);

reg[7:0] dp0;
reg[7:0] dn0;
always@(posedge clk)
begin
	dp0<=io;
end

always@(negedge clk)
begin
	dn0=io;
end

always@(posedge clk)
begin
	d0<=dp0;
	d1<=dn0;
end

endmodule
