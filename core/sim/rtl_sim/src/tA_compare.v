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
/*                                  TIMER A                                  */
/*---------------------------------------------------------------------------*/
/* Test the timer A:                                                         */
/*                        - Check the timer compare features.                */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 180 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2013-02-25 22:23:18 +0100 (Mon, 25 Feb 2013) $          */
/*===========================================================================*/

integer my_counter;
always @ (posedge mclk)
  my_counter <=  my_counter+1;


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

      // TIMER A TEST:  UP MODE
      //--------------------------------------------------------

      @(mem200 === 16'h0001);  // Check Comparator 0
      @(posedge ta_out0);
      @(negedge mclk);
      my_counter = 0;
      @(posedge irq_ta1);
      if (my_counter !== 32'h2) tb_error("====== TIMER_A COMPARE 0: UP MODE =====");

      @(negedge ta_out0);
      @(negedge mclk);
      my_counter = 0;
      @(posedge irq_ta1);
      if (my_counter !== 32'h2) tb_error("====== TIMER_A COMPARE 0: UP MODE =====");
      @(posedge ta_out0);
      if (my_counter !== 32'h2C) tb_error("====== TIMER_A COMPARE 0: UP MODE =====");

      @(posedge irq_ta0);
      @(negedge mclk);
      my_counter = 0;
      @(posedge irq_ta1);
      if (my_counter !== 32'h2) tb_error("====== TIMER_A COMPARE 0: UP MODE =====");

      
      @(mem200 === 16'h0002);  // Check Comparator 1
      @(posedge ta_out1);
      @(negedge mclk);
      my_counter = 0;
      @(posedge ta_out0);
      if (my_counter !== 32'h20) tb_error("====== TIMER_A COMPARE 1: UP MODE =====");

      @(negedge ta_out1);
      @(negedge mclk);
      my_counter = 0;
      @(negedge ta_out0);
      if (my_counter !== 32'h20) tb_error("====== TIMER_A COMPARE 1: UP MODE =====");

      @(posedge irq_ta1);
      @(negedge mclk);
      my_counter = 0;
      @(posedge ta_out0);
      if (my_counter !== 32'h20) tb_error("====== TIMER_A COMPARE 1: UP MODE =====");

      
      @(mem200 === 16'h0003);  // Check Comparator 2
      @(posedge ta_out2);
      @(negedge mclk);
      my_counter = 0;
      @(posedge ta_out0);
      if (my_counter !== 32'h12) tb_error("====== TIMER_A COMPARE 2: UP MODE =====");

      @(negedge ta_out2);
      @(negedge mclk);
      my_counter = 0;
      @(negedge ta_out0);
      if (my_counter !== 32'h12) tb_error("====== TIMER_A COMPARE 2: UP MODE =====");

      @(posedge irq_ta1);
      @(negedge mclk);
      my_counter = 0;
      @(posedge ta_out0);
      if (my_counter !== 32'h12) tb_error("====== TIMER_A COMPARE 2: UP MODE =====");
      

      // TIMER A TEST:  CONTINUOUS MODE
      //--------------------------------------------------------
      
      @(mem200 === 16'h0001);
      @(posedge irq_ta1);
      @(negedge mclk);
      my_counter = 0;
      @(negedge irq_ta1);
      repeat(10) @(negedge mclk);
      if (mem206 !== 16'h000A) tb_error("====== TIMER_A COMPARE: CONTINUOUS MODE - TEST 1 =====");

      @(posedge ta_out0);
      if (my_counter !== 32'h60) tb_error("====== TIMER_A COMPARE 0: CONTINUOUS MODE - TEST 1 =====");

      @(posedge ta_out1);
      if (my_counter !== 32'hC0) tb_error("====== TIMER_A COMPARE 1: CONTINUOUS MODE - TEST 1 =====");
      @(negedge irq_ta1);
      repeat(10) @(negedge mclk);
      if (mem206 !== 16'h0002) tb_error("====== TIMER_A COMPARE 1: CONTINUOUS MODE - TEST 1 =====");

      @(posedge ta_out2);
      if (my_counter !== 32'h120) tb_error("====== TIMER_A COMPARE 2: CONTINUOUS MODE - TEST 1 =====");
      @(negedge irq_ta1);
      repeat(10) @(negedge mclk);
      if (mem206 !== 16'h0004) tb_error("====== TIMER_A COMPARE 2: CONTINUOUS MODE - TEST 1 =====");

      
      @(mem200 === 16'h0002);
      @(posedge irq_ta1);
      @(negedge mclk);
      my_counter = 0;
      @(negedge irq_ta1);
      repeat(10) @(negedge mclk);
      if (mem206 !== 16'h000A) tb_error("====== TIMER_A COMPARE: CONTINUOUS MODE - TEST 2 =====");

      @(posedge irq_ta0);
      if (my_counter !== 32'h60) tb_error("====== TIMER_A COMPARE 0: CONTINUOUS MODE - TEST 2 =====");

      @(posedge irq_ta1);
      if (my_counter !== 32'hC0) tb_error("====== TIMER_A COMPARE 1: CONTINUOUS MODE - TEST 2 =====");
      @(negedge irq_ta1);
      repeat(10) @(negedge mclk);
      if (mem206 !== 16'h0002) tb_error("====== TIMER_A COMPARE 1: CONTINUOUS MODE - TEST 2 =====");

      @(posedge irq_ta1);
      if (my_counter !== 32'h120) tb_error("====== TIMER_A COMPARE 2: CONTINUOUS MODE - TEST 2 =====");
      @(negedge irq_ta1);
      repeat(10) @(negedge mclk);
      if (mem206 !== 16'h0004) tb_error("====== TIMER_A COMPARE 2: CONTINUOUS MODE - TEST 2 =====");

      
      
      // TIMER A TEST:  UP-DOWN MODE
      //--------------------------------------------------------

      @(mem200 === 16'h0001);
      @(posedge irq_ta1);
      @(negedge mclk);
      my_counter = 0;
      @(posedge ta_out2);
      if (my_counter !== 32'h60)  tb_error("====== TIMER_A COMPARE 2: CONTINUOUS MODE - TEST 1 =====");
      @(posedge ta_out1);
      if (my_counter !== 32'hC0)  tb_error("====== TIMER_A COMPARE 1: CONTINUOUS MODE - TEST 1 =====");
      @(posedge ta_out0);
      if (my_counter !== 32'h120) tb_error("====== TIMER_A COMPARE 0: CONTINUOUS MODE - TEST 1 =====");

      @(negedge ta_out1);
      if (my_counter !== 32'h180) tb_error("====== TIMER_A COMPARE 1: CONTINUOUS MODE - TEST 2 =====");
      @(negedge ta_out2);
      if (my_counter !== 32'h1E0) tb_error("====== TIMER_A COMPARE 2: CONTINUOUS MODE - TEST 2 =====");
      @(negedge ta_out0);
      if (my_counter !== 32'h360) tb_error("====== TIMER_A COMPARE 0: CONTINUOUS MODE - TEST 2 =====");

      
      @(mem200 === 16'h0002);
      @(posedge irq_ta1);
      @(negedge mclk);
      my_counter = 0;
      @(negedge irq_ta1);
      repeat(10) @(negedge mclk);
      if (mem206 !== 16'h000A)    tb_error("====== TIMER_A COMPARE: CONTINUOUS MODE - TEST 3 =====");
      @(posedge irq_ta1);
      if (my_counter !== 32'h60)  tb_error("====== TIMER_A COMPARE 2: CONTINUOUS MODE - TEST 3 =====");
      @(negedge irq_ta1);
      repeat(10) @(negedge mclk);
      if (mem206 !== 16'h0004)    tb_error("====== TIMER_A COMPARE 2: CONTINUOUS MODE - TEST 3 =====");
      @(posedge irq_ta1);
      if (my_counter !== 32'hC0)  tb_error("====== TIMER_A COMPARE 1: CONTINUOUS MODE - TEST 3 =====");
      @(negedge irq_ta1);
      repeat(10) @(negedge mclk);
      if (mem206 !== 16'h0002)    tb_error("====== TIMER_A COMPARE 1: CONTINUOUS MODE - TEST 3 =====");
      @(posedge irq_ta0);
      if (my_counter !== 32'h120) tb_error("====== TIMER_A COMPARE 0: CONTINUOUS MODE - TEST 3 =====");

      @(posedge irq_ta1);
      if (my_counter !== 32'h180) tb_error("====== TIMER_A COMPARE 1: CONTINUOUS MODE - TEST 4 =====");
      @(negedge irq_ta1);
      repeat(10) @(negedge mclk);
      if (mem206 !== 16'h0002)    tb_error("====== TIMER_A COMPARE 1: CONTINUOUS MODE - TEST 4 =====");
      @(posedge irq_ta1);
      if (my_counter !== 32'h1E0) tb_error("====== TIMER_A COMPARE 2: CONTINUOUS MODE - TEST 4 =====");
      @(negedge irq_ta1);
      repeat(10) @(negedge mclk);
      if (mem206 !== 16'h0004)    tb_error("====== TIMER_A COMPARE 2: CONTINUOUS MODE - TEST 4 =====");
      @(posedge irq_ta1);
      if (my_counter !== 32'h240) tb_error("====== TIMER_A COMPARE: CONTINUOUS MODE - TEST 4 =====");
      @(negedge irq_ta1);
      repeat(10) @(negedge mclk);
      if (mem206 !== 16'h000A)    tb_error("====== TIMER_A COMPARE: CONTINUOUS MODE - TEST 4 =====");
      @(posedge irq_ta0);
      if (my_counter !== 32'h360) tb_error("====== TIMER_A COMPARE: CONTINUOUS MODE - TEST 4 =====");


      // TIMER A TEST:  CCI INPUT LATCHING (SCCI)
      //--------------------------------------------------------

      @(r15 === 16'h4000);
      if (mem202 !== 16'h3088) tb_error("====== TIMER_A COMPARE 0: CCI INPUT LATCHING (SCCI) =====");
      if (mem204 !== 16'h3489) tb_error("====== TIMER_A COMPARE 0: CCI INPUT LATCHING (SCCI) =====");
      if (mem206 !== 16'h2480) tb_error("====== TIMER_A COMPARE 0: CCI INPUT LATCHING (SCCI) =====");
      if (mem208 !== 16'h2081) tb_error("====== TIMER_A COMPARE 0: CCI INPUT LATCHING (SCCI) =====");

      if (mem212 !== 16'h3088) tb_error("====== TIMER_A COMPARE 1: CCI INPUT LATCHING (SCCI) =====");
      if (mem214 !== 16'h3489) tb_error("====== TIMER_A COMPARE 1: CCI INPUT LATCHING (SCCI) =====");
      if (mem216 !== 16'h2480) tb_error("====== TIMER_A COMPARE 1: CCI INPUT LATCHING (SCCI) =====");
      if (mem218 !== 16'h2081) tb_error("====== TIMER_A COMPARE 1: CCI INPUT LATCHING (SCCI) =====");

      if (mem222 !== 16'h3088) tb_error("====== TIMER_A COMPARE 2: CCI INPUT LATCHING (SCCI) =====");
      if (mem224 !== 16'h3489) tb_error("====== TIMER_A COMPARE 2: CCI INPUT LATCHING (SCCI) =====");
      if (mem226 !== 16'h2480) tb_error("====== TIMER_A COMPARE 2: CCI INPUT LATCHING (SCCI) =====");
      if (mem228 !== 16'h2081) tb_error("====== TIMER_A COMPARE 2: CCI INPUT LATCHING (SCCI) =====");

`endif

      stimulus_done = 1;
   end

