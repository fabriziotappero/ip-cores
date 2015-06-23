`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:22:46 05/02/2012 
// Design Name: 
// Module Name:    shifter 
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
module shiftbyte(
    input [7:0] din,
    output reg [7:0] dshift,
    input [2:0] sh
    );

	always@*
		case (sh)
			0: dshift <= {din[6:0], 0};
			1: dshift <= {din[6:0], din[7]};
			2: dshift <= {0, din[7:1]};
			3: dshift <= {din[0], din[7:1]};
			4: dshift <= din;
			5: dshift <= {din[6:0], 1};
			6: dshift <= {1, din[7:1]};
			default: dshift <= din;
		endcase

endmodule
