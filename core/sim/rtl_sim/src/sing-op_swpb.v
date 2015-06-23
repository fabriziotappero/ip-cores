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
/*                 SINGLE-OPERAND ARITHMETIC: SWPB INSTRUCTION               */
/*---------------------------------------------------------------------------*/
/* Test the SWPB instruction.                                                */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 111 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2011-05-20 22:39:02 +0200 (Fri, 20 May 2011) $          */
/*===========================================================================*/

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;


      // Addressing mode: Rn
      @(r15==16'h1000);
      if (r4     !==16'h2475) tb_error("====== SWPB (Rn mode): test 1 (result) =====");
      if (r5     !==16'h0102) tb_error("====== SWPB (Rn mode): test 1 (C flag) =====");

      if (r6     !==16'hb61c) tb_error("====== SWPB (Rn mode): test 2 (result) =====");
      if (r7     !==16'h0005) tb_error("====== SWPB (Rn mode): test 2 (C flag) =====");


      // Addressing mode: @Rn
      @(r15==16'h2000);
      if (mem200 !==16'h2475)             tb_error("====== SWPB (@Rn mode): test 1 (result)  =====");
      if (r4     !==(`PER_SIZE+16'h0000)) tb_error("====== SWPB (@Rn mode): test 1 (address) =====");
      if (r5     !==16'h0102)             tb_error("====== SWPB (@Rn mode): test 1 (C flag)  =====");

      if (mem202 !==16'hb61c)             tb_error("====== SWPB (@Rn mode): test 2 (result)  =====");
      if (r6     !==(`PER_SIZE+16'h0002)) tb_error("====== SWPB (@Rn mode): test 2 (address) =====");
      if (r7     !==16'h0005)             tb_error("====== SWPB (@Rn mode): test 2 (C flag)  =====");


      // Addressing mode: @Rn+
      @(r15==16'h3000);
      if (mem208 !==16'h2475)             tb_error("====== SWPB (@Rn+ mode): test 1 (result)  =====");
      if (r4     !==(`PER_SIZE+16'h000A)) tb_error("====== SWPB (@Rn+ mode): test 1 (address) =====");
      if (r5     !==16'h0102)             tb_error("====== SWPB (@Rn+ mode): test 1 (C flag)  =====");

      if (mem20A !==16'hb61c)             tb_error("====== SWPB (@Rn+ mode): test 2 (result)  =====");
      if (r6     !==(`PER_SIZE+16'h000C)) tb_error("====== SWPB (@Rn+ mode): test 2 (address) =====");
      if (r7     !==16'h0005)             tb_error("====== SWPB (@Rn+ mode): test 2 (C flag)  =====");


      // Addressing mode: X(Rn)
      @(r15==16'h4000);
      if (mem210 !==16'h2475) tb_error("====== SWPB (X(Rn) mode): test 1 (result)  =====");
      if (r5     !==16'h0102) tb_error("====== SWPB (X(Rn) mode): test 1 (C flag)  =====");

      if (mem212 !==16'hb61c) tb_error("====== SWPB (X(Rn) mode): test 2 (result)  =====");
      if (r7     !==16'h0005) tb_error("====== SWPB (X(Rn) mode): test 2 (C flag)  =====");


      // Addressing mode: EDE
      @(r15==16'h5000);
      if (mem218 !==16'h2475) tb_error("====== SWPB (EDE mode): test 1 (result)  =====");
      if (r5     !==16'h0102) tb_error("====== SWPB (EDE mode): test 1 (C flag)  =====");

      if (mem21A !==16'hb61c) tb_error("====== SWPB (EDE mode): test 2 (result)  =====");
      if (r7     !==16'h0005) tb_error("====== SWPB (EDE mode): test 2 (C flag)  =====");


      // Addressing mode: &EDE
      @(r15==16'h6000);
      if (mem220 !==16'h2475) tb_error("====== SWPB (&EDE mode): test 1 (result)  =====");
      if (r5     !==16'h0102) tb_error("====== SWPB (&EDE mode): test 1 (C flag)  =====");

      if (mem222 !==16'hb61c) tb_error("====== SWPB (&EDE mode): test 2 (result)  =====");
      if (r7     !==16'h0005) tb_error("====== SWPB (&EDE mode): test 2 (C flag)  =====");


      stimulus_done = 1;
   end

