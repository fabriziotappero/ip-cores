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
/*                        - Check the timer capture unit.                    */
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

wire [15:0] tar = timerA_0.tar;
   
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

      // TIMER A TEST:  INPUT MUX (CCI)
      //--------------------------------------------------------

	                        // --------- Comparator 0 ----------
      @(mem200 === 16'h0001);
      ta_cci0a = 1'b1;
      ta_cci0b = 1'b0;
      ta_cci1a = 1'b0;
      ta_cci1b = 1'b0;
      ta_cci2a = 1'b0;
      ta_cci2b = 1'b0;
      @(mem200 === 16'h0002);     
      ta_cci0a = 1'b0;
      ta_cci0b = 1'b1;
      ta_cci1a = 1'b1;
      ta_cci1b = 1'b1;
      ta_cci2a = 1'b1;
      ta_cci2b = 1'b1;
      @(mem200 === 16'h0003);     
      if (mem202 !== 16'h0008) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 0 - CCIxA =====");
      if (mem204 !== 16'h0000) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 0 - CCIxA =====");

      @(mem200 === 16'h0004);
      ta_cci0a = 1'b0;
      ta_cci0b = 1'b1;
      ta_cci1a = 1'b0;
      ta_cci1b = 1'b0;
      ta_cci2a = 1'b0;
      ta_cci2b = 1'b0;
      @(mem200 === 16'h0005);     
      ta_cci0a = 1'b1;
      ta_cci0b = 1'b0;
      ta_cci1a = 1'b1;
      ta_cci1b = 1'b1;
      ta_cci2a = 1'b1;
      ta_cci2b = 1'b1;
      @(mem200 === 16'h0006);     
      if (mem202 !== 16'h1008) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 0 - CCIxB =====");
      if (mem204 !== 16'h1000) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 0 - CCIxB =====");

      @(mem200 === 16'h0007);
      ta_cci0a = 1'b0;
      ta_cci0b = 1'b0;
      ta_cci1a = 1'b0;
      ta_cci1b = 1'b0;
      ta_cci2a = 1'b0;
      ta_cci2b = 1'b0;
      @(mem200 === 16'h0008);     
      ta_cci0a = 1'b1;
      ta_cci0b = 1'b1;
      ta_cci1a = 1'b1;
      ta_cci1b = 1'b1;
      ta_cci2a = 1'b1;
      ta_cci2b = 1'b1;
      @(mem200 === 16'h0009);     
      if (mem202 !== 16'h2000) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 0 - GND =====");
      if (mem204 !== 16'h2000) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 0 - GND =====");

      @(mem200 === 16'h000A);
      ta_cci0a = 1'b0;
      ta_cci0b = 1'b0;
      ta_cci1a = 1'b0;
      ta_cci1b = 1'b0;
      ta_cci2a = 1'b0;
      ta_cci2b = 1'b0;
      @(mem200 === 16'h000B);     
      ta_cci0a = 1'b1;
      ta_cci0b = 1'b1;
      ta_cci1a = 1'b1;
      ta_cci1b = 1'b1;
      ta_cci2a = 1'b1;
      ta_cci2b = 1'b1;
      @(mem200 === 16'h000C);     
      if (mem202 !== 16'h3008) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 0 - VDD =====");
      if (mem204 !== 16'h3008) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 0 - VDD =====");

      
	                        // --------- Comparator 1 ----------
      @(mem200 === 16'h0011);
      ta_cci0a = 1'b0;
      ta_cci0b = 1'b0;
      ta_cci1a = 1'b1;
      ta_cci1b = 1'b0;
      ta_cci2a = 1'b0;
      ta_cci2b = 1'b0;
      @(mem200 === 16'h0012);     
      ta_cci0a = 1'b1;
      ta_cci0b = 1'b1;
      ta_cci1a = 1'b0;
      ta_cci1b = 1'b1;
      ta_cci2a = 1'b1;
      ta_cci2b = 1'b1;
      @(mem200 === 16'h0013);     
      if (mem202 !== 16'h0008) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 1 - CCIxA =====");
      if (mem204 !== 16'h0000) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 1 - CCIxA =====");

      @(mem200 === 16'h0014);
      ta_cci0a = 1'b0;
      ta_cci0b = 1'b0;
      ta_cci1a = 1'b0;
      ta_cci1b = 1'b1;
      ta_cci2a = 1'b0;
      ta_cci2b = 1'b0;
      @(mem200 === 16'h0015);     
      ta_cci0a = 1'b1;
      ta_cci0b = 1'b1;
      ta_cci1a = 1'b1;
      ta_cci1b = 1'b0;
      ta_cci2a = 1'b1;
      ta_cci2b = 1'b1;
      @(mem200 === 16'h0016);     
      if (mem202 !== 16'h1008) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 1 - CCIxB =====");
      if (mem204 !== 16'h1000) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 1 - CCIxB =====");

      @(mem200 === 16'h0017);
      ta_cci0a = 1'b0;
      ta_cci0b = 1'b0;
      ta_cci1a = 1'b0;
      ta_cci1b = 1'b0;
      ta_cci2a = 1'b0;
      ta_cci2b = 1'b0;
      @(mem200 === 16'h0018);     
      ta_cci0a = 1'b1;
      ta_cci0b = 1'b1;
      ta_cci1a = 1'b1;
      ta_cci1b = 1'b1;
      ta_cci2a = 1'b1;
      ta_cci2b = 1'b1;
      @(mem200 === 16'h0019);     
      if (mem202 !== 16'h2000) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 1 - GND =====");
      if (mem204 !== 16'h2000) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 1 - GND =====");

      @(mem200 === 16'h001A);
      ta_cci0a = 1'b0;
      ta_cci0b = 1'b0;
      ta_cci1a = 1'b0;
      ta_cci1b = 1'b0;
      ta_cci2a = 1'b0;
      ta_cci2b = 1'b0;
      @(mem200 === 16'h001B);     
      ta_cci0a = 1'b1;
      ta_cci0b = 1'b1;
      ta_cci1a = 1'b1;
      ta_cci1b = 1'b1;
      ta_cci2a = 1'b1;
      ta_cci2b = 1'b1;
      @(mem200 === 16'h001C);     
      if (mem202 !== 16'h3008) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 1 - VDD =====");
      if (mem204 !== 16'h3008) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 1 - VDD =====");

      
	                        // --------- Comparator 2 ----------
      @(mem200 === 16'h0021);
      ta_cci0a = 1'b0;
      ta_cci0b = 1'b0;
      ta_cci1a = 1'b0;
      ta_cci1b = 1'b0;
      ta_cci2a = 1'b1;
      ta_cci2b = 1'b0;
      @(mem200 === 16'h0022);     
      ta_cci0a = 1'b1;
      ta_cci0b = 1'b1;
      ta_cci1a = 1'b1;
      ta_cci1b = 1'b1;
      ta_cci2a = 1'b0;
      ta_cci2b = 1'b1;
      @(mem200 === 16'h0023);     
      if (mem202 !== 16'h0008) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 2 - CCIxA =====");
      if (mem204 !== 16'h0000) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 2 - CCIxA =====");

      @(mem200 === 16'h0024);
      ta_cci0a = 1'b0;
      ta_cci0b = 1'b0;
      ta_cci1a = 1'b0;
      ta_cci1b = 1'b0;
      ta_cci2a = 1'b0;
      ta_cci2b = 1'b1;
      @(mem200 === 16'h0025);     
      ta_cci0a = 1'b1;
      ta_cci0b = 1'b1;
      ta_cci1a = 1'b1;
      ta_cci1b = 1'b1;
      ta_cci2a = 1'b1;
      ta_cci2b = 1'b0;
      @(mem200 === 16'h0026);     
      if (mem202 !== 16'h1008) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 2 - CCIxB =====");
      if (mem204 !== 16'h1000) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 2 - CCIxB =====");

      @(mem200 === 16'h0027);
      ta_cci0a = 1'b0;
      ta_cci0b = 1'b0;
      ta_cci1a = 1'b0;
      ta_cci1b = 1'b0;
      ta_cci2a = 1'b0;
      ta_cci2b = 1'b0;
      @(mem200 === 16'h0028);     
      ta_cci0a = 1'b1;
      ta_cci0b = 1'b1;
      ta_cci1a = 1'b1;
      ta_cci1b = 1'b1;
      ta_cci2a = 1'b1;
      ta_cci2b = 1'b1;
      @(mem200 === 16'h0029);     
      if (mem202 !== 16'h2000) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 2 - GND =====");
      if (mem204 !== 16'h2000) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 2 - GND =====");

      @(mem200 === 16'h002A);
      ta_cci0a = 1'b0;
      ta_cci0b = 1'b0;
      ta_cci1a = 1'b0;
      ta_cci1b = 1'b0;
      ta_cci2a = 1'b0;
      ta_cci2b = 1'b0;
      @(mem200 === 16'h002B);     
      ta_cci0a = 1'b1;
      ta_cci0b = 1'b1;
      ta_cci1a = 1'b1;
      ta_cci1b = 1'b1;
      ta_cci2a = 1'b1;
      ta_cci2b = 1'b1;
      @(mem200 === 16'h002C);     
      if (mem202 !== 16'h3008) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 2 - VDD =====");
      if (mem204 !== 16'h3008) tb_error("====== TIMER_A INPUT MUX: COMPARATOR 2 - VDD =====");
      ta_cci0a = 1'b0;
      ta_cci0b = 1'b0;
      ta_cci1a = 1'b0;
      ta_cci1b = 1'b0;
      ta_cci2a = 1'b0;
      ta_cci2b = 1'b0;

       
      // TIMER A TEST:  CAPTURE, EDGE SELECTION AND INTERRUPT
      //--------------------------------------------------------
      @(r15 === 16'h1000);

	                        // --------- Comparator 0 ----------
      @(mem200 === 16'h0001);
      ta_cci0a = 1'b1;
      repeat(5) @(posedge mclk);
      if (irq_ta0) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 0: NO CAPTURE 1 =====");
      @(mem200 === 16'h0002);
      ta_cci0a = 1'b0;
      repeat(5) @(posedge mclk);
      if (irq_ta0) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 0: NO CAPTURE 2 =====");
      @(mem200 === 16'h0003);
      if (mem202 !== 16'h0000) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 0: NO CAPTURE 3 =====");
      if (mem204 !== 16'h0000) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 0: NO CAPTURE 4 =====");

      @(mem200 === 16'h0004);
      ta_cci0a = 1'b1;
      repeat(5) @(posedge mclk);
      if (!irq_ta0) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 0: RISING EDGE 1 =====");
      @(mem200 === 16'h0005);
      ta_cci0a = 1'b0;
      repeat(5) @(posedge mclk);
      if (irq_ta0) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 0: RISING EDGE 2 =====");
      @(mem200 === 16'h0006);
      if (mem202 !== 16'h1234) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 0: RISING EDGE 3 =====");
      if (mem204 !== 16'h0000) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 0: RISING EDGE 4 =====");

      @(mem200 === 16'h0007);
      ta_cci0a = 1'b1;
      repeat(5) @(posedge mclk);
      if (irq_ta0) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 0: FALLING EDGE 1 =====");
      @(mem200 === 16'h0008);
      ta_cci0a = 1'b0;
      repeat(5) @(posedge mclk);
      if (!irq_ta0) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 0: FALLING EDGE 2 =====");
      @(mem200 === 16'h0009);
      if (mem202 !== 16'h0000) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 0: FALLING EDGE 3 =====");
      if (mem204 !== 16'h1234) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 0: FALLING EDGE 4 =====");

      @(mem200 === 16'h000A);
      ta_cci0a = 1'b1;
      repeat(5) @(posedge mclk);
      if (!irq_ta0) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 0: RISING/FALLING EDGE 1 =====");
      @(mem200 === 16'h000B);
      ta_cci0a = 1'b0;
      repeat(5) @(posedge mclk);
      if (!irq_ta0) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 0: RISING/FALLING EDGE 2 =====");
      @(mem200 === 16'h000C);
      if (mem202 !== 16'h1234) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 0: RISING/FALLING EDGE 3 =====");
      if (mem204 !== 16'h1234) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 0: RISING/FALLING EDGE 4 =====");

      
	                        // --------- comparator 1 ----------
      @(mem200 === 16'h0001);
      ta_cci1a = 1'b1;
      repeat(5) @(posedge mclk);
      if (irq_ta1) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 1: NO CAPTURE 1 =====");
      @(mem200 === 16'h0002);
      ta_cci1a = 1'b0;
      repeat(5) @(posedge mclk);
      if (irq_ta1) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 1: NO CAPTURE 2 =====");
      @(mem200 === 16'h0003);
      if (mem202 !== 16'h0000) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 1: NO CAPTURE 3 =====");
      if (mem204 !== 16'h0000) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 1: NO CAPTURE 4 =====");

      @(mem200 === 16'h0004);
      ta_cci1a = 1'b1;
      repeat(5) @(posedge mclk);
      if (!irq_ta1) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 1: RISING EDGE 1 =====");
      @(mem200 === 16'h0005);
      ta_cci1a = 1'b0;
      repeat(5) @(posedge mclk);
      if (irq_ta1) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 1: RISING EDGE 2 =====");
      @(mem200 === 16'h0006);
      if (mem202 !== 16'h1234) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 1: RISING EDGE 3 =====");
      if (mem204 !== 16'h0000) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 1: RISING EDGE 4 =====");

      @(mem200 === 16'h0007);
      ta_cci1a = 1'b1;
      repeat(5) @(posedge mclk);
      if (irq_ta1) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 1: FALLING EDGE 1 =====");
      @(mem200 === 16'h0008);
      ta_cci1a = 1'b0;
      repeat(5) @(posedge mclk);
      if (!irq_ta1) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 1: FALLING EDGE 2 =====");
      @(mem200 === 16'h0009);
      if (mem202 !== 16'h0000) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 1: FALLING EDGE 3 =====");
      if (mem204 !== 16'h1234) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 1: FALLING EDGE 4 =====");

      @(mem200 === 16'h000A);
      ta_cci1a = 1'b1;
      repeat(5) @(posedge mclk);
      if (!irq_ta1) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 1: RISING/FALLING EDGE 1 =====");
      @(mem200 === 16'h000B);
      ta_cci1a = 1'b0;
      repeat(5) @(posedge mclk);
      if (!irq_ta1) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 1: RISING/FALLING EDGE 2 =====");
      @(mem200 === 16'h000C);
      if (mem202 !== 16'h1234) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 1: RISING/FALLING EDGE 3 =====");
      if (mem204 !== 16'h1234) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 1: RISING/FALLING EDGE 4 =====");

      
	                        // --------- comparator 2 ----------
      @(mem200 === 16'h0001);
      ta_cci2a = 1'b1;
      repeat(5) @(posedge mclk);
      if (irq_ta1) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 2: NO CAPTURE 1 =====");
      @(mem200 === 16'h0002);
      ta_cci2a = 1'b0;
      repeat(5) @(posedge mclk);
      if (irq_ta1) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 2: NO CAPTURE 2 =====");
      @(mem200 === 16'h0003);
      if (mem202 !== 16'h0000) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 2: NO CAPTURE 3 =====");
      if (mem204 !== 16'h0000) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 2: NO CAPTURE 4 =====");

      @(mem200 === 16'h0004);
      ta_cci2a = 1'b1;
      repeat(5) @(posedge mclk);
      if (!irq_ta1) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 2: RISING EDGE 1 =====");
      @(mem200 === 16'h0005);
      ta_cci2a = 1'b0;
      repeat(5) @(posedge mclk);
      if (irq_ta1) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 2: RISING EDGE 2 =====");
      @(mem200 === 16'h0006);
      if (mem202 !== 16'h1234) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 2: RISING EDGE 3 =====");
      if (mem204 !== 16'h0000) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 2: RISING EDGE 4 =====");

      @(mem200 === 16'h0007);
      ta_cci2a = 1'b1;
      repeat(5) @(posedge mclk);
      if (irq_ta1) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 2: FALLING EDGE 1 =====");
      @(mem200 === 16'h0008);
      ta_cci2a = 1'b0;
      repeat(5) @(posedge mclk);
      if (!irq_ta1) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 2: FALLING EDGE 2 =====");
      @(mem200 === 16'h0009);
      if (mem202 !== 16'h0000) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 2: FALLING EDGE 3 =====");
      if (mem204 !== 16'h1234) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 2: FALLING EDGE 4 =====");

      @(mem200 === 16'h000A);
      ta_cci2a = 1'b1;
      repeat(5) @(posedge mclk);
      if (!irq_ta1) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 2: RISING/FALLING EDGE 1 =====");
      @(mem200 === 16'h000B);
      ta_cci2a = 1'b0;
      repeat(5) @(posedge mclk);
      if (!irq_ta1) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 2: RISING/FALLING EDGE 2 =====");
      @(mem200 === 16'h000C);
      if (mem202 !== 16'h1234) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 2: RISING/FALLING EDGE 3 =====");
      if (mem204 !== 16'h1234) tb_error("====== TIMER_A CAPTURE, EDGE SELECTION AND INTERRUPT COMPARATOR 2: RISING/FALLING EDGE 4 =====");

      
      // TIMER A TEST:  CAPTURE OVERFLOW
      //--------------------------------------------------------
      @(r15 === 16'h2000);

	                        // --------- Comparator 0 ----------
      @(mem200 === 16'h0001);
      ta_cci0a = 1'b1;
      @(mem200 === 16'h0002);
      ta_cci0a = 1'b0;
      @(mem200 === 16'h0003);
      if (mem202 !== 16'hC008) tb_error("====== TIMER_A CAPTURE OVERFLOW: COMPARATOR 0 =====");
      if (mem204 !== 16'hC002) tb_error("====== TIMER_A CAPTURE OVERFLOW: COMPARATOR 0 =====");

      @(mem200 === 16'h0004);
      ta_cci0a = 1'b1;
      @(mem200 === 16'h0005);
      ta_cci0a = 1'b0;
      @(mem200 === 16'h0006);
      if (mem202 !== 16'hC008) tb_error("====== TIMER_A CAPTURE OVERFLOW: COMPARATOR 0 =====");
      if (mem204 !== 16'hC000) tb_error("====== TIMER_A CAPTURE OVERFLOW: COMPARATOR 0 =====");

      
	                        // --------- Comparator 1 ----------
      @(mem200 === 16'h0001);
      ta_cci1a = 1'b1;
      @(mem200 === 16'h0002);
      ta_cci1a = 1'b0;
      @(mem200 === 16'h0003);
      if (mem202 !== 16'hC008) tb_error("====== TIMER_A CAPTURE OVERFLOW: COMPARATOR 1 =====");
      if (mem204 !== 16'hC002) tb_error("====== TIMER_A CAPTURE OVERFLOW: COMPARATOR 1 =====");

      @(mem200 === 16'h0004);
      ta_cci1a = 1'b1;
      @(mem200 === 16'h0005);
      ta_cci1a = 1'b0;
      @(mem200 === 16'h0006);
      if (mem202 !== 16'hC008) tb_error("====== TIMER_A CAPTURE OVERFLOW: COMPARATOR 1 =====");
      if (mem204 !== 16'hC000) tb_error("====== TIMER_A CAPTURE OVERFLOW: COMPARATOR 1 =====");

      
	                        // --------- Comparator 2 ----------
      @(mem200 === 16'h0001);
      ta_cci2a = 1'b1;
      @(mem200 === 16'h0002);
      ta_cci2a = 1'b0;
      @(mem200 === 16'h0003);
      if (mem202 !== 16'hC008) tb_error("====== TIMER_A CAPTURE OVERFLOW: COMPARATOR 2 =====");
      if (mem204 !== 16'hC002) tb_error("====== TIMER_A CAPTURE OVERFLOW: COMPARATOR 2 =====");

      @(mem200 === 16'h0004);
      ta_cci2a = 1'b1;
      @(mem200 === 16'h0005);
      ta_cci2a = 1'b0;
      @(mem200 === 16'h0006);
      if (mem202 !== 16'hC008) tb_error("====== TIMER_A CAPTURE OVERFLOW: COMPARATOR 2 =====");
      if (mem204 !== 16'hC000) tb_error("====== TIMER_A CAPTURE OVERFLOW: COMPARATOR 2 =====");


`endif     

      stimulus_done = 1;
   end

