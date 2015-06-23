/*
 * Decodes an opcode
 *
 * All decoders in one module
 *
 */
`include "defs.v"
 
module decoders(
    input wire clk_in,
	input wire [7:0] opcode,
	input wire [7:0] postbyte0,
	input wire page2_valid, // is 1 when the postbyte0 is a valid opcode (after it was loaded)
	input wire page3_valid, // is 1 when the postbyte0 is a valid opcode (after it was loaded)
 
	output reg [3:0] path_left_addr_lo,
	output reg [3:0] path_right_addr_lo,
	output reg [3:0] dest_reg_lo,
	output wire write_dest,
	output wire source_size,
	output wire result_size,
	output wire [1:0] path_left_memtype_o,
	output wire [1:0] path_right_memtype_o,
	output wire [1:0] dest_memtype_o,
	output reg [1:0] path_left_memtype_lo,
	output reg [1:0] path_right_memtype_lo,
	output reg [1:0] dest_memtype_lo,
	output wire operand_read_o, // reads 1 operand from memory
	output wire operand_write_o, // writes result to memory
 
    output wire [2:0] mode,
	output reg op_SYNC,
	output reg op_EXG,
	output reg op_TFR,
	output reg op_RTS,
	output reg op_RTI,
	output reg op_CWAI,
	output reg op_MUL,
	output reg op_SWI,
	output reg op_PUSH,
	output reg op_PULL,
	output reg op_LEA,
	output reg op_JMP,
	output reg op_JSR,
	output wire use_s,
 
    output wire [4:0] alu_opcode,
	output wire dest_flags_o
 
 
    );
reg [3:0] lr, rr, dr; // left, right and destination register addresses
reg [1:0] lm, rm, dm; // left, right and destination memory sizes
reg ss, sz, p2, p3; // S or *U, 16 or *8, page 2, page 3
reg [2:0] mo; // Addressing Mode
reg [4:0] aop; // ALU opcode
assign write_dest = (dr != `RN_INV);
assign source_size = (lr < `RN_ACCA) | sz | (rm == `MT_WORD);
// result size is used to determine the size of the argument
// to load, compare has no result, thus the source is used instead,
// why do we need the result size ?... because of tfr&exg 
assign result_size = (dr == `RN_INV) ? (lr < `RN_ACCA):
                     (dr < `RN_ACCA) ? 1:0;
 
// for registers, memory writes are handled differently
 
assign operand_read_o = (lm != `MT_NONE) | (rm != `MT_NONE);
assign operand_write_o = dm != `MT_NONE;
assign path_left_memtype_o = lm;
assign path_right_memtype_o = rm;
assign dest_memtype_o = dm;
assign dest_flags_o = (aop != `NOP) && (opcode != 8'h1a) && (opcode != 8'h1c);
assign use_s = ss;
assign mode = mo;
assign alu_opcode = aop;
 
always @(*)
    begin
        lr = `RN_INV;
        rr = `RN_INV;
        dr = `RN_INV;
        lm = `MT_NONE;
        rm = `MT_NONE;
        dm = `MT_NONE;
        mo = `NONE;
        aop = `NOP;
        ss = 1;
        sz = 0;
        op_SYNC = 0;
		op_EXG = 0;
		op_TFR = 0;
		op_RTS = 0;
		op_RTI = 0;
		op_CWAI = 0;
		op_MUL = 0;
		op_SWI = 0;
		op_PUSH = 0;
		op_PULL = 0;
		op_LEA = 0;
		op_JMP = 0;
		op_JSR = 0;
        p2 = 0;
        p3 = 0;
        case (opcode[7:4])
            4'h0:
                begin
                    mo = `DIRECT;
                    lm = `MT_BYTE; 
                    dm = `MT_BYTE;
                    case (opcode[3:0]) // Direct
                        4'h0: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `NEG; end // NEG
                        4'h1: begin end 
                        4'h2: begin end
                        4'h3: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `COM; end // COM
                        4'h4: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `LSR; end
                        4'h5: begin end
                        4'h6: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `ROR; end
                        4'h7: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `ASR; end
                        4'h8: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `LSL; end
                        4'h9: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `ROL; end
                        4'ha: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `DEC; end
                        4'hb: begin end
                        4'hc: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `INC; end
                        4'hd: begin lm = `MT_BYTE; aop = `TST; end
                        4'he: begin op_JMP = 1; end // JMP
                        4'hf: begin dm = `MT_BYTE; aop = `CLR; end 
                    endcase
                end
            4'h1:
                begin
                    case (opcode[3:0])
                        4'h0: begin p2 = 1; end
                        4'h1: begin p3 = 1; end
                        4'h2: begin end // nop
                        4'h3: begin op_SYNC = 1; end
                        4'h4: begin end
                        4'h5: begin end
                        4'h6: begin mo = `REL16; end // lbra
                        4'h7: begin mo = `REL16; op_JSR = 1; end
                        4'h8: begin end
                        4'h9: begin mo = `INHERENT; lr = `RN_ACCA; dr = `RN_ACCA; aop = `DAA; end
                        4'ha: begin mo = `IMMEDIATE; lr = `RN_CC; dr = `RN_CC; aop = `OR; end
                        4'hb: begin end
                        4'hc: begin mo = `IMMEDIATE; lr = `RN_CC; dr = `RN_CC; aop = `AND; end
                        4'hd: begin mo = `INHERENT; lr = `RN_ACCB; dr = `RN_ACCA; aop = `SEXT; end
                        4'he: begin op_EXG = 1; lr = postbyte0[7:4]; rr = postbyte0[3:0]; dr = postbyte0[3:0]; end
                        4'hf: begin op_TFR = 1; lr = postbyte0[7:4]; rr = postbyte0[3:0]; dr = postbyte0[3:0]; end
                    endcase
                end
            4'h2:
                begin
                    mo = `REL8;
                    case (opcode[3:0])
                        4'h0: begin end
                        4'h1: begin end
                        4'h2: begin end
                        4'h3: begin end
                        4'h4: begin end
                        4'h5: begin end
                        4'h6: begin end
                        4'h7: begin end
                        4'h8: begin end
                        4'h9: begin end
                        4'ha: begin end
                        4'hb: begin end
                        4'hc: begin end
                        4'hd: begin end
                        4'he: begin end
                        4'hf: begin end
                    endcase
                end
            4'h3:
                begin
                    case (opcode[3:0])
                        4'h0: begin mo = `INDEXED; op_LEA = 1; dr = `RN_IX; end
                        4'h1: begin mo = `INDEXED; op_LEA = 1; dr = `RN_IY; end
                        4'h2: begin mo = `INDEXED; op_LEA = 1; dr = `RN_S; end
                        4'h3: begin mo = `INDEXED; op_LEA = 1; dr = `RN_U; end
                        4'h4: begin op_PUSH = 1; end
                        4'h5: begin op_PULL = 1; end
                        4'h6: begin op_PUSH = 1; ss = 0; end
                        4'h7: begin op_PULL = 1; ss = 0; end
                        4'h8: begin end
                        4'h9: begin mo = `INHERENT; op_RTS = 1; end
                        4'ha: begin mo = `INHERENT; lr = `RN_ACCB; rr = `RN_IX; dr = `RN_IX; aop = `ADD; end // ABX
                        4'hb: begin mo = `INHERENT; op_RTI = 1; end
                        4'hc: begin op_CWAI = 1; end
                        4'hd: begin mo = `INHERENT; lr = `RN_ACCA; rr = `RN_ACCB; dr = `RN_ACCD; aop = `MUL; op_MUL = 1; end
                        4'he: begin end
                        4'hf: begin op_SWI = 1; end
                    endcase
                end
            4'h4:
                begin
                    mo = `INHERENT;
                    case (opcode[3:0])
                        4'h0: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `NEG; end // NEG
                        4'h1: begin end 
                        4'h2: begin end
                        4'h3: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `COM; end // COM
                        4'h4: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `LSR; end
                        4'h5: begin end
                        4'h6: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `ROR; end
                        4'h7: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `ASR; end
                        4'h8: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `LSL; end
                        4'h9: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `ROL; end
                        4'ha: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `DEC; end
                        4'hb: begin end
                        4'hc: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `INC; end
                        4'hd: begin lr = `RN_ACCA; aop = `TST; end
                        4'he: begin end
                        4'hf: begin dr = `RN_ACCA; aop = `CLR; end
                    endcase
                end
            4'h5:
                begin
                    mo = `INHERENT;
                    case (opcode[3:0])
                        4'h0: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `NEG; end // NEG
                        4'h1: begin end 
                        4'h2: begin end
                        4'h3: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `COM; end // COM
                        4'h4: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `LSR; end
                        4'h5: begin end
                        4'h6: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `ROR; end
                        4'h7: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `ASR; end
                        4'h8: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `LSL; end
                        4'h9: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `ROL; end
                        4'ha: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `DEC; end
                        4'hb: begin end
                        4'hc: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `INC; end
                        4'hd: begin lr = `RN_ACCB; aop = `TST; end
                        4'he: begin end
                        4'hf: begin dr = `RN_ACCB; aop = `CLR; end
                    endcase
                end
            4'h6:
                begin
                    mo = `INDEXED;
                    case (opcode[3:0])
                        4'h0: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `NEG; end // NEG
                        4'h1: begin end 
                        4'h2: begin end
                        4'h3: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `COM; end // COM
                        4'h4: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `LSR; end
                        4'h5: begin end
                        4'h6: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `ROR; end
                        4'h7: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `ASR; end
                        4'h8: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `LSL; end
                        4'h9: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `ROL; end
                        4'ha: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `DEC; end
                        4'hb: begin end
                        4'hc: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `INC; end
                        4'hd: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `AND; end// TST FIXME
                        4'he: begin op_JMP = 1; end // JMP
                        4'hf: begin dm = `MT_BYTE; aop = `CLR; end // CLR FIXME
                    endcase
                end
            4'h7:
                begin
                    mo = `EXTENDED;
                    case (opcode[3:0])
                        4'h0: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `NEG; end // NEG
                        4'h1: begin end 
                        4'h2: begin end
                        4'h3: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `COM; end // COM
                        4'h4: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `LSR; end
                        4'h5: begin end
                        4'h6: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `ROR; end
                        4'h7: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `ASR; end
                        4'h8: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `LSL; end
                        4'h9: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `ROL; end
                        4'ha: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `DEC; end
                        4'hb: begin end
                        4'hc: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `INC; end
                        4'hd: begin lm = `MT_BYTE; dm = `MT_BYTE; aop = `AND; end // TST FIXME
                        4'he: begin op_JMP = 1; end // JMP
                        4'hf: begin dm = `MT_BYTE; aop = `CLR; end // CLR FIXME
                    endcase
                end
            4'h8:
                begin
                    mo = `IMMEDIATE; // right path filled in the right-path mux
                    case (opcode[3:0])
                        4'h0: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `SUB; end
                        4'h1: begin lr = `RN_ACCA; aop = `SUB; end // cmpa
                        4'h2: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `SBC; end
                        4'h3: begin lr = `RN_ACCD; dr = `RN_ACCD; aop = `SUB; end
                        4'h4: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `AND; end
                        4'h5: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `AND; end
                        4'h6: begin dr = `RN_ACCA; aop = `LD; end
                        4'h7: begin end
                        4'h8: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `EOR; end
                        4'h9: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `ADC; end
                        4'ha: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `OR; end
                        4'hb: begin lr = `RN_ACCA; dr = `RN_ACCA; aop = `ADD; end
                        4'hc: begin lr = `RN_IX; aop = `SUB; end // cmpx
                        4'hd: begin mo = `REL8; op_JSR = 1; end
                        4'he: begin dr = `RN_IX; aop = `LD; end
                        4'hf: begin end
                    endcase
                end
            4'h9:
                begin
                    mo = `DIRECT;
                    case (opcode[3:0])
                        4'h0: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `SUB; end
                        4'h1: begin lr = `RN_ACCA; rm = `MT_BYTE; aop = `SUB; end // cmpa
                        4'h2: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `SBC; end
                        4'h3: begin lr = `RN_ACCD; rm = `MT_BYTE; dr = `RN_ACCD; aop = `SUB; end
                        4'h4: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `AND; end
                        4'h5: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `AND; end
                        4'h6: begin rm = `MT_BYTE; dr = `RN_ACCA; aop = `LD; end
                        4'h7: begin lr = `RN_ACCA; dm = `MT_BYTE; aop = `ST; end
                        4'h8: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `EOR; end
                        4'h9: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `ADC; end
                        4'ha: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `OR; end
                        4'hb: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `ADD; end
                        4'hc: begin lr = `RN_IX; rm = `MT_WORD; aop = `SUB; end // cmpx
                        4'hd: begin op_JSR = 1; end
                        4'he: begin rm = `MT_WORD; dr = `RN_IX; aop = `LD; end
                        4'hf: begin lr = `RN_IX; dm = `MT_WORD; aop = `ST; end
                    endcase
                end
            4'ha:
                begin
                    mo = `INDEXED;
                    case (opcode[3:0])
                        4'h0: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `SUB; end
                        4'h1: begin lr = `RN_ACCA; rm = `MT_BYTE; aop = `SUB; end // cmpa
                        4'h2: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `SBC; end
                        4'h3: begin lr = `RN_ACCD; rm = `MT_BYTE; dr = `RN_ACCD; aop = `SUB; end
                        4'h4: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `AND; end
                        4'h5: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `AND; end
                        4'h6: begin rm = `MT_BYTE; dr = `RN_ACCA; aop = `LD; end
                        4'h7: begin lr = `RN_ACCA; dm = `MT_BYTE; aop = `ST; end
                        4'h8: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `EOR; end
                        4'h9: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `ADC; end
                        4'ha: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `OR; end
                        4'hb: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `ADD; end
                        4'hc: begin lr = `RN_IX; rm = `MT_WORD; aop = `SUB; end // cmpx
                        4'hd: begin op_JSR = 1; end
                        4'he: begin rm = `MT_WORD; dr = `RN_IX; aop = `LD; end
                        4'hf: begin lr = `RN_IX; dm = `MT_WORD; aop = `ST; end
                    endcase
                end
            4'hb:
                begin
                    mo = `EXTENDED;
                    case (opcode[3:0])
                        4'h0: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `SUB; end
                        4'h1: begin lr = `RN_ACCA; rm = `MT_BYTE; aop = `SUB; end // cmpa
                        4'h2: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `SBC; end
                        4'h3: begin lr = `RN_ACCD; rm = `MT_BYTE; dr = `RN_ACCD; aop = `SUB; end
                        4'h4: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `AND; end
                        4'h5: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `AND; end
                        4'h6: begin rm = `MT_BYTE; dr = `RN_ACCA; aop = `LD; end
                        4'h7: begin lr = `RN_ACCA; dm = `MT_BYTE; aop = `ST; end
                        4'h8: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `EOR; end
                        4'h9: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `ADC; end
                        4'ha: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `OR; end
                        4'hb: begin lr = `RN_ACCA; rm = `MT_BYTE; dr = `RN_ACCA; aop = `ADD; end
                        4'hc: begin lr = `RN_IX; rm = `MT_WORD; aop = `SUB; end // cmpx
                        4'hd: begin op_JSR = 1; end
                        4'he: begin rm = `MT_WORD; dr = `RN_IX; aop = `LD; end
                        4'hf: begin lr = `RN_IX; dm = `MT_WORD; aop = `ST; end
                    endcase
                end
            4'hc:
                begin
                    mo = `IMMEDIATE; // right path filled in the right-path mux
                    case (opcode[3:0])
                        4'h0: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `SUB; end
                        4'h1: begin lr = `RN_ACCB; aop = `SUB; end // cmp
                        4'h2: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `SBC; end
                        4'h3: begin sz = 1; lr = `RN_ACCD; dr = `RN_ACCD; aop = `ADD; end
                        4'h4: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `AND; end
                        4'h5: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `AND; end // bit
                        4'h6: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `LD; end
                        4'h7: begin end
                        4'h8: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `EOR; end
                        4'h9: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `ADC; end
                        4'ha: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `OR; end
                        4'hb: begin lr = `RN_ACCB; dr = `RN_ACCB; aop = `ADD; end
                        4'hc: begin sz = 1; dr = `RN_ACCD; aop = `LD; end 
                        4'hd: begin end
                        4'he: begin sz = 1; dr = `RN_U; aop = `LD; end
                        4'hf: begin end
                    endcase
                end
            4'hd:
                begin
                    mo = `DIRECT;
                    case (opcode[3:0])
                        4'h0: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `SUB; end
                        4'h1: begin lr = `RN_ACCB; rm = `MT_BYTE; aop = `SUB; end // cmp
                        4'h2: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `SBC; end
                        4'h3: begin lr = `RN_ACCD; rm = `MT_BYTE; dr = `RN_ACCD; aop = `ADD; end
                        4'h4: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `AND; end
                        4'h5: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `AND; end // bit
                        4'h6: begin rm = `MT_BYTE; dr = `RN_ACCB; aop = `LD; end
                        4'h7: begin lr = `RN_ACCB; dm = `MT_BYTE; aop = `ST; end
                        4'h8: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `EOR; end
                        4'h9: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `ADC; end
                        4'ha: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `OR; end
                        4'hb: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `ADD; end
                        4'hc: begin rm = `MT_WORD; dr = `RN_ACCD; aop = `LD; end 
                        4'hd: begin lr = `RN_ACCD; dm = `MT_WORD; aop = `ST; end
                        4'he: begin rm = `MT_WORD; dr = `RN_U; aop = `LD; end
                        4'hf: begin lr = `RN_U; dm = `MT_WORD; aop = `ST; end
                    endcase
 
                end
            4'he:
                begin
                    mo = `INDEXED;
                    case (opcode[3:0])
                        4'h0: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `SUB; end
                        4'h1: begin lr = `RN_ACCB; rm = `MT_BYTE; aop = `SUB; end // cmp
                        4'h2: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `SBC; end
                        4'h3: begin lr = `RN_ACCD; rm = `MT_BYTE; dr = `RN_ACCD; aop = `ADD; end
                        4'h4: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `AND; end
                        4'h5: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `AND; end // bit
                        4'h6: begin rm = `MT_BYTE; dr = `RN_ACCB; aop = `LD; end
                        4'h7: begin lr = `RN_ACCB; dm = `MT_BYTE; aop = `ST; end
                        4'h8: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `EOR; end
                        4'h9: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `ADC; end
                        4'ha: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `OR; end
                        4'hb: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `ADD; end
                        4'hc: begin rm = `MT_WORD; dr = `RN_ACCD; aop = `LD; end 
                        4'hd: begin lr = `RN_ACCD; dm = `MT_WORD; aop = `ST; end
                        4'he: begin rm = `MT_WORD; dr = `RN_U; aop = `LD; end
                        4'hf: begin lr = `RN_U; dm = `MT_WORD; aop = `ST; end
                    endcase
 
                end
            4'hf:
                 begin
                    mo = `EXTENDED;
                    case (opcode[3:0])
                        4'h0: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `SUB; end
                        4'h1: begin lr = `RN_ACCB; rm = `MT_BYTE; aop = `SUB; end // cmp
                        4'h2: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `SBC; end
                        4'h3: begin lr = `RN_ACCD; rm = `MT_BYTE; dr = `RN_ACCD; aop = `ADD; end
                        4'h4: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `AND; end
                        4'h5: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `AND; end // bit
                        4'h6: begin rm = `MT_BYTE; dr = `RN_ACCB; aop = `LD; end
                        4'h7: begin lr = `RN_ACCB; dm = `MT_BYTE; aop = `ST; end
                        4'h8: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `EOR; end
                        4'h9: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `ADC; end
                        4'ha: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `OR; end
                        4'hb: begin lr = `RN_ACCB; rm = `MT_BYTE; dr = `RN_ACCB; aop = `ADD; end
                        4'hc: begin rm = `MT_WORD; dr = `RN_ACCD; aop = `LD; end 
                        4'hd: begin lr = `RN_ACCD; dm = `MT_WORD; aop = `ST; end
                        4'he: begin rm = `MT_WORD; dr = `RN_U; aop = `LD; end
                        4'hf: begin lr = `RN_U; dm = `MT_WORD; aop = `ST; end
                    endcase
                end
        endcase
        if (p2)
            case (postbyte0[7:4])
                4'h0, 4'h1, 4'h4, 4'h5, 4'h6, 4'h7: begin end
                4'h2: mo = `REL16;
                4'h3: if (postbyte0[3:0] == 4'hf) op_SWI = 1;
                4'h8:
                    begin
                        case (postbyte0[3:0])
                            4'h0: begin end
                            4'h1: begin end
                            4'h2: begin end
                            4'h3: begin mo = `IMMEDIATE; sz = 1; lr = `RN_ACCD; aop = `SUB; end // cmpd
                            4'h4: begin end
                            4'h5: begin end
                            4'h6: begin end
                            4'h7: begin end
                            4'h8: begin end
                            4'h9: begin end
                            4'ha: begin end
                            4'hb: begin end
                            4'hc: begin mo = `IMMEDIATE; sz = 1; lr = `RN_IY; aop = `SUB; end
                            4'hd: begin end
                            4'he: begin mo = `IMMEDIATE; sz = 1; dr = `RN_IY; aop = `LD; end
                            4'hf: begin end
                        endcase
                    end
                4'h9:
                    begin
                        case (postbyte0[3:0])
                            4'h0: begin end
                            4'h1: begin end
                            4'h2: begin end
                            4'h3: begin mo = `DIRECT; lr = `RN_ACCD; rm = `MT_WORD; aop = `SUB; end // cmpd
                            4'h4: begin end
                            4'h5: begin end
                            4'h6: begin end
                            4'h7: begin end
                            4'h8: begin end
                            4'h9: begin end
                            4'ha: begin end
                            4'hb: begin end
                            4'hc: begin mo = `DIRECT; lr = `RN_IY; rm = `MT_WORD; aop = `SUB; end
                            4'hd: begin end
                            4'he: begin mo = `DIRECT; rm = `MT_WORD; dr = `RN_IY; aop = `LD; end
                            4'hf: begin mo = `DIRECT; lr = `RN_IY; dm = `MT_WORD; aop = `ST; end
                        endcase
                    end
                4'ha:
                    begin
                        case (postbyte0[3:0])
                            4'h0: begin end
                            4'h1: begin end
                            4'h2: begin end
                            4'h3: begin mo = `INDEXED; lr = `RN_ACCD; rm = `MT_WORD; aop = `SUB; end // cmpd
                            4'h4: begin end
                            4'h5: begin end
                            4'h6: begin end
                            4'h7: begin end
                            4'h8: begin end
                            4'h9: begin end
                            4'ha: begin end
                            4'hb: begin end
                            4'hc: begin mo = `INDEXED; lr = `RN_IY; rm = `MT_WORD; aop = `SUB; end
                            4'hd: begin end
                            4'he: begin mo = `INDEXED; rm = `MT_WORD; dr = `RN_IY; aop = `LD; end
                            4'hf: begin mo = `INDEXED; lr = `RN_IY; dm = `MT_WORD; aop = `ST; end
                        endcase
                    end
                4'hb:
                    begin
                        case (postbyte0[3:0])
                            4'h0: begin end
                            4'h1: begin end
                            4'h2: begin end
                            4'h3: begin mo = `EXTENDED; lr = `RN_ACCD; rm = `MT_WORD; aop = `SUB; end // cmpd
                            4'h4: begin end
                            4'h5: begin end
                            4'h6: begin end
                            4'h7: begin end
                            4'h8: begin end
                            4'h9: begin end
                            4'ha: begin end
                            4'hb: begin end
                            4'hc: begin mo = `EXTENDED; lr = `RN_IY; rm = `MT_WORD; aop = `SUB; end
                            4'hd: begin end
                            4'he: begin mo = `EXTENDED; rm = `MT_WORD; dr = `RN_IY; aop = `LD; end
                            4'hf: begin mo = `EXTENDED; lr = `RN_IY; dm = `MT_WORD; aop = `ST; end
                        endcase
                    end
                 4'hc:
                    begin
                        case (postbyte0[3:0])
                            4'h0: begin end
                            4'h1: begin end
                            4'h2: begin end
                            4'h3: begin end 
                            4'h4: begin end
                            4'h5: begin end
                            4'h6: begin end
                            4'h7: begin end
                            4'h8: begin end
                            4'h9: begin end
                            4'ha: begin end
                            4'hb: begin end
                            4'hc: begin end
                            4'hd: begin end
                            4'he: begin mo = `IMMEDIATE; sz = 1; dr = `RN_S; aop = `LD; end
                            4'hf: begin end
                        endcase
                    end
                4'hd:
                    begin
                        case (postbyte0[3:0])
                            4'h0: begin end
                            4'h1: begin end
                            4'h2: begin end
                            4'h3: begin end
                            4'h4: begin end
                            4'h5: begin end
                            4'h6: begin end
                            4'h7: begin end
                            4'h8: begin end
                            4'h9: begin end
                            4'ha: begin end
                            4'hb: begin end
                            4'hc: begin end
                            4'hd: begin end
                            4'he: begin mo = `DIRECT; rm = `MT_WORD; dr = `RN_S; aop = `LD; end
                            4'hf: begin mo = `DIRECT; lr = `RN_S; dm = `MT_WORD; aop = `ST; end
                        endcase
                    end
                4'he:
                    begin
                        case (postbyte0[3:0])
                            4'h0: begin end
                            4'h1: begin end
                            4'h2: begin end
                            4'h3: begin end
                            4'h4: begin end
                            4'h5: begin end
                            4'h6: begin end
                            4'h7: begin end
                            4'h8: begin end
                            4'h9: begin end
                            4'ha: begin end
                            4'hb: begin end
                            4'hc: begin end
                            4'hd: begin end
                            4'he: begin mo = `INDEXED; rm = `MT_WORD; dr = `RN_S; aop = `LD; end
                            4'hf: begin mo = `INDEXED; lr = `RN_S; dm = `MT_WORD; aop = `ST; end
                        endcase
                    end
                4'hf:
                    begin
                        case (postbyte0[3:0])
                            4'h0: begin end
                            4'h1: begin end
                            4'h2: begin end
                            4'h3: begin end // cmpd
                            4'h4: begin end
                            4'h5: begin end
                            4'h6: begin end
                            4'h7: begin end
                            4'h8: begin end
                            4'h9: begin end
                            4'ha: begin end
                            4'hb: begin end
                            4'hc: begin end
                            4'hd: begin end
                            4'he: begin mo = `EXTENDED; rm = `MT_WORD; dr = `RN_S; aop = `LD; end
                            4'hf: begin mo = `EXTENDED; lr = `RN_S; dm = `MT_WORD; aop = `ST; end
                        endcase 
                    end          
            endcase
        if (p3)
            case (postbyte0[7:4])
                4'h0, 4'h1, 4'h4, 4'h5, 4'h6, 4'h7,
                4'hc, 4'hd, 4'he, 4'hf: begin end
                4'h3: if (postbyte0[3:0] == 4'hf) op_SWI = 1;
                4'h8:
                    begin
                        case (postbyte0[3:0])
                            4'h0: begin end
                            4'h1: begin end
                            4'h2: begin end
                            4'h3: begin mo = `IMMEDIATE; sz = 1; lr = `RN_U; aop = `SUB; end // cmpd
                            4'h4: begin end
                            4'h5: begin end
                            4'h6: begin end
                            4'h7: begin end
                            4'h8: begin end
                            4'h9: begin end
                            4'ha: begin end
                            4'hb: begin end
                            4'hc: begin mo = `IMMEDIATE; sz = 1; lr = `RN_S; aop = `SUB; end
                            4'hd: begin end
                            4'he: begin end
                            4'hf: begin end
                        endcase
                    end
                4'h9:
                    begin
                        case (postbyte0[3:0])
                            4'h0: begin end
                            4'h1: begin end
                            4'h2: begin end
                            4'h3: begin mo = `DIRECT; lr = `RN_U; rm = `MT_WORD; aop = `SUB; end // cmpd
                            4'h4: begin end
                            4'h5: begin end
                            4'h6: begin end
                            4'h7: begin end
                            4'h8: begin end
                            4'h9: begin end
                            4'ha: begin end
                            4'hb: begin end
                            4'hc: begin mo = `DIRECT; lr = `RN_S; rm = `MT_WORD; aop = `SUB; end
                            4'hd: begin end
                            4'he: begin end
                            4'hf: begin end
                        endcase
                    end
                4'ha:
                    begin
                        case (postbyte0[3:0])
                            4'h0: begin end
                            4'h1: begin end
                            4'h2: begin end
                            4'h3: begin mo = `INDEXED; lr = `RN_U; rm = `MT_WORD; aop = `SUB; end // cmpd
                            4'h4: begin end
                            4'h5: begin end
                            4'h6: begin end
                            4'h7: begin end
                            4'h8: begin end
                            4'h9: begin end
                            4'ha: begin end
                            4'hb: begin end
                            4'hc: begin mo = `INDEXED; lr = `RN_S; rm = `MT_WORD; aop = `SUB; end
                            4'hd: begin end
                            4'he: begin end
                            4'hf: begin end
                        endcase
                    end
                4'hb:
                    begin
                        case (postbyte0[3:0])
                            4'h0: begin end
                            4'h1: begin end
                            4'h2: begin end
                            4'h3: begin mo = `EXTENDED; lr = `RN_U; rm = `MT_WORD; aop = `SUB; end // cmpd
                            4'h4: begin end
                            4'h5: begin end
                            4'h6: begin end
                            4'h7: begin end
                            4'h8: begin end
                            4'h9: begin end
                            4'ha: begin end
                            4'hb: begin end
                            4'hc: begin mo = `EXTENDED; lr = `RN_S; rm = `MT_WORD; aop = `SUB; end
                            4'hd: begin end
                            4'he: begin end
                            4'hf: begin end
                        endcase
                    end
            endcase
 
    end
 always @(posedge clk_in)
	begin
		path_right_addr_lo <= rr;
		path_left_addr_lo <= lr;
		dest_reg_lo <= dr;
        path_right_memtype_lo <= rm;
		path_left_memtype_lo <= lm;
		dest_memtype_lo <= dm;
	end
 
endmodule
 
module decode_ea(
    input wire [7:0]    eapostbyte,
	output reg [3:0]    eabase_o, // base register
    output reg [3:0]    eaindex_o, // index register
    output reg          ea_ofs5_o,
    output reg          ea_ofs8_o,
    output reg          ea_ofs16_o,
    output wire         ea_is_indirect_o,
    output reg          ea_write_back_o
    );
 
assign ea_is_indirect_o = eapostbyte[7] & eapostbyte[4];
 
always @(*)
	begin
        eabase_o = `RN_PC;
		if (eapostbyte[7] & eapostbyte[3] & eapostbyte[2] & (!eapostbyte[1]))
            eabase_o = `RN_PC;
        else
            casex (eapostbyte)
                8'bx00_x_xxxx: eabase_o = `RN_IX;
                8'bx01_x_xxxx: eabase_o = `RN_IY;
                8'bx10_x_xxxx: eabase_o = `RN_U;
                8'bx11_x_xxxx: eabase_o = `RN_S;
            endcase
    end
 
always @(*)
	begin
        ea_ofs5_o = 1'b0;
        ea_ofs8_o = 1'b0;
        ea_ofs16_o = 1'b0;
        ea_write_back_o = 1'b0;
		eaindex_o = `RN_ACCA;
		casex (eapostbyte)
			8'b0xx0xxxx: // base + 5 bit signed offset +
				ea_ofs5_o = 1'b1;
			8'b0xx1xxxx: // 5 bit signed offset -
				ea_ofs5_o = 1'b1;
			8'b1xx_x_0000, // post increment, increment occurs at a later stage
			8'b1xx_x_0001: ea_write_back_o = 1'b1;
			8'b1xx_x_0100: begin end
			8'b1xx_x_0010, // pre decrement
			8'b1xx_x_0011: ea_write_back_o = 1'b1;
			8'b1xx_x_0101: // B,R
				eaindex_o = `RN_ACCB;
			8'b1xx_x_0110: // A,R
				eaindex_o = `RN_ACCA;
			8'b1xx_x_1011: // D,R
				eaindex_o = `RN_ACCD;
			8'b1xx_x_1000: // n,R 8 bit offset
				ea_ofs8_o = 1'b1;
			8'b1xx_x_1001: // n,R // 16 bit offset
				ea_ofs16_o = 1'b1;
			8'b1xx_x_1100: // n,PC
				ea_ofs8_o = 1'b1;
			8'b1xx_x_1101: // n,PC
				ea_ofs16_o = 1'b1;
		endcase
	end
endmodule
 
 
/* decodes the condition and checks the flags to see if it is met */
module test_condition(
	input wire [7:0] opcode,
	input wire [7:0] postbyte0,
	input wire page2_valid,
	input wire [7:0] CCR,
	output reg cond_taken
	);
 
wire [7:0] op = page2_valid ? postbyte0:opcode;
 
always @(*)
	begin
		cond_taken = 1'b0;
		if ((opcode == 8'h16) || (opcode == 8'h17) || (opcode == 8'h8D) ||
			(opcode == 8'h0e) || (opcode == 8'h6e) || (opcode == 8'h7e)) // jmp
			cond_taken = 1'b1; // LBRA/LBSR, BSR
		if (op[7:4] == 4'h2)
			case (op[3:0])
				4'h0: cond_taken = 1'b1; // BRA
				4'h1: cond_taken = 0; // BRN
				4'h2: cond_taken = !(`DFLAGC & `DFLAGZ); // BHI
				4'h3: cond_taken = `DFLAGC | `DFLAGZ; // BLS
				4'h4: cond_taken = !`DFLAGC; // BCC, BHS
				4'h5: cond_taken = `DFLAGC; // BCS, BLO
				4'h6: cond_taken = !`DFLAGZ; // BNE
				4'h7: cond_taken = `DFLAGZ; // BEQ
				4'h8: cond_taken = !`DFLAGV; // BVC
				4'h9: cond_taken = `DFLAGV; // BVS
				4'ha: cond_taken = !`DFLAGN; // BPL
				4'hb: cond_taken = `DFLAGN; // BMI
				4'hc: cond_taken = `DFLAGN == `DFLAGV; // BGE
				4'hd: cond_taken = `DFLAGN != `DFLAGV; // BLT
				4'he: cond_taken = (`DFLAGN == `DFLAGV) & (!`DFLAGZ); // BGT
				4'hf: cond_taken = (`DFLAGN != `DFLAGV) | (`DFLAGZ); // BLE
		endcase
	end
 
endmodule