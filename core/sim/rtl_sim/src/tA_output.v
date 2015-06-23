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
/*                        - Check the timer output unit.                     */
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
always @ (posedge mclk)
  my_counter <=  my_counter+1;

wire [15:0] tar = timerA_0.tar;
   
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

      // TIMER A TEST:  COMPARATOR 0
      //--------------------------------------------------------

	                        // --------- Output       (mode 0) ----------
      @(mem200 === 16'h0001);
      if (ta_out0 !== 1'b1) tb_error("====== TIMER_A COMPARE 0: Output (mode 0) =====");
      @(mem200 === 16'h0002);
      if (ta_out0 !== 1'b0) tb_error("====== TIMER_A COMPARE 0: Output (mode 0) =====");

      
 	                        // --------- Set          (mode 1) ----------
      @(mem200 === 16'h0003);
      @(tar === 16'h0014);
      if (ta_out0 !== 1'b0) tb_error("====== TIMER_A COMPARE 0: Set (mode 1) =====");
      @(tar === 16'h0015);
      if (ta_out0 !== 1'b1) tb_error("====== TIMER_A COMPARE 0: Set (mode 1) =====");
      @(tar === 16'h0014);
      if (ta_out0 !== 1'b1) tb_error("====== TIMER_A COMPARE 0: Set (mode 1) =====");
      @(tar === 16'h0015);
      if (ta_out0 !== 1'b1) tb_error("====== TIMER_A COMPARE 0: Set (mode 1) =====");
      @(mem200 === 16'h0004);
      if (ta_out0 !== 1'b0) tb_error("====== TIMER_A COMPARE 0: Set (mode 1) =====");

      
 	                        // --------- Toggle       (mode 4) ----------
      @(mem200 === 16'h0005);
      @(tar === 16'h0014);
      if (ta_out0 !== 1'b0) tb_error("====== TIMER_A COMPARE 0: Toggle (mode 4) =====");
      @(tar === 16'h0015);
      if (ta_out0 !== 1'b1) tb_error("====== TIMER_A COMPARE 0: Toggle (mode 4) =====");
      @(tar === 16'h0014);
      if (ta_out0 !== 1'b1) tb_error("====== TIMER_A COMPARE 0: Toggle (mode 4) =====");
      @(tar === 16'h0015);
      if (ta_out0 !== 1'b0) tb_error("====== TIMER_A COMPARE 0: Toggle (mode 4) =====");

      
 	                        // --------- Reset        (mode 5) ----------
      @(mem200 === 16'h0006);
      @(tar === 16'h0014);
      if (ta_out0 !== 1'b1) tb_error("====== TIMER_A COMPARE 0: Reset (mode 5) =====");
      @(tar === 16'h0015);
      if (ta_out0 !== 1'b0) tb_error("====== TIMER_A COMPARE 0: Reset (mode 5) =====");
      @(tar === 16'h0014);
      if (ta_out0 !== 1'b0) tb_error("====== TIMER_A COMPARE 0: Reset (mode 5) =====");
      @(tar === 16'h0015);
      if (ta_out0 !== 1'b0) tb_error("====== TIMER_A COMPARE 0: Reset (mode 5) =====");

      
      // TIMER A TEST:  COMPARATOR 1
      //--------------------------------------------------------
      @(r15 === 16'h1000);

	                        // --------- Output       (mode 0) ----------
      @(mem200 === 16'h0001);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Output (mode 0) =====");
      @(mem200 === 16'h0002);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Output (mode 0) =====");

      
 	                        // --------- Set          (mode 1) ----------
      @(mem200 === 16'h0003);
      @(tar === 16'h0014);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Set (mode 1) =====");
      @(tar === 16'h0015);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Set (mode 1) =====");
      @(tar === 16'h0014);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Set (mode 1) =====");
      @(tar === 16'h0015);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Set (mode 1) =====");
      @(mem200 === 16'h0004);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Set (mode 1) =====");


 	                        // --------- Toggle/Reset (mode 2) ----------
      @(mem200 === 16'h0005);
      @(tar === 16'h0014);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Toggle/Reset (mode 2) =====");
      @(tar === 16'h0015);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Toggle/Reset (mode 2) =====");
      @(tar === 16'h001f);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Toggle/Reset (mode 2) =====");
      @(tar === 16'h0020);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Toggle/Reset (mode 2) =====");

      @(mem200 === 16'h0006);
      @(tar === 16'h0014);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Toggle/Reset (mode 2) =====");
      @(tar === 16'h0015);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Toggle/Reset (mode 2) =====");
      @(tar === 16'h001f);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Toggle/Reset (mode 2) =====");
      @(tar === 16'h0020);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Toggle/Reset (mode 2) =====");

      
 	                        // --------- Set/Reset (mode 3) ----------
      @(mem200 === 16'h0007);
      @(tar === 16'h0014);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Set/Reset (mode 3) =====");
      @(tar === 16'h0015);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Set/Reset (mode 3) =====");
      @(tar === 16'h001f);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Set/Reset (mode 3) =====");
      @(tar === 16'h0020);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Set/Reset (mode 3) =====");

      @(mem200 === 16'h0008);
      @(tar === 16'h0014);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Set/Reset (mode 3) =====");
      @(tar === 16'h0015);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Set/Reset (mode 3) =====");
      @(tar === 16'h001f);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Set/Reset (mode 3) =====");
      @(tar === 16'h0020);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Set/Reset (mode 3) =====");

      
 	                        // --------- Toggle (mode 4) ----------
      @(mem200 === 16'h0009);
      @(tar === 16'h0014);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Toggle (mode 4) =====");
      @(tar === 16'h0015);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Toggle (mode 4) =====");
      @(tar === 16'h0014);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Toggle (mode 4) =====");
      @(tar === 16'h0015);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Toggle (mode 4) =====");

   
 	                        // --------- Reset  (mode 5) ----------
      @(mem200 === 16'h000A);
      @(tar === 16'h0014);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Reset (mode 5) =====");
      @(tar === 16'h0015);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Reset (mode 5) =====");
      @(tar === 16'h0014);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Reset (mode 5) =====");
      @(tar === 16'h0015);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Reset (mode 5) =====");

      
 	                        // --------- Toggle/Set (mode 6) ----------
      @(mem200 === 16'h000B);
      @(tar === 16'h0014);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Toggle/Set (mode 6) =====");
      @(tar === 16'h0015);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Toggle/Set (mode 6) =====");
      @(tar === 16'h001f);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Toggle/Set (mode 6) =====");
      @(tar === 16'h0020);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Toggle/Set (mode 6) =====");

      @(mem200 === 16'h000C);
      @(tar === 16'h0014);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Toggle/Set (mode 6) =====");
      @(tar === 16'h0015);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Toggle/Set (mode 6) =====");
      @(tar === 16'h001f);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Toggle/Set (mode 6) =====");
      @(tar === 16'h0020);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Toggle/Set (mode 6) =====");

      
 	                        // --------- Reset/Set (mode 7) ----------
      @(mem200 === 16'h000D);
      @(tar === 16'h0014);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Reset/Set (mode 7) =====");
      @(tar === 16'h0015);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Reset/Set (mode 7) =====");
      @(tar === 16'h001f);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Reset/Set (mode 7) =====");
      @(tar === 16'h0020);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Reset/Set (mode 7) =====");

      @(mem200 === 16'h000E);
      @(tar === 16'h0014);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Reset/Set (mode 7) =====");
      @(tar === 16'h0015);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Reset/Set (mode 7) =====");
      @(tar === 16'h001f);
      if (ta_out1 !== 1'b0) tb_error("====== TIMER_A COMPARE 1: Reset/Set (mode 7) =====");
      @(tar === 16'h0020);
      if (ta_out1 !== 1'b1) tb_error("====== TIMER_A COMPARE 1: Reset/Set (mode 7) =====");

      
      // TIMER A TEST:  COMPARATOR 2
      //--------------------------------------------------------
      @(r15 === 16'h2000);

	                        // --------- Output       (mode 0) ----------
      @(mem200 === 16'h0001);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Output (mode 0) =====");
      @(mem200 === 16'h0002);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Output (mode 0) =====");


 	                        // --------- Set          (mode 1) ----------
      @(mem200 === 16'h0003);
      @(tar === 16'h0014);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Set (mode 1) =====");
      @(tar === 16'h0015);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Set (mode 1) =====");
      @(tar === 16'h0014);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Set (mode 1) =====");
      @(tar === 16'h0015);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Set (mode 1) =====");
      @(mem200 === 16'h0004);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Set (mode 1) =====");


 	                        // --------- Toggle/Reset (mode 2) ----------
      @(mem200 === 16'h0005);
      @(tar === 16'h0014);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Toggle/Reset (mode 2) =====");
      @(tar === 16'h0015);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Toggle/Reset (mode 2) =====");
      @(tar === 16'h001f);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Toggle/Reset (mode 2) =====");
      @(tar === 16'h0020);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Toggle/Reset (mode 2) =====");

      @(mem200 === 16'h0006);
      @(tar === 16'h0014);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Toggle/Reset (mode 2) =====");
      @(tar === 16'h0015);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Toggle/Reset (mode 2) =====");
      @(tar === 16'h001f);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Toggle/Reset (mode 2) =====");
      @(tar === 16'h0020);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Toggle/Reset (mode 2) =====");

      
 	                        // --------- Set/Reset (mode 3) ----------
      @(mem200 === 16'h0007);
      @(tar === 16'h0014);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Set/Reset (mode 3) =====");
      @(tar === 16'h0015);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Set/Reset (mode 3) =====");
      @(tar === 16'h001f);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Set/Reset (mode 3) =====");
      @(tar === 16'h0020);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Set/Reset (mode 3) =====");

      @(mem200 === 16'h0008);
      @(tar === 16'h0014);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Set/Reset (mode 3) =====");
      @(tar === 16'h0015);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Set/Reset (mode 3) =====");
      @(tar === 16'h001f);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Set/Reset (mode 3) =====");
      @(tar === 16'h0020);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Set/Reset (mode 3) =====");

      
 	                        // --------- Toggle (mode 4) ----------
      @(mem200 === 16'h0009);
      @(tar === 16'h0014);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Toggle (mode 4) =====");
      @(tar === 16'h0015);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Toggle (mode 4) =====");
      @(tar === 16'h0014);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Toggle (mode 4) =====");
      @(tar === 16'h0015);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Toggle (mode 4) =====");

   
 	                        // --------- Reset  (mode 5) ----------
      @(mem200 === 16'h000A);
      @(tar === 16'h0014);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Reset (mode 5) =====");
      @(tar === 16'h0015);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Reset (mode 5) =====");
      @(tar === 16'h0014);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Reset (mode 5) =====");
      @(tar === 16'h0015);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Reset (mode 5) =====");

      
 	                        // --------- Toggle/Set (mode 6) ----------
      @(mem200 === 16'h000B);
      @(tar === 16'h0014);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Toggle/Set (mode 6) =====");
      @(tar === 16'h0015);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Toggle/Set (mode 6) =====");
      @(tar === 16'h001f);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Toggle/Set (mode 6) =====");
      @(tar === 16'h0020);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Toggle/Set (mode 6) =====");

      @(mem200 === 16'h000C);
      @(tar === 16'h0014);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Toggle/Set (mode 6) =====");
      @(tar === 16'h0015);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Toggle/Set (mode 6) =====");
      @(tar === 16'h001f);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Toggle/Set (mode 6) =====");
      @(tar === 16'h0020);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Toggle/Set (mode 6) =====");

      
 	                        // --------- Reset/Set (mode 7) ----------
      @(mem200 === 16'h000D);
      @(tar === 16'h0014);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Reset/Set (mode 7) =====");
      @(tar === 16'h0015);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Reset/Set (mode 7) =====");
      @(tar === 16'h001f);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Reset/Set (mode 7) =====");
      @(tar === 16'h0020);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Reset/Set (mode 7) =====");

      @(mem200 === 16'h000E);
      @(tar === 16'h0014);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Reset/Set (mode 7) =====");
      @(tar === 16'h0015);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Reset/Set (mode 7) =====");
      @(tar === 16'h001f);
      if (ta_out2 !== 1'b0) tb_error("====== TIMER_A COMPARE 2: Reset/Set (mode 7) =====");
      @(tar === 16'h0020);
      if (ta_out2 !== 1'b1) tb_error("====== TIMER_A COMPARE 2: Reset/Set (mode 7) =====");

`endif

      stimulus_done = 1;
   end

