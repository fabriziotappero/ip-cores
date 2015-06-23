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
/*                     PUSH:   DATA READ ACCESS FROM ROM                     */
/*---------------------------------------------------------------------------*/
/* Test the PUSH instruction with all addressing modes making a read access  */
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

      /* -------------- TEST INSTRUCTION IN WORD MODE ------------------- */

      // Initialization
      @(r15==16'h1000);
      if (r1     !==(`PER_SIZE+16'h0052)) tb_error("====== SP  initialization (R1 value)      =====");
      if (mem250 !==16'h0000) tb_error("====== RAM Initialization (@0x0250 value) =====");
      if (mem24E !==16'h0000) tb_error("====== RAM Initialization (@0x024e value) =====");
      if (mem24C !==16'h0000) tb_error("====== RAM Initialization (@0x024c value) =====");
      if (mem24A !==16'h0000) tb_error("====== RAM Initialization (@0x024a value) =====");
      if (mem248 !==16'h0000) tb_error("====== RAM Initialization (@0x0248 value) =====");
      if (mem246 !==16'h0000) tb_error("====== RAM Initialization (@0x0246 value) =====");
      if (mem244 !==16'h0000) tb_error("====== RAM Initialization (@0x0244 value) =====");
      if (mem242 !==16'h0000) tb_error("====== RAM Initialization (@0x0242 value) =====");
      if (mem240 !==16'h0000) tb_error("====== RAM Initialization (@0x0240 value) =====");
      if (mem23E !==16'h0000) tb_error("====== RAM Initialization (@0x023e value) =====");
      if (mem23C !==16'h0000) tb_error("====== RAM Initialization (@0x023c value) =====");
      if (mem23A !==16'h0000) tb_error("====== RAM Initialization (@0x023a value) =====");
      if (mem238 !==16'h0000) tb_error("====== RAM Initialization (@0x0238 value) =====");
      if (mem236 !==16'h0000) tb_error("====== RAM Initialization (@0x0236 value) =====");
      if (mem234 !==16'h0000) tb_error("====== RAM Initialization (@0x0234 value) =====");
      if (mem232 !==16'h0000) tb_error("====== RAM Initialization (@0x0232 value) =====");
      if (mem230 !==16'h0000) tb_error("====== RAM Initialization (@0x0230 value) =====");


      // Addressing mode: @Rn
      @(r15==16'h2000);
      if (r1     !==(`PER_SIZE+16'h004E)) tb_error("====== PUSH (@Rn mode): SP value      =====");
      if (mem250 !==16'h1234) tb_error("====== PUSH (@Rn mode): @0x0250 value =====");
      if (mem24E !==16'h5678) tb_error("====== PUSH (@Rn mode): @0x024E value =====");
      if (mem24C !==16'h0000) tb_error("====== PUSH (@Rn mode): @0x024c value =====");
      if (mem24A !==16'h0000) tb_error("====== PUSH (@Rn mode): @0x024a value =====");
      if (mem248 !==16'h0000) tb_error("====== PUSH (@Rn mode): @0x0248 value =====");
      if (mem246 !==16'h0000) tb_error("====== PUSH (@Rn mode): @0x0246 value =====");
      if (mem244 !==16'h0000) tb_error("====== PUSH (@Rn mode): @0x0244 value =====");
      if (mem242 !==16'h0000) tb_error("====== PUSH (@Rn mode): @0x0242 value =====");
      if (mem240 !==16'h0000) tb_error("====== PUSH (@Rn mode): @0x0240 value =====");
      if (mem23E !==16'h0000) tb_error("====== PUSH (@Rn mode): @0x023e value =====");
      if (mem23C !==16'h0000) tb_error("====== PUSH (@Rn mode): @0x023c value =====");
      if (mem23A !==16'h0000) tb_error("====== PUSH (@Rn mode): @0x023a value =====");
      if (mem238 !==16'h0000) tb_error("====== PUSH (@Rn mode): @0x0238 value =====");
      if (mem236 !==16'h0000) tb_error("====== PUSH (@Rn mode): @0x0236 value =====");
      if (mem234 !==16'h0000) tb_error("====== PUSH (@Rn mode): @0x0234 value =====");
      if (mem232 !==16'h0000) tb_error("====== PUSH (@Rn mode): @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH (@Rn mode): @0x0230 value =====");


      // Addressing mode: @Rn+
      @(r15==16'h3000);
      if (r1     !==(`PER_SIZE+16'h004a)) tb_error("====== PUSH (@Rn+ mode): SP value      =====");
      if (mem250 !==16'h1234) tb_error("====== PUSH (@Rn+ mode): @0x0250 value =====");
      if (mem24E !==16'h5678) tb_error("====== PUSH (@Rn+ mode): @0x024E value =====");
      if (mem24C !==16'h9abc) tb_error("====== PUSH (@Rn+ mode): @0x024c value =====");
      if (mem24A !==16'hdef0) tb_error("====== PUSH (@Rn+ mode): @0x024a value =====");
      if (mem248 !==16'h0000) tb_error("====== PUSH (@Rn+ mode): @0x0248 value =====");
      if (mem246 !==16'h0000) tb_error("====== PUSH (@Rn+ mode): @0x0246 value =====");
      if (mem244 !==16'h0000) tb_error("====== PUSH (@Rn+ mode): @0x0244 value =====");
      if (mem242 !==16'h0000) tb_error("====== PUSH (@Rn+ mode): @0x0242 value =====");
      if (mem240 !==16'h0000) tb_error("====== PUSH (@Rn+ mode): @0x0240 value =====");
      if (mem23E !==16'h0000) tb_error("====== PUSH (@Rn+ mode): @0x023e value =====");
      if (mem23C !==16'h0000) tb_error("====== PUSH (@Rn+ mode): @0x023c value =====");
      if (mem23A !==16'h0000) tb_error("====== PUSH (@Rn+ mode): @0x023a value =====");
      if (mem238 !==16'h0000) tb_error("====== PUSH (@Rn+ mode): @0x0238 value =====");
      if (mem236 !==16'h0000) tb_error("====== PUSH (@Rn+ mode): @0x0236 value =====");
      if (mem234 !==16'h0000) tb_error("====== PUSH (@Rn+ mode): @0x0234 value =====");
      if (mem232 !==16'h0000) tb_error("====== PUSH (@Rn+ mode): @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH (@Rn+ mode): @0x0230 value =====");


      // Addressing mode: X(Rn)
      @(r15==16'h4000);
      if (r1     !==(`PER_SIZE+16'h0046)) tb_error("====== PUSH (X(Rn) mode): SP value      =====");
      if (mem250 !==16'h1234) tb_error("====== PUSH (X(Rn) mode): @0x0250 value =====");
      if (mem24E !==16'h5678) tb_error("====== PUSH (X(Rn) mode): @0x024E value =====");
      if (mem24C !==16'h9abc) tb_error("====== PUSH (X(Rn) mode): @0x024c value =====");
      if (mem24A !==16'hdef0) tb_error("====== PUSH (X(Rn) mode): @0x024a value =====");
      if (mem248 !==16'h0fed) tb_error("====== PUSH (X(Rn) mode): @0x0248 value =====");
      if (mem246 !==16'hcba9) tb_error("====== PUSH (X(Rn) mode): @0x0246 value =====");
      if (mem244 !==16'h0000) tb_error("====== PUSH (X(Rn) mode): @0x0244 value =====");
      if (mem242 !==16'h0000) tb_error("====== PUSH (X(Rn) mode): @0x0242 value =====");
      if (mem240 !==16'h0000) tb_error("====== PUSH (X(Rn) mode): @0x0240 value =====");
      if (mem23E !==16'h0000) tb_error("====== PUSH (X(Rn) mode): @0x023e value =====");
      if (mem23C !==16'h0000) tb_error("====== PUSH (X(Rn) mode): @0x023c value =====");
      if (mem23A !==16'h0000) tb_error("====== PUSH (X(Rn) mode): @0x023a value =====");
      if (mem238 !==16'h0000) tb_error("====== PUSH (X(Rn) mode): @0x0238 value =====");
      if (mem236 !==16'h0000) tb_error("====== PUSH (X(Rn) mode): @0x0236 value =====");
      if (mem234 !==16'h0000) tb_error("====== PUSH (X(Rn) mode): @0x0234 value =====");
      if (mem232 !==16'h0000) tb_error("====== PUSH (X(Rn) mode): @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH (X(Rn) mode): @0x0230 value =====");


      // Addressing mode: EDE
      @(r15==16'h5000);
      if (r1     !==(`PER_SIZE+16'h0042)) tb_error("====== PUSH (EDE mode): SP value      =====");
      if (mem250 !==16'h1234) tb_error("====== PUSH (EDE mode): @0x0250 value =====");
      if (mem24E !==16'h5678) tb_error("====== PUSH (EDE mode): @0x024E value =====");
      if (mem24C !==16'h9abc) tb_error("====== PUSH (EDE mode): @0x024c value =====");
      if (mem24A !==16'hdef0) tb_error("====== PUSH (EDE mode): @0x024a value =====");
      if (mem248 !==16'h0fed) tb_error("====== PUSH (EDE mode): @0x0248 value =====");
      if (mem246 !==16'hcba9) tb_error("====== PUSH (EDE mode): @0x0246 value =====");
      if (mem244 !==16'h8765) tb_error("====== PUSH (EDE mode): @0x0244 value =====");
      if (mem242 !==16'h4321) tb_error("====== PUSH (EDE mode): @0x0242 value =====");
      if (mem240 !==16'h0000) tb_error("====== PUSH (EDE mode): @0x0240 value =====");
      if (mem23E !==16'h0000) tb_error("====== PUSH (EDE mode): @0x023e value =====");
      if (mem23C !==16'h0000) tb_error("====== PUSH (EDE mode): @0x023c value =====");
      if (mem23A !==16'h0000) tb_error("====== PUSH (EDE mode): @0x023a value =====");
      if (mem238 !==16'h0000) tb_error("====== PUSH (EDE mode): @0x0238 value =====");
      if (mem236 !==16'h0000) tb_error("====== PUSH (EDE mode): @0x0236 value =====");
      if (mem234 !==16'h0000) tb_error("====== PUSH (EDE mode): @0x0234 value =====");
      if (mem232 !==16'h0000) tb_error("====== PUSH (EDE mode): @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH (EDE mode): @0x0230 value =====");


      // Addressing mode: &EDE
      @(r15==16'h6000);
      if (r1     !==(`PER_SIZE+16'h003E)) tb_error("====== PUSH (&EDE mode): SP value      =====");
      if (mem250 !==16'h1234) tb_error("====== PUSH (&EDE mode): @0x0250 value =====");
      if (mem24E !==16'h5678) tb_error("====== PUSH (&EDE mode): @0x024E value =====");
      if (mem24C !==16'h9abc) tb_error("====== PUSH (&EDE mode): @0x024c value =====");
      if (mem24A !==16'hdef0) tb_error("====== PUSH (&EDE mode): @0x024a value =====");
      if (mem248 !==16'h0fed) tb_error("====== PUSH (&EDE mode): @0x0248 value =====");
      if (mem246 !==16'hcba9) tb_error("====== PUSH (&EDE mode): @0x0246 value =====");
      if (mem244 !==16'h8765) tb_error("====== PUSH (&EDE mode): @0x0244 value =====");
      if (mem242 !==16'h4321) tb_error("====== PUSH (&EDE mode): @0x0242 value =====");
      if (mem240 !==16'h1f2e) tb_error("====== PUSH (&EDE mode): @0x0240 value =====");
      if (mem23E !==16'h3d4c) tb_error("====== PUSH (&EDE mode): @0x023e value =====");
      if (mem23C !==16'h0000) tb_error("====== PUSH (&EDE mode): @0x023c value =====");
      if (mem23A !==16'h0000) tb_error("====== PUSH (&EDE mode): @0x023a value =====");
      if (mem238 !==16'h0000) tb_error("====== PUSH (&EDE mode): @0x0238 value =====");
      if (mem236 !==16'h0000) tb_error("====== PUSH (&EDE mode): @0x0236 value =====");
      if (mem234 !==16'h0000) tb_error("====== PUSH (&EDE mode): @0x0234 value =====");
      if (mem232 !==16'h0000) tb_error("====== PUSH (&EDE mode): @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH (&EDE mode): @0x0230 value =====");




      stimulus_done = 1;
   end

