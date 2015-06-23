/***************************************************************************
       This file is part of "HD63701V0 Compatible Processor Core".
****************************************************************************/
`timescale 1ps / 1ps

`include "HD63701_defs.i"

module HD63701_SEQ
(
	input						CLK,
	input						RST,

	input						NMI,
	input						IRQ,

	input						IRQ2,
	input  	[3:0]			IRQ2V,

	input 	[7:0]			DI,

	output `mcwidth		mcout,
	input		[7:0]			vect,
	input						inte,
	output					fncu,

	output 	[5:0] 		PH
);

`define MC_SEI {`mcSCB,   `bfI    ,`mcrC,`mcpN,`amPC,`pcN}
`define MC_YLD {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpK,`amPC,`pcN} 

reg [7:0]   opcode;
reg `mcwidth mcode;
reg  mcside;


reg  pNMI, pIRQ, pIR2;

reg  [2:0]  fINT;
wire bIRQ  = fINT[1] & inte;
wire bIRQ2 = fINT[0] & inte;

wire 		  bINT = fINT[2]|bIRQ|bIRQ2;
wire [7:0] vINT = fINT[2] ? `vaNMI :
						bIRQ    ? `vaIRQ :
						bIRQ2   ? {4'hF,IRQ2V} :
						0;

function [2:0] INTUpd;
input [2:0] n;
	case(n)
	3'b000: INTUpd = 3'b000;
	3'b001: INTUpd = 3'b000;
	3'b010: INTUpd = 3'b000;
	3'b011: INTUpd = 3'b001;
	3'b100: INTUpd = 3'b000;
	3'b101: INTUpd = 3'b001;
	3'b110: INTUpd = 3'b010;
	3'b111: INTUpd = 3'b011;
	endcase
endfunction


reg [5:0] PHASE;
always @( posedge CLK or posedge RST ) begin
	if (RST) begin
		fINT <= 0;
		pIRQ <= 0;
		pNMI <= 0;
		pIR2 <= 0;

		opcode <= 0;
		mcode  <= 0;
		mcside <= 0;
	end
	else begin

		// Capture Interrupt signal edge
		if ((pNMI^NMI)&NMI)   fINT[2] <= 1'b1; pNMI <= NMI;
		if ((pIRQ^IRQ)&IRQ)   fINT[1] <= 1'b1; pIRQ <= IRQ;
		if ((pIR2^IRQ2)&IRQ2) fINT[0] <= 1'b1; pIR2 <= IRQ2;


		case (PHASE)

		// Reset
		`phRST :	mcside <= 1;

		// Load Vector
		`phVECT: mcside <= 1;

		// Execute
		`phEXEC: begin
						opcode <= DI;
						if ( bINT & (opcode[7:1]!=7'b0000111) ) begin
							mcside <= 0;
							mcode  <= {`mcINT,vINT,`mcrn,`mcpI,`amPC,`pcN};
							fINT   <= INTUpd(fINT);
						end
						else mcside <= 1;
					end

		// Interrupt (TRAP/IRQ/NMI/SWI/WAI)
		`phINTR:  mcside <= 1; 
		`phINTR8: begin
						mcside <= 0;
						if (vect==`vaWAI) begin
							if (bINT) begin
								mcode  <= `MC_SEI;
								opcode <= vINT;
								fINT   <= INTUpd(fINT);
							end
							else mcode <= `MC_YLD;
						end
						else begin
							opcode <= vect;
							mcode  <= `MC_SEI;
						end
					 end
		`phINTR9: mcode <= {`mcLDV, opcode,`mcrn,`mcpV,`amE0,`pcN};	//(Load Vector)

		// Sleep
		`phSLEP: begin
						mcside <= 0;
						if (bINT) begin
							mcode  <= {`mcINT,vINT,`mcrn,`mcpI,`amPC,`pcN};
							fINT   <= INTUpd(fINT);
						end
						else mcode <= `MC_YLD;
					end

		// HALT (Bug in MicroCode)
		`phHALT: $stop;

		default:;
		endcase
	end
end

// Update Phase
wire [2:0] mcph = mcout[6:4];
always @( negedge CLK or posedge RST ) begin
	if (RST) PHASE <= 0;
	else begin
		case (mcph)
			`mcpN: PHASE <= PHASE+6'h1;
			`mcp0: PHASE <=`phEXEC;
			`mcpI: PHASE <=`phINTR;
			`mcpV: PHASE <=`phVECT;
			`mcpH: PHASE <=`phHALT;
			`mcpS: PHASE <=`phSLEP;
		 default: PHASE <= PHASE;
		endcase
	end
end
assign PH = PHASE;

// Output MicroCode
wire `mcwidth mcoder;
HD63701_MCROM mcr( CLK, PHASE, (PHASE==`phEXEC) ? DI : opcode, mcoder );
assign mcout = mcside ? mcoder : mcode;

assign fncu = ( opcode[7:4]==4'h2)|
				  ((opcode[7:4]==4'h3)&(opcode[3:0]!=4'hD));

endmodule

