/***************************************************************************
       This file is part of "HD63701V0 Compatible Processor Core".
****************************************************************************/
`timescale 1ps / 1ps
`include "HD63701_defs.i"

module HD63701_Core
(
	input					CLKx2,

	input					RST,
	input					NMI,
	input					IRQ,
	input					IRQ2,
	input 	 [3:0]	IRQ2V,

	output 				RW,
	output 	[15:0]	AD,
	output	 [7:0]	DO,
	input     [7:0]	DI,

  // for DEBUG
	output				CLKo,
	output    [5:0]	PH,
	output `mcwidth	MC,
	output   [15:0]	REG_D,
	output   [15:0]	REG_X,
	output	[15:0]	REG_S,
	output	 [5:0]	REG_C
);

reg CLK = 0;
always @( negedge CLKx2 ) CLK <= ~CLK;
assign CLKo = CLK;

wire `mcwidth mcode;
wire [7:0] 	  vect;
wire		  	  inte, fncu;

assign MC = mcode;

HD63701_SEQ   SEQ(.CLK(CLK),.RST(RST),
						.NMI(NMI),.IRQ(IRQ),.IRQ2(IRQ2),.IRQ2V(IRQ2V),
						.DI(DI),
						.mcout(mcode),.vect(vect),.inte(inte),.fncu(fncu),
						.PH(PH) );

HD63701_EXEC EXEC(.CLK(CLK),.RST(RST),.DI(DI),.AD(AD),.RW(RW),.DO(DO),
						.mcode(mcode),.vect(vect),.inte(inte),.fncu(fncu),
						.REG_D(REG_D),.REG_X(REG_X),.REG_S(REG_S),.REG_C(REG_C) );

endmodule


