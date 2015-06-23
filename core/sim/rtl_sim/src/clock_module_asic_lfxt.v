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
/*                        - Check the LFXT wakeup when selected sa MCLK.     */
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

`ifdef ASIC_CLOCKING
  `ifdef OSCOFF_EN
     `ifdef MCLK_MUX
    
      //--------------------------------------------------------
      // First make sure CPU runs with LFXT_CLK
      //--------------------------------------------------------

      @(r15 === 16'h0001);
      #10;
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      @(r15 === 16'h0002);
      #10;
      if (mclk_counter     !==  40) tb_error("====== CLOCK GENERATOR: TEST 1 =====");
      if (lfxt_clk_counter !==  40) tb_error("====== CLOCK GENERATOR: TEST 2 =====");
      if (r10              !==  0)  tb_error("====== CLOCK GENERATOR: TEST 3 =====");


      //--------------------------------------------------------
      // Make sure the CPU stops and LFXT oscillator too
      //--------------------------------------------------------

      #10000;
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      #10000;
      if (mclk_counter     !==  0)  tb_error("====== CLOCK GENERATOR: TEST 4 =====");
      if (lfxt_clk_counter !==  0)  tb_error("====== CLOCK GENERATOR: TEST 5 =====");
      if (r10              !==  0)  tb_error("====== CLOCK GENERATOR: TEST 6 =====");
      #10000;


      //--------------------------------------------------------
      // Generate IRQ and make sure CPU re-runs with LFXT_CLK
      //--------------------------------------------------------

      wkup[0]          = 1'b1;
      @(negedge mclk);
      irq[`IRQ_NR-16]  = 1'b1;
      @(negedge irq_acc[`IRQ_NR-16])
      @(negedge mclk);
      wkup[0]          = 1'b0;
      irq[`IRQ_NR-16]    = 1'b0;

      @(r15 === 16'h0003);
      #10;
      mclk_counter     = 0;
      lfxt_clk_counter = 0;
      @(r15 === 16'h0004);
      #10;
      if (mclk_counter     !==  40)        tb_error("====== CLOCK GENERATOR: TEST 7 =====");
      if (lfxt_clk_counter !==  40)        tb_error("====== CLOCK GENERATOR: TEST 8 =====");
      if (r10              !==  16'h5678)  tb_error("====== CLOCK GENERATOR: TEST 9 =====");


     `else
      $display(" ===============================================");
      $display("|               SIMULATION SKIPPED              |");
      $display("|   (this test requires the MCLK clock mux)     |");
      $display(" ===============================================");
      $finish;
     `endif
  `else
      $display(" ===============================================");
      $display("|               SIMULATION SKIPPED              |");
      $display("|   (this test requires the OSCOFF option)      |");
      $display(" ===============================================");
      $finish;
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

