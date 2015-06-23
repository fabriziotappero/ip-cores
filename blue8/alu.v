/*
    This file is part of Blue8.

    Foobar is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Blue8.  If not, see <http://www.gnu.org/licenses/>.

    Blue8 by Al Williams alw@al-williams.com

*/

`default_nettype none
module alu(input wire [15:0] y,input wire [15:0] z,output reg [15:0] dout, 
  input wire asum,input wire aor,input wire aand,input wire axor,input wire abar,input wire a2,	input wire adiff,
  input wire ahalf,
  output wire overflow, output wire zero, output reg cy,input wire cin);
   assign 	 overflow=asum&&(y[15]==z[15]?1'b1:1'b0)&&dout[15]!=y[15];
   assign    zero=(dout==0?1'b1:1'b0);


	// carry is a problem since we use the ALU to handle increment PC
	// we really need an sendinc line that increments with no carry or something
	// although address arith ought not overflow ;-)
	// or we need to latch it at the right time like we do Z
	// Even then, putting carry as a reg here gives a combinatorial clock
	// I'd like to pull it out as a flag, but I can't seem to figure how to do that
	// with an assignment (particularly in sum) and changing the ALU clock to clk does NOT work!



   always @(*) begin
	   
     case ({ahalf,adiff, asum, aor, aand, axor, abar, a2})
      8'b00000001: begin	  //a2
                    {cy, dout}<={z[15:0], cin};  // could use cy to rotate
                end
      8'b00000010: begin			// abar
                   dout<=~z;
						 cy<=cin;
                end
      8'b00000100: begin					 // axor
						 dout<=y^z;
						 cy<=cin;
                end
      8'b00001000: begin				 // aand
                   dout<=y&z;
						 cy<=cin;
                end
      8'b00010000: begin					  // aor
                   dout<=y|z;
						 cy<=cin;
                end
      8'b00100000: begin					  // asum
                    {cy, dout}<=y+z;
                end
      8'b01000000: begin							// adiff
                    {cy, dout}<={1'b1, z}-y;
                end											  // ahalf
      8'b10000000: begin
					     { dout, cy}<={cin, z[15:0]};
					 end
      default : begin
						 cy<=cin;
                   dout<=16'bz;
                end
   endcase


   end
   
endmodule // alu

 