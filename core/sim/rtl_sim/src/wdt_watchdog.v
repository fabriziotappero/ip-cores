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
/*                        - Watchdog mode.                                   */
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

      @(mem250===16'h1000);
`ifdef NMI
  `ifdef WATCHDOG_MUX
      if (mem200 !== 16'h6920) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6920 (CONFIG 1) =====");
      if (mem202 !== 16'h69f7) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69f7 (CONFIG 1) =====");
      if (mem204 !== 16'h6975) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6975 (CONFIG 1) =====");
      if (mem206 !== 16'h69a2) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69a2 (CONFIG 1) =====");
      if (mem208 !== 16'h6920) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6920 (CONFIG 1) =====");
  `else
    `ifdef WATCHDOG_NOMUX_ACLK
      if (mem200 !== 16'h6924) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6924 (CONFIG 2) =====");
      if (mem202 !== 16'h69f7) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69f7 (CONFIG 2) =====");
      if (mem204 !== 16'h6975) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6975 (CONFIG 2) =====");
      if (mem206 !== 16'h69a6) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69a6 (CONFIG 2) =====");
      if (mem208 !== 16'h6924) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6924 (CONFIG 2) =====");
    `else
      if (mem200 !== 16'h6920) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6920 (CONFIG 3) =====");
      `ifdef ASIC_CLOCKING
      if (mem202 !== 16'h69f3) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69f3 (CONFIG 3-ASIC) =====");
      if (mem204 !== 16'h6971) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6971 (CONFIG 3-ASIC) =====");
      if (mem206 !== 16'h69a2) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69a2 (CONFIG 3-ASIC) =====");
      `else
      if (mem202 !== 16'h69f7) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69f7 (CONFIG 3) =====");
      if (mem204 !== 16'h6975) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6975 (CONFIG 3) =====");
      if (mem206 !== 16'h69a2) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x69a2 (CONFIG 3) =====");
      `endif
      if (mem208 !== 16'h6920) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6920 (CONFIG 3) =====");
    `endif
  `endif
`else
  `ifdef WATCHDOG_MUX
      if (mem200 !== 16'h6900) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6900 (CONFIG 4) =====");
      if (mem202 !== 16'h6997) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6997 (CONFIG 4) =====");
      if (mem204 !== 16'h6915) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6915 (CONFIG 4) =====");
      if (mem206 !== 16'h6982) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6982 (CONFIG 4) =====");
      if (mem208 !== 16'h6900) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6900 (CONFIG 4) =====");
  `else
    `ifdef WATCHDOG_NOMUX_ACLK
      if (mem200 !== 16'h6904) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6904 (CONFIG 5) =====");
      if (mem202 !== 16'h6997) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6997 (CONFIG 5) =====");
      if (mem204 !== 16'h6915) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6915 (CONFIG 5) =====");
      if (mem206 !== 16'h6986) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6986 (CONFIG 5) =====");
      if (mem208 !== 16'h6904) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6904 (CONFIG 5) =====");
    `else
      if (mem200 !== 16'h6900) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6900 (CONFIG 6) =====");
      `ifdef ASIC_CLOCKING
      if (mem202 !== 16'h6993) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6993 (CONFIG 6-ASIC) =====");
      if (mem204 !== 16'h6911) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6911 (CONFIG 6-ASIC) =====");
      if (mem206 !== 16'h6982) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6982 (CONFIG 6-ASIC) =====");
      `else
      if (mem202 !== 16'h6997) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6997 (CONFIG 6) =====");
      if (mem204 !== 16'h6915) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6915 (CONFIG 6) =====");
      if (mem206 !== 16'h6982) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6982 (CONFIG 6) =====");
      `endif
      if (mem208 !== 16'h6900) tb_error("====== WATCHDOG RD/WR ACCESS: WDTCTL != 0x6900 (CONFIG 6) =====");
    `endif
  `endif
`endif
  
`ifdef ASIC_CLOCKING
  `ifdef WATCHDOG_MUX
  `else
    `ifdef WATCHDOG_NOMUX_ACLK
      // From there, force the watchdog clock to DCO_CLK to speedup simulation
      force lfxt_clk = dco_clk; 
    `endif
  `endif
`endif

      // WATCHDOG TEST:  WATCHDOG MODE /64
      //--------------------------------------------------------

      @(mem250===16'h2000);
`ifdef ASIC_CLOCKING
      if (mem200 !== 16'h000B) tb_error("====== WATCHDOG MODE /64: @0x200 != 0x000B =====");
`else
      if (mem200 !== 16'h000A) tb_error("====== WATCHDOG MODE /64: @0x200 != 0x000A =====");
`endif
    
      $display("Watchdog mode /64 mode test completed...");

      
      // WATCHDOG TEST:  INTERVAL MODE /512
      //--------------------------------------------------------

      @(mem250===16'h3000);
`ifdef ASIC_CLOCKING
      if (mem202 !== 16'h0056) tb_error("====== WATCHDOG MODE /512: @0x202 != 0x0056 =====");
`else
      if (mem202 !== 16'h0055) tb_error("====== WATCHDOG MODE /512: @0x202 != 0x0055 =====");
`endif

      $display("Watchdog mode /512 mode test completed...");

      
      // WATCHDOG TEST:  INTERVAL MODE /8192
      //--------------------------------------------------------

      @(mem250===16'h4000);
`ifdef ASIC_CLOCKING
      if (mem204 !== 16'h0556) tb_error("====== WATCHDOG MODE /8192: @0x204 != 0x0556 =====");
`else
      if (mem204 !== 16'h0555) tb_error("====== WATCHDOG MODE /8192: @0x204 != 0x0555 =====");
`endif

      $display("Watchdog mode /8192 mode test completed...");

      
      // WATCHDOG TEST:  INTERVAL MODE /32768
      //--------------------------------------------------------

      @(mem250===16'h5000);
`ifdef ASIC_CLOCKING
      if (mem206 !== 16'h1556) tb_error("====== WATCHDOG MODE /32768: @0x206 != 0x1556 =====");
`else
      if (mem206 !== 16'h1555) tb_error("====== WATCHDOG MODE /32768: @0x206 != 0x1555 =====");
`endif

      $display("Watchdog mode /32768 mode test completed...");

`else
      $display(" ===============================================");
      $display("|               SIMULATION SKIPPED              |");
      $display("|         (the Watchdog is not included)        |");
      $display(" ===============================================");
      $finish;
`endif

      stimulus_done = 1;
   end

