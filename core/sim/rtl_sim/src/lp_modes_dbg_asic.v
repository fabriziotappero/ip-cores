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
/*                            CPU LOW POWER MODES                            */
/*---------------------------------------------------------------------------*/
/* Test the CPU Low Power modes:                                             */
/*                              - LPM0    <=>  CPUOFF                        */
/*                              - LPM1    <=>  CPUOFF + SCG0                 */
/*                              - LPM2    <=>  CPUOFF +        SCG1          */
/*                              - LPM3    <=>  CPUOFF + SCG0 + SCG1          */
/*                              - LPM4    <=>  CPUOFF + SCG0 + SCG1 + OSCOFF */
/*                                                                           */
/* Reminder:                                                                 */
/*                              - CPUOFF  <=>  turns off CPU.                */
/*                              - SCG0    <=>  turns off DCO.                */
/*                              - SCG1    <=>  turns off SMCLK.              */
/*                              - OSCOFF  <=>  turns off LFXT_CLK.           */
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
      @(negedge puc_rst);
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

      // Enable debug interface
      dbg_en  = 1;

      irq[`IRQ_NR-14]  = 0;
      wkup[2] = 0;

      irq[`IRQ_NR-13]  = 0;
      wkup[3] = 0;

      //$display("dco_clk_cnt: %d / mclk_cnt: %d / smclk_cnt: %d / aclk_cnt: %d / inst_cnt: %d ", dco_clk_cnt, mclk_cnt, smclk_cnt, aclk_cnt, inst_cnt);

`ifdef ASIC_CLOCKING
      
      // ACTIVE
      //--------------------------------------------------------

      @(r15==16'h1001);
      #(10*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== ACTIVE TEST 1: DCO_CLK IS NOT RUNNING =====");
      if (mclk_cnt    !== 100) tb_error("====== ACTIVE TEST 2: MCLK    IS NOT RUNNING =====");
      if (smclk_cnt   !== 100) tb_error("====== ACTIVE TEST 3: SMCLK   IS NOT RUNNING =====");
      if (aclk_cnt    <  3)    tb_error("====== ACTIVE TEST 4: ACLK    IS NOT RUNNING =====");
      if (inst_cnt    <  60)   tb_error("====== ACTIVE TEST 5: CPU IS NOT EXECUTING   =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;



      // LPM0 ( CPUOFF )
      //--------------------------------------------------------

      @(r15==16'h2001);
      #(10*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM0 TEST 1: DCO_CLK IS NOT RUNNING =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM0 TEST 2: MCLK    IS NOT RUNNING =====");
      if (smclk_cnt   !== 100) tb_error("====== LPM0 TEST 3: SMCLK   IS NOT RUNNING =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM0 TEST 4: ACLK    IS NOT RUNNING =====");
      if (inst_cnt    !== 0)   tb_error("====== LPM0 TEST 5: CPU IS EXECUTING       =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      @(posedge dco_clk);                //---------- PORT1 IRQ TRIAL (STAYING IN POWER MODE) -------------//
      wkup[2] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-14]); // IRQ_ACC-2
      #(10*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM0 TEST  6: DCO_CLK IS NOT RUNNING DURING IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM0 TEST  7: MCLK    IS NOT RUNNING DURING IRQ =====");
      if (smclk_cnt   !== 100) tb_error("====== LPM0 TEST  8: SMCLK   IS NOT RUNNING DURING IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM0 TEST  9: ACLK    IS NOT RUNNING DURING IRQ =====");
      if (inst_cnt    <  60)   tb_error("====== LPM0 TEST 10: CPU IS NOT EXECUTING DURING IRQ   =====");
      @(r13==16'haaaa);
      wkup[2] = 1'b0;
      
       #(10*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM0 TEST 11: DCO_CLK IS NOT RUNNING AFTER IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM0 TEST 12: MCLK    IS NOT RUNNING AFTER IRQ =====");
      if (smclk_cnt   !== 100) tb_error("====== LPM0 TEST 13: SMCLK   IS NOT RUNNING AFTER IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM0 TEST 14: ACLK    IS NOT RUNNING AFTER IRQ =====");
      if (inst_cnt    !== 0)   tb_error("====== LPM0 TEST 15: CPU IS EXECUTING AFTER IRQ       =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

                                         //---------- PORT2 IRQ TRIAL (EXITING POWER MODE) -------------//
      wkup[3] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-13]); // IRQ_ACC-3
      #(10*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM0 TEST 16: DCO_CLK IS NOT RUNNING DURING IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM0 TEST 17: MCLK    IS NOT RUNNING DURING IRQ =====");
      if (smclk_cnt   !== 100) tb_error("====== LPM0 TEST 18: SMCLK   IS NOT RUNNING DURING IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM0 TEST 19: ACLK    IS NOT RUNNING DURING IRQ =====");
      if (inst_cnt    <  60)   tb_error("====== LPM0 TEST 20: CPU IS NOT EXECUTING DURING IRQ   =====");
      @(r13==16'hbbbb);
      wkup[3] = 1'b0;
      
       #(10*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM0 TEST 21: DCO_CLK IS NOT RUNNING AFTER IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM0 TEST 22: MCLK    IS NOT RUNNING AFTER IRQ =====");
      if (smclk_cnt   !== 100) tb_error("====== LPM0 TEST 23: SMCLK   IS NOT RUNNING AFTER IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM0 TEST 24: ACLK    IS NOT RUNNING AFTER IRQ =====");
      if (inst_cnt    <  60)   tb_error("====== LPM0 TEST 25: CPU IS NOT EXECUTING AFTER IRQ   =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      
      // LPM1 ( CPUOFF + SCG0 )
      //--------------------------------------------------------

      @(r15==16'h3001);
      // Until the SMCLK clock mux is implemented, force SMCLK to LFXT_CLK;
      force dut.clock_module_0.nodiv_smclk = lfxt_clk;
      //force dut.clock_module_0.smclk       = lfxt_clk;

      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM1 TEST 1: DCO_CLK IS NOT RUNNING =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM1 TEST 2: MCLK    IS NOT RUNNING =====");
      if (smclk_cnt   <   3)   tb_error("====== LPM1 TEST 3: SMCLK   IS NOT RUNNING =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM1 TEST 4: ACLK    IS NOT RUNNING =====");
      if (inst_cnt    !== 0)   tb_error("====== LPM1 TEST 5: CPU IS EXECUTING       =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      #(1*50);                           //---------- PORT1 IRQ TRIAL (STAYING IN POWER MODE) -------------//
      wkup[2] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-14]); // IRQ_ACC-2
      #(10*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM1 TEST  6: DCO_CLK IS NOT RUNNING DURING IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM1 TEST  7: MCLK    IS NOT RUNNING DURING IRQ =====");
      if (smclk_cnt   <   3)   tb_error("====== LPM1 TEST  8: SMCLK   IS NOT RUNNING DURING IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM1 TEST  9: ACLK    IS NOT RUNNING DURING IRQ =====");
      if (inst_cnt    <  60)   tb_error("====== LPM1 TEST 10: CPU IS NOT EXECUTING DURING IRQ   =====");
      @(r13==16'haaaa);
      wkup[2] = 1'b0;
      
       #(10*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM1 TEST 11: DCO_CLK IS NOT RUNNING AFTER IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM1 TEST 12: MCLK    IS NOT RUNNING AFTER IRQ =====");
      if (smclk_cnt   <   3)   tb_error("====== LPM1 TEST 13: SMCLK   IS NOT RUNNING AFTER IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM1 TEST 14: ACLK    IS NOT RUNNING AFTER IRQ =====");
      if (inst_cnt    !== 0)   tb_error("====== LPM1 TEST 15: CPU IS EXECUTING AFTER IRQ       =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

                                         //---------- PORT2 IRQ TRIAL (EXITING POWER MODE) -------------//
      wkup[3] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-13]); // IRQ_ACC-3
      #(10*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM1 TEST 16: DCO_CLK IS NOT RUNNING DURING IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM1 TEST 17: MCLK    IS NOT RUNNING DURING IRQ =====");
      if (smclk_cnt   !== 4)   tb_error("====== LPM1 TEST 18: SMCLK   IS NOT RUNNING DURING IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM1 TEST 19: ACLK    IS NOT RUNNING DURING IRQ =====");
      if (inst_cnt    <  60)   tb_error("====== LPM1 TEST 20: CPU IS NOT EXECUTING DURING IRQ   =====");
      @(r13==16'hbbbb);
      wkup[3] = 1'b0;
      
       #(10*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM1 TEST 21: DCO_CLK IS NOT RUNNING AFTER IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM1 TEST 22: MCLK    IS NOT RUNNING AFTER IRQ =====");
      if (smclk_cnt   <   3)   tb_error("====== LPM1 TEST 23: SMCLK   IS NOT RUNNING AFTER IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM1 TEST 24: ACLK    IS NOT RUNNING AFTER IRQ =====");
      if (inst_cnt    <  60)   tb_error("====== LPM1 TEST 25: CPU IS NOT EXECUTING AFTER IRQ   =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;


      // LPM2 ( CPUOFF + SCG1 )
      //--------------------------------------------------------

      @(r15==16'h4001);
      
      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM2 TEST 1: DCO_CLK IS NOT RUNNING =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM2 TEST 2: MCLK    IS NOT RUNNING =====");
`ifdef SCG1_EN
      if (smclk_cnt   !== 0)   tb_error("====== LPM2 TEST 3: SMCLK   IS RUNNING     =====");
`else
      if (smclk_cnt   <   3)   tb_error("====== LPM2 TEST 3: SMCLK   IS NOT RUNNING     =====");
`endif
      if (aclk_cnt    <   3)   tb_error("====== LPM2 TEST 4: ACLK    IS NOT RUNNING =====");
      if (inst_cnt    !== 0)   tb_error("====== LPM2 TEST 5: CPU IS EXECUTING       =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      #(1*50);                           //---------- PORT1 IRQ TRIAL (STAYING IN POWER MODE) -------------//
      wkup[2] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-14]); // IRQ_ACC-2
      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM2 TEST  6: DCO_CLK IS NOT RUNNING DURING IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM2 TEST  7: MCLK    IS NOT RUNNING DURING IRQ =====");
      if (smclk_cnt   <   3)   tb_error("====== LPM2 TEST  8: SMCLK   IS NOT RUNNING DURING IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM2 TEST  9: ACLK    IS NOT RUNNING DURING IRQ =====");
      if (inst_cnt    <  60)   tb_error("====== LPM2 TEST 10: CPU IS NOT EXECUTING DURING IRQ   =====");
      @(r13==16'haaaa);
      wkup[2] = 1'b0;
      
       #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM2 TEST 11: DCO_CLK IS NOT RUNNING AFTER IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM2 TEST 12: MCLK    IS NOT RUNNING AFTER IRQ =====");
`ifdef SCG1_EN
      if (smclk_cnt   !== 0)   tb_error("====== LPM2 TEST 13: SMCLK   IS RUNNING     =====");
`else
      if (smclk_cnt   <   3)   tb_error("====== LPM2 TEST 13: SMCLK   IS NOT RUNNING     =====");
`endif
      if (aclk_cnt    <   3)   tb_error("====== LPM2 TEST 14: ACLK    IS NOT RUNNING AFTER IRQ =====");
      if (inst_cnt    !== 0)   tb_error("====== LPM2 TEST 15: CPU IS EXECUTING AFTER IRQ       =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

                                         //---------- PORT2 IRQ TRIAL (EXITING POWER MODE) -------------//
      wkup[3] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-13]); // IRQ_ACC-3
      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM2 TEST 16: DCO_CLK IS NOT RUNNING DURING IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM2 TEST 17: MCLK    IS NOT RUNNING DURING IRQ =====");
      if (smclk_cnt   <   3)   tb_error("====== LPM2 TEST 18: SMCLK   IS NOT RUNNING DURING IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM2 TEST 19: ACLK    IS NOT RUNNING DURING IRQ =====");
      if (inst_cnt    <  60)   tb_error("====== LPM2 TEST 20: CPU IS NOT EXECUTING DURING IRQ   =====");
      @(r13==16'hbbbb);
      wkup[3] = 1'b0;
      
       #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM2 TEST 21: DCO_CLK IS NOT RUNNING AFTER IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM2 TEST 22: MCLK    IS NOT RUNNING AFTER IRQ =====");
      if (smclk_cnt   <   3)   tb_error("====== LPM2 TEST 23: SMCLK   IS NOT RUNNING AFTER IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM2 TEST 24: ACLK    IS NOT RUNNING AFTER IRQ =====");
      if (inst_cnt    <  60)   tb_error("====== LPM2 TEST 25: CPU IS NOT EXECUTING AFTER IRQ   =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;


      // LPM3 ( CPUOFF + SCG0 + SCG1 )
      //--------------------------------------------------------

      @(r15==16'h5001);
      
      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM3 TEST 1: DCO_CLK IS NOT RUNNING =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM3 TEST 2: MCLK    IS NOT RUNNING =====");
`ifdef SCG1_EN
      if (smclk_cnt   !== 0)   tb_error("====== LPM3 TEST 3: SMCLK   IS RUNNING     =====");
`else
      if (smclk_cnt   <   3)   tb_error("====== LPM3 TEST 3: SMCLK   IS NOT RUNNING     =====");
`endif
      if (aclk_cnt    <   3)   tb_error("====== LPM3 TEST 4: ACLK    IS NOT RUNNING =====");
      if (inst_cnt    !== 0)   tb_error("====== LPM3 TEST 5: CPU IS EXECUTING       =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      #(1*50);                           //---------- PORT1 IRQ TRIAL (STAYING IN POWER MODE) -------------//
      wkup[2] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-14]); // IRQ_ACC-2
      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM3 TEST  6: DCO_CLK IS NOT RUNNING DURING IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM3 TEST  7: MCLK    IS NOT RUNNING DURING IRQ =====");
      if (smclk_cnt   <   3)   tb_error("====== LPM3 TEST  8: SMCLK   IS NOT RUNNING DURING IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM3 TEST  9: ACLK    IS NOT RUNNING DURING IRQ =====");
      if (inst_cnt    <  60)   tb_error("====== LPM3 TEST 10: CPU IS NOT EXECUTING DURING IRQ   =====");
      @(r13==16'haaaa);
      wkup[2] = 1'b0;
      
      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM3 TEST 11: DCO_CLK IS NOT RUNNING AFTER IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM3 TEST 12: MCLK    IS NOT RUNNING AFTER IRQ =====");
`ifdef SCG1_EN
      if (smclk_cnt   !== 0)   tb_error("====== LPM3 TEST 13: SMCLK   IS RUNNING     AFTER IRQ =====");
`else
      if (smclk_cnt   <   3)   tb_error("====== LPM3 TEST 13: SMCLK   IS NOT RUNNING     AFTER IRQ =====");
`endif
      if (aclk_cnt    <   3)   tb_error("====== LPM3 TEST 14: ACLK    IS NOT RUNNING AFTER IRQ =====");
      if (inst_cnt    !== 0)   tb_error("====== LPM3 TEST 15: CPU IS EXECUTING AFTER IRQ       =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

                                         //---------- PORT2 IRQ TRIAL (EXITING POWER MODE) -------------//
      wkup[3] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-13]); // IRQ_ACC-3
      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM3 TEST 16: DCO_CLK IS NOT RUNNING DURING IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM3 TEST 17: MCLK    IS NOT RUNNING DURING IRQ =====");
      if (smclk_cnt   <   3)   tb_error("====== LPM3 TEST 18: SMCLK   IS NOT RUNNING DURING IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM3 TEST 19: ACLK    IS NOT RUNNING DURING IRQ =====");
      if (inst_cnt    <  60)   tb_error("====== LPM3 TEST 20: CPU IS NOT EXECUTING DURING IRQ   =====");
      @(r13==16'hbbbb);
      wkup[3] = 1'b0;
      
      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM3 TEST 21: DCO_CLK IS NOT RUNNING AFTER IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM3 TEST 22: MCLK    IS NOT RUNNING AFTER IRQ =====");
      if (smclk_cnt   <   3)   tb_error("====== LPM3 TEST 23: SMCLK   IS NOT RUNNING AFTER IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM3 TEST 24: ACLK    IS NOT RUNNING AFTER IRQ =====");
      if (inst_cnt    <  60)   tb_error("====== LPM3 TEST 25: CPU IS NOT EXECUTING AFTER IRQ   =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;


      // LPM4 ( CPUOFF + SCG0 + SCG1 + OSCOFF)
      //--------------------------------------------------------

      @(r15==16'h6001);      

      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM4 TEST 1: DCO_CLK IS NOT RUNNING =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM4 TEST 2: MCLK    IS NOT RUNNING =====");
`ifdef SCG1_EN
      if (smclk_cnt   !== 0)   tb_error("====== LPM4 TEST 3: SMCLK   IS RUNNING     =====");
`else
      if (smclk_cnt   <   3)   tb_error("====== LPM4 TEST 3: SMCLK   IS NOT RUNNING     =====");
`endif
`ifdef ACLK_DIVIDER
  `ifdef OSCOFF_EN
      if (aclk_cnt    !== 0)   tb_error("====== LPM4 TEST 4: ACLK    IS RUNNING =====");
  `else
      if (aclk_cnt    <   3)   tb_error("====== LPM4 TEST 4: ACLK    IS NOT RUNNING =====");
  `endif
`else
      if (aclk_cnt    <   3)   tb_error("====== LPM4 TEST 4: ACLK    IS NOT RUNNING =====");
`endif
      if (inst_cnt    !== 0)   tb_error("====== LPM4 TEST 5: CPU IS EXECUTING       =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      #(1*50);                           //---------- PORT1 IRQ TRIAL (STAYING IN POWER MODE) -------------//
      wkup[2] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-14]); // IRQ_ACC-2
      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM4 TEST  6: DCO_CLK IS NOT RUNNING DURING IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM4 TEST  7: MCLK    IS NOT RUNNING DURING IRQ =====");
      if (smclk_cnt   <   3)   tb_error("====== LPM4 TEST  8: SMCLK   IS NOT RUNNING DURING IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM4 TEST  9: ACLK    IS NOT RUNNING DURING IRQ =====");
      if (inst_cnt    <  60)   tb_error("====== LPM4 TEST 10: CPU IS NOT EXECUTING DURING IRQ   =====");
      @(r13==16'haaaa);
      wkup[2] = 1'b0;
      
      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM4 TEST 11: DCO_CLK IS NOT RUNNING AFTER IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM4 TEST 12: MCLK    IS NOT RUNNING AFTER IRQ =====");
`ifdef SCG1_EN
      if (smclk_cnt   !== 0)   tb_error("====== LPM4 TEST 13: SMCLK   IS RUNNING     AFTER IRQ =====");
`else
      if (smclk_cnt   <   3)   tb_error("====== LPM4 TEST 13: SMCLK   IS NOT RUNNING     AFTER IRQ =====");
`endif
`ifdef ACLK_DIVIDER
  `ifdef OSCOFF_EN
      if (aclk_cnt    !== 0)   tb_error("====== LPM4 TEST 14: ACLK    IS RUNNING AFTER IRQ =====");
  `else
      if (aclk_cnt    <   3)   tb_error("====== LPM4 TEST 14: ACLK    IS NOT RUNNING AFTER IRQ =====");
  `endif
`else
      if (aclk_cnt    <   3)   tb_error("====== LPM4 TEST 14: ACLK    IS NOT RUNNING AFTER IRQ =====");
`endif
      if (inst_cnt    !== 0)   tb_error("====== LPM4 TEST 15: CPU IS EXECUTING AFTER IRQ       =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

                                         //---------- PORT2 IRQ TRIAL (EXITING POWER MODE) -------------//
      wkup[3] = 1'b1;
      @(posedge irq_acc[`IRQ_NR-13]); // IRQ_ACC-3
      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM4 TEST 16: DCO_CLK IS NOT RUNNING DURING IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM4 TEST 17: MCLK    IS NOT RUNNING DURING IRQ =====");
      if (smclk_cnt   <   3)   tb_error("====== LPM4 TEST 18: SMCLK   IS NOT RUNNING DURING IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM4 TEST 19: ACLK    IS NOT RUNNING DURING IRQ =====");
      if (inst_cnt    <  60)   tb_error("====== LPM4 TEST 20: CPU IS NOT EXECUTING DURING IRQ   =====");
      @(r13==16'hbbbb);
      wkup[3] = 1'b0;
      
      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== LPM4 TEST 21: DCO_CLK IS NOT RUNNING AFTER IRQ =====");
      if (mclk_cnt    !== 100) tb_error("====== LPM4 TEST 22: MCLK    IS NOT RUNNING AFTER IRQ =====");
      if (smclk_cnt   <   3)   tb_error("====== LPM4 TEST 23: SMCLK   IS NOT RUNNING AFTER IRQ =====");
      if (aclk_cnt    <   3)   tb_error("====== LPM4 TEST 24: ACLK    IS NOT RUNNING AFTER IRQ =====");
      if (inst_cnt    <  60)   tb_error("====== LPM4 TEST 25: CPU IS NOT EXECUTING AFTER IRQ   =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;



`else
      $display(" ===============================================");
      $display("|               SIMULATION SKIPPED              |");
      $display("|   (this test is not supported in FPGA mode)   |");
      $display(" ===============================================");
      $finish;
`endif    

      stimulus_done = 1;
   end

