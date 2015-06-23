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
/*                        - Check RD/WR register access.                     */
/*                        - Check the clock divider.                         */
/*                        - Check the timer modes.                           */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 180 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2013-02-25 22:23:18 +0100 (Mon, 25 Feb 2013) $          */
/*===========================================================================*/


integer test_step;
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
      test_step     = 0;
      
`ifdef ASIC_CLOCKING
      $display(" ===============================================");
      $display("|               SIMULATION SKIPPED              |");
      $display("|   (this test is not supported in ASIC mode)   |");
      $display(" ===============================================");
      $finish;
`else

      // TIMER A TEST:  RD/WR ACCESS
      //--------------------------------------------------------

      @(r15===16'h1000);
      if (mem200 !== 16'h02a2) tb_error("====== TIMER_A RD/WR REGISTERS: TACTL   ERROR =====");
      if (mem202 !== 16'h0151) tb_error("====== TIMER_A RD/WR REGISTERS: TACTL   ERROR =====");
      if (mem204 !== 16'h0000) tb_error("====== TIMER_A RD/WR REGISTERS: TACTL   ERROR =====");
      if (mem206 !== 16'h0000) tb_error("====== TIMER_A RD/WR REGISTERS: TACTL   ERROR =====");

      if (mem208 !== 16'haaaa) tb_error("====== TIMER_A RD/WR REGISTERS: TAR     ERROR =====");
      if (mem20A !== 16'h5555) tb_error("====== TIMER_A RD/WR REGISTERS: TAR     ERROR =====");
      if (mem20C !== 16'h0000) tb_error("====== TIMER_A RD/WR REGISTERS: TAR     ERROR =====");

      if (mem210 !== 16'ha8a2) tb_error("====== TIMER_A RD/WR REGISTERS: TACCTL0 ERROR =====");
      if (mem212 !== 16'h5155) tb_error("====== TIMER_A RD/WR REGISTERS: TACCTL0 ERROR =====");
      if (mem214 !== 16'h0000) tb_error("====== TIMER_A RD/WR REGISTERS: TACCTL0 ERROR =====");

      if (mem216 !== 16'haaaa) tb_error("====== TIMER_A RD/WR REGISTERS: TACCR0  ERROR =====");
      if (mem218 !== 16'h5555) tb_error("====== TIMER_A RD/WR REGISTERS: TACCR0  ERROR =====");
      if (mem21A !== 16'h0000) tb_error("====== TIMER_A RD/WR REGISTERS: TACCR0  ERROR =====");

      if (mem220 !== 16'ha8a2) tb_error("====== TIMER_A RD/WR REGISTERS: TACCTL1 ERROR =====");
      if (mem222 !== 16'h5155) tb_error("====== TIMER_A RD/WR REGISTERS: TACCTL1 ERROR =====");
      if (mem224 !== 16'h0000) tb_error("====== TIMER_A RD/WR REGISTERS: TACCTL1 ERROR =====");

      if (mem226 !== 16'haaaa) tb_error("====== TIMER_A RD/WR REGISTERS: TACCR1  ERROR =====");
      if (mem228 !== 16'h5555) tb_error("====== TIMER_A RD/WR REGISTERS: TACCR1  ERROR =====");
      if (mem22A !== 16'h0000) tb_error("====== TIMER_A RD/WR REGISTERS: TACCR1  ERROR =====");

      if (mem230 !== 16'ha8a2) tb_error("====== TIMER_A RD/WR REGISTERS: TACCTL2 ERROR =====");
      if (mem232 !== 16'h5155) tb_error("====== TIMER_A RD/WR REGISTERS: TACCTL2 ERROR =====");
      if (mem234 !== 16'h0000) tb_error("====== TIMER_A RD/WR REGISTERS: TACCTL2 ERROR =====");

      if (mem236 !== 16'haaaa) tb_error("====== TIMER_A RD/WR REGISTERS: TACCR2  ERROR =====");
      if (mem238 !== 16'h5555) tb_error("====== TIMER_A RD/WR REGISTERS: TACCR2  ERROR =====");
      if (mem23A !== 16'h0000) tb_error("====== TIMER_A RD/WR REGISTERS: TACCR2  ERROR =====");

      if (mem240 !== 16'h0000) tb_error("====== TIMER_A RD/WR REGISTERS: TAIV    ERROR =====");
      if (mem242 !== 16'h0000) tb_error("====== TIMER_A RD/WR REGISTERS: TAIV    ERROR =====");
      if (mem244 !== 16'h0000) tb_error("====== TIMER_A RD/WR REGISTERS: TAIV    ERROR =====");
      test_step = 1;
      
      // TIMER A TEST:  INPUT DIVIDER
      //--------------------------------------------------------

      @(mem200 === 16'h0001);  // Check /1 divider
      @(posedge irq_ta1)
      @(negedge mclk)
	my_counter = 0;
      @(posedge irq_ta1)
        if (my_counter !== 32'h21) tb_error("====== TIMER_A INPUT DIVIDER: /1 ERROR =====");
      test_step = 2;

      @(mem200 === 16'h0002);  // Check /2 divider
      @(posedge irq_ta1)
      @(negedge mclk)
	my_counter = 0;
      @(posedge irq_ta1)
        if (my_counter !== 32'h22) tb_error("====== TIMER_A INPUT DIVIDER: /2 ERROR =====");
      test_step = 3;

      @(mem200 === 16'h0003);  // Check /4 divider
      @(posedge irq_ta1)
      @(negedge mclk)
	my_counter = 0;
      @(posedge irq_ta1)
        if (my_counter !== 32'h24) tb_error("====== TIMER_A INPUT DIVIDER: /4 ERROR =====");
      test_step = 4;

      @(mem200 === 16'h0004);  // Check /8 divider
      @(posedge irq_ta1)
      @(negedge mclk)
	my_counter = 0;
      @(posedge irq_ta1)
        if (my_counter !== 32'h28) tb_error("====== TIMER_A INPUT DIVIDER: /8 ERROR =====");
      test_step = 5;

      @(r15===16'h2000);
      test_step = 6;

      
      // TIMER A TEST:  UP MODE
      //--------------------------------------------------------

      @(mem200 === 16'h0001);  // Check timing 1 - TAIFG interrupt
      @(posedge irq_ta1)
      @(negedge mclk)
	my_counter = 0;
      @(posedge irq_ta1)
        if (my_counter !== 32'h26) tb_error("====== TIMER_A UP MODE: TIMING 1 - TAIFG interrupt =====");
      test_step = 7;

      @(mem200 === 16'h0002);  // Check timing 2 - TAIFG interrupt
      @(posedge irq_ta1)
      @(negedge mclk)
	my_counter = 0;
      @(posedge irq_ta1)
        if (my_counter !== 32'h3E) tb_error("====== TIMER_A UP MODE: TIMING 2 - TAIFG interrupt =====");
      test_step = 8;
   
      @(mem200 === 16'h0003);  // Check timing 1 - TACCR0 interrupt
      @(posedge irq_ta0)
      @(negedge mclk)
	my_counter = 0;
      @(posedge irq_ta0)
        if (my_counter !== 32'h26) tb_error("====== TIMER_A UP MODE: TIMING 1 - TACCR0 interrupt =====");
      test_step = 8;

      @(mem200 === 16'h0004);  // Check timing 2 - TACCR0 interrupt
      @(posedge irq_ta0)
      @(negedge mclk)
	my_counter = 0;
      @(posedge irq_ta0)
        if (my_counter !== 32'h3E) tb_error("====== TIMER_A UP MODE: TIMING 2 - TACCR0 interrupt =====");
      test_step = 9;
    
      @(r15===16'h3000);
      if (mem202 !== 16'h0004) tb_error("====== TIMER_A UP MODE: TAIFG LATENCY ERROR =====");
      if (mem204 !== 16'h0003) tb_error("====== TIMER_A UP MODE: TACCR0 LATENCY ERROR =====");
      test_step = 10;

  
      // TIMER A TEST:  CONTINUOUS MODE
      //--------------------------------------------------------

      @(mem200 === 16'h0001);  // Check timing 1 - TAIFG interrupt
      @(negedge mclk)
      my_counter = 0;
      @(posedge irq_ta1)
        if (my_counter !== 32'h1C) tb_error("====== TIMER_A CONTINUOUS MODE: TIMING 1 - TAIFG interrupt =====");
      test_step = 11;

      
      // TIMER A TEST:  UP-DOWN MODE
      //--------------------------------------------------------

      @(mem200 === 16'h0001);  // Check timing 1 - TAIFG interrupt
      @(posedge irq_ta0)
      @(negedge mclk)
      my_counter = 0;
      @(posedge irq_ta0)
        if (my_counter !== 32'h62) tb_error("====== TIMER_A UP-DOWN MODE: TIMING 1 - TAIFG interrupt =====");
      test_step = 12;

      @(posedge irq_ta1)       // Check timing 1 - TACCR0 interrupt
      @(negedge mclk)
      my_counter = 0;
      @(posedge irq_ta1)
        if (my_counter !== 32'h62) tb_error("====== TIMER_A UP-DOWN MODE: TIMING 1 - TACCR0 interrupt =====");
      test_step = 13;

      @(posedge irq_ta0)       // Check timing 1 - TAIFG->TACCR0 interrupt
      @(negedge mclk)
      my_counter = 0;
      @(posedge irq_ta1)
        if (my_counter !== 32'h31) tb_error("====== TIMER_A UP-DOWN MODE: TIMING 1 - TAIFG->TACCR0 interrupt =====");
      test_step = 14;

      @(mem200===16'h0002);
      if (mem202 !== 16'h0008) tb_error("====== TIMER_A UP-DOWN MODE: TAIFG LATENCY ERROR =====");
      if (mem204 !== 16'h0028) tb_error("====== TIMER_A UP-DOWN MODE: TACCR0 LATENCY ERROR =====");
      test_step = 15;

`endif

      stimulus_done = 1;
   end

