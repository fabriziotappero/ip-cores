/***************************************************************************
       This file is part of "HD63701V0 Compatible Processor Core".
      ( DON'T ADD TO PROJECT, Because this file is include file. )
****************************************************************************/
`define vaRST		8'hFE		// RESET	Vector $FFFE
`define vaTRP		8'hEE		// TRAP	Vector $FFEE
`define vaNMI		8'hFC		// NMI	Vector $FFFC	(NMI signal)
`define vaSWI		8'hFA		// SWI	Vector $FFFA	(Software Interrupt)
`define vaIRQ		8'hF8		// IRQ	Vector $FFF8	(IRQ signal)
`define vaICF		8'hF6		// ICF	Vector $FFF6	(Timer Input Capture)
`define vaOCF		8'hF4		// OCF	Vector $FFF4	(Timer Output Compare)
`define vaTOF		8'hF2		// TOF	Vector $FFF2	(Timer OverFlow)
`define vaSCI		8'hF0		// SCI	Vector $FFF0	(Serial)
`define vaWAI		8'h00		// WAI	Vector			(Special)


`define phRST		 0
//------------------
`define phVECT		 1
`define phVEC1		 2
`define phVEC2		 3
//------------------
`define phEXEC		16
`define phEXEC1	17
`define phEXEC2	18
`define phEXEC3	19
`define phEXEC4	20
`define phEXEC5	21
`define phEXEC6	22
`define phEXEC7	23
`define phEXEC8	24
`define phEXEC9	25
//------------------
`define phINTR		32
`define phINTR1	33
`define phINTR2	34
`define phINTR3	35
`define phINTR4	36
`define phINTR5	37
`define phINTR6	38
`define phINTR7	39
`define phINTR8	40
`define phINTR9	41
//------------------
`define phSLEP		62
`define phHALT		63


`define mcNOP		`mcLDN
`define mcLDN		5'd0
`define mcINC		5'd1
`define mcADD		5'd2
`define mcADC		5'd3
`define mcDEC		5'd4
`define mcSUB		5'd5
`define mcSBC		5'd6
`define mcMUL		5'd7
`define mcNEG		5'd8
`define mcNOT		5'd9
`define mcAND		5'd10
`define mcLOR		5'd11
`define mcEOR		5'd12
`define mcASL		5'd13
`define mcASR		5'd14
`define mcLSR		5'd15
`define mcROL		5'd16
`define mcROR		5'd17
`define mcCCB		5'd18
`define mcSCB		5'd19
`define mcLDR		5'd20
`define mcTST		5'd21
//---------------------
`define mcINT		5'd25
`define mcPSH		5'd26
`define mcPUL		5'd27
`define mcXTD		5'd28
`define mcDAA		5'd29
`define mcAPC		5'd30
`define mcLDV		5'd31


									// [2] : 0=byte,1=word
`define mcrn		4'd0		// none
`define mcrA		4'd1
`define mcrB		4'd2
`define mcrC		4'd3

`define mcrD		4'd4		// {A,B}
`define mcrX		4'd5
`define mcrS		4'd6
`define mcrP		4'd7

`define mcrU		4'd8
`define mcrV		4'd9
`define mcrN		4'd10		// x.H <-> (rE)
`define mcrM		4'd11		// x.L <-> (rE)

`define mcrT		4'd12		// {U,V} Temporary
`define mcrE		4'd13		// Effective Address
`define mcrI		4'd14		// Immidiate
//---------------------


`define mcpK		3'd0		// Keep
`define mcpN		3'd1		// Next
`define mcp0		3'd2		// To Stage0
`define mcpI		3'd3		// To Interrupt
`define mcpV		3'd4		// To Vector
//------------------------------------------
`define mcpH		3'd6		// To HALT
`define mcpS		3'd7		// To SLEEP


`define amPC		3'd0
`define amP1		3'd1
`define amSP		3'd2
`define amS1		3'd3
`define amX0		3'd4
`define amXT		3'd5
`define amE0		3'd6
`define amE1		3'd7


`define pcN			1'b0		// PC=PC
`define pcI			1'b1		// PC=PC+1


//                    +- N^V
//                    |
`define bfRA		8'b00000000
`define bfRN		8'b10000000
`define bfHI		8'b00000101
`define bfLS		8'b10000101
`define bfCC		8'b00000001
`define bfCS		8'b10000001
`define bfNE		8'b00000100
`define bfEQ		8'b10000100
`define bfVC		8'b00000010
`define bfVS		8'b10000010
`define bfPL		8'b00001000
`define bfMI		8'b10001000
`define bfGE		8'b01000000
`define bfLT		8'b11000000
`define bfGT		8'b01000100
`define bfLE		8'b11000100

`define bfC			8'b00000001
`define bfV			8'b00000010
`define bfZ			8'b00000100
`define bfN			8'b00001000
`define bfI			8'b00010000
`define bfH			8'b00100000


`define mcwidth [23:0]
