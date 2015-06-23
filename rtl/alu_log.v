/*******************************************************************************************/
/**                                                                                       **/
/** COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED          **/
/**                                                                                       **/
/** alu logic module                                                  Rev 0.0  07/17/2011 **/
/**                                                                                       **/
/*******************************************************************************************/
module alu_log  (logic_c, logic_hc, logic_out, alua_in, alub_in, aluop_reg, carry_bit);

  input         carry_bit;     /* cpu carry flag                                           */
  input  [15:0] alua_in;       /* alu a input                                              */
  input  [15:0] alub_in;       /* alu b input                                              */
  input  [`AOP_IDX:0] aluop_reg;   /* alu operation control                                */
  output        logic_c;       /* alu logic carry result                                   */
  output        logic_hc;      /* alu logic half-carry result                              */
  output [15:0] logic_out;     /* alu logic result                                         */

  /*****************************************************************************************/
  /*                                                                                       */
  /* signal declarations                                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  reg         logic_c;                                     /* logic carry output           */
  reg         logic_hc;                                    /* logic half-carry output      */
  reg  [15:0] logic_out;                                   /* logic output                 */

  /*****************************************************************************************/
  /*                                                                                       */
  /* alu logic function                                                                    */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (aluop_reg or carry_bit) begin
    casex (aluop_reg)
      `AOP_CCF:   logic_c = !carry_bit;
      `AOP_SCF:   logic_c = 1'b1;
      default:    logic_c = 1'b0;
      endcase
    end

  always @ (aluop_reg or carry_bit) begin
    casex (aluop_reg)
      `AOP_BAND:  logic_hc = 1'b1;
      `AOP_CCF:   logic_hc = carry_bit;
      default:    logic_hc = 1'b0;
      endcase
    end

  always @ (aluop_reg or alua_in or alub_in) begin
    casex (aluop_reg)
      `AOP_BAND:  logic_out = {8'h00, alua_in[7:0] & alub_in[7:0]};
      `AOP_BOR:   logic_out = {8'h00, alua_in[7:0] | alub_in[7:0]};
      `AOP_BXOR:  logic_out = {8'h00, alua_in[7:0] ^ alub_in[7:0]};
      `AOP_RLD1:  logic_out = {8'h00, alub_in[3:0],  alua_in[3:0]};
      `AOP_RLD2:  logic_out = {8'h00, alua_in[7:4],  alub_in[7:4]};
      `AOP_RRD1:  logic_out = {8'h00, alua_in[3:0],  alub_in[7:4]};
      `AOP_RRD2:  logic_out = {8'h00, alua_in[7:4],  alub_in[3:0]};
      `AOP_APAS:  logic_out = alua_in;
      `AOP_PASS:  logic_out = alub_in;
      default:    logic_out = 16'h0000;
      endcase
    end

  endmodule





