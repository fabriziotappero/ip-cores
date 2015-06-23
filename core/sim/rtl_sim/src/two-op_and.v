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
/*                 TWO-OPERAND ARITHMETIC: AND[.B] INSTRUCTION               */
/*---------------------------------------------------------------------------*/
/* Test the AND[.B] instruction.                                             */
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


      // AND (WORD MODE)
      //--------------------------------------------------------
      @(r15==16'h1000);

      if (r5    !==16'h1111) tb_error("====== AND Test =====");
      if (r6    !==16'h4444) tb_error("====== AND Test =====");


      // AND.B (BYTE MODE)
      //--------------------------------------------------------
      @(r15==16'h2000);

      if (r5    !==16'h0011) tb_error("====== AND.B Test =====");
      if (r6    !==16'h0044) tb_error("====== AND.B Test =====");


      // AND (WORD MODE): Check Flags
      //--------------------------------------------------------

      @(r15==16'h3000);
      if (r2    !==16'h0001) tb_error("====== AND FLAG: Flag   check error: V=0, N=0, Z=0, C=1 =====");
      if (r5    !==16'h0111) tb_error("====== AND FLAG: Result check error: V=0, N=0, Z=0, C=1 =====");

      @(r15==16'h3001);
      if (r2    !==16'h0002) tb_error("====== AND FLAG: Flag   check error: V=0, N=0, Z=1, C=0 =====");
      if (r5    !==16'h0000) tb_error("====== AND FLAG: Result check error: V=0, N=0, Z=1, C=0 =====");

      @(r15==16'h3002);
      if (r2    !==16'h0005) tb_error("====== AND FLAG: Flag   check error: V=0, N=1, Z=0, C=1 =====");
      if (r5    !==16'h8111) tb_error("====== AND FLAG: Result check error: V=0, N=1, Z=0, C=1 =====");


      // AND.B (BYTE MODE): Check Flags
      //--------------------------------------------------------

      @(r15==16'h4000);
      if (r2    !==16'h0001) tb_error("====== AND.B FLAG: Flag   check error: V=0, N=0, Z=0, C=1 =====");
      if (r5    !==16'h0001) tb_error("====== AND.B FLAG: Result check error: V=0, N=0, Z=0, C=1 =====");

      @(r15==16'h4001);
      if (r2    !==16'h0002) tb_error("====== AND.B FLAG: Flag   check error: V=0, N=0, Z=1, C=0 =====");
      if (r5    !==16'h0000) tb_error("====== AND.B FLAG: Result check error: V=0, N=0, Z=1, C=0 =====");

      @(r15==16'h4002);
      if (r2    !==16'h0005) tb_error("====== AND.B FLAG: Flag   check error: V=0, N=1, Z=0, C=1 =====");
      if (r5    !==16'h0081) tb_error("====== AND.B FLAG: Result check error: V=0, N=1, Z=0, C=1 =====");


      stimulus_done = 1;
   end

