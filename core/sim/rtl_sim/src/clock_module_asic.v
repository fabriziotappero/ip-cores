/*===========================================================================*/
/* Copyright (C) 2001 Authors                                                */
/*                                                                           */
/* This source file may be used and distributed without restriction provided */
/* that this copyright statement is not removed from the file and that any   */
/* derivative work contains the original copyright notice and the associated */
/* disclaimer.                                                               */
/*                                                                           */
/* This source file is free software; you can redistribute it and/or modify  */
/* it under the terms of the GNU Lesser General Public License as published  */
/* by the Free Software Foundation; either version 2.1 of the License, or    */
/* (at your option) any later version.                                       */
/*                                                                           */
/* This source is distributed in the hope that it will be useful, but WITHOUT*/
/* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or     */
/* FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public       */
/* License for more details.                                                 */
/*                                                                           */
/* You should have received a copy of the GNU Lesser General Public License  */
/* along with this source; if not, write to the Free Software Foundation,    */
/* Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA        */
/*                                                                           */
/*===========================================================================*/
/*                               CLOCK MODULE                                */
/*---------------------------------------------------------------------------*/
/* Test the clock module:                                                    */
/*                        - Check the ACLK and SMCLK clock generation.       */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 19 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2009-08-04 23:47:15 +0200 (Tue, 04 Aug 2009) $          */
/*===========================================================================*/

`define LONG_TIMEOUT


integer dco_clk_counter;
always @ (negedge dco_clk)
  dco_clk_counter <=  dco_clk_counter+1;

integer lfxt_clk_counter;
always @ (negedge lfxt_clk)
  lfxt_clk_counter <=  lfxt_clk_counter+1;

integer mclk_counter;
always @ (posedge mclk)
  mclk_counter <=  mclk_counter+1;

integer aclk_counter;
always @ (negedge aclk)
  aclk_counter <=  aclk_counter+1;

integer smclk_counter;
always @ (negedge smclk)
  smclk_counter <=  smclk_counter+1;

integer dbg_clk_counter;
always @ (negedge dbg_clk)
  dbg_clk_counter <=  dbg_clk_counter+1;

reg [15:0] reg_val;
reg [15:0] bcsctl1_mask;
reg [15:0] bcsctl2_mask;
      
initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

      force tb_openMSP430.dut.wdt_reset = 1'b0;

`ifdef ASIC_CLOCKING

      // MCLK GENERATION: SELECTING DCO_CLK
      //--------------------------------------------------------

	                        // ------- Divider /1 ----------
      @(r15 === 16'h0001);
      @(posedge mclk);
      #1;
      dco_clk_counter = 0;
      mclk_counter    = 0;
      repeat(735) @(posedge dco_clk);
      #1;
      if (dco_clk_counter !== 735) tb_error("====== CLOCK GENERATOR: MCLK - DCO_CLK INPUT  (DIV /1) - TEST 1 =====");
      if (mclk_counter    !== 735) tb_error("====== CLOCK GENERATOR: MCLK - DCO_CLK INPUT  (DIV /1) - TEST 2 =====");

      
   `ifdef MCLK_DIVIDER
	                        // ------- Divider /2 ----------
      @(r15 === 16'h0002);
      @(posedge mclk);
      #1;
      dco_clk_counter = 0;
      mclk_counter    = 0;
      repeat(735) @(posedge dco_clk);
      #1;
      if (dco_clk_counter !== 735) tb_error("====== CLOCK GENERATOR: MCLK - DCO_CLK INPUT  (DIV /2) - TEST 1 =====");
      if (mclk_counter    !== 367) tb_error("====== CLOCK GENERATOR: MCLK - DCO_CLK INPUT  (DIV /2) - TEST 2 =====");

      
	                        // ------- Divider /4 ----------
      @(r15 === 16'h0003);
      @(posedge mclk);
      #1;
      dco_clk_counter = 0;
      mclk_counter    = 0;
      repeat(735) @(posedge dco_clk);
      #1;
      if (dco_clk_counter !== 735) tb_error("====== CLOCK GENERATOR: MCLK - DCO_CLK INPUT  (DIV /4) - TEST 1 =====");
      if (mclk_counter    !== 183) tb_error("====== CLOCK GENERATOR: MCLK - DCO_CLK INPUT  (DIV /4) - TEST 2 =====");
      
      
	                        // ------- Divider /8 ----------
      @(r15 === 16'h0004);
      @(posedge mclk);
      #1;
      dco_clk_counter = 0;
      mclk_counter    = 0;
      repeat(735) @(posedge dco_clk);
      #1;
      if (dco_clk_counter !== 735) tb_error("====== CLOCK GENERATOR: MCLK - DCO_CLK INPUT  (DIV /8) - TEST 1 =====");
      if (mclk_counter    !== 91)  tb_error("====== CLOCK GENERATOR: MCLK - DCO_CLK INPUT  (DIV /8) - TEST 2 =====");

   `else
	                        // ------- Divider /2 ----------
      @(r15 === 16'h0002);
      @(posedge dco_clk);
      #1;
      dco_clk_counter = 0;
      mclk_counter    = 0;
      repeat(735) @(posedge dco_clk);
      #1;
      if (dco_clk_counter !== 735) tb_error("====== CLOCK GENERATOR: MCLK - DCO_CLK INPUT  (DIV /2) - TEST 1 =====");
      if (mclk_counter    !== 735) tb_error("====== CLOCK GENERATOR: MCLK - DCO_CLK INPUT  (DIV /2) - TEST 2 =====");

      
	                        // ------- Divider /4 ----------
      @(r15 === 16'h0003);
      @(posedge dco_clk);
      #1;
      dco_clk_counter = 0;
      mclk_counter    = 0;
      repeat(735) @(posedge dco_clk);
      #1;
      if (dco_clk_counter !== 735) tb_error("====== CLOCK GENERATOR: MCLK - DCO_CLK INPUT  (DIV /4) - TEST 1 =====");
      if (mclk_counter    !== 735) tb_error("====== CLOCK GENERATOR: MCLK - DCO_CLK INPUT  (DIV /4) - TEST 2 =====");
      
      
	                        // ------- Divider /8 ----------
      @(r15 === 16'h0004);
      @(posedge dco_clk);
      #1;
      dco_clk_counter = 0;
      mclk_counter    = 0;
      repeat(735) @(posedge dco_clk);
      #1;
      if (dco_clk_counter !== 735) tb_error("====== CLOCK GENERATOR: MCLK - DCO_CLK INPUT  (DIV /8) - TEST 1 =====");
      if (mclk_counter    !== 735) tb_error("====== CLOCK GENERATOR: MCLK - DCO_CLK INPUT  (DIV /8) - TEST 2 =====");


   `endif

      @(r15 === 16'h1000);
     

      // MCLK GENERATION: SELECTING LFXT_CLK
      //--------------------------------------------------------
      // VERIFICATION DONE IN THE "CLOC_MODULE_ASIC_MCLK" PATTERN
      @(r15 === 16'h2000);
     

      // ACLK GENERATION
      //--------------------------------------------------------

	                        // ------- Divider /1 ----------
      @(r15 === 16'h2001);
`ifdef LFXT_DOMAIN
      @(posedge lfxt_clk);
`else
      @(posedge dco_clk);
`endif
      #1;
      dco_clk_counter  = 0;
      lfxt_clk_counter = 0;
      aclk_counter     = 0;
`ifdef LFXT_DOMAIN
      repeat(54) @(posedge lfxt_clk);
      if (lfxt_clk_counter !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /1) - TEST 1 =====");
      if (aclk_counter     !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /1) - TEST 2 =====");
`else
      repeat(54) @(posedge dco_clk);
      #1;
      if (dco_clk_counter  !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /1) - TEST 1 =====");
      if (aclk_counter     !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /1) - TEST 2 =====");
`endif

      
   `ifdef ACLK_DIVIDER
	                        // ------- Divider /2 ----------
      @(r15 === 16'h2002);
`ifdef LFXT_DOMAIN
      @(posedge lfxt_clk);
`else
      @(posedge dco_clk);
`endif
      #1;
      dco_clk_counter  = 0;
      lfxt_clk_counter = 0;
      aclk_counter     = 0;
`ifdef LFXT_DOMAIN
      repeat(54) @(posedge lfxt_clk);
      #1;
      if (lfxt_clk_counter !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /2) - TEST 1 =====");
      if (aclk_counter     !== 28) tb_error("====== CLOCK GENERATOR: ACLK (DIV /2) - TEST 2 =====");
`else
      repeat(54) @(posedge dco_clk);
      #1;
      if (dco_clk_counter  !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /2) - TEST 1 =====");
      if (aclk_counter     !== 27) tb_error("====== CLOCK GENERATOR: ACLK (DIV /2) - TEST 2 =====");
`endif

     
	                        // ------- Divider /4 ----------
      @(r15 === 16'h2003);
`ifdef LFXT_DOMAIN
      @(posedge lfxt_clk);
`else
      @(posedge dco_clk);
`endif
      #1;
      dco_clk_counter  = 0;
      lfxt_clk_counter = 0;
      aclk_counter     = 0;
`ifdef LFXT_DOMAIN
      repeat(54) @(posedge lfxt_clk);
      if (lfxt_clk_counter !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /4) - TEST 1 =====");
      if (aclk_counter     !== 14) tb_error("====== CLOCK GENERATOR: ACLK (DIV /4) - TEST 2 =====");
`else
      repeat(54) @(posedge dco_clk);
      if (dco_clk_counter  !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /4) - TEST 1 =====");
      if (aclk_counter     !== 14) tb_error("====== CLOCK GENERATOR: ACLK (DIV /4) - TEST 2 =====");
`endif
      
      
	                        // ------- Divider /8 ----------
      @(r15 === 16'h2004);
`ifdef LFXT_DOMAIN
      @(posedge lfxt_clk);
`else
      @(posedge dco_clk);
`endif
      #1;
      dco_clk_counter  = 0;
      lfxt_clk_counter = 0;
      aclk_counter     = 0;
`ifdef LFXT_DOMAIN
      repeat(54) @(posedge lfxt_clk);
      if (lfxt_clk_counter !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /8) - TEST 1 =====");
      if (aclk_counter     !== 7)  tb_error("====== CLOCK GENERATOR: ACLK (DIV /8) - TEST 2 =====");
`else
      repeat(54) @(posedge dco_clk);
      if (dco_clk_counter  !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /8) - TEST 1 =====");
      if (aclk_counter     !== 7)  tb_error("====== CLOCK GENERATOR: ACLK (DIV /8) - TEST 2 =====");
`endif
 
   `else
	                        // ------- Divider /2 ----------
      @(r15 === 16'h2002);
`ifdef LFXT_DOMAIN
      @(posedge lfxt_clk);
`else
      @(posedge dco_clk);
`endif
      #1;
      dco_clk_counter  = 0;
      lfxt_clk_counter = 0;
      aclk_counter     = 0;
`ifdef LFXT_DOMAIN
      repeat(54) @(posedge lfxt_clk);
      #1;
      if (lfxt_clk_counter !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /2) - TEST 1 =====");
      if (aclk_counter     !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /2) - TEST 2 =====");
`else
      repeat(54) @(posedge dco_clk);
      #1;
      if (dco_clk_counter  !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /2) - TEST 1 =====");
      if (aclk_counter     !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /2) - TEST 2 =====");
`endif

      
	                        // ------- Divider /4 ----------
      @(r15 === 16'h2003);
`ifdef LFXT_DOMAIN
      @(posedge lfxt_clk);
`else
      @(posedge dco_clk);
`endif
      #1;
      dco_clk_counter  = 0;
      lfxt_clk_counter = 0;
      aclk_counter     = 0;
`ifdef LFXT_DOMAIN
      repeat(54) @(posedge lfxt_clk);
      #1;
      if (lfxt_clk_counter !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /4) - TEST 1 =====");
      if (aclk_counter     !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /4) - TEST 2 =====");
`else
      repeat(54) @(posedge dco_clk);
      #1;
      if (dco_clk_counter  !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /4) - TEST 1 =====");
      if (aclk_counter     !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /4) - TEST 2 =====");
`endif
      
      
	                        // ------- Divider /8 ----------
      @(r15 === 16'h2004);
`ifdef LFXT_DOMAIN
      @(posedge lfxt_clk);
`else
      @(posedge dco_clk);
`endif
      #1;
      dco_clk_counter  = 0;
      lfxt_clk_counter = 0;
      aclk_counter     = 0;
`ifdef LFXT_DOMAIN
      repeat(54) @(posedge lfxt_clk);
      #1;
      if (lfxt_clk_counter !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /8) - TEST 1 =====");
      if (aclk_counter     !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /8) - TEST 2 =====");
`else
      repeat(54) @(posedge dco_clk);
      #1;
      if (dco_clk_counter  !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /8) - TEST 1 =====");
      if (aclk_counter     !== 54) tb_error("====== CLOCK GENERATOR: ACLK (DIV /8) - TEST 2 =====");
`endif
 
   `endif

      @(r15 === 16'h3000);
     

      // SMCLK GENERATION - DCO_CLK INPUT
      //--------------------------------------------------------

	                        // ------- Divider /1 ----------
      @(r15 === 16'h3001);
      @(posedge dco_clk);
      #1;
      dco_clk_counter = 0;
      smclk_counter   = 0;
      repeat(600) @(posedge dco_clk);
      if (dco_clk_counter !== 600) tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /1) - TEST 1 =====");
      if (smclk_counter   !== 600) tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /1) - TEST 2 =====");

   `ifdef SMCLK_DIVIDER
	                        // ------- Divider /2 ----------
      @(r15 === 16'h3002);
      @(posedge dco_clk);
      #1;
      dco_clk_counter = 0;
      smclk_counter   = 0;
      repeat(600) @(posedge dco_clk);
      if (dco_clk_counter !== 600) tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /2) - TEST 1 =====");
      if (smclk_counter   !== 300) tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /2) - TEST 2 =====");

      
	                        // ------- Divider /4 ----------
      @(r15 === 16'h3003);
      @(posedge dco_clk);
      #1;
      dco_clk_counter = 0;
      smclk_counter   = 0;
      repeat(600) @(posedge dco_clk);
      if (dco_clk_counter !== 600) tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /4) - TEST 1 =====");
      if (smclk_counter   !== 150) tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /4) - TEST 2 =====");
      
      
	                        // ------- Divider /8 ----------
      @(r15 === 16'h3004);
      @(posedge dco_clk);
      #1;
      dco_clk_counter = 0;
      smclk_counter   = 0;
      repeat(600) @(posedge dco_clk);
      if (dco_clk_counter !== 600) tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /8) - TEST 1 =====");
      if (smclk_counter   !== 75)  tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /8) - TEST 2 =====");

   `else
	                        // ------- Divider /2 ----------
      @(r15 === 16'h3002);
      @(posedge dco_clk);
      #1;
      dco_clk_counter = 0;
      smclk_counter   = 0;
      repeat(600) @(posedge dco_clk);
      if (dco_clk_counter !== 600) tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /2) - TEST 1 =====");
      if (smclk_counter   !== 600) tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /2) - TEST 2 =====");

      
	                        // ------- Divider /4 ----------
      @(r15 === 16'h3003);
      @(posedge dco_clk);
      #1;
      dco_clk_counter = 0;
      smclk_counter   = 0;
      repeat(600) @(posedge dco_clk);
      if (dco_clk_counter !== 600) tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /4) - TEST 1 =====");
      if (smclk_counter   !== 600) tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /4) - TEST 2 =====");
      
      
	                        // ------- Divider /8 ----------
      @(r15 === 16'h3004);
      @(posedge dco_clk);
      #1;
      dco_clk_counter = 0;
      smclk_counter   = 0;
      repeat(600) @(posedge dco_clk);
      if (dco_clk_counter !== 600) tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /8) - TEST 1 =====");
      if (smclk_counter   !== 600) tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /8) - TEST 2 =====");

   `endif

      @(r15 === 16'h4000);


      // SMCLK GENERATION - LFXT_CLK INPUT
      //--------------------------------------------------------
      // VERIFICATION DONE IN THE "CLOC_MODULE_ASIC_SMCLK" PATTERN
      @(r15 === 16'h5000);


      // CPU ENABLE - CPU_EN INPUT / DBG ENABLE - DBG_EN INPUT
      //--------------------------------------------------------

      @(r15 === 16'h5001);
      repeat(50) @(negedge dco_clk);
      if (dbg_freeze    == 1'b1) tb_error("====== DBG_FREEZE signal is active (test 1) =====");
      cpu_en        = 1'b0;
      #(3*763*2);
      reg_val       = r14;            // Read R14 register & initialize mclk/smclk/aclk counters
      mclk_counter  = 0;
      aclk_counter  = 0;
      smclk_counter = 0;

      #(50*500); // Make sure that the CPU is stopped
      if (reg_val       !== r14)  tb_error("====== CPU is not stopped (test 3) =====");
      if (mclk_counter  !== 0)    tb_error("====== MCLK is not stopped (test 4) =====");
`ifdef OSCOFF_EN
      if (aclk_counter  !== 0)    tb_error("====== ACLK is not stopped (test 5) =====");
`else
  `ifdef LFXT_DOMAIN
    `ifdef ACLK_DIVIDER
      if (aclk_counter  !== 0)    tb_error("====== ACLK is running     (test 5) =====");
    `else
      if (aclk_counter  !== 17)   tb_error("====== ACLK is not running (test 5) =====");
    `endif
  `else
      if (aclk_counter  !== 0)    tb_error("====== ACLK is running (test 5) =====");
  `endif
`endif
      if (smclk_counter !== 0)    tb_error("====== SMCLK is not stopped (test 6) =====");
      cpu_en = 1'b1;

      #(50*500); // Make sure that the CPU runs again
      if (reg_val       == r14)  tb_error("====== CPU is not running (test 7) =====");
      if (mclk_counter  == 0)    tb_error("====== MCLK is not running (test 8) =====");
      if (aclk_counter  == 0)    tb_error("====== ACLK is not running (test 9) =====");
      if (smclk_counter == 0)    tb_error("====== SMCLK is not running (test 10) =====");

      
      @(r15 === 16'h5002);
`ifdef DBG_EN
      repeat(50) @(posedge dco_clk);
      if (dbg_freeze     == 1'b1) tb_error("====== DBG_FREEZE signal is active (test 1) =====");
      if (dbg_rst        == 1'b0) tb_error("====== DBG_RST signal is not active (test 2) =====");

      dbg_en = 1'b1;
      repeat(6)  @(posedge mclk);
      reg_val         = r14;          // Read R14 register & initialize mclk/smclk/aclk/dbg_clk counters
      mclk_counter    = 0;
      aclk_counter    = 0;
      smclk_counter   = 0;
      dbg_clk_counter = 0;
      if (dbg_freeze     == 1'b1) tb_error("====== DBG_FREEZE signal is not active (test 3) =====");
      if (dbg_rst       !== 1'b0) tb_error("====== DBG_RST signal is active (test 4) =====");

      repeat(500) @(posedge dco_clk); // Make sure that the DBG interface runs
      if (reg_val          == r14)  tb_error("====== CPU is stopped (test 5) =====");
      if (mclk_counter     == 0)    tb_error("====== MCLK is stopped (test 6) =====");
      if (aclk_counter     == 0)    tb_error("====== ACLK is stopped (test 7) =====");
      if (smclk_counter    == 0)    tb_error("====== SMCLK is stopped (test 8) =====");
      if (dbg_clk_counter  == 0)    tb_error("====== DBG_CLK is stopped (test 9) =====");
      if (dbg_freeze       == 1'b1) tb_error("====== DBG_FREEZE signal is active (test 10) =====");
      if (dbg_rst         !== 1'b0) tb_error("====== DBG_RST signal is active (test 11) =====");

      dbg_en = 1'b0;
      repeat(6)  @(posedge mclk);
      reg_val         = r14;          // Read R14 register & initialize mclk/smclk/aclk/dbg_clk counters
      mclk_counter    = 0;
      aclk_counter    = 0;
      smclk_counter   = 0;
      dbg_clk_counter = 0;
      if (dbg_freeze     == 1'b1) tb_error("====== DBG_FREEZE signal is not active (test 12) =====");
      if (dbg_rst        == 1'b0) tb_error("====== DBG_RST signal is not active (test 13) =====");

      repeat(500) @(posedge dco_clk); // Make sure that the DBG interface is stopped
      if (reg_val          == r14)  tb_error("====== CPU is not running (test 14) =====");
      if (mclk_counter     == 0)    tb_error("====== MCLK is not running (test 15) =====");
      if (aclk_counter     == 0)    tb_error("====== ACLK is not running (test 16) =====");
      if (smclk_counter    == 0)    tb_error("====== SMCLK is not running (test 17) =====");
      if (dbg_clk_counter !== 0)    tb_error("====== DBG_CLK is not stopped (test 18) =====");
      if (dbg_freeze       == 1'b1) tb_error("====== DBG_FREEZE signal is active (test 19) =====");
      if (dbg_rst          == 1'b0) tb_error("====== DBG_RST signal is not active (test 20) =====");

      if (r15 !== 16'h5002) tb_error("====== DBG_EN did generate a PUC reset (test 21) =====");
`endif

      @(r15 === 16'h6000);


      // RD/WR ACCESS TO REGISTERS
      //--------------------------------------------------------

      bcsctl1_mask = 16'h0000;
      bcsctl2_mask = 16'h0000;

`ifdef ASIC_CLOCKING
  `ifdef ACLK_DIVIDER
      bcsctl1_mask = bcsctl1_mask | 16'h0030;
  `endif  
`else
      bcsctl1_mask = bcsctl1_mask | 16'h0030;
`endif
      
`ifdef MCLK_MUX
      bcsctl2_mask = bcsctl2_mask | 16'h0080;
`endif
`ifdef MCLK_DIVIDER
      bcsctl2_mask = bcsctl2_mask | 16'h0030;
`endif
`ifdef ASIC_CLOCKING
  `ifdef SMCLK_MUX
      bcsctl2_mask = bcsctl2_mask | 16'h0008;
  `endif
  `ifdef SMCLK_DIVIDER
      bcsctl2_mask = bcsctl2_mask | 16'h0006;
  `endif
`else
      bcsctl2_mask = bcsctl2_mask | 16'h0008;
      bcsctl2_mask = bcsctl2_mask | 16'h0006;
`endif

       @(r15 === 16'h7000);
       if (r4  !== 16'h0000)     tb_error("====== BCSCTL1 rd/wr access error (test 1) =====");
       if (r5  !== 16'h0000)     tb_error("====== BCSCTL2 rd/wr access error (test 1) =====");

       if (r6  !== bcsctl1_mask) tb_error("====== BCSCTL1 rd/wr access error (test 2) =====");
       if (r7  !== 16'h0000)     tb_error("====== BCSCTL2 rd/wr access error (test 2) =====");

       if (r8  !== 16'h0000)     tb_error("====== BCSCTL1 rd/wr access error (test 3) =====");
       if (r9  !== 16'h0000)     tb_error("====== BCSCTL2 rd/wr access error (test 3) =====");

       if (r10 !== 16'h0000)     tb_error("====== BCSCTL1 rd/wr access error (test 4) =====");
       if (r11 !== bcsctl2_mask) tb_error("====== BCSCTL2 rd/wr access error (test 4) =====");

       if (r12 !== 16'h0000)     tb_error("====== BCSCTL1 rd/wr access error (test 5) =====");
       if (r13 !== 16'h0000)     tb_error("====== BCSCTL2 rd/wr access error (test 5) =====");
   

`else
      $display(" ===============================================");
      $display("|               SIMULATION SKIPPED              |");
      $display("|   (this test is not supported in FPGA mode)   |");
      $display(" ===============================================");
      $finish;
`endif

      stimulus_done = 1;
   end

