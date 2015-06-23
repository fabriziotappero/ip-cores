////////////////////////////////////////////////////////////////////////////
////									////
//// T6507LP IP Core	 						////
////									////
//// This file is part of the T6507LP project				////
//// http://www.opencores.org/cores/t6507lp/				////
////									////
//// Description							////
//// T6507LP Package							////
////									////
//// To Do:								////
//// - Documentation							////
//// - Check syntax & Compile						////
////									////
//// Author(s):								////
//// - Gabriel Oshiro Zardo, gabrieloshiro@gmail.com			////
//// - Samuel Nascimento Pagliarini (creep), snpagliarini@gmail.com	////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
//// Copyright (C) 2001 Authors and OPENCORES.ORG			////
////									////
//// This source file may be used and distributed without		////
//// restriction provided that this copyright statement is not		////
//// removed from the file and that any derivative work contains	////
//// the original copyright notice and the associated disclaimer.	////
////									////
//// This source file is free software; you can redistribute it		////
//// and/or modify it under the terms of the GNU Lesser General		////
//// Public License as published by the Free Software Foundation;	////
//// either version 2.1 of the License, or (at your option) any		////
//// later version.							////
////									////
//// This source is distributed in the hope that it will be		////
//// useful, but WITHOUT ANY WARRANTY; without even the implied		////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR		////
//// PURPOSE. See the GNU Lesser General Public License for more	////
//// details.								////
////									////
//// You should have received a copy of the GNU Lesser General		////
//// Public License along with this source; if not, download it		////
//// from http://www.opencores.org/lgpl.shtml				////
////									////
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
////									////
////			Processor Status Register			////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
//// C - Carry Flag							////
//// Z - Zero Flag							////
//// I - Interrupt Disable						////
//// D - Decimal Mode							////
//// B - Break Command							////
//// 1 - Constant One							////
//// V - oVerflow Flag							////
//// N - Negative Flag							////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
////	    -------------------------------------------------		////
////	    |  N  |  V  |  1  |  B  |  D  |  I  |  Z  |  C  |		////
////	    -------------------------------------------------		////
////									////
////////////////////////////////////////////////////////////////////////////

localparam C = 3'b000;
localparam Z = 3'b001;
localparam I = 3'b010;
localparam D = 3'b011;
localparam B = 3'b100;
//localparam 1 = 3'b101;
localparam V = 3'b110;
localparam N = 3'b111;


// All opcodes are listed in alphabetic order.

////////////////////////////////////////////////////////////////////////////
////									////
////			    Addressing Modes				////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
//// IMP - Implicit							////
//// ACC - Accumulator							////
//// IMM - Immediate							////
//// ZPG - Zero Page							////
//// ZPX - Zero Page,X							////
//// ZPY - Zero Page,Y							////
//// REL - Relative							////
//// ABS - Absolute							////
//// ABX - Absolute,X							////
//// ABY - Absolute,Y							////
//// IDX - (Indirect,X)							////
//// IDY - (Indirect),Y							////
////									////
////////////////////////////////////////////////////////////////////////////

localparam	IMP = 4'h0,
		ACC = 4'h1,
		IMM = 4'h2,
		ZPG = 4'h3,
		ZPX = 4'h4,
		ZPY = 4'h5,
		REL = 4'h6,
		ABS = 4'h7,
		ABX = 4'h8,
		ABY = 4'h9,
		IDX = 4'hA,
		IDY = 4'hB;


//TODO: Document all opcodes
////////////////////////////////////////////////////////////////////////////
////									////
////			  ADC - Add with Carry				////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
//// A,Z,C,N = A+M+C							////
////									////
//// This instruction adds the contents of a memory location to the	////
//// accumulator together with the carry bit. If overflow occurs the	////
//// carry bit is set, this enables multiple byte addition to be	////
//// performed.								////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
//// C - Not affected							////
//// Z - Not affected							////
//// I - Not affected							////
//// D - Not affected							////
//// B - Not affected							////
//// V - Not affected							////
//// N - Not affected							////
////									////
////////////////////////////////////////////////////////////////////////////
localparam	ADC_IMM = 8'h69,
		ADC_ZPG = 8'h65,
		ADC_ZPX = 8'h75,
		ADC_ABS = 8'h6D,
		ADC_ABX = 8'h7D,
		ADC_ABY = 8'h79,
		ADC_IDX = 8'h61,
		ADC_IDY = 8'h71;

localparam	AND_IMM = 8'h29,
		AND_ZPG = 8'h25,
		AND_ZPX = 8'h35,
		AND_ABS = 8'h2D,
		AND_ABX = 8'h3D,
		AND_ABY = 8'h39,
		AND_IDX = 8'h21,
		AND_IDY = 8'h31;

localparam	ASL_ACC = 8'h0A,
		ASL_ZPG = 8'h06,
		ASL_ZPX = 8'h16,
		ASL_ABS = 8'h0E,
		ASL_ABX = 8'h1E;

localparam	BCC_REL = 8'h90;

localparam	BCS_REL = 8'hB0;

localparam	BEQ_REL = 8'hF0;

localparam	BIT_ZPG = 8'h24,
		BIT_ABS = 8'h2C;

localparam	BMI_REL = 8'h30;

localparam	BNE_REL = 8'hD0;

localparam	BPL_REL = 8'h10;

localparam	BRK_IMP = 8'h00;

localparam	BVC_REL = 8'h50;

localparam	BVS_REL = 8'h70;

localparam	CLC_IMP = 8'h18;

localparam	CLD_IMP = 8'hD8;

localparam	CLI_IMP = 8'h58;

localparam	CLV_IMP = 8'hB8;

localparam	CMP_IMM = 8'hC9,
		CMP_ZPG = 8'hC5,
		CMP_ZPX = 8'hD5,
		CMP_ABS = 8'hCD,
		CMP_ABX = 8'hDD,
		CMP_ABY = 8'hD9,
		CMP_IDX = 8'hC1,
		CMP_IDY = 8'hD1;

localparam	CPX_IMM = 8'hE0,
		CPX_ZPG = 8'hE4,
		CPX_ABS = 8'hEC;

localparam	CPY_IMM = 8'hC0,
		CPY_ZPG = 8'hC4,
		CPY_ABS = 8'hCC;

localparam	DEC_ZPG = 8'hC6,
		DEC_ZPX = 8'hD6,
		DEC_ABS = 8'hCE,
		DEC_ABX = 8'hDE;

localparam	DEX_IMP = 8'hCA;

localparam	DEY_IMP = 8'h88;

localparam	EOR_IMM = 8'h49,
		EOR_ZPG = 8'h45,
		EOR_ZPX = 8'h55,
		EOR_ABS = 8'h4D,
		EOR_ABX = 8'h5D,
		EOR_ABY = 8'h59,
		EOR_IDX = 8'h41,
		EOR_IDY = 8'h51;

localparam	INC_ZPG = 8'hE6,
		INC_ZPX = 8'hF6,
		INC_ABS = 8'hEE,
		INC_ABX = 8'hFE;

localparam	INX_IMP = 8'hE8;

localparam	INY_IMP = 8'hC8;

localparam	JMP_ABS = 8'h4C,
		JMP_IND = 8'h6C;

localparam	JSR_ABS = 8'h20;

localparam	LDA_IMM = 8'hA9,
		LDA_ZPG = 8'hA5,
		LDA_ZPX = 8'hB5,
		LDA_ABS = 8'hAD,
		LDA_ABX = 8'hBD,
		LDA_ABY = 8'hB9,
		LDA_IDX = 8'hA1,
		LDA_IDY = 8'hB1;

localparam	LDX_IMM = 8'hA2,
		LDX_ZPG = 8'hA6,
		LDX_ZPY = 8'hB6,
		LDX_ABS = 8'hAE,
		LDX_ABY = 8'hBE;

localparam	LDY_IMM = 8'hA0,
		LDY_ZPG = 8'hA4,
		LDY_ZPX = 8'hB4,
		LDY_ABS = 8'hAC,
		LDY_ABX = 8'hBC;

localparam	LSR_ACC = 8'h4A,
		LSR_ZPG = 8'h46,
		LSR_ZPX = 8'h56,
		LSR_ABS = 8'h4E,
		LSR_ABX = 8'h5E;

localparam	NOP_IMP = 8'hEA;

localparam	ORA_IMM = 8'h09,
		ORA_ZPG = 8'h05,
		ORA_ZPX = 8'h15,
		ORA_ABS = 8'h0D,
		ORA_ABX = 8'h1D,
		ORA_ABY = 8'h19,
		ORA_IDX = 8'h01,
		ORA_IDY = 8'h11;

localparam	PHA_IMP = 8'h48;

localparam	PHP_IMP = 8'h08;

localparam	PLA_IMP = 8'h68;

localparam	PLP_IMP = 8'h28;

localparam	ROL_ACC = 8'h2A,
		ROL_ZPG = 8'h26,
		ROL_ZPX = 8'h36,
		ROL_ABS = 8'h2E,
		ROL_ABX = 8'h3E;

localparam	ROR_ACC = 8'h6A,
		ROR_ZPG = 8'h66,
		ROR_ZPX = 8'h76,
		ROR_ABS = 8'h6E,
		ROR_ABX = 8'h7E;

localparam	RTI_IMP = 8'h40;

localparam	RTS_IMP = 8'h60;

localparam	SBC_IMM = 8'hE9,
		SBC_ZPG = 8'hE5,
		SBC_ZPX = 8'hF5,
		SBC_ABS = 8'hED,
		SBC_ABX = 8'hFD,
		SBC_ABY = 8'hF9,
		SBC_IDX = 8'hE1,
		SBC_IDY = 8'hF1;

localparam	SEC_IMP = 8'h38;

localparam	SED_IMP = 8'hF8;

localparam	SEI_IMP = 8'h78;

localparam	STA_ZPG = 8'h85,
		STA_ZPX = 8'h95,
		STA_ABS = 8'h8D,
		STA_ABX = 8'h9D,
		STA_ABY = 8'h99,
		STA_IDX = 8'h81,
		STA_IDY = 8'h91;

localparam	STX_ZPG = 8'h86,
		STX_ZPY = 8'h96,
		STX_ABS = 8'h8E;

localparam	STY_ZPG = 8'h84,
		STY_ZPX = 8'h94,
		STY_ABS = 8'h8C;

localparam	TAX_IMP = 8'hAA;

localparam	TAY_IMP = 8'hA8;

localparam	TSX_IMP = 8'hBA;

localparam	TXA_IMP = 8'h8A;

localparam	TXS_IMP = 8'h9A;

localparam	TYA_IMP = 8'h98;

// DDT did a job on me...
