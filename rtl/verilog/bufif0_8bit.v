`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chinthaka A.K.
// 
// Create Date:    10:52:01 12/08/2009 
// Design Name: 
// Module Name:    bufif0_8bit 
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
module bufif0_8bit(buf_out, buf_in,ENB);
	output [7:0]buf_out;
	input [7:0]buf_in;
	input ENB;
	
   bufif0(buf_out[0],buf_in[0],ENB);
   bufif0(buf_out[1],buf_in[1],ENB);
   bufif0(buf_out[2],buf_in[2],ENB);
   bufif0(buf_out[3],buf_in[3],ENB);
   bufif0(buf_out[4],buf_in[4],ENB);
   bufif0(buf_out[5],buf_in[5],ENB);
   bufif0(buf_out[6],buf_in[6],ENB);
   bufif0(buf_out[7],buf_in[7],ENB);

endmodule
