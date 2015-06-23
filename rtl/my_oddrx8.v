/*
Single Data Rate to Double Data Rate Output Register
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
module my_oddrx8(
input wire 			clk,
input wire [7:0] 	d0,
input wire [7:0] 	d1,
output reg [7:0]  io
);



always@(*)
begin
	case(clk)
	1'b0:io<=d1;
	1'b1:io<=d0;
	endcase
end

endmodule
