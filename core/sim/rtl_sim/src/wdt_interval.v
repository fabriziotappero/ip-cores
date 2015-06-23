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
/* $Rev: 180 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2013-02-25 22:23:18 +0100 (Mon, 25 Feb 2013) $          */
/*===========================================================================*/
    
`define LONG_TIMEOUT

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

`ifdef WATCHDOG

      // WATCHDOG TEST:  RD/WR ACCESS
      //--------------------------------------------------------

      @(r15==16'h1000);
`ifdef NMI
  `ifdef WATCHDOG_MUX
      if (r4 !== 16'h6920) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6920 (CONFIG 1) =====");
      if (r5 !== 16'h69f7) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69f7 (CONFIG 1) =====");
      if (r6 !== 16'h6975) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6975 (CONFIG 1) =====");
      if (r7 !== 16'h69a2) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69a2 (CONFIG 1) =====");
      if (r8 !== 16'h6920) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6920 (CONFIG 1) =====");
  `else
    `ifdef WATCHDOG_NOMUX_ACLK
      if (r4 !== 16'h6924) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6924 (CONFIG 2) =====");
      if (r5 !== 16'h69f7) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69f7 (CONFIG 2) =====");
      if (r6 !== 16'h6975) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6975 (CONFIG 2) =====");
      if (r7 !== 16'h69a6) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69a6 (CONFIG 2) =====");
      if (r8 !== 16'h6924) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6924 (CONFIG 2) =====");
    `else
      if (r4 !== 16'h6920) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6920 (CONFIG 3) =====");
      `ifdef ASIC_CLOCKING
      if (r5 !== 16'h69f3) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69f3 (CONFIG 3-ASIC) =====");
      if (r6 !== 16'h6971) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6971 (CONFIG 3-ASIC) =====");
      if (r7 !== 16'h69a2) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69a2 (CONFIG 3-ASIC) =====");
      `else
      if (r5 !== 16'h69f7) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69f7 (CONFIG 3) =====");
      if (r6 !== 16'h6975) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6975 (CONFIG 3) =====");
      if (r7 !== 16'h69a2) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69a2 (CONFIG 3) =====");
      `endif
      if (r8 !== 16'h6920) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6920 (CONFIG 3) =====");
    `endif
  `endif
`else
  `ifdef WATCHDOG_MUX
      if (r4 !== 16'h6900) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6900 (CONFIG 4) =====");
      if (r5 !== 16'h6997) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6997 (CONFIG 4) =====");
      if (r6 !== 16'h6915) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6915 (CONFIG 4) =====");
      if (r7 !== 16'h6982) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6982 (CONFIG 4) =====");
      if (r8 !== 16'h6900) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6900 (CONFIG 4) =====");
  `else
    `ifdef WATCHDOG_NOMUX_ACLK
      if (r4 !== 16'h6904) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6904 (CONFIG 5) =====");
      if (r5 !== 16'h6997) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6997 (CONFIG 5) =====");
      if (r6 !== 16'h6915) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6915 (CONFIG 5) =====");
      if (r7 !== 16'h6986) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6986 (CONFIG 5) =====");
      if (r8 !== 16'h6904) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6904 (CONFIG 5) =====");
    `else
      if (r4 !== 16'h6900) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6900 (CONFIG 6) =====");
      `ifdef ASIC_CLOCKING
      if (r5 !== 16'h6993) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6993 (CONFIG 6-ASIC) =====");
      if (r6 !== 16'h6911) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6911 (CONFIG 6-ASIC) =====");
      if (r7 !== 16'h6982) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6982 (CONFIG 6-ASIC) =====");
      `else
      if (r5 !== 16'h6997) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6997 (CONFIG 6) =====");
      if (r6 !== 16'h6915) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6915 (CONFIG 6) =====");
      if (r7 !== 16'h6982) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6982 (CONFIG 6) =====");
      `endif
      if (r8 !== 16'h6900) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6900 (CONFIG 6) =====");
    `endif
  `endif
`endif
`ifdef NMI
      if (r9 !== 16'h0010) tb_error("====== WATCHDOG RD/WR ACCESS: IFG1   != 0x10 =====");
`else
      if (r9 !== 16'h0000) tb_error("====== WATCHDOG RD/WR ACCESS: IFG1   != 0x00 =====");
`endif

      
      // WATCHDOG TEST:  INTERVAL MODE /64
      //--------------------------------------------------------

      @(r15==16'h2000);
      if (r5 !== 16'h3401) tb_error("====== WATCHDOG INTERVAL MODE /64: R5 != 0x3401 =====");
      if (r6 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /64: R6 != 0x0000 =====");
`ifdef ASIC_CLOCKING
  `ifdef WATCHDOG_MUX
      if (r7 !== 16'h000E) tb_error("====== WATCHDOG INTERVAL MODE /64: R7 != 0x000E (CONFIG 1) =====");
  `else
    `ifdef WATCHDOG_NOMUX_ACLK
      `ifdef ACLK_DIVIDER
      if (r7 !== 16'h019F) tb_error("====== WATCHDOG INTERVAL MODE /64: R7 != 0x019F (CONFIG 1) =====");
      `else
      if (r7 !== 16'h0199) tb_error("====== WATCHDOG INTERVAL MODE /64: R7 != 0x0199 (CONFIG 1) =====");
      `endif
    `else
      if (r7 !== 16'h000E) tb_error("====== WATCHDOG INTERVAL MODE /64: R7 != 0x000E (CONFIG 1) =====");
    `endif
  `endif
`else
      if (r7 !== 16'h000D) tb_error("====== WATCHDOG INTERVAL MODE /64: R7 != 0x000D (CONFIG 1) =====");
`endif
    
      @(r15==16'h2001);
      if (r5 !== 16'h0002) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ: R5 != 0x0002 =====");
      if (r6 !== 16'h0001) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ: R6 != 0x0001 =====");
      if (r7 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ: R7 != 0x0000 =====");
      if (r8 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ: R8 != 0x0000 =====");
      
`ifdef ASIC_CLOCKING
  `ifdef WATCHDOG_MUX
  `else
    `ifdef WATCHDOG_NOMUX_ACLK
      // From there, force the watchdog clock to DCO_CLK to speedup simulation
      force lfxt_clk = dco_clk; 
    `endif
  `endif
`endif

      @(r15==16'h2002);
      if (r5 !== 16'h0022) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ HOLD: R5 != 0x0022 =====");
      if (r6 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ HOLD: R6 != 0x0000 =====");
      if (r7 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ HOLD: R7 != 0x0000 =====");

      @(r15==16'h2003);
      if (r4 !== 16'h0033) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ CNT CLEAR: R4 != 0x0033 =====");
      if (r6 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ CNT CLEAR: R6 != 0x0000 =====");
      if (r7 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ CNT CLEAR: R7 != 0x0000 =====");
      if (r8 !== 16'h0001) tb_error("====== WATCHDOG INTERVAL MODE /64 NO IRQ CNT CLEAR: R8 != 0x0001 =====");

      $display("Interval mode /64 mode test completed...");
      
      
      // WATCHDOG TEST:  INTERVAL MODE /512
      //--------------------------------------------------------

      @(r15==16'h3000);
      if (r5 !== 16'h3403) tb_error("====== WATCHDOG INTERVAL MODE /512: R5 != 0x3403 =====");
      if (r6 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /512: R6 != 0x0000 =====");
`ifdef ASIC_CLOCKING
      if (r7 !== 16'h0068) tb_error("====== WATCHDOG INTERVAL MODE /512: R7 != 0x0068 =====");
`else
      if (r7 !== 16'h0066) tb_error("====== WATCHDOG INTERVAL MODE /512: R7 != 0x0066 =====");
`endif

      $display("Interval mode /512 mode test completed...");

      
      // WATCHDOG TEST:  INTERVAL MODE /8192
      //--------------------------------------------------------

      @(r15==16'h4000);
      if (r5 !== 16'h3404) tb_error("====== WATCHDOG INTERVAL MODE /8192: R5 != 0x3404 =====");
      if (r6 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /8192: R6 != 0x0000 =====");
`ifdef ASIC_CLOCKING
      if (r7 !== 16'h0668) tb_error("====== WATCHDOG INTERVAL MODE /8192: R7 != 0x0668 =====");
`else
      if (r7 !== 16'h0667) tb_error("====== WATCHDOG INTERVAL MODE /8192: R7 != 0x0667 =====");
`endif

      $display("Interval mode /8192 mode test completed...");

      
      // WATCHDOG TEST:  INTERVAL MODE /32768
      //--------------------------------------------------------

      @(r15==16'h5000);
      if (r5 !== 16'h3405) tb_error("====== WATCHDOG INTERVAL MODE /32768: R5 != 0x3405 =====");
      if (r6 !== 16'h0000) tb_error("====== WATCHDOG INTERVAL MODE /32768: R6 != 0x0000 =====");
`ifdef ASIC_CLOCKING
      if (r7 !== 16'h199B) tb_error("====== WATCHDOG INTERVAL MODE /32768: R7 != 0x199B =====");
`else
      if (r7 !== 16'h199A) tb_error("====== WATCHDOG INTERVAL MODE /32768: R7 != 0x199A =====");
`endif

      $display("Interval mode /32768 mode test completed...");

`else
      $display(" ===============================================");
      $display("|               SIMULATION SKIPPED              |");
      $display("|         (the Watchdog is not included)        |");
      $display(" ===============================================");
      $finish;
`endif

      stimulus_done = 1;
   end

