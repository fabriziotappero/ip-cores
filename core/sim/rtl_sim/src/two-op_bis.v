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
/*                 TWO-OPERAND ARITHMETIC: BIS[.B] INSTRUCTION               */
/*---------------------------------------------------------------------------*/
/* Test the BIS[.B] instruction.                                             */
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


      // BIS (WORD MODE)
      //--------------------------------------------------------
      @(r15==16'h1000);

      if (r5    !==16'hbbbb) tb_error("====== BIS Test =====");
      if (r6    !==16'hdddd) tb_error("====== BIS Test =====");


      // BIS.B (BYTE MODE)
      //--------------------------------------------------------
      @(r15==16'h2000);

      if (r5    !==16'h0055) tb_error("====== BIS.B Test =====");
      if (r6    !==16'h00aa) tb_error("====== BIS.B Test =====");


      // BIS (WORD MODE): Check Flags
      //--------------------------------------------------------

      @(r15==16'h3000);
      if (r2    !==16'h0005) tb_error("====== BIS FLAG: Flag   check error =====");
      if (r5    !==16'h0eee) tb_error("====== BIS FLAG: Result check error =====");

      @(r15==16'h3001);
      if (r2    !==16'h0102) tb_error("====== BIS FLAG: Flag   check error =====");
      if (r5    !==16'h0eee) tb_error("====== BIS FLAG: Result check error =====");


      // BIS.B (BYTE MODE): Check Flags
      //--------------------------------------------------------

      @(r15==16'h4000);
      if (r2    !==16'h0005) tb_error("====== BIS.B FLAG: Flag   check error =====");
      if (r5    !==16'h000e) tb_error("====== BIS.B FLAG: Result check error =====");

      @(r15==16'h4001);
      if (r2    !==16'h0102) tb_error("====== BIS.B FLAG: Flag   check error =====");
      if (r5    !==16'h000e) tb_error("====== BIS.B FLAG: Result check error =====");


      stimulus_done = 1;
   end

