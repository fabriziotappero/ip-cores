`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:39:35 05/16/2012 
// Design Name: 
// Module Name:    LIFO 
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
module LIFO(
    input clk,
	 input rst,
    input wr_en,
    input rd_en,
    input [10:0] din,
    output [10:0] dout
    );


   (* RAM_STYLE="DISTRIBUTED" *)
   reg [3:0] addr;
	reg [10:0] ram [15:0];

   always@(posedge clk)
		if (rst)
			addr<=0;
		else 
			 begin 
			  if (wr_en==0 && rd_en==1)  //leer
					if (addr>0)
						addr<=addr-1;
			  if (wr_en==1 && rd_en==0)  //guardar
					if (addr<15)
						addr<=addr+1;
			 end
		
	always @(posedge clk)
      if (wr_en)
         ram[addr] <= din;

   assign dout = ram[addr];   

endmodule
