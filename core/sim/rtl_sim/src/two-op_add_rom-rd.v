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
/*                     ADD:   DATA READ ACCESS FROM ROM                      */
/*---------------------------------------------------------------------------*/
/* Test the ADD instruction with all addressing modes making a read access   */
/* to the ROM.                                                               */
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


      // Check when source is @Rn
      //--------------------------------------------------------
      @(r15==16'h1000);

      if (r5     !==16'h7777) tb_error("====== ROM Read: ADD @Rn Rm    =====");
      if (r4     ===16'h0000) tb_error("====== ROM Read: ADD @Rn PC    =====");
      if (mem210 !==16'h6666) tb_error("====== ROM Read: ADD @Rn x(Rm) =====");
      if (mem212 !==16'hed2e) tb_error("====== ROM Read: ADD @Rn EDE   =====");
      if (mem214 !==16'h4653) tb_error("====== ROM Read: ADD @Rn &EDE  =====");
      

      // Check when source is @Rn+
      //--------------------------------------------------------
      @(r15==16'h2000);

      if (r5     !==16'hdddd) tb_error("====== ROM Read: ADD @Rn+ Rm    =====");
      if (r7     !==16'haaaa) tb_error("====== ROM Read: ADD @Rn+ PC    =====");
      if (mem210 !==16'h89ab) tb_error("====== ROM Read: ADD @Rn+ x(Rm) =====");
      if (mem212 !==16'h5073) tb_error("====== ROM Read: ADD @Rn+ EDE   =====");
      if (mem214 !==16'h5776) tb_error("====== ROM Read: ADD @Rn+ &EDE  =====");


      // Check when source is x(Rn)
      //--------------------------------------------------------
      @(r15==16'h3000);

      if (r5     !==16'h957b) tb_error("====== ROM Read: ADD x(Rn) Rm    =====");
      if (r6     ===16'h0000) tb_error("====== ROM Read: ADD x(Rn) PC    =====");
      if (mem214 !==16'h5776) tb_error("====== ROM Read: ADD x(Rn) x(Rm) =====");
      if (mem220 !==16'h937b) tb_error("====== ROM Read: ADD x(Rn) EDE   =====");
      if (mem208 !==16'hace4) tb_error("====== ROM Read: ADD x(Rn) &EDE  =====");


      // Check when source is EDE
      //--------------------------------------------------------
      @(r15==16'h4000);

      if (r4     !==16'h06f7) tb_error("====== ROM Read: ADD EDE Rm    =====");
      if (r6     ===16'h0000) tb_error("====== ROM Read: ADD EDE PC    =====");
      if (mem214 !==16'h0946) tb_error("====== ROM Read: ADD EDE x(Rm) =====");
      if (mem216 !==16'hb933) tb_error("====== ROM Read: ADD EDE EDE   =====");
      if (mem212 !==16'h2ab2) tb_error("====== ROM Read: ADD EDE &EDE  =====");


      // Check when source is &EDE
      //--------------------------------------------------------
      @(r15==16'h5000);

      if (r4     !==16'h66f5) tb_error("====== ROM Read: ADD &EDE Rm    =====");
      if (r6     ===16'h0000) tb_error("====== ROM Read: ADD &EDE PC    =====");
      if (mem214 !==16'h82d1) tb_error("====== ROM Read: ADD &EDE x(Rm) =====");
      if (mem218 !==16'hca4e) tb_error("====== ROM Read: ADD &EDE EDE   =====");
      if (mem202 !==16'h1338) tb_error("====== ROM Read: ADD &EDE &EDE  =====");


      stimulus_done = 1;
   end

