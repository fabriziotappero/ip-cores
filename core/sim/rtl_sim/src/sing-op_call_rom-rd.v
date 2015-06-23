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
/*                     CALL:   DATA READ ACCESS FROM ROM                     */
/*---------------------------------------------------------------------------*/
/* Test the CALL instruction with all addressing modes making a read access  */
/* to the ROM.                                                               */
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

      // Initialization
      @(r15==16'h1000);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== SP  initialization =====");
      if (r5    !==16'h0000)             tb_error("====== R5  initialization  =====");


      // Addressing mode: @Rn
      @(r15==16'h2000);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== CALL (@Rn mode): SP value      =====");
      if (r5    !==16'h5678)             tb_error("====== CALL (@Rn mode): R5 value      =====");


      // Addressing mode: @Rn+
      @(r15==16'h3000);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== CALL (@Rn+ mode): SP value      =====");
      if (r5    !==16'h9abc)             tb_error("====== CALL (@Rn+ mode): R5 value      =====");

      // Addressing mode: X(Rn)
      @(r15==16'h4000);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== CALL (X(Rn) mode): SP value      =====");
      if (r5    !==16'hef01)             tb_error("====== CALL (X(Rn) mode): R5 value      =====");


      // Addressing mode: EDE
      @(r15==16'h5000);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== CALL (EDE mode): SP value      =====");
      if (r5    !==16'h2345)             tb_error("====== CALL (EDE mode): R5 value      =====");


      // Addressing mode: &EDE
      @(r15==16'h6000);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== CALL (&EDE mode): SP value      =====");
      if (r5    !==16'h6789)             tb_error("====== CALL (&EDE mode): R5 value      =====");


      stimulus_done = 1;
   end

