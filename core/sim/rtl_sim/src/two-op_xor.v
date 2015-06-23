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
/*                 TWO-OPERAND ARITHMETIC: XOR[.B] INSTRUCTION               */
/*---------------------------------------------------------------------------*/
/* Test the XOR[.B] instruction.                                             */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 19 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2009-08-04 23:47:15 +0200 (Tue, 04 Aug 2009) $          */
/*===========================================================================*/

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;


      // XOR (WORD MODE)
      //--------------------------------------------------------
      @(r15==16'h1000);

      if (r5    !==16'hbbbb) tb_error("====== XOR Test =====");
      if (r6    !==16'hcccc) tb_error("====== XOR Test =====");


      // XOR.B (BYTE MODE)
      //--------------------------------------------------------
      @(r15==16'h2000);

      if (r5    !==16'h00bb) tb_error("====== XOR.B Test =====");
      if (r6    !==16'h00cc) tb_error("====== XOR.B Test =====");


      // XOR (WORD MODE): Check Flags
      //--------------------------------------------------------

      @(r15==16'h3000);
      if (r2    !==16'h0001) tb_error("====== XOR FLAG: Flag   check error: V=0, N=0, Z=0, C=1 =====");
      if (r5    !==16'h0ccc) tb_error("====== XOR FLAG: Result check error: V=0, N=0, Z=0, C=1 =====");

      @(r15==16'h3001);
      if (r2    !==16'h0002) tb_error("====== XOR FLAG: Flag   check error: V=0, N=0, Z=1, C=0 =====");
      if (r5    !==16'h0000) tb_error("====== XOR FLAG: Result check error: V=0, N=0, Z=1, C=0 =====");

      @(r15==16'h3002);
      if (r2    !==16'h0005) tb_error("====== XOR FLAG: Flag   check error: V=0, N=1, Z=0, C=1 =====");
      if (r5    !==16'h8ccc) tb_error("====== XOR FLAG: Result check error: V=0, N=1, Z=0, C=1 =====");

      @(r15==16'h3003);
      if (r2    !==16'h0101) tb_error("====== XOR FLAG: Flag   check error: V=1, N=0, Z=0, C=1 =====");
      if (r5    !==16'h0ccc) tb_error("====== XOR FLAG: Result check error: V=1, N=0, Z=0, C=1 =====");

      @(r15==16'h3004);
      if (r2    !==16'h0102) tb_error("====== XOR FLAG: Flag   check error: V=1, N=0, Z=1, C=0 =====");
      if (r5    !==16'h0000) tb_error("====== XOR FLAG: Result check error: V=1, N=0, Z=1, C=0 =====");


      // XOR.B (BYTE MODE): Check Flags
      //--------------------------------------------------------

      @(r15==16'h4000);
      if (r2    !==16'h0001) tb_error("====== XOR FLAG: Flag   check error: V=0, N=0, Z=0, C=1 =====");
      if (r5    !==16'h000c) tb_error("====== XOR FLAG: Result check error: V=0, N=0, Z=0, C=1 =====");

      @(r15==16'h4001);
      if (r2    !==16'h0002) tb_error("====== XOR FLAG: Flag   check error: V=0, N=0, Z=1, C=0 =====");
      if (r5    !==16'h0000) tb_error("====== XOR FLAG: Result check error: V=0, N=0, Z=1, C=0 =====");

      @(r15==16'h4002);
      if (r2    !==16'h0005) tb_error("====== XOR FLAG: Flag   check error: V=0, N=1, Z=0, C=1 =====");
      if (r5    !==16'h008c) tb_error("====== XOR FLAG: Result check error: V=0, N=1, Z=0, C=1 =====");

      @(r15==16'h4003);
      if (r2    !==16'h0101) tb_error("====== XOR FLAG: Flag   check error: V=1, N=0, Z=0, C=1 =====");
      if (r5    !==16'h000c) tb_error("====== XOR FLAG: Result check error: V=1, N=0, Z=0, C=1 =====");

      @(r15==16'h4004);
      if (r2    !==16'h0102) tb_error("====== XOR FLAG: Flag   check error: V=1, N=0, Z=1, C=0 =====");
      if (r5    !==16'h0000) tb_error("====== XOR FLAG: Result check error: V=1, N=0, Z=1, C=0 =====");


      stimulus_done = 1;
   end

