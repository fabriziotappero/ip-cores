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

module constant #(parameter VALUE=0)(input wire send, output wire [15:0] dout);
  assign dout=send?VALUE:16'bz;
endmodule

module ffff(input wire send,output wire [15:0] dout);
   constant #(.VALUE(16'hffff)) xffff(send,dout);
endmodule // ffff
   

module zero(input wire send,output wire [15:0] dout);
   constant #(.VALUE(16'h0000)) xzero(send,dout);
endmodule // zero
 
   
module one(input wire send,output wire [15:0] dout);
    constant #(.VALUE(16'h0001)) xone(send,dout);
endmodule // one



module register #(parameter SIZE=16) (input wire clk,input wire [15:0] din,input wire write,
   output wire [15:0] dout,input wire send,output wire [SIZE-1:0] tap, input wire reset);
   reg [SIZE-1:0] 	 regvalue=0;
   assign 	 dout=send?regvalue:16'bz;
	assign tap=regvalue;   
   
   always @(posedge clk, posedge reset) begin
	 if (reset) regvalue<=0;
	 else if (write) regvalue<=din;
	 end
endmodule // register


module aregister(input wire clk,input wire [15:0] din, input wire write, 
  output [15:0] dout, input wire send, output [11:0] tap, input reset);
register #(.SIZE(12)) areg(clk,din,write,dout,send,tap,reset);
endmodule // aregister

