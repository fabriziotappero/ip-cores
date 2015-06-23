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

`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    22:15:16 01/11/06
// Design Name:    
// Module Name:    gpreg
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
module gpreg(input clk, input wire [15:0] din, output wire [15:0] dout, input wire [3:0] wselect,
   input wire [3:0] sendselect, input wire write, input wire send,
	output wire awrite, output wire asend, output wire pwrite, output wire psend);

   reg [15:0] values[11];

   
	assign awrite=write & (wselect==4'h4);
	assign asend=send & (sendselect==4'h4);
	assign pwrite=write & (wselect==4'h3);
	assign psend= send & (sendselect==4'h3);

   // put a case here for write
	always @(posedge clk) begin
	  if (write) begin
	    case (wselect) begin
		 4'b0101: values[0]<=din;
		 4'b0110: values[1]<=din;
		 4'b0111: values[2]<=din;
		 4'b1000: values[3]<=din;
		 4'b1001: values[4]<=din;
		 4'b1010: values[5]<=din;
		 4'b1011: values[6]<=din;
		 4'b1100: values[7]<=din;
		 4'b1101: values[8]<=din;
		 4'b1110: values[9]<=din;
		 4'b1111: values[10]<=din;
		 default: ;
		 end
	  end
	end
	// put a case here for send
	always @(posedge clk) begin
	  if (send) begin
	    case (sendselect) begin
		 4'b0101: dout<=values[0];
		 4'b0110: dout<=values[1];
		 4'b0111: dout<=values[2];
		 4'b1000: dout<=values[3];
		 4'b1001: dout<=values[4];
		 4'b1010: dout<=values[5];
		 4'b1011: dout<=values[6];
		 4'b1100: dout<=values[7];
		 4'b1101: dout<=values[8];
		 4'b1110: dout<=values[9];
		 4'b1111: dout<=values[10];
		 default: dout<=16'bz;
		 end
	  end
	end



endmodule
