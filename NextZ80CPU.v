//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the NextZ80 project
// http://www.opencores.org/cores/nextz80/
//
// Filename: NextZ80CPU.v
// Description: Implementation of Z80 compatible CPU
// Version 1.0
// Creation date: 28Jan2011 - 18Mar2011
//
// Author: Nicolae Dumitrache 
// e-mail: ndumitrache@opencores.org
//
/////////////////////////////////////////////////////////////////////////////////
// 
// Copyright (C) 2011 Nicolae Dumitrache
// 
// This source file may be used and distributed without 
// restriction provided that this copyright statement is not 
// removed from the file and that any derivative work contains 
// the original copyright notice and the associated disclaimer.
// 
// This source file is free software; you can redistribute it 
// and/or modify it under the terms of the GNU Lesser General 
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any 
// later version. 
// 
// This source is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied 
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
// PURPOSE. See the GNU Lesser General Public License for more 
// details. 
// 
// You should have received a copy of the GNU Lesser General 
// Public License along with this source; if not, download it 
// from http://www.opencores.org/lgpl.shtml 
// 
///////////////////////////////////////////////////////////////////////////////////
//
// Comments:
// This project was developed and tested on a XILINX Spartan3AN board.
//
//	NextZ80 processor features:
//		All documented/undocumented intstructions are implemented
//		All documented/undocumented flags are implemented
//		All (doc/undoc)flags are changed accordingly by all (doc/undoc)instructions. 
//			The block instructions (LDx, CPx, INx, OUTx) have only the documented effects on flags. 
//			The Bit n,(IX/IY+d) and BIT n,(HL) undocumented flags XF and YF are implemented like the BIT n,r and not actually like on the real Z80 CPU.
//		All interrupt modes implemented: NMI, IM0, IM1, IM2
//		R register available
//		Fast conditional jump/call/ret takes only 1 T state if not executed
//		Fast block instructions: LDxR - 3 T states/byte, INxR/OTxR - 2 T states/byte, CPxR - 4 T states / byte
//		Each CPU machine cycle takes (mainly) one clock T state. This makes this processor over 4 times faster than a Z80 at the same 
//			clock frequency (some instructions are up to 10 times faster). 
//		Works at ~40MHZ on Spartan XC3S700AN speed grade -4)
//		Small size ( ~12%  ~700 slices - on Spartan XC3S700AN )
//		Tested with ZEXDOC (fully compliant).
//		Tested with ZEXALL (all OK except CPx(R), LDx(R), BIT n, (IX/IY+d), BIT n, (HL) - fail because of the un-documented XF and YF flags).
// 
///////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NextZ80
(
		input wire[7:0] DI,
		output wire[7:0] DO,
		output wire[15:0] ADDR,
		output reg WR,
		output reg MREQ,
		output reg IORQ,
		output reg HALT,
		output reg M1,
		input wire CLK,
		input wire RESET,
		input wire INT,
		input wire NMI,
		input	wire WAIT
);

// connections and registers
	reg	[9:0] CPUStatus = 0;	// 0=AF-AF', 1=HL-HL', 2=DE-HL, 3=DE'-HL', 4=HL-X, 5=IX-IY, 6=IFF1,7=IFF2, 9:8=IMODE
	wire	[7:0] ALU8FLAGS;
	wire	[7:0]	FLAGS;
	wire 	[7:0] ALU80;
	wire 	[7:0] ALU81;
	wire 	[15:0]ALU160;
	wire 	[7:0] ALU161;
	wire	[15:0]ALU8OUT;

	reg 	[9:0]	FETCH = 0;
	reg 	[2:0]	STAGE = 0;
	wire	[5:0]	opd;
	wire	[2:0] op16;
	wire	op0mem = FETCH[2:0] == 6;
	wire	op1mem = FETCH[5:3] == 6;
	reg	[1:0]fetch98;

// stage status
	reg	[1:0]DO_SEL;			// ALU80 - th - flags - ALU8OUT[7:0]
	reg	ALU160_SEL;				// regs - pc
	reg	DINW_SEL;				// ALU8OUT - DI
	reg 	[5:0]WE;					// 5 = flags, 4 = PC, 3 = SP, 2 = tmpHI, 1 = hi, 0 = lo
	reg 	[4:0] ALU8OP;
	reg 	[2:0] ALU16OP;
	reg 	next_stage;
	reg 	[3:0]REG_WSEL;
	reg 	[3:0]REG_RSEL;
	reg	[11:0]status;			// 0=AF-AF', 1=HL-HL', 2=DE-HL, 3=DE'-HL', 4=HL-X, 5=IX-IY, 7:6=IFFVAL, 9:8=imode, 10=setIMODE, 11=set IFFVAL
// FETCH[5:3]: 000 NZ, 001 Z, 010 NC, 011 C, 100 PO, 101 PE, 110 P, 111 M
	wire	[7:0]FlagMux = {FLAGS[7], !FLAGS[7], FLAGS[2], !FLAGS[2], FLAGS[0], !FLAGS[0], FLAGS[6], !FLAGS[6]};
	reg	tzf;
	reg 	FNMI = 0, SNMI = 0;
	reg 	SRESET = 0;
	reg	SINT = 0;
	wire	[2:0]intop = FETCH[1] ? 4 : (FETCH[0] ? 5 : 6);
	reg 	xmask;

	Z80Reg CPU_REGS (
		 .rstatus(CPUStatus[7:0]), 
		 .M1(M1), 
		 .WE(WE), 
		 .CLK(CLK), 
		 .ALU8OUT(ALU8OUT), 
		 .DI(DI), 
		 .DO(DO), 
		 .ADDR(ADDR), 									
		 .CONST(FETCH[7] ? {2'b00, FETCH[5:3], 3'b000} : 8'h66),	// RST/NMI address
		 .ALU80(ALU80), 
		 .ALU81(ALU81), 
		 .ALU160(ALU160), 
		 .ALU161(ALU161), 
		 .ALU8FLAGS(ALU8FLAGS), 
		 .FLAGS(FLAGS),
		 .DO_SEL(DO_SEL), 
		 .ALU160_sel(ALU160_SEL), 
		 .REG_WSEL(REG_WSEL), 
		 .REG_RSEL(REG_RSEL), 
		 .DINW_SEL(DINW_SEL),
		 .XMASK(xmask),
		 .ALU16OP(ALU16OP),			// used for post increment for ADDR, SP mux re-direct
		 .WAIT(WAIT)
		 );

	ALU8 CPU_ALU8 (
		 .D0(ALU80), 
		 .D1(ALU81), 
		 .FIN(FLAGS), 
		 .FOUT(ALU8FLAGS), 
		 .ALU8DOUT(ALU8OUT), 
		 .OP(ALU8OP),
		 .EXOP(FETCH[8:3]),
		 .LDIFLAGS(REG_WSEL[2]),	// inc16 HL
		 .DSTHI(!REG_WSEL[0])
		 );

	ALU16 CPU_ALU16 (
		 .D0(ALU160), 
		 .D1(ALU161), 
		 .DOUT(ADDR), 
		 .OP(ALU16OP)
		 );

	always @(posedge CLK)
		if(!WAIT) begin
			SRESET <= RESET;
			SNMI <= NMI;
			SINT <= INT;
			if(!SNMI) FNMI <= 0; 
			if(SRESET) FETCH <= 10'b1110000000;
			else 
				if(FETCH[9:6] == 4'b1110) {FETCH[9:7]} <= 3'b000;	// exit RESET state
				else begin 
					if(M1)
						case({MREQ, CPUStatus[9:8]})
							3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111: FETCH <= {fetch98, DI};
							3'b010: FETCH <= {fetch98, 8'hff};	// IM1 - RST38
							3'b011: ; // IM2 - get addrLO
						endcase
					if(~|{next_stage, fetch98[1:0], status[4]})				// INT or NMI sample
						if(SNMI & !FNMI) begin						// NMI posedge
							{FETCH[9:6], FETCH[1:0]} <= {4'b1101, HALT, M1};
							FNMI <= 1;	// NMI acknowledged
						end else if(SINT & CPUStatus[6] & !status[11]) {FETCH[9:6], FETCH[1:0]} <= {4'b1100, HALT, M1};	// INT request
				end
			if(next_stage) STAGE <= STAGE + 3'b001;
			else STAGE <= 0;
			if(status[4]) CPUStatus[5:4] <= status[5:4];
			else if(~|{next_stage, fetch98[1]} | fetch98[0]) CPUStatus[4] <= 1'b0;		// clear X
			CPUStatus[3:0] <= CPUStatus[3:0] ^ status[3:0];
			if(status[11]) CPUStatus[7:6] <= status[7:6]; 	// IFF2:1
			if(status[10]) CPUStatus[9:8] <= status[9:8];	// IMM
			tzf <= ALU8FLAGS[6];
		end

	assign opd[0] = FETCH[0] ^ &FETCH[2:1];
	assign opd[2:1] = FETCH[2:1];
	assign opd[3] = FETCH[3] ^ &FETCH[5:4];
	assign opd[5:4] = FETCH[5:4];
	assign op16[2:0] = &FETCH[5:4] ? 3'b101 : {1'b0, FETCH[5:4]};

	always @* begin
		DO_SEL	= 2'bxx;						// ALU80 - th - flags - ALU8OUT[7:0]
		ALU160_SEL = 1'bx;					// regs - pc
		DINW_SEL = 1'bx;						// ALU8OUT - DI
		WE 		= 6'bxxxxxx;				// 5 = flags, 4 = PC, 3 = SP, 2 = tmpHI, 1 = hi, 0 = lo
		ALU8OP	= 5'bxxxxx;
		ALU16OP	= 3'b000;					// NOP, post inc
		next_stage = 0;
		REG_WSEL	= 4'bxxxx;
		REG_RSEL	= 4'bxxxx;
		M1 		= 1;
		MREQ		= 1;
		WR			= 0;

		HALT = 0;
		IORQ = 0;
		status	= 12'b00xxxxx00000;
		fetch98 = 2'b00;
		
		case({FETCH[7:6], op1mem, op0mem})
			4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b1000, 4'b1100: xmask = 1;
			default: xmask = 0;
		endcase
		
		case(FETCH[9:6])	
//------------------------------------------- block 00 ----------------------------------------------------
			4'b0000:
				case(FETCH[3:0])
//				-----------------------		NOP, EX AF, AF', DJNZ, JR, JR c --------------------
					4'b0000, 4'b1000:	
						case(FETCH[5:4])
							2'b00: begin					// NOP, EX AF, AF'
								DO_SEL	= 2'bxx;			
								ALU160_SEL = 1;			// PC
								WE 		= 6'b010x00;	// PC
								status[0] = FETCH[3];
							end
							2'b01:				
								if(!STAGE[0]) begin		// DJNZ, JR - stage1
									ALU160_SEL = 1;				// pc
									WE 		= 6'b010100;		// PC, tmpHI
									if(!FETCH[3]) begin
										ALU8OP	= 5'b01010;			// DEC, for tzf only
										REG_WSEL	= 4'b0000;			// B
									end
									next_stage = 1;
									M1 		= 0;
								end else if(FETCH[3]) begin	// JR - stage2
									ALU160_SEL = 1;				// pc
									WE 		= 6'b010x00;		// PC
									ALU16OP	= 3;					// ADD
								end else begin				// DJNZ - stage2
									ALU160_SEL = 1;				// pc
									DINW_SEL = 0;					// ALU8OUT
									WE 		= 6'b010x10;		// PC, hi
									ALU8OP	= 5'b01010;			// DEC
									ALU16OP	= tzf ? 3'd0 : 3'd3;		// NOP/ADD
									REG_WSEL	= 4'b0000;			// B
								end
							2'b10, 2'b11: 							// JR cc, stage1, stage2
								case({STAGE[0], FlagMux[{1'b0, FETCH[4:3]}]})
									2'b00, 2'b11: begin
										ALU160_SEL = 1;				// pc
										WE 		= 6'b010x00;		// PC
										ALU16OP	= STAGE[0] ? 3'd3 : 3'd1;		// ADD/ INC, post inc
									end 
									2'b01: begin
										ALU160_SEL = 1;				// pc
										WE 		= 6'b010100;		// PC, tmpHI
										next_stage = 1; 
										M1 		= 0;
									end
								endcase
						endcase
//				-----------------------		LD rr,nn  --------------------
					4'b0001: 			// LD rr,nn, stage1
						case({STAGE[1:0], op16[2]})
							3'b00_0, 3'b00_1, 3'b01_0, 3'b01_1: begin			// LD rr,nn, stage1,2
								ALU160_SEL = 1;			// pc
								DINW_SEL = 1;				// DI
								WE 		= {4'b010x, STAGE[0] ? 1'b1 : 1'bx, !STAGE[0]};	// PC, lo/HI
								next_stage = 1;
								REG_WSEL	= {op16, 1'bx}; 
								M1 		= 0;
							end
							3'b10_0, 3'b11_1: begin		// BC, DE, HL, stage3, SP stage4
								ALU160_SEL = 1;			// pc
								WE 		= 6'b010x00;	// PC
							end
							3'b10_1: begin				// SP stage3
								ALU160_SEL = 0;			// regs
								WE 		= 6'b001x00;	// SP
								ALU16OP	= 4;				// NOP
								next_stage = 1;
								REG_RSEL	= 4'b101x;		// tmpSP
								M1 		= 0;
								MREQ		= 0;
							end
						endcase
//				-----------------------		LD (BC) A -  LD (DE) A - LD (nn) HL, LD (nn),A   --------------------
//				-----------------------		LD A (BC) -  LD A (DE) - LD HL (nn), LD A (nn)   --------------------
					4'b0010,	4'b1010:
						case(STAGE[2:0])
							3'b000:
								if(FETCH[5] == 0) begin			// LD (BC) A, LD (DE) A - stage1
									if(FETCH[3]) DINW_SEL = 1;		// DI
									else DO_SEL	= 2'b00;				// ALU80
									ALU160_SEL = 0;				// regs
									WE 		= {4'b000x, FETCH[3], 1'bx};		// hi
									next_stage = 1;
									REG_WSEL	= FETCH[3] ? 4'b011x : 4'b0110;	// A
									REG_RSEL	= {op16, 1'bx};
									M1 		= 0;
									WR = !FETCH[3];
								end else begin						// LD (nn) A - LD (nn) HL - stage 1
									ALU160_SEL = 1;				// PC
									DINW_SEL = 1;					// DI
									WE 		= 6'b010xx1;		// PC, lo
									next_stage = 1;
									REG_WSEL	= 4'b111x;
									M1 		= 0;
								end
							3'b001:
								if(FETCH[5] == 0) begin			// LD (BC), A, LD (DE), A - stage2
									ALU160_SEL = 1;				// pc
									WE 		= 6'b010x00;		// PC
								end else begin						// LD (nn),A  - LH (nn),HL - stage 2
									ALU160_SEL = 1;				// pc
									DINW_SEL = 1;					// DI
									WE 		= 6'b010x10;		// PC, hi
									next_stage = 1;
									REG_WSEL	= 4'b111x;
									M1 		= 0;
								end
							3'b010: begin					
								ALU160_SEL = 1'b0;		// regs
								REG_RSEL	= 4'b111x;
								M1 		= 0;
								WR			= !FETCH[3];
								next_stage = 1;
								if(FETCH[3]) begin		// LD A (nn)  - LD HL (nn) - stage 3
									DINW_SEL = 1;				// DI
									WE 		= {4'b000x, FETCH[4] ? 1'b1 : 1'bx, FETCH[4] ? 1'bx : 1'b1};	// lo/hi
									REG_WSEL = FETCH[4] ? 4'b011x : 4'b010x;	// A or L
								end else begin				// LD (nn),A  - LD (nn),HL - stage 3
									DO_SEL	= 2'b00;			// ALU80
									WE 		= 6'b000x00;	// nothing
									REG_WSEL = FETCH[4] ? 4'b0110 : 4'b0101;	// A or L
								end
							end
							3'b011:
								if(FETCH[4]) begin			// LD (nn),A - stage 4
									ALU160_SEL = 1;			// pc
									WE 		= 6'b010x00;	// PC
								end else begin					
									REG_RSEL	= 4'b111x;
									M1 		= 0;
									WR			= !FETCH[3];
									ALU160_SEL = 1'b0;		// regs
									ALU16OP	= 1;				// INC
									next_stage = 1;
									if(FETCH[3]) begin	// LD HL (nn) - stage 4
										DINW_SEL = 1;				// DI
										WE 		= 6'b000x10;	// hi
										REG_WSEL = 4'b010x;		// H
									end else begin			// LD (nn),HL - stage 4
										DO_SEL	= 2'b00;			// ALU80
										WE 		= 6'b000x00;	// nothing
										REG_WSEL = 4'b0100;		// H
									end
								end
							3'b100: begin				// LD (nn),HL - stage 5
								ALU160_SEL = 1;			// pc
								WE 		= 6'b010x00;	// PC
							end
						endcase
//				-----------------------		inc/dec rr   --------------------
					4'b0011, 4'b1011:
						if(!STAGE[0])
							if(op16[2]) begin				// SP - stage1
								ALU160_SEL = 0;			// regs
								WE 		= 6'b001x00;	// SP
								ALU16OP	= {FETCH[3], 1'b0, FETCH[3]};		// post inc, dec
								next_stage = 1;
								REG_RSEL	= 4'b101x;		// sp
								M1 		= 0;
								MREQ		= 0;
							end else begin					// BC, DE, HL - stage 1
								ALU160_SEL = 1;			// pc
								DINW_SEL = 0;				// ALU8OUT
								WE 		= 6'b010x11;	// PC, hi, lo
								ALU8OP	= {4'b0111, FETCH[3]};			// INC16 / DEC16
								REG_WSEL	= {op16, 1'b0};	// hi
								REG_RSEL	= {op16, 1'b1};	// lo
							end
						else 	begin				// SP, stage2
							ALU160_SEL = 1;			// pc
							WE 		= 6'b010x00;	// PC
						end
//				-----------------------		inc/dec 8  --------------------
					4'b0100, 4'b0101, 4'b1100, 4'b1101: 
						if(!op1mem) begin						//regs
							DINW_SEL = 0;						// ALU8OUT
							ALU160_SEL = 1;					// pc
							WE 		= opd[3] ? 6'b110x01 : 6'b110x10;	// flags, PC, hi/lo
							ALU8OP	= {3'b010, FETCH[0], 1'b0};		// inc / dec
							REG_WSEL	= {1'b0, opd[5:3]};
						end else case({STAGE[1:0], CPUStatus[4]})
							3'b00_0, 3'b01_1: begin				// (HL) - stage1, (X) - stage2
								ALU160_SEL = 0;					// regs
								DINW_SEL = 1;						// DI
								WE 		= 6'b000001;			// lo
								ALU16OP	= CPUStatus[4] ? 3'd3 : 3'd0;
								next_stage = 1;
								REG_WSEL	= 4'b011x;				// tmpLO
								REG_RSEL	= 4'b010x;				// HL
								M1 		= 0;
							end
							3'b00_1:	begin							// (X) - stage1
								ALU160_SEL = 1;					// pc
								WE 		= 6'b010100;			// PC, tmpHI
								next_stage = 1;
								M1 		= 0;
							end 
							3'b01_0, 3'b10_1: begin					// (HL) stage2, (X) - stage3
								DO_SEL	= 2'b11;						// ALU80OUT
								ALU160_SEL = 0;						// regs
								WE 		= 6'b100x0x;				// flags
								ALU8OP	= {3'b010, FETCH[0], 1'b0};		// inc / dec
								ALU16OP	= CPUStatus[4] ? 3'd3 : 3'd0;
								next_stage = 1;
								REG_WSEL	= 4'b0111;					// tmpLO
								REG_RSEL	= 4'b010x;					// HL
								M1 		= 0;
								WR			= 1;
							end
							3'b10_0, 3'b11_1: begin					// (HL) - stage3, (X) - stage 4
								ALU160_SEL = 1;						// pc
								WE 		= 6'b010x00;				// PC
							end
						endcase
//				-----------------------		ld r/(HL-X), n  --------------------						
					4'b0110, 4'b1110: 				
						case({STAGE[1:0], CPUStatus[4], op1mem})
							4'b00_0_0, 4'b00_0_1, 4'b00_1_0, 4'b01_1_1: begin		// r, (HL) - stage1, (X) - stage2 (read n)
								ALU160_SEL = 1;					// pc
								DINW_SEL = 1;						// DI
								WE 		= opd[3] ? 6'b010001 : 6'b010010;			// PC, hi/lo
								next_stage = 1;
								REG_WSEL	= {1'b0, opd[5:4], 1'bx};
								M1 		= 0;
							end
							4'b01_0_0, 4'b01_1_0, 4'b10_0_1, 4'b11_1_1: begin		// r - stage2, (HL) - stage3, (X) - stage4
								ALU160_SEL = 1;						// pc
								WE 		= 6'b010x00;				// PC
							end
							4'b01_0_1, 4'b10_1_1: begin			// (HL) - stage2, (X) - stage3
								DO_SEL	= 2'b00;						// ALU80
								ALU160_SEL = 0;						// regs
								WE 		= 6'b000x0x;				// nothing
								ALU16OP	= CPUStatus[4] ? 3'd3 : 3'd0;
								next_stage = 1;
								REG_WSEL	= 4'b0111;					// tmpLO
								REG_RSEL	= 4'b010x;					// HL
								M1 		= 0;
								WR			= 1;
							end
							4'b00_1_1: begin							// (X) - stage1
								ALU160_SEL = 1;						// pc
								WE 		= 6'b010100;				// PC, tmpHI
								next_stage = 1;
								M1 		= 0;
							end
						endcase
//				-----------------------		rlca, rrca, rla, rra, daa, cpl, scf, ccf  --------------------						
					4'b0111, 4'b1111: 				
						case(FETCH[5:3])
							3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101: begin		// rlca, rrca, rla, rra, daa, cpl
								ALU160_SEL = 1;					// pc
								DINW_SEL = 0;						// ALU8OUT
								WE 		= 6'b110x1x;			// flags, PC, hi
								ALU8OP	= FETCH[5] ? {2'b01, !FETCH[3], 2'b01} : {3'b110, FETCH[4:3]};
								REG_WSEL	= 4'b0110;				// A
							end
							3'b110, 3'b111:	begin				// scf, ccf
								ALU160_SEL = 1;					// pc
								DINW_SEL = 0;						// ALU8OUT
								WE 		= 6'b110x0x;			// flags, PC
								ALU8OP	= {4'b1010, !FETCH[3]};
							end
						endcase
//				-----------------------		add 16  --------------------						
					4'b1001: 
						if(!STAGE[0]) begin
							DINW_SEL = 0;						// ALU8OUT
							WE 		= 6'b100x01;			// flags, lo
							ALU8OP	= 5'b10000;				// ADD16LO
							next_stage = 1;
							REG_WSEL	= 4'b0101;				// L
							REG_RSEL	= {op16, 1'b1};
							M1 		= 0;
							MREQ		= 0;
						end else begin
							ALU160_SEL = 1;					// pc
							DINW_SEL = 0;						// ALU8OUT
							WE 		= 6'b110x10;			// flags, PC, hi
							ALU8OP	= 5'b10001;				// ADD16HI
							REG_WSEL	= 4'b0100;				// H
							REG_RSEL	= {op16, 1'b0};
						end
				endcase

// ---------------------------------------------- block 01 LD8 ---------------------------------------------------
			4'b0001:	
				case({STAGE[1:0], CPUStatus[4], op1mem, op0mem})
					5'b00_0_00, 5'b00_1_00,		// LD r, r 1st stage
					5'b01_0_01,						// LD r, (HL) 2nd stage
					5'b10_1_01:						// LD r, (X) 3rd stage
					begin	
						ALU160_SEL = 1;			// PC
						DINW_SEL	  = 0;			// ALU8
						WE = opd[3] ? 6'b010x01 : 6'b010x10;	// PC and LO or HI
						ALU8OP = 29;				// PASS D1
						REG_WSEL = {1'b0, opd[5:4], 1'bx};
						REG_RSEL = {1'b0, opd[2:0]};
					end
					5'b00_0_01,						// LD r, (HL) 1st stage
					5'b01_1_01:						// LD r, (X) 2nd stage
					begin	
						ALU160_SEL = 0;			// regs
						DINW_SEL = 1;				// DI		
						WE 		= 6'b000x01;	// LO
						ALU16OP	= CPUStatus[4] ? 3'd3 : 3'd0;		// ADD - NOP
						next_stage = 1;
						REG_WSEL	= 4'b011x;		// A - tmpLO
						REG_RSEL = 4'b010x;		// HL
						M1 = 0;
					end
					5'b00_1_01,						// LD r, (X) 1st stage
					5'b00_1_10:						// LD (X), r 1st stage
					begin
						ALU160_SEL = 1;			// pc
						WE 		= 6'b010100;	// PC, tmpHI
						next_stage = 1;
						M1 		= 0;
					end
					5'b00_0_10, 					// LD (HL), r 1st stage
					5'b01_1_10:						// LD (X), r 2nd stage
					begin	
						DO_SEL	= 0;				// ALU80
						ALU160_SEL = 0;			// regs
						WE 		= 6'b000x00;	// no write
						ALU16OP	= CPUStatus[4] ? 3'd3 : 3'd0;			// ADD - NOP
						next_stage = 1;
						REG_WSEL	= {1'b0, opd[2:0]};
						REG_RSEL	= 4'b010x;		// HL
						M1 		= 0;
						WR			= 1;			
					end
					5'b01_0_10, 					// LD (HL), r 2nd stage
					5'b10_1_10:						// LD (X), r 3rd stage
					begin	
						ALU160_SEL = 1;			// pc
						WE 		= 6'b010x00;	// PC
					end
					5'b00_0_11, 5'b00_1_11: begin	// HALT
						WE 		= 6'b000x00;	// no write
						M1 		= 0;
						MREQ		= 0;
						HALT 		= 1;
					end
				endcase
// ---------------------------------------------- block 10 arith8 ---------------------------------------------------
			4'b0010:	
				case({STAGE[1:0], CPUStatus[4], op0mem})
					4'b00_0_0, 4'b00_1_0,		// OP r,r 1st stage
					4'b01_0_1,						// OP r, (HL) 2nd stage
					4'b10_1_1:						// OP r, (X) 3rd stage
					begin
						ALU160_SEL = 1;			// pc
						DINW_SEL = 0;				// ALU8OUT
						WE 		= {4'b110x, ~&FETCH[5:3], 1'bx};	// flags, PC, hi
						ALU8OP	= {2'b00, FETCH[5:3]};
						REG_WSEL	= 4'b0110;		// A
						REG_RSEL	= {1'b0, opd[2:0]};
					end
					4'b00_0_1,						// OP r, (HL) 1st stage
					4'b01_1_1:						// OP r, (X) 2nd stage
					begin
						ALU160_SEL = 0;			// HL
						DINW_SEL = 1;				// DI
						WE 		= 6'b000x01;	// lo
						ALU16OP	= CPUStatus[4] ? 3'd3 : 3'd0;			// ADD - NOP
						next_stage = 1;
						REG_WSEL	= 4'b011x;		// A-tmpLO
						REG_RSEL	= 4'b010x;		// HL
						M1 		= 0;
					end
					4'b00_1_1:						// OP r, (X) 1st stage
					begin
						ALU160_SEL = 1;			// pc
						WE 		= 6'b010100;	// PC, tmpHI
						next_stage = 1;
						M1 		= 0;
					end
				endcase
//------------------------------------------- block 11 ----------------------------------------------------
			4'b0011:
				case(FETCH[3:0])
//				-----------------------		RET cc --------------------
					4'b0000, 4'b1000:
						case(STAGE[1:0])
							2'b00, 2'b01:			// stage1, stage2
								if(FlagMux[FETCH[5:3]]) begin	// POP addr
									ALU160_SEL = 0;				// regs
									DINW_SEL = 1;					// DI
									WE 		= {4'b001x, STAGE[0] ? 1'b1 : 1'bx, !STAGE[0]};		// SP, lo/hi
									next_stage = 1;
									REG_WSEL	= 4'b111x;			// tmp16
									REG_RSEL	= 4'b101x;			// SP
									M1 		= 0;
								end else begin
									ALU160_SEL = 1;				// pc
									WE 		= 6'b010x00;		// PC
								end
							2'b10: begin			// stage3
								ALU160_SEL = 0;					// regs
								WE 		= 6'b010x00;			// PC
								REG_RSEL	= 4'b111x;				// tmp16
							end
						endcase
//				-----------------------		POP --------------------
					4'b0001:
						case(STAGE[1:0])
							2'b00, 2'b01: begin
								if(op16[2]) begin	// AF
									WE 		= STAGE[0] ? 6'b101x1x : 6'b001xx1;		// flags, SP, lo/hi
									REG_WSEL	= {3'b011, STAGE[0] ? 1'b1 : 1'bx};
									if(STAGE[0]) ALU8OP	= 30;						// FLAGS <- D0
								end else begin		// r16
									WE 		= STAGE[0] ? 6'b001x10 : 6'b001xx1;		// SP, lo/hi
									REG_WSEL	= {1'b0, FETCH[5:4], 1'bx};
								end
								ALU160_SEL = 0;			// regs
								DINW_SEL = 1;				// DI
								next_stage = 1;
								REG_RSEL	= 4'b101x;		// SP
								M1 		= 0;
							end
							2'b10: begin					// stage3
								ALU160_SEL = 1;			// PC
								WE 		= 6'b010x00;	// PC
							end
						endcase
//				-----------------------		JP cc --------------------
					4'b0010, 4'b1010:
						case(STAGE[1:0])
							2'b00, 2'b01:	begin				// stage1,2
								if(FlagMux[FETCH[5:3]]) begin
									ALU160_SEL = 1;					// pc
									DINW_SEL = 1;						// DI
									WE 		= {4'b010x, STAGE[0] ? 1'b1 : 1'bx, !STAGE[0]};		// PC, hi/lo
									next_stage = 1;
									REG_WSEL	= 4'b111x;				// tmp7
									M1 		= 0;
								end else begin
									ALU160_SEL = 1;					// pc
									WE 		= 6'b010x00;			// PC
									ALU16OP	= 2;						// add2
								end
							end
							2'b10: begin						// stage3
								ALU160_SEL = 0;					// regs
								WE 		= 6'b010x00;			// PC
								REG_RSEL	= 4'b111x;				// tmp7
							end
						endcase
//				-----------------------		JP, OUT (n) A, EX (SP) HL, DI --------------------
					4'b0011:
						case(FETCH[5:4])
							2'b00:					// JP
								case(STAGE[1:0])
									2'b00, 2'b01:	begin				// stage1,2 - read addr
										ALU160_SEL = 1;					// pc
										DINW_SEL = 1;						// DI
										WE 		= {4'b010x, STAGE[0] ? 1'b1 : 1'bx, !STAGE[0]};		// PC, hi/lo
										next_stage = 1;
										REG_WSEL	= 4'b111x;				// tmp7
										M1 		= 0;
									end
									2'b10: begin						// stage3
										ALU160_SEL = 0;					// regs
										WE 		= 6'b010x00;			// PC
										REG_RSEL	= 4'b111x;				// tmp7
									end
								endcase
							2'b01: 					// OUT (n), a - stage1 - read n
								case(STAGE[1:0])
									2'b00: begin
										ALU160_SEL = 1;					// pc
										DINW_SEL = 1;						// DI
										WE 		= 6'b010x01;			// PC, lo
										next_stage = 1;
										REG_WSEL	= 4'b011x;				// tmpLO
										M1 		= 0;
									end
									2'b01: begin		// stage2 - OUT
										DO_SEL	= 2'b00;					// ALU80
										ALU160_SEL = 0;					// regs
										WE 		= 6'b000x00;			// nothing
										next_stage = 1;
										REG_WSEL	= 4'b0110;				// A
										REG_RSEL	= 4'b011x;				// A-tmpLO
										M1 		= 0;
										MREQ		= 0;
										WR 		= 1;
										IORQ		= 1;
									end
									2'b10: begin		// stage3 - fetch
										ALU160_SEL = 1;			// PC
										WE 		= 6'b010x00;	// PC
									end
								endcase
							2'b10:				// EX (SP), HL
								case(STAGE[2:0])
									3'b000, 3'b001:	begin			// stage1,2 - pop tmp16
										ALU160_SEL = 0;					// regs
										DINW_SEL = 1;						// DI
										WE 		= {4'b001x, STAGE[0] ? 1'b1 : 1'bx, !STAGE[0]};			// SP, lo/hi
										next_stage = 1;
										REG_WSEL	= 4'b111x;				// tmp16
										REG_RSEL	= 4'b101x;				// SP
										M1 		= 0;
									end
									3'b010, 3'b011: begin			// stage3,4 - push hl
										DO_SEL	= 2'b00;					// ALU80
										ALU160_SEL = 0;					// regs
										WE 		= 6'b001x00;			// SP
										ALU16OP	= 5;						// dec
										next_stage = 1;
										REG_WSEL	= {3'b010, STAGE[0]};// H/L	
										REG_RSEL	= 4'b101x;				// SP
										M1 		= 0;
										WR			= 1;
									end
									3'b100, 3'b101: begin		// stage5,6
										ALU160_SEL = 1;					// pc
										DINW_SEL = 0;						// ALU8OUT
										WE 		= {1'b0, STAGE[0], 2'b0x, STAGE[0] ? 1'b1 : 1'bx, !STAGE[0]};	// PC, lo/hi
										ALU8OP	= 29;		// pass D1
										next_stage = !STAGE[0];
										REG_WSEL	= 4'b010x;		// HL
										REG_RSEL	= {3'b111, !STAGE[0]};		// tmp16
										M1 		= STAGE[0];
										MREQ		= STAGE[0];
									end
								endcase
							2'b11:	begin			// DI
								ALU160_SEL = 1;			// PC
								WE 		= 6'b010x00;	// PC
								status[11] = 1'b1;		// set IFF flags
								status[7:6] = 2'b00;
							end
						endcase
//				-----------------------		CALL cc --------------------
					4'b0100, 4'b1100:	
						case(STAGE[2:0])
							3'b000, 3'b001:		// stage 1,2 - load addr
								if(FlagMux[FETCH[5:3]]) begin
									ALU160_SEL = 1;					// pc
									DINW_SEL = 1;						// DI
									WE 		= {4'b010x, STAGE[0] ? 1'b1 : 1'bx, !STAGE[0]};		// PC, hi/lo
									next_stage = 1;
									REG_WSEL	= 4'b111x;				// tmp7
									M1 		= 0;
								end else begin
									ALU160_SEL = 1;					// pc
									WE 		= 6'b010x00;			// PC
									ALU16OP	= 2;						// add2
								end
							3'b010, 3'b011: begin		// stage 3,4 - push pc
								DO_SEL	= {1'b0, STAGE[0]};	// pc hi/lo
								ALU160_SEL = 0;					// regs
								WE 		= 6'b001x00;			// SP
								ALU16OP	= 5;						// DEC
								next_stage = 1;
								REG_WSEL	= 4'b1xxx;				// pc
								REG_RSEL	= 4'b101x;				// sp
								M1 		= 0;
								WR			= 1;
							end
							3'b100:	begin	// stage5
								ALU160_SEL = 0;					// regs
								WE 		= 6'b010x00;			// PC
								REG_RSEL	= 4'b111x;				// tmp7
							end
						endcase
//				-----------------------		PUSH --------------------
					4'b0101: 
						case(STAGE[1:0])
							2'b00, 2'b01: begin			// stage1,2
								DO_SEL	= {STAGE[0] & op16[2], 1'b0};		// FLAGS/ALU80
								ALU160_SEL = 0;				// regs
								WE 		= 6'b001x00;		// SP
								ALU16OP	= 5;  				// dec
								next_stage = 1;
								REG_WSEL	= {1'b0, FETCH[5:4], STAGE[0]};
								REG_RSEL	= 4'b101x;				// SP
								M1 		= 0;
								WR			= 1;
							end
							2'b10: begin					//stage3
								ALU160_SEL = 1;				// PC
								WE 		= 6'b010x00;		// PC
							end
						endcase
//				-----------------------		op A, n  --------------------
					4'b0110, 4'b1110:
						if(!STAGE[0]) begin			// stage1, read n
							ALU160_SEL = 1;					// pc
							DINW_SEL = 1;						// DI
							WE 		= 6'b010x01;			// PC, lo
							next_stage = 1;
							REG_WSEL	= 4'b011x;				// tmpLO
							M1 		= 0;
						end else begin					// stage 2
							DINW_SEL = 0;						// ALU8OUT[7:0]
							ALU160_SEL = 1;					// pc
							WE 		= {4'b110x, ~&FETCH[5:3], 1'bx};			// flags, PC, hi
							ALU8OP	= {2'b00, FETCH[5:3]};
							REG_WSEL	= 4'b0110;				// A
							REG_RSEL	= 4'b0111;				// tmpLO
						end
//				-----------------------		RST  --------------------
					4'b0111, 4'b1111:
						case(STAGE[1:0])
							2'b00, 2'b01: begin		// stage 1,2 - push pc
								DO_SEL	= {1'b0, STAGE[0]};	// pc hi/lo
								ALU160_SEL = 0;					// regs
								WE 		= 6'b001x00;			// SP
								ALU16OP	= 5;						// DEC
								next_stage = 1;
								REG_WSEL	= 4'b1xxx;				// pc
								REG_RSEL	= 4'b101x;				// sp
								M1 		= 0;
								WR			= 1;
							end
							2'b10:	begin				// stage3
								ALU160_SEL = 0;					// regs
								WE 		= 6'b010x00;			// PC
								REG_RSEL	= 4'b110x;				// const
							end
						endcase
//				-----------------------		RET, EXX, JP (HL), LD SP HL --------------------
					4'b1001:	
						case(FETCH[5:4])	
							2'b00: 				// RET
								case(STAGE[1:0])
									2'b00, 2'b01:	begin		// stage1, stage2 - pop addr
										ALU160_SEL = 0;				// regs
										DINW_SEL = 1;					// DI
										WE 		= {4'b001x, STAGE[0] ? 1'b1 : 1'bx, !STAGE[0]};		// SP, lo/hi
										next_stage = 1;
										REG_WSEL	= 4'b111x;			// tmp16
										REG_RSEL	= 4'b101x;			// SP
										M1 		= 0;
									end		
									2'b10: begin			// stage3 - jump
										ALU160_SEL = 0;					// regs
										WE 		= 6'b010x00;			// PC
										REG_RSEL	= 4'b111x;				// tmp16
									end
								endcase
							2'b01: begin			// EXX
								ALU160_SEL = 1;			// PC
								WE 		= 6'b010x00;	// PC
								status[1] = 1;			
							end
							2'b10:	begin		// JP (HL)
								ALU160_SEL = 0;					// regs
								WE 		= 6'b010x00;			// PC
								REG_RSEL	= 4'b010x;				// HL
							end
							2'b11: begin	// LD SP,HL	
								if(!STAGE[0]) begin			// stage1
									ALU160_SEL = 0;				// regs
									WE 		= 6'b001x00;		// SP
									ALU16OP	= 4;					// NOP, no post inc
									next_stage = 1;
									REG_RSEL	= 4'b010x;			// HL
									M1 		= 0;
									MREQ		= 0;
								end else begin						// stage2
									ALU160_SEL = 1;				// pc
									WE 		= 6'b010x00;		// PC
								end
							end
						endcase
//				-----------------------		CB, IN A (n), EX DE HL, EI --------------------
					4'b1011:
						case(FETCH[5:4])
							2'b00:  					// CB prefix
								case({STAGE[0], CPUStatus[4]})
									2'b00, 2'b11: begin
										ALU160_SEL = 1;			// PC
										WE 		= 6'b010000;	// PC
										fetch98 = 2'b10;		
									end
									2'b01: begin
										ALU160_SEL = 1;			// PC
										WE 		= 6'b010100;	// PC, tmpHI
										next_stage = 1;
										M1 		= 0;
									end
								endcase
							2'b01:					// IN A, (n)
								case(STAGE[1:0])
									2'b00: begin		//stage1 - read n
										ALU160_SEL = 1;				// pc
										DINW_SEL = 1;					// DI
										WE 		= 6'b010x01;		// PC, lo
										next_stage = 1;
										REG_WSEL	= 4'b011x;			// tmpLO
										M1 		= 0;
									end
									2'b01: begin		// stage2 - IN
										ALU160_SEL = 0;				// regs
										DINW_SEL = 1;					// DI
										WE 		= 6'b000x1x;		// hi
										next_stage = 1;
										REG_WSEL	= 4'b011x;			// A
										REG_RSEL	= 4'b011x;			// A - tmpLO
										M1 		= 0;
										MREQ		= 0;
										IORQ		= 1;
									end
									2'b10: begin		// stage3 - fetch
										ALU160_SEL = 1;			// PC
										WE 		= 6'b010x00;	// PC
									end
								endcase
							2'b10: begin			// EX DE, HL
								ALU160_SEL = 1;			// PC
								WE 		= 6'b010x00;	// PC
								if(CPUStatus[1]) status[3] = 1;	
								else status[2] = 1;
							end
							2'b11: begin			// EI
								ALU160_SEL = 1;			// PC
								WE 		= 6'b010x00;	// PC
								status[11] = 1'b1;
								status[7:6] = 2'b11;
							end
						endcase
//				-----------------------		CALL , IX, ED, IY --------------------
					4'b1101:	
						case(FETCH[5:4])
							2'b00: 					// CALL
								case(STAGE[2:0])
									3'b000, 3'b001: begin		// stage 1,2 - load addr
										ALU160_SEL = 1;					// pc
										DINW_SEL = 1;						// DI
										WE 		= {4'b010x, STAGE[0] ? 1'b1 : 1'bx, !STAGE[0]};		// PC, hi/lo
										next_stage = 1;
										REG_WSEL	= 4'b111x;				// tmp7
										M1 		= 0;
									end
									3'b010, 3'b011: begin		// stage 3,4 - push pc
										DO_SEL	= {1'b0, STAGE[0]};	// pc hi/lo
										ALU160_SEL = 0;					// regs
										WE 		= 6'b001x00;			// SP
										ALU16OP	= 5;						// DEC
										next_stage = 1;
										REG_WSEL	= 4'b1xxx;				// pc
										REG_RSEL	= 4'b101x;				// sp
										M1 		= 0;
										WR			= 1;
									end
									3'b100:	begin	// stage5 - jump
										ALU160_SEL = 0;					// regs
										WE 		= 6'b010x00;			// PC
										REG_RSEL	= 4'b111x;				// tmp7
									end
								endcase
							2'b01: begin			// DD - IX
								ALU160_SEL = 1;			// PC
								WE 		= 6'b010x00;	// PC
								status[5:4] = 2'b01;
							end
							2'b10: begin			// ED prefix
								ALU160_SEL = 1;			// PC
								WE 		= 6'b010x00;	// PC
								fetch98 = 2'b01;		
							end
							2'b11:	begin			// FD - IY
								ALU160_SEL = 1;			// PC
								WE 		= 6'b010x00;	// PC
								status[5:4]	= 2'b11;	
							end
						endcase
				endcase

//	------------------------------------------- ED + opcode ----------------------------------------------------
			4'b0100, 4'b0111: begin		// ED + 2'b00, ED + 2'b11 		= NOP
				ALU160_SEL = 1;			// PC
				WE 		= 6'b010x00;	// PC
			end
			4'b0101:
				case(FETCH[2:0])
//				-----------------------		in r (C)  --------------------
					3'b000:
						if(!STAGE[0]) begin
							ALU160_SEL = 0;					// regs
							DINW_SEL = 1;						// DI
							WE 		= {4'b000x, !opd[3], opd[3]} ;	// hi/lo
							next_stage = 1;
							REG_WSEL	= {1'b0, opd[5:4], 1'bx};
							REG_RSEL	= 4'b000x;				// BC
							M1 		= 0;
							MREQ		= 0;
							IORQ 		= 1;
						end else begin
							ALU160_SEL = 1;					// pc
							WE 		= 6'b110x00;			// flags, PC
							ALU8OP	= 29;						// IN
							REG_RSEL	= {1'b0, opd[5:3]};	// reg
						end
//				-----------------------		out (C) r  --------------------
					3'b001:
						if(!STAGE[0]) begin
							DO_SEL	= 2'b00;					// ALU80
							ALU160_SEL = 0;					// regs
							WE 		= 6'b000x00;			// nothing
							next_stage = 1;
							REG_WSEL	= &opd[5:3] ? 4'b110x : {1'b0, opd[5:3]}; // zero/reg
							REG_RSEL	= 4'b000x;				// BC
							M1 		= 0;
							MREQ		= 0;
							WR			= 1;
							IORQ 		= 1;
						end else begin
							ALU160_SEL = 1;					// pc
							WE 		= 6'b010x00;			// PC
						end
//				-----------------------		SBC16, ADC16  --------------------
					3'b010:
						if(!STAGE[0]) begin			// stage1
							DINW_SEL = 0;						// ALU8OUT
							WE 		= 6'b100x01;			// flags, lo
							ALU8OP	= {3'b000, !FETCH[3], 1'b1};	// SBC/ADC
							next_stage = 1;
							REG_WSEL	= 4'b0101;				// L			
							REG_RSEL	= {op16, 1'b1};
							M1 		= 0;
							MREQ		= 0;
						end else begin
							ALU160_SEL = 1;					// pc
							DINW_SEL = 0;						// ALU8OUT
							WE 		= 6'b110x10;			// flags, PC, hi
							ALU8OP	= {3'b000, !FETCH[3], 1'b1};
							REG_WSEL	= 4'b0100;				// H
							REG_RSEL	= {op16, 1'b0};
						end
//				-----------------------		LD (nn) r16, ld r16 (nn)  --------------------
					3'b011:
						case(STAGE[2:1])
							2'b00:	begin // stage 1,2 - read address
								ALU160_SEL = 1;				// pc
								DINW_SEL = 1;					// DI
								WE 		= {4'b010x, STAGE[0] ? 1'b1 : 1'bx, !STAGE[0]};	// PC, hi/lo
								next_stage = 1;
								REG_WSEL	= 4'b111x;			// tmp16
								M1 		= 0;
							end
							2'b01: begin
								ALU160_SEL = 0;			// regs
								next_stage = 1;
								ALU16OP	= {2'b00, STAGE[0]};				
								REG_RSEL	= 4'b111x;		// tmp16
								REG_WSEL	= {op16, !STAGE[0]};
								M1 		= 0;
								if(FETCH[3]) begin	// LD rr, (nn) - stage3,4
									DINW_SEL = 1;				// DI
									WE 		= {4'b000x, STAGE[0] ? 1'b1 : 1'bx, !STAGE[0]};	// lo
								end else begin			// LD (nn), rr - stage3,4
									DO_SEL	= op16[2] ? {1'b1, !STAGE[0]} : 2'b00;				// ALU80/sp
									WE 		= 6'b000x00;		// nothing
									WR			= 1;
								end
							end
							2'b10:		// stage5 
								if(FETCH[3] & op16[2] & !STAGE[0]) begin	// LD sp, (nn) - stage5
									ALU160_SEL = 0;					// regs
									WE 		= 6'b001x00;			// SP
									ALU16OP	= 4;						// NOP
									next_stage = 1;
									REG_RSEL	= 4'b101x;				// tmp SP
									M1 		= 0;
									MREQ		= 0;
								end else begin
									ALU160_SEL = 1;					// pc
									WE 		= 6'b010x00;			// PC
								end
							endcase
//				-----------------------		NEG  --------------------
					3'b100: begin
						ALU160_SEL = 1;					// pc
						DINW_SEL = 0;						// ALU8OUT
						WE 		= 6'b110x10;			// flags, PC, hi
						ALU8OP	= 5'b11111;				// NEG
						REG_WSEL	= 4'b011x;				// A
						REG_RSEL	= 4'b0110;				// A
					end
//				-----------------------		RETN, RETI  --------------------
					3'b101:
						case(STAGE[1:0])
							2'b00, 2'b01:	begin		// stage1, stage2 - pop addr
								ALU160_SEL = 0;				// regs
								DINW_SEL = 1;					// DI
								WE 		= {4'b001x, STAGE[0] ? 1'b1 : 1'bx, !STAGE[0]};		// SP, lo/hi
								next_stage = 1;
								REG_WSEL	= 4'b111x;			// tmp16
								REG_RSEL	= 4'b101x;			// SP
								M1 		= 0;
							end		
							2'b10: begin			// stage3 - jump
								ALU160_SEL = 0;					// regs
								WE 		= 6'b010x00;			// PC
								REG_RSEL	= 4'b111x;				// tmp16
								status[11] = 1'b1;
								status[7:6] = {CPUStatus[7], CPUStatus[7]};
							end
						endcase
//				-----------------------		IM  --------------------
					3'b110: begin
						ALU160_SEL = 1;					// PC
						WE 		= 6'b010x00;			// PC
						status[10:8] = {1'b1, FETCH[4:3]};
					end
//				-----------------------		LD I A, LD R A, LD A I, LD A R, RRD, RLD  --------------------
					3'b111:
						case(FETCH[5:4])
							2'b00: begin	// LD I/R A
								ALU160_SEL = 1;					// pc
								DINW_SEL = 1'b0;					// ALU8OUT
								WE 		= {4'b010x, !FETCH[3], FETCH[3]};	// PC, hi/lo
								ALU8OP	= 29;						// pass D1
								REG_WSEL	= 4'b1001;				// IR, write r
								REG_RSEL	= 4'b0110;				// A
							end
							2'b01: begin	// LD A I/R
								ALU160_SEL = 1;					// pc
								DINW_SEL = 1'b0;					// ALU8OUT
								WE 		= 6'b110x1x;			// flags, PC, hi
								ALU8OP	= 29;						// PASS D1
								REG_WSEL	= 4'b011x;				// A
								REG_RSEL	= {3'b100, FETCH[3]};// I/R
							end
							2'b10: 			// RRD, RLD
								case(STAGE[1:0])
									2'b00:begin		// stage1, read data
										ALU160_SEL = 0;					// regs
										DINW_SEL = 1;						// DI
										WE 		= 6'b000x01;			// lo
										next_stage = 1;
										REG_WSEL	= 4'b011x;				// tmpLO
										REG_RSEL	= 4'b010x;				// HL
										M1 		= 0;
									end
									2'b01: begin	// stage2, shift data
										DINW_SEL = 0;						// ALU8OUT
										WE 		= 6'b100x11;			// flags, hi, lo
										ALU8OP	= FETCH[3] ? 5'b01100 : 5'b01011;	// RRD/RLD
										next_stage = 1;
										REG_WSEL	= 4'b0110;				// A
										REG_RSEL	= 4'b0111;				// tmpLO
										M1 		= 0;
										MREQ		= 0;
									end
									2'b10: begin // stage3 - write
										DO_SEL	= 2'b00;					// ALU80
										ALU160_SEL = 0;					// regs
										WE 		= 6'b000x0x;			// nothing
										next_stage = 1;
										REG_WSEL	= 4'b0111;				// tmpLO
										REG_RSEL	= 4'b010x;				// HL
										M1 		= 0;
										WR			= 1;
									end
									2'b11: begin
										ALU160_SEL = 1;					// PC
										WE 		= 6'b010x00;			// PC
									end
								endcase
							2'b11: begin	// NOP
								ALU160_SEL = 1;					// PC
								WE 		= 6'b010x00;			// PC
							end
						endcase
				endcase
//				-----------------------		block instructions  --------------------
			4'b0110:
				if({FETCH[5], FETCH[2]} == 4'b10)
					case(FETCH[1:0])
						2'b00:	// LDI, LDD, LDIR, LDDR
							case(STAGE[1:0])
								2'b00:	begin			// stage1, read data, inc/dec HL
									ALU160_SEL = 0;					// regs
									DINW_SEL = 0;						// ALU8OUT
									WE 		= 6'b100111;			// flags, tmpHI, hi, lo
									ALU8OP	= {4'b0111, FETCH[3]};	// INC/DEC16
									next_stage = 1;
									REG_WSEL	= 4'b0100;				// H
									REG_RSEL	= 4'b0101;				// L
									M1 		= 0;
								end
								2'b01:	begin			// stage2, dec BC
									DINW_SEL = 0;						// ALU8OUT
									WE 		= 6'b100011;			// flags, hi, lo (affects PF only)
									ALU8OP	= 5'b01111;				// DEC
									next_stage = 1;
									REG_WSEL	= 4'b0000;				// B
									REG_RSEL	= 4'b0001;				// C
									M1 		= 0;
									MREQ		= 0;
								end
								2'b10:	begin			// stage2, write data, inc/dec DE
									DO_SEL	= 2'b01;					// th
									ALU160_SEL = 0;					// regs
									DINW_SEL = 0;						// ALU8OUT
									WE 		= 6'b000x11;			// hi, lo
									ALU8OP	= {4'b0111, FETCH[3]};	// INC / DEC
									next_stage = FETCH[4] ? !FLAGS[2] : 1'b1;
									REG_WSEL	= 4'b0010;				// D
									REG_RSEL	= 4'b0011;				// E
									M1 		= 0;
									WR			= 1;
								end
								2'b11: begin
									ALU160_SEL = 1;					// PC
									WE 		= 6'b010x00;			// PC
								end
							endcase
						2'b01:	// CPI, CPD, CPIR, CPDR
							case(STAGE[1:0])
								2'b00: begin			// stage1, load data
									ALU160_SEL = 0;					// regs
									DINW_SEL = 1;						// DI
									WE 		= 6'b000x01;			// lo
									next_stage = 1;
									REG_WSEL	= 4'b011x;				// tmpLO
									REG_RSEL	= 4'b010x;				// HL
									M1 		= 0;
								end
								2'b01: begin			// stage2, CP
									WE 		= 6'b100x0x;			// flags
									ALU8OP	= 7;						// CP
									next_stage = 1;
									REG_WSEL	= 4'b0110;				// A
									REG_RSEL	= 4'b0111;				// tmpLO
									M1 		= 0;
									MREQ		= 0;
								end
								2'b10: begin			// stage3, dec BC
									DINW_SEL = 0;						// ALU8OUT
									WE 		= 6'b100x11;			// flags, hi, lo
									ALU8OP	= 5'b01111;				// DEC16
									next_stage = 1;
									REG_WSEL	= 4'b0000;				// B
									REG_RSEL	= 4'b0001;				// C
									M1 		= 0;
									MREQ		= 0;
								end
								2'b11: begin			// stage4, inc/dec HL
									ALU160_SEL = 1;					// pc
									DINW_SEL = 0;						// ALU8OUT
									M1 		= FETCH[4] ? (!FLAGS[2] || FLAGS[6]) : 1'b1;
									WE 		= {1'b0, M1, 4'b0x11};	// PC, hi, lo
									ALU8OP	= {4'b0111, FETCH[3]};	// INC / DEC
									REG_WSEL	= 4'b0100;				// H
									REG_RSEL	= 4'b0101;				// L
									MREQ		= M1;
								end
							endcase
						2'b10:	// INI, IND, INIR, INDR
							case(STAGE[1:0])
								2'b00: 	begin			// stage1, in data, dec B
									ALU160_SEL = 0;					// regs
									DINW_SEL = 0;						// ALU8OUT
									WE 		= 6'b100110;			// flags, tmpHI, hi
									ALU8OP	= 10;						// DEC
									next_stage = 1;
									REG_WSEL	= 4'b0000;				// B
									REG_RSEL	= 4'b000x;				// BC
									M1 		= 0;
									MREQ		= 0;
									IORQ		= 1;
								end
								2'b01:	begin			// stage2, write data, inc/dec HL
									DO_SEL	= 2'b01;					// th
									ALU160_SEL = 0;					// regs
									DINW_SEL = 0;						// ALU8OUT
									WE 		= 6'b000x11;			// hi, lo
									ALU8OP	= {4'b0111, FETCH[3]};	// INC / DEC
									next_stage = FETCH[4] ? FLAGS[6] : 1'b1;
									REG_WSEL	= 4'b0100;				// H
									REG_RSEL	= 4'b0101;				// L
									M1 		= 0;
									WR			= 1;
								end
								2'b10:	begin			// stage3
									ALU160_SEL = 1;					// pc
									WE 		= 6'b010x00;			// PC
								end
							endcase
						2'b11:	// OUTI/OUTD/OTIR/OTDR
							case(STAGE[1:0])
								2'b00:	begin			// stage1, load data, inc/dec HL
									ALU160_SEL = 0;					// regs
									DINW_SEL = 0;						// ALU8OUT
									WE 		= 6'b000111;			// tmpHI, hi, lo
									ALU8OP	= {4'b0111, FETCH[3]};	// INC / DEC
									next_stage = 1;
									REG_WSEL	= 4'b0100;				// H
									REG_RSEL	= 4'b0101;				// L
									M1 		= 0;
								end
								2'b01: 	begin			// stage2, out data, dec B
									DO_SEL	= 2'b01;					// th
									ALU160_SEL = 0;					// regs
									DINW_SEL = 0;						// ALU8OUT
									WE 		= 6'b100x10;			// flags, hi
									ALU8OP	= 10;						// DEC
									next_stage = FETCH[4] ? (ALU80 == 8'b00000001) : 1'b1;
									REG_WSEL	= 4'b0000;				// B
									REG_RSEL	= 4'b000x;				// BC
									M1 		= 0;
									MREQ		= 0;
									IORQ		= 1;
									WR			= 1;
								end
								2'b10:	begin			// stage3
									ALU160_SEL = 1;					// pc
									WE 		= 6'b010x00;			// PC
								end
							endcase
					endcase
				else begin			// NOP
					ALU160_SEL = 1;					// PC
					WE 		= 6'b010x00;			// PC
				end
//------------------------------------------- CB + opcode ----------------------------------------------------
			4'b1000, 4'b1001, 4'b1010, 4'b1011:										// CB class (rot/shift, bit/res/set)
				case({STAGE[1:0], CPUStatus[4], op0mem})				
					4'b00_0_0: begin						// execute reg-reg
						DINW_SEL = 0;						// ALU8OUT
						ALU160_SEL = 1;					// pc
						WE 		= {!FETCH[7], 3'b10x, FETCH[7:6] == 2'b01 ? 2'b00 : {!opd[0], opd[0]}};	// flags, hi/lo
						ALU8OP	= 28;					// BIT
						REG_WSEL	= {1'b0, opd[2:0]};
					end
					4'b00_0_1, 4'b00_1_0, 4'b00_1_1: begin				// stage1, (HL-X) - read data
						ALU160_SEL = 0;				// regs
						DINW_SEL = 1;					// DI
						WE 		= opd[0] ? 6'b000001 : 6'b000010;	// lo/hi
						ALU16OP	= CPUStatus[4] ? 3'd3 : 3'd0;					// ADD - NOP
						next_stage = 1;
						REG_WSEL = FETCH[7:6] == 2'b01 ? 4'b111x : {1'b0, opd[2:0]};	// dest, tmp16 for BIT
						REG_RSEL	= 4'b010x;			// HL
						M1 		= 0;
					end
					4'b01_0_1, 4'b01_1_0, 4'b01_1_1:		// stage2 (HL-X) - execute, write
						case(FETCH[7:6])
							2'b00, 2'b10, 2'b11: begin		// exec + write
								DINW_SEL = 0;					// ALU8OUT
								DO_SEL	= 2'b11;				// ALU8OUT[7:0]
								ALU160_SEL = 0;				// regs
								WE 		= {!FETCH[7], 3'b00x, !opd[0], opd[0]};	// flags, hi/lo
								ALU8OP	= 28;
								ALU16OP	= CPUStatus[4] ? 3'd3 : 3'd0;
								next_stage = 1;
								REG_WSEL	= {1'b0, opd[2:0]};
								REG_RSEL	= 4'b010x;				// HL
								M1 		= 0;
								WR			= 1;
							end
							2'b01: begin							// BIT, no write
								ALU160_SEL = 1;					// pc
								WE 		= 6'b110xxx;			// flags, PC
								ALU8OP	= 28;						// BIT
								REG_WSEL	= {3'b111, opd[0]};	// tmp
							end 
						endcase
					4'b10_0_1, 4'b10_1_0, 4'b10_1_1: begin	// (HL-X) - load next op
						ALU160_SEL = 1;							// pc
						WE 		= 6'b010x00;					// PC
					end
				endcase
//------------------------------------------- // RST, NMI, INT ----------------------------------------------------
			4'b1110: begin 			// RESET: IR <- 0, IM <- 0, IFF1,IFF2 <- 0, pC <- 0
					ALU160_SEL = 0;					// regs
					DINW_SEL = 0;						// ALU8OUT
					WE 		= 6'bx1xx11;			// PC, hi, lo
					ALU8OP	= 29;						// pass D1
					ALU16OP	= 4;						// NOP
					REG_WSEL	= 4'b1001;				// IR, write r
					REG_RSEL	= 4'b110x;				// const
					M1 		= 0;
					MREQ		= 0;
					status[11:6] = 6'b110000;		// IM0, DI
				end 
			4'b1101:						// NMI
				case(STAGE[1:0])
					2'b00: begin		
						ALU160_SEL = 1;				// pc
						WE 		= 6'b010x00;		// PC
						ALU16OP	= intop;				// DEC/DEC2 (if block instruction interrupted)
						next_stage = 1;
						M1 		= 0;
						MREQ		= 0;
					end
					2'b01, 2'b10: begin
						DO_SEL	= {1'b0, !STAGE[0]};	// pc hi/lo
						ALU160_SEL = 0;					// regs
						WE 		= 6'b001x00;			// SP
						ALU16OP	= 5;						// DEC
						next_stage = 1;
						REG_WSEL	= 4'b1xxx;				// pc
						REG_RSEL	= 4'b101x;				// sp
						M1 		= 0;
						WR			= 1;
						status[11]	= 1'b1;
						status[7:6] = {CPUStatus[7], 1'b0};	// reset IFF1
					end
					2'b11: begin
						ALU160_SEL = 0;					// regs
						WE 		= 6'b010x00;			// PC
						REG_RSEL	= 4'b110x;				// const
					end
				endcase
			4'b1100:				// INT
				case(CPUStatus[9:8])
					2'b00, 2'b01, 2'b10: begin		// IM0, IM1	
						ALU160_SEL = 1;					// pc
						WE 		= 6'b010x00;			// PC
						ALU16OP	= intop;					// DEC/DEC2 (if block instruction interrupted)
						MREQ		= 0;
						IORQ		= 1;
						status[11]	= 1'b1;
						status[7:6] = 2'b0;				// reset IFF1, IFF2
					end
					2'b11: 								// IM2
						case(STAGE[2:0])
							3'b000: begin
								ALU160_SEL = 1;				// pc
								DINW_SEL = 1;					// DI
								WE 		= 6'b010x01;		// PC, lo
								ALU16OP	= intop;				// DEC/DEC2 (if block instruction interrupted)
								next_stage = 1;
								REG_WSEL	= 4'b1000;			// Itmp, no write r
								MREQ		= 0;
								IORQ		= 1;
								status[11]	= 1'b1;
								status[7:6] = 2'b0;			// reset IFF1, IFF2
							end
							3'b001, 3'b010: begin			// push pc
								DO_SEL	= {1'b0, !STAGE[0]};	// pc hi/lo
								ALU160_SEL = 0;					// regs
								WE 		= 6'b001x00;			// SP
								ALU16OP	= 5;						// DEC
								next_stage = 1;
								REG_WSEL	= 4'b1xxx;				// pc
								REG_RSEL	= 4'b101x;				// sp
								M1 		= 0;
								WR			= 1;
							end
							3'b011, 3'b100:	begin			// read address
								ALU160_SEL = 0;					// regs
								DINW_SEL = 1;						// DI
								WE 		= {4'b0x0x, STAGE[0] ? 1'bx : 1'b1, STAGE[0]};				// hi/lo
								ALU16OP	= {2'b00, !STAGE[0]};// NOP/INC
								next_stage = 1;
								REG_WSEL	= 4'b111x;				// tmp16
								REG_RSEL	= 4'b1000;				// I-Itmp
								M1 		= 0;
							end
							3'b101: begin						// jump
								ALU160_SEL = 0;					// regs
								WE 		= 6'b010x00;			// PC
								REG_RSEL	= 4'b111x;				// tmp16
							end
						endcase
				endcase
		endcase	
	end

endmodule
