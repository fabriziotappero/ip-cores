/*******************************************************************************************/
/**                                                                                       **/
/** ORIGINAL COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED **/
/** COPYRIGHT (C) 2012, SERGEY BELYASHOV                                                  **/
/**                                                                                       **/
/** alu function unit combiner module                                 Rev 0.0  06/13/2012 **/
/**                                                                                       **/
/*******************************************************************************************/
module aluout (cry_nxt, data_bus, hcar_nxt, one_nxt, par_nxt, sign_nxt, zero_nxt, adder_c,
               adder_hc, adder_out, hi_byte, logic_c, logic_hc, logic_out, shft_c, shft_out,
               mult_out,
               unit_sel, word_op);

  input         adder_c;       /* math carry result                                        */
  input         adder_hc;      /* math half-carry result                                   */
  input         hi_byte;       /* shift left byte control                                  */
  input         logic_c;       /* logic carry result                                       */
  input         logic_hc;      /* logic half-carry result                                  */
  input         shft_c;        /* shift carry result                                       */
  input         word_op;       /* word operation                                           */
  input   [1:0] unit_sel;      /* alu function unit select                                 */
  input   [7:0] shft_out;      /* shift unit result                                        */
  input  [15:0] adder_out;     /* math unit result                                         */
  input  [15:0] logic_out;     /* logic unit result                                        */
  input  [15:0] mult_out;      /* multiplier unit result                                   */
  output        cry_nxt;       /* carry flag next                                          */
  output        hcar_nxt;      /* half-carry flag next                                     */
  output        one_nxt;       /* one flag next                                            */
  output        par_nxt;       /* parity flag next                                         */
  output        sign_nxt;      /* sign flag next                                           */
  output        zero_nxt;      /* zero flag next                                           */
  output [15:0] data_bus;      /* datapath data bus                                        */

  /*****************************************************************************************/
  /*                                                                                       */
  /* signal declarations                                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  wire        one_nxt, par_nxt, sign_nxt, zero_nxt;
  wire [15:0] data_bus;

  reg         cry_nxt, hcar_nxt;
  reg  [15:0] alu_result;

  /*****************************************************************************************/
  /*                                                                                       */
  /* alu function unit combination                                                         */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (unit_sel or adder_out or logic_out or shft_out or mult_out) begin
    casex (unit_sel)
      2'b01:   alu_result = adder_out;
      2'b10:   alu_result = {8'h00, shft_out};
      2'b11:   alu_result = mult_out;
      default: alu_result = logic_out;
      endcase
    end

  /*****************************************************************************************/
  /*                                                                                       */
  /* alu flag outputs                                                                      */
  /*                                                                                       */
  /*****************************************************************************************/
  always @ (unit_sel or adder_c or logic_c or shft_c) begin
    casex (unit_sel)
      2'b01:   cry_nxt = adder_c;
      2'b1x:   cry_nxt = shft_c;
      default: cry_nxt = logic_c;
      endcase
    end

  always @ (unit_sel or adder_hc or logic_hc) begin
    casex (unit_sel)
      2'b01:   hcar_nxt = adder_hc;
      2'b1x:   hcar_nxt = 1'b0;
      default: hcar_nxt = logic_hc;
      endcase
    end

  assign one_nxt  = ~|alu_result[7:1] && alu_result[0];
  assign par_nxt  = ~^alu_result[7:0];
  assign sign_nxt = (word_op) ?   alu_result[15]   :   alu_result[7];
  assign zero_nxt = (word_op) ? ~|alu_result[15:0] : ~|alu_result[7:0];

  /*****************************************************************************************/
  /*                                                                                       */
  /* alu output left shift                                                                 */
  /*                                                                                       */
  /*****************************************************************************************/
  assign data_bus = (hi_byte) ? {alu_result[7:0], alu_result[7:0]} : alu_result[15:0];

  endmodule






