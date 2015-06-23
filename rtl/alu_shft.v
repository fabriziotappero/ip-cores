/*******************************************************************************************/
/**                                                                                       **/
/** ORIGINAL COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED **/
/** COPYRIGHT (C) 2012, SERGEY BELYASHOV                                                  **/
/**                                                                                       **/
/** alu shifter module                                                Rev 0.0  06/13/2012 **/
/**                                                                                       **/
/*******************************************************************************************/
module alu_shft (shft_c, shft_out, alub_in, aluop_reg, carry_bit);

  input         carry_bit;     /* carry flag input                                         */
  input   [7:0] alub_in;       /* alu b input                                              */
  input  [`AOP_IDX:0] aluop_reg;   /* alu operation control subset                         */
  output        shft_c;        /* alu shifter carry output                                 */
  output  [7:0] shft_out;      /* alu shifter output                                       */

  /*****************************************************************************************/
  /*                                                                                       */
  /* signal declarations                                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  reg         shft_c;                                      /* shifter carry output         */
  reg   [7:0] shft_out;                                    /* shifter output               */

  /*****************************************************************************************/
  /*                                                                                       */
  /* alu shifter function                                                                  */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (aluop_reg or alub_in) begin
    casex (aluop_reg) //synopsys parallel_case
      `AOP_RL,
      `AOP_RLA:   shft_c = alub_in[7];
      `AOP_RLC,
      `AOP_RLCA:  shft_c = alub_in[7];
      `AOP_RR,
      `AOP_RRA:   shft_c = alub_in[0];
      `AOP_RRC,
      `AOP_RRCA:  shft_c = alub_in[0];
      `AOP_SLL,
      `AOP_SLA:   shft_c = alub_in[7];
      `AOP_SRA:   shft_c = alub_in[0];
      `AOP_SRL:   shft_c = alub_in[0];
      default:    shft_c = 1'b0;
      endcase
    end

  always @ (aluop_reg or alub_in or carry_bit) begin
    casex (aluop_reg) //synopsys parallel_case
      `AOP_RL,
      `AOP_RLA:   shft_out = {alub_in[6:0], carry_bit};
      `AOP_RLC,
      `AOP_RLCA:  shft_out = {alub_in[6:0], alub_in[7]};
      `AOP_RR,
      `AOP_RRA:   shft_out = {carry_bit, alub_in[7:1]};
      `AOP_RRC,
      `AOP_RRCA:  shft_out = {alub_in[0], alub_in[7:1]};
      `AOP_SLA:   shft_out = {alub_in[6:0], 1'b0};
      `AOP_SLL:   shft_out = {alub_in[6:0], 1'b1};
      `AOP_SRA:   shft_out = {alub_in[7], alub_in[7:1]};
      `AOP_SRL:   shft_out = {1'b0, alub_in[7:1]};
      default:    shft_out = 8'h00;
      endcase
    end

  endmodule





