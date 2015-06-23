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
/*                                 DIGITAL I/O                               */
/*---------------------------------------------------------------------------*/
/* Test the Digital I/O interface:                                           */
/*                                   - Interrupts.                           */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 111 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2011-05-20 22:39:02 +0200 (Fri, 20 May 2011) $          */
/*===========================================================================*/

integer test_step;

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;
      test_step     = 0;

      // PORT 1: TEST INTERRUPT FLAGS
      //--------------------------------------------------------

      @(r15==(`PER_SIZE+16'h0000)) p1_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0001)) p1_din = 8'h03;
      @(r15==(`PER_SIZE+16'h0002)) p1_din = 8'h07;
      @(r15==(`PER_SIZE+16'h0003)) p1_din = 8'h0f;
      @(r15==(`PER_SIZE+16'h0004)) p1_din = 8'h1f;
      @(r15==(`PER_SIZE+16'h0005)) p1_din = 8'h3f;
      @(r15==(`PER_SIZE+16'h0006)) p1_din = 8'h7f;
      @(r15==(`PER_SIZE+16'h0007)) p1_din = 8'hff;
      @(r15==(`PER_SIZE+16'h0008));
      if (mem200 !== 16'h0201) tb_error("====== RISING EDGE TEST: P1IFG != 0x0201 =====");
      if (mem202 !== 16'h0804) tb_error("====== RISING EDGE TEST: P1IFG != 0x0804 =====");
      if (mem204 !== 16'h2010) tb_error("====== RISING EDGE TEST: P1IFG != 0x2010 =====");
      if (mem206 !== 16'h8040) tb_error("====== RISING EDGE TEST: P1IFG != 0x8040 =====");
      test_step = 1;

      
      @(r15==(`PER_SIZE+16'h0010)) p1_din = 8'h7f;
      @(r15==(`PER_SIZE+16'h0011)) p1_din = 8'h3f;
      @(r15==(`PER_SIZE+16'h0012)) p1_din = 8'h1f;
      @(r15==(`PER_SIZE+16'h0013)) p1_din = 8'h0f;
      @(r15==(`PER_SIZE+16'h0014)) p1_din = 8'h07;
      @(r15==(`PER_SIZE+16'h0015)) p1_din = 8'h03;
      @(r15==(`PER_SIZE+16'h0016)) p1_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0017)) p1_din = 8'h00;
      @(r15==(`PER_SIZE+16'h0018));
      if (mem210 !== 16'h0000) tb_error("====== RISING EDGE TEST: P1IFG != 0x0000 =====");
      if (mem212 !== 16'h0000) tb_error("====== RISING EDGE TEST: P1IFG != 0x0000 =====");
      if (mem214 !== 16'h0000) tb_error("====== RISING EDGE TEST: P1IFG != 0x0000 =====");
      if (mem216 !== 16'h0000) tb_error("====== RISING EDGE TEST: P1IFG != 0x0000 =====");
      test_step = 2;

      
      @(r15==(`PER_SIZE+16'h0020)) p1_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0021)) p1_din = 8'h03;
      @(r15==(`PER_SIZE+16'h0022)) p1_din = 8'h07;
      @(r15==(`PER_SIZE+16'h0023)) p1_din = 8'h0f;
      @(r15==(`PER_SIZE+16'h0024)) p1_din = 8'h1f;
      @(r15==(`PER_SIZE+16'h0025)) p1_din = 8'h3f;
      @(r15==(`PER_SIZE+16'h0026)) p1_din = 8'h7f;
      @(r15==(`PER_SIZE+16'h0027)) p1_din = 8'hff;
      @(r15==(`PER_SIZE+16'h0028));
      if (mem220 !== 16'h0301) tb_error("====== RISING EDGE TEST: P1IFG != 0x0301 =====");
      if (mem222 !== 16'h0f07) tb_error("====== RISING EDGE TEST: P1IFG != 0x0f07 =====");
      if (mem224 !== 16'h3f1f) tb_error("====== RISING EDGE TEST: P1IFG != 0x3f1f =====");
      if (mem226 !== 16'hff7f) tb_error("====== RISING EDGE TEST: P1IFG != 0xff7f =====");
      test_step = 3;

   
      @(r15==(`PER_SIZE+16'h0030)) p1_din = 8'h7f;
      @(r15==(`PER_SIZE+16'h0031)) p1_din = 8'h3f;
      @(r15==(`PER_SIZE+16'h0032)) p1_din = 8'h1f;
      @(r15==(`PER_SIZE+16'h0033)) p1_din = 8'h0f;
      @(r15==(`PER_SIZE+16'h0034)) p1_din = 8'h07;
      @(r15==(`PER_SIZE+16'h0035)) p1_din = 8'h03;
      @(r15==(`PER_SIZE+16'h0036)) p1_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0037)) p1_din = 8'h00;
      @(r15==(`PER_SIZE+16'h0038));
      if (mem230 !== 16'h4080) tb_error("====== FALLING EDGE TEST: P1IFG != 0x4080 =====");
      if (mem232 !== 16'h1020) tb_error("====== FALLING EDGE TEST: P1IFG != 0x1020 =====");
      if (mem234 !== 16'h0408) tb_error("====== FALLING EDGE TEST: P1IFG != 0x0408 =====");
      if (mem236 !== 16'h0102) tb_error("====== FALLING EDGE TEST: P1IFG != 0x0102 =====");
      test_step = 4;

      @(r15==(`PER_SIZE+16'h0040)) p1_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0041)) p1_din = 8'h03;
      @(r15==(`PER_SIZE+16'h0042)) p1_din = 8'h07;
      @(r15==(`PER_SIZE+16'h0043)) p1_din = 8'h0f;
      @(r15==(`PER_SIZE+16'h0044)) p1_din = 8'h1f;
      @(r15==(`PER_SIZE+16'h0045)) p1_din = 8'h3f;
      @(r15==(`PER_SIZE+16'h0046)) p1_din = 8'h7f;
      @(r15==(`PER_SIZE+16'h0047)) p1_din = 8'hff;
      @(r15==(`PER_SIZE+16'h0048));
      if (mem240 !== 16'h0000) tb_error("====== FALLING EDGE TEST: P1IFG != 0x0000 =====");
      if (mem242 !== 16'h0000) tb_error("====== FALLING EDGE TEST: P1IFG != 0x0000 =====");
      if (mem244 !== 16'h0000) tb_error("====== FALLING EDGE TEST: P1IFG != 0x0000 =====");
      if (mem246 !== 16'h0000) tb_error("====== FALLING EDGE TEST: P1IFG != 0x0000 =====");
      test_step = 5;

      @(r15==(`PER_SIZE+16'h0050)) p1_din = 8'h7f;
      @(r15==(`PER_SIZE+16'h0051)) p1_din = 8'h3f;
      @(r15==(`PER_SIZE+16'h0052)) p1_din = 8'h1f;
      @(r15==(`PER_SIZE+16'h0053)) p1_din = 8'h0f;
      @(r15==(`PER_SIZE+16'h0054)) p1_din = 8'h07;
      @(r15==(`PER_SIZE+16'h0055)) p1_din = 8'h03;
      @(r15==(`PER_SIZE+16'h0056)) p1_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0057)) p1_din = 8'h00;
      @(r15==(`PER_SIZE+16'h0058));
      if (mem250 !== 16'hc080) tb_error("====== FALLING EDGE TEST: P1IFG != 0xc080 =====");
      if (mem252 !== 16'hf0e0) tb_error("====== FALLING EDGE TEST: P1IFG != 0xf0e0 =====");
      if (mem254 !== 16'hfcf8) tb_error("====== FALLING EDGE TEST: P1IFG != 0xfcf8 =====");
      if (mem256 !== 16'hfffe) tb_error("====== FALLING EDGE TEST: P1IFG != 0xfffe =====");
      test_step = 6;

      
      // PORT 2: TEST INTERRUPT FLAGS
      //--------------------------------------------------------

      @(r15==(`PER_SIZE+16'h0000)) p2_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0001)) p2_din = 8'h03;
      @(r15==(`PER_SIZE+16'h0002)) p2_din = 8'h07;
      @(r15==(`PER_SIZE+16'h0003)) p2_din = 8'h0f;
      @(r15==(`PER_SIZE+16'h0004)) p2_din = 8'h1f;
      @(r15==(`PER_SIZE+16'h0005)) p2_din = 8'h3f;
      @(r15==(`PER_SIZE+16'h0006)) p2_din = 8'h7f;
      @(r15==(`PER_SIZE+16'h0007)) p2_din = 8'hff;
      @(r15==(`PER_SIZE+16'h0008));
      if (mem200 !== 16'h0201) tb_error("====== RISING EDGE TEST: P2IFG != 0x0201 =====");
      if (mem202 !== 16'h0804) tb_error("====== RISING EDGE TEST: P2IFG != 0x0804 =====");
      if (mem204 !== 16'h2010) tb_error("====== RISING EDGE TEST: P2IFG != 0x2010 =====");
      if (mem206 !== 16'h8040) tb_error("====== RISING EDGE TEST: P2IFG != 0x8040 =====");
      test_step = 7;

      
      @(r15==(`PER_SIZE+16'h0010)) p2_din = 8'h7f;
      @(r15==(`PER_SIZE+16'h0011)) p2_din = 8'h3f;
      @(r15==(`PER_SIZE+16'h0012)) p2_din = 8'h1f;
      @(r15==(`PER_SIZE+16'h0013)) p2_din = 8'h0f;
      @(r15==(`PER_SIZE+16'h0014)) p2_din = 8'h07;
      @(r15==(`PER_SIZE+16'h0015)) p2_din = 8'h03;
      @(r15==(`PER_SIZE+16'h0016)) p2_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0017)) p2_din = 8'h00;
      @(r15==(`PER_SIZE+16'h0018));
      if (mem210 !== 16'h0000) tb_error("====== RISING EDGE TEST: P2IFG != 0x0000 =====");
      if (mem212 !== 16'h0000) tb_error("====== RISING EDGE TEST: P2IFG != 0x0000 =====");
      if (mem214 !== 16'h0000) tb_error("====== RISING EDGE TEST: P2IFG != 0x0000 =====");
      if (mem216 !== 16'h0000) tb_error("====== RISING EDGE TEST: P2IFG != 0x0000 =====");
      test_step = 8;

      
      @(r15==(`PER_SIZE+16'h0020)) p2_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0021)) p2_din = 8'h03;
      @(r15==(`PER_SIZE+16'h0022)) p2_din = 8'h07;
      @(r15==(`PER_SIZE+16'h0023)) p2_din = 8'h0f;
      @(r15==(`PER_SIZE+16'h0024)) p2_din = 8'h1f;
      @(r15==(`PER_SIZE+16'h0025)) p2_din = 8'h3f;
      @(r15==(`PER_SIZE+16'h0026)) p2_din = 8'h7f;
      @(r15==(`PER_SIZE+16'h0027)) p2_din = 8'hff;
      @(r15==(`PER_SIZE+16'h0028));
      if (mem220 !== 16'h0301) tb_error("====== RISING EDGE TEST: P2IFG != 0x0301 =====");
      if (mem222 !== 16'h0f07) tb_error("====== RISING EDGE TEST: P2IFG != 0x0f07 =====");
      if (mem224 !== 16'h3f1f) tb_error("====== RISING EDGE TEST: P2IFG != 0x3f1f =====");
      if (mem226 !== 16'hff7f) tb_error("====== RISING EDGE TEST: P2IFG != 0xff7f =====");
      test_step = 9;

   
      @(r15==(`PER_SIZE+16'h0030)) p2_din = 8'h7f;
      @(r15==(`PER_SIZE+16'h0031)) p2_din = 8'h3f;
      @(r15==(`PER_SIZE+16'h0032)) p2_din = 8'h1f;
      @(r15==(`PER_SIZE+16'h0033)) p2_din = 8'h0f;
      @(r15==(`PER_SIZE+16'h0034)) p2_din = 8'h07;
      @(r15==(`PER_SIZE+16'h0035)) p2_din = 8'h03;
      @(r15==(`PER_SIZE+16'h0036)) p2_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0037)) p2_din = 8'h00;
      @(r15==(`PER_SIZE+16'h0038));
      if (mem230 !== 16'h4080) tb_error("====== FALLING EDGE TEST: P2IFG != 0x4080 =====");
      if (mem232 !== 16'h1020) tb_error("====== FALLING EDGE TEST: P2IFG != 0x1020 =====");
      if (mem234 !== 16'h0408) tb_error("====== FALLING EDGE TEST: P2IFG != 0x0408 =====");
      if (mem236 !== 16'h0102) tb_error("====== FALLING EDGE TEST: P2IFG != 0x0102 =====");
      test_step = 10;

      @(r15==(`PER_SIZE+16'h0040)) p2_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0041)) p2_din = 8'h03;
      @(r15==(`PER_SIZE+16'h0042)) p2_din = 8'h07;
      @(r15==(`PER_SIZE+16'h0043)) p2_din = 8'h0f;
      @(r15==(`PER_SIZE+16'h0044)) p2_din = 8'h1f;
      @(r15==(`PER_SIZE+16'h0045)) p2_din = 8'h3f;
      @(r15==(`PER_SIZE+16'h0046)) p2_din = 8'h7f;
      @(r15==(`PER_SIZE+16'h0047)) p2_din = 8'hff;
      @(r15==(`PER_SIZE+16'h0048));
      if (mem240 !== 16'h0000) tb_error("====== FALLING EDGE TEST: P2IFG != 0x0000 =====");
      if (mem242 !== 16'h0000) tb_error("====== FALLING EDGE TEST: P2IFG != 0x0000 =====");
      if (mem244 !== 16'h0000) tb_error("====== FALLING EDGE TEST: P2IFG != 0x0000 =====");
      if (mem246 !== 16'h0000) tb_error("====== FALLING EDGE TEST: P2IFG != 0x0000 =====");
      test_step = 11;

      @(r15==(`PER_SIZE+16'h0050)) p2_din = 8'h7f;
      @(r15==(`PER_SIZE+16'h0051)) p2_din = 8'h3f;
      @(r15==(`PER_SIZE+16'h0052)) p2_din = 8'h1f;
      @(r15==(`PER_SIZE+16'h0053)) p2_din = 8'h0f;
      @(r15==(`PER_SIZE+16'h0054)) p2_din = 8'h07;
      @(r15==(`PER_SIZE+16'h0055)) p2_din = 8'h03;
      @(r15==(`PER_SIZE+16'h0056)) p2_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0057)) p2_din = 8'h00;
      @(r15==(`PER_SIZE+16'h0058));
      if (mem250 !== 16'hc080) tb_error("====== FALLING EDGE TEST: P2IFG != 0xc080 =====");
      if (mem252 !== 16'hf0e0) tb_error("====== FALLING EDGE TEST: P2IFG != 0xf0e0 =====");
      if (mem254 !== 16'hfcf8) tb_error("====== FALLING EDGE TEST: P2IFG != 0xfcf8 =====");
      if (mem256 !== 16'hfffe) tb_error("====== FALLING EDGE TEST: P2IFG != 0xfffe =====");
      test_step = 12;

      
      // PORT 1: TEST INTERRUPT VECTOR
      //--------------------------------------------------------

      @(r15==(`PER_SIZE+16'h0008));
      if (mem200 !== 16'h0201) tb_error("====== INTERRUPT VECTOR TEST: P1IFG != 0x0201 =====");
      if (mem202 !== 16'h0804) tb_error("====== INTERRUPT VECTOR TEST: P1IFG != 0x0804 =====");
      if (mem204 !== 16'h2010) tb_error("====== INTERRUPT VECTOR TEST: P1IFG != 0x2010 =====");
      if (mem206 !== 16'h8040) tb_error("====== INTERRUPT VECTOR TEST: P1IFG != 0x8040 =====");
      test_step = 13;

      
      // PORT 2: TEST INTERRUPT VECTOR
      //--------------------------------------------------------

      @(r15==(`PER_SIZE+16'h0018));
      if (mem210 !== 16'h0201) tb_error("====== INTERRUPT VECTOR TEST: P1IFG != 0x0201 =====");
      if (mem212 !== 16'h0804) tb_error("====== INTERRUPT VECTOR TEST: P1IFG != 0x0804 =====");
      if (mem214 !== 16'h2010) tb_error("====== INTERRUPT VECTOR TEST: P1IFG != 0x2010 =====");
      if (mem216 !== 16'h8040) tb_error("====== INTERRUPT VECTOR TEST: P1IFG != 0x8040 =====");
      test_step = 14;


      stimulus_done = 1;
   end

