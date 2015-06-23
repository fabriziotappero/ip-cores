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
/*                        - Check the MCLK clock generation.                 */
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

integer mclk_counter;
always @ (negedge mclk)
  mclk_counter     <=  mclk_counter+1;

integer dco_clk_counter;
always @ (negedge dco_clk)
  dco_clk_counter  <=  dco_clk_counter+1;

integer lfxt_clk_counter;
always @ (negedge lfxt_clk)
  lfxt_clk_counter <=  lfxt_clk_counter+1;

reg [15:0] reg_val;
   
initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

      force tb_openMSP430.dut.wdt_reset = 1'b0;

`ifdef ASIC_CLOCKING
     
      //--------------------------------------------------------
      // MCLK GENERATION - LFXT_CLK INPUT
      //--------------------------------------------------------

	                        // ------- Divider /1 ----------
      @(r15 === 16'h0001);
      repeat(2) @(posedge mclk);
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      dco_clk_counter  = 0;
      repeat(15) @(posedge mclk);
      if (mclk_counter     !==  15) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /1) - TEST 1 =====");
  `ifdef MCLK_MUX
      if (lfxt_clk_counter !==  15) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /1) - TEST 2 =====");
  `else
      if (dco_clk_counter  !==  15) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /1) - TEST 3 =====");
  `endif

	                        // ------- Divider /2 ----------
      @(r15 === 16'h0002);
      repeat(2) @(posedge mclk);
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      dco_clk_counter  = 0;
      repeat(15) @(posedge mclk);
      if (mclk_counter     !==  15) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /2) - TEST 1 =====");
  `ifdef MCLK_DIVIDER
    `ifdef MCLK_MUX
      if (lfxt_clk_counter !==  30) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /2) - TEST 2 =====");
    `else
      if (dco_clk_counter  !==  30) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /2) - TEST 3 =====");
    `endif
  `else
    `ifdef MCLK_MUX
      if (lfxt_clk_counter !==  15) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /2) - TEST 4 =====");
    `else
      if (dco_clk_counter  !==  15) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /2) - TEST 5 =====");
    `endif
  `endif
      
	                        // ------- Divider /4 ----------
      @(r15 === 16'h0003);
      repeat(2) @(posedge mclk);
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      dco_clk_counter  = 0;
      repeat(15) @(posedge mclk);
      if (mclk_counter     !==  15) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /4) - TEST 1 =====");
  `ifdef MCLK_DIVIDER
    `ifdef MCLK_MUX
      if (lfxt_clk_counter !==  60) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /4) - TEST 2 =====");
    `else
      if (dco_clk_counter  !==  60) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /4) - TEST 3 =====");
    `endif
  `else
    `ifdef MCLK_MUX
      if (lfxt_clk_counter !==  15) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /4) - TEST 4 =====");
    `else
      if (dco_clk_counter  !==  15) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /4) - TEST 5 =====");
    `endif
  `endif
      
	                        // ------- Divider /8 ----------
      @(r15 === 16'h0004);
      repeat(2) @(posedge mclk);
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      dco_clk_counter  = 0;
      repeat(15) @(posedge mclk);
      if (mclk_counter     !==  15) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /8) - TEST 1 =====");
  `ifdef MCLK_DIVIDER
    `ifdef MCLK_MUX
      if (lfxt_clk_counter !== 120) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /8) - TEST 2 =====");
    `else
      if (dco_clk_counter  !== 120) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /8) - TEST 3 =====");
    `endif
  `else
    `ifdef MCLK_MUX
      if (lfxt_clk_counter !==  15) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /8) - TEST 4 =====");
    `else
      if (dco_clk_counter  !==  15) tb_error("====== CLOCK GENERATOR 1: MCLK - LFXT_CLK INPUT (DIV /8) - TEST 5 =====");
    `endif
  `endif

      
      //--------------------------------------------------------
      // SMCLK GENERATION - DCO_CLK INPUT
      //--------------------------------------------------------

	                        // ------- Divider /1 ----------
      @(r15 === 16'h1001);
      repeat(2) @(posedge mclk);
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      dco_clk_counter  = 0;
      repeat(15) @(posedge mclk);
      if (mclk_counter    !==  15) tb_error("====== CLOCK GENERATOR 2: MCLK - DCO_CLK INPUT (DIV /1) - TEST 1 =====");
      if (dco_clk_counter !==  15) tb_error("====== CLOCK GENERATOR 2: MCLK - DCO_CLK INPUT (DIV /1) - TEST 2 =====");

	                        // ------- Divider /2 ----------
      @(r15 === 16'h1002);
      repeat(2) @(posedge mclk);
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      dco_clk_counter  = 0;
      repeat(15) @(posedge mclk);
      if (mclk_counter    !==  15) tb_error("====== CLOCK GENERATOR 2: MCLK - DCO_CLK INPUT (DIV /2) - TEST 1 =====");
  `ifdef MCLK_DIVIDER
      if (dco_clk_counter !==  30) tb_error("====== CLOCK GENERATOR 2: MCLK - DCO_CLK INPUT (DIV /2) - TEST 2 =====");
  `else
      if (dco_clk_counter !==  15) tb_error("====== CLOCK GENERATOR 2: MCLK - DCO_CLK INPUT (DIV /2) - TEST 3 =====");
  `endif
      
	                        // ------- Divider /4 ----------
      @(r15 === 16'h1003);
      repeat(2) @(posedge mclk);
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      dco_clk_counter  = 0;
      repeat(15) @(posedge mclk);
      if (mclk_counter    !==  15) tb_error("====== CLOCK GENERATOR 2: MCLK - DCO_CLK INPUT (DIV /4) - TEST 1 =====");
  `ifdef MCLK_DIVIDER
      if (dco_clk_counter !==  60) tb_error("====== CLOCK GENERATOR 2: MCLK - DCO_CLK INPUT (DIV /4) - TEST 2 =====");
  `else
      if (dco_clk_counter !==  15) tb_error("====== CLOCK GENERATOR 2: MCLK - DCO_CLK INPUT (DIV /4) - TEST 3 =====");
  `endif
      
	                        // ------- Divider /8 ----------
      @(r15 === 16'h1004);
      repeat(2) @(posedge mclk);
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      dco_clk_counter  = 0;
      repeat(15) @(posedge mclk);
      if (mclk_counter    !==  15) tb_error("====== CLOCK GENERATOR 2: MCLK - DCO_CLK INPUT (DIV /8) - TEST 1 =====");
  `ifdef MCLK_DIVIDER
      if (dco_clk_counter !== 120) tb_error("====== CLOCK GENERATOR 2: MCLK - DCO_CLK INPUT (DIV /8) - TEST 2 =====");
  `else
      if (dco_clk_counter !==  15) tb_error("====== CLOCK GENERATOR 2: MCLK - DCO_CLK INPUT (DIV /8) - TEST 3 =====");
  `endif


      //--------------------------------------------------------
      // MCLK GENERATION - LFXT_CLK INPUT
      //--------------------------------------------------------

	                        // ------- Divider /1 ----------
      @(r15 === 16'h2001);
      repeat(2) @(posedge mclk);
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      dco_clk_counter  = 0;
      repeat(15) @(posedge mclk);
      if (mclk_counter     !==  15) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /1) - TEST 1 =====");
  `ifdef MCLK_MUX
      if (lfxt_clk_counter !==  15) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /1) - TEST 2 =====");
  `else
      if (dco_clk_counter  !==  15) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /1) - TEST 3 =====");
  `endif

	                        // ------- Divider /2 ----------
      @(r15 === 16'h2002);
      repeat(2) @(posedge mclk);
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      dco_clk_counter  = 0;
      repeat(15) @(posedge mclk);
      if (mclk_counter     !==  15) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /2) - TEST 1 =====");
  `ifdef MCLK_DIVIDER
    `ifdef MCLK_MUX
      if (lfxt_clk_counter !==  30) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /2) - TEST 2 =====");
    `else
      if (dco_clk_counter  !==  30) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /2) - TEST 3 =====");
    `endif
  `else
    `ifdef MCLK_MUX
      if (lfxt_clk_counter !==  15) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /2) - TEST 4 =====");
    `else
      if (dco_clk_counter  !==  15) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /2) - TEST 5 =====");
    `endif
  `endif
      
	                        // ------- Divider /4 ----------
      @(r15 === 16'h2003);
      repeat(2) @(posedge mclk);
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      dco_clk_counter  = 0;
      repeat(15) @(posedge mclk);
      if (mclk_counter     !==  15) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /4) - TEST 1 =====");
  `ifdef MCLK_DIVIDER
    `ifdef MCLK_MUX
      if (lfxt_clk_counter !==  60) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /4) - TEST 2 =====");
    `else
      if (dco_clk_counter  !==  60) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /4) - TEST 3 =====");
    `endif
  `else
    `ifdef MCLK_MUX
      if (lfxt_clk_counter !==  15) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /4) - TEST 4 =====");
    `else
      if (dco_clk_counter  !==  15) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /4) - TEST 5 =====");
    `endif
  `endif
      
	                        // ------- Divider /8 ----------
      @(r15 === 16'h2004);
      repeat(2) @(posedge mclk);
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      dco_clk_counter  = 0;
      repeat(15) @(posedge mclk);
      if (mclk_counter     !==  15) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /8) - TEST 1 =====");
  `ifdef MCLK_DIVIDER
    `ifdef MCLK_MUX
      if (lfxt_clk_counter !== 120) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /8) - TEST 2 =====");
    `else
      if (dco_clk_counter  !== 120) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /8) - TEST 3 =====");
    `endif
  `else
    `ifdef MCLK_MUX
      if (lfxt_clk_counter !==  15) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /8) - TEST 4 =====");
    `else
      if (dco_clk_counter  !==  15) tb_error("====== CLOCK GENERATOR 3: MCLK - LFXT_CLK INPUT (DIV /8) - TEST 5 =====");
    `endif
  `endif

      
      //--------------------------------------------------------
      // SMCLK GENERATION - DCO_CLK INPUT
      //--------------------------------------------------------

	                        // ------- Divider /1 ----------
      @(r15 === 16'h3001);
      repeat(2) @(posedge mclk);
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      dco_clk_counter  = 0;
      repeat(15) @(posedge mclk);
      if (mclk_counter    !==  15) tb_error("====== CLOCK GENERATOR 4: MCLK - DCO_CLK INPUT (DIV /1) - TEST 1 =====");
      if (dco_clk_counter !==  15) tb_error("====== CLOCK GENERATOR 4: MCLK - DCO_CLK INPUT (DIV /1) - TEST 2 =====");

	                        // ------- Divider /2 ----------
      @(r15 === 16'h3002);
      repeat(2) @(posedge mclk);
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      dco_clk_counter  = 0;
      repeat(15) @(posedge mclk);
      if (mclk_counter    !==  15) tb_error("====== CLOCK GENERATOR 4: MCLK - DCO_CLK INPUT (DIV /2) - TEST 1 =====");
  `ifdef MCLK_DIVIDER
      if (dco_clk_counter !==  30) tb_error("====== CLOCK GENERATOR 4: MCLK - DCO_CLK INPUT (DIV /2) - TEST 2 =====");
  `else
      if (dco_clk_counter !==  15) tb_error("====== CLOCK GENERATOR 4: MCLK - DCO_CLK INPUT (DIV /2) - TEST 3 =====");
  `endif
      
	                        // ------- Divider /4 ----------
      @(r15 === 16'h3003);
      repeat(2) @(posedge mclk);
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      dco_clk_counter  = 0;
      repeat(15) @(posedge mclk);
      if (mclk_counter    !==  15) tb_error("====== CLOCK GENERATOR 4: MCLK - DCO_CLK INPUT (DIV /4) - TEST 1 =====");
  `ifdef MCLK_DIVIDER
      if (dco_clk_counter !==  60) tb_error("====== CLOCK GENERATOR 4: MCLK - DCO_CLK INPUT (DIV /4) - TEST 2 =====");
  `else
      if (dco_clk_counter !==  15) tb_error("====== CLOCK GENERATOR 4: MCLK - DCO_CLK INPUT (DIV /4) - TEST 3 =====");
  `endif
      
	                        // ------- Divider /8 ----------
      @(r15 === 16'h3004);
      repeat(2) @(posedge mclk);
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      dco_clk_counter  = 0;
      repeat(15) @(posedge mclk);
      if (mclk_counter    !==  15) tb_error("====== CLOCK GENERATOR 4: MCLK - DCO_CLK INPUT (DIV /8) - TEST 1 =====");
  `ifdef MCLK_DIVIDER
      if (dco_clk_counter !== 120) tb_error("====== CLOCK GENERATOR 4: MCLK - DCO_CLK INPUT (DIV /8) - TEST 2 =====");
  `else
      if (dco_clk_counter !==  15) tb_error("====== CLOCK GENERATOR 4: MCLK - DCO_CLK INPUT (DIV /8) - TEST 3 =====");
  `endif


`else
      $display(" ===============================================");
      $display("|               SIMULATION SKIPPED              |");
      $display("|   (this test is not supported in FPGA mode)   |");
      $display(" ===============================================");
      $finish;
`endif

      stimulus_done = 1;
   end

