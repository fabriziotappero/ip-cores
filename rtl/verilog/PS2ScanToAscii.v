// ============================================================================
//  Scan Code Converter
//  - Convert PS2 style scancodes to ascii
//
//	2010  Robert Finch
//	robfinch<remove>@FPGAfield.ca
//
//
//  This source code is available for evaluation and validation purposes
//  only. This copyright statement and disclaimer must remain present in
//  the file.
//
//
//	NO WARRANTY.
//  THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
//  EXPRESS OR IMPLIED. The user must assume the entire risk of using the
//  Work.
//
//  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
//  INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
//  THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.
//
//  IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
//  IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
//  REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
//  LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
//  AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
//  LOSSES RELATING TO SUCH UNAUTHORIZED USE.
//
//
//	Convert a PS2 scancode to ascii
//
//	Verilog 1995
//	Webpack 9.2i  xc3s1200-4fg320
//	86 slices / 151 LUTs / 13.164 ns
//
// ============================================================================

module PS2ScanToAscii(shift, ctrl, alt, extend, sc, ascii);
input shift;			// shift indicator
input ctrl;
input alt;
input extend;			// extended scancode
input [7:0] sc;			// scan code
output [7:0] ascii;		// acsii equivalent
reg [7:0] ascii;


always @(sc or shift or ctrl or extend)
begin
	if (extend) begin
		case (sc)
		8'h75:	ascii <= 8'h90;		// up
		8'h74:	ascii <= 8'h91;		// right
		8'h72:	ascii <= 8'h92;		// down
		8'h6b:	ascii <= 8'h93;		// left
		8'h6c:	ascii <= 8'h94;		// home
		8'h69:	ascii <= 8'h95;		// end
		8'h7d:	ascii <= 8'h96;		// pg up
		8'h7a:	ascii <= 8'h97;		// pg down
		8'h70:	ascii <= 8'h98;		// insert
		8'h71:	ascii <= 8'h99;		// delete
		8'h05:	ascii <= 8'ha1;		// F1
		8'h06:	ascii <= 8'ha2;		// F2
		8'h04:	ascii <= 8'ha3;		// F3
		default:	ascii <= 8'h2e;
		endcase
	end
	else if (ctrl) begin
		case (sc)
		8'h0d: ascii <= 8'h09;
		8'h0e: ascii <= 8'h7e;	// ~
		8'h15: ascii <= 8'h11;	// Q
		8'h16: ascii <= 8'h21;	// !
		8'h1b: ascii <= 8'h13;	// S
		8'h1a: ascii <= 8'h1a;	// Z
		8'h1c: ascii <= 8'h01;	// A
		8'h1d: ascii <= 8'h17;	// W
		8'h1e: ascii <= 8'h40;	// @
		8'h21: ascii <= 8'h03;	// C
		8'h22: ascii <= 8'h18;	// X
		8'h23: ascii <= 8'h04;	// D
		8'h24: ascii <= 8'h05;	// E
		8'h25: ascii <= 8'h24;	// $
		8'h26: ascii <= 8'h23;	// #
		8'h29: ascii <= 8'h20;	// space
		8'h2a: ascii <= 8'h16;	// V
		8'h2b: ascii <= 8'h06;	// F
		8'h2c: ascii <= 8'h14;	// T
		8'h2d: ascii <= 8'h12;	// R
		8'h2e: ascii <= 8'h25;	// %
		8'h31: ascii <= 8'h0e;	// N
		8'h32: ascii <= 8'h02;	// B
		8'h33: ascii <= 8'h08;	// H
		8'h34: ascii <= 8'h07;	// G
		8'h35: ascii <= 8'h19;	// Y
		8'h36: ascii <= 8'h5e;	// ^
		8'h3a: ascii <= 8'h0d;	// M
		8'h3b: ascii <= 8'h0a;	// J
		8'h3c: ascii <= 8'h15;	// U
		8'h3d: ascii <= 8'h26;	// &
		8'h3e: ascii <= 8'h2a;	// *
		8'h41: ascii <= 8'h3c;	// <
		8'h42: ascii <= 8'h0b;	// K
		8'h43: ascii <= 8'h09;	// I
		8'h44: ascii <= 8'h0f;	// O
		8'h45: ascii <= 8'h29;	// )
		8'h46: ascii <= 8'h28;	// (
		8'h49: ascii <= 8'h3e;	// >
		8'h4a: ascii <= 8'h3f;	// ?
		8'h4b: ascii <= 8'h0c;	// L
		8'h4c: ascii <= 8'h3a;	// :
		8'h4d: ascii <= 8'h10;	// P
		8'h4e: ascii <= 8'h5f;	// _
		8'h52: ascii <= 8'h22;	// "
		8'h54: ascii <= 8'h7b;	// {
		8'h55: ascii <= 8'h2b;	// +
		8'h5a: ascii <= 8'h0d;
		8'h5b: ascii <= 8'h7d;	// }
		8'h5d: ascii <= 8'h7c;	// |
		8'h66: ascii <= 8'h08;
		8'h76: ascii <= 8'h1b;
		8'h71: ascii <= 8'h7f;	// del
		default:	ascii <= 8'h2e;
		endcase
	end
	else if (shift) begin
		case (sc)
		8'h0d: ascii <= 8'h09;
		8'h0e: ascii <= 8'h7e;	// ~
		8'h15: ascii <= 8'h51;	// Q
		8'h16: ascii <= 8'h21;	// !
		8'h1b: ascii <= 8'h53;	// S
		8'h1a: ascii <= 8'h5a;	// Z
		8'h1c: ascii <= 8'h41;	// A
		8'h1d: ascii <= 8'h57;	// W
		8'h1e: ascii <= 8'h40;	// @
		8'h21: ascii <= 8'h43;	// C
		8'h22: ascii <= 8'h58;	// X
		8'h23: ascii <= 8'h44;	// D
		8'h24: ascii <= 8'h45;	// E
		8'h25: ascii <= 8'h24;	// $
		8'h26: ascii <= 8'h23;	// #
		8'h29: ascii <= 8'h20;	// space
		8'h2a: ascii <= 8'h56;	// V
		8'h2b: ascii <= 8'h46;	// F
		8'h2c: ascii <= 8'h54;	// T
		8'h2d: ascii <= 8'h52;	// R
		8'h2e: ascii <= 8'h25;	// %
		8'h31: ascii <= 8'h4e;	// N
		8'h32: ascii <= 8'h42;	// B
		8'h33: ascii <= 8'h48;	// H
		8'h34: ascii <= 8'h47;	// G
		8'h35: ascii <= 8'h59;	// Y
		8'h36: ascii <= 8'h5e;	// ^
		8'h3a: ascii <= 8'h4d;	// M
		8'h3b: ascii <= 8'h4a;	// J
		8'h3c: ascii <= 8'h55;	// U
		8'h3d: ascii <= 8'h26;	// &
		8'h3e: ascii <= 8'h2a;	// *
		8'h41: ascii <= 8'h3c;	// <
		8'h42: ascii <= 8'h4b;	// K
		8'h43: ascii <= 8'h49;	// I
		8'h44: ascii <= 8'h4f;	// O
		8'h45: ascii <= 8'h29;	// )
		8'h46: ascii <= 8'h28;	// (
		8'h49: ascii <= 8'h3e;	// >
		8'h4a: ascii <= 8'h3f;	// ?
		8'h4b: ascii <= 8'h4c;	// L
		8'h4c: ascii <= 8'h3a;	// :
		8'h4d: ascii <= 8'h50;	// P
		8'h4e: ascii <= 8'h5f;	// _
		8'h52: ascii <= 8'h22;	// "
		8'h54: ascii <= 8'h7b;	// {
		8'h55: ascii <= 8'h2b;	// +
		8'h5a: ascii <= 8'h0d;
		8'h5b: ascii <= 8'h7d;	// }
		8'h5d: ascii <= 8'h7c;	// |
		8'h66: ascii <= 8'h08;
		8'h76: ascii <= 8'h1b;
		8'h71: ascii <= 8'h7f;	// del
		default:	ascii <= 8'h2e;
		endcase
	end
	else begin
		case (sc)
		8'h0d: ascii <= 8'h09;	// tab
		8'h0e: ascii <= 8'h60;	// `
		8'h15: ascii <= 8'h71;	// q
		8'h16: ascii <= 8'h31;	// 1
		8'h1a: ascii <= 8'h7a;	// z
		8'h1b: ascii <= 8'h73;	// s
		8'h1c: ascii <= 8'h61;	// a
		8'h1d: ascii <= 8'h77;	// w
		8'h1e: ascii <= 8'h32;	// 2
		8'h21: ascii <= 8'h63;	// c
		8'h22: ascii <= 8'h78;	// x
		8'h23: ascii <= 8'h64;	// d
		8'h24: ascii <= 8'h65;	// e
		8'h25: ascii <= 8'h34;	// 4
		8'h26: ascii <= 8'h33;	// 3
		8'h29: ascii <= 8'h20;	// space
		8'h2a: ascii <= 8'h76;	// v
		8'h2b: ascii <= 8'h66;	// f
		8'h2c: ascii <= 8'h74;	// t
		8'h2d: ascii <= 8'h72;	// r
		8'h2e: ascii <= 8'h35;	// 5
		8'h31: ascii <= 8'h6e;	// n
		8'h32: ascii <= 8'h62;	// b
		8'h33: ascii <= 8'h68;	// h
		8'h34: ascii <= 8'h67;	// g
		8'h35: ascii <= 8'h79;	// y
		8'h36: ascii <= 8'h36;	// 6
		8'h3a: ascii <= 8'h6d;	// m
		8'h3b: ascii <= 8'h6a;	// j
		8'h3c: ascii <= 8'h75;	// u
		8'h3d: ascii <= 8'h37;	// 7
		8'h3e: ascii <= 8'h38;	// 8
		8'h41: ascii <= 8'h2c;	// ,
		8'h42: ascii <= 8'h6b;	// k
		8'h43: ascii <= 8'h69;	// i
		8'h44: ascii <= 8'h6f;	// o
		8'h45: ascii <= 8'h30;	// 0
		8'h46: ascii <= 8'h39;	// 9
		8'h49: ascii <= 8'h2e;	// .
		8'h4a: ascii <= 8'h2f;	// /
		8'h4b: ascii <= 8'h6c;	// l
		8'h4c: ascii <= 8'h3b;	// ;
		8'h4d: ascii <= 8'h70;	// p
		8'h4e: ascii <= 8'h2d;	// -
		8'h52: ascii <= 8'h27;	// '
		8'h54: ascii <= 8'h5b;	// [
		8'h55: ascii <= 8'h3d;	// =
		8'h5a: ascii <= 8'h0d;	// carriage return
		8'h5b: ascii <= 8'h5d;	// ]
		8'h5d: ascii <= 8'h5c;	// \
		8'h63: ascii <= 8'h90;		// up	{set 3}
		8'h66: ascii <= 8'h08;	// backspace
		8'h71: ascii <= 8'h7f;	// del
		8'h76: ascii <= 8'h1b;	// escape
		default: ascii <= 8'h2e;  // '.' used for unlisted characters.
		endcase
	end
end

endmodule
