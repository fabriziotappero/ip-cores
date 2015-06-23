//--------------------------------------------------------------------------------------------------
//
// Title       : AU
// Design      : MicroRISCII
// Author      : Ali Mashtizadeh
//
//-------------------------------------------------------------------------------------------------
`timescale 1ps / 1ps

`define		ALUENABLEMUL	1
// `define	ALUENABLEDIV	1
// `define	ALUENABLEMOD	1
`define		ALU_ADD		4'b0000
`define		ALU_SUB		4'b0001
`define		ALU_MUL		4'b0010
`define		ALU_UMUL	4'b0011
`define		ALU_DIV		4'b0100
`define		ALU_UDIV	4'b0101
`define		ALU_MOD		4'b0110
`define		ALU_UMOD	4'b0111
`define		ALU_SHR		4'b1000
`define		ALU_SHL		4'b1001
`define		ALU_ROR		4'b1010
`define		ALU_ROL		4'b1011
`define		ALU_PCNT	4'b1100
`define		ALU_PCNTZ	4'b1101
`define		ALU_PCNTC	4'b1110
`define		ALU_RND		4'b1111

module au(a,b,arith_op,carry,o,rndin);
	// Inputs
	input	[31:0]	a;
	wire	[31:0]	a;
	input	[31:0]	b;
	wire	[31:0]	b;
	input	[3:0]	arith_op;
	wire	[3:0]	arith_op;
	input	[31:0]	rndin;
	wire	[31:0]	rndin;
	// Outputs
	output	[31:0]	o;
	reg		[31:0]	o;
	output			carry;
	reg				carry;
	// Internal
	reg		[4:0]	pcnt0,pcnt1; // Population Count
	reg		[4:0]	pcntz0,pcntz1;
	reg		[4:0]	pcntc0,pcntc1;
	reg		[31:0]	a_inv; // Inverted A Register
	reg		[31:0]	a_chg; // Bit Change Checking Register
	reg		[31:0]	rnd; // Random Register

	always @ (a) // Inverter
		a_inv = !(a);

	always @ (a) // Change Checker
		begin
			a_chg[31] = 1'b0;
			a_chg[30] = a[31] ^^ a[30];
			a_chg[29] = a[30] ^^ a[29];
			a_chg[28] = a[29] ^^ a[28];
			a_chg[27] = a[28] ^^ a[27];
			a_chg[26] = a[27] ^^ a[26];
			a_chg[25] = a[26] ^^ a[25];
			a_chg[24] = a[25] ^^ a[24];
			a_chg[23] = a[24] ^^ a[23];
			a_chg[22] = a[23] ^^ a[22];
			a_chg[21] = a[22] ^^ a[21];
			a_chg[20] = a[21] ^^ a[20];
			a_chg[19] = a[20] ^^ a[19];
			a_chg[18] = a[19] ^^ a[18];
			a_chg[17] = a[18] ^^ a[17];
			a_chg[16] = a[17] ^^ a[16];
			a_chg[15] = a[16] ^^ a[15];
			a_chg[14] = a[15] ^^ a[14];
			a_chg[13] = a[14] ^^ a[13];
			a_chg[12] = a[13] ^^ a[12];
			a_chg[11] = a[12] ^^ a[11];
			a_chg[10] = a[11] ^^ a[10];
			a_chg[9] = a[10] ^^ a[9];
			a_chg[8] = a[9] ^^ a[8];
			a_chg[7] = a[8] ^^ a[7];
			a_chg[6] = a[7] ^^ a[6];
			a_chg[5] = a[6] ^^ a[5];
			a_chg[4] = a[5] ^^ a[4];
			a_chg[3] = a[4] ^^ a[3];
			a_chg[2] = a[3] ^^ a[2];
			a_chg[1] = a[2] ^^ a[1];
			a_chg[0] = a[1] ^^ a[0];
		end

	// TODO: Random Number Generator

	always @ (arith_op || a || b) // Main Operation
		case (arith_op)
			`ALU_ADD : // Add
				o = a + b;
			`ALU_SUB : // Sub
				o = a - b;
`ifdef ALUENABLEMUL
			`ALU_MUL : // Multiply
				{o[31],o[30:0]} = {(a ^^ b),(a[30:0] * b[30:0])};
			`ALU_UMUL : // Multiply
				o = a * b;
`endif
`ifdef ALUENABLEDIV			
			`ALU_DIV : // Divide
				{o[31],o[30:0]} = {(a ^^ b),(a[30:0] / b[30:0])};
			`ALU_UDIV : // Divide
				o = a / b;
`endif
`ifdef ALUENABLEMOD
			`ALU_MOD : // Modulo
				{o[31],o[30:0]} = {(a ^^ b),(a[30:0] % b[30:0])};
			`ALU_UMOD : // Modulo
				o = a % b;
`endif
			`ALU_SHR : // Shift Right
				o = a >> b[4:0];
			`ALU_SHL : // Shift Left
				o = a << b[4:0];
			`ALU_ROR : // Rotate Right ? I think this is mest up
				o = (a >> b[4:0]) || (a << (5'b1-b[4:0]));
			`ALU_ROL : // Rotate Left ? I think this is mest up
				o = (a << b[4:0]) || (a >> (5'b1-b[4:0]));
			`ALU_PCNT : // Population Count (One)
			begin
				pcnt0 = PopCntO4(a[31:28]) + PopCntO4(a[27:24]) + PopCntO4(a[23:20]) + PopCntO4(a[19:16]);
				pcnt1 = PopCntO4(a[15:12]) + PopCntO4(a[11:8]) + PopCntO4(a[7:4]) + PopCntO4(a[3:0]);
				o = pcnt0 + pcnt1;
			end
			`ALU_PCNTZ : // Population Count (Zero)
			begin
				pcntz0 = PopCntO4(a_inv[31:28]) + PopCntO4(a_inv[27:24]) + PopCntO4(a_inv[23:20]) + PopCntO4(a_inv[19:16]);
				pcntz1 = PopCntO4(a_inv[15:12]) + PopCntO4(a_inv[11:8]) + PopCntO4(a_inv[7:4]) + PopCntO4(a_inv[3:0]);
				o = pcntz0 + pcntz1;
			end
			`ALU_PCNTC : // Population Count (Change)
			begin
				pcntc0 = PopCntO4(a_chg[31:28]) + PopCntO4(a_chg[27:24]) + PopCntO4(a_chg[23:20]) + PopCntO4(a_chg[19:16]);
				pcntc1 = PopCntO4(a_chg[15:12]) + PopCntO4(a_chg[11:8]) + PopCntO4(a_chg[7:4]) + PopCntO4(a_chg[3:0]);
				o = pcntc0 + pcntc1;
			end
			`ALU_RND : // Random
				o = rnd;
		endcase

	function [5:0] PopCntO4; // One Count
	input [3:0] x;
		begin
			PopCntO4[5:3] = 3'b000;
			PopCntO4[2] = x[0] && x[1] && x[2] && x[3];
			PopCntO4[1] = (((x[0] ^^ x[1]) && (x[2] ^^ x[3])) || ((x[0] && x[1]) ^^ (x[2] && x[3])));
			PopCntO4[0] = (((x[0] ^^ x[1]) && !(x[2] ^^ x[3])) || (!(x[0] ^^ x[1]) && (x[2] ^^ x[3])));
		end
	endfunction
endmodule
