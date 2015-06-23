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

`define LONG_TIMEOUT

   integer my_test;
   integer test_var;

   
initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
`ifdef DBG_EN
`ifdef DBG_I2C
      #1 dbg_en = 1;
      repeat(30) @(posedge mclk);
      stimulus_done = 0;

   `ifdef DBG_RST_BRK_EN
      dbg_i2c_wr(CPU_CTL,  16'h0002);  // RUN
   `endif


      // STOP, FREEZE, ISTEP, RUN
      //--------------------------------------------------------

      dbg_i2c_wr(CPU_STAT,  16'h00ff); // HALT
      dbg_i2c_rd(CPU_STAT);            // READ STATUS
      if (dbg_i2c_buf !== 16'h0000)      tb_error("====== STOP, FREEZE, ISTEP, RUN: status test 1 =====");

      dbg_i2c_wr(CPU_CTL,  16'h0001);  // HALT
      repeat(10) @(posedge mclk);
      test_var = inst_number;
      repeat(50) @(posedge mclk);
      if (test_var !== inst_number)       tb_error("====== STOP, FREEZE, ISTEP, RUN: HALT function =====");
    
      dbg_i2c_rd(CPU_STAT);            // READ STATUS
      if (dbg_i2c_buf !== 16'h0001)      tb_error("====== STOP, FREEZE, ISTEP, RUN: HALT status - test 1 =====");

      if (dbg_freeze !== 1'b0)            tb_error("====== STOP, FREEZE, ISTEP, RUN: FREEZE value - test 1 =====");
      dbg_i2c_wr(CPU_CTL,  16'h0010);  // FREEZE WITH BREAK
      repeat(10) @(posedge mclk);
      if (dbg_freeze !== 1'b1)            tb_error("====== STOP, FREEZE, ISTEP, RUN: FREEZE value - test 2 =====");

      
      test_var = r14;
      dbg_i2c_wr(CPU_CTL,  16'h0004); // ISTEP
      dbg_i2c_wr(CPU_CTL,  16'h0004); // ISTEP
      repeat(12) @(posedge mclk);
      if (test_var !== (r14+1))           tb_error("====== STOP, FREEZE, ISTEP, RUN: ISTEP test 1 =====");
      dbg_i2c_wr(CPU_CTL,  16'h0004); // ISTEP
      dbg_i2c_wr(CPU_CTL,  16'h0004); // ISTEP
      repeat(12) @(posedge mclk);
      if (test_var !== (r14+2))           tb_error("====== STOP, FREEZE, ISTEP, RUN: ISTEP test 2 =====");
      dbg_i2c_wr(CPU_CTL,  16'h0004); // ISTEP
      dbg_i2c_wr(CPU_CTL,  16'h0004); // ISTEP
      repeat(12) @(posedge mclk);
      if (test_var !== (r14+3))           tb_error("====== STOP, FREEZE, ISTEP, RUN: ISTEP test 3 =====");

      
      test_var = inst_number;
      dbg_i2c_wr(CPU_CTL,  16'h0002); // RUN
      repeat(50) @(posedge mclk);
      if (test_var === inst_number)       tb_error("====== STOP, FREEZE, ISTEP, RUN: RUN function - test 1 =====");
      test_var = inst_number;
      repeat(50) @(posedge mclk);
      if (test_var === inst_number)       tb_error("====== STOP, FREEZE, ISTEP, RUN: RUN function - test 2 =====");

      dbg_i2c_rd(CPU_STAT);           // READ STATUS
      if (dbg_i2c_buf !== 16'h0000)      tb_error("====== STOP/RUN, ISTEP: HALT status - test 2 =====");
     

      
      // RESET / BREAK ON RESET
      //--------------------------------------------------------

      test_var = r14;
      dbg_i2c_wr(CPU_CTL,  16'h0040); // RESET CPU
      dbg_i2c_rd(CPU_STAT);           // READ STATUS
      if (dbg_i2c_buf !== 16'h0004)      tb_error("====== RESET / BREAK ON RESET: RESET error- test 1 =====");
      if (puc_rst      !== 1'b1)          tb_error("====== RESET / BREAK ON RESET: RESET error- test 2 =====");
      dbg_i2c_wr(CPU_CTL,  16'h0000); // RELEASE RESET
      dbg_i2c_rd(CPU_STAT);           // READ STATUS
      if (dbg_i2c_buf !== 16'h0004)      tb_error("====== RESET / BREAK ON RESET: RESET error- test 3 =====");
      if (puc_rst      !== 1'b0)          tb_error("====== RESET / BREAK ON RESET: RESET error- test 4 =====");
      if (test_var >= r14)                tb_error("====== RESET / BREAK ON RESET: RESET error- test 5 =====");
      dbg_i2c_wr(CPU_STAT,  16'h0004); // CLEAR STATUS
      dbg_i2c_rd(CPU_STAT);            // READ STATUS
      if (dbg_i2c_buf !== 16'h0000)      tb_error("====== RESET / BREAK ON RESET: RESET error- test 6 =====");


      test_var = r14;
      dbg_i2c_wr(CPU_CTL,  16'h0060); // RESET & BREAK ON RESET
      dbg_i2c_rd(CPU_STAT);           // READ STATUS
      if (dbg_i2c_buf !== 16'h0004)      tb_error("====== RESET / BREAK ON RESET: BREAK ON RESET error- test 1 =====");
      if (puc_rst      !== 1'b1)          tb_error("====== RESET / BREAK ON RESET: BREAK ON RESET error- test 2 =====");
      dbg_i2c_wr(CPU_CTL,  16'h0020); // RELEASE RESET
      dbg_i2c_rd(CPU_STAT);           // READ STATUS
      if (dbg_i2c_buf !== 16'h0005)      tb_error("====== RESET / BREAK ON RESET: BREAK ON RESET error- test 3 =====");
      if (puc_rst      !== 1'b0)          tb_error("====== RESET / BREAK ON RESET: BREAK ON RESET error- test 4 =====");
      repeat(10) @(posedge mclk);
      test_var = inst_number;
      repeat(50) @(posedge mclk);
      if (test_var !== inst_number)       tb_error("====== RESET / BREAK ON RESET: BREAK ON RESET error- test 5 =====");
      if (r0       !== irq_vect_15)       tb_error("====== RESET / BREAK ON RESET: BREAK ON RESET error- test 6 =====");

      dbg_i2c_wr(CPU_STAT,  16'h0004); // CLEAR STATUS
      dbg_i2c_rd(CPU_STAT);            // READ STATUS
      if (dbg_i2c_buf !== 16'h0001)      tb_error("====== RESET / BREAK ON RESET: BREAK ON RESET error- test 7 =====");

      dbg_i2c_wr(CPU_CTL,  16'h0002);  // RUN
      dbg_i2c_rd(CPU_STAT);            // READ STATUS
      if (dbg_i2c_buf !== 16'h0000)      tb_error("====== RESET / BREAK ON RESET: BREAK ON RESET error- test 8 =====");

      
      // SOFTWARE BREAKPOINT
      //--------------------------------------------------------

      dbg_i2c_wr(CPU_CTL,  16'h0048);  // RESET & ENABLE SOFTWARE BREAKPOINT
      dbg_i2c_wr(CPU_CTL,  16'h0008);  // RELEASE RESET
      dbg_i2c_rd(CPU_STAT);            // READ STATUS
      if (dbg_i2c_buf !== 16'h000D)      tb_error("====== SOFTWARE BREAKPOINT: test 1 =====");
      if (r0           !== ('h10000-`PMEM_SIZE+'h12))      tb_error("====== SOFTWARE BREAKPOINT: test 2 =====");
      dbg_i2c_wr(CPU_STAT,  16'h000C); // CLEAR STATUS
      dbg_i2c_rd(CPU_STAT);            // READ STATUS
      if (dbg_i2c_buf !== 16'h0001)      tb_error("====== SOFTWARE BREAKPOINT: test 3 =====");

      // Replace software breakpoint with a mov #2, r15 (opcode=0x432f)
      dbg_i2c_wr(MEM_ADDR, ('h10000-`PMEM_SIZE+'h12));
      dbg_i2c_wr(MEM_DATA, 16'h432f);
      dbg_i2c_wr(MEM_CTL,  16'h0003);

      // Dummy write
      dbg_i2c_wr(MEM_ADDR, 16'hff00);
      dbg_i2c_wr(MEM_DATA, 16'h1234);
      dbg_i2c_wr(MEM_CTL,  16'h0003);

      // RUN
      dbg_i2c_wr(CPU_CTL,  16'h000A);
      repeat(20) @(posedge mclk);
      if (r15     !== 16'h0002)           tb_error("====== SOFTWARE BREAKPOINT: test 4 =====");
 
      dbg_i2c_rd(CPU_STAT);            // READ STATUS
      if (dbg_i2c_buf !== 16'h0009)      tb_error("====== SOFTWARE BREAKPOINT: test 5 =====");
      if (r0           !== ('h10000-`PMEM_SIZE+'h16))      tb_error("====== SOFTWARE BREAKPOINT: test 6 =====");
      dbg_i2c_wr(CPU_STAT,  16'h0008); // CLEAR STATUS
      dbg_i2c_rd(CPU_STAT);            // READ STATUS
      if (dbg_i2c_buf !== 16'h0001)      tb_error("====== SOFTWARE BREAKPOINT: test 7 =====");

      
      // Replace software breakpoint with a mov #4, r15 (opcode=0x422f)
      dbg_i2c_wr(MEM_ADDR, ('h10000-`PMEM_SIZE+'h16));
      dbg_i2c_wr(MEM_DATA, 16'h422f);
      dbg_i2c_wr(MEM_CTL,  16'h0003);

      // Dummy write
      dbg_i2c_wr(MEM_ADDR, 16'hff00);
      dbg_i2c_wr(MEM_DATA, 16'h5678);
      dbg_i2c_wr(MEM_CTL,  16'h0003);
     
      // RUN
      dbg_i2c_wr(CPU_CTL,  16'h000A);
      repeat(20) @(posedge mclk);
      if (r15     !== 16'h0004)           tb_error("====== SOFTWARE BREAKPOINT: test 8 =====");
 

      stimulus_done = 1;
`else

       $display(" ===============================================");
       $display("|               SIMULATION SKIPPED              |");
       $display("|   (serial debug interface I2C not included)   |");
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

