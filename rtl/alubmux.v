/*******************************************************************************************/
/**                                                                                       **/
/** COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED          **/
/**                                                                                       **/
/** alu b input multiplexer module                                    Rev 0.0  07/24/2011 **/
/**                                                                                       **/
/*******************************************************************************************/
module alubmux (addb_in, alub_in, alub_reg, af_reg_out, bc_reg_out, de_reg_out, din0_reg,
                din1_reg, hl_reg_out, ix_reg, iy_reg, pc_reg, sp_reg, tmp_reg);

  input   [7:0] din0_reg;      /* data input 0 register                                    */
  input   [7:0] din1_reg;      /* data input 1 register                                    */
  input  [15:0] af_reg_out;    /* af register output                                       */
  input  [15:0] bc_reg_out;    /* bc register output                                       */
  input  [15:0] de_reg_out;    /* de register output                                       */
  input  [15:0] hl_reg_out;    /* hl register output                                       */
  input  [15:0] ix_reg;        /* ix register output                                       */
  input  [15:0] iy_reg;        /* iy register output                                       */
  input  [15:0] pc_reg;        /* pc register output                                       */
  input  [15:0] sp_reg;        /* sp register output                                       */
  input  [15:0] tmp_reg;       /* temporary register output                                */
  input  [`ALUB_IDX:0] alub_reg;   /* pipelined alu input b mux control                    */
  output [15:0] addb_in;       /* address alu b input bus                                  */
  output [15:0] alub_in;       /* alu b input bus                                          */

  /*****************************************************************************************/
  /*                                                                                       */
  /* signal declarations                                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  wire [15:0] alub_in;
  reg  [15:0] alub_mux;
  reg  [15:0] alub_mux_1, alub_mux_2, alub_mux_3, alub_mux_4, alub_mux_5;
  reg  [15:0] alub_mux_6, alub_mux_7, alub_mux_8, alub_mux_9, alub_mux_10, alub_mux_11;

  wire [15:0] addb_in;
  wire [15:0] addb_mux_2, addb_mux_3, addb_mux_4, addb_mux_5, addb_mux_6, addb_mux_7;
  wire [15:0] addb_mux_8, addb_mux_9, addb_mux_10, addb_mux_12;

  /*****************************************************************************************/
  /*                                                                                       */
  /* alu input b select                                                                    */
  /*                                                                                       */
  /*****************************************************************************************/
   always @ (alub_reg or af_reg_out or bc_reg_out or de_reg_out or hl_reg_out or ix_reg or
             iy_reg or sp_reg or din1_reg or din0_reg or tmp_reg or pc_reg) begin
    alub_mux_1  = 32'h0;
    alub_mux_2  = 32'h0;
    alub_mux_3  = 32'h0;
    alub_mux_4  = 32'h0;
    alub_mux_5  = 32'h0;
    alub_mux_6  = 32'h0;
    alub_mux_7  = 32'h0;
    alub_mux_8  = 32'h0;
    alub_mux_9  = 32'h0;
    alub_mux_10 = 32'h0;
    alub_mux_11 = 32'h0;
    if (alub_reg[`AB_AF])  alub_mux_1  = af_reg_out;
    if (alub_reg[`AB_BC])  alub_mux_2  = bc_reg_out;
    if (alub_reg[`AB_DE])  alub_mux_3  = de_reg_out;
    if (alub_reg[`AB_HL])  alub_mux_4  = hl_reg_out;
    if (alub_reg[`AB_IX])  alub_mux_5  = ix_reg;
    if (alub_reg[`AB_IY])  alub_mux_6  = iy_reg;
    if (alub_reg[`AB_SP])  alub_mux_7  = sp_reg;
    if (alub_reg[`AB_DIN]) alub_mux_8  = {din1_reg, din0_reg};
    if (alub_reg[`AB_IO])  alub_mux_9  = {af_reg_out[15:8], din0_reg};
    if (alub_reg[`AB_TMP]) alub_mux_10 =  tmp_reg;
    if (alub_reg[`AB_PC])  alub_mux_11 = pc_reg;
    end

  always @ (alub_mux_1 or alub_mux_2 or alub_mux_3 or alub_mux_4 or alub_mux_5 or
            alub_mux_6 or alub_mux_7 or alub_mux_8 or alub_mux_9 or alub_mux_10 or
            alub_mux_11) begin
    alub_mux = alub_mux_1 | alub_mux_2 | alub_mux_3 | alub_mux_4 | alub_mux_5 |
               alub_mux_6 | alub_mux_7 | alub_mux_8 | alub_mux_9 | alub_mux_10 | alub_mux_11;
    end

  assign alub_in  = (alub_reg[`AB_SHR]) ? {alub_mux[15:8], alub_mux[15:8]} : alub_mux;

  /*****************************************************************************************/
  /*                                                                                       */
  /* address alu input b select                                                            */
  /*                                                                                       */
  /*****************************************************************************************/
  assign addb_mux_2  = (alub_reg[`AB_BC])  ? bc_reg_out                   : 16'h0;
  assign addb_mux_3  = (alub_reg[`AB_DE])  ? de_reg_out                   : 16'h0;
  assign addb_mux_4  = (alub_reg[`AB_HL])  ? hl_reg_out                   : 16'h0;
  assign addb_mux_5  = (alub_reg[`AB_IX])  ? ix_reg                       : 16'h0;
  assign addb_mux_6  = (alub_reg[`AB_IY])  ? iy_reg                       : 16'h0;
  assign addb_mux_7  = (alub_reg[`AB_SP])  ? sp_reg                       : 16'h0;
  assign addb_mux_8  = (alub_reg[`AB_DIN]) ? {din1_reg, din0_reg}         : 16'h0;
  assign addb_mux_9  = (alub_reg[`AB_IO])  ? {af_reg_out[15:8], din0_reg} : 16'h0;
  assign addb_mux_10 = (alub_reg[`AB_TMP]) ? tmp_reg                      : 16'h0;
  assign addb_mux_12 = (alub_reg[`AB_ADR]) ? pc_reg                       : 16'h0;

  assign addb_in =  addb_mux_2 | addb_mux_3 | addb_mux_4 | addb_mux_5  | addb_mux_6 |
                    addb_mux_7  | addb_mux_8 |addb_mux_9 | addb_mux_10 | addb_mux_12;

  endmodule





