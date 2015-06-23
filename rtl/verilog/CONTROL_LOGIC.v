// ============================================================================
//  CONTROL_LOGIC
//  - assorted control logic
//
//
//  (C) 2009,2010,2013  Robert Finch
//  robfinch[remove]@finitron.ca
//
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//
//
//  Verilog 
//
// ============================================================================
//
wire [15:0] sp_dec = sp - 16'd1;
wire [15:0] sp_inc = sp + 16'd1;
wire [15:0] ip_inc = ip + 16'd1;
wire [15:0] ip_dec = ip - 16'd1;
wire [15:0] cx_dec = cx - 16'd1;
wire [15:0] si_dec = si - 16'd1;
wire [15:0] di_dec = di - 16'd1;
wire [15:0] si_inc = si + 16'd1;
wire [15:0] di_inc = di + 16'd1;
wire [15:0] sp_dec2 = sp - 16'd2;
wire [15:0] sp_inc2 = sp + 16'd2;
wire [15:0] ip_inc2 = ip + 16'd2;
wire [15:0] ip_dec2 = ip - 16'd2;
wire [19:0] ea_inc = ea + 20'd1;
wire [19:0] ea_inc2 = ea + 20'd2;
wire [19:0] adr_o_inc = adr_o + 20'd1;
wire [4:0] modrm = {mod,rm};
wire [15:0] offsdisp = offset + disp16;

wire checkForInts = (prefix1==8'h00) && (prefix2==8'h00);
 
wire doCmp = ir==8'h38 || ir==8'h39 || ir==8'h3A || ir==8'h3B || ir==8'h3C || ir==8'h3D;


// Detect when to fetch the mod-r/m byte
//
wire fetch_modrm =
	ir==8'h00 || ir==8'h01 || ir==8'h02 || ir==8'h03 || // ADD
	ir==8'h08 || ir==8'h09 || ir==8'h0A || ir==8'h0B || // OR
	ir==8'h10 || ir==8'h11 || ir==8'h12 || ir==8'h13 ||	// ADC
	ir==8'h18 || ir==8'h19 || ir==8'h1A || ir==8'h1B || // SBB
	ir==8'h20 || ir==8'h21 || ir==8'h22 || ir==8'h23 || // AND
	ir==8'h28 || ir==8'h29 || ir==8'h2A || ir==8'h2B || // SUB
	ir==8'h30 || ir==8'h31 || ir==8'h32 || ir==8'h33 || // XOR
	ir==8'h38 || ir==8'h39 || ir==8'h3A || ir==8'h3B || // CMP
	ir==8'h3C || ir==8'h3D ||						    // CMP
	ir==8'h62 ||	// BOUND
	ir==8'h63 ||	// ARPL
	ir==8'h69 || ir==8'h6B ||							// IMUL
	ir[7:4]==4'h8 ||
	(ir[7]==1'b0 && ir[6]==1'b0 && ir[2]==1'b0) ||		// arithmetic
	(ir==8'h0F && ir2[7:4]==4'hA && ir2[2:1]==2'b10) ||
	ir==8'hC4 || ir==8'hC5 ||							// LES / LDS
	ir==8'hC6 || ir==8'hC7 || 							// MOV I
	ir==8'hC0 || ir==8'hC1 ||							// shift / rotate
	ir==8'hD0 || ir==8'hD1 || ir==8'hD2 || ir==8'hD3 ||	// shift / rotate
	ir==8'hF6 || ir==8'hF7 ||							// NOT / NEG / TEST / MUL / IMUL / DIV / IDIV
	ir==8'hFE || ir==8'hFF								// INC / DEC / CALL
	;

// Detect when to fetch the mod-r/m byte during a two byte opcode
//
wire fetch_modrm2 =
	ir2==8'h00 ||	// LLDT / LTR / STR / VERR / VERW
	ir2==8'h01 || 	// INVLPG / LGDT / LIDT / LMSW / SGDT / 
	ir2==8'h02 ||	// LAR
	ir2==8'h03 ||	// LSL
	ir2[7:4]==4'h9 ||
	ir2==8'hA4 || ir2==8'hAC || ir2==8'hA5 || ir2==8'hAD || // SHRD / SHLD
	ir2==8'hAF ||	// IMUL
	ir2==8'hB0 || ir2==8'hB1 ||		// CMPXCHG
	ir2==8'hB2 || ir2==8'hB4 || ir2==8'hB5 ||	// LSS / LFS / LGS
	ir2==8'hB6 || ir2==8'hB7 || ir2==8'hFE || ir2==8'hFF ||
	ir2==8'hA3 || ir2==8'hBA || ir2==8'hBB || ir2==8'hBC || ir2==8'hBD ||
	ir2==8'hC0 || ir2==8'hC1		// XADD
	;

wire fetch_data =
	ir==8'h8A || ir==8'h8B ||	// memory to register
	ir==8'hA0 || ir==8'hA1 ||	// memory to accumulator
	ir==8'h8E ||				// memory to segmenr register
	(ir==8'h0f && (ir2==8'hB6 || ir2==8'hB7 || ir2==8'hBE || ir2==8'hBf)) ||	// memory to register - needs more resolving.
	ir==`POP_AX ||
	ir==`POP_DX ||
	ir==`POP_CX ||
	ir==`POP_BX ||
	ir==`POP_SP ||
	ir==`POP_BP ||
	ir==`POP_SI ||
	ir==`POP_DI ||
	ir==8'h86 || ir==8'h87 || // exchange register with memory
	ir==`LDS ||
	ir==`LES ||
	(ir==`EXTOP && (ir2==`LFS || ir2==`LGS || ir2==`LSS)) ||
	ir==`POPF ||

	fetch_modrm;

wire store_data =
	(ir==8'h0F && ir2==8'h00 && rrr==3'd0 && mod!=2'b11) ||	// SLDT
	(ir==8'h0F && ir2==8'h00 && rrr==3'd1 && mod!=2'b11) ||	// STR
	(ir==8'h0F && ir2==8'h01 && rrr==3'd0 && mod!=2'b11) ||	// SGDT
	(ir==8'h0F && ir2==8'h01 && rrr==3'd1 && mod!=2'b11) ||	// SIDT
	(ir==8'h0F && ir2==8'h01 && rrr==3'd4 && mod!=2'b11) ||	// SMSW
	(ir==8'h00 && mod!=2'b11) ||	// ADD b
	(ir==8'h01 && mod!=2'b11) ||	// ADD w
	(ir==8'h08 && mod!=2'b11) ||	// OR b
	(ir==8'h09 && mod!=2'b11) ||	// OR w
	(ir==8'h10 && mod!=2'b11) ||	// ADC b
	(ir==8'h11 && mod!=2'b11) ||	// ADC w
	(ir==8'h18 && mod!=2'b11) ||	// SBB b
	(ir==8'h19 && mod!=2'b11) ||	// SBB w
	(ir==8'h20 && mod!=2'b11) ||	// AND b
	(ir==8'h21 && mod!=2'b11) ||	// AND w
	(ir==8'h28 && mod!=2'b11) ||	// SUB b
	(ir==8'h29 && mod!=2'b11) ||	// SUB w
	(ir==8'h30 && mod!=2'b11) ||	// XOR b
	(ir==8'h31 && mod!=2'b11) ||	// XOR w
	(ir==8'h63 && mod!=2'b11) ||	// ARPL
	(ir==8'hD0 && mod!=2'b11) ||	// byte shifts #1
	(ir==8'hD1 && mod!=2'b11) ||	// word shifts #1
	(ir==8'hD2 && mod!=2'b11) ||	// byte shifts CL
	(ir==8'hD3 && mod!=2'b11) ||	// word shifts CL
	(ir==8'hC0 && mod!=2'b11) ||	// byte shifts #n8
	(ir==8'hC1 && mod!=2'b11) ||	// word shifts #n8
	(hasFetchedModrm && (d==1'b0) && (mod!=2'b11)) ||
	ir==8'hA2 ||	// MOV mem8,AL
	ir==8'hA3 ||	// MOV mem16,AL
	((ir==8'h86 || ir==8'h87) && (mod!=2'b11))	|| // XCHG
	((ir==8'h88 || ir==8'h89) && (mod!=2'b11))	|| // MOV
	((ir==8'h6B || ir==8'h69) && (mod!=2'b11))	|| // IMUL
	((ir==8'hC6 || ir==8'hC7) && rrr==3'd0 && (mod!=2'b11))	|| // MOV mem,imm
	( ir==8'h8C && rrr[2]==1'b0 && (mod!=2'b11))	|| // MOV mem16,seg_reg
	((ir==8'hF6 || ir==8'hF7) && rrr==3'd2 && (mod!=2'b11))	|| // NOT
	((ir==8'hF6 || ir==8'hF7) && rrr==3'd3 && (mod!=2'b11))	|| // NEG
	((ir==8'hF6 || ir==8'hF7) && rrr==3'd4 && (mod!=2'b11))	|| // MUL
	((ir==8'hF6 || ir==8'hF7) && rrr==3'd5 && (mod!=2'b11))	|| // IMUL
	((ir==8'hF6 || ir==8'hF7) && rrr==3'd6 && (mod!=2'b11))	|| // DIV
	((ir==8'hF6 || ir==8'hF7) && rrr==3'd7 && (mod!=2'b11))	|| // IDIV
	((ir==8'hFE || ir==8'hFF) && rrr==3'd0 && (mod!=2'b11))	|| // INC
	((ir==8'hFE || ir==8'hFF) && rrr==3'd1 && (mod!=2'b11))	||   // DEC 
	((ir==8'h80 || ir==8'h81 || ir==8'h83) && (rrr!=3'b111) && (mod!=2'b11))	   // compare excluded
	;

wire bus_locked = prefix1==`LOCK || prefix2==`LOCK ||
	((ir==8'h86||ir==8'h87) && mod!=2'b11)
	;

wire is_prefix = 
	ir==`REPZ ||
	ir==`REPNZ ||
	ir==`LOCK ||
	ir==`CS ||
	ir==`DS ||
	ir==`ES ||
	ir==`SS
	;

wire tgt_reg8 =
	ir==8'h10 ||
	ir==8'h12
	
	;

/*
if (ir==8'h80 && mod==2'b11) tgt <= RM8; src <= IMM8;
if (ir==8'h81 && mod==2'b11) tgt <= RM16; src <= IMM16;
if (ir==8'h83 && mod==2'b11) tgt <= RM16; src <= IMM8;
if (ir==8'h80 && mod!=2'b11) tgt <= MEM8; src <= IMM8;
if (ir==8'h81 && mod!=2'b11) tgt <= MEM16; src <= IMM16;
if (ir==8'h83 && mod!=2'b11) tgt <= MEM16; src <= IMM8;
case(rrr)
3'b000: op <= `ADD;
3'b010: op <= `ADC;
3'b100: op <= `AND;
3'b111: op <= `CMP;
endcase
*/

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
wire lea = ir==`LEA;

wire hasPrefix = prefix1!=8'h00;
wire hasDoublePrefix = hasPrefix && prefix2!=8'h00;
wire repz = prefix1==`REPZ || prefix2==`REPZ;
wire repnz = prefix1==`REPNZ || prefix2==`REPNZ;

// ZF is tested only for SCAS, CMPS
wire repdone =
	((repz | repnz) & cxz) ||
	(repz && !zf && (ir==`SCASB||ir==`SCASW||ir==`CMPSB||ir==`CMPSW)) ||
	(repnz && zf && (ir==`SCASB||ir==`SCASW||ir==`CMPSB||ir==`CMPSW))
	;

