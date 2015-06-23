/* This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
   
   Email : semiconductors@varkongroup.com
   Tel   : 1-732-447-8611
   
*/
module DP_RAM (clk,we,re,address_read,address_write,data_in,data_out);

parameter address_width=8;
parameter data_width=8;
parameter num_words=205;

input clk,we,re;
input [address_width-1:0] address_read,address_write;
input [data_width-1:0] data_in;
output [data_width-1:0] data_out;

reg [data_width-1:0] data_out;
reg [data_width-1:0] mem [0:num_words-1];

integer		i;
	initial
	begin
		for (i=0;i<num_words;i=i+1)
			mem[i] = 0;
	end 

always @ (posedge(clk))
begin
	if (we==1'b1)
		begin
			mem[address_write]<= data_in;
		end
	if (re==1'b1)
		begin
			data_out<=mem[address_read];
		end
end

endmodule
