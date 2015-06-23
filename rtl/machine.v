/*******************************************************************************************/
/**                                                                                       **/
/** COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED          **/
/**                                                                                       **/
/** state machine module                                              Rev 0.0  07/01/2011 **/
/**                                                                                       **/
/*******************************************************************************************/
module machine (ld_ctrl, state_reg, wait_st, clkc, dmar_reg, intr_reg, ld_inta, ld_wait,
                resetb, state_nxt, wait_req);

  input         clkc;          /* main cpu clock                                           */
  input         dmar_reg;      /* latched dma request                                      */
  input         intr_reg;      /* latched interrupt request                                */
  input         ld_inta;       /* load interrupt request                                   */
  input         ld_wait;       /* load wait request                                        */
  input         resetb;        /* internal reset                                           */
  input         wait_req;      /* wait request                                             */
  input   [`STATE_IDX:0] state_nxt;   /* next processor state                              */
  output        ld_ctrl;       /* load control register                                    */
  output        wait_st;       /* wait state identifier                                    */
  output  [`STATE_IDX:0] state_reg;   /* current processor state                           */

  /*****************************************************************************************/
  /*                                                                                       */
  /* signal declarations                                                                   */
  /*                                                                                       */
  /*****************************************************************************************/
  wire         ld_ctrl;                                    /* advance state                */

  reg          wait_st;                                    /* wait state - inhibit op      */
  reg  [`STATE_IDX:0] state_reg;                           /* current processor state      */

  /*****************************************************************************************/
  /*                                                                                       */
  /* processor state machine                                                               */
  /*                                                                                       */
  /*****************************************************************************************/
  assign ld_ctrl = !ld_wait || !wait_req;

  always @ (posedge clkc or negedge resetb) begin
    if (!resetb) wait_st   <= 1'b0;
    else         wait_st   <= !ld_ctrl;
    end

  always @ (posedge clkc or negedge resetb) begin
    if      (!resetb) state_reg <= `sRST;
    else if (ld_ctrl) state_reg <= (ld_inta && dmar_reg) ? `sDMA1 :
                                   (ld_inta && intr_reg) ? `sINTA : state_nxt;
    end

  endmodule





