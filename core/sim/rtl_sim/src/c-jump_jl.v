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
/*                 CONDITIONAL JUMP: JL INSTRUCTION                          */
/*---------------------------------------------------------------------------*/
/* Test the JL instruction.                                                  */
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


      // TEST JUMP FORWARD AND BACKWARD
      @(r15==16'h1000);
      if (r4    !==16'h1234) tb_error("====== JL (jump forward 1) =====");
      if (r5    !==16'h5678) tb_error("====== JL (jump backward) =====");
      if (r6    !==16'h9abc) tb_error("====== JL (jump forward 2) =====");

      // TEST JUMP FOR ALL FLAG CONFIGURATIONS
      @(r15==16'h2000);
      if (r4    !==16'h0000) tb_error("====== JL ({V,N,Z,C}=4'b0000) ==");
      @(r15==16'h2001);
      if (r4    !==16'h0000) tb_error("====== JL ({V,N,Z,C}=4'b0001) ==");
      @(r15==16'h2002);
      if (r4    !==16'h0000) tb_error("====== JL ({V,N,Z,C}=4'b0010) ==");
      @(r15==16'h2003);
      if (r4    !==16'h0000) tb_error("====== JL ({V,N,Z,C}=4'b0011) ==");
      @(r15==16'h2004);
      if (r4    !==16'h1234) tb_error("====== JL ({V,N,Z,C}=4'b0100) ==");
      @(r15==16'h2005);
      if (r4    !==16'h1234) tb_error("====== JL ({V,N,Z,C}=4'b0101) ==");
      @(r15==16'h2006);
      if (r4    !==16'h1234) tb_error("====== JL ({V,N,Z,C}=4'b0110) ==");
      @(r15==16'h2007);
      if (r4    !==16'h1234) tb_error("====== JL ({V,N,Z,C}=4'b0111) ==");
      @(r15==16'h2008);
      if (r4    !==16'h1234) tb_error("====== JL ({V,N,Z,C}=4'b1000) ==");
      @(r15==16'h2009);
      if (r4    !==16'h1234) tb_error("====== JL ({V,N,Z,C}=4'b1001) ==");
      @(r15==16'h200A);
      if (r4    !==16'h1234) tb_error("====== JL ({V,N,Z,C}=4'b1010) ==");
      @(r15==16'h200B);
      if (r4    !==16'h1234) tb_error("====== JL ({V,N,Z,C}=4'b1011) ==");
      @(r15==16'h200C);
      if (r4    !==16'h0000) tb_error("====== JL ({V,N,Z,C}=4'b1100) ==");
      @(r15==16'h200D);
      if (r4    !==16'h0000) tb_error("====== JL ({V,N,Z,C}=4'b1101) ==");
      @(r15==16'h200E);
      if (r4    !==16'h0000) tb_error("====== JL ({V,N,Z,C}=4'b1110) ==");
      @(r15==16'h200F);
      if (r4    !==16'h0000) tb_error("====== JL ({V,N,Z,C}=4'b1111) ==");

      
      stimulus_done = 1;
   end

