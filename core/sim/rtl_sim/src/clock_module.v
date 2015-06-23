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
/* $Rev: 180 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2013-02-25 22:23:18 +0100 (Mon, 25 Feb 2013) $          */
/*===========================================================================*/

`define LONG_TIMEOUT

integer mclk_counter;
always @ (negedge mclk)
  mclk_counter <=  mclk_counter+1;

integer aclk_counter;
always @ (negedge mclk)
  if (aclk_en) aclk_counter <=  aclk_counter+1;

integer smclk_counter;
always @ (negedge mclk)
  if (smclk_en) smclk_counter <=  smclk_counter+1;

reg [15:0] reg_val;
   
initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

`ifdef ASIC_CLOCKING
      $display(" ===============================================");
      $display("|               SIMULATION SKIPPED              |");
      $display("|   (this test is not supported in ASIC mode)   |");
      $display(" ===============================================");
      $finish;
`else

      // ACLK GENERATION
      //--------------------------------------------------------

	                        // ------- Divider /1 ----------
      @(r15 === 16'h0001);
      @(negedge aclk_en);
      mclk_counter = 0;
      aclk_counter = 0;
      repeat(735) @(posedge mclk);
      if (mclk_counter !== 735) tb_error("====== CLOCK GENERATOR: ACLK (DIV /1) =====");
      if (aclk_counter !== 24)  tb_error("====== CLOCK GENERATOR: ACLK (DIV /1) =====");

      
	                        // ------- Divider /2 ----------
      @(r15 === 16'h0002);
      @(negedge aclk_en);
      mclk_counter = 0;
      aclk_counter = 0;
      repeat(735) @(posedge mclk);
      if (mclk_counter !== 735) tb_error("====== CLOCK GENERATOR: ACLK (DIV /2) =====");
      if (aclk_counter !== 12)  tb_error("====== CLOCK GENERATOR: ACLK (DIV /2) =====");

      
	                        // ------- Divider /4 ----------
      @(r15 === 16'h0003);
      @(negedge aclk_en);
      mclk_counter = 0;
      aclk_counter = 0;
      repeat(735) @(posedge mclk);
      if (mclk_counter !== 735) tb_error("====== CLOCK GENERATOR: ACLK (DIV /4) =====");
      if (aclk_counter !== 6)   tb_error("====== CLOCK GENERATOR: ACLK (DIV /4) =====");
      
      
	                        // ------- Divider /8 ----------
      @(r15 === 16'h0004);
      @(negedge aclk_en);
      mclk_counter = 0;
      aclk_counter = 0;
      repeat(735) @(posedge mclk);
      if (mclk_counter !== 735) tb_error("====== CLOCK GENERATOR: ACLK (DIV /8) =====");
      if (aclk_counter !== 3)   tb_error("====== CLOCK GENERATOR: ACLK (DIV /8) =====");
 
     
      // SMCLK GENERATION - LFXT_CLK INPUT
      //--------------------------------------------------------

	                        // ------- Divider /1 ----------
      @(r15 === 16'h1001);
      @(negedge smclk_en);
      mclk_counter = 0;
      smclk_counter = 0;
      repeat(735) @(posedge mclk);
      if (mclk_counter !== 735) tb_error("====== CLOCK GENERATOR: SMCLK - LFXT_CLK INPUT (DIV /1) =====");
      if (smclk_counter !== 24) tb_error("====== CLOCK GENERATOR: SMCLK - LFXT_CLK INPUT (DIV /1) =====");

      
	                        // ------- Divider /2 ----------
      @(r15 === 16'h1002);
      @(negedge smclk_en);
      mclk_counter = 0;
      smclk_counter = 0;
      repeat(735) @(posedge mclk);
      if (mclk_counter !== 735) tb_error("====== CLOCK GENERATOR: SMCLK - LFXT_CLK INPUT (DIV /2) =====");
      if (smclk_counter !== 12) tb_error("====== CLOCK GENERATOR: SMCLK - LFXT_CLK INPUT (DIV /2) =====");

      
	                        // ------- Divider /4 ----------
      @(r15 === 16'h1003);
      @(negedge smclk_en);
      mclk_counter = 0;
      smclk_counter = 0;
      repeat(735) @(posedge mclk);
      if (mclk_counter !== 735) tb_error("====== CLOCK GENERATOR: SMCLK - LFXT_CLK INPUT (DIV /4) =====");
      if (smclk_counter !== 6)  tb_error("====== CLOCK GENERATOR: SMCLK - LFXT_CLK INPUT (DIV /4) =====");
      
      
	                        // ------- Divider /8 ----------
      @(r15 === 16'h1004);
      @(negedge smclk_en);
      mclk_counter = 0;
      smclk_counter = 0;
      repeat(735) @(posedge mclk);
      if (mclk_counter !== 735) tb_error("====== CLOCK GENERATOR: SMCLK - LFXT_CLK INPUT (DIV /8) =====");
      if (smclk_counter !== 3)  tb_error("====== CLOCK GENERATOR: SMCLK - LFXT_CLK INPUT (DIV /8) =====");

      
      // SMCLK GENERATION - DCO_CLK INPUT
      //--------------------------------------------------------

	                        // ------- Divider /1 ----------
      @(r15 === 16'h2001);
      mclk_counter = 0;
      smclk_counter = 0;
      repeat(600) @(posedge mclk);
      if (mclk_counter !== 600)  tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /1) =====");
      if (smclk_counter !== 600) tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /1) =====");

	                        // ------- Divider /2 ----------
      @(r15 === 16'h2002);
      @(negedge smclk_en);
      mclk_counter = 0;
      smclk_counter = 0;
      repeat(600) @(posedge mclk);
      if (mclk_counter !== 600)  tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /2) =====");
      if (smclk_counter !== 300) tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /2) =====");

      
	                        // ------- Divider /4 ----------
      @(r15 === 16'h2003);
      @(negedge smclk_en);
      mclk_counter = 0;
      smclk_counter = 0;
      repeat(600) @(posedge mclk);
      if (mclk_counter !== 600)  tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /4) =====");
      if (smclk_counter !== 150) tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /4) =====");
      
      
	                        // ------- Divider /8 ----------
      @(r15 === 16'h2004);
      @(negedge smclk_en);
      mclk_counter = 0;
      smclk_counter = 0;
      repeat(600) @(posedge mclk);
      if (mclk_counter !== 600)  tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /8) =====");
      if (smclk_counter !== 75)  tb_error("====== CLOCK GENERATOR: SMCLK - DCO_CLK INPUT (DIV /8) =====");
 

      // CPU ENABLE - CPU_EN INPUT
      //--------------------------------------------------------

      @(r15 === 16'h3000);
      repeat(50) @(posedge mclk);
      if (dbg_freeze    == 1'b1) tb_error("====== DBG_FREEZE signal is active (test 1) =====");
      cpu_en        = 1'b0;
      repeat(3)   @(posedge mclk);
      reg_val       = r14;           // Read R14 register & initialize aclk/smclk counters
      aclk_counter  = 0;
      smclk_counter = 0;
      repeat(3)   @(posedge mclk);
      if (dbg_freeze    !== 1'b1) tb_error("====== DBG_FREEZE signal is not active (test 2) =====");

      repeat(500) @(posedge mclk);   // Make sure that the CPU is stopped
      if (reg_val       !== r14)  tb_error("====== CPU is not stopped (test 3) =====");
      if (aclk_counter  !== 0)    tb_error("====== ACLK is not stopped (test 4) =====");
      if (smclk_counter !== 0)    tb_error("====== SMCLK is not stopped (test 5) =====");
      if (dbg_freeze    !== 1'b1) tb_error("====== DBG_FREEZE signal is not active (test 6) =====");
      cpu_en = 1'b1;

      repeat(500) @(posedge mclk);  // Make sure that the CPU runs again
      if (reg_val       == r14)  tb_error("====== CPU is not running (test 7) =====");
      if (aclk_counter  == 0)    tb_error("====== ACLK is not running (test 8) =====");
      if (smclk_counter == 0)    tb_error("====== SMCLK is not running (test 9) =====");
      if (dbg_freeze    == 1'b1) tb_error("====== DBG_FREEZE signal is active (test 10) =====");


      // RD/WR ACCESS TO REGISTERS
      //--------------------------------------------------------

      @(r15 === 16'h5000);
      if (r4  !== 16'h0000) tb_error("====== BCSCTL1 rd/wr access error (test 1) =====");
      if (r5  !== 16'h0000) tb_error("====== BCSCTL2 rd/wr access error (test 1) =====");

      if (r6  !== 16'h0030) tb_error("====== BCSCTL1 rd/wr access error (test 2) =====");
      if (r7  !== 16'h0000) tb_error("====== BCSCTL2 rd/wr access error (test 2) =====");

      if (r8  !== 16'h0000) tb_error("====== BCSCTL1 rd/wr access error (test 3) =====");
      if (r9  !== 16'h0000) tb_error("====== BCSCTL2 rd/wr access error (test 3) =====");

      if (r10 !== 16'h0000) tb_error("====== BCSCTL1 rd/wr access error (test 4) =====");
      if (r11 !== 16'h000e) tb_error("====== BCSCTL2 rd/wr access error (test 4) =====");

      if (r12 !== 16'h0000) tb_error("====== BCSCTL1 rd/wr access error (test 5) =====");
      if (r13 !== 16'h0000) tb_error("====== BCSCTL2 rd/wr access error (test 5) =====");
   
`endif

      stimulus_done = 1;
   end

