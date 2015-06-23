`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:20:38 04/05/2009 
// Design Name: 
// Module Name:    move_cell 
// Project Name:   The FPGA Othello Game
// Target Devices: 
// Tool versions: 
// Description: 
//     Represents a square from othello board
//     Inputs: r bit, b bit, pulse (1-when we want to put a disc on then square, 0-otherwise
//     Outputs: r bit, b bit (flipped if there is the case).  (forward and backwards signals
//              to carry away the info (like a ripple carry adder).
//
// Dependencies: -
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//  Marius TIVADAR Mar-Apr, 2009
//////////////////////////////////////////////////////////////////////////////////
module move_cell(
    input r,
    input b,
    input fw_in,
    input bw_in,
    output fw_out,
    output bw_out,
    input pulse,
    output r_out,
    output b_out
    );
	 
reg r_out_reg;
reg b_out_reg;
	 

always @( * ) begin
	
	/* if backward signal and forward signal, flip the discs. 
      Otherwise, r,b bits remain the same	*/
	if ( bw_in && fw_in ) begin
		b_out_reg = 1;
		r_out_reg = 0;
	end
	else begin
		b_out_reg = b;
		r_out_reg = r;
	end
end

/* equations for forward and backward signal propagation */
/* forward signal is 1 if we have an outside pulse, or we received fw signal from neighbour cell */
assign 	fw_out = pulse || (r && fw_in);
/* backward signal is 1 if we received backward signal from neighbour cell, or if we flanc the disc (b bit is 1)
   and we propagate the bw signal */
assign	bw_out = bw_in || (b && fw_in);

assign 	r_out = r_out_reg;
assign	b_out = b_out_reg;

endmodule
