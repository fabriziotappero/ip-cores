`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:20:37 02/23/2012 
// Design Name: 
// Module Name:    clkdiv 
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

module clk_div(input clk, output clk1);
	parameter divide = 16;
	wire clk0;

   DCM_SP #(
      .CLKDV_DIVIDE(divide) // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                          //   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
   ) DCM_SP_inst (
      .CLKDV(clk1),   // Divided DCM CLK out (CLKDV_DIVIDE)
      .CLKIN(clk),   // Clock input (from IBUFG, BUFG or DCM)
		.CLK0(clk0),
		.CLKFB(clk0),
		.RST(0)
   );

endmodule


module my_clk_div(input clk, output reg clk1 = 0);
	parameter divide = 16;
	integer cnt = 0;
	always @(posedge clk) begin
		cnt <= (cnt?cnt:(divide/2)) - 1;
		if (!cnt) clk1 <= ~clk1;
	end
	
endmodule
