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
/*                        - Clock source selection.                          */
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
always @ (posedge mclk)
  mclk_counter <=  mclk_counter+1;

integer r5_counter;
always @ (posedge r5[0] or negedge r5[0])
  r5_counter <=  r5_counter+1;

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

`ifdef WATCHDOG

      // WATCHDOG TEST INTERVAL MODE /64 - SMCLK == MCLK/2
      //--------------------------------------------------------

      @(r15 === 16'h0001);
      @(posedge r5[0]);
      @(negedge mclk);
      mclk_counter = 0;
      r5_counter   = 0;
      repeat(1024) @(negedge mclk);
      if (mclk_counter !== 1024)        tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - SMCLK - TEST 1 =====");
   `ifdef ASIC_CLOCKING
     `ifdef WATCHDOG_MUX
        `ifdef SMCLK_DIVIDER
            if (r5_counter   !== 7)     tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - SMCLK - TEST 2 =====");
        `else
            if (r5_counter   !== 14)    tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - SMCLK - TEST 3 =====");
        `endif
     `else
        `ifdef WATCHDOG_NOMUX_ACLK
           `ifdef LFXT_DOMAIN
               if (r5_counter   !== 0)  tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - SMCLK - TEST 4 =====");
           `else
               if (r5_counter   !== 14) tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - SMCLK - TEST 5 =====");
           `endif
        `else
           `ifdef SMCLK_DIVIDER
               if (r5_counter   !== 7)  tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - SMCLK - TEST 6 =====");
           `else
               if (r5_counter   !== 14) tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - SMCLK - TEST 7 =====");
           `endif
        `endif
     `endif
   `else
      if (r5_counter   !== 8)           tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - SMCLK - TEST 8 =====");
   `endif

   
      // WATCHDOG TEST INTERVAL MODE /64 - ACLK == LFXTCLK/1
      //--------------------------------------------------------

      @(r15 === 16'h1001);
      @(negedge r5[0]);
      @(negedge mclk);
      mclk_counter = 0;
      r5_counter   = 0;
      repeat(7815) @(negedge mclk);
      if (mclk_counter !== 7815)         tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - ACLK - TEST 1 =====");
   `ifdef ASIC_CLOCKING
     `ifdef WATCHDOG_MUX
            if (r5_counter      !== 4)   tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - ACLK - TEST 2 =====");
     `else
        `ifdef WATCHDOG_NOMUX_ACLK
           `ifdef LFXT_DOMAIN
               if (r5_counter   !== 4)   tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - ACLK - TEST 3 =====");
           `else
               if (r5_counter   !== 122) tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - ACLK - TEST 4 =====");
           `endif
        `else
             if (r5_counter     !== 122) tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - ACLK - TEST 5 =====");
        `endif
     `endif
   `else
      if (r5_counter   !== 4)            tb_error("====== WATCHDOG TEST INTERVAL MODE /64 - ACLK - TEST 6 =====");
   `endif

`else
      $display(" ===============================================");
      $display("|               SIMULATION SKIPPED              |");
      $display("|         (the Watchdog is not included)        |");
      $display(" ===============================================");
      $finish;
`endif

      stimulus_done = 1;
   end

