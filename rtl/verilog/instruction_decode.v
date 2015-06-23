`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////////
// 
// 4004 Instruction Decoder
// 
// This file is part of the MCS-4 project hosted at OpenCores:
//      http://www.opencores.org/cores/mcs-4/
// 
// Copyright © 2012 by Reece Pollack <rrpollack@opencores.org>
// 
// These materials are provided under the Creative Commons
// "Attribution-NonCommercial-ShareAlike" Public License. They
// are NOT "public domain" and are protected by copyright.
// 
// This work based on materials provided by Intel Corporation and
// others under the same license. See the file doc/License for
// details of this license.
//
////////////////////////////////////////////////////////////////////////

module instruction_decode(
	input  wire			sysclk,					// 50 MHz FPGA clock
	
	// Inputs from the Timing and I/O board
	input  wire			clk1,
	input  wire			clk2,
	input  wire			a22,
	input  wire			m12,
	input  wire			m22,
	input  wire			x12,
	input  wire			x22,
	input  wire			x32,
	input  wire			poc,					// Power-On Clear (reset)
	input  wire			n0432,					// Conditioned TEST_PAD

	// Common 4-bit data bus
	inout  wire	[3:0]	data,

	// These drive the Instruction Pointer (IP) board
	output wire			jcn_isz,				// JCN+ISZ
	output wire			jin_fin,				// JIN+FIN
	output wire			jun_jms,				// JUN+JMS
	output wire			cn_n,					// ~CN
	output wire			bbl,					// BBL
	output wire			jms,					// JMS
	
	// Outputs to both the IP and SP boards
	output wire			sc,						// SC (Single Cycle)
	output wire			dc,						// DC (Double Cycle, ~SC)

	// Outputs to the Scratch Pad (SP) board
	output wire			sc_m22_clk2,			// SC&M22&CLK2 
	output wire			fin_fim_src_jin,		// FIN+FIM+SRC+JIN
	output wire			inc_isz_add_sub_xch_ld,	// INC+ISZ+ADD+SUB+XCH+LD
	output wire			inc_isz_xch,			// INC+ISZ+XCH
	output wire			opa0_n,					// ~OPA.0

	// Inputs from the ALU board (condition bits)
	input  wire			acc_0,					// ACC_0
	input  wire			add_0,					// ADD_0
	input  wire			cy_1,					// CY_1

	// Outputs to the Arithmetic Logic Unit (ALU) board
	output wire			cma,
	output wire			write_acc_1,
	output wire			write_carry_2,
	output wire			read_acc_3,
	output wire			add_group_4,
	output wire			inc_group_5,
	output wire			sub_group_6,
	output wire			ior,
	output wire			iow,
	output wire			ral,
	output wire			rar,
	output wire			ope_n,
	output wire			daa,
	output wire			dcl,
	output wire			inc_isz,
	output wire			kbp,
	output wire			o_ib,
	output wire			tcs,
	output wire			xch,
	output wire			n0342,
	output wire			x21_clk2,
	output wire			x31_clk2,
	output wire			com_n
	);
	
	wire	sc_m12_clk2 = sc & m12 & clk2;
	assign	sc_m22_clk2 = sc & m22 & clk2;

	// Latch the first 4 bits of the opcode
	reg [3:0] opr = 4'b0000;
	always @(posedge sysclk) begin
		if (sc_m12_clk2)
			opr <= data;
	end
	
	// Latch the second 4 bits of the opcode
	reg [3:0] opa = 4'b0000;
	always @(posedge sysclk) begin
		if (sc_m22_clk2)
			opa <= data;
	end
	assign opa0_n = ~opa[0];
	
	// Full OPR Decoding
	wire	nop		= (opr == 4'b0000);
	wire	jcn		= (opr == 4'b0001);
	wire	fim_src	= (opr == 4'b0010);
	assign	jin_fin	= (opr == 4'b0011);
	wire	jun		= (opr == 4'b0100);
	assign	jms		= (opr == 4'b0101);
	wire	inc		= (opr == 4'b0110);
	wire	isz		= (opr == 4'b0111);
	wire	add		= (opr == 4'b1000);
	wire	sub		= (opr == 4'b1001);
	wire	ld		= (opr == 4'b1010);
	assign	xch		= (opr == 4'b1011);
	assign	bbl		= (opr == 4'b1100);
	wire	ldm		= (opr == 4'b1101);
	wire	io		= (opr == 4'b1110);
	wire	ope		= (opr == 4'b1111);
	
	assign	ope_n	= ~ope;
	assign	jcn_isz	= jcn | isz;
	assign	jun_jms = jun | jms;
	wire	ldm_bbl = ldm | bbl;
	assign	inc_isz	= (inc | isz) & sc;
	assign	inc_isz_xch = inc | isz | xch;
	assign	inc_isz_add_sub_xch_ld = inc | isz | add | sub | xch | ld;
	assign	fin_fim_src_jin = fim_src | jin_fin;
	
	// OPE: OPA Decoding
	assign	o_ib	= ope & (opa[3] == 1'b0);
	wire	clb		= ope & (opa == 4'b0000);
	wire	clc		= ope & (opa == 4'b0001);
	wire	iac		= ope & (opa == 4'b0010);
	wire	cmc		= ope & (opa == 4'b0011);
	assign	cma		= ope & (opa == 4'b0100);
	assign	ral		= ope & (opa == 4'b0101);
	assign	rar		= ope & (opa == 4'b0110);
	wire	tcc		= ope & (opa == 4'b0111);
	
	wire	dac		= ope & (opa == 4'b1000);
	assign	tcs		= ope & (opa == 4'b1001);
	wire	stc		= ope & (opa == 4'b1010);
	assign	daa		= ope & (opa == 4'b1011);
	assign	kbp		= ope & (opa == 4'b1100);
	assign	dcl		= ope & (opa == 4'b1101);

	// IO: OPA Decoding
	assign	iow		= io & (opa[3] == 1'b0);
	assign	ior		= io & (opa[3] == 1'b1);
	wire	adm		= io & (opa == 4'b1011);
	wire	sbm		= io & (opa == 4'b1000);

	wire	fin_fim = fin_fim_src_jin & ~opa[0];
	wire	src		= fim_src & opa[0];
	
	assign	write_acc_1		= ~(kbp | tcs | daa | xch | poc | cma | tcc | dac | iac |
								clb | ior | ld  | sub | add | ldm_bbl);
	assign	write_carry_2	= ~(tcs | poc | tcc | stc | cmc | dac | iac |
								clc | clb | sbm | adm | sub | add);
	assign	read_acc_3		= ~(daa | rar | ral | dac | iac | sbm | adm | sub | add);
	assign	add_group_4		= ~(tcs | tcc | adm | add);
	assign	inc_group_5		= ~(inc_isz | stc | iac);
	assign	sub_group_6		= ~(cmc | sbm | sub | m12);

	// The Condition Flip-Flop
	reg  n0397;
	wire n0486 = ~((opa[2] & acc_0) | (opa[1] & cy_1) | (opa[0] & n0432));
	wire n0419 = ~((add_0 & ~isz) & (~jcn | ((~n0486 | opa[3]) & (n0486 | ~opa[3]))));
	wire n0413 = ~((sc & n0419 & x32) | (~x32 | n0397));
	reg  n0405;
	always @(posedge sysclk) begin
		if (clk2)
			n0405 <= n0413;
		if (clk1)
			n0397 <= ~n0405;
	end
	assign cn_n = ~n0397;

	// The Single-Cycle Flip-Flop
	reg  n0343;
	wire n0368 = ~((sc & (fin_fim | jcn_isz | jun_jms) & x32) | (n0343 & ~x32));
	reg  n0362;
	always @(posedge sysclk) begin
		if (clk2)
			n0362 <= n0368;
		if (clk1)
			n0343 <= ~n0362;
	end
	assign sc = ~n0343;
	assign dc = ~sc;

	// Generate ~(X21&~CLK2)
	reg n0360;
	always @(posedge sysclk) begin
		if (clk2)
			n0360 <= ~x12;
	end
	wire n0337 = ~(n0360 | clk2);
	assign x21_clk2 = ~n0337;

	// Generate ~(X31&~CLK2)
	reg n0380;
	always @(posedge sysclk) begin
		if (clk2)
			n0380 <= ~x22;
	end
	wire n0375 = ~(n0380 | clk2);
	assign x31_clk2 = ~n0375;
	
	// Generate ~COM
	wire n0329 = io;

	reg n0414, n0797;
	always @(posedge sysclk) begin
		if (clk2)
			n0414 <= a22;
		else
			n0797 <= n0414;
	end

	reg n0433, n0801;
	always @(posedge sysclk) begin
		if (clk2)
			n0433 <= m12;
		else
			n0801 <= n0433;
	end
	
	reg n0425, n0805;
	always @(posedge sysclk) begin
		if (clk2)
			n0425 <= x12;
		else
			n0805 <= n0425;
	end

	wire n0782 = ~((n0801 & n0329) | (src & n0805) | n0797);
	assign com_n = n0782;
	
	// Generate N0342
	wire n0332 = ~(((n0329 | poc) & x22 & clk2) | (~(n0329 | poc) & n0337 & clk1));
	assign n0342 = n0332;

	// Output OPA onto the data bus
	wire opa_ib = (ldm_bbl | jun_jms) & ~x21_clk2;
	assign data = opa_ib ? opa : 4'bzzzz;

endmodule
