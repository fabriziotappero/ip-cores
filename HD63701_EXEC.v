/***************************************************************************
       This file is part of "HD63701V0 Compatible Processor Core".
****************************************************************************/
`timescale 1ps / 1ps
`include "HD63701_defs.i"

module HD63701_EXEC
(
	input						CLK,
	input						RST,
	
	input			[7:0]		DI,
	
	output	  [15:0]		AD,
	output reg				RW,
	output reg  [7:0]		DO,

	input		`mcwidth		mcode,
	output reg	[7:0]		vect,
	output					inte,
	input						fncu,
	
	output	[15:0]		REG_D,
	output	[15:0]		REG_X,
	output	[15:0]		REG_S,
	output	 [5:0]		REG_C
);

// MicroCode Format
wire       mcpi = mcode[0];
wire [2:0] mcam = mcode[3:1];
wire [2:0] mcph = mcode[6:4];
wire [3:0] mcr2 = mcode[10:7];
wire [3:0] mcr1 = mcode[14:11];
wire [3:0] mcr0 = mcode[18:15];
wire [4:0] mcop = mcode[23:19];

wire		  mcnw = (mcop==`mcCCB)|(mcop==`mcSCB)|(mcop==`mcAPC)|
						(mcop==`mcLDV)|(mcop==`mcINT);

wire [7:0] mccf = {mcr0,mcr1};	// case of mcCCB & mcSCB & mcAPC
wire [7:0] mcva = {mcr0,mcr1};	// case of mcLDV & mcINT


// Registers
reg  [15:0] rT, rE, rD, rX, rS, rSp, rP;
reg	[5:0]	rC;

`define rA	rD[15:8]
`define rB	rD[7:0]
`define rU	rT[15:8]
`define rV	rT[7:0]


// ALU
wire IsCCR   = (mcop==`mcCCB)|(mcop==`mcSCB);
wire IsCChit = (({(rC[1]^rC[3]),rC} & mccf[6:0]) == 7'h0) ^ mccf[7];

wire [15:0] R0, R1, RR;
wire  [5:0] CC;

HD63701_DSEL13 sR0(
	.o(R0),
	.f0((mcr0 == `mcrC)|IsCCR),.d0({10'b00000000_11,rC}),
	.f1(mcr0 == `mcrA), .d1({8'h0,`rA}),
	.f2(mcr0 == `mcrB), .d2({8'h0,`rB}),
	.f3(mcr0 == `mcrD), .d3(rD),
	.f4(mcr0 == `mcrX), .d4(rX),
	.f5(mcr0 == `mcrS), .d5(rS),
	.f6(mcr0 == `mcrP), .d6(rP),
	.f7(mcr0 == `mcrU), .d7({8'h0,`rU}),
	.f8(mcr0 == `mcrV), .d8({8'h0,`rV}),
	.f9(mcr0 == `mcrN), .d9({DI,8'h0}),
	.fA(mcr0 == `mcrM), .dA({8'h0,DI}),
	.fB(mcr0 == `mcrT), .dB(rT),
	.fC(mcr0 == `mcrE), .dC(rE)
);

HD63701_DSEL13 sR1(
	.o(R1),
	.f0((mcr1 == `mcrC)|IsCCR),.d0({10'b00000000_11,rC}),
	.f1(mcr1 == `mcrA), .d1({8'h0,`rA}),
	.f2(mcr1 == `mcrB), .d2({8'h0,`rB}),
	.f3(mcr1 == `mcrD), .d3(rD),
	.f4(mcr1 == `mcrX), .d4(rX),
	.f5(mcr1 == `mcrS), .d5(rS),
	.f6(mcr1 == `mcrP), .d6(rP),
	.f7(mcr1 == `mcrU), .d7({8'h0,`rU}),
	.f8(mcr1 == `mcrV), .d8({8'h0,`rV}),
	.f9(mcr1 == `mcrN), .d9({DI,8'h0}),
	.fA(mcr1 == `mcrM), .dA({8'h0,DI}),
	.fB(mcr1 == `mcrT), .dB(rT),
	.fC(mcr1 == `mcrE), .dC(rE)
);

HD63701_ALU ALU(
	.op(mcop),.cf(mccf),.bw((mcr2==`mcrn) ? mcr0[2] : mcr2[2]),
	.R0(R0),.R1(R1),.C(rC[0]),
	.RR(RR),.RC(CC)
);


// Bus Control
HD63701_DSEL8 sAB(
	.o(AD),
	.f0(mcam==`amPC), .d0(rP),
	.f1(mcam==`amP1), .d1(rP+16'h1),
	.f2(mcam==`amSP), .d2(rS),
	.f3(mcam==`amS1), .d3(rS+16'h1),
	.f4(mcam==`amX0), .d4(rX),
	.f5(mcam==`amXT), .d5(rX+rT),
	.f6(mcam==`amE0), .d6(rE),
	.f7(mcam==`amE1), .d7(rE+16'h1)
);


// Update Registers
reg [4:0] pmcop;
always @( posedge CLK ) begin
		  if (pmcop==`mcPSH) rS <= rSp-16'h1;
	else if (pmcop==`mcPUL) rS <= rSp+16'h1;
	else rS <= rSp;
end

wire noCCop = (mcop!=`mcLDV)&(mcop!=`mcLDN)&(mcop!=`mcPSH)&(mcop!=`mcPUL)&(mcop!=`mcAPC)&(mcop!=`mcTST)&(~fncu);
wire noCCrg = (mcr2!=`mcrC )&(mcr2!=`mcrS )&(mcr2!=`mcrP )&(mcr0!=`mcrC );

always @( negedge CLK or posedge RST ) begin
	if (RST) begin
		pmcop <= 0;
		vect <= 0;
		rT   <= 0;
		rE   <= 0;
		rP   <= 0;
		rC   <= 6'b010000;
		DO   <= 0;
	end
	else begin
		if ((mcr2!=`mcrP)&(mcpi==`pcI)) rP <= rP+16'h1;
		if (noCCrg & noCCop) rC <= {CC[5],rC[4],CC[3:0]};
		if (mcr2!=`mcrS) rSp <= rS;
		case (mcop)
			`mcXTD: begin rT <= rX; rX <= rD; end
			`mcAPC: if (IsCChit) rP <= rP+{{8{rT[7]}},rT[7:0]};
			`mcINT: vect <= mcva;
			`mcLDV: rE   <= {8'hFF,mcva};
			`mcTST: rC   <= {rC[5:3],CC[2],rC[1:0]};
		  default: case (mcr2)
					`mcrA: `rA  <= RR[7:0];
					`mcrB: `rB  <= RR[7:0];
					`mcrC:  rC  <= RR[5:0];
					`mcrD:  rD  <= RR;
					`mcrX:  rX  <= RR;
					`mcrS:  rSp <= RR;
					`mcrP:  rP  <= RR;
					`mcrU: `rU  <= RR[7:0];
					`mcrV: `rV  <= RR[7:0];
					`mcrT:  rT  <= RR;
					`mcrE:  rE  <= RR;
				 default:;
			endcase
		endcase
		DO <=  mcnw ? 8'h0 :
				(mcr2==`mcrN) ? RR[15:8] :
			   (mcr2==`mcrM) ? RR[ 7:0] :
				 8'h0;

		pmcop <= mcop;
	end
end

wire RWRES = CLK;
always @( negedge CLK or posedge RWRES ) begin
	if (RWRES) RW <= 0;
	else begin
		RW <= ((mcr2==`mcrN)|(mcr2==`mcrM)) & (~mcnw);
	end
end

assign inte = ~rC[4];


assign REG_D = rD;
assign REG_X = rX;
assign REG_S = rS;
assign REG_C = rC;

endmodule


module HD63701_DSEL13
(
	output [15:0] o,

	input f0, input [15:0] d0,
	input f1, input [15:0] d1,
	input f2, input [15:0] d2,
	input f3, input [15:0] d3,
	input f4, input [15:0] d4,
	input f5, input [15:0] d5,
	input f6, input [15:0] d6,
	input f7, input [15:0] d7,
	input f8, input [15:0] d8,
	input f9, input [15:0] d9,
	input fA, input [15:0] dA,
	input fB, input [15:0] dB,
	input fC, input [15:0] dC
);

assign o =
			f0 ? d0 :
			f1 ? d1 :
			f2 ? d2 :
			f3 ? d3 :
			f4 ? d4 :
			f5 ? d5 :
			f6 ? d6 :
			f7 ? d7 :
			f8 ? d8 :
			f9 ? d9 :
			fA ? dA :
			fB ? dB :
			fC ? dC :
			16'h0 ;

endmodule


module HD63701_DSEL8
(
	output [15:0] o,

	input f0, input [15:0] d0,
	input f1, input [15:0] d1,
	input f2, input [15:0] d2,
	input f3, input [15:0] d3,
	input f4, input [15:0] d4,
	input f5, input [15:0] d5,
	input f6, input [15:0] d6,
	input f7, input [15:0] d7
);

assign o =
			f0 ? d0 :
			f1 ? d1 :
			f2 ? d2 :
			f3 ? d3 :
			f4 ? d4 :
			f5 ? d5 :
			f6 ? d6 :
			f7 ? d7 :
			16'h0 ;

endmodule

