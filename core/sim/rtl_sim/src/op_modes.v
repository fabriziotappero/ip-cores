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
/*                            CPU OPERATING MODES                            */
/*---------------------------------------------------------------------------*/
/* Test the CPU Operating modes:                                             */
/*                                 - CPUOFF (<=> R2[4]): turn off CPU.       */
/*                                 - OSCOFF (<=> R2[5]): turn off LFXT_CLK.  */
/*                                 - SCG1   (<=> R2[7]): turn off SMCLK.     */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 180 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2013-02-25 22:23:18 +0100 (Mon, 25 Feb 2013) $          */
/*===========================================================================*/

integer smclk_cnt;
always @(negedge mclk)
  if (smclk_en) smclk_cnt <= smclk_cnt+1;

integer aclk_cnt;
always @(negedge mclk)
  if (aclk_en) aclk_cnt <= aclk_cnt+1;

integer inst_cnt;
always @(inst_number)
  inst_cnt = inst_cnt+1;

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

      // SCG1   (<=> R2[7]): turn off SMCLK
      //--------------------------------------------------------

      @(r15==16'h1001);
      smclk_cnt = 0;
      repeat (84) @(posedge mclk);
      if (smclk_cnt !== 16'h000a) tb_error("====== SCG1 TEST 1: SMCLK IS NOT RUNNING =====");

      @(r15==16'h1002);
      smclk_cnt = 0;
      repeat (84) @(posedge mclk);
      if (smclk_cnt !== 16'h0000) tb_error("====== SCG1 TEST 2: SMCLK IS NOT STOPPED =====");

      @(r15==16'h1003);
      p1_din[0] = 1'b1;
      repeat (2) @(posedge mclk);
      p1_din[0] = 1'b0;
      smclk_cnt = 0;
      repeat (84) @(posedge mclk);
      if (smclk_cnt !== 16'h000a) tb_error("====== SCG1 TEST 3: SMCLK IS NOT RUNNING DURING IRQ =====");

      @(r15==16'h1004);
      smclk_cnt = 0;
      repeat (84) @(posedge mclk);
      if (smclk_cnt !== 16'h0000) tb_error("====== SCG1 TEST 4: SMCLK IS NOT STOPPED =====");
   
      @(r15==16'h1005);
      smclk_cnt = 0;
      repeat (80) @(posedge mclk);
      if (smclk_cnt !== 16'h000a) tb_error("====== SCG1 TEST 5: SMCLK IS NOT RUNNING =====");

      
      // OSCOFF  (<=> R2[5]): turn off LFXT1CLK
      //--------------------------------------------------------

      @(r15==16'h2001);
      aclk_cnt  = 0;
      smclk_cnt = 0;
      repeat (104) @(posedge mclk);
      if (aclk_cnt  !== 16'h0004) tb_error("====== OSCOFF TEST 1: ACLK  IS NOT RUNNING =====");
      if (smclk_cnt !== 16'h0068) tb_error("====== OSCOFF TEST 1: SMCLK IS NOT RUNNING ON MCLK =====");

      @(r15==16'h2002);
      aclk_cnt  = 0;
      smclk_cnt = 0;
      repeat (104) @(posedge mclk);
      if (aclk_cnt  !== 16'h0000) tb_error("====== OSCOFF TEST 2: ACLK  IS NOT STOPPED =====");
      if (smclk_cnt !== 16'h0068) tb_error("====== OSCOFF TEST 2: SMCLK IS NOT RUNNING ON MCLK =====");

      @(r15==16'h2003);
      p1_din[0] = 1'b1;
      repeat (2) @(posedge mclk);
      p1_din[0] = 1'b0;
      aclk_cnt  = 0;
      smclk_cnt = 0;
      repeat (104) @(posedge mclk);
      if (aclk_cnt  !== 16'h0003) tb_error("====== OSCOFF TEST 3: ACLK  IS NOT RUNNING DURING IRQ =====");
      if (smclk_cnt !== 16'h0068) tb_error("====== OSCOFF TEST 3: SMCLK IS NOT RUNNING ON MCLK =====");

       @(r15==16'h2004);
      aclk_cnt  = 0;
      smclk_cnt = 0;
      repeat (104) @(posedge mclk);
      if (aclk_cnt  !== 16'h0000) tb_error("====== OSCOFF TEST 4: ACLK  IS NOT STOPPED =====");
      if (smclk_cnt !== 16'h0068) tb_error("====== OSCOFF TEST 4: SMCLK IS NOT RUNNING ON MCLK =====");

      @(r15==16'h2005);
      aclk_cnt  = 0;
      smclk_cnt = 0;
      repeat (104) @(posedge mclk);
      if (aclk_cnt  !== 16'h0004) tb_error("====== OSCOFF TEST 5: ACLK  IS NOT RUNNING =====");
      if (smclk_cnt !== 16'h0004) tb_error("====== OSCOFF TEST 5: SMCLK IS NOT RUNNING ON LFXT1 =====");

      @(r15==16'h2006);
      aclk_cnt  = 0;
      smclk_cnt = 0;
      repeat (104) @(posedge mclk);
      if (aclk_cnt  !== 16'h0003) tb_error("====== OSCOFF TEST 6: ACLK  IS NOT RUNNING =====");
      if (smclk_cnt !== 16'h0068) tb_error("====== OSCOFF TEST 6: SMCLK IS NOT RUNNING ON MCLK =====");

      
      // CPUOFF  (<=> R2[4]): turn off CPU
      //--------------------------------------------------------

      @(r15==16'h3001);
      @(negedge mclk);
      inst_cnt  = 0;
      repeat (80) @(negedge mclk);
      if (inst_cnt  <= 16'h0030) tb_error("====== CPUOFF TEST 1: CPU IS NOT RUNNING =====");

      @(r15==16'h3002);
      repeat (3) @(negedge mclk);
      inst_cnt  = 0;
      repeat (80) @(negedge mclk);
      if (inst_cnt  !== 16'h0000) tb_error("====== CPUOFF TEST 2: CPU IS NOT STOPPED =====");

      @(posedge mclk);
      p1_din[0] = 1'b1;
      repeat (2) @(posedge mclk);
      p1_din[0] = 1'b0;
      @(negedge mclk);
      inst_cnt  = 0;
      repeat (80) @(negedge mclk);
      if (inst_cnt <= 16'h0025) tb_error("====== CPUOFF TEST 3: CPU IS NOT RUNNING DURING IRQ (PORT 1) =====");
      
      @(r1==(`PER_SIZE+16'h0050));
      repeat (3) @(negedge mclk);
      inst_cnt  = 0;
      repeat (80) @(negedge mclk);
      if (inst_cnt  !== 16'h0000) tb_error("====== CPUOFF TEST 4: CPU IS NOT STOPPED AFTER IRQ =====");

      @(posedge mclk);
      p2_din[0] = 1'b1;
      repeat (2) @(posedge mclk);
      p2_din[0] = 1'b0;
      @(negedge mclk);
      inst_cnt  = 0;
      repeat (80) @(negedge mclk);
      if (inst_cnt <= 16'h0025) tb_error("====== CPUOFF TEST 5: CPU IS NOT RUNNING DURING IRQ (PORT 2) =====");

      @(r15==16'h3003);
      @(negedge mclk);
      inst_cnt  = 0;
      repeat (80) @(negedge mclk);
      if (inst_cnt  <= 16'h0030) tb_error("====== CPUOFF TEST 6: CPU IS NOT RUNNING =====");

`endif    

      stimulus_done = 1;
   end

