//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 project
// http://opencores.org/project,next186
//
// Filename: Next186_CPU.v
// Description: Implementation of 80186 instruction compatible CPU
// Version 1.0
// Creation date: 24Mar2011 - 07Jun2011
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
//	Next186 processor features:
//		All 80186 intstructions are implemented according with the 80186 specifications (excepting ENTER instruction, 
//		which uses always 0 as the second parameter - level).
//		Designed with 2 buses: 16bit/20bit data/data_address and 48bit/20bit instruction/instruction_address.
//		This allows most instructions to be executed in one clock cycle.
//		In order to couple the CPU unit with a single bus, these sepparate data/instruction buses must be multiplexed by
//		a dedicated bus interface unit (BIU).
//		It is able to execute up to 40Mips on Spartan XC3S700AN speed grade -4, performances comparable with a 486 CPU.
//		Small size, the CPU + BIU requires ~25%  or 1500 slices - on Spartan XC3S700AN
// 
//	16May2012 - fixed REP CMPS/SCAS bug when interrupted on the <equal> item
// 23Dec2012 - fixed DIV bug (exception on sign bit)
// 27Feb2013 - fixed MUL/IMUL 8bit flags bug
// 03Apr2013 - fix RET n alignment bug
// 04Apr2013 - fix TRAP interrupt acknowledge
// 12Apr2013 - fix IDIV when Q=0
// 16May2013 - fix PUSHA SP pushed stack value, which should be the one before PUSHA
// 25May2013 - generate invalid opcode exception for MOV FS and GS 
///////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module Next186_CPU(
    output [20:0] ADDR,
    input [15:0] DIN,
    output [15:0] DOUT,
	 input CLK,
	 input CE,
	 input INTR,
	 input NMI,
	 input RST,
	 output reg MREQ,
	 output wire IORQ,
	 output reg INTA,
	 output reg WR,
	 output reg WORD,
	 output LOCK,
	 output [20:0]IADDR,
	 input [47:0]INSTR,
	 output reg IFETCH,
	 output FLUSH,
	 output reg [2:0]ISIZE,
	 output reg HALT
    );
	
// connections	
	wire [15:0]RA;
	wire [15:0]RB;
	wire [15:0]TMP16;
	wire [15:0]SP;
	wire [15:0]IP;
	wire [15:0]AX;
	wire [15:0]BX;
	wire [15:0]BP;
	wire [15:0]SI;
	wire [15:0]DI;
	wire [15:0]DX;
	wire [15:0]FLAGS;
	wire [15:0]FIN;
	wire [15:0]ALUOUT;
	wire [15:0]AIMM1;
	reg [15:0]DIMM1;
	wire [15:0]RS;
	wire [15:0]ADDR16;
	wire [15:0]CS;
	wire ALUCONT;
	wire NULLSHIFT;
	wire [1:0]CXZ;
	wire COUT; // adder carry out
	wire DIVEXC; // exit carry for unsigned DIV 
	
// Registers
	reg [7:0]FETCH[5:0];
	reg [6:0]STAGE = 0;
	reg [5:0]CPUStatus = 0;	//1:0=SR override, 2=override ON/OFF, 3=Z(REP), 4=REP ON/OFF, 5=LOCK
	reg TZF = 0, TLF = 0;
	reg SRST = 0;
	reg SNMI = 0, FNMI = 0;
	reg SINTR = 0;
	reg [15:0]CRTIP;	// current instruction ptr (used by interrupts)
	reg DIVQSGN;
	reg RDIVEXC;
	
// control	
	reg [2:0]RASEL;
	reg [2:0]RBSEL;
	reg BASEL;
	reg [1:0]BBSEL;
	reg [1:0]RSSEL;
	reg [4:0]WE; // 4=flags, 3=TMP16, 2=RSSEL, 1=RASEL_HI, 0=RASEL_LO
	reg [4:0]ALUOP;
	reg [3:0]EAC;
	reg [1:0]DISEL;
	reg [1:0]ISEL;
	reg ASEL;
	reg AEXT;
	reg DEXT;
	reg [1:0]DOSEL;
	reg IPWSEL;
	reg [5:0]status;	//1:0=SR override, 2=override ON/OFF, 3=Z(REP), 4=REP ON/OFF, 5=lock
	reg NOBP;
	reg ALUSTAGE;	// inc STAGE with 2
	reg DIVSTAGE;  // inc STAGE with 4
	reg DISP16;
	reg DECCX;
	reg IRQ;
	reg [2:0]IRQL;
	reg REPINT;
	reg [5:0]ICODE1 = 23;
	reg NULLSEG;
	reg DIVOP;

// signals
	assign IORQ = &EAC;
	assign LOCK = CPUStatus[5];
	assign FLUSH = ~IPWSEL || (ISIZE == 3'b000);
	wire [15:0]IPADD = ISIZE == 3'b000 ? CRTIP : IP + ISIZE;
	wire [15:0]IPIN = IPWSEL ? IPADD : ALUOUT;
	wire [1:0]MOD = FETCH[1][7:6];
	wire [2:0]REG = FETCH[1][5:3];
	wire [2:0]RM  = FETCH[1][2:0];
	wire USEBP = RM[1] && ~&RM;
	wire POP = {EAC[3], EAC[1:0]} == 3'b101;
	wire [15:0]ADDR16_SP = POP ? SP : ADDR16;
	wire [1:0]WBIT = {WORD | RASEL[2], WORD | !RASEL[2]};
	wire [1:0]ISELS = {DISP16 | AEXT, DISP16 | ~AEXT};
	wire [2:0]ISIZES = DISP16 ? 4 : AEXT ? 3 : 2;
	reg  [2:0]ISIZEW;
	reg  [2:0]ISIZEI;	// ise imm
	wire [1:0]WRBIT = WR ? 2'b00 : WBIT;
	wire RCXZ = CPUStatus[4] && ~|CXZ;
	wire NRORCXLE1 = ~CPUStatus[4] || ~CXZ[1];
	wire [7:0]JMPC = {(FLAGS[7] ^ FLAGS[11]) | FLAGS[6], FLAGS[7] ^ FLAGS[11], FLAGS[2], FLAGS[7], FLAGS[0] | FLAGS[6], FLAGS[6], FLAGS[0], FLAGS[11]};
	wire [3:0]LOOPC = {CXZ != 2'b00, CXZ == 2'b01, CXZ == 2'b01 || !FLAGS[6], CXZ == 2'b01 || FLAGS[6]};
	wire IDIV = FETCH[0][1] & FETCH[1][3];
	wire DIVRSGN = (WORD ? FETCH[3][7] : FETCH[2][7]) & IDIV;
	wire DIVSGN = DIVQSGN ^ DIVRSGN;
	wire DIVEND = FETCH[0][0] ? STAGE[6] : STAGE[5];
	wire DIVC = ((COUT & ~RDIVEXC) ^ ~DIVRSGN);
	wire QSGN = (WORD ? DX[15] : AX[15]) & IDIV;
// interrupts
	wire SAMPLEINT = ~(WE[2] & RASEL[1:0] == 2'b10) & ~status[2] & ~status[4] & ~status[5]; // not load SS, no prefix
	wire NMIACK = SNMI & ~FNMI;	// NMI acknowledged
	wire INTRACK = FLAGS[9] & (~WE[4] | FIN[9]) & SINTR;			// INTR acknowledged (IF and not CLI in progress)
	wire IACK = IRQ | (SAMPLEINT & (NMIACK | INTRACK | (~HALT & FLAGS[8]))); // interrupt acknowledged (fixed 04Apr2013)
	reg CMPS;	// early EQ test for CMPS
	reg SCAS;   // early EQ test for SCAS

	Next186_Regs REGS (
    .RASEL(RASEL),
    .RBSEL(RBSEL), 
    .BASEL(BASEL), 
    .BBSEL(BBSEL), 
    .RSSEL(RSSEL), 
    .DIN(DIN),
	 .ALUOUT(ALUOUT),
	 .ADDR16(ADDR16),
	 .DIMM(DEXT ? {{8{DIMM1[7]}}, DIMM1[7:0]} : DIMM1),
    .WE(WE), 
	 .IFETCH(IFETCH),
    .RA(RA), 
    .RB(RB), 
    .TMP16(TMP16), 
    .SP(SP), 
    .IP(IP),
	 .AX(AX),
	 .BX(BX),
	 .BP(BP),
	 .SI(SI),
	 .DI(DI),
	 .DX(DX),
	 .RS(RS),
	 .FIN(FIN),
	 .FOUT(FLAGS),
	 .DISEL(DISEL),
	 .WORD(WORD | &DISEL),
	 .IPIN(IPIN),
	 .CLK(CLK),
	 .CLKEN(CE),
	 .CS(CS),
	 .INCSP(POP),
	 .CXZ(CXZ),
	 .DECCX(DECCX),
	 .DIVOP(DIVOP),
	 .DIVEND(DIVEND),
	 .DIVSGN(DIVSGN),
	 .DIVC(DIVC),
	 .DIVEXC(DIVEXC)
    );

	Next186_ALU ALU16 (
	 .RA(DOSEL == 2'b01 ? IPADD : RA), 
	 .RB(RB),
	 .TMP16(TMP16),
	 .FETCH23({FETCH[3], FETCH[2]}),
	 .FIN(FLAGS), 
	 .FOUT(FIN),
	 .ALUOP(ALUOP),
	 .EXOP(FETCH[1][5:3]),
	 .FLAGOP(FETCH[0][3:0]),
	 .ALUOUT(ALUOUT),
	 .WORD(WORD),
	 .ALUCONT(ALUCONT),
	 .NULLSHIFT(NULLSHIFT),
	 .STAGE(STAGE[2:0]),
	 .INC2(&DISEL),	// when DISEL == 2'b11, inc/dec value is 2 if WORD and 1 if ~WORD
	 .COUT(COUT),
	 .CLK(CLK)
	 );
		 
	Next186_EA EA (
    .SP(SP), 
    .BX(BX), 
    .BP(NOBP ? 16'h0000 : BP), 
    .SI(SI), 
    .DI(DI), 
	 .PIO(FETCH[0][3] ? DX : {8'h00, FETCH[1]}),
	 .TMP16(TMP16),
	 .AL(AX[7:0]),
    .AIMM(AEXT ? {{8{AIMM1[7]}}, AIMM1[7:0]} : (DISP16 ? AIMM1 : 16'h0000)), 
    .ADDR16(ADDR16),
	 .EAC(EAC)
    );

	 assign DOUT = DOSEL[1] ? DOSEL[0] ? AX : TMP16 : DOSEL[0] ? IPADD : ALUOUT;
	 assign ADDR = {{NULLSEG ? 16'h0000 : RS} + {5'b00000, ADDR16_SP[15:4]}, ADDR16_SP[3:0]};
	 assign IADDR = {CS + {5'b00000, IPIN[15:4]}, IPIN[3:0]};
	 assign AIMM1 = ASEL ? {FETCH[3], FETCH[2]} : {FETCH[2], FETCH[1]};

	 always @(posedge CLK)
		if(CE) begin
			if(SRST) begin		// reset
//				FETCH[0] <= 8'h0f;
				FETCH[0][0] <= 1'b1; // for word=1
				ICODE1 <= 54;
				FETCH[5][1:0] <= 2'b01;	// RESET
				STAGE <= 4'b1000;
			end else begin
				if(IACK & (IFETCH | HALT | REPINT)) begin // interrupt sampled and acknowledged
					FETCH[0][1:0] <= 2'b11;	
					ICODE1 <= 54;
					STAGE <= 4'b1000;
					FETCH[5][2:0] <= {HALT, 2'b00};
					if(IRQ) FETCH[2] <= IRQL != 3'b010 ? {5'b00000, IRQL} : FETCH[1];
					else if(NMIACK) begin
						FETCH[2] <= 8'h02;
						FNMI <= 1'b1;
					end else if(INTRACK) FETCH[5][1:0] <= 2'b10;
					else FETCH[2] <= 8'h01;	// trap
				end else if(IFETCH) begin		// no interrupt, fetch
					FETCH[5] <= INSTR[47:40];
					FETCH[4] <= INSTR[39:32];
					FETCH[3] <= INSTR[31:24];
					FETCH[2] <= INSTR[23:16];
					FETCH[1] <= INSTR[15:8];
					FETCH[0] <= INSTR[7:0];
					STAGE <= 0;
					CPUStatus[5:0] <= status[5:0];
					ICODE1 <= ICODE(INSTR[7:0]);
				end else begin		// no interrupt, no fetch
					STAGE <= STAGE + {DIVSTAGE, ALUSTAGE} + 1; 
					if(&DOSEL) {FETCH[3], FETCH[2]} <= |DISEL ? DIN : RB;
					TZF <= FIN[6];		// zero flag for BOUND
					TLF <= FIN[7] != FIN[11];	// less flag for BOUND
				end
			end
			if(IFETCH & ~status[2] & ~status[4] & ~status[5]) CRTIP <= IPIN; // no prefix
			SRST <= RST;				// level detection RST
			SINTR <= INTR;				// level detection INTR
			if(NMI) SNMI <= 1'b1;	// edge detection NMI
			else if(FNMI) begin
				SNMI <= 1'b0;
				FNMI <= 1'b0;
			end
			if(~|STAGE[1:0]) DIVQSGN <= QSGN;
			RDIVEXC <= DIVOP & DIVEXC & ~IDIV; // bit 8/16 for unsigned DIV
			CMPS <= (~FETCH[0][0] | (FETCH[3] == DIN[15:8])) & (FETCH[2] == DIN[7:0]);	// early EQ test for CMPS
			SCAS <= (~FETCH[0][0] | (AX[15:8] == DIN[15:8])) & (AX[7:0] == DIN[7:0]);  // early EQ test for SCAS
		end

	always @(ISEL, FETCH[0], FETCH[1], FETCH[2], FETCH[3], FETCH[4], FETCH[5])
		case(ISEL)
			2'b00: DIMM1 = {FETCH[2], FETCH[1]};
			2'b01: DIMM1 = {FETCH[3], FETCH[2]};
			2'b10: DIMM1 = {FETCH[4], FETCH[3]};
			2'b11: DIMM1 = {FETCH[5], FETCH[4]};
		endcase

	always @(FETCH[0], WORD, DISP16, AEXT) begin
		case({WORD, DISP16, AEXT})
			3'b000: ISIZEW = 3;
			3'b001, 3'b100: ISIZEW = 4;
			3'b010, 3'b101: ISIZEW = 5;
			default: ISIZEW = 6;
		endcase
		case({FETCH[0][1:0] == 2'b01, DISP16, AEXT})
			3'b000: ISIZEI = 3;
			3'b001, 3'b100: ISIZEI = 4;
			3'b110: ISIZEI = 6;
			default: ISIZEI = 5;
		endcase
	end

	 always @(FETCH[0], FETCH[1], FETCH[2], FETCH[3], FETCH[4], FETCH[5], MOD, REG, RM, CPUStatus, USEBP, NOBP, RASEL, ISIZEI, TLF, EAC, COUT, DIVEND, DIVC, QSGN, CMPS, SCAS,
				 WBIT, ISIZES, ISELS, WRBIT, ISIZEW, STAGE, NULLSHIFT, ALUCONT, FLAGS, CXZ, RCXZ, NRORCXLE1, TZF, JMPC, LOOPC, ICODE1, DIVQSGN, DIVSGN, DIVRSGN, FIN, IDIV, AX) begin
		WORD = FETCH[0][0];
		BASEL = FETCH[0][1] | &MOD;
		RASEL = FETCH[0][1] ? REG : RM; // destination
		BBSEL = {1'b0, !FETCH[0][1] | &MOD};
		RBSEL = FETCH[0][1] ? RM : REG; // source
		RSSEL = CPUStatus[2] ? CPUStatus[1:0] : (USEBP && !NOBP ? 2'b10 : 2'b11);
		WE = 5'b00000;		// 5=flags, 3=TMP16, 2=RSSEL, 1=RASEL_HI, 0=RASEL_LO
		ALUOP = 5'bxxxxx;
		EAC = {1'b0, RM};
		DISEL = 2'b01;		// ALU
		ISEL = 2'bxx;
		ASEL = 1'bx;
		AEXT = MOD == 2'b01;
		DEXT = 1'b0;
		DOSEL = 2'b00;	// ALU	 
		MREQ = 1'b1;
		WR = 1'b0;
		ISIZE = 3'bxxx;
		IPWSEL = 1'b1;		// IP + ISIZE
		IFETCH = 1'b1;
		status = 6'b00x0xx;

		DISP16 = MOD == 2'b10 || NOBP;
		NOBP = {MOD, RM} == 5'b00110;
		HALT = 1'b0;
		INTA = 1'b0;
		ALUSTAGE = 1'b0;
		DIVSTAGE = 1'b0;
		DECCX = 1'b0;
		IRQ = 1'b0;
		IRQL = 3'b110;	// unused opcode
		REPINT = 1'b0;
		NULLSEG = 1'b0;
		DIVOP = 1'b0;
		
		case(ICODE1) // one hot synthesis
// --------------------------------  mov R/M to/from R/SR  --------------------------------
			0: begin				
				if(FETCH[0][2]) WORD = 1'b1;
				if(FETCH[0][2:1] == 2'b10) BBSEL = 2'b11; // RB = SR
				ALUOP = 31;	// PASS B
				DISEL = {1'b0, &MOD};
				ASEL = 1'b1;
				IRQ = FETCH[0][2] & FETCH[1][5];	// 25May2013 - generate invalid opcode exception for MOV FS and GS						
				MREQ = ~&MOD & ~IRQ;
				WR = MREQ & !FETCH[0][1];
				WE = WR | IRQ ? 5'b00000 : &FETCH[0][2:1] ? {2'b00, FETCH[1][4:3] != 2'b01, 2'b00} : {3'b000, WBIT};		// RSSEL, RASEL_HI/RASEL_LO
				ISIZE = IRQ ? 0 : ISIZES;
			end
// --------------------------------  mov IMM to R/M  --------------------------------
			1: begin	
				RASEL = RM; // destination
				BBSEL = 2'b10;
				ALUOP = 31;	// PASS B
				ISEL = ISELS;
				ASEL = 1'b1;
				MREQ = ~&MOD;
				WR = MREQ;
				WE[1:0] = WRBIT;		// RASEL_HI/RASEL_LO
				ISIZE = ISIZEW;
			end
// --------------------------------  mov IMM to R --------------------------------
			2: begin	
				WORD = FETCH[0][3];
				RASEL = FETCH[0][2:0]; // destination
				BBSEL = 2'b10;				// imm
				WE[1:0] = WBIT;		// RASEL_HI/RASEL_LO
				ALUOP = 31;	// PASS B
				ISEL = 2'b00;
				MREQ = 1'b0;
				ISIZE = WORD ? 3 : 2;
			end
// --------------------------------  mov mem to/from ACC --------------------------------
			3: begin
				RASEL = 0; // ACC
				BBSEL = 2'b01;		// reg
				RBSEL = 0; // ACC
				ALUOP = 31;	// PASS B
				EAC = 4'b0110;
				DISEL = 2'b00;
				ASEL = 1'b0;
				AEXT = 1'b0;
				MREQ = 1'b1;
				WR = FETCH[0][1];
				WE[1:0] = WRBIT;		// IP, RASEL_HI/RASEL_LO
				ISIZE = 3;
				NOBP = 1'b1;
			end
// --------------------------------  segment override prefix --------------------------------
			4: begin	
				status = {CPUStatus[5:3], 1'b1, FETCH[0][4:3]};
				MREQ = 1'b0;
				ISIZE = 1;
			end
// --------------------------------  rep prefix --------------------------------
			5: begin
				status = {CPUStatus[5], 1'b1, FETCH[0][0], CPUStatus[2:0]};
				MREQ = 1'b0;
				ISIZE = 1;
			end
// --------------------------------  lock prefix --------------------------------
			6: begin
				status = {1'b1, CPUStatus[4:0]};
				MREQ = 1'b0;
				ISIZE = 1;
			end
// --------------------------------  FF block --------------------------------
			7:	begin
				ISIZE = ISIZES;
				case({FETCH[0][0], REG})
		// --------------------------------  push R/M --------------------------------
					4'b1110:
						if(!(&MOD || STAGE[0])) begin	// stage1, read data in TMP16
							WE[3] = 1'b1;		// TMP16
							DISEL = 2'b00;
							ASEL = 1'b1;
							IFETCH = 1'b0;
						end else begin		// stage2, push R/TMP16
							RASEL = 3'b100;		// write SP
							RSSEL = 2'b10;			// SS
							ALUOP = 31;	// PASS B
							WE[1:0] = 2'b11;		// RASEL_HI/RASEL_LO
							EAC = 4'b1000;			// SP - 2
							DISEL = 2'b10;			// ADDR
							WR = 1'b1;
						end
		// --------------------------------  inc/dec R/M --------------------------------
					4'b0000, 4'b1000, 4'b0001, 4'b1001: begin	
						ASEL = 1'b1;
						if(!(&MOD || STAGE[0])) begin	// stage1, load op from memory in TMP16
							WE[3] = 1'b1;		// TMP16
							DISEL = 2'b00;			// DIN
							IFETCH = 1'b0;
						end else begin						// stage2, execute and write		
							BASEL = &MOD;
							RASEL = RM; 			// destination
							ALUOP = {2'b01, FETCH[1][5:3]};
							MREQ = ~BASEL;
							WR = MREQ;
							WE = {3'b100, WRBIT};		// flags, IP, RASEL_HI, RASEL_LO
						end
					end
		// --------------------------------  call/jmp near R/M --------------------------------
					4'b1010, 4'b1100: begin
						if(!STAGE[0] && ~&MOD) begin	// stage1, load op in TMP16
							ASEL = 1'b1;
							WE[3] = 1'b1;		// TMP16
							DISEL = 2'b00;			// DIN
							IFETCH = 1'b0;
						end else begin 		// stage2, push IP, jump
							RASEL = 3'b100; 	// write SP
							RSSEL = 2'b10;		// SS
							ALUOP = 31;	// PASS B
							EAC = 4'b1000;		// SP - 2
							DISEL = 2'b10;		// ADDR
							DOSEL = 2'b01;	// IP	 
							MREQ = REG[1];
							WR = MREQ;
							WE[1:0] = {WR, WR};
							IPWSEL = 1'b0;		// ALU
						end
					end
		// --------------------------------  call/jmp far R/M --------------------------------
					4'b1011, 4'b1101: begin
						ALUOP = 31;				// PASS B
						IRQ = &MOD;
						case({STAGE[1:0], REG[1]})
							3'b001: begin	// stage1, push CS
								RASEL = 3'b100;		// write SP
								BBSEL = 2'b11;
								RBSEL = 3'b001; 		// CS
								RSSEL = 2'b10;			// SS
								EAC = 4'b1000;			// SP - 2
								DISEL = 2'b10;			// ADDR
								MREQ = ~IRQ;
								WR = MREQ;
								IFETCH = IRQ;
								WE[1:0] = IRQ ? 2'b00 : 2'b11;			// RASEL_HI/RASEL_LO
								ISIZE = 0;
							end
							3'b011, 3'b000: begin	// stage2, read offset in FETCH, ADDR16 in TMP16
								RASEL = 3'b100; 		// SP	- write SP to SP for getting ADDR16 to TMP16
								BBSEL = 2'b01;
								RBSEL = 3'b100; 		// SP
								WE[3:0] = IRQ ? 4'b0000 : 4'b1011;			// TMP16, RASEL_HI, RASEL_LO
								ASEL = 1'b1;
								DOSEL = 2'b11;			// load FETCH with DIN
								IFETCH = IRQ;
								MREQ = ~IRQ;
								ISIZE = 0;
							end 
							3'b101, 3'b010: begin 	// stage3, read CS
								RASEL = 3'b001; 		// CS
								WE[2] = 1'b1;			// RSSEL
								EAC = 4'b1011;			// TMP16 + 2
								DISEL = 2'b00;			// DIN
								IFETCH = 1'b0;
							end
							3'b111, 3'b100: begin	// stage4, push IP, jump
								RASEL = 3'b100; 	// write SP
								BBSEL = 2'b10;		// imm
								RSSEL = 2'b10;		// SS
								EAC = 4'b1000;		// SP - 2
								DISEL = 2'b10;		// ADDR
								DOSEL = 2'b01;		// IP	 
								ISEL = 2'b01;
								MREQ = REG[1];
								WR = MREQ;
								WE[1:0] = {WR, WR};
								IPWSEL = 1'b0;		// ALU
							end
						endcase
					end
		// --------------------------------  bad opcode --------------------------------
					default: begin		
						MREQ = 1'b0;
						IRQ = 1'b1;
						ISIZE = 0;
					end
				endcase
			end
// --------------------------------  push R/SR --------------------------------
			8: begin
				WORD = 1'b1;
				RASEL = 3'b100;		// write SP
				BBSEL = {~FETCH[0][6], 1'b1};
				RBSEL = FETCH[0][6] ? FETCH[0][2:0] : {1'b0, FETCH[0][4:3]}; // source
				RSSEL = 2'b10;			// SS
				EAC = 4'b1000;			// SP - 2
				DISEL = 2'b10;			// ADDR
				WE[1:0] = 2'b11;		// RASEL_HI/RASEL_LO
				ALUOP = 31;				// PASS B
				WR = 1'b1;
				ISIZE = 1;
			end
// --------------------------------  push Imm --------------------------------
			9: begin		
				WORD = 1'b1;
				RASEL = 3'b100;		// write SP
				BBSEL = 2'b10;			// imm
				RSSEL = 2'b10;			// SS
				WE[1:0] = 2'b11;		// RASEL_HI/RASEL_LO
				ALUOP = 31;				// PASS B
				EAC = 4'b1000;			// SP - 2
				DISEL = 2'b10;			// ADDR
				ISEL = 2'b00;
				DEXT = FETCH[0][1];
				WR = 1'b1;
				ISIZE = FETCH[0][1] ? 2 : 3;
			end
// --------------------------------  pusha --------------------------------
			10: begin
				WORD = 1'b1;
				RASEL = 3'b100;		// write SP
				RBSEL = STAGE[2:0];  // source
				RSSEL = 2'b10;			// SS
				ALUOP = 31;				// PASS B
				EAC = 4'b1000;			// SP - 2
				DISEL = 2'b10;			// ADDR
				WR = 1'b1;
				ISIZE = 1;
				IFETCH = STAGE[2:0] == 3'b111;
				WE[1:0] = 2'b11;					// RASEL_HI, RASEL_LO
				BASEL = STAGE[1:0] == 2'b00;	// 16May2013 - fix PUSHA SP pushed stack value, which should be the one before PUSHA
				BBSEL[0] = STAGE[2:0] != 3'b100;	// SP stage
			end
// --------------------------------  pop R/M --------------------------------
			11: 			
				case(REG)
					3'b000: begin
						ISIZE = ISIZES;
						if(!STAGE[0]) begin	// pop TMP16/REG
							RASEL = RM; 		// destination
							RSSEL = 2'b10;			// SS
							EAC = 4'b1001;			// SP
							DISEL = 2'b00;			// DIN
							IFETCH = &MOD;
							WE[3:0] = IFETCH ? 4'b0011 : 4'b1000;		// TMP16, RASEL_HI, RASEL_LO
						end else begin			// R/M <- TMP16
							RASEL = RM; // destination
							BBSEL = 2'b00;			// TMP
							ALUOP = 31;				// PASS B
							ASEL = 1'b1;
							MREQ = ~&MOD;
							WR = MREQ;
							WE[1:0] = WR ? 2'b00 : 2'b11;		// RASEL_HI, RASEL_LO
						end
					end
					default:	begin		// bad opcode
						MREQ = 1'b0;
						ISIZE = 0;
						IRQ = 1'b1;						
					end
				endcase
// --------------------------------  pop R / SR --------------------------------
			12: begin	
				WORD = 1'b1;
				RASEL = FETCH[0][6] ? FETCH[0][2:0] : {1'b0, FETCH[0][4:3]}; // destination
				RSSEL = 2'b10;			// SS
				WE[2:0] = FETCH[0][6] ? 3'b011 : 3'b100;		// RSSEL, RASEL_HI, RASEL_LO
				EAC = 4'b1001;			// SP
				DISEL = 2'b00;			// DIN
				ISIZE = 1;
			end
// --------------------------------  popa --------------------------------
			13: begin
				RASEL = ~STAGE[2:0]; // destination
				RSSEL = 2'b10;			// SS
				EAC = 4'b1001;			// SP
				DISEL = 2'b00;			// DIN
				ISIZE = 1;
				IFETCH = &STAGE[2:0];
				WE[1:0] = {STAGE[2:0] == 3'b011 ? 2'b00 : 2'b11};		// IP, RASEL_HI, RASEL_LO (skip SP)
			end
// --------------------------------  xchg R with R/M/Acc --------------------------------
			14: begin
				WORD = FETCH[0][0] | FETCH[0][4];
				ASEL = 1'b1;
				MREQ = ~&MOD && !FETCH[0][4];
				ALUOP = 31;				// PASS B
				ISIZE = FETCH[0][4] ? 1 : ISIZES;
				if(!STAGE[0]) begin		// stage1, R/M/Acc -> REG -> TMP16
					BASEL = 1'b1;
					RASEL = FETCH[0][4] ? FETCH[0][2:0] : REG; // destination
					BBSEL = 2'b01;		// reg
					RBSEL = FETCH[0][4] ? 3'b000 : RM; // source
					DISEL = {1'b0, !MREQ};		
					WE[1:0] = WBIT;		// RASEL_HI, RASEL_LO
					IFETCH = ~|FETCH[0][2:0]; // nop
				end else begin 		// stage2, TMP16 -> R/M/Acc
					RASEL = FETCH[0][4] ? 3'b000 : RM; // destination
					BBSEL = 2'b00;		// TMP16
					WR = MREQ;
					WE[1:0] = WRBIT;		// RASEL_HI, RASEL_LO
				end
			end
// --------------------------------  in --------------------------------
			15:	begin
				RASEL = 3'b000; // AX/AL
				WE[1:0] = {WORD, 1'b1};		// RASEL_HI, RASEL_LO
				DISEL = 2'b00;	//DIN
				MREQ = 1'b0;
				ISIZE = FETCH[0][3] ? 1 : 2;
				EAC = 4'b1111;
				NULLSEG = 1'b1;
			end
// --------------------------------  out --------------------------------
			16:	begin
				DOSEL = 2'b11;	// AX
				MREQ = 1'b0;
				WR = 1'b1;
				ISIZE = FETCH[0][3] ? 1 : 2;
				EAC = 4'b1111;
				NULLSEG = 1'b1;
			end
// --------------------------------  xlat --------------------------------
			17: begin
				WORD = 1'b0;
				RASEL = 3'b000; 	// AL
				WE[0] = 1'b1;		// RASEL_LO
				EAC = 4'b1010;		// XLAT
				DISEL = 2'b00;		// DIN 
				ISIZE = 1;
				NOBP = 1'b1;	// for RSSEL
			end
// --------------------------------  lea --------------------------------
			18: begin
				RASEL = REG; 			// destination
				WE[1:0] = {&MOD ? 2'b00 : 2'b11};		// RASEL_HI, RASEL_LO
				DISEL = 2'b10;			// EA
				ASEL = 1'b1;
				MREQ = 1'b0;
				ISIZE = ISIZES;
			end
// --------------------------------  lds, les --------------------------------
			19: begin
				WORD = 1'b1;
				DISEL = 2'b00;			// DIN
				ASEL = 1'b1;
				if(!STAGE[0]) begin		// stage1, load offset
					RASEL = REG; 			// destination
					IFETCH = &MOD;			// bad opcode
					IRQ = IFETCH;
					ISIZE = 0;
					WE[3:0] = {2'b10, IFETCH ? 2'b00 : 2'b11};		// TMP16, RASEL_HI, RASEL_LO
				end else begin				// stage2, load segment
					RASEL = FETCH[0][0] ? 3'b011 : 3'b000; // ds/es
					WE[2] = 1'b1;			// RSSEL
					EAC = 4'b1011;			// TMP16 + 2
					ISIZE = ISIZES;
				end
			end
// --------------------------------  lahf, sahf --------------------------------
			20: begin
				WORD = 1'b0;
				RASEL = 3'b100; 		// AH
				WE = {!FETCH[0][0], 2'b00, FETCH[0][0], 1'b0};		// FLAGS, IP, RASEL_HI
				ALUOP = FETCH[0][0] ? 30 : 31;			// PASS/STORE FLAGS
				MREQ = 1'b0;
				ISIZE = 1;
			end
// --------------------------------  pushf --------------------------------
			21: begin
				WORD = 1'b1;
				RASEL = 3'b100;		// write SP
				RSSEL = 2'b10;			// SS
				WE[1:0] = 2'b11;			
				ALUOP = 30;				// pass flags
				EAC = 4'b1000;			// SP - 2
				DISEL = 2'b10;			// ADDR
				WR = 1'b1;
				ISIZE = 1;
			end
// --------------------------------  popf --------------------------------
			22: begin
				ISIZE = 1;
				IFETCH = STAGE[0];
				if(!STAGE[0]) begin	// stage1, pop TMP16
					RSSEL = 2'b10;			// SS
					WE[3] = 1'b1;			// TMP16
					EAC = 4'b1001;			// SP
					DISEL = 2'b00;
				end else begin			// stage2, TMP16 to FLAGS
					BASEL = 1'b0;
					WE[4] = 1'b1;			// flags
					ALUOP = 31;				// store flags
					MREQ = 1'b0;
				end
			end
// --------------------------------  add, or, adc, sbb, and, sub, xor, cmp, test R/M with R --------------------------------
			23: begin									
				ASEL = 1'b1;
				if(!(&MOD || STAGE[0])) begin	// stage1, load op from memory in TMP16
					WE[3] = 1'b1;		// TMP16
					DISEL = 2'b00;			// DIN
					IFETCH = 1'b0;
				end else begin						// stage2, execute and write			
					ALUOP = {2'b00, FETCH[0][2] ? 3'b100 : FETCH[0][5:3]};	// test = and
					MREQ = ~&MOD & ~|FETCH[0][2:1] & ~&FETCH[0][5:3];		// no cmp or test
					WR = MREQ;
					WE = {3'b100, WR | &FETCH[0][5:3] | FETCH[0][2] ? 2'b00 : WBIT};		// flags, RASEL_HI, RASEL_LO
					ISIZE = ISIZES;
				end
			end
// --------------------------------  add, or, adc, sbb, and, sub, xor, cmp R/M with Imm --------------------------------
			24: begin
				ASEL = 1'b1;
				if(!(&MOD || STAGE[0])) begin	// stage1, load op from memory in TMP16
					WE[3] = 1'b1;			// TMP16
					DISEL = 2'b00;			// DIN
					IFETCH = 1'b0;
				end else begin						// stage2, execute and write		
					BASEL = &MOD;
					RASEL = RM;
					BBSEL = 2'b10;			// imm
					ALUOP = {2'b00, FETCH[1][5:3]};
					ISEL = ISELS;
					DEXT = FETCH[0][1];
					MREQ = ~BASEL & ~&FETCH[1][5:3];
					WR = MREQ;
					WE = {3'b100, WR  | &FETCH[1][5:3]? 2'b00 : WBIT};		// flags, RASEL_HI, RASEL_LO
					ISIZE = ISIZEI;
				end
			end
// --------------------------------  add, or, adc, sbb, and, sub, xor, cmp, test Acc with Imm --------------------------------
			25: begin // test
				BASEL = 1'b1;
				RASEL = 3'b000; 	// acc
				BBSEL = 2'b10;					// imm
				WE = {3'b100, &FETCH[0][5:3] | FETCH[0][7] ? 2'b00 : WBIT};		// flags, RASEL_HI, RASEL_LO
				ALUOP = {2'b00, FETCH[0][7] ? 3'b100 : FETCH[0][5:3]};
				ISEL = 2'b00;
				MREQ = 1'b0;
				ISIZE = WORD ? 3 : 2;
			end
// --------------------------------  inc/dec R16 --------------------------------
			26: begin
				WORD = 1'b1;
				BASEL = 1'b1;
				RASEL = FETCH[0][2:0]; // destination
				WE = 5'b10011;		// flags, RASEL_HI, RASEL_LO
				ALUOP = {2'b01, FETCH[0][5:3]};
				MREQ = 1'b0;
				ISIZE = 1;
			end
// --------------------------------  test/???/not/neg/mul/imul/div/idiv --------------------------------
			27: begin
				ASEL = 1'b1;
				case(REG)					
					3'b000: begin		// TEST R/M with Imm
						if(!(&MOD || |STAGE[1:0])) begin	// stage1, load op from memory in TMP16
							DISEL = 2'b00;		
							WE[3] = 1'b1;					// mem in TMP16
							IFETCH = 1'b0;
						end else begin
							BASEL = &MOD;
							RASEL = RM; 	// destination
							BBSEL = 2'b10;			// imm
							ALUOP = 5'b00100;		// AND
							ISEL = ISELS;
							MREQ = 1'b0;
							WE[4] = 1'b1;			// flags
							ISIZE = ISIZEW;
						end
					end
					3'b010, 3'b011: begin	// NOT/NEG R/M
						if(!(&MOD || |STAGE[1:0])) begin	// stage1, load op from memory in TMP16
							DISEL = 2'b00;		
							WE[3] = 1'b1;					// mem in TMP16
							IFETCH = 1'b0;
						end else begin
							BASEL = &MOD;
							RASEL = RM; 	// destination
							ALUOP = {2'b01, REG};
							MREQ = ~&MOD;
							WR = MREQ;
							WE = {REG[0], 2'b00, WRBIT};		// flags, RASEL_HI, RASEL_LO
							ISIZE = ISIZES;
						end
					end
					3'b100, 3'b101: begin	// MUL, IMUL
						ISIZE = ISIZES;
						ALUOP = {4'b1000, REG[0]};		// BASEL = FETCH[0][1] = 1
						WE[4] = 1'b1;			// fix MUL/IMUL 8bit flags bug
						case(STAGE[1:0])
							2'b00: begin		// stage1, RA -> TMP16, RB (mem) -> FETCH
								MREQ = ~&MOD;
								DISEL = {1'b0, MREQ};
								RASEL = 3'b000; // AX
								DOSEL = 2'b11;	 
								IFETCH = 1'b0;
							end
							2'b01: begin			// stage2, write AX
								WE[1:0] = 2'b11;	// flags, RASEL_HI, RASEL_LO 
								RASEL = 3'b000;	// AX
								MREQ = 1'b0;
								IFETCH = ~FETCH[0][0];
							end
							2'b10: begin			// stage 2, write DX
								WE[1:0] = 2'b11;	// flags, RASEL_HI, RASEL_LO	
								RASEL = 3'b010;	// DX
								MREQ = 1'b0;
							end
						endcase
					end
					3'b110, 3'b111: begin	// div, idiv
						ISIZE = ISIZES;
						IRQL = 3'b000;	// divide overflow
						MREQ = 1'b0;
						case({DIVEND, STAGE[1:0]})
							3'b000: begin		// stage1, RB (mem) -> FETCH
								MREQ = ~&MOD;
								DISEL = {1'b0, MREQ};
								DOSEL = 2'b11;	 
								IFETCH = 1'b0;
								DIVSTAGE = ~QSGN;
							end
							3'b001: begin	// stage2, pre dec AX
//								WORD = 1'b1;
								RASEL = 3'b000; // AX
								WE[1:0] = 2'b11;		// RASEL_HI, RASEL_LO
								ALUOP = 5'b01001;		// DEC
								IFETCH = 1'b0;
								ALUSTAGE = ~(DIVQSGN && FETCH[0][0] && COUT);
							end
							3'b010: begin // stage3, pre dec DX
								RASEL = 3'b010; 	// DX
								WE[1:0] = 2'b11;		// RASEL_HI, RASEL_LO
								ALUOP = 5'b01001;		// DEC
								IFETCH = 1'b0;
							end
							3'b011, 3'b111: begin	// stage4, div loop
								RASEL = WORD ? 3'b010 : 3'b100; // DX/AH
								BBSEL = 2'b10;		// imm
								WE[1:0] = {1'b1, WORD};		// RASEL_HI, RASEL_LO
								ALUOP = {2'b00, DIVSGN ? 3'b000 : 3'b101};	// add/sub
								ISEL = 2'b01;
								DIVSTAGE = ~DIVEND;
								ALUSTAGE = ~DIVEND | ~DIVQSGN;
								DIVOP = 1'b1;
//								IRQ = ~|STAGE[6:3] & DIVC & ~(STAGE[2] & DIVSGN); - DIV bug, fixed 23Dec2012
								IRQ = ~|STAGE[6:3] & DIVC & (~STAGE[2] | (~DIVSGN & IDIV)); // early overflow for positive quotient
								IFETCH = (DIVEND && ~DIVQSGN && ~DIVRSGN) || IRQ;
							end
							3'b100: begin		// stage5, post inc R
								RASEL = WORD ? 3'b010 : 3'b100; // DX/AH
								WE[1:0] = {1'b1, WORD};		// RASEL_HI, RASEL_LO
								ALUOP = 5'b01000;	// inc
								IFETCH = ~DIVSGN;
							end
							default: begin	// stage6, post inc Q
								RASEL = 3'b000; // AX/AL
								WE[1:0] = {WORD, 1'b1};		// RASEL_HI, RASEL_LO
								ALUOP = 5'b01000;	// inc
//								IRQ = SOUT ^ DIVSGN;	// overflow for negative quotient - fixed 12Apr2013 - IDIV bug when Q=0
								IRQ = ~(FIN[7] | (FETCH[0][0] ? AX[15] : AX[7])); // overflow for negative quotient
							end
						endcase
					end
					default: begin		// bad opcode
						MREQ = 1'b0;
						ISIZE = 0;
						IRQ = 1'b1;
					end
				endcase
			end
// --------------------------------  imul imm --------------------------------
			28: begin
				ASEL = 1'b1;
				if(!STAGE[0]) begin	// stage1, load op from memory (or RA) in TMP16
					RASEL = RM;
					DISEL = 2'b00;			// DIN
					DOSEL = 2'b11;
					ISEL = ISELS;
					DEXT = FETCH[0][1];
					BBSEL = 2'b10;			// imm
					MREQ = ~&MOD;
					WE[3] = MREQ;			// TMP16
					IFETCH = 1'b0;
				end else begin						// stage2, execute and write		
					RASEL = REG;
					ALUOP = 5'b10001;		// imul
					MREQ = 1'b0;
					WE = 5'b10011;		// flags, RASEL_HI, RASEL_LO
					ISIZE = ISIZEI;
				end
			end
// --------------------------------  aad --------------------------------
			29: begin
				MREQ = 1'b0;
				WORD = 1'b0;
				BASEL = 1'b1;
				IFETCH = &STAGE[1:0];
				case(STAGE[1:0])
					2'b00: begin	// stage1, load AH in TMP16, move imm in FETCH
						RASEL = 3'b100;		// AH
						DISEL = 2'b00;			// DIN
						DOSEL = 2'b11;			// write FETCH
						ISEL = 2'b00;			// RB -> FETCH
						BBSEL = 2'b10;			// imm
					end
					2'b01: begin				// stage2, TMP16 <- TMP16 * 10
						ALUOP = 5'b10000;		// mul
						WE[3] = 1'b1;			// TMP16
					end
					2'b10: begin			// stage3, AL <- TMP16 + AL
						RASEL = 3'b000; 	// AL
						BBSEL = 2'b00;		// TMP16
						WE = 5'b10001;		// flags, RASEL_LO
						ALUOP = 5'b00000;	// ADD
					end
					2'b11: begin			// stage4, AH <- 0
						RASEL = 3'b100; 	// AH
						RBSEL = 3'b100; 	// AH
						WE[1] = 1'b1;		// RASEL_HI
						ALUOP = 5'b00101;	// SUB
						ISIZE = 2;
					end
				endcase
			end
// --------------------------------  daa, das, aaa, aas --------------------------------
			30: begin
				WORD = FETCH[0][4];
				RASEL = 3'b000; 	// AX,AL
				WE = {3'b100, FETCH[0][4], 1'b1};		// flags, RASEL_HI, RASEL_LO
				ALUOP = {2'b01, FETCH[0][5:3]};
				MREQ = 1'b0;
				ISIZE = 1;
			end
// --------------------------------  shift/rot --------------------------------
			31: begin	// imm
				ALUOP = {4'b1110, FETCH[0][4:1] != 4'b1000};
				ASEL = 1'b1;
				if(!(&MOD || STAGE[0])) begin	// stage1, load op from memory in TMP16
					WE[3] = 1'b1;			// TMP16
					DISEL = 2'b00;			// DIN
					IFETCH = 1'b0;
				end else begin						// stage2, execute and write		
					BASEL = &MOD && ~|STAGE[2:1];
					RASEL = RM;
					BBSEL = FETCH[0][1] ? 2'b01 : 2'b10; // imm/reg
					RBSEL = 3'b001;		// CL
					ISEL = ISELS;
					IRQ = REG == 3'b110;					
					MREQ = ~&MOD && ~NULLSHIFT && ~ALUCONT && ~IRQ;
					WR = MREQ;
					WE = NULLSHIFT || IRQ ? 5'b00000 : ALUCONT ? 5'b11000 : {3'b100, WRBIT};		// flags, TMP16, RASEL_HI, RASEL_LO
					IFETCH = ~ALUCONT || IRQ;
					ALUSTAGE = 1'b1;
					if(IRQ) ISIZE = 0;
					else case({|FETCH[0][4:1], DISP16, AEXT})
						3'b100:	ISIZE = 2;
						3'b000, 3'b101: ISIZE = 3;
						3'b001, 3'b110: ISIZE = 4;
						default: ISIZE = 5;
					endcase
				end
			end
// --------------------------------  (rep)movs --------------------------------
			32: begin
				BASEL = 1'b1;
				AEXT = 1'b0;
				DISP16 = 1'b0;
				NOBP = 1'b1;	// for RSSEL
				if(!STAGE[0]) begin		// stage1, read DS:[SI] in TMP16, inc/dec SI
					RASEL = 3'b110; 	// SI
					ALUOP = {4'b0100, FLAGS[10]};	
					EAC = 4'b0100;		// SI+DISP
					DISEL = 2'b11;		// ALU 16bit
					IFETCH = RCXZ;	// REP & CX==0
					MREQ = ~RCXZ;
					WE = IFETCH ? 5'b00000 : 5'b01011;		// TMP16, RASEL_HI, RASEL_LO
				end else begin			// stage2, write TMP16 in ES:[DI], inc/dec DI, dec CX
					RASEL = 3'b111; 	// DI
					RSSEL = 2'b00;		// ES
					WE[1:0] = 2'b11;		// RASEL_HI, RASEL_LO
					ALUOP = {4'b0100, FLAGS[10]};	
					EAC = 4'b0101;		// DI + DISP
					DISEL = 2'b11;		// ALU 16bit
					DOSEL = 2'b10;		// TMP16	 	
					WR = 1'b1;
					IFETCH = NRORCXLE1;  // not REP or CX<=1
					DECCX = CPUStatus[4];
					REPINT = 1'b1;
				end
				ISIZE = IFETCH ? 1 : 0;
			end
// --------------------------------  (rep)cmps --------------------------------
			33: begin
				DISP16 = 1'b0;
				AEXT = 1'b0;
				NOBP = 1'b1;	// for RSSEL
				case(STAGE[1:0])
					2'b00: begin		// stage1, read ES:[DI] in FETCH[3:2], inc/dec DI
						RASEL = 3'b111; 	// SI
						RSSEL = 2'b00;		// ES
						ALUOP = {4'b0100, FLAGS[10]};	
						EAC = 4'b0101;		// DI+DISP
						DISEL = 2'b11;		// ALU 16bit
						DOSEL = 2'b11;		// read data to FETCH
						IFETCH = RCXZ;//(~|CXZ || (CPUStatus[3] ^ TZF));	// REP & CX==0
						MREQ = ~RCXZ;
						WE[1:0] = IFETCH ? 2'b00 : 2'b11;		// RASEL_HI, RASEL_LO
					end
					2'b01: begin		// stage2, read DS:[SI] in TMP16, inc/dec SI
						RASEL = 3'b110; 	// DI
						ALUOP = {4'b0100, FLAGS[10]};	
						EAC = 4'b0100;		// SI+DISP
						DISEL = 2'b11;		// ALU 16bit
						IFETCH = 1'b0;
						WE[3:0] = 4'b1011;		// RASEL_HI, RASEL_LO
					end
					2'b10: begin		// stage3, compare TMP16 with imm, set flags, dec CX
						BASEL = 1'b0;			// TMP16
						BBSEL = 2'b10;			// imm
						ISEL = 2'b01;
						WE[4] = 1'b1;			// flags
						ALUOP = 5'b00111;		// cmp
						MREQ = 1'b0;
						IFETCH = NRORCXLE1 | (CPUStatus[3] ^ CMPS);
						DECCX = CPUStatus[4];
						ALUSTAGE = 1'b1;
						REPINT = 1'b1;
					end
				endcase
				ISIZE = IFETCH ? 1 : 0;
			end
// --------------------------------  (rep)scas --------------------------------
			34: begin
				DISP16 = 1'b0;
				AEXT = 1'b0;
				if(!STAGE[0]) begin	// stage1, read ES:[DI] in TMP16, inc/dec DI
					RASEL = 3'b111; 	// DI
					RSSEL = 2'b00;		// ES
					ALUOP = {4'b0100, FLAGS[10]};	
					EAC = 4'b0101;		// DI+DISP
					DISEL = 2'b11;		// ALU 16bit
					IFETCH = RCXZ;//(~|CXZ || (CPUStatus[3] ^ TZF));	// REP & CX==0
					MREQ = ~RCXZ;
					WE[3:0] = IFETCH ? 4'b0000 : 4'b1011;		// TMP16, RASEL_HI, RASEL_LO
				end else begin	//stage2, compare AL/AX with TMP16, set flags, dec CX
					RASEL = 3'b000;		// AL/AX
					BBSEL = 2'b00;			// TMP16
					WE[4] = 1'b1;			// flags
					ALUOP = 5'b00111;		// cmp
					MREQ = 1'b0;
					IFETCH = NRORCXLE1 | (CPUStatus[3] ^ SCAS);
					DECCX = CPUStatus[4];
					REPINT = 1'b1;
				end
				ISIZE = IFETCH ? 1 : 0;
			end
// --------------------------------  (rep)lods --------------------------------
			35: begin
				BASEL = 1'b1;
				DISP16 = 1'b0;
				AEXT = 1'b0;
				NOBP = 1'b1;	// for RSSEL
				if(!STAGE[0]) begin		// stage1, read DS:[SI] in AL/AX
					RASEL = 3'b000; 	// AX
					EAC = 4'b0100;		// SI+DISP
					DISEL = 2'b00;		// DIN
					IFETCH = RCXZ;	// REP & CX==0
					MREQ = ~RCXZ;
					WE[1:0] = IFETCH ? 2'b00 : {WORD, 1'b1};		// RASEL_HI, RASEL_LO
				end else begin 		// stage2, inc/dec SI, dec CX
					RASEL = 3'b110; 	// SI
					ALUOP = {4'b0100, FLAGS[10]};	
					DISEL = 2'b11;		// ALU 16bit
					IFETCH = NRORCXLE1;  // nor REP or CX<=1
					MREQ = 1'b0;
					WE[1:0] = 2'b11;		// RASEL_HI, RASEL_LO
					DECCX = CPUStatus[4];
					REPINT = 1'b1;
				end
				ISIZE = IFETCH ? 1 : 0;
			end
// --------------------------------  (rep)stos --------------------------------
			36: begin  // stage1, write AL/AX in ES:[DI], inc/dec DI, dec CX
				BASEL = 1'b1;
				DISP16 = 1'b0;
				AEXT = 1'b0;
				RASEL = 3'b111; 	// DI
				RSSEL = 2'b00;		// ES
				ALUOP = {4'b0100, FLAGS[10]};	
				EAC = 4'b0101;		// DI + DISP
				DISEL = 2'b11;		// ALU 16bit
				DOSEL = 2'b11;		// AX
				IFETCH = NRORCXLE1;  // not REP or CX<=1
				MREQ = ~RCXZ;
				WR = ~RCXZ;
				WE[1:0] = {MREQ, MREQ};		// RASEL_HI, RASEL_LO
				DECCX = CPUStatus[4] && |CXZ;
				REPINT = 1'b1;
				ISIZE = IFETCH ? 1 : 0;
			end
// --------------------------------  (rep)ins --------------------------------
			37: begin
				BASEL = 1'b1;
				DISP16 = 1'b0;
				AEXT = 1'b0;
				if(!STAGE[0]) begin	// stage1, input in TMP16
					WE[3] = 1'b1;		// TMP16
					DISEL = 2'b00;		//DIN
					IFETCH = RCXZ;		// REP & CX==0
					MREQ = 1'b0;
					EAC = {~RCXZ, 3'b111};
					NULLSEG = 1'b1;
				end else begin			// stage2, write TMP16 in ES:[DI], inc/dec DI, dec CX
					RASEL = 3'b111; 	// DI
					RSSEL = 2'b00;		// ES
					WE[1:0] = 2'b11;		// RASEL_HI, RASEL_LO
					ALUOP = {4'b0100, FLAGS[10]};	
					EAC = 4'b0101;		// DI + DISP
					DISEL = 2'b11;		// ALU 16bit
					DOSEL = 2'b10;		// TMP16	 	
					WR = 1'b1;
					IFETCH = NRORCXLE1;  // not REP or CX<=1
					DECCX = CPUStatus[4];
					REPINT = 1'b1;
				end
				ISIZE = IFETCH ? 1 : 0;
			end
// --------------------------------  (rep)outs --------------------------------
			38: begin
				BASEL = 1'b1;
				DISP16 = 1'b0;
				NOBP = 1'b1;	// for RSSEL
				if(!STAGE[0]) begin		// stage1, read DS:[SI] in TMP16, inc/dec SI
					AEXT = 1'b0;		// tweak for speed (can be moved outside <if>)
					RASEL = 3'b110; 	// SI
					ALUOP = {4'b0100, FLAGS[10]};	
					EAC = 4'b0100;		// SI+DISP
					DISEL = 2'b11;		// ALU 16bit
					IFETCH = RCXZ;	// REP & CX==0
					MREQ = ~RCXZ;
					WE[3:0] = IFETCH ? 4'b0000 : 4'b1011;		// TMP16, RASEL_HI, RASEL_LO
				end else begin			// stage2, out TMP16 at port DX, dec CX
					DOSEL = 2'b10;		// TMP16	 	
					MREQ = 1'b0;
					EAC = 4'b1111;
					WR = 1'b1;
					IFETCH = NRORCXLE1;  // not REP or CX<=1
					DECCX = CPUStatus[4];
					REPINT = 1'b1;
					NULLSEG = 1'b1;
				end
				ISIZE = IFETCH ? 1 : 0;
			end
// --------------------------------  call/jmp direct near --------------------------------
			39: begin	// jump long
				WORD = 1'b1;
				ALUOP = 0;			// ADD
				DISEL = 2'b10;		// ADDR
				ISIZE = FETCH[0][1] ? 2 : 3;
				RASEL = 3'b100;	// write SP
				RSSEL = 2'b10;		// SS
				DOSEL = 2'b01;		// IP
				EAC = 4'b1000;		// SP - 2
				BBSEL = 2'b10;		// imm
				ISEL = 2'b00;
				DEXT = FETCH[0][1];
				MREQ = !FETCH[0][0];
				WR = MREQ;
				WE[1:0] = FETCH[0][0] ? 2'b00 : 2'b11;		// RASEL_HI/RASEL_LO
				IPWSEL = 1'b0;		// ALU
			end
// --------------------------------  call/jmp far imm --------------------------------
			40: begin
				WORD = 1'b1;
				ALUOP = 31;				// PASS B
				case({STAGE[1:0], FETCH[0][6]})
					3'b000: begin	// stage1, push CS
						RASEL = 3'b100;		// write SP
						BBSEL = 2'b11;
						RBSEL = 3'b001; 		// CS
						RSSEL = 2'b10;			// SS
						EAC = 4'b1000;			// SP - 2
						DISEL = 2'b10;			// ADDR
						WR = 1'b1;
						IFETCH = 1'b0;
						WE[1:0] = 2'b11;			// RASEL_HI/RASEL_LO
					end 
					3'b010, 3'b001: begin	// stage2, load CS
						RASEL = 3'b001; 	// CS
						BBSEL = 2'b10;		// imm
						WE[2] = 1'b1;		// RSSEL
						ISEL = 2'b10;
						MREQ = 1'b0;
						IFETCH = 1'b0;
					end
					3'b100, 3'b011: begin	// stage3, push IP, load IP
						RASEL = 3'b100; 	// write SP
						BBSEL = 2'b10;		// imm
						RSSEL = 2'b10;		// SS
						EAC = 4'b1000;		// SP - 2
						DISEL = 2'b10;		// ADDR
						DOSEL = 2'b01;		// IP	 
						ISEL = 2'b00;
						MREQ = FETCH[0][4];
						WR = MREQ;
						WE[1:0] = {WR, WR};
						IPWSEL = 1'b0;		// ALU
						ISIZE = 5;
					end
				endcase
			end
// --------------------------------  ret near --------------------------------
			41: begin
				WORD = 1'b1;		// fix RET n alignment bug - 03Apr2013
				ISIZE = FETCH[0][0] ? 1 : 3;
				IFETCH = STAGE[0];
				ALUOP = 31;			// PASS B
				if(!STAGE[0]) begin	// stage1, pop TMP16
					RSSEL = 2'b10;			// SS
					WE[3] = 1'b1;			// TMP16
					ASEL = 1'b0;
					AEXT = 1'b0;
					DISP16 = 1'b1;
					EAC = {1'b1, !FETCH[0][0], 2'b01};			// SP + 2 (+ imm) 
					DISEL = 2'b00;
				end else begin			// stage2, TMP16 to IP
					BBSEL = 2'b00;		// TMP16	
					IPWSEL = 1'b0;		// ALU
					MREQ = 1'b0;
				end
			end
// --------------------------------  ret far --------------------------------
			42: begin
				WORD = 1'b1;		// fix RET n alignment bug - 03Apr2013
				ALUOP = 31;			// PASS B
				RSSEL = 2'b10;			// SS
				IFETCH = STAGE[1];
				DISEL = 2'b00;			// DIN
				case(STAGE[1:0])
					2'b00: begin	// stage1, pop IP in TMP16
						WE[3] = 1'b1;			// TMP16
						EAC = 4'b1001;			// SP + 2
					end
					2'b01: begin		// stage2, pop CS, TMP16 <- RA
						RASEL = 3'b001;	// CS
						WE[2] = 1'b1;	
						EAC = {1'b1, !FETCH[0][0], 2'b01};
						ASEL = 1'b0;
						AEXT = 1'b0;
						DISP16 = 1'b1;
						BASEL = 1'b0;		// RA <- TMP16
					end
					2'b10: begin		// stage3, IP <- TMP16
						BBSEL = 2'b00;		// TMP16
						IPWSEL = 1'b0;		// ALU
						MREQ = 1'b0;
						ISIZE = FETCH[0][0] ? 1 : 3;
					end
				endcase
			end
// --------------------------------  iret --------------------------------
			43: begin  
				ALUOP = 31;			// PASS B
				RSSEL = 2'b10;			// SS
				ISIZE = 1;
				IFETCH = &STAGE[1:0];
				case(STAGE[1:0])
					2'b00: begin	// stage1, pop IP in FETCH
						EAC = 4'b1001;			// SP + 2
						DOSEL = 2'b11;			// write FETCH
					end
					2'b01: begin		// stage2, pop CS
						RASEL = 3'b001;	// CS
						WE[2] = 1'b1;	
						EAC = {1'b1, !FETCH[0][0], 2'b01};
						DISEL = 2'b00;
						ASEL = 1'b0;
						AEXT = 1'b0;
						DISP16 = 1'b1;
					end
					2'b10: begin		// stage3, pop flags in TMP16
						WE[3] = 1'b1;			// TMP16
						EAC = 4'b1001;			// SP
						DISEL = 2'b00;
					end 
					2'b11: begin		// stage4, IP <- FETCH, FLAGS <- TM
						BASEL = 1'b0;
						BBSEL = 2'b10;		// imm
						WE[4] = 1'b1;		// flags
						ISEL = 2'b01;
						DEXT = 1'b0;
						IPWSEL = 1'b0;		// ALU
						MREQ = 1'b0;
					end
				endcase
			end
// --------------------------------  cbw/cwd --------------------------------
			44: begin
				RASEL = FETCH[0][0] ? 3'b010 : 3'b100; // AH/DX
				RBSEL = 3'b000; // AX
				WE[1:0] = {1'b1, FETCH[0][0]};		// RASEL_HI, RASEL_LO
				ALUOP = {4'b1101, FETCH[0][0]};	// cbw/cwd
				MREQ = 1'b0;
				ISIZE = 1;
			end
// --------------------------------  JMP cond, LOOP, LOOPZ, LOOPNZ, JCXZ --------------------------------
			45: begin  // loop/loopz/loopnz/jcxz
				ALUOP = 0;			// add
				ISIZE = 2;
				DOSEL = 2'b01;		// IP
				BBSEL = 2'b10;		// imm
				ISEL = 2'b00;
				DEXT = 1'b1;
				MREQ = 1'b0;
				IPWSEL = FETCH[0][7] ? LOOPC[FETCH[0][1:0]] : (JMPC[FETCH[0][3:1]] ~^ FETCH[0][0]);
				DECCX = FETCH[0][7] && (FETCH[0][1:0] != 2'b11);
			end
// --------------------------------  CLC, CMC, STC, CLD, STD, CLI, STI --------------------------------
			46: begin
				WE[4] = 1'b1;		// flags
				ALUOP = 5'b11001;	// flag op
				ISIZE = 1;
				MREQ = 1'b0;
			end
// --------------------------------  enter --------------------------------
			47: begin
				WORD = 1'b1;
				WE[1:0] = 2'b11;			// RASEL_HI/RASEL_LO
				case(STAGE[1:0])
					2'b00: begin		// push BP
						RASEL = 3'b100;		// write SP
						RBSEL = 3'b101; 		// BP
						RSSEL = 2'b10;			// SS
						EAC = 4'b1000;			// SP - 2
						DISEL = 2'b10;			// ADDR
						ALUOP = 31;				// PASS B
						WR = 1'b1;
						IFETCH = 1'b0;
					end
					2'b01: begin		// mov BP, SP
						RASEL = 3'b101; // BP
						RBSEL = 3'b100; // SP
						ALUOP = 31;				// PASS B
						MREQ = 1'b0;
						IFETCH = 1'b0;
					end
					2'b10: begin		// sub SP, imm
						BASEL = 1'b1;
						RASEL = 3'b100; // SP
						BBSEL = 2'b10;
						ALUOP = 5'b00101;	// sub
						ISEL = 2'b00;
						MREQ = 1'b0;
						ISIZE = 4;
					end
				endcase
			end	
// --------------------------------  leave --------------------------------
			48: begin
				WE[1:0] = 2'b11;			// RASEL_HI/RASEL_LO
				if(!STAGE[0]) begin	// stage1, mov sp, bp
					RASEL = 3'b100; // BP
					RBSEL = 3'b101; // SP
					ALUOP = 31;				// PASS B
					MREQ = 1'b0;
					IFETCH = 1'b0;
				end else begin			// stage2, pop bp
					RASEL = 3'b101; 	// BP
					RSSEL = 2'b10;			// SS
					EAC = 4'b1001;			// SP
					DISEL = 2'b00;			// DIN
					ISIZE = 1;
				end
			end
// --------------------------------  int, int 3, into --------------------------------
			49: begin
				MREQ = 1'b0;
				ISIZE = FETCH[0][1:0] == 2'b01 ? 2 : 1;
				IRQ = ~FETCH[0][1] | FLAGS[11];
				IRQL = FETCH[0][1] ? 3'b100 : {1'b0, ~FETCH[0][1:0]};	// 4, 2, 3
			end
// --------------------------------  bound --------------------------------
			50: begin
				WORD = 1'b1;
				DOSEL = 2'b11;			// load FETCH with DIN
				case(STAGE[1:0])
					2'b00: begin // stage1,  read min in FETCH, ADDR16 in TMP16
						RASEL = 3'b100; 		// SP	- write SP to SP for getting ADDR16 to TMP16
						BBSEL = 2'b01;
						RBSEL = 3'b100; 		// SP
						ALUOP = 31;				// PASS B
						WE[3:0] = 4'b1011;			// TMP16, RASEL_HI, RASEL_LO
						ASEL = 1'b1;
						IRQ = &MOD;		// illegal instruction
						ISIZE = 0;
						IFETCH = IRQ;
					end
					2'b01, 2'b10, 2'b11: begin	// stage2,3,4 load min/max in TMP16, compare reg with imm
						BBSEL = 2'b10;			// imm
						ALUOP = 5'b00111;		// cmp
						EAC = 4'b1011;			// TMP16 + 2
						ISEL = 2'b01;
						IRQ = STAGE[1] & (STAGE[0] ? ~TLF & ~TZF : TLF);
						MREQ = ~&STAGE[1:0];
						IFETCH = IRQ | ~MREQ;
						IRQL = 3'b101;
						ISIZE = IRQ ? 0 : ISIZES;	// return address is BOUND
					end
				endcase
			end
// --------------------------------  hlt --------------------------------
			51: begin
				IFETCH = 1'b0;
				HALT = 1'b1;
				MREQ = 1'b0;
			end
// --------------------------------  wait --------------------------------
			52: begin	// do nothing
				ISIZE = 1;
				MREQ = 1'b0;
			end
// --------------------------------  aam --------------------------------
			53: begin
				MREQ = 1'b0;
				IRQL = 3'b000;	// divide overflow
				ISIZE = 2;
				case({DIVEND, STAGE[1:0]})
					3'b000: begin	// stage1, clear AH
						BASEL = 1'b0;	 // TMP16
						RASEL = 3'b100; // AH
						BBSEL = 2'b00;	 // TMP16
						WE[1] = 1'b1;	 // RASEL_HI
						ALUOP = 5'b00101;	// sub
						IFETCH = 1'b0;
					end
					3'b001, 3'b101: begin	// stage2, div
						RASEL = 3'b100; // AH
						BASEL = 1'b1;
						BBSEL = 2'b10;	 // imm
						WE[1] = 1'b1;	 // RASEL_HI
						ALUOP = 5'b00101;	// sub
						ISEL = 2'b00;
						DIVSTAGE = ~DIVEND;
						ALUSTAGE = ~DIVEND;
						DIVOP = 1'b1;
						IRQ = ~|STAGE[6:2] & DIVC;
						IFETCH = IRQ;
					end
					3'b110: begin	// stage 3, AH <- AL, TMP16 <- AH
						RASEL = 3'b100; // AH
						BASEL = 1'b1;
						RBSEL = 3'b000; // AL
						WE[1] = 1'b1;	// RASEL_HI
						ALUOP = 31;			// PASS B
						IFETCH = 1'b0;
					end
					3'b111: begin // stage4, AL <- TMP16 | TMP16, set flags
						RASEL = 3'b000; // dest = AL
						BASEL = 1'b0;	 // TMP16
						BBSEL = 2'b00;	 // TMP16
						WE = 5'b10001;	 // FLAGS, RASEL_LO
						ALUOP = 5'b00001;		// OR
					end
				endcase
			end
// --------------------------------  reset, irq, nmi, intr --------------------------------
			54:
				if(STAGE[3]) begin
					if(FETCH[5][0]) begin	// reset
						RASEL = {1'b0, STAGE[1:0]}; 	// ES, CS, SS, DS
						WE = 5'b11100;		// FLAGS, TMP16, RSSEL
						BASEL = 1'b0;		// TMP16
						BBSEL = 2'b00;		// TMP16
						ALUOP = STAGE[0] ? STAGE[1] ? 31 : 5'b01001 : 5'b00101;	// pass, dec, sub
						MREQ = 1'b0;
						IPWSEL = 1'b0;		// ALU16
						IFETCH = &STAGE[1:0];
					end else case({FETCH[5][1], STAGE[2:0]}) 
						4'b1000: begin		// stage1 intr
							DOSEL = 2'b11;	// read FETCH[2]	 
							MREQ = 1'b0;
							IFETCH = 1'b0;
							INTA = 1'b1;
						end 
						4'b1001, 4'b0000: begin // stage1 irq, nmi, tf, stage2 intr - push flags, clear TF, IF
							RASEL = 3'b100;		// write SP
							RSSEL = 2'b10;			// SS
							WE = 5'b10011;			// flags, SP	
							ALUOP = 30;				// pass flags
							EAC = 4'b1000;			// SP - 2
							DISEL = 2'b10;			// ADDR
							WR = 1'b1;
							IFETCH = 1'b0;
						end
						4'b1010, 4'b0001: begin // stage2 irq, nmi, tf, stage3 intr - push CS
							RASEL = 3'b100;		// write SP
							BBSEL = 2'b11;
							RBSEL = 3'b001; 		// CS
							RSSEL = 2'b10;			// SS
							ALUOP = 31;				// PASS B
							EAC = 4'b1000;			// SP - 2
							DISEL = 2'b10;			// ADDR
							WR = 1'b1;
							IFETCH = 1'b0;
							WE[1:0] = 2'b11;			// RASEL_HI/RASEL_LO
						end
						4'b1011, 4'b0010: begin // stage3 irq, nmi, tf, stage4 intr - read offset in FETCH, ADDR16 in TMP16
							RASEL = 3'b100; 		// SP	- write SP to SP for getting ADDR16 to TMP16
							BBSEL = 2'b01;
							RBSEL = 3'b100; 		// SP
							ALUOP = 31;				// PASS B
							EAC = 4'b1110;			// int vector
							WE[3:0] = 4'b1011;	// TMP16, RASEL_HI, RASEL_LO
							ASEL = 1'b1;
							DISP16 = 1'b1;
							DOSEL = 2'b11;			// load FETCH with DIN
							IFETCH = 1'b0;
							NULLSEG = 1'b1;
						end
						4'b1100, 4'b0011: begin // stage4 irq, nmi, tf, stage5 intr - read CS
							RASEL = 3'b001; 		// CS
							WE[2] = 1'b1;			// RSSEL
							EAC = 4'b1011;			// TMP16 + 2
							DISEL = 2'b00;			// DIN
							IFETCH = 1'b0;
							NULLSEG = 1'b1;
						end
						4'b1101, 4'b0100: begin // stage5 irq, nmi, tf, stage6 intr - push IP, jump
							RASEL = 3'b100; 	// write SP
							BBSEL = 2'b10;		// imm
							RSSEL = 2'b10;		// SS
							ALUOP = 31;			// PASS B
							EAC = 4'b1000;		// SP - 2
							DISEL = 2'b10;		// ADDR
							DOSEL = 2'b01;		// IP	 
							ISEL = 2'b01;
							WR = 1'b1;
							WE[1:0] = 2'b11;
							ISIZE = FETCH[5][2] ? 1 : 0;
							IPWSEL = 1'b0;		// ALU
						end
					endcase
				end else begin
					MREQ = 1'b0;
					ISIZE = 0;
					IRQ = 1'b1;
				end
			
// --------------------------------  bad opcode/esc --------------------------------
			default: begin
				MREQ = 1'b0;
				ISIZE = 0;
				IRQ = 1'b1;
				if(FETCH[0][7:3] == 5'b11011) IRQL = 3'b111; // esc
			end
		endcase
	 end



// instruction pre-decoder
function [5:0]ICODE;
	input [7:0]INSTR;
	begin
		case(INSTR[7:0])
// --------------------------------  mov R/M to/from R/SR  --------------------------------
			8'b10001000, 8'b10001001, 8'b10001010, 8'b10001011, 
			8'b10001110, 8'b10001100: ICODE = 0;
// --------------------------------  mov IMM to R/M  --------------------------------
			8'b11000110, 8'b11000111: ICODE = 1;	
// --------------------------------  mov IMM to R --------------------------------
			8'b10110_000, 8'b10110_001, 8'b10110_010, 8'b10110_011, 8'b10110_100, 8'b10110_101, 8'b10110_110, 8'b10110_111,
			8'b10111_000, 8'b10111_001, 8'b10111_010, 8'b10111_011, 8'b10111_100, 8'b10111_101, 8'b10111_110, 8'b10111_111: ICODE = 2;
// --------------------------------  mov mem to/from ACC --------------------------------
			8'b10100000, 8'b10100001,
			8'b10100010, 8'b10100011: ICODE = 3;
// --------------------------------  segment override prefix --------------------------------
			8'b001_00_110, 8'b001_01_110, 8'b001_10_110, 8'b001_11_110: ICODE = 4;
// --------------------------------  rep prefix --------------------------------
			8'b11110010, 8'b11110011: ICODE = 5;
// --------------------------------  lock prefix --------------------------------
			8'b11110000: ICODE = 6;
// --------------------------------  FF block --------------------------------
			8'b11111111, 8'b11111110:	ICODE = 7;
// --------------------------------  push R/SR --------------------------------
			8'b01010_000, 8'b01010_001, 8'b01010_010, 8'b01010_011, 8'b01010_100, 8'b01010_101, 8'b01010_110, 8'b01010_111,
			8'b000_00_110, 8'b000_01_110, 8'b000_10_110, 8'b000_11_110: ICODE = 8;
// --------------------------------  push Imm --------------------------------
			8'b01101000, 8'b01101010: ICODE = 9;		
// --------------------------------  pusha --------------------------------
			8'b01100000: ICODE = 10;
// --------------------------------  pop R/M --------------------------------
			8'b10001111: ICODE = 11;			
// --------------------------------  pop R / SR --------------------------------
			8'b01011_000, 8'b01011_001, 8'b01011_010, 8'b01011_011, 8'b01011_100, 8'b01011_101, 8'b01011_110, 8'b01011_111,
			8'b000_00_111, 8'b000_10_111, 8'b000_11_111: ICODE = 12;
// --------------------------------  popa --------------------------------
			8'b01100001: ICODE = 13;
// --------------------------------  xchg R with R/M/Acc --------------------------------
			8'b10000110, 8'b10000111,
			8'b10010000, 8'b10010001, 8'b10010010, 8'b10010011, 8'b10010100, 8'b10010101, 8'b10010110, 8'b10010111: ICODE = 14;
// --------------------------------  in --------------------------------
			8'b11100100, 8'b11100101,
			8'b11101100, 8'b11101101:	ICODE = 15;
// --------------------------------  out --------------------------------
			8'b11100110, 8'b11100111,
			8'b11101110, 8'b11101111:	ICODE = 16;
// --------------------------------  xlat --------------------------------
			8'b11010111: ICODE = 17;
// --------------------------------  lea --------------------------------
			8'b10001101: ICODE = 18;
// --------------------------------  lds, les --------------------------------
			8'b11000101, 8'b11000100: ICODE = 19;
// --------------------------------  lahf, sahf --------------------------------
			8'b10011111, 8'b10011110: ICODE = 20;
// --------------------------------  pushf --------------------------------
			8'b10011100: ICODE = 21;
// --------------------------------  popf --------------------------------
			8'b10011101: ICODE = 22;
// --------------------------------  add, or, adc, sbb, and, sub, xor, cmp, test R/M with R --------------------------------
			8'b00000000, 8'b00000001, 8'b00000010, 8'b00000011,		// add
			8'b00001000, 8'b00001001, 8'b00001010, 8'b00001011,		// or
			8'b00010000, 8'b00010001, 8'b00010010, 8'b00010011,		// adc
			8'b00011000, 8'b00011001, 8'b00011010, 8'b00011011,		// sbb
			8'b00100000, 8'b00100001, 8'b00100010, 8'b00100011,		// and
			8'b00101000, 8'b00101001, 8'b00101010, 8'b00101011,		// sub
			8'b00110000, 8'b00110001, 8'b00110010, 8'b00110011,		// xor
			8'b00111000, 8'b00111001, 8'b00111010, 8'b00111011,		// cmp
			8'b10000100, 8'b10000101: ICODE = 23;									// test 
// --------------------------------  add, or, adc, sbb, and, sub, xor, cmp R/M with Imm --------------------------------
			8'b10000000, 8'b10000001, 8'b10000010, 8'b10000011: ICODE = 24;
// --------------------------------  add, or, adc, sbb, and, sub, xor, cmp, test Acc with Imm --------------------------------
			8'b00000100, 8'b00000101, 		// add
			8'b00001100, 8'b00001101, 		// or
			8'b00010100, 8'b00010101, 		// adc
			8'b00011100, 8'b00011101, 		// sbb
			8'b00100100, 8'b00100101, 		// and
			8'b00101100, 8'b00101101, 		// sub
			8'b00110100, 8'b00110101, 		// xor
			8'b00111100, 8'b00111101,  	// cmp
			8'b10101000, 8'b10101001: ICODE = 25; // test
// --------------------------------  inc/dec R16 --------------------------------
			8'b01000000, 8'b01000001, 8'b01000010, 8'b01000011, 8'b01000100, 8'b01000101, 8'b01000110, 8'b01000111,
			8'b01001000, 8'b01001001, 8'b01001010, 8'b01001011, 8'b01001100, 8'b01001101, 8'b01001110, 8'b01001111: ICODE = 26;
// --------------------------------  test/???/not/neg/mul/imul/div/idiv --------------------------------
			8'b11110110, 8'b11110111: ICODE = 27;
// --------------------------------  imul imm --------------------------------
			8'b01101001, 8'b01101011: ICODE = 28;
// --------------------------------  aad --------------------------------
			8'b11010101: ICODE = 29;
// --------------------------------  daa, das, aaa, aas --------------------------------
			8'b00_100_111, 8'b00_101_111, 8'b00_110_111, 8'b00_111_111: ICODE = 30;
// --------------------------------  shift/rot --------------------------------
			8'b11010000, 8'b11010001,			// 1
			8'b11010010, 8'b11010011,			// CL
			8'b11000000, 8'b11000001: ICODE = 31;	// imm
// --------------------------------  (rep)movs --------------------------------
			8'b10100100, 8'b10100101: ICODE = 32;
// --------------------------------  (rep)cmps --------------------------------
			8'b10100110, 8'b10100111: ICODE = 33;
// --------------------------------  (rep)scas --------------------------------
			8'b10101110, 8'b10101111: ICODE = 34;
// --------------------------------  (rep)lods --------------------------------
			8'b10101100, 8'b10101101: ICODE = 35;
// --------------------------------  (rep)stos --------------------------------
			8'b10101010, 8'b10101011: ICODE = 36;  // stage1, write AL/AX in ES:[DI], inc/dec DI, dec CX
// --------------------------------  (rep)ins --------------------------------
			8'b01101100, 8'b01101101: ICODE = 37;
// --------------------------------  (rep)outs --------------------------------
			8'b01101110, 8'b01101111: ICODE = 38;
// --------------------------------  call/jmp direct near --------------------------------
			8'b11101000, 			// call long
			8'b11101011,			// jump short
			8'b11101001: ICODE = 39;	// jump long
// --------------------------------  call/jmp far imm --------------------------------
			8'b10011010, 8'b11101010: ICODE = 40;
// --------------------------------  ret near --------------------------------
			8'b11000011, 8'b11000010: ICODE = 41;
// --------------------------------  ret far --------------------------------
			8'b11001011, 8'b11001010: ICODE = 42;
// --------------------------------  iret --------------------------------
			8'b11001111: ICODE = 43;  
// --------------------------------  cbw/cwd --------------------------------
			8'b10011000, 8'b10011001: ICODE = 44;
// --------------------------------  JMP cond, LOOP, LOOPZ, LOOPNZ, JCXZ --------------------------------
			8'b01110000, 8'b01110001,	// JO/JNO
			8'b01110010, 8'b01110011,	// JB/JNB
			8'b01110100, 8'b01110101,	// JE/JNE
			8'b01110110, 8'b01110111,	// JBE/JA
			8'b01111000, 8'b01111001,	// JS/JNS
			8'b01111010, 8'b01111011,	// JP/JNP
			8'b01111100, 8'b01111101,	// JL/JNL
			8'b01111110, 8'b01111111,	// JLE/JG
			8'b11100010, 8'b11100001, 8'b11100000, 8'b11100011: ICODE = 45;  // loop/loopz/loopnz/jcxz
// --------------------------------  CLC, CMC, STC, CLD, STD, CLI, STI --------------------------------
			8'b11111000, 8'b11110101, 8'b11111001, 8'b11111100, 8'b11111101, 8'b11111010, 8'b11111011: ICODE = 46;
// --------------------------------  enter --------------------------------
			8'b11001000: ICODE = 47;
// --------------------------------  leave --------------------------------
			8'b11001001: ICODE = 48;
// --------------------------------  int, int 3, into --------------------------------
			8'b11001101, 8'b11001100, 8'b11001110: ICODE = 49;
// --------------------------------  bound --------------------------------
			8'b01100010: ICODE = 50;
// --------------------------------  hlt --------------------------------
			8'b11110100: ICODE = 51;
// --------------------------------  wait --------------------------------
			8'b10011011: ICODE = 52;	// do nothing
// --------------------------------  aam --------------------------------
			8'b11010100: ICODE = 53;	
// --------------------------------  reset, irq, nmi, intr --------------------------------
			8'b00001111: ICODE = 54;		
// --------------------------------  bad opcode/esc --------------------------------
			default: ICODE = 55;
		endcase
	end
endfunction

endmodule

