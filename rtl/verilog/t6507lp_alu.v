////////////////////////////////////////////////////////////////////////////
////                                                                    ////
//// T6507LP IP Core                                                    ////
////                                                                    ////
//// This file is part of the T6507LP project                           ////
//// http://www.opencores.org/cores/t6507lp/                            ////
////                                                                    ////
//// Description                                                        ////
//// 6507 ALU                                                           ////
////                                                                    ////
//// To Do:                                                             ////
//// - Search for TODO                                                  ////
////                                                                    ////
//// Author(s):                                                         ////
//// - Gabriel Oshiro Zardo, gabrieloshiro@gmail.com                    ////
//// - Samuel Nascimento Pagliarini (creep), snpagliarini@gmail.com     ////
////                                                                    ////
////////////////////////////////////////////////////////////////////////////
////                                                                    ////
//// Copyright (C) 2001 Authors and OPENCORES.ORG                       ////
////                                                                    ////
//// This source file may be used and distributed without               ////
//// restriction provided that this copyright statement is not          ////
//// removed from the file and that any derivative work contains        ////
//// the original copyright notice and the associated disclaimer.       ////
////                                                                    ////
//// This source file is free software; you can redistribute it         ////
//// and/or modify it under the terms of the GNU Lesser General         ////
//// Public License as published by the Free Software Foundation;       ////
//// either version 2.1 of the License, or (at your option) any         ////
//// later version.                                                     ////
////                                                                    ////
//// This source is distributed in the hope that it will be             ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied         ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR            ////
//// PURPOSE. See the GNU Lesser General Public License for more        ////
//// details.                                                           ////
////                                                                    ////
//// You should have received a copy of the GNU Lesser General          ////
//// Public License along with this source; if not, download it         ////
//// from http://www.opencores.org/lgpl.shtml                           ////
////                                                                    ////
////////////////////////////////////////////////////////////////////////////

`include "timescale.v"

module t6507lp_alu(clk,	reset_n, alu_enable, alu_result, alu_status, alu_opcode, alu_a,	alu_x, alu_y);

`include "t6507lp_package.v"

localparam DATA_SIZE = 8;
localparam [3:0] BCD_HIGH_LIMIT = 4'd9; 
localparam [3:0] BCD_FIX = 8'd6;

input wire       clk;
input wire       reset_n;
input wire       alu_enable;
input wire [DATA_SIZE - 1:0] alu_opcode;
input wire [DATA_SIZE - 1:0] alu_a;
output reg [DATA_SIZE - 1:0] alu_result;
output reg [DATA_SIZE - 1:0] alu_status;
output reg [DATA_SIZE - 1:0] alu_x;
output reg [DATA_SIZE - 1:0] alu_y;

reg [DATA_SIZE - 1:0] A;
reg [DATA_SIZE - 1:0] STATUS;
reg [DATA_SIZE + 1:0] result;
reg [DATA_SIZE - 1:0] op1;
reg [DATA_SIZE - 1:0] op2;
reg [DATA_SIZE - 1:0] bcdl;
reg [DATA_SIZE - 1:0] bcdh;
reg [DATA_SIZE - 1:0] bcdh2;
reg [DATA_SIZE - 1:0] AL;
reg [DATA_SIZE - 1:0] AH;

always @ (posedge clk or negedge reset_n)
begin
	if (reset_n == 1'b0) begin
		alu_result <= 10'd0;
		alu_status[C] <= 1'b0;
		alu_status[N] <= 1'b0;
		alu_status[V] <= 1'b0;
		alu_status[5] <= 1'b1;
		alu_status[Z] <= 1'b1;
		alu_status[I] <= 1'b0;
		alu_status[B] <= 1'b0;
		alu_status[D] <= 1'b0;
		A <= 8'd0;
		alu_x <= 8'd0;
		alu_y <= 8'd0;
	end
	else if ( alu_enable == 1'b1 ) begin
		case (alu_opcode)
			ADC_IMM, ADC_ZPG, ADC_ZPX, ADC_ABS, ADC_ABX, ADC_ABY,
			ADC_IDX, ADC_IDY, AND_IMM, AND_ZPG, AND_ZPX, AND_ABS,
			AND_ABX, AND_ABY, AND_IDX, AND_IDY, ASL_ACC, EOR_IMM,
			EOR_ZPG, EOR_ZPX, EOR_ABS, EOR_ABX, EOR_ABY, EOR_IDX,
			EOR_IDY, LSR_ACC, ORA_IMM, ORA_ZPG, ORA_ZPX, ORA_ABS,
			ORA_ABX, ORA_ABY, ORA_IDX, ORA_IDY, ROL_ACC, ROR_ACC,
			SBC_IMM, SBC_ZPG, SBC_ZPX, SBC_ABS, SBC_ABX, SBC_ABY,
			SBC_IDX, SBC_IDY, LDA_IMM, LDA_ZPG, LDA_ZPX, LDA_ABS,
			LDA_ABX, LDA_ABY, LDA_IDX, LDA_IDY, PLA_IMP : begin
				A          <= result[7:0];
				alu_result <= result[7:0];
				alu_status <= STATUS;
			end
			LDX_IMM, LDX_ZPG, LDX_ZPY, LDX_ABS, LDX_ABY, TAX_IMP,
			TSX_IMP, INX_IMP, DEX_IMP : begin
				alu_x      <= result[7:0];
				alu_status <= STATUS;
			end
			TXS_IMP : begin
				alu_x      <= result[7:0];
			end
			TXA_IMP, TYA_IMP : begin
				A          <= result[7:0];
				alu_status <= STATUS;
			end
			LDY_IMM, LDY_ZPG, LDY_ZPX, LDY_ABS, LDY_ABX, TAY_IMP,
			INY_IMP, DEY_IMP : begin
				alu_y      <= result[7:0];
				alu_status <= STATUS;
			end
			CMP_IMM, CMP_ZPG, CMP_ZPX, CMP_ABS, CMP_ABX, CMP_ABY,
			CMP_IDX, CMP_IDY, CPX_IMM, CPX_ZPG, CPX_ABS, CPY_IMM,
			CPY_ZPG, CPY_ABS : begin
				alu_status <= STATUS;
			end
			PHA_IMP, STA_ZPG, STA_ZPX, STA_ABS, STA_ABX, STA_ABY,
			STA_IDX, STA_IDY : begin
				alu_result <= result[7:0];
			end
			STX_ZPG, STX_ZPY, STX_ABS : begin
				alu_x <= result[7:0];
			end
			STY_ZPG, STY_ZPX, STY_ABS : begin
				alu_y <= result[7:0];
			end
			SEC_IMP : begin
				alu_status[C] <= 1'b1;
			end
			SED_IMP : begin
				alu_status[D] <= 1'b1;
			end
			SEI_IMP : begin
				alu_status[I] <= 1'b1;
			end
			CLC_IMP : begin
				alu_status[C] <= 1'b0;
			end
			CLD_IMP : begin
				alu_status[D] <= 1'b0;
			end
			CLI_IMP : begin
				alu_status[I] <= 1'b0;
			end
			CLV_IMP : begin
				alu_status[V] <= 1'b0;
			end
			BRK_IMP : begin
				alu_status[B] <= 1'b1;
			end
			PLP_IMP, RTI_IMP : begin
				alu_status[C] <= alu_a[C];
				alu_status[Z] <= alu_a[Z];
				alu_status[I] <= alu_a[I];
				alu_status[D] <= alu_a[D];
				alu_status[B] <= alu_a[B];
				alu_status[V] <= alu_a[V];
				alu_status[N] <= alu_a[N];
				alu_status[5] <= 1'b1;
			end
			BIT_ZPG, BIT_ABS : begin
				alu_status[Z] <= STATUS[Z];
				alu_status[V] <= alu_a[6];
				alu_status[N] <= alu_a[7];
			end
			INC_ZPG, INC_ZPX, INC_ABS, INC_ABX, DEC_ZPG, DEC_ZPX,
			DEC_ABS, DEC_ABX, ASL_ZPG, ASL_ZPX, ASL_ABS, ASL_ABX,
			LSR_ZPG, LSR_ZPX, LSR_ABS, LSR_ABX, ROL_ZPG, ROL_ZPX,
			ROL_ABS, ROL_ABX, ROR_ZPG, ROR_ZPX, ROR_ABS, ROR_ABX :
			begin
				alu_result <= result[7:0];
				alu_status <= STATUS;
			end
			default : begin
				alu_result <= 8'hFF;
				alu_status <= 8'hFF;
				A <= 8'hFF;
				alu_x <= 8'hFF;
				alu_y <= 8'hFF;
			end
		endcase
	end
end

always @ (*) begin
	op1       = A;
	op2       = alu_a;
	result    = {2'd0, A[7:0]};
	result[9:8] = 2'b00;
	STATUS[N] = alu_status[N];
	STATUS[C] = alu_status[C];
	STATUS[V] = alu_status[V];
	STATUS[B] = alu_status[B];
	STATUS[I] = alu_status[I];
	STATUS[D] = alu_status[D];
	STATUS[Z] = alu_status[Z];
	STATUS[5] = 1'b1;

	bcdl = 8'd0;
	bcdh = 8'd0;
	bcdh2 = 8'd0;
	AL = 8'd0;
	AH = 8'd0;

	if (alu_enable == 1'b1) begin
		case (alu_opcode)
			// BIT - Bit Test
			BIT_ZPG, BIT_ABS: begin
				result[7:0] = A & alu_a;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// PLA - Pull Accumulator
			PLA_IMP : begin
				result[7:0] = alu_a;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// TAX - Transfer Accumulator to X
			// TAY - Transfer Accumulator to Y
			// PHA - Push Accumulator
			// STA - Store Accumulator
			TAX_IMP, TAY_IMP, PHA_IMP, STA_ZPG, STA_ZPX, STA_ABS, STA_ABX,
			STA_ABY, STA_IDX, STA_IDY : begin
				result[7:0] = A;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// STX - Store X Register
			// TXA - Transfer X to Accumulator
			// TXS - Transfer X to Stack pointer
			STX_ZPG, STX_ZPY, STX_ABS, TXA_IMP, TXS_IMP : begin
				result[7:0] = alu_x;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
				
			// STY - Store Y Register
			// TYA - Transfer Y to Accumulator
			STY_ZPG, STY_ZPX, STY_ABS, TYA_IMP : begin
				result[7:0] = alu_y;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// INC - Increment memory
			INC_ZPG, INC_ZPX, INC_ABS, INC_ABX : begin
				result[7:0] = alu_a + 8'd1;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// INX - Increment X Register
			INX_IMP: begin
				result[7:0] = alu_x + 8'd1;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// INY - Increment Y Register
			INY_IMP : begin
				result[7:0] = alu_y + 8'd1;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// DEC - Decrement memory
			DEC_ZPG, DEC_ZPX, DEC_ABS, DEC_ABX : begin
				result[7:0] = alu_a - 8'd1;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// DEX - Decrement X register
			DEX_IMP: begin
				result[7:0] = alu_x - 8'd1;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// DEY - Decrement Y Register
			DEY_IMP: begin
				result[7:0] = alu_y - 8'd1;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// ADC - Add with carry
			ADC_IMM, ADC_ZPG, ADC_ZPX, ADC_ABS,
			ADC_ABX, ADC_ABY, ADC_IDX, ADC_IDY : begin
				if (!alu_status[D]) begin
					result = op1 + op2 + {7'd0, alu_status[C]}; // this looks so ugly but the operands are all 8 bits now
					STATUS[N] = result[7];
					STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
					STATUS[V] = ((op1[7] == op2[7]) && (op1[7] != result[7])) ? 1'b1 : 1'b0;
					STATUS[C] = result[8];
				end
				else begin
					AL = op1[3:0] + op2[3:0] + {7'd0, alu_status[C]};
					AH = op1[7:4] + op2[7:4];
					STATUS[Z] = (AL == 0 && AH == 0) ? 1'b1 : 1'b0;
					if (AL > {4'd0,BCD_HIGH_LIMIT}) begin
						bcdl = AL + {4'd0, BCD_FIX};
						bcdh = AH + 8'd1;
					end
					else begin
						bcdl = AL;
						bcdh = AH;
					end
					STATUS[N] = bcdh[3];
					STATUS[V] = ((op1[7] == op2[7]) && (op1[7] != bcdh[3])) ? 1'b1 : 1'b0;
					if (bcdh > {4'd0, BCD_HIGH_LIMIT}) begin
						bcdh2 = bcdh + {4'd0, BCD_FIX};
					end
					else begin
						bcdh2 = bcdh;
					end
					STATUS[C] = bcdh2[4] || bcdh2[5];
					result[7:0] = {bcdh2[3:0], bcdl[3:0]};
				end
			end
				
			// AND - Logical AND
			AND_IMM, AND_ZPG, AND_ZPX, AND_ABS, AND_ABX, AND_ABY, AND_IDX,
			AND_IDY : begin
				result[7:0] = A & alu_a;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// CMP - Compare
			CMP_IMM, CMP_ZPG, CMP_ZPX, CMP_ABS, CMP_ABX, CMP_ABY, CMP_IDX,
			CMP_IDY : begin
				result[7:0] = A - alu_a;
				STATUS[C] = (A >= alu_a) ? 1'b1 : 1'b0;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// EOR - Exclusive OR
			EOR_IMM, EOR_ZPG, EOR_ZPX, EOR_ABS, EOR_ABX, EOR_ABY,
			EOR_IDX, EOR_IDY : begin
				result[7:0] = A ^ alu_a;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// LDA - Load Accumulator
			// LDX - Load X Register
			// LDY - Load Y Register
			// TSX - Transfer Stack Pointer to X
			LDA_IMM, LDA_ZPG, LDA_ZPX, LDA_ABS, LDA_ABX, LDA_ABY, LDA_IDX,
			LDA_IDY, LDX_IMM, LDX_ZPG, LDX_ZPY, LDX_ABS, LDX_ABY, LDY_IMM,
			LDY_ZPG, LDY_ZPX, LDY_ABS, LDY_ABX, TSX_IMP : begin
				result[7:0] = alu_a;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// ORA - Logical OR
			ORA_IMM, ORA_ZPG, ORA_ZPX, ORA_ABS, ORA_ABX, ORA_ABY, ORA_IDX,
			ORA_IDY : begin
				result[7:0] = A | alu_a;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// SBC - Subtract with Carry
			SBC_IMM, SBC_ZPG, SBC_ZPX, SBC_ABS, SBC_ABX, SBC_ABY, SBC_IDX,
			SBC_IDY : begin
				result = op1 - op2 - (1'b1 - alu_status[C]);
				STATUS[N] = result[7];
				STATUS[V] = ((op1[7] ^ op2[7]) && (op1[7] ^ result[7])) ? 1'b1 : 1'b0;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[C] = ~(result[8] || result[9]);
				if (alu_status[D]) begin
					AL = op1[3:0] - op2[3:0] - (1'b1 - alu_status[C]);
					AH = op1[7:4] - op2[7:4];
					if (AL[4]) begin
						bcdl = AL - {4'd0, BCD_FIX};
						bcdh = AH - 8'd1;
					end
					else begin
						bcdl = AL;
						bcdh = AH;
					end
					if (bcdh[4]) begin
						bcdh2 = bcdh - {4'd0, BCD_FIX};
					end
					else begin
						bcdh2 = bcdh;
					end
					result[7:0] = {bcdh2[3:0],bcdl[3:0]};
				end
			end
  	
			// ASL - Arithmetic Shift Left
			ASL_ACC : begin
				{STATUS[C],result[7:0]} = {A, 1'b0};
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
			ASL_ZPG, ASL_ZPX, ASL_ABS, ASL_ABX : begin
				{STATUS[C],result[7:0]} = {alu_a, 1'b0};
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// LSR - Logical Shift Right
			LSR_ACC: begin
				{result[7:0],STATUS[C]} = {1'b0,A};
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
			LSR_ZPG, LSR_ZPX, LSR_ABS, LSR_ABX : begin
				{result[7:0],STATUS[C]} = {1'b0,alu_a};
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
				
			// ROL - Rotate Left
			ROL_ACC : begin
				{STATUS[C],result[7:0]} = {A,alu_status[C]};
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
			ROL_ZPG, ROL_ZPX, ROL_ABS, ROL_ABX : begin
				{STATUS[C],result[7:0]} = {alu_a,alu_status[C]};
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// ROR - Rotate Right
			ROR_ACC : begin
				{result[7:0],STATUS[C]} = {alu_status[C],A};
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
			ROR_ZPG, ROR_ZPX, ROR_ABS, ROR_ABX : begin
				{result[7:0], STATUS[C]} = {alu_status[C], alu_a};
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// CPX - Compare X Register
			CPX_IMM, CPX_ZPG, CPX_ABS : begin
				result[7:0] = alu_x - alu_a;
				STATUS[C] = (alu_x >= alu_a) ? 1'b1 : 1'b0;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			// CPY - Compare Y Register
			CPY_IMM, CPY_ZPG, CPY_ABS : begin
				result[7:0] = alu_y - alu_a;
				STATUS[C] = (alu_y >= alu_a) ? 1'b1 : 1'b0;
				STATUS[Z] = (result[7:0] == 0) ? 1'b1 : 1'b0;
				STATUS[N] = result[7];
			end
	
			default: begin
				result = 10'h3FF;
				STATUS = 8'hFF;
			end
		endcase
	end
end
endmodule
