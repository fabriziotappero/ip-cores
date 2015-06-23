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
/*                                 CPU STARTUP                               */
/*---------------------------------------------------------------------------*/
/* Test the CPU startup in ASIC mode:                                        */
/*                        - Check the CPU startup depending on the           */
/*                      CPU_EN / DBG_EN / RESET_N signal.                    */
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
always @(negedge aclk)
  aclk_cnt <= aclk_cnt+1;

integer inst_cnt;
always @(inst_number)
  inst_cnt = inst_cnt+1;

integer test_nr;
   
initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

`ifdef ASIC_CLOCKING
      //  ####  CPU_EN=0  ####  DBG_EN=0  ####  RESET_N=0  ####  //
      test_nr = 0;

      cpu_en  = 0;
      dbg_en  = 0;
      reset_n = 0;

      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 0) tb_error("====== 0/0/0 TEST 1: DCO_CLK IS RUNNING =====");
      if (dco_enable  !== 0) tb_error("====== 0/0/0 TEST 2: DCO_ENABLE  IS SET =====");
      if (dco_wkup    !== 0) tb_error("====== 0/0/0 TEST 3: DCO_WKUP    IS SET =====");
      if (mclk_cnt    !== 0) tb_error("====== 0/0/0 TEST 4: MCLK    IS RUNNING =====");
      if (smclk_cnt   !== 0) tb_error("====== 0/0/0 TEST 5: SMCLK   IS RUNNING =====");
`ifdef OSCOFF_EN
      if (aclk_cnt    !== 0) tb_error("====== 0/0/0 TEST 6: ACLK    IS RUNNING =====");
      if (lfxt_enable !== 0) tb_error("====== 0/0/0 TEST 7: LFXT_ENABLE IS SET =====");
      if (lfxt_wkup   !== 0) tb_error("====== 0/0/0 TEST 8: LFXT_WKUP   IS SET =====");
`else
  `ifdef LFXT_DOMAIN
    `ifdef ACLK_DIVIDER
      if (aclk_cnt    !== 0) tb_error("====== 0/0/0 TEST 6: ACLK IS NOT RUNNING =====");
    `else
      if (aclk_cnt    <   3) tb_error("====== 0/0/0 TEST 6: ACLK IS RUNNING =====");
    `endif
  `else
      if (aclk_cnt    !== 0) tb_error("====== 0/0/0 TEST 6: ACLK IS RUNNING =====");
  `endif
      if (lfxt_enable !== 1) tb_error("====== 0/0/0 TEST 7: LFXT_ENABLE IS CLEARED =====");
      if (lfxt_wkup   !== 0) tb_error("====== 0/0/0 TEST 8: LFXT_WKUP   IS SET =====");
`endif

      if (inst_cnt    !== 0) tb_error("====== 0/0/0 TEST 9: CPU IS EXECUTING   =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      cpu_en  = 0;
      dbg_en  = 0;
      reset_n = 0;
      #(100*50);

      //  ####  CPU_EN=0  ####  DBG_EN=0  ####  RESET_N=1  ####  //
      test_nr = 1;

      cpu_en  = 0;
      dbg_en  = 0;
      reset_n = 1;

      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 0) tb_error("====== 0/0/1 TEST 1: DCO_CLK IS RUNNING =====");
      if (dco_enable  !== 0) tb_error("====== 0/0/1 TEST 2: DCO_ENABLE  IS SET =====");
      if (dco_wkup    !== 0) tb_error("====== 0/0/1 TEST 3: DCO_WKUP    IS SET =====");
      if (mclk_cnt    !== 0) tb_error("====== 0/0/1 TEST 4: MCLK    IS RUNNING =====");
      if (smclk_cnt   !== 0) tb_error("====== 0/0/1 TEST 5: SMCLK   IS RUNNING =====");
      if (inst_cnt    !== 0) tb_error("====== 0/0/1 TEST 6: CPU IS EXECUTING   =====");
`ifdef OSCOFF_EN
      if (aclk_cnt    !== 0) tb_error("====== 0/0/1 TEST 7: ACLK    IS RUNNING =====");
      if (lfxt_enable !== 0) tb_error("====== 0/0/1 TEST 8: LFXT_ENABLE IS SET =====");
      if (lfxt_wkup   !== 0) tb_error("====== 0/0/1 TEST 9: LFXT_WKUP   IS SET =====");
`else
  `ifdef LFXT_DOMAIN
    `ifdef ACLK_DIVIDER
      if (aclk_cnt    !== 0) tb_error("====== 0/0/1 TEST 7: ACLK IS NOT RUNNING =====");
    `else
      if (aclk_cnt    <   3) tb_error("====== 0/0/1 TEST 7: ACLK IS RUNNING =====");
    `endif
  `else
      if (aclk_cnt    !== 0) tb_error("====== 0/0/1 TEST 7: ACLK IS RUNNING =====");
  `endif
      if (lfxt_enable !== 1) tb_error("====== 0/0/1 TEST 8: LFXT_ENABLE IS CLEARED =====");
      if (lfxt_wkup   !== 0) tb_error("====== 0/0/1 TEST 9: LFXT_WKUP   IS SET =====");
`endif
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      cpu_en  = 0;
      dbg_en  = 0;
      reset_n = 0;
      #(100*50);

      //  ####  CPU_EN=0  ####  DBG_EN=1  ####  RESET_N=0  ####  //
      test_nr = 2;

      cpu_en  = 0;
      dbg_en  = 1;
      reset_n = 0;

      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 0) tb_error("====== 0/1/0 TEST 1: DCO_CLK IS RUNNING =====");
      if (dco_enable  !== 0) tb_error("====== 0/1/0 TEST 2: DCO_ENABLE  IS SET =====");
      if (dco_wkup    !== 0) tb_error("====== 0/1/0 TEST 3: DCO_WKUP    IS SET =====");
      if (mclk_cnt    !== 0) tb_error("====== 0/1/0 TEST 4: MCLK    IS RUNNING =====");
      if (smclk_cnt   !== 0) tb_error("====== 0/1/0 TEST 5: SMCLK   IS RUNNING =====");
      if (inst_cnt    !== 0) tb_error("====== 0/1/0 TEST 6: CPU IS EXECUTING   =====");
`ifdef OSCOFF_EN
      if (aclk_cnt    !== 0) tb_error("====== 0/1/0 TEST 7: ACLK    IS RUNNING =====");
      if (lfxt_enable !== 0) tb_error("====== 0/1/0 TEST 8: LFXT_ENABLE IS SET =====");
      if (lfxt_wkup   !== 0) tb_error("====== 0/1/0 TEST 9: LFXT_WKUP   IS SET =====");
`else
  `ifdef LFXT_DOMAIN
    `ifdef ACLK_DIVIDER
      if (aclk_cnt    !== 0) tb_error("====== 0/1/0 TEST 7: ACLK IS NOT RUNNING =====");
    `else
      if (aclk_cnt    <   3) tb_error("====== 0/1/0 TEST 7: ACLK IS NOT RUNNING =====");
    `endif
  `else
      if (aclk_cnt    !== 0) tb_error("====== 0/1/0 TEST 7: ACLK IS RUNNING =====");
  `endif
      if (lfxt_enable !== 1) tb_error("====== 0/1/0 TEST 8: LFXT_ENABLE IS CLEARED =====");
      if (lfxt_wkup   !== 0) tb_error("====== 0/1/0 TEST 9: LFXT_WKUP   IS SET     =====");
`endif
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      cpu_en  = 0;
      dbg_en  = 0;
      reset_n = 0;
      #(100*50);

      //  ####  CPU_EN=1  ####  DBG_EN=0  ####  RESET_N=0  ####  //
      test_nr = 3;

      cpu_en  = 1;
      dbg_en  = 0;
      reset_n = 0;

      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== 1/0/0 TEST 1: DCO_CLK IS NOT RUNNING =====");
      if (dco_enable  !== 0)   tb_error("====== 1/0/0 TEST 2: DCO_ENABLE  IS SET     =====");
      if (dco_wkup    !== 1)   tb_error("====== 1/0/0 TEST 3: DCO_WKUP    IS CLEARED =====");
`ifdef SYNC_CPU_EN
      if (mclk_cnt    !== 0)   tb_error("====== 1/0/0 TEST 4: MCLK    IS RUNNING     =====");
      if (smclk_cnt   !== 0)   tb_error("====== 1/0/0 TEST 5: SMCLK   IS RUNNING     =====");
`else
      if (mclk_cnt    !== 100) tb_error("====== 1/0/0 TEST 4: MCLK    IS NOT RUNNING =====");
    `ifdef SMCLK_MUX
      if (smclk_cnt   !== 0)   tb_error("====== 1/0/0 TEST 5: SMCLK   IS NOT RUNNING =====");
    `else
      if (smclk_cnt   !== 100) tb_error("====== 1/0/0 TEST 5: SMCLK   IS NOT RUNNING =====");
    `endif
`endif
      if (inst_cnt    !== 0)   tb_error("====== 1/0/0 TEST 6: CPU IS EXECUTING       =====");
`ifdef ACLK_DIVIDER
      if (aclk_cnt    !== 0)   tb_error("====== 1/0/0 TEST 7: ACLK    IS RUNNING =====");
`else
      if (aclk_cnt    <   3)   tb_error("====== 1/0/0 TEST 7: ACLK    IS NOT RUNNING =====");
`endif
`ifdef OSCOFF_EN
      if (lfxt_enable !== 0)   tb_error("====== 1/0/0 TEST 8: LFXT_ENABLE IS SET     =====");
      if (lfxt_wkup   !== 1)   tb_error("====== 1/0/0 TEST 9: LFXT_WKUP   IS CLEARED =====");
`else
      if (lfxt_enable !== 1)   tb_error("====== 1/0/0 TEST 8: LFXT_ENABLE IS CLEARED =====");
      if (lfxt_wkup   !== 0)   tb_error("====== 1/0/0 TEST 9: LFXT_WKUP   IS SET     =====");
`endif
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      cpu_en  = 0;
      dbg_en  = 0;
      reset_n = 0;
      #(100*50);

      //  ####  CPU_EN=1  ####  DBG_EN=1  ####  RESET_N=0  ####  //
      test_nr = 4;

      cpu_en  = 1;
      dbg_en  = 1;
      reset_n = 0;

      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== 1/1/0 TEST 1 (simultaneous): DCO_CLK IS NOT RUNNING =====");
      if (dco_enable  !== 0)   tb_error("====== 1/1/0 TEST 2 (simultaneous): DCO_ENABLE  IS SET     =====");
      if (dco_wkup    !== 1)   tb_error("====== 1/1/0 TEST 3 (simultaneous): DCO_WKUP    IS CLEARED =====");
`ifdef SYNC_CPU_EN
      if (mclk_cnt    !== 0)   tb_error("====== 1/1/0 TEST 4 (simultaneous): MCLK    IS RUNNING     =====");
      if (smclk_cnt   !== 0)   tb_error("====== 1/1/0 TEST 5 (simultaneous): SMCLK   IS RUNNING     =====");
`else
      if (mclk_cnt    !== 100) tb_error("====== 1/1/0 TEST 4 (simultaneous): MCLK    IS NOT RUNNING =====");
    `ifdef SMCLK_MUX
      if (smclk_cnt   !== 0)   tb_error("====== 1/1/0 TEST 5 (simultaneous): SMCLK   IS NOT RUNNING =====");
    `else
      if (smclk_cnt   !== 100) tb_error("====== 1/1/0 TEST 5 (simultaneous): SMCLK   IS NOT RUNNING =====");
    `endif
`endif
      if (inst_cnt    !== 0)   tb_error("====== 1/1/0 TEST 6 (simultaneous): CPU IS EXECUTING       =====");
`ifdef ACLK_DIVIDER
      if (aclk_cnt    !== 0)   tb_error("====== 1/1/0 TEST 7 (simultaneous): ACLK    IS RUNNING =====");
`else
      if (aclk_cnt    <   3)   tb_error("====== 1/1/0 TEST 7 (simultaneous): ACLK    IS NOT RUNNING =====");
`endif
`ifdef OSCOFF_EN
      if (lfxt_enable !== 0)   tb_error("====== 1/1/0 TEST 8 (simultaneous): LFXT_ENABLE IS SET     =====");
      if (lfxt_wkup   !== 1)   tb_error("====== 1/1/0 TEST 9 (simultaneous): LFXT_WKUP   IS CLEARED =====");
`else
      if (lfxt_enable !== 1)   tb_error("====== 1/1/0 TEST 8 (simultaneous): LFXT_ENABLE IS CLEARED =====");
      if (lfxt_wkup   !== 0)   tb_error("====== 1/1/0 TEST 9 (simultaneous): LFXT_WKUP   IS SET     =====");
`endif
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      cpu_en  = 0;
      dbg_en  = 0;
      reset_n = 0;
      #(100*50);

      //  ####  CPU_EN=1  ####  DBG_EN=0  ####  RESET_N=1  ####  //
      test_nr = 5;

      cpu_en  = 1;
      dbg_en  = 0;
      reset_n = 1;

      #(200*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== 1/0/1 TEST 1 (simultaneous): DCO_CLK IS NOT RUNNING =====");
      if (dco_enable  !== 1)   tb_error("====== 1/0/1 TEST 2 (simultaneous): DCO_ENABLE  IS CLEARED =====");
      if (dco_wkup    !== 0)   tb_error("====== 1/0/1 TEST 3 (simultaneous): DCO_WKUP    IS SET     =====");
      if (mclk_cnt    !== 100) tb_error("====== 1/0/1 TEST 4 (simultaneous): MCLK    IS NOT RUNNING =====");
      if (smclk_cnt   !== 100) tb_error("====== 1/0/1 TEST 5 (simultaneous): SMCLK   IS NOT RUNNING =====");
      if (inst_cnt    === 0)   tb_error("====== 1/0/1 TEST 6 (simultaneous): CPU IS NOT EXECUTING   =====");
      if (aclk_cnt    <   3)   tb_error("====== 1/0/1 TEST 7 (simultaneous): ACLK    IS NOT RUNNING =====");
      if (lfxt_enable !== 1)   tb_error("====== 1/0/1 TEST 8 (simultaneous): LFXT_ENABLE IS CLEARED =====");
      if (lfxt_wkup   !== 0)   tb_error("====== 1/0/1 TEST 9 (simultaneous): LFXT_WKUP   IS SET     =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      cpu_en  = 0;
      dbg_en  = 0;
      reset_n = 0;
      #(100*50);

      //  ####  CPU_EN=0  ####  DBG_EN=1  ####  RESET_N=1  ####  //
      test_nr = 6;

      cpu_en  = 0;
      dbg_en  = 1;
      reset_n = 1;

      #(100*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 0) tb_error("====== 0/1/1 TEST 1 (simultaneous): DCO_CLK IS  RUNNING =====");
      if (dco_enable  !== 0) tb_error("====== 0/1/1 TEST 2 (simultaneous): DCO_ENABLE  IS SET  =====");
      if (dco_wkup    !== 0) tb_error("====== 0/1/1 TEST 3 (simultaneous): DCO_WKUP    IS SET  =====");
      if (mclk_cnt    !== 0) tb_error("====== 0/1/1 TEST 4 (simultaneous): MCLK    IS  RUNNING =====");
      if (smclk_cnt   !== 0) tb_error("====== 0/1/1 TEST 5 (simultaneous): SMCLK   IS  RUNNING =====");
      if (inst_cnt    !== 0) tb_error("====== 0/1/1 TEST 6 (simultaneous): CPU IS EXECUTING    =====");
`ifdef OSCOFF_EN
      if (aclk_cnt    !== 0) tb_error("====== 0/1/1 TEST 7 (simultaneous): ACLK    IS  RUNNING =====");
      if (lfxt_enable !== 0) tb_error("====== 0/1/1 TEST 8 (simultaneous): LFXT_ENABLE IS SET  =====");
`else
  `ifdef LFXT_DOMAIN
     `ifdef ACLK_DIVIDER
      if (aclk_cnt    !== 0) tb_error("====== 0/1/1 TEST 7 (simultaneous): ACLK IS NOT RUNNING =====");
    `else
      if (aclk_cnt    <   3) tb_error("====== 0/1/1 TEST 7 (simultaneous): ACLK IS NOT RUNNING =====");
    `endif
  `else
      if (aclk_cnt    !== 0) tb_error("====== 0/1/1 TEST 7 (simultaneous): ACLK IS RUNNING =====");
  `endif
      if (lfxt_enable !== 1) tb_error("====== 0/1/1 TEST 8 (simultaneous): LFXT_ENABLE IS CLEARED  =====");
`endif
      if (lfxt_wkup   !== 0) tb_error("====== 0/1/1 TEST 9 (simultaneous): LFXT_WKUP   IS SET  =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      cpu_en  = 0;
      dbg_en  = 0;
      reset_n = 0;
      #(100*50);

      //  ####  CPU_EN=1  ####  DBG_EN=1  ####  RESET_N=1  ####  //
      test_nr = 7;

      cpu_en  = 1;
      dbg_en  = 1;
      reset_n = 1;

      #(150*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== 1/1/1 TEST 1 (simultaneous): DCO_CLK IS NOT RUNNING =====");
      if (mclk_cnt    !== 100) tb_error("====== 1/1/1 TEST 2 (simultaneous): MCLK    IS NOT RUNNING =====");
      if (smclk_cnt   !== 100) tb_error("====== 1/1/1 TEST 3 (simultaneous): SMCLK   IS NOT RUNNING =====");
      if (aclk_cnt    <   3)   tb_error("====== 1/1/1 TEST 4 (simultaneous): ACLK    IS NOT RUNNING =====");
      if (dco_enable  !== 1)   tb_error("====== 1/1/1 TEST 5 (simultaneous): DCO_ENABLE  IS CLEARED =====");
      if (dco_wkup    !== 0)   tb_error("====== 1/1/1 TEST 6 (simultaneous): DCO_WKUP    IS SET     =====");
      if (lfxt_enable !== 1)   tb_error("====== 1/1/1 TEST 7 (simultaneous): LFXT_ENABLE IS CLEARED =====");
      if (lfxt_wkup   !== 0)   tb_error("====== 1/1/1 TEST 8 (simultaneous): LFXT_WKUP   IS SET     =====");
      if (inst_cnt    !== 0)   tb_error("====== 1/1/1 TEST 9 (simultaneous): CPU IS EXECUTING       =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      cpu_en  = 0;
      dbg_en  = 0;
      reset_n = 0;
      #(100*50);

     
      //  ####  CPU_EN=1  ####  DBG_EN=1  ####  RESET_N=1  ####  SEQUENCE 1: RESET_N -> CPU_EN -> DBG_EN
      test_nr = 8;

      reset_n = 1;
      #(150*50);
      cpu_en  = 1;
      #(150*50);
      dbg_en  = 1;

      #(150*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== 1/1/1 TEST 1 (sequence 1): DCO_CLK IS NOT RUNNING =====");
      if (mclk_cnt    !== 100) tb_error("====== 1/1/1 TEST 2 (sequence 1): MCLK    IS NOT RUNNING =====");
      if (smclk_cnt   !== 100) tb_error("====== 1/1/1 TEST 3 (sequence 1): SMCLK   IS NOT RUNNING =====");
      if (aclk_cnt    <   3)   tb_error("====== 1/1/1 TEST 4 (sequence 1): ACLK    IS NOT RUNNING =====");
      if (dco_enable  !== 1)   tb_error("====== 1/1/1 TEST 5 (sequence 1): DCO_ENABLE  IS CLEARED =====");
      if (dco_wkup    !== 0)   tb_error("====== 1/1/1 TEST 6 (sequence 1): DCO_WKUP    IS SET     =====");
      if (lfxt_enable !== 1)   tb_error("====== 1/1/1 TEST 7 (sequence 1): LFXT_ENABLE IS CLEARED =====");
      if (lfxt_wkup   !== 0)   tb_error("====== 1/1/1 TEST 8 (sequence 1): LFXT_WKUP   IS SET     =====");
      if (inst_cnt    === 0)   tb_error("====== 1/1/1 TEST 9 (sequence 1): CPU IS NOT EXECUTING   =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      cpu_en  = 0;
      dbg_en  = 0;
      reset_n = 0;
      #(100*50);

     
      //  ####  CPU_EN=1  ####  DBG_EN=1  ####  RESET_N=1  ####  SEQUENCE 2: RESET_N -> DBG_EN -> CPU_EN
      test_nr = 9;

      reset_n = 1;
      #(150*50);
      dbg_en  = 1;
      #(150*50);
      cpu_en  = 1;

      #(200*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== 1/1/1 TEST 1 (sequence 2): DCO_CLK IS NOT RUNNING =====");
      if (mclk_cnt    !== 100) tb_error("====== 1/1/1 TEST 2 (sequence 2): MCLK    IS NOT RUNNING =====");
      if (smclk_cnt   !== 100) tb_error("====== 1/1/1 TEST 3 (sequence 2): SMCLK   IS NOT RUNNING =====");
      if (aclk_cnt    <   3)   tb_error("====== 1/1/1 TEST 4 (sequence 2): ACLK    IS NOT RUNNING =====");
      if (dco_enable  !== 1)   tb_error("====== 1/1/1 TEST 5 (sequence 2): DCO_ENABLE  IS CLEARED =====");
      if (dco_wkup    !== 0)   tb_error("====== 1/1/1 TEST 6 (sequence 2): DCO_WKUP    IS SET     =====");
      if (lfxt_enable !== 1)   tb_error("====== 1/1/1 TEST 7 (sequence 2): LFXT_ENABLE IS CLEARED =====");
      if (lfxt_wkup   !== 0)   tb_error("====== 1/1/1 TEST 8 (sequence 2): LFXT_WKUP   IS SET     =====");
      if (inst_cnt    !== 0)   tb_error("====== 1/1/1 TEST 9 (sequence 2): CPU IS EXECUTING       =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      cpu_en  = 0;
      dbg_en  = 0;
      reset_n = 0;
      #(100*50);

      //  ####  CPU_EN=1  ####  DBG_EN=1  ####  RESET_N=1  ####  SEQUENCE 3: DBG_EN -> RESET_N -> CPU_EN
      test_nr = 10;

      dbg_en  = 1;
      #(150*50);
      reset_n = 1;
      #(150*50);
      cpu_en  = 1;

      #(200*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== 1/1/1 TEST 1 (sequence 3): DCO_CLK IS NOT RUNNING =====");
      if (mclk_cnt    !== 100) tb_error("====== 1/1/1 TEST 2 (sequence 3): MCLK    IS NOT RUNNING =====");
      if (smclk_cnt   !== 100) tb_error("====== 1/1/1 TEST 3 (sequence 3): SMCLK   IS NOT RUNNING =====");
      if (aclk_cnt    <   3)   tb_error("====== 1/1/1 TEST 4 (sequence 3): ACLK    IS NOT RUNNING =====");
      if (dco_enable  !== 1)   tb_error("====== 1/1/1 TEST 5 (sequence 3): DCO_ENABLE  IS CLEARED =====");
      if (dco_wkup    !== 0)   tb_error("====== 1/1/1 TEST 6 (sequence 3): DCO_WKUP    IS SET     =====");
      if (lfxt_enable !== 1)   tb_error("====== 1/1/1 TEST 7 (sequence 3): LFXT_ENABLE IS CLEARED =====");
      if (lfxt_wkup   !== 0)   tb_error("====== 1/1/1 TEST 8 (sequence 3): LFXT_WKUP   IS SET     =====");
      if (inst_cnt    !== 0)   tb_error("====== 1/1/1 TEST 9 (sequence 3): CPU IS EXECUTING       =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      cpu_en  = 0;
      dbg_en  = 0;
      reset_n = 0;
      #(100*50);


      //  ####  CPU_EN=1  ####  DBG_EN=1  ####  RESET_N=1  ####  SEQUENCE 4: DBG_EN -> CPU_EN -> RESET_N
      test_nr = 10;

      dbg_en  = 1;
      #(150*50);
      cpu_en  = 1;
      #(150*50);
      reset_n = 1;

      #(200*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== 1/1/1 TEST 1 (sequence 4): DCO_CLK IS NOT RUNNING =====");
      if (mclk_cnt    !== 100) tb_error("====== 1/1/1 TEST 2 (sequence 4): MCLK    IS NOT RUNNING =====");
      if (smclk_cnt   !== 100) tb_error("====== 1/1/1 TEST 3 (sequence 4): SMCLK   IS NOT RUNNING =====");
      if (aclk_cnt    <   3)   tb_error("====== 1/1/1 TEST 4 (sequence 4): ACLK    IS NOT RUNNING =====");
      if (dco_enable  !== 1)   tb_error("====== 1/1/1 TEST 5 (sequence 4): DCO_ENABLE  IS CLEARED =====");
      if (dco_wkup    !== 0)   tb_error("====== 1/1/1 TEST 6 (sequence 4): DCO_WKUP    IS SET     =====");
      if (lfxt_enable !== 1)   tb_error("====== 1/1/1 TEST 7 (sequence 4): LFXT_ENABLE IS CLEARED =====");
      if (lfxt_wkup   !== 0)   tb_error("====== 1/1/1 TEST 8 (sequence 4): LFXT_WKUP   IS SET     =====");
      if (inst_cnt    !== 0)   tb_error("====== 1/1/1 TEST 9 (sequence 4): CPU IS EXECUTING       =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      cpu_en  = 0;
      dbg_en  = 0;
      reset_n = 0;
      #(100*50);

      //  ####  CPU_EN=1  ####  DBG_EN=1  ####  RESET_N=1  ####  SEQUENCE 5: CPU_EN -> DBG_EN -> RESET_N
      test_nr = 10;

      cpu_en  = 1;
      #(150*50);
      dbg_en  = 1;
      #(150*50);
      reset_n = 1;

      #(200*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== 1/1/1 TEST 1 (sequence 5): DCO_CLK IS NOT RUNNING =====");
      if (mclk_cnt    !== 100) tb_error("====== 1/1/1 TEST 2 (sequence 5): MCLK    IS NOT RUNNING =====");
      if (smclk_cnt   !== 100) tb_error("====== 1/1/1 TEST 3 (sequence 5): SMCLK   IS NOT RUNNING =====");
      if (aclk_cnt    <   3)   tb_error("====== 1/1/1 TEST 4 (sequence 5): ACLK    IS NOT RUNNING =====");
      if (dco_enable  !== 1)   tb_error("====== 1/1/1 TEST 5 (sequence 5): DCO_ENABLE  IS CLEARED =====");
      if (dco_wkup    !== 0)   tb_error("====== 1/1/1 TEST 6 (sequence 5): DCO_WKUP    IS SET     =====");
      if (lfxt_enable !== 1)   tb_error("====== 1/1/1 TEST 7 (sequence 5): LFXT_ENABLE IS CLEARED =====");
      if (lfxt_wkup   !== 0)   tb_error("====== 1/1/1 TEST 8 (sequence 5): LFXT_WKUP   IS SET     =====");
      if (inst_cnt    !== 0)   tb_error("====== 1/1/1 TEST 9 (sequence 5): CPU IS EXECUTING       =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      cpu_en  = 0;
      dbg_en  = 0;
      reset_n = 0;
      #(100*50);

      //  ####  CPU_EN=1  ####  DBG_EN=1  ####  RESET_N=1  ####  SEQUENCE 6: CPU_EN -> RESET_N -> DBG_EN
      test_nr = 10;

      cpu_en  = 1;
      #(150*50);
      reset_n = 1;
      #(150*50);
      dbg_en  = 1;

      #(200*50);
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;
      #(100*50);
      if (dco_clk_cnt !== 100) tb_error("====== 1/1/1 TEST 1 (sequence 6): DCO_CLK IS NOT RUNNING =====");
      if (mclk_cnt    !== 100) tb_error("====== 1/1/1 TEST 2 (sequence 6): MCLK    IS NOT RUNNING =====");
      if (smclk_cnt   !== 100) tb_error("====== 1/1/1 TEST 3 (sequence 6): SMCLK   IS NOT RUNNING =====");
      if (aclk_cnt    <   3)   tb_error("====== 1/1/1 TEST 4 (sequence 6): ACLK    IS NOT RUNNING =====");
      if (dco_enable  !== 1)   tb_error("====== 1/1/1 TEST 5 (sequence 6): DCO_ENABLE  IS CLEARED =====");
      if (dco_wkup    !== 0)   tb_error("====== 1/1/1 TEST 6 (sequence 6): DCO_WKUP    IS SET     =====");
      if (lfxt_enable !== 1)   tb_error("====== 1/1/1 TEST 7 (sequence 6): LFXT_ENABLE IS CLEARED =====");
      if (lfxt_wkup   !== 0)   tb_error("====== 1/1/1 TEST 8 (sequence 6): LFXT_WKUP   IS SET     =====");
      if (inst_cnt    === 0)   tb_error("====== 1/1/1 TEST 9 (sequence 6): CPU IS NOT EXECUTING   =====");
      dco_clk_cnt  = 0;
      mclk_cnt     = 0;
      smclk_cnt    = 0;
      aclk_cnt     = 0;
      inst_cnt     = 0;

      #(100*50);


      

`else
      $display(" ===============================================");
      $display("|               SIMULATION SKIPPED              |");
      $display("|   (this test is not supported in FPGA mode)   |");
      $display(" ===============================================");
      $finish;
`endif

      stimulus_done = 1;
   end

