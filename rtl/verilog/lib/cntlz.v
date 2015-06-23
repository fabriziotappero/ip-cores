/* ===============================================================
	(C) 2006  Robert Finch
	All rights reserved.
	rob@birdcomputer.ca

	cntlz.v
		- count number of leading zeros in a byte
		- count number of leading ones in a byte
		- simple fast approach - lookup table

	This source code is free for use and modification for
	non-commercial or evaluation purposes, provided this
	copyright statement and disclaimer remains present in
	the file.

	If the code is modified, please state the origin and
	note that the code has been modified.

	NO WARRANTY.
	THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF
	ANY KIND, WHETHER EXPRESS OR IMPLIED. The user must assume
	the entire risk of using the Work.

	IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
	ANY INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES
	WHATSOEVER RELATING TO THE USE OF THIS WORK, OR YOUR
	RELATIONSHIP WITH THE AUTHOR.

	IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU
	TO USE THE WORK IN APPLICATIONS OR SYSTEMS WHERE THE
	WORK'S FAILURE TO PERFORM CAN REASONABLY BE EXPECTED
	TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN LOSS
	OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK,
	AND YOU AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS
	FROM ANY CLAIMS OR LOSSES RELATING TO SUCH UNAUTHORIZED
	USE.

	Ref: Webpack 8.1i Spartan3-4 xc3s1000-4ft256
	11 LUTs / 6 slices / 12.2 ns

=============================================================== */

module cntlz8(
	input [7:0] i,
	output reg [3:0] o
);

	always @(i)
		case (i)
		8'b00000000:	o = 8;
		8'b00000001:	o = 7;
		8'b00000010:	o = 6;
		8'b00000011:	o = 6;
		8'b00000100:	o = 5;
		8'b00000101:	o = 5;
		8'b00000110:	o = 5;
		8'b00000111:	o = 5;
		8'b00001000:	o = 4;
		8'b00001001:	o = 4;
		8'b00001010:	o = 4;
		8'b00001011:	o = 4;
		8'b00001100:	o = 4;
		8'b00001101:	o = 4;
		8'b00001110:	o = 4;
		8'b00001111:	o = 4;
	         
		8'b00010000:	o = 3;
		8'b00010001:	o = 3;
		8'b00010010:	o = 3;
		8'b00010011:	o = 3;
		8'b00010100:	o = 3;
		8'b00010101:	o = 3;
		8'b00010110:	o = 3;
		8'b00010111:	o = 3;
		8'b00011000:	o = 3;
		8'b00011001:	o = 3;
		8'b00011010:	o = 3;
		8'b00011011:	o = 3;
		8'b00011100:	o = 3;
		8'b00011101:	o = 3;
		8'b00011110:	o = 3;
		8'b00011111:	o = 3;
	         
		8'b00100000:	o = 2;
		8'b00100001:	o = 2;
		8'b00100010:	o = 2;
		8'b00100011:	o = 2;
		8'b00100100:	o = 2;
		8'b00100101:	o = 2;
		8'b00100110:	o = 2;
		8'b00100111:	o = 2;
		8'b00101000:	o = 2;
		8'b00101001:	o = 2;
		8'b00101010:	o = 2;
		8'b00101011:	o = 2;
		8'b00101100:	o = 2;
		8'b00101101:	o = 2;
		8'b00101110:	o = 2;
		8'b00101111:	o = 2;
	         
		8'b00110000:	o = 2;
		8'b00110001:	o = 2;
		8'b00110010:	o = 2;
		8'b00110011:	o = 2;
		8'b00110100:	o = 2;
		8'b00110101:	o = 2;
		8'b00110110:	o = 2;
		8'b00110111:	o = 2;
		8'b00111000:	o = 2;
		8'b00111001:	o = 2;
		8'b00111010:	o = 2;
		8'b00111011:	o = 2;
		8'b00111100:	o = 2;
		8'b00111101:	o = 2;
		8'b00111110:	o = 2;
		8'b00111111:	o = 2;
             
		// 44 - 1	
		8'b01000000:	o = 1;
		8'b01000001:	o = 1;
		8'b01000010:	o = 1;
		8'b01000011:	o = 1;
		8'b01000100:	o = 1;
		8'b01000101:	o = 1;
		8'b01000110:	o = 1;
		8'b01000111:	o = 1;
		8'b01001000:	o = 1;
		8'b01001001:	o = 1;
		8'b01001010:	o = 1;
		8'b01001011:	o = 1;
		8'b01001100:	o = 1;
		8'b01001101:	o = 1;
		8'b01001110:	o = 1;
		8'b01001111:	o = 1;

		8'b01010000:	o = 1;
		8'b01010001:	o = 1;
		8'b01010010:	o = 1;
		8'b01010011:	o = 1;
		8'b01010100:	o = 1;
		8'b01010101:	o = 1;
		8'b01010110:	o = 1;
		8'b01010111:	o = 1;
		8'b01011000:	o = 1;
		8'b01011001:	o = 1;
		8'b01011010:	o = 1;
		8'b01011011:	o = 1;
		8'b01011100:	o = 1;
		8'b01011101:	o = 1;
		8'b01011110:	o = 1;
		8'b01011111:	o = 1;
             
		8'b01100000:	o = 1;
		8'b01100001:	o = 1;
		8'b01100010:	o = 1;
		8'b01100011:	o = 1;
		8'b01100100:	o = 1;
		8'b01100101:	o = 1;
		8'b01100110:	o = 1;
		8'b01100111:	o = 1;
		8'b01101000:	o = 1;
		8'b01101001:	o = 1;
		8'b01101010:	o = 1;
		8'b01101011:	o = 1;
		8'b01101100:	o = 1;
		8'b01101101:	o = 1;
		8'b01101110:	o = 1;
		8'b01101111:	o = 1;
	         
		8'b01110000:	o = 1;
		8'b01110001:	o = 1;
		8'b01110010:	o = 1;
		8'b01110011:	o = 1;
		8'b01110100:	o = 1;
		8'b01110101:	o = 1;
		8'b01110110:	o = 1;
		8'b01110111:	o = 1;
		8'b01111000:	o = 1;
		8'b01111001:	o = 1;
		8'b01111010:	o = 1;
		8'b01111011:	o = 1;
		8'b01111100:	o = 1;
		8'b01111101:	o = 1;
		8'b01111110:	o = 1;
		8'b01111111:	o = 1;

		//  - 2	
		8'b10000000:	o = 0;
		8'b10000001:	o = 0;
		8'b10000010:	o = 0;
		8'b10000011:	o = 0;
		8'b10000100:	o = 0;
		8'b10000101:	o = 0;
		8'b10000110:	o = 0;
		8'b10000111:	o = 0;
		8'b10001000:	o = 0;
		8'b10001001:	o = 0;
		8'b10001010:	o = 0;
		8'b10001011:	o = 0;
		8'b10001100:	o = 0;
		8'b10001101:	o = 0;
		8'b10001110:	o = 0;
		8'b10001111:	o = 0;

		8'b10010000:	o = 0;
		8'b10010001:	o = 0;
		8'b10010010:	o = 0;
		8'b10010011:	o = 0;
		8'b10010100:	o = 0;
		8'b10010101:	o = 0;
		8'b10010110:	o = 0;
		8'b10010111:	o = 0;
		8'b10011000:	o = 0;
		8'b10011001:	o = 0;
		8'b10011010:	o = 0;
		8'b10011011:	o = 0;
		8'b10011100:	o = 0;
		8'b10011101:	o = 0;
		8'b10011110:	o = 0;
		8'b10011111:	o = 0;
	        
		8'b10100000:	o = 0;
		8'b10100001:	o = 0;
		8'b10100010:	o = 0;
		8'b10100011:	o = 0;
		8'b10100100:	o = 0;
		8'b10100101:	o = 0;
		8'b10100110:	o = 0;
		8'b10100111:	o = 0;
		8'b10101000:	o = 0;
		8'b10101001:	o = 0;
		8'b10101010:	o = 0;
		8'b10101011:	o = 0;
		8'b10101100:	o = 0;
		8'b10101101:	o = 0;
		8'b10101110:	o = 0;
		8'b10101111:	o = 0;
	                           
		8'b10110000:	o = 0;
		8'b10110001:	o = 0;
		8'b10110010:	o = 0;
		8'b10110011:	o = 0;
		8'b10110100:	o = 0;
		8'b10110101:	o = 0;
		8'b10110110:	o = 0;
		8'b10110111:	o = 0;
		8'b10111000:	o = 0;
		8'b10111001:	o = 0;
		8'b10111010:	o = 0;
		8'b10111011:	o = 0;
		8'b10111100:	o = 0;
		8'b10111101:	o = 0;
		8'b10111110:	o = 0;
		8'b10111111:	o = 0;
            
		// 44 - 3	
		8'b11000000:	o = 0;
		8'b11000001:	o = 0;
		8'b11000010:	o = 0;
		8'b11000011:	o = 0;
		8'b11000100:	o = 0;
		8'b11000101:	o = 0;
		8'b11000110:	o = 0;
		8'b11000111:	o = 0;
		8'b11001000:	o = 0;
		8'b11001001:	o = 0;
		8'b11001010:	o = 0;
		8'b11001011:	o = 0;
		8'b11001100:	o = 0;
		8'b11001101:	o = 0;
		8'b11001110:	o = 0;
		8'b11001111:	o = 0;
	                           
		8'b11010000:	o = 0;
		8'b11010001:	o = 0;
		8'b11010010:	o = 0;
		8'b11010011:	o = 0;
		8'b11010100:	o = 0;
		8'b11010101:	o = 0;
		8'b11010110:	o = 0;
		8'b11010111:	o = 0;
		8'b11011000:	o = 0;
		8'b11011001:	o = 0;
		8'b11011010:	o = 0;
		8'b11011011:	o = 0;
		8'b11011100:	o = 0;
		8'b11011101:	o = 0;
		8'b11011110:	o = 0;
		8'b11011111:	o = 0;
	        
		8'b11100000:	o = 0;
		8'b11100001:	o = 0;
		8'b11100010:	o = 0;
		8'b11100011:	o = 0;
		8'b11100100:	o = 0;
		8'b11100101:	o = 0;
		8'b11100110:	o = 0;
		8'b11100111:	o = 0;
		8'b11101000:	o = 0;
		8'b11101001:	o = 0;
		8'b11101010:	o = 0;
		8'b11101011:	o = 0;
		8'b11101100:	o = 0;
		8'b11101101:	o = 0;
		8'b11101110:	o = 0;
		8'b11101111:	o = 0;
	                           
		8'b11110000:	o = 0;
		8'b11110001:	o = 0;
		8'b11110010:	o = 0;
		8'b11110011:	o = 0;
		8'b11110100:	o = 0;
		8'b11110101:	o = 0;
		8'b11110110:	o = 0;
		8'b11110111:	o = 0;
		8'b11111000:	o = 0;
		8'b11111001:	o = 0;
		8'b11111010:	o = 0;
		8'b11111011:	o = 0;
		8'b11111100:	o = 0;
		8'b11111101:	o = 0;
		8'b11111110:	o = 0;
		8'b11111111:	o = 0;

		endcase
		

endmodule


module cntlz16(
	input [15:0] i,
	output [4:0] o
);

	wire [3:0] cnt1, cnt2;

	cntlz8 u1 (i[ 7:0],cnt1);
	cntlz8 u2 (i[15:8],cnt2);

	assign o = cnt2[3] ? cnt1 + 4'h8 : cnt2;

endmodule


// 39 slices / 67 LUTs / 19.3ns
module cntlz24(
	input [23:0] i,
	output [4:0] o
);

	wire [3:0] cnt1, cnt2, cnt3;

	// cntlz8 results in faster result than cntlz16
	cntlz8 u1 (i[ 7: 0],cnt1);
	cntlz8 u2 (i[15: 8],cnt2);
	cntlz8 u3 (i[23:16],cnt3);

	assign o =
		!cnt3[3] ? cnt3 :
		!cnt2[3] ? cnt2 + 5'd8 :
		 cnt1 + 5'd16;

endmodule

// 39 slices / 67 LUTs / 19.3ns
module cntlz32(
	input [31:0] i,
	output [5:0] o
);

	wire [3:0] cnt1, cnt2, cnt3, cnt4;

	// cntlz8 results in faster result than cntlz16
	cntlz8 u1 (i[ 7: 0],cnt1);
	cntlz8 u2 (i[15: 8],cnt2);
	cntlz8 u3 (i[23:16],cnt3);
	cntlz8 u4 (i[31:24],cnt4);

	assign o =
		!cnt4[3] ? cnt4 :
		!cnt3[3] ? cnt3 + 6'd8 :
		!cnt2[3] ? cnt2 + 6'd16 :
		 cnt1 + 6'd24;

endmodule


// 88 slices / 154 LUTs / 22.5 ns
module cntlz48(
	input [47:0] i,
	output [5:0] o
);

	wire [4:0] cnt1, cnt2, cnt3;

	cntlz16 u1 (i[15: 0],cnt1);
	cntlz16 u2 (i[31:16],cnt2);
	cntlz16 u3 (i[47:32],cnt3);

	assign o =
		!cnt3[4] ? cnt3 :
		!cnt2[4] ? cnt2 + 7'd16 :
		 cnt1 + 7'd32;

endmodule


// 88 slices / 154 LUTs / 22.5 ns
module cntlz64(
	input [63:0] i,
	output [6:0] o
);

	wire [4:0] cnt1, cnt2, cnt3, cnt4;

	cntlz16 u1 (i[15: 0],cnt1);
	cntlz16 u2 (i[31:16],cnt2);
	cntlz16 u3 (i[47:32],cnt3);
	cntlz16 u4 (i[63:48],cnt4);

	assign o =
		!cnt4[4] ? cnt4 :
		!cnt3[4] ? cnt3 + 7'd16 :
		!cnt2[4] ? cnt2 + 7'd32 :
		 cnt1 + 7'd48;

endmodule


module cntlz32Reg(
	input clk,
	input ce,
	input [31:0] i,
	output reg [5:0] o
);

	wire [5:0] o1;
	cntlz32 u1 (i,o1);
	always @(posedge clk)
		if (ce) o <= o1;

endmodule


module cntlz64Reg(
	input clk,
	input ce,
	input [63:0] i,
	output reg [6:0] o
);

	wire [6:0] o1;
	cntlz64 u1 (i,o1);
	always @(posedge clk)
		if (ce) o <= o1;

endmodule

// 5 slices / 10 LUTs / 7.702 ns
module cntlo8(
	input [7:0] i,
	output [3:0] o
);

	cntlz8 u1 (~i,o);

endmodule


module cntlo16(
	input [15:0] i,
	output [4:0] o
);

	cntlz16 u1 (~i,o);

endmodule


module cntlo32(
	input [31:0] i,
	output [5:0] o
);

	cntlz32 u1 (~i,o);

endmodule


module cntlo48(
	input [47:0] i,
	output [5:0] o
);

	cntlz48 u1 (~i,o);

endmodule


// 59 slices / 99 LUTs / 14.065 ns
module cntlo64(
	input [63:0] i,
	output [6:0] o
);

	cntlz64 u1 (~i,o);

endmodule


