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
/*                                 - SCG0   (<=> R2[6]): turn off DCO.       */
/*                                 - SCG1   (<=> R2[7]): turn off SMCLK.     */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 95 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2011-02-24 21:37:57 +0100 (Thu, 24 Feb 2011) $          */
/*===========================================================================*/

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
always @(negedge aclk)
  aclk_cnt <= aclk_cnt+1;

integer inst_cnt;
always @(inst_number)
  inst_cnt = inst_cnt+1;

// Wakeup synchronizer to generate IRQ
reg [1:0] wkup2_sync;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst) wkup2_sync <= 2'b00;
  else         wkup2_sync <= {wkup2_sync[0], wkup[2]};

always @(wkup2_sync)
  irq[`IRQ_NR-14] = wkup2_sync[1]; // IRQ-2
   
// Wakeup synchronizer to generate IRQ
reg [1:0] wkup3_sync;
always @(posedge mclk or posedge puc_rst)
  if (puc_rst) wkup3_sync <= 2'b00;
  else         wkup3_sync <= {wkup3_sync[0], wkup[3]};

always @(wkup3_sync)
  irq[`IRQ_NR-13] = wkup3_sync[1]; // IRQ-3
   

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

      irq[`IRQ_NR-14]  = 0; // IRQ-2
      wkup[2] = 0;

      irq[`IRQ_NR-13]  = 0; // IRQ-3
      wkup[3] = 0;


`ifdef ASIC_CLOCKING

      // SCG1   (<=> R2[7]): turn off SMCLK
      //--------------------------------------------------------

      @(r15==16'h1001);
      repeat (10)  @(posedge mclk);
      smclk_cnt = 0;
      repeat (100) @(posedge mclk);
      if (smclk_cnt !== 100) tb_error("====== SCG1 TEST 1: SMCLK IS NOT RUNNING =====");
      smclk_cnt = 0;

      @(r15==16'h1002);
      repeat (10)  @(posedge mclk);
      smclk_cnt = 0;
      repeat (100) @(posedge mclk);
`ifdef SCG1_EN
      if (smclk_cnt !== 0)   tb_error("====== SCG1 TEST 2: SMCLK IS NOT STOPPED =====");
`else
      if (smclk_cnt !== 100) tb_error("====== SCG1 TEST 2: SMCLK IS STOPPED =====");
`endif
      smclk_cnt = 0;


      @(r15==16'h1003);                //---------- PORT2 IRQ TRIAL (EXITING POWER MODE) -------------//
      wkup[3] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-13]); // IRQ_ACC-3
      aclk_cnt = 0;
      repeat (10) @(posedge mclk);
      smclk_cnt = 0;
      repeat (50) @(posedge mclk);
      if (smclk_cnt !== 50)  tb_error("====== SCG1 TEST 3: SMCLK IS NOT RUNNING DURING IRQ =====");
      smclk_cnt = 0;
      @(r13==16'hbbbb);
      wkup[3] = 1'b0;

      @(r15==16'h1004);
      smclk_cnt = 0;
      repeat (50) @(posedge mclk);
      if (smclk_cnt !== 50)  tb_error("====== SCG1 TEST 4: SMCLK IS STILL NOT RUNNING WHEN RETURNING FROM IRQ =====");
      smclk_cnt = 0;


      @(r15==16'h1005);
      repeat (10)  @(posedge mclk);
      smclk_cnt = 0;
      repeat (100) @(posedge mclk);
`ifdef SCG1_EN
      if (smclk_cnt !== 0)   tb_error("====== SCG1 TEST 5: SMCLK IS NOT STOPPED =====");
`else
      if (smclk_cnt !== 100) tb_error("====== SCG1 TEST 5: SMCLK IS STOPPED =====");
`endif
      smclk_cnt = 0;

      
      @(r15==16'h1006);                //---------- PORT1 IRQ TRIAL (STAYING IN POWER MODE) -------------//
      wkup[2] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-14]); // IRQ_ACC-2
      repeat (10) @(posedge mclk);
      smclk_cnt = 0;
      repeat (50) @(posedge mclk);
      if (smclk_cnt !== 50)  tb_error("====== SCG1 TEST 6: SMCLK IS NOT RUNNING DURING IRQ =====");
      smclk_cnt = 0;
      @(r13==16'haaaa);
      wkup[2] = 1'b0;

      @(r15==16'h1007);
      repeat (10)  @(posedge mclk);
      smclk_cnt = 0;
      repeat (50) @(posedge mclk);
`ifdef SCG1_EN
      if (smclk_cnt !== 0)   tb_error("====== SCG1 TEST 7: SMCLK IS NOT STOPPED WHEN RETURNING FROM IRQ =====");
`else
      if (smclk_cnt !== 50)  tb_error("====== SCG1 TEST 7: SMCLK IS STOPPED WHEN RETURNING FROM IRQ =====");
`endif
      smclk_cnt = 0;


      @(r15==16'h1008);
      repeat (10) @(posedge mclk);
      smclk_cnt = 0;
      repeat (50) @(posedge mclk);
      if (smclk_cnt !== 50)  tb_error("====== SCG1 TEST 8: SMCLK IS NOT RUNNING =====");
      smclk_cnt = 0;

      
      // OSCOFF  (<=> R2[5]): turn off LFXT1CLK
      //--------------------------------------------------------

      @(r15==16'h2001);
      repeat (10)  @(posedge mclk);
      aclk_cnt = 0;
      repeat (200) @(posedge mclk);
  `ifdef LFXT_DOMAIN
      if (aclk_cnt !== 7)   tb_error("====== OSCOFF TEST 1: ACLK IS NOT RUNNING =====");
  `else
      if (aclk_cnt !== 200) tb_error("====== OSCOFF TEST 1: ACLK IS NOT RUNNING =====");
  `endif
      aclk_cnt = 0;

      @(r15==16'h2002);
      repeat (100) @(posedge mclk);
      aclk_cnt = 0;
      repeat (100) @(posedge mclk);
`ifdef OSCOFF_EN
      if (aclk_cnt !== 0)   tb_error("====== OSCOFF TEST 2: ACLK IS NOT STOPPED =====");
`else
      if (aclk_cnt <   3)   tb_error("====== OSCOFF TEST 2: ACLK IS STOPPED =====");
`endif
      aclk_cnt = 0;


      @(r15==16'h2003);                //---------- PORT2 IRQ TRIAL (EXITING POWER MODE) -------------//
      wkup[3] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-13]); // IRQ_ACC-3
      repeat (100) @(posedge mclk);
      aclk_cnt = 0;
      repeat (100) @(posedge mclk);
  `ifdef LFXT_DOMAIN
      if (aclk_cnt !== 3)   tb_error("====== OSCOFF TEST 3: ACLK IS NOT RUNNING DURING IRQ =====");
  `else
      if (aclk_cnt !== 100) tb_error("====== OSCOFF TEST 3: ACLK IS NOT RUNNING DURING IRQ =====");
  `endif
      aclk_cnt = 0;
      @(r13==16'hbbbb);
      wkup[3] = 1'b0;

      @(r15==16'h2004);
      repeat (100) @(posedge mclk);
      aclk_cnt = 0;
      repeat (100) @(posedge mclk);
  `ifdef LFXT_DOMAIN
      if (aclk_cnt <   3)   tb_error("====== OSCOFF TEST 4: ACLK IS STILL NOT RUNNING WHEN RETURNING FROM IRQ =====");
  `else
      if (aclk_cnt !== 100) tb_error("====== OSCOFF TEST 4: ACLK IS STILL NOT RUNNING WHEN RETURNING FROM IRQ =====");
    `endif
      aclk_cnt = 0;


      @(r15==16'h2005);
      repeat (100) @(posedge mclk);
      aclk_cnt = 0;
      repeat (100) @(posedge mclk);
`ifdef OSCOFF_EN
      if (aclk_cnt !== 0)   tb_error("====== OSCOFF TEST 5: ACLK IS NOT STOPPED =====");
`else
      if (aclk_cnt <   3)   tb_error("====== OSCOFF TEST 5: ACLK IS STOPPED =====");
`endif
      aclk_cnt = 0;

      
      @(r15==16'h2006);                //---------- PORT1 IRQ TRIAL (STAYING IN POWER MODE) -------------//
      wkup[2] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-14]); // IRQ_ACC-2
      repeat (100) @(posedge mclk);
      aclk_cnt = 0;
      repeat (100) @(posedge mclk);
  `ifdef LFXT_DOMAIN
      if (aclk_cnt !== 3)   tb_error("====== OSCOFF TEST 6: ACLK IS NOT RUNNING DURING IRQ =====");
  `else
      if (aclk_cnt !== 100) tb_error("====== OSCOFF TEST 6: ACLK IS NOT RUNNING DURING IRQ =====");
  `endif
      aclk_cnt = 0;
      @(r13==16'haaaa);
      wkup[2] = 1'b0;

      @(r15==16'h2007);
      repeat (100) @(posedge mclk);
      aclk_cnt = 0;
      repeat (100) @(posedge mclk);
`ifdef OSCOFF_EN
      if (aclk_cnt !== 0)   tb_error("====== OSCOFF TEST 7: ACLK IS NOT STOPPED WHEN RETURNING FROM IRQ =====");
`else
      if (aclk_cnt <   3)   tb_error("====== OSCOFF TEST 7: ACLK IS STOPPED WHEN RETURNING FROM IRQ =====");
`endif
      aclk_cnt = 0;


      @(r15==16'h2008);
      repeat (100) @(posedge mclk);
      aclk_cnt = 0;
      repeat (100) @(posedge mclk);
  `ifdef LFXT_DOMAIN
      if (aclk_cnt !== 3)   tb_error("====== OSCOFF TEST 8: ACLK IS NOT RUNNING =====");
  `else
      if (aclk_cnt !== 100) tb_error("====== OSCOFF TEST 8: ACLK IS NOT RUNNING =====");
  `endif
      aclk_cnt = 0;

      
      // CPUOFF  (<=> R2[4]): turn off CPU
      //--------------------------------------------------------

      @(r15==16'h3001);
      repeat (10) @(negedge dco_clk);
      mclk_cnt  = 0;
      repeat (80) @(negedge dco_clk);
      if (mclk_cnt !== 80) tb_error("====== CPUOFF TEST 1: CPU IS NOT RUNNING =====");

      @(r15==16'h3002);
      repeat (10) @(negedge dco_clk);
      mclk_cnt  = 0;
      repeat (80) @(negedge dco_clk);
      if (mclk_cnt !== 0)  tb_error("====== CPUOFF TEST 2: CPU IS NOT STOPPED =====");

      @(posedge dco_clk);                //---------- PORT1 IRQ TRIAL (STAYING IN POWER MODE) -------------//
      wkup[2] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-14]); // IRQ_ACC-2
      repeat(10)  @(negedge dco_clk);
      mclk_cnt  = 0;
      repeat (80) @(negedge dco_clk);
      if (mclk_cnt !== 80) tb_error("====== CPUOFF TEST 3: CPU IS NOT RUNNING DURING IRQ (PORT 1) =====");
      mclk_cnt = 0;
      @(r13==16'haaaa);
      wkup[2] = 1'b0;
      
      @(r1==(`PER_SIZE+16'h0050));
      repeat (10) @(negedge dco_clk);
      mclk_cnt  = 0;
      repeat (80) @(negedge dco_clk);
      if (mclk_cnt  !== 0) tb_error("====== CPUOFF TEST 4: CPU IS NOT STOPPED AFTER IRQ =====");


                                         //---------- PORT2 IRQ TRIAL (EXITING POWER MODE) -------------//
      wkup[3] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-13]); // IRQ_ACC-3
      repeat (10) @(posedge dco_clk);
      mclk_cnt = 0;
      repeat (80) @(posedge dco_clk);
      if (mclk_cnt !== 80)  tb_error("====== CPUOFF TEST 5: CPU IS NOT RUNNING DURING IRQ =====");
      mclk_cnt = 0;
      @(r13==16'hbbbb);
      wkup[3] = 1'b0;

      @(r1==(`PER_SIZE+16'h0050));
      repeat (10) @(negedge dco_clk);
      mclk_cnt  = 0;
      repeat (80) @(negedge dco_clk);
      if (mclk_cnt  !== 80) tb_error("====== CPUOFF TEST 6: CPU IS NOT RUNNING AFTER IRQ =====");



      @(r15==16'h3003);
      repeat (10) @(posedge dco_clk);
      mclk_cnt = 0;
      repeat (80) @(posedge dco_clk);
      if (mclk_cnt !== 80)  tb_error("====== CPUOFF TEST 7: CPU IS STILL NOT RUNNING WHEN RETURNING FROM IRQ =====");
      mclk_cnt = 0;



      // SCG0 (<=> R2[6]): turn off DCO oscillator
      //--------------------------------------------------------

      @(r15==16'h4001);
      #(10*50);
      dco_clk_cnt  = 0;
      #(80*50);
      if (dco_clk_cnt !== 80) tb_error("====== SCG0 TEST 1: DCO IS NOT RUNNING =====");

      @(r15==16'h4002);
      #(10*50);
      dco_clk_cnt  = 0;
      #(80*50);
      if (dco_clk_cnt !== 0)  tb_error("====== SCG0 TEST 2: DCO IS NOT STOPPED =====");


      #(1*50);                           //---------- PORT1 IRQ TRIAL (STAYING IN POWER MODE) -------------//
      wkup[2] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-14]); // IRQ_ACC-2
      #(10*50);
      dco_clk_cnt  = 0;
      #(80*50);
      if (dco_clk_cnt !== 80) tb_error("====== SCG0 TEST 3: DCO IS NOT RUNNING DURING IRQ (PORT 1) =====");
      dco_clk_cnt = 0;
      @(r13==16'haaaa);
      wkup[2] = 1'b0;
      
      #(10*50);
      dco_clk_cnt  = 0;
      #(80*50);
      if (dco_clk_cnt  !== 0) tb_error("====== SCG0 TEST 4: DCO IS NOT STOPPED AFTER IRQ =====");


                                         //---------- PORT2 IRQ TRIAL (EXITING POWER MODE) -------------//
      wkup[3] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-13]); // IRQ_ACC-3
      #(10*50);
      dco_clk_cnt = 0;
      #(80*50);
      if (dco_clk_cnt !== 80)  tb_error("====== SCG0 TEST 5: DCO IS NOT RUNNING DURING IRQ =====");
      dco_clk_cnt = 0;
      @(r13==16'hbbbb);
      wkup[3] = 1'b0;

      #(10*50);
      dco_clk_cnt  = 0;
      #(80*50);
      if (dco_clk_cnt  !== 80) tb_error("====== SCG0 TEST 6: DCO IS NOT RUNNING AFTER IRQ =====");



      @(r15==16'h4003);
      #(10*50);
      dco_clk_cnt = 0;
      #(80*50);
      if (dco_clk_cnt !== 80)  tb_error("====== SCG0 TEST 7: DCO IS STILL NOT RUNNING WHEN RETURNING FROM IRQ =====");
      dco_clk_cnt = 0;



`else
      $display(" ===============================================");
      $display("|               SIMULATION SKIPPED              |");
      $display("|   (this test is not supported in FPGA mode)   |");
      $display(" ===============================================");
      $finish;
`endif    

      stimulus_done = 1;
   end

