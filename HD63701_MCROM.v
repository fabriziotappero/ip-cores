/***************************************************************************
       This file is part of "HD63701V0 Compatible Processor Core".
****************************************************************************/
`include "HD63701_defs.i"

module HD63701_MCROM
(
	input			CLK,
	input [5:0] PHASE,
	input [7:0] OPCODE,

	output `mcwidth mcode
);

`include "HD63701_MCODE.i"

reg [5:0] p;
always @( posedge CLK ) p <= PHASE;

wire `mcwidth mc0,mc1,mc2,mc3,mc4,mc5,mc6,mc7,mc8,mc9;
HD63701_MCROM_S0 r0(CLK,OPCODE,mc0);
HD63701_MCROM_S1 r1(CLK,OPCODE,mc1);
HD63701_MCROM_S2 r2(CLK,OPCODE,mc2);
HD63701_MCROM_S3 r3(CLK,OPCODE,mc3);
HD63701_MCROM_S4 r4(CLK,OPCODE,mc4);
HD63701_MCROM_S5 r5(CLK,OPCODE,mc5);
HD63701_MCROM_S6 r6(CLK,OPCODE,mc6);
HD63701_MCROM_S7 r7(CLK,OPCODE,mc7);
HD63701_MCROM_S8 r8(CLK,OPCODE,mc8);
HD63701_MCROM_S9 r9(CLK,OPCODE,mc9);

assign mcode = 
				(p==`phRST  ) ? {`mcLDV,  `vaRST,   `mcrn,`mcpN,`amE0,`pcN}: 	//(Load Reset Vector)
				
				(p==`phVECT ) ? {`mcLDN,`mcrM,`mcrn,`mcrU,`mcpN,`amE0,`pcN}:	//(Load VectorH)
				(p==`phVEC1 ) ? {`mcLDN,`mcrM,`mcrn,`mcrV,`mcpN,`amE1,`pcN}:	//(Load VectorL)
				(p==`phVEC2 ) ? {`mcLDN,`mcrT,`mcrn,`mcrP,`mcp0,`amPC,`pcN}:	//(Load to PC)

				(p==`phEXEC ) ? mc0 :
				(p==`phEXEC1) ? mc1 :
				(p==`phEXEC2) ? mc2 :
				(p==`phEXEC3) ? mc3 :
				(p==`phEXEC4) ? mc4 :
				(p==`phEXEC5) ? mc5 :
				(p==`phEXEC6) ? mc6 :
				(p==`phEXEC7) ? mc7 :
				(p==`phEXEC8) ? mc8 :
				(p==`phEXEC9) ? mc9 :

				(p==`phINTR ) ? {`mcLDN,`mcrC,`mcrn,`mcrT,`mcpN,`amPC,`pcN}:	//(T=C)
				(p==`phINTR1) ? {`mcPSH,`mcrP,`mcrn,`mcrM,`mcpN,`amSP,`pcN}: 	//[PUSH PL]
				(p==`phINTR2) ? {`mcPSH,`mcrP,`mcrn,`mcrN,`mcpN,`amSP,`pcN}:	//[PUSH PH]
				(p==`phINTR3) ? {`mcPSH,`mcrX,`mcrn,`mcrM,`mcpN,`amSP,`pcN}:	//[PUSH XL]
				(p==`phINTR4) ? {`mcPSH,`mcrX,`mcrn,`mcrN,`mcpN,`amSP,`pcN}:	//[PUSH XH]
				(p==`phINTR5) ? {`mcPSH,`mcrA,`mcrn,`mcrM,`mcpN,`amSP,`pcN}:	//[PUSH A]
				(p==`phINTR6) ? {`mcPSH,`mcrB,`mcrn,`mcrM,`mcpN,`amSP,`pcN}:	//[PUSH B]
				(p==`phINTR7) ? {`mcPSH,`mcrT,`mcrn,`mcrM,`mcpN,`amSP,`pcN}:	//[PUSH T]
				(p==`phINTR8) ? 0:
				(p==`phINTR9) ? 0:
									`MC_HALT;
				
endmodule

module HD63701_MCROM_S0( input CLK, input [7:0] OPCODE, output reg `mcwidth mcode );
`include "HD63701_MCODE.i"
always @( posedge CLK ) mcode <= MCODE_S0(OPCODE);
endmodule

module HD63701_MCROM_S1( input CLK, input [7:0] OPCODE, output reg `mcwidth mcode );
`include "HD63701_MCODE.i"
always @( posedge CLK ) mcode <= MCODE_S1(OPCODE);
endmodule

module HD63701_MCROM_S2( input CLK, input [7:0] OPCODE, output reg `mcwidth mcode );
`include "HD63701_MCODE.i"
always @( posedge CLK ) mcode <= MCODE_S2(OPCODE);
endmodule

module HD63701_MCROM_S3( input CLK, input [7:0] OPCODE, output reg `mcwidth mcode );
`include "HD63701_MCODE.i"
always @( posedge CLK ) mcode <= MCODE_S3(OPCODE);
endmodule

module HD63701_MCROM_S4( input CLK, input [7:0] OPCODE, output reg `mcwidth mcode );
`include "HD63701_MCODE.i"
always @( posedge CLK ) mcode <= MCODE_S4(OPCODE);
endmodule

module HD63701_MCROM_S5( input CLK, input [7:0] OPCODE, output reg `mcwidth mcode );
`include "HD63701_MCODE.i"
always @( posedge CLK ) mcode <= MCODE_S5(OPCODE);
endmodule

module HD63701_MCROM_S6( input CLK, input [7:0] OPCODE, output reg `mcwidth mcode );
`include "HD63701_MCODE.i"
always @( posedge CLK ) mcode <= MCODE_S6(OPCODE);
endmodule

module HD63701_MCROM_S7( input CLK, input [7:0] OPCODE, output reg `mcwidth mcode );
`include "HD63701_MCODE.i"
always @( posedge CLK ) mcode <= MCODE_S7(OPCODE);
endmodule

module HD63701_MCROM_S8( input CLK, input [7:0] OPCODE, output reg `mcwidth mcode );
`include "HD63701_MCODE.i"
always @( posedge CLK ) mcode <= MCODE_S8(OPCODE);
endmodule

module HD63701_MCROM_S9( input CLK, input [7:0] OPCODE, output reg `mcwidth mcode );
`include "HD63701_MCODE.i"
always @( posedge CLK ) mcode <= MCODE_S9(OPCODE);
endmodule

