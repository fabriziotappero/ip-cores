/*single clock dual port ram
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


Example:
Desity     Bank     Row    Col
-----------------------------
   64MB    2:0      12:0   9:0
  128MB    2:0      13:0   9:0
  512MB    2:0      13:0  10:0
    1GB    2:0      15:0  10:0
*/
     
module dport_ram
#(
	parameter DATA_WIDTH=8, 
	parameter ADDR_WIDTH=36
)(
	input 						 clk,
	input [(DATA_WIDTH-1):0] di,
	input [(ADDR_WIDTH-1):0] read_addr, 
	input [(ADDR_WIDTH-1):0] write_addr,
	input 						 we, 
	output reg [(DATA_WIDTH-1):0] do
);
localparam ACTUAL_ADDR_WIDTH=16; //due to small size of internal memory
//localparam ACTUAL_ADDR_WIDTH=26; //due to small size of internal memory
wire [ACTUAL_ADDR_WIDTH-1:0]ACTUAL_WRITE_ADDR;
wire [ACTUAL_ADDR_WIDTH-1:0]ACTUAL_READ_ADDR;
												//bank            row               col
//assign ACTUAL_WRITE_ADDR={write_addr[34:32],write_addr[25:16],write_addr[7:0]};
//assign ACTUAL_READ_ADDR ={ read_addr[34:32], read_addr[25:16], read_addr[7:0]};
assign ACTUAL_WRITE_ADDR={write_addr[34:32],write_addr[28:16],write_addr[9:0]};
assign ACTUAL_READ_ADDR ={ read_addr[34:32], read_addr[28:16], read_addr[9:0]};
//8196Kbytes RAM
reg [DATA_WIDTH-1:0] ram[2**ACTUAL_ADDR_WIDTH-1:0];

	always @ (posedge clk)
	begin	
		if (we==1'b1)
			begin
				ram[ACTUAL_WRITE_ADDR] <= di;
			end
		else
			begin
				do <= ram[ACTUAL_READ_ADDR];
			end
	end
endmodule
