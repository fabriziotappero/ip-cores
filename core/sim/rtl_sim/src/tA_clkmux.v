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
/*                                  TIMER A                                  */
/*---------------------------------------------------------------------------*/
/* Test the timer A:                                                         */
/*                        - Check the timer clock input mux.                 */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 180 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2013-02-25 22:23:18 +0100 (Mon, 25 Feb 2013) $          */
/*===========================================================================*/

integer my_counter;
always @ (negedge mclk)
  my_counter <=  my_counter+1;

wire [15:0] tar = timerA_0.tar;

// Generate TACLK as MCLK/3
integer taclk_cnt;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)           taclk_cnt <=  0;
  else if (taclk_cnt==2) taclk_cnt <=  0;
  else                   taclk_cnt <=  taclk_cnt+1;

always @ (taclk_cnt)
  if (taclk_cnt==2) taclk = 1'b1;
  else              taclk = 1'b0;

// Generate INCLK as MCLK/5
integer inclk_cnt;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)           inclk_cnt <=  0;
  else if (inclk_cnt==4) inclk_cnt <=  0;
  else                   inclk_cnt <=  inclk_cnt+1;

always @ (inclk_cnt)
  if (inclk_cnt==4) inclk = 1'b1;
  else              inclk = 1'b0;

   
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

      // TIMER A TEST:  INPUT MUX - TACLK
      //--------------------------------------------------------
//      @(r15 === 16'h0000);

      @(r15 === 16'h0001);
      @(tar === 1);
      my_counter = 0;
      repeat(300) @(posedge mclk);
      if (tar !== 16'h0032) tb_error("====== TIMER A TEST:  INPUT MUX - TACLK =====");

      
      // TIMER A TEST:  INPUT MUX - ACLK
      //--------------------------------------------------------
      @(r15 === 16'h1000);

      @(r15 === 16'h1001);
      @(tar === 1);
      my_counter = 0;
      repeat(300) @(posedge mclk);
      if (tar !== 16'h0005) tb_error("====== TIMER A TEST:  INPUT MUX - ACLK =====");

      
      // TIMER A TEST:  INPUT MUX - SMCLK
      //--------------------------------------------------------
      @(r15 === 16'h2000);

      @(r15 === 16'h2001);
      @(tar === 1);
      my_counter = 0;
      repeat(300) @(posedge mclk);
      if (tar !== 16'h0013) tb_error("====== TIMER A TEST:  INPUT MUX - SMCLK =====");

      
      // TIMER A TEST:  INPUT MUX - INCLK
      //--------------------------------------------------------
      @(r15 === 16'h3000);

      @(r15 === 16'h3001);
      @(tar === 1);
      my_counter = 0;
      repeat(300) @(posedge mclk);
      if (tar !== 16'h001E) tb_error("====== TIMER A TEST:  INPUT MUX - INCLK =====");

`endif    

      stimulus_done = 1;
   end

