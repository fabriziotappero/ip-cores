/*
 * Simply RISC M1 Arithmetic-Logic Unit
 *
 * Simple RTL-level ALU with Alternating Bit Protocol (ABP) interface.
 */

`include "m1_defs.vh"

// Combinational ALU with 32-bit operands
module m1_alu(
    input[31:0] a_i,             // Operand A
    input[31:0] b_i,             // Operand B
    input[4:0] func_i,           // Function to be performed
    input signed_i,              // Operation is signed
    output reg[32:0] result_o    // 33-bit result (uppermost bit is the carry)
  );

  // ALU Logic
  always @(a_i or b_i or func_i or signed_i) begin
    case(func_i)

      // Shift instructions
      `ALU_OP_SLL: result_o = {1'b0, a_i << b_i[4:0]};
      `ALU_OP_SRL: result_o = {1'b0, a_i >> b_i[4:0]};
      `ALU_OP_SRA: result_o = {1'b0, {{32{a_i[31]}}, a_i } >> b_i[4:0]};

      // Arithmetical instructions
      `ALU_OP_ADD: if(signed_i) result_o = a_i + b_i;  // Result may include a carry bit
                   else result_o = {1'b0,  a_i + b_i};
      `ALU_OP_SUB: if(signed_i) result_o = a_i - b_i;  // Result may include a carry bit
                   else result_o = {1'b0,  a_i - b_i};

      // Logical instructions
      `ALU_OP_AND: result_o = {1'b0, a_i & b_i};
      `ALU_OP_OR:  result_o = {1'b0, a_i | b_i};
      `ALU_OP_XOR: result_o = {1'b0, a_i ^ b_i};
      `ALU_OP_NOR: result_o = {1'b0, ~(a_i | b_i)};

      // Conditional instructions
      `ALU_OP_SEQ: result_o = (a_i == b_i) ? 33'b1 : 33'b0;
      `ALU_OP_SNE: result_o = (a_i != b_i) ? 33'b1 : 33'b0;
      `ALU_OP_SLT: if(signed_i) result_o = ({~a_i[31],a_i[30:0]} <  {~b_i[31],b_i[30:0]}) ? 33'b1 : 33'b0;
                   else result_o = (a_i < b_i) ? 33'b1 : 33'b0;
      `ALU_OP_SLE: if(signed_i) result_o = ({~a_i[31],a_i[30:0]} <= {~b_i[31],b_i[30:0]}) ? 33'b1 : 33'b0;
                   else result_o = (a_i <= b_i) ? 33'b1 : 33'b0;
      `ALU_OP_SGT: if(signed_i) result_o = ({~a_i[31],a_i[30:0]} >  {~b_i[31],b_i[30:0]}) ? 33'b1 : 33'b0;
                   else result_o = (a_i > b_i) ? 33'b1 : 33'b0;
      `ALU_OP_SGE: if(signed_i) result_o = ({~a_i[31],a_i[30:0]} >= {~b_i[31],b_i[30:0]}) ? 33'b1 : 33'b0;
                   else result_o = (a_i >= b_i) ? 33'b1 : 33'b0;
      
      default: result_o = 33'b0;
    endcase
  end

endmodule

