`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:       Universidad Pontificia Bolivariana
// Engineer:      Fabio Andres Guzman Figueroa
// 
// Create Date:    12:03:56 05/15/2012 
// Design Name: 
// Module Name:    memram 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module memram(
    input clk,
    input [7:0] din,
    input [4:0] addr,
    output [7:0] dout,
    input we
    );

   (* RAM_STYLE="DISTRIBUTED" *)
   
	reg [7:0] ram [31:0];

   always @(posedge clk)
      if (we)
         ram[addr] <= din;

   assign dout = ram[addr];   
					

endmodule
