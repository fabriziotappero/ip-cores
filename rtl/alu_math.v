/*******************************************************************************************/
/**                                                                                       **/
/** COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED          **/
/**                                                                                       **/
/** alu math module                                                   Rev 0.0  07/29/2011 **/
/**                                                                                       **/
/*******************************************************************************************/
module alu_math (adder_c, adder_hc, adder_out, adder_ov, alua_in, alub_in, aluop_reg,
                 carry_bit, carry_daa, daa_op, word_op);

  input         carry_bit;     /* carry flag                                               */
  input         carry_daa;     /* carry for daa                                            */
  input         daa_op;        /* daa operation                                            */
  input         word_op;       /* word operation                                           */
  input  [15:0] alua_in;       /* alu a input                                              */
  input  [15:0] alub_in;       /* alu b input                                              */
  input  [`AOP_IDX:0] aluop_reg;   /* alu operation control subset                         */
  output        adder_c;       /* alu math carry result                                    */
  output        adder_hc;      /* alu math half-carry result                               */
  output        adder_ov;      /* alu math overflow result                                 */
  output [15:0] adder_out;     /* alu math result                                          */

  /*****************************************************************************************/
  /*                                                                                       */
  /* signal declarations                                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  wire         adder_c;                                    /* alu math carry out           */
  wire         adder_hc;                                   /* alu math half-carry out      */
  wire  [15:8] bsign_ext;                                  /* alu b sign extend            */
  wire  [15:0] adder_out;                                  /* alu math out                 */

  reg          alu_cin;                                    /* alu math carry in            */
  reg          adder_ov;                                   /* alu math overflow out        */
  reg    [4:0] alu0_out;                                   /* alu math nibble 0            */
  reg    [4:0] alu1_out;                                   /* alu math nibble 1            */
  reg    [4:0] alu2_out;                                   /* alu math nibble 2            */
  reg    [4:0] alu3_out;                                   /* alu math nibble 3            */

  /*****************************************************************************************/
  /*                                                                                       */
  /* alu math carry input, sign extend                                                     */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (aluop_reg or carry_bit) begin
    casex (aluop_reg) //synopsys parallel_case
      `AOP_ADC,
      `AOP_BADC,
      `AOP_SBC,
      `AOP_BSBC: alu_cin = carry_bit;
      default:   alu_cin = 1'b0;
      endcase
    end

  assign bsign_ext = {alub_in[7],  alub_in[7],  alub_in[7],  alub_in[7],
                      alub_in[7],  alub_in[7],  alub_in[7],  alub_in[7]};

  /*****************************************************************************************/
  /*                                                                                       */
  /* alu math function unit                                                                */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (aluop_reg or alua_in or alub_in or alu_cin) begin
    casex (aluop_reg) //synopsys parallel_case
      `AOP_SUB,
      `AOP_BSUB,
      `AOP_SBC,
      `AOP_BSBC: alu0_out = alua_in[3:0] - alub_in[3:0] - alu_cin;
      default:   alu0_out = alua_in[3:0] + alub_in[3:0] + alu_cin;
      endcase
    end

  always @ (aluop_reg or alua_in or alub_in or alu0_out) begin
    casex (aluop_reg) //synopsys parallel_case
      `AOP_SUB,
      `AOP_BSUB,
      `AOP_SBC,
      `AOP_BSBC: alu1_out = alua_in[7:4] - alub_in[7:4] - alu0_out[4];
      default:   alu1_out = alua_in[7:4] + alub_in[7:4] + alu0_out[4];
      endcase
    end

  always @ (aluop_reg or alua_in or alub_in or alu1_out or bsign_ext) begin
    casex (aluop_reg) //synopsys parallel_case
      `AOP_ADS:   alu2_out = alua_in[11:8] + bsign_ext[11:8] + alu1_out[4];
      `AOP_SUB,
      `AOP_BSUB,
      `AOP_SBC,
      `AOP_BSBC:  alu2_out = alua_in[11:8] - alub_in[11:8] - alu1_out[4];
      default:    alu2_out = alua_in[11:8] + alub_in[11:8] + alu1_out[4];
      endcase
    end

  always @ (aluop_reg or alua_in or alub_in or alu2_out or bsign_ext) begin
    casex (aluop_reg) //synopsys parallel_case
      `AOP_ADS:   alu3_out = alua_in[15:12] + bsign_ext[15:12] + alu2_out[4];
      `AOP_SUB,
      `AOP_BSUB,
      `AOP_SBC,
      `AOP_BSBC:  alu3_out = alua_in[15:12] - alub_in[15:12] - alu2_out[4];
      default:    alu3_out = alua_in[15:12] + alub_in[15:12] + alu2_out[4];
      endcase
    end

  assign adder_out = {alu3_out[3:0], alu2_out[3:0], alu1_out[3:0], alu0_out[3:0]};

  /*****************************************************************************************/
  /*                                                                                       */
  /* alu math flag generation                                                              */
  /*                                                                                       */
  /*****************************************************************************************/
  assign adder_c  = (word_op) ? alu3_out[4] :
                    (daa_op)  ? carry_daa   : alu1_out[4];
  assign adder_hc = (word_op) ? alu2_out[4] : alu0_out[4];

  always @ (aluop_reg or alua_in or alub_in or alu3_out or alu1_out or bsign_ext) begin
    casex (aluop_reg) //synopsys parallel_case
      `AOP_ADC,
      `AOP_ADD:  adder_ov = (!alu3_out[3] &&  alua_in[15] &&  alub_in[15]) || 
                            ( alu3_out[3] && !alua_in[15] && !alub_in[15]); 
      `AOP_BADC,
      `AOP_BADD,
      `AOP_BDEC: adder_ov = (!alu1_out[3] &&  alua_in[7]  &&  alub_in[7]) || 
                            ( alu1_out[3] && !alua_in[7]  && !alub_in[7]); 
      `AOP_SBC,
      `AOP_SUB:  adder_ov = (!alu3_out[3] &&  alua_in[15] && !alub_in[15]) || 
                            ( alu3_out[3] && !alua_in[15] &&  alub_in[15]); 
      `AOP_BSBC,
      `AOP_BSUB: adder_ov = (!alu1_out[3] &&  alua_in[7]  && !alub_in[7]) || 
                            ( alu1_out[3] && !alua_in[7]  &&  alub_in[7]); 
      default:   adder_ov = 1'b0;
      endcase
    end

  endmodule






