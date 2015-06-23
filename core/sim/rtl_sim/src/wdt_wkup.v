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
/*                            WATCHDOG TIMER                                 */
/*---------------------------------------------------------------------------*/
/* Test the Watdog timer:                                                    */
/*                        - Interval timer mode.                             */
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

integer dco_clk_cnt;
always @(negedge dco_clk)
  dco_clk_cnt <= dco_clk_cnt+1;

integer mclk_cnt;
always @(negedge mclk)
  mclk_cnt <= mclk_cnt+1;

integer smclk_cnt;
always @(negedge smclk)
  smclk_cnt <= smclk_cnt+1;

integer aclk_cnt;
`ifdef ASIC_CLOCKING
always @(negedge aclk)
  aclk_cnt <= aclk_cnt+1;
`else
always @(negedge lfxt_clk)
  aclk_cnt <= aclk_cnt+1;
`endif

integer inst_cnt;
always @(inst_number)
  inst_cnt <= inst_cnt+1;

reg watchdog_clock;
`ifdef ASIC_CLOCKING
  `ifdef WATCHDOG_MUX
       always @(posedge lfxt_clk or negedge lfxt_clk) watchdog_clock <= lfxt_clk;
  `else
    `ifdef WATCHDOG_NOMUX_ACLK
       always @(posedge lfxt_clk or negedge lfxt_clk) watchdog_clock <= lfxt_clk;
    `else
       always @(posedge dco_clk  or negedge dco_clk)  watchdog_clock <= dco_clk;
    `endif
  `endif
`else
       always @(posedge lfxt_clk or negedge lfxt_clk) watchdog_clock <= lfxt_clk;
`endif

integer watchdog_clock_cnt;
always @(posedge watchdog_clock)
  watchdog_clock_cnt <= watchdog_clock_cnt+1;

always @(posedge dut.wdt_irq)
  watchdog_clock_cnt = 1'b0;


integer ii;
integer jj;
   
initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;
      ii = 0;
      jj = 0;
      
`ifdef WATCHDOG

      
      // WATCHDOG TEST:  INTERVAL MODE /64
      //--------------------------------------------------------

      @(r15==16'h1000);

`ifdef ASIC_CLOCKING
  `ifdef WATCHDOG_MUX
    `ifdef ACLK_DIVIDER
      repeat(5) @(posedge watchdog_clock);
    `else
      repeat(4) @(posedge watchdog_clock);
    `endif
  `else
    `ifdef WATCHDOG_NOMUX_ACLK
      `ifdef ACLK_DIVIDER
        repeat(6) @(posedge watchdog_clock);
      `else
        repeat(5) @(posedge watchdog_clock);
      `endif
    `else
      repeat(21) @(posedge watchdog_clock);
    `endif
  `endif
`endif

      for ( ii=0; ii < 9; ii=ii+1)
	begin
	   repeat(1) @(posedge watchdog_clock);
	   jj = 1;
	   dco_clk_cnt = 0;
	   mclk_cnt    = 0;
	   smclk_cnt   = 0;
	   aclk_cnt    = 0;
	   inst_cnt    = 0;
           `ifdef ASIC_CLOCKING
             `ifdef WATCHDOG_MUX
	         repeat(62) @(posedge watchdog_clock);
      	         jj = 2;
      	         if (dco_clk_cnt !==  0)   tb_error("====== DCO_CLK is running                     (CONFIG 1) =====");
	         if (mclk_cnt    !==  0)   tb_error("====== MCLK    is running                     (CONFIG 1) =====");
	         if (smclk_cnt   !==  0)   tb_error("====== SMCLK   is running                     (CONFIG 1) =====");
	         if (aclk_cnt    !== 62)   tb_error("====== ACLK    is not running                 (CONFIG 1) =====");
	         if (inst_cnt    !== 0)    tb_error("====== CPU is executing                       (CONFIG 1) =====");
	         if (r6          !== ii)   tb_error("====== WATCHDOG interrupt was taken too early (CONFIG 1) =====");
	         repeat(1) @(posedge watchdog_clock);
	         jj = 3;
	         if (r6          !== ii+1) tb_error("====== WATCHDOG interrupt was not taken       (CONFIG 1) =====");
             `else
               `ifdef WATCHDOG_NOMUX_ACLK
	         repeat(62) @(posedge watchdog_clock);
	         jj = 2;
      	         if (dco_clk_cnt !== 0)    tb_error("====== DCO_CLK is running                     (CONFIG 2) =====");
	         if (mclk_cnt    !== 0)    tb_error("====== MCLK    is running                     (CONFIG 2) =====");
	         if (smclk_cnt   !== 0)    tb_error("====== SMCLK   is running                     (CONFIG 2) =====");
	         if (aclk_cnt    !== 62)   tb_error("====== ACLK    is not running                 (CONFIG 2) =====");
	         if (inst_cnt    !== 0)    tb_error("====== CPU is executing                       (CONFIG 2) =====");
	         if (r6          !== ii)   tb_error("====== WATCHDOG interrupt was taken too early (CONFIG 2) =====");
    	         repeat(1) @(posedge watchdog_clock);
	         jj = 3;
	         if (r6          !== ii+1) tb_error("====== WATCHDOG interrupt was not taken       (CONFIG 2) =====");
               `else
       	         repeat(39) @(posedge watchdog_clock);
	         jj = 2;
      	         if (dco_clk_cnt !== 39)   tb_error("====== DCO_CLK is not running                 (CONFIG 3) =====");
	         if (mclk_cnt    !== 0)    tb_error("====== MCLK    is running                     (CONFIG 3) =====");
	         if (smclk_cnt   !== 39)   tb_error("====== SMCLK   is not running                 (CONFIG 3) =====");
	         if (aclk_cnt    === 0)    tb_error("====== ACLK    is not running                 (CONFIG 3) =====");
	         if (inst_cnt    !== 0)    tb_error("====== CPU is executing                       (CONFIG 3) =====");
	         if (r6          !== ii)   tb_error("====== WATCHDOG interrupt was taken too early (CONFIG 3) =====");
                 repeat(24) @(posedge watchdog_clock);
 	         jj = 3;
	         if (r6          !== ii+1) tb_error("====== WATCHDOG interrupt was not taken       (CONFIG 3) =====");
               `endif
             `endif
           `else
	         repeat(62) @(posedge watchdog_clock);
	         jj = 2;
      	         if (dco_clk_cnt  <  1800) tb_error("====== DCO_CLK is not running                 (CONFIG 4) =====");
	         if (mclk_cnt     <  1800) tb_error("====== MCLK    is not running                 (CONFIG 4) =====");
	         if (smclk_cnt    <  1800) tb_error("====== SMCLK   is not running                 (CONFIG 4) =====");
	         if (aclk_cnt    !== 62)   tb_error("====== ACLK    is not running                 (CONFIG 4) =====");
	         if (inst_cnt    !== 0)    tb_error("====== CPU is executing                       (CONFIG 4) =====");
	         if (r6          !== ii)   tb_error("====== WATCHDOG interrupt was taken too early (CONFIG 4) =====");
	         repeat(1) @(posedge watchdog_clock);
	         jj = 3;
	         if (r6          !== ii+1) tb_error("====== WATCHDOG interrupt was not taken       (CONFIG 4) =====");
           `endif
	end

      // WATCHDOG TEST:  RESET MODE /64
      //--------------------------------------------------------

      @(r15==16'h5000);
      if (r7 !== 16'h0000) tb_error("====== WATCHDOG reset was not taken =====");


`else
      $display(" ===============================================");
      $display("|               SIMULATION SKIPPED              |");
      $display("|         (the Watchdog is not included)        |");
      $display(" ===============================================");
      $finish;
`endif

      stimulus_done = 1;
   end

