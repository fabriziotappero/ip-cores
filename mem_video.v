`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:       Universidad Pontificia Bolivariana
// Engineer:      Fabio Andres Guzman Figueroa
// 
// Create Date:    11:47:57 05/17/2012 
// Design Name: 
// Module Name:    mem_video 
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
module mem_video(
    input clk,
	 input we,
    input [12:0] addr_write,
    input [12:0] addr_read,
    input [3:0] din,
    output reg [3:0] dout
    );

	(* RAM_STYLE="BLOCK" *)
	 reg [3:0] ram_video [8191:0];
	
	  
   always @(posedge clk) 
		begin
			if (we)
				ram_video[addr_write] <= din;
			dout <= ram_video[addr_read];
		end
		
endmodule
