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
/*                            DEBUG INTERFACE                                */
/*---------------------------------------------------------------------------*/
/* Test the debug interface:                                                 */
/*                           - CPU Control features.                         */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 95 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2011-02-24 21:37:57 +0100 (Thu, 24 Feb 2011) $          */
/*===========================================================================*/


   integer test_nr;
   integer test_var;

   integer dco_clk_counter;
   always @ (negedge dco_clk)
     dco_clk_counter <=  dco_clk_counter+1;

   integer dbg_clk_counter;
   always @ (negedge dbg_clk)
     dbg_clk_counter <=  dbg_clk_counter+1;

   
initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
`ifdef DBG_EN
`ifdef DBG_UART
  `ifdef ASIC_CLOCKING
      test_nr = 0;
      #1 dbg_en = 0;
      repeat(30) @(posedge dco_clk);
      stimulus_done = 0;

      // Make sure the CPU always starts executing when the
      // debug interface is disabled during POR.
      // Also make sure that the debug interface clock is stopped
      // and that it is under reset
      //--------------------------------------------------------
      dbg_en  = 0;
      test_nr = 1;

      @(negedge dco_clk) dbg_clk_counter = 0;

      repeat(300) @(posedge dco_clk);
      if (r14 === 16'h0000)         tb_error("====== CPU is stopped event though the debug interface is disabled - test 1 =====");
      if (dbg_clk_counter !== 0)    tb_error("====== DBG_CLK is not stopped (test 1) =====");
      if (dbg_rst          == 1'b0) tb_error("====== DBG_RST signal is not active (test 3) =====");
      test_var = r14;
      
      
      // Make sure that enabling the debug interface after the POR
      // don't stop the cpu
      // Also make sure that the debug interface clock is running
      // and that its reset is released
      //--------------------------------------------------------
      dbg_en  = 1;
      test_nr = 2;
     
      @(negedge dco_clk) dbg_clk_counter = 0;

      repeat(300) @(posedge dco_clk);
      if (r14 === test_var[15:0])   tb_error("====== CPU is stopped when the debug interface is disabled after POR - test 4 =====");
      if (dbg_clk_counter  == 0)    tb_error("====== DBG_CLK is not running (test 5) =====");
      if (dbg_rst         !== 1'b0) tb_error("====== DBG_RST signal is active (test 6) =====");

      
      // Make sure that disabling the CPU with debug enabled
      // will stop the CPU
      // Also make sure that the debug interface clock is stopped
      // and that it is NOT under reset
      //--------------------------------------------------------
      cpu_en  = 0;
      dbg_en  = 1;
      test_nr = 3;
     
      #(6*50);
      test_var = r14;
      dbg_clk_counter = 0;

      #(300*50);
      if (r14 !== test_var[15:0])   tb_error("====== CPU is not stopped (test 7) =====");
      if (dbg_clk_counter !== 0)    tb_error("====== DBG_CLK is not running (test 8) =====");
      if (dbg_rst         !== 1'b0) tb_error("====== DBG_RST signal is active (test 9) =====");

      cpu_en  = 1;
      repeat(6) @(negedge dco_clk);
     

      // Create POR with debug enable and observe the
      // behavior depending on the DBG_RST_BRK_EN define
      //--------------------------------------------------------
      dbg_en  = 1;
      test_nr = 4;
      
      @(posedge dco_clk); // Generate POR
      reset_n = 1'b0;
      @(posedge dco_clk);
      reset_n = 1'b1;
     
      repeat(300) @(posedge dco_clk);
  `ifdef DBG_RST_BRK_EN
      if (r14 !== 16'h0000)       tb_error("====== CPU is not stopped with the debug interface enabled and DBG_RST_BRK_EN=1 - test 3 =====");
  `else
      if (r14 === 16'h0000)       tb_error("====== CPU is stopped with the debug interface enabled and DBG_RST_BRK_EN=0 - test 3 =====");
  `endif

      // Send uart synchronization frame
      dbg_uart_tx(DBG_SYNC);

      // Check CPU_CTL reset value
      dbg_uart_rd(CPU_CTL);
  `ifdef DBG_RST_BRK_EN
      if (dbg_uart_buf !== 16'h0030) tb_error("====== CPU_CTL wrong reset value -  test 4 =====");
  `else
      if (dbg_uart_buf !== 16'h0010) tb_error("====== CPU_CTL wrong reset value -  test 4 =====");     
  `endif


      // Make sure that DBG_EN resets the debug interface
      //--------------------------------------------------------
      test_nr = 5;

      // Let the CPU run
      dbg_uart_wr(CPU_CTL,  16'h0002);

      repeat(300) @(posedge dco_clk);
      dbg_uart_wr(CPU_CTL,   16'h0000);
      dbg_uart_wr(MEM_DATA,  16'haa55);
      dbg_uart_rd(CPU_CTL);
      if (dbg_uart_buf !== 16'h0000)  tb_error("====== CPU_CTL write access failed  - test 5 =====");
      dbg_uart_rd(MEM_DATA);
      if (dbg_uart_buf !== 16'haa55)  tb_error("====== MEM_DATA write access failed - test 6 =====");

      
      test_var = r14;  // Backup the current register value

      
      @(posedge dco_clk); // Resets the debug interface
      dbg_en = 1'b0;
      repeat(2) @(posedge dco_clk);
      dbg_en = 1'b1;

      // Make sure that the register was not reseted
      if (r14 < test_var) tb_error("====== CPU was reseted with DBG_EN -  test 7 =====");
      repeat(2) @(posedge dco_clk);   
      
      // Send uart synchronization frame
      dbg_uart_tx(DBG_SYNC);

      // Check CPU_CTL reset value
      dbg_uart_rd(CPU_CTL);
  `ifdef DBG_RST_BRK_EN
      if (dbg_uart_buf !== 16'h0030) tb_error("====== CPU_CTL wrong reset value -  test 8 =====");
  `else
      if (dbg_uart_buf !== 16'h0010) tb_error("====== CPU_CTL wrong reset value -  test 8 =====");     
  `endif
      dbg_uart_rd(MEM_DATA);
      if (dbg_uart_buf !== 16'h0000) tb_error("====== MEM_DATA read access failed - test 9 =====");


      // Make sure that RESET_N resets the debug interface
      //--------------------------------------------------------
      test_nr = 6;

      // Let the CPU run
      dbg_uart_wr(CPU_CTL,  16'h0002);

      repeat(300) @(posedge dco_clk);
      dbg_uart_wr(CPU_CTL,   16'h0000);
      dbg_uart_wr(MEM_DATA,  16'haa55);
      dbg_uart_rd(CPU_CTL);
      if (dbg_uart_buf !== 16'h0000)  tb_error("====== CPU_CTL write access failed  - test 10 =====");
      dbg_uart_rd(MEM_DATA);
      if (dbg_uart_buf !== 16'haa55)  tb_error("====== MEM_DATA write access failed - test 11 =====");

      test_nr = 7;

      @(posedge dco_clk); // Generates POR
      reset_n = 1'b0;
      repeat(2) @(posedge dco_clk);
      reset_n = 1'b1;

      // Make sure that the register was reseted
      if (r14 !== 16'h0000) tb_error("====== CPU was not reseted with RESET_N -  test 12 =====");
      repeat(2) @(posedge dco_clk);
     
      // Send uart synchronization frame
      dbg_uart_tx(DBG_SYNC);

      test_nr = 8;

      // Check CPU_CTL reset value
      dbg_uart_rd(CPU_CTL);
  `ifdef DBG_RST_BRK_EN
      if (dbg_uart_buf !== 16'h0030) tb_error("====== CPU_CTL wrong reset value -  test 8 =====");
  `else
      if (dbg_uart_buf !== 16'h0010) tb_error("====== CPU_CTL wrong reset value -  test 8 =====");     
  `endif
      dbg_uart_rd(MEM_DATA);
      if (dbg_uart_buf !== 16'h0000) tb_error("====== MEM_DATA read access failed - test 9 =====");

      
      // Let the CPU run
      dbg_uart_wr(CPU_CTL,  16'h0002);

      test_nr = 9;

      // Generate IRQ to terminate the test pattern
      irq[`IRQ_NR-15] = 1'b1;
      @(r13);
      irq[`IRQ_NR-15] = 1'b0;
      
      stimulus_done = 1;

  `else
      $display(" ===============================================");
      $display("|               SIMULATION SKIPPED              |");
      $display("|   (this test is not supported in FPGA mode)   |");
      $display(" ===============================================");
      $finish;
  `endif
`else

       $display(" ===============================================");
       $display("|               SIMULATION SKIPPED              |");
       $display("|   (serial debug interface UART not included)  |");
       $display(" ===============================================");
       $finish;
`endif
`else

       $display(" ===============================================");
       $display("|               SIMULATION SKIPPED              |");
       $display("|      (serial debug interface not included)    |");
       $display(" ===============================================");
       $finish;
`endif
   end

