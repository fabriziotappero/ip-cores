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
/*                 SINGLE-OPERAND ARITHMETIC: PUSH  INSTRUCTION              */
/*---------------------------------------------------------------------------*/
/* Test the PUSH instruction.                                                */
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


      // Addressing mode: Rn
      @(r15==16'h2000);
      if (r1     !==(`PER_SIZE+16'h004E)) tb_error("====== PUSH (Rn mode): SP value      =====");
      if (mem250 !==16'h7524) tb_error("====== PUSH (Rn mode): @0x0250 value =====");
      if (mem24E !==16'h1cb6) tb_error("====== PUSH (Rn mode): @0x024E value =====");
      if (mem24C !==16'h0000) tb_error("====== PUSH (Rn mode): @0x024c value =====");
      if (mem24A !==16'h0000) tb_error("====== PUSH (Rn mode): @0x024a value =====");
      if (mem248 !==16'h0000) tb_error("====== PUSH (Rn mode): @0x0248 value =====");
      if (mem246 !==16'h0000) tb_error("====== PUSH (Rn mode): @0x0246 value =====");
      if (mem244 !==16'h0000) tb_error("====== PUSH (Rn mode): @0x0244 value =====");
      if (mem242 !==16'h0000) tb_error("====== PUSH (Rn mode): @0x0242 value =====");
      if (mem240 !==16'h0000) tb_error("====== PUSH (Rn mode): @0x0240 value =====");
      if (mem23E !==16'h0000) tb_error("====== PUSH (Rn mode): @0x023e value =====");
      if (mem23C !==16'h0000) tb_error("====== PUSH (Rn mode): @0x023c value =====");
      if (mem23A !==16'h0000) tb_error("====== PUSH (Rn mode): @0x023a value =====");
      if (mem238 !==16'h0000) tb_error("====== PUSH (Rn mode): @0x0238 value =====");
      if (mem236 !==16'h0000) tb_error("====== PUSH (Rn mode): @0x0236 value =====");
      if (mem234 !==16'h0000) tb_error("====== PUSH (Rn mode): @0x0234 value =====");
      if (mem232 !==16'h0000) tb_error("====== PUSH (Rn mode): @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH (Rn mode): @0x0230 value =====");


      // Addressing mode: @Rn
      @(r15==16'h3000);
      if (r1     !==(`PER_SIZE+16'h004A)) tb_error("====== PUSH (@Rn mode): SP value      =====");
      if (mem250 !==16'h7524) tb_error("====== PUSH (@Rn mode): @0x0250 value =====");
      if (mem24E !==16'h1cb6) tb_error("====== PUSH (@Rn mode): @0x024E value =====");
      if (mem24C !==16'h1234) tb_error("====== PUSH (@Rn mode): @0x024c value =====");
      if (mem24A !==16'h5678) tb_error("====== PUSH (@Rn mode): @0x024a value =====");
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
      @(r15==16'h4000);
      if (r4     !==(`PER_SIZE+16'h001A)) tb_error("====== PUSH (@Rn+ mode): R4 value      =====");
      if (r1     !==(`PER_SIZE+16'h0046)) tb_error("====== PUSH (@Rn+ mode): SP value      =====");
      if (mem250 !==16'h7524) tb_error("====== PUSH (@Rn+ mode): @0x0250 value =====");
      if (mem24E !==16'h1cb6) tb_error("====== PUSH (@Rn+ mode): @0x024E value =====");
      if (mem24C !==16'h1234) tb_error("====== PUSH (@Rn+ mode): @0x024c value =====");
      if (mem24A !==16'h5678) tb_error("====== PUSH (@Rn+ mode): @0x024a value =====");
      if (mem248 !==16'h9abc) tb_error("====== PUSH (@Rn+ mode): @0x0248 value =====");
      if (mem246 !==16'hdef0) tb_error("====== PUSH (@Rn+ mode): @0x0246 value =====");
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
      @(r15==16'h5000);
      if (r1     !==(`PER_SIZE+16'h0042)) tb_error("====== PUSH (X(Rn) mode): SP value      =====");
      if (mem250 !==16'h7524) tb_error("====== PUSH (X(Rn) mode): @0x0250 value =====");
      if (mem24E !==16'h1cb6) tb_error("====== PUSH (X(Rn) mode): @0x024E value =====");
      if (mem24C !==16'h1234) tb_error("====== PUSH (X(Rn) mode): @0x024c value =====");
      if (mem24A !==16'h5678) tb_error("====== PUSH (X(Rn) mode): @0x024a value =====");
      if (mem248 !==16'h9abc) tb_error("====== PUSH (X(Rn) mode): @0x0248 value =====");
      if (mem246 !==16'hdef0) tb_error("====== PUSH (X(Rn) mode): @0x0246 value =====");
      if (mem244 !==16'h0fed) tb_error("====== PUSH (X(Rn) mode): @0x0244 value =====");
      if (mem242 !==16'hcba9) tb_error("====== PUSH (X(Rn) mode): @0x0242 value =====");
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
      @(r15==16'h6000);
      if (r1     !==(`PER_SIZE+16'h003E)) tb_error("====== PUSH (EDE mode): SP value      =====");
      if (mem250 !==16'h7524) tb_error("====== PUSH (EDE mode): @0x0250 value =====");
      if (mem24E !==16'h1cb6) tb_error("====== PUSH (EDE mode): @0x024E value =====");
      if (mem24C !==16'h1234) tb_error("====== PUSH (EDE mode): @0x024c value =====");
      if (mem24A !==16'h5678) tb_error("====== PUSH (EDE mode): @0x024a value =====");
      if (mem248 !==16'h9abc) tb_error("====== PUSH (EDE mode): @0x0248 value =====");
      if (mem246 !==16'hdef0) tb_error("====== PUSH (EDE mode): @0x0246 value =====");
      if (mem244 !==16'h0fed) tb_error("====== PUSH (EDE mode): @0x0244 value =====");
      if (mem242 !==16'hcba9) tb_error("====== PUSH (EDE mode): @0x0242 value =====");
      if (mem240 !==16'h8765) tb_error("====== PUSH (EDE mode): @0x0240 value =====");
      if (mem23E !==16'h4321) tb_error("====== PUSH (EDE mode): @0x023e value =====");
      if (mem23C !==16'h0000) tb_error("====== PUSH (EDE mode): @0x023c value =====");
      if (mem23A !==16'h0000) tb_error("====== PUSH (EDE mode): @0x023a value =====");
      if (mem238 !==16'h0000) tb_error("====== PUSH (EDE mode): @0x0238 value =====");
      if (mem236 !==16'h0000) tb_error("====== PUSH (EDE mode): @0x0236 value =====");
      if (mem234 !==16'h0000) tb_error("====== PUSH (EDE mode): @0x0234 value =====");
      if (mem232 !==16'h0000) tb_error("====== PUSH (EDE mode): @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH (EDE mode): @0x0230 value =====");


      // Addressing mode: &EDE
      @(r15==16'h7000);
      if (r1     !==(`PER_SIZE+16'h003A)) tb_error("====== PUSH (&EDE mode): SP value      =====");
      if (mem250 !==16'h7524) tb_error("====== PUSH (&EDE mode): @0x0250 value =====");
      if (mem24E !==16'h1cb6) tb_error("====== PUSH (&EDE mode): @0x024E value =====");
      if (mem24C !==16'h1234) tb_error("====== PUSH (&EDE mode): @0x024c value =====");
      if (mem24A !==16'h5678) tb_error("====== PUSH (&EDE mode): @0x024a value =====");
      if (mem248 !==16'h9abc) tb_error("====== PUSH (&EDE mode): @0x0248 value =====");
      if (mem246 !==16'hdef0) tb_error("====== PUSH (&EDE mode): @0x0246 value =====");
      if (mem244 !==16'h0fed) tb_error("====== PUSH (&EDE mode): @0x0244 value =====");
      if (mem242 !==16'hcba9) tb_error("====== PUSH (&EDE mode): @0x0242 value =====");
      if (mem240 !==16'h8765) tb_error("====== PUSH (&EDE mode): @0x0240 value =====");
      if (mem23E !==16'h4321) tb_error("====== PUSH (&EDE mode): @0x023e value =====");
      if (mem23C !==16'h1f2e) tb_error("====== PUSH (&EDE mode): @0x023c value =====");
      if (mem23A !==16'h3d4c) tb_error("====== PUSH (&EDE mode): @0x023a value =====");
      if (mem238 !==16'h0000) tb_error("====== PUSH (&EDE mode): @0x0238 value =====");
      if (mem236 !==16'h0000) tb_error("====== PUSH (&EDE mode): @0x0236 value =====");
      if (mem234 !==16'h0000) tb_error("====== PUSH (&EDE mode): @0x0234 value =====");
      if (mem232 !==16'h0000) tb_error("====== PUSH (&EDE mode): @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH (&EDE mode): @0x0230 value =====");


      // Addressing mode: #N
      @(r15==16'h7001);
      if (r1     !==(`PER_SIZE+16'h0036)) tb_error("====== PUSH (#N mode): SP value      =====");
      if (mem250 !==16'h7524) tb_error("====== PUSH (#N mode): @0x0250 value =====");
      if (mem24E !==16'h1cb6) tb_error("====== PUSH (#N mode): @0x024E value =====");
      if (mem24C !==16'h1234) tb_error("====== PUSH (#N mode): @0x024c value =====");
      if (mem24A !==16'h5678) tb_error("====== PUSH (#N mode): @0x024a value =====");
      if (mem248 !==16'h9abc) tb_error("====== PUSH (#N mode): @0x0248 value =====");
      if (mem246 !==16'hdef0) tb_error("====== PUSH (#N mode): @0x0246 value =====");
      if (mem244 !==16'h0fed) tb_error("====== PUSH (#N mode): @0x0244 value =====");
      if (mem242 !==16'hcba9) tb_error("====== PUSH (#N mode): @0x0242 value =====");
      if (mem240 !==16'h8765) tb_error("====== PUSH (#N mode): @0x0240 value =====");
      if (mem23E !==16'h4321) tb_error("====== PUSH (#N mode): @0x023e value =====");
      if (mem23C !==16'h1f2e) tb_error("====== PUSH (#N mode): @0x023c value =====");
      if (mem23A !==16'h3d4c) tb_error("====== PUSH (#N mode): @0x023a value =====");
      if (mem238 !==16'h71c8) tb_error("====== PUSH (#N mode): @0x0238 value =====");
      if (mem236 !==16'h178c) tb_error("====== PUSH (#N mode): @0x0236 value =====");
      if (mem234 !==16'h0000) tb_error("====== PUSH (#N mode): @0x0234 value =====");
      if (mem232 !==16'h0000) tb_error("====== PUSH (#N mode): @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH (#N mode): @0x0230 value =====");


      /* -------------- TEST INSTRUCTION IN BYTE MODE ------------------- */

      // Initialization
      @(r15==16'h8000);
      if (r1     !==(`PER_SIZE+16'h0052)) tb_error("====== SP  initialization (R1 value)      =====");
      if (mem250 !==16'h7524) tb_error("====== RAM Initialization (@0x0250 value) =====");
      if (mem24E !==16'h1cb6) tb_error("====== RAM Initialization (@0x024E value) =====");
      if (mem24C !==16'h1234) tb_error("====== RAM Initialization (@0x024c value) =====");
      if (mem24A !==16'h5678) tb_error("====== RAM Initialization (@0x024a value) =====");
      if (mem248 !==16'h9abc) tb_error("====== RAM Initialization (@0x0248 value) =====");
      if (mem246 !==16'hdef0) tb_error("====== RAM Initialization (@0x0246 value) =====");
      if (mem244 !==16'h0fed) tb_error("====== RAM Initialization (@0x0244 value) =====");
      if (mem242 !==16'hcba9) tb_error("====== RAM Initialization (@0x0242 value) =====");
      if (mem240 !==16'h8765) tb_error("====== RAM Initialization (@0x0240 value) =====");
      if (mem23E !==16'h4321) tb_error("====== RAM Initialization (@0x023e value) =====");
      if (mem23C !==16'h1f2e) tb_error("====== RAM Initialization (@0x023c value) =====");
      if (mem23A !==16'h3d4c) tb_error("====== RAM Initialization (@0x023a value) =====");
      if (mem238 !==16'h71c8) tb_error("====== RAM Initialization (@0x0238 value) =====");
      if (mem236 !==16'h178c) tb_error("====== RAM Initialization (@0x0236 value) =====");
      if (mem234 !==16'h0000) tb_error("====== RAM Initialization (@0x0234 value) =====");
      if (mem232 !==16'h0000) tb_error("====== RAM Initialization (@0x0232 value) =====");
      if (mem230 !==16'h0000) tb_error("====== RAM Initialization (@0x0230 value) =====");


      // Addressing mode: Rn
      @(r15==16'h9000);
      if (r1     !==(`PER_SIZE+16'h004E)) tb_error("====== PUSH.B (Rn mode): SP value      =====");
      if (mem250 !==16'h75e2) tb_error("====== PUSH.B (Rn mode): @0x0250 value =====");
      if (mem24E !==16'h1cc4) tb_error("====== PUSH.B (Rn mode): @0x024E value =====");
      if (mem24C !==16'h1234) tb_error("====== PUSH.B (Rn mode): @0x024c value =====");
      if (mem24A !==16'h5678) tb_error("====== PUSH.B (Rn mode): @0x024a value =====");
      if (mem248 !==16'h9abc) tb_error("====== PUSH.B (Rn mode): @0x0248 value =====");
      if (mem246 !==16'hdef0) tb_error("====== PUSH.B (Rn mode): @0x0246 value =====");
      if (mem244 !==16'h0fed) tb_error("====== PUSH.B (Rn mode): @0x0244 value =====");
      if (mem242 !==16'hcba9) tb_error("====== PUSH.B (Rn mode): @0x0242 value =====");
      if (mem240 !==16'h8765) tb_error("====== PUSH.B (Rn mode): @0x0240 value =====");
      if (mem23E !==16'h4321) tb_error("====== PUSH.B (Rn mode): @0x023e value =====");
      if (mem23C !==16'h1f2e) tb_error("====== PUSH.B (Rn mode): @0x023c value =====");
      if (mem23A !==16'h3d4c) tb_error("====== PUSH.B (Rn mode): @0x023a value =====");
      if (mem238 !==16'h71c8) tb_error("====== PUSH.B (Rn mode): @0x0238 value =====");
      if (mem236 !==16'h178c) tb_error("====== PUSH.B (Rn mode): @0x0236 value =====");
      if (mem234 !==16'h0000) tb_error("====== PUSH.B (Rn mode): @0x0234 value =====");
      if (mem232 !==16'h0000) tb_error("====== PUSH.B (Rn mode): @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH.B (Rn mode): @0x0230 value =====");


      // Addressing mode: @Rn
      @(r15==16'hA000);
      if (r1     !==(`PER_SIZE+16'h004A)) tb_error("====== PUSH.B (@Rn mode): SP value      =====");
      if (mem250 !==16'h75e2) tb_error("====== PUSH.B (@Rn mode): @0x0250 value =====");
      if (mem24E !==16'h1cc4) tb_error("====== PUSH.B (@Rn mode): @0x024E value =====");
      if (mem24C !==16'h12a6) tb_error("====== PUSH.B (@Rn mode): @0x024c value =====");
      if (mem24A !==16'h5679) tb_error("====== PUSH.B (@Rn mode): @0x024a value =====");
      if (mem248 !==16'h9abc) tb_error("====== PUSH.B (@Rn mode): @0x0248 value =====");
      if (mem246 !==16'hdef0) tb_error("====== PUSH.B (@Rn mode): @0x0246 value =====");
      if (mem244 !==16'h0fed) tb_error("====== PUSH.B (@Rn mode): @0x0244 value =====");
      if (mem242 !==16'hcba9) tb_error("====== PUSH.B (@Rn mode): @0x0242 value =====");
      if (mem240 !==16'h8765) tb_error("====== PUSH.B (@Rn mode): @0x0240 value =====");
      if (mem23E !==16'h4321) tb_error("====== PUSH.B (@Rn mode): @0x023e value =====");
      if (mem23C !==16'h1f2e) tb_error("====== PUSH.B (@Rn mode): @0x023c value =====");
      if (mem23A !==16'h3d4c) tb_error("====== PUSH.B (@Rn mode): @0x023a value =====");
      if (mem238 !==16'h71c8) tb_error("====== PUSH.B (@Rn mode): @0x0238 value =====");
      if (mem236 !==16'h178c) tb_error("====== PUSH.B (@Rn mode): @0x0236 value =====");
      if (mem234 !==16'h0000) tb_error("====== PUSH.B (@Rn mode): @0x0234 value =====");
      if (mem232 !==16'h0000) tb_error("====== PUSH.B (@Rn mode): @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH.B (@Rn mode): @0x0230 value =====");


      // Addressing mode: @Rn+
      @(r15==16'hB000);
      if (r4     !==(`PER_SIZE+16'h0018)) tb_error("====== PUSH.B (@Rn+ mode): R4 value      =====");
      if (r1     !==(`PER_SIZE+16'h0046)) tb_error("====== PUSH.B (@Rn+ mode): SP value      =====");
      if (mem250 !==16'h75e2) tb_error("====== PUSH.B (@Rn+ mode): @0x0250 value =====");
      if (mem24E !==16'h1cc4) tb_error("====== PUSH.B (@Rn+ mode): @0x024E value =====");
      if (mem24C !==16'h12a6) tb_error("====== PUSH.B (@Rn+ mode): @0x024c value =====");
      if (mem24A !==16'h5679) tb_error("====== PUSH.B (@Rn+ mode): @0x024a value =====");
      if (mem248 !==16'h9a6a) tb_error("====== PUSH.B (@Rn+ mode): @0x0248 value =====");
      if (mem246 !==16'hde97) tb_error("====== PUSH.B (@Rn+ mode): @0x0246 value =====");
      if (mem244 !==16'h0fed) tb_error("====== PUSH.B (@Rn+ mode): @0x0244 value =====");
      if (mem242 !==16'hcba9) tb_error("====== PUSH.B (@Rn+ mode): @0x0242 value =====");
      if (mem240 !==16'h8765) tb_error("====== PUSH.B (@Rn+ mode): @0x0240 value =====");
      if (mem23E !==16'h4321) tb_error("====== PUSH.B (@Rn+ mode): @0x023e value =====");
      if (mem23C !==16'h1f2e) tb_error("====== PUSH.B (@Rn+ mode): @0x023c value =====");
      if (mem23A !==16'h3d4c) tb_error("====== PUSH.B (@Rn+ mode): @0x023a value =====");
      if (mem238 !==16'h71c8) tb_error("====== PUSH.B (@Rn+ mode): @0x0238 value =====");
      if (mem236 !==16'h178c) tb_error("====== PUSH.B (@Rn+ mode): @0x0236 value =====");
      if (mem234 !==16'h0000) tb_error("====== PUSH.B (@Rn+ mode): @0x0234 value =====");
      if (mem232 !==16'h0000) tb_error("====== PUSH.B (@Rn+ mode): @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH.B (@Rn+ mode): @0x0230 value =====");


      // Addressing mode: X(Rn)
      @(r15==16'hC000);
      if (r1     !==(`PER_SIZE+16'h0042)) tb_error("====== PUSH.B (X(Rn) mode): SP value      =====");
      if (mem250 !==16'h75e2) tb_error("====== PUSH.B (X(Rn) mode): @0x0250 value =====");
      if (mem24E !==16'h1cc4) tb_error("====== PUSH.B (X(Rn) mode): @0x024E value =====");
      if (mem24C !==16'h12a6) tb_error("====== PUSH.B (X(Rn) mode): @0x024c value =====");
      if (mem24A !==16'h5679) tb_error("====== PUSH.B (X(Rn) mode): @0x024a value =====");
      if (mem248 !==16'h9a6a) tb_error("====== PUSH.B (X(Rn) mode): @0x0248 value =====");
      if (mem246 !==16'hde97) tb_error("====== PUSH.B (X(Rn) mode): @0x0246 value =====");
      if (mem244 !==16'h0f4c) tb_error("====== PUSH.B (X(Rn) mode): @0x0244 value =====");
      if (mem242 !==16'hcbc3) tb_error("====== PUSH.B (X(Rn) mode): @0x0242 value =====");
      if (mem240 !==16'h8765) tb_error("====== PUSH.B (X(Rn) mode): @0x0240 value =====");
      if (mem23E !==16'h4321) tb_error("====== PUSH.B (X(Rn) mode): @0x023e value =====");
      if (mem23C !==16'h1f2e) tb_error("====== PUSH.B (X(Rn) mode): @0x023c value =====");
      if (mem23A !==16'h3d4c) tb_error("====== PUSH.B (X(Rn) mode): @0x023a value =====");
      if (mem238 !==16'h71c8) tb_error("====== PUSH.B (X(Rn) mode): @0x0238 value =====");
      if (mem236 !==16'h178c) tb_error("====== PUSH.B (X(Rn) mode): @0x0236 value =====");
      if (mem234 !==16'h0000) tb_error("====== PUSH.B (X(Rn) mode): @0x0234 value =====");
      if (mem232 !==16'h0000) tb_error("====== PUSH.B (X(Rn) mode): @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH.B (X(Rn) mode): @0x0230 value =====");


      // Addressing mode: EDE
      @(r15==16'hD000);
      if (r1     !==(`PER_SIZE+16'h003E)) tb_error("====== PUSH.B (EDE mode): SP value      =====");
      if (mem250 !==16'h75e2) tb_error("====== PUSH.B (EDE mode): @0x0250 value =====");
      if (mem24E !==16'h1cc4) tb_error("====== PUSH.B (EDE mode): @0x024E value =====");
      if (mem24C !==16'h12a6) tb_error("====== PUSH.B (EDE mode): @0x024c value =====");
      if (mem24A !==16'h5679) tb_error("====== PUSH.B (EDE mode): @0x024a value =====");
      if (mem248 !==16'h9a6a) tb_error("====== PUSH.B (EDE mode): @0x0248 value =====");
      if (mem246 !==16'hde97) tb_error("====== PUSH.B (EDE mode): @0x0246 value =====");
      if (mem244 !==16'h0f4c) tb_error("====== PUSH.B (EDE mode): @0x0244 value =====");
      if (mem242 !==16'hcbc3) tb_error("====== PUSH.B (EDE mode): @0x0242 value =====");
      if (mem240 !==16'h870e) tb_error("====== PUSH.B (EDE mode): @0x0240 value =====");
      if (mem23E !==16'h43fe) tb_error("====== PUSH.B (EDE mode): @0x023e value =====");
      if (mem23C !==16'h1f2e) tb_error("====== PUSH.B (EDE mode): @0x023c value =====");
      if (mem23A !==16'h3d4c) tb_error("====== PUSH.B (EDE mode): @0x023a value =====");
      if (mem238 !==16'h71c8) tb_error("====== PUSH.B (EDE mode): @0x0238 value =====");
      if (mem236 !==16'h178c) tb_error("====== PUSH.B (EDE mode): @0x0236 value =====");
      if (mem234 !==16'h0000) tb_error("====== PUSH.B (EDE mode): @0x0234 value =====");
      if (mem232 !==16'h0000) tb_error("====== PUSH.B (EDE mode): @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH.B (EDE mode): @0x0230 value =====");


      // Addressing mode: &EDE
      @(r15==16'hE000);
      if (r1     !==(`PER_SIZE+16'h003A)) tb_error("====== PUSH.B (&EDE mode): SP value      =====");
      if (mem250 !==16'h75e2) tb_error("====== PUSH.B (&EDE mode): @0x0250 value =====");
      if (mem24E !==16'h1cc4) tb_error("====== PUSH.B (&EDE mode): @0x024E value =====");
      if (mem24C !==16'h12a6) tb_error("====== PUSH.B (&EDE mode): @0x024c value =====");
      if (mem24A !==16'h5679) tb_error("====== PUSH.B (&EDE mode): @0x024a value =====");
      if (mem248 !==16'h9a6a) tb_error("====== PUSH.B (&EDE mode): @0x0248 value =====");
      if (mem246 !==16'hde97) tb_error("====== PUSH.B (&EDE mode): @0x0246 value =====");
      if (mem244 !==16'h0f4c) tb_error("====== PUSH.B (&EDE mode): @0x0244 value =====");
      if (mem242 !==16'hcbc3) tb_error("====== PUSH.B (&EDE mode): @0x0242 value =====");
      if (mem240 !==16'h870e) tb_error("====== PUSH.B (&EDE mode): @0x0240 value =====");
      if (mem23E !==16'h43fe) tb_error("====== PUSH.B (&EDE mode): @0x023e value =====");
      if (mem23C !==16'h1fc2) tb_error("====== PUSH.B (&EDE mode): @0x023c value =====");
      if (mem23A !==16'h3d3b) tb_error("====== PUSH.B (&EDE mode): @0x023a value =====");
      if (mem238 !==16'h71c8) tb_error("====== PUSH.B (&EDE mode): @0x0238 value =====");
      if (mem236 !==16'h178c) tb_error("====== PUSH.B (&EDE mode): @0x0236 value =====");
      if (mem234 !==16'h0000) tb_error("====== PUSH.B (&EDE mode): @0x0234 value =====");
      if (mem232 !==16'h0000) tb_error("====== PUSH.B (&EDE mode): @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH.B (&EDE mode): @0x0230 value =====");


      // Addressing mode: #N
      @(r15==16'hF000);
      if (r1     !==(`PER_SIZE+16'h0036)) tb_error("====== PUSH.B (#N mode): SP value      =====");
      if (mem250 !==16'h75e2) tb_error("====== PUSH.B (#N mode): @0x0250 value =====");
      if (mem24E !==16'h1cc4) tb_error("====== PUSH.B (#N mode): @0x024E value =====");
      if (mem24C !==16'h12a6) tb_error("====== PUSH.B (#N mode): @0x024c value =====");
      if (mem24A !==16'h5679) tb_error("====== PUSH.B (#N mode): @0x024a value =====");
      if (mem248 !==16'h9a6a) tb_error("====== PUSH.B (#N mode): @0x0248 value =====");
      if (mem246 !==16'hde97) tb_error("====== PUSH.B (#N mode): @0x0246 value =====");
      if (mem244 !==16'h0f4c) tb_error("====== PUSH.B (#N mode): @0x0244 value =====");
      if (mem242 !==16'hcbc3) tb_error("====== PUSH.B (#N mode): @0x0242 value =====");
      if (mem240 !==16'h870e) tb_error("====== PUSH.B (#N mode): @0x0240 value =====");
      if (mem23E !==16'h43fe) tb_error("====== PUSH.B (#N mode): @0x023e value =====");
      if (mem23C !==16'h1fc2) tb_error("====== PUSH.B (#N mode): @0x023c value =====");
      if (mem23A !==16'h3d3b) tb_error("====== PUSH.B (#N mode): @0x023a value =====");
      if (mem238 !==16'h71d9) tb_error("====== PUSH.B (#N mode): @0x0238 value =====");
      if (mem236 !==16'h178d) tb_error("====== PUSH.B (#N mode): @0x0236 value =====");
      if (mem234 !==16'h0000) tb_error("====== PUSH.B (#N mode): @0x0234 value =====");
      if (mem232 !==16'h0000) tb_error("====== PUSH.B (#N mode): @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH.B (#N mode): @0x0230 value =====");

      /* -------------- TEST INSTRUCTION WITH SR AS ARGUMENT ------------------- */

      // Addressing mode: SR
      @(r15==16'hF100);
      if (r1     !==(`PER_SIZE+16'h0032)) tb_error("====== PUSH SR : SP value      =====");
      if (mem250 !==16'h75e2) tb_error("====== PUSH SR : @0x0250 value =====");
      if (mem24E !==16'h1cc4) tb_error("====== PUSH SR : @0x024E value =====");
      if (mem24C !==16'h12a6) tb_error("====== PUSH SR : @0x024c value =====");
      if (mem24A !==16'h5679) tb_error("====== PUSH SR : @0x024a value =====");
      if (mem248 !==16'h9a6a) tb_error("====== PUSH SR : @0x0248 value =====");
      if (mem246 !==16'hde97) tb_error("====== PUSH SR : @0x0246 value =====");
      if (mem244 !==16'h0f4c) tb_error("====== PUSH SR : @0x0244 value =====");
      if (mem242 !==16'hcbc3) tb_error("====== PUSH SR : @0x0242 value =====");
      if (mem240 !==16'h870e) tb_error("====== PUSH SR : @0x0240 value =====");
      if (mem23E !==16'h43fe) tb_error("====== PUSH SR : @0x023e value =====");
      if (mem23C !==16'h1fc2) tb_error("====== PUSH SR : @0x023c value =====");
      if (mem23A !==16'h3d3b) tb_error("====== PUSH SR : @0x023a value =====");
      if (mem238 !==16'h71d9) tb_error("====== PUSH SR : @0x0238 value =====");
      if (mem236 !==16'h178d) tb_error("====== PUSH SR : @0x0236 value =====");
      if (mem234 !==(`PER_SIZE+16'h0034)) tb_error("====== PUSH SR : @0x0234 value =====");
      if (mem232 !==(`PER_SIZE+16'h0032)) tb_error("====== PUSH SR : @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH SR : @0x0230 value =====");

      // Addressing mode: @SR
      @(r15==16'hF200);
      if (r1     !==(`PER_SIZE+16'h002E)) tb_error("====== PUSH @SR : SP value      =====");
      if (mem250 !==16'h75e2) tb_error("====== PUSH @SR : @0x0250 value =====");
      if (mem24E !==16'h1cc4) tb_error("====== PUSH @SR : @0x024E value =====");
      if (mem24C !==16'h12a6) tb_error("====== PUSH @SR : @0x024c value =====");
      if (mem24A !==16'h5679) tb_error("====== PUSH @SR : @0x024a value =====");
      if (mem248 !==16'h9a6a) tb_error("====== PUSH @SR : @0x0248 value =====");
      if (mem246 !==16'hde97) tb_error("====== PUSH @SR : @0x0246 value =====");
      if (mem244 !==16'h0f4c) tb_error("====== PUSH @SR : @0x0244 value =====");
      if (mem242 !==16'hcbc3) tb_error("====== PUSH @SR : @0x0242 value =====");
      if (mem240 !==16'h870e) tb_error("====== PUSH @SR : @0x0240 value =====");
      if (mem23E !==16'h43fe) tb_error("====== PUSH @SR : @0x023e value =====");
      if (mem23C !==16'h1fc2) tb_error("====== PUSH @SR : @0x023c value =====");
      if (mem23A !==16'h3d3b) tb_error("====== PUSH @SR : @0x023a value =====");
      if (mem238 !==16'h71d9) tb_error("====== PUSH @SR : @0x0238 value =====");
      if (mem236 !==16'h178d) tb_error("====== PUSH @SR : @0x0236 value =====");
      if (mem234 !==(`PER_SIZE+16'h0034)) tb_error("====== PUSH @SR : @0x0234 value =====");
      if (mem232 !==(`PER_SIZE+16'h0032)) tb_error("====== PUSH @SR : @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH @SR : @0x0230 value =====");
      if (mem22E !==16'h1234) tb_error("====== PUSH @SR : @0x022E value =====");
      if (mem22C !==16'h5678) tb_error("====== PUSH @SR : @0x022C value =====");

      // Addressing mode: @SR+
      @(r15==16'hF300);
      if (r1     !==(`PER_SIZE+16'h002E)) tb_error("====== PUSH @SR : SP value      =====");
      if (mem250 !==16'h75e2) tb_error("====== PUSH @SR : @0x0250 value =====");
      if (mem24E !==16'h1cc4) tb_error("====== PUSH @SR : @0x024E value =====");
      if (mem24C !==16'h12a6) tb_error("====== PUSH @SR : @0x024c value =====");
      if (mem24A !==16'h5679) tb_error("====== PUSH @SR : @0x024a value =====");
      if (mem248 !==16'h9a6a) tb_error("====== PUSH @SR : @0x0248 value =====");
      if (mem246 !==16'hde97) tb_error("====== PUSH @SR : @0x0246 value =====");
      if (mem244 !==16'h0f4c) tb_error("====== PUSH @SR : @0x0244 value =====");
      if (mem242 !==16'hcbc3) tb_error("====== PUSH @SR : @0x0242 value =====");
      if (mem240 !==16'h870e) tb_error("====== PUSH @SR : @0x0240 value =====");
      if (mem23E !==16'h43fe) tb_error("====== PUSH @SR : @0x023e value =====");
      if (mem23C !==16'h1fc2) tb_error("====== PUSH @SR : @0x023c value =====");
      if (mem23A !==16'h3d3b) tb_error("====== PUSH @SR : @0x023a value =====");
      if (mem238 !==16'h71d9) tb_error("====== PUSH @SR : @0x0238 value =====");
      if (mem236 !==16'h178d) tb_error("====== PUSH @SR : @0x0236 value =====");
      if (mem234 !==(`PER_SIZE+16'h0034)) tb_error("====== PUSH @SR : @0x0234 value =====");
      if (mem232 !==(`PER_SIZE+16'h0032)) tb_error("====== PUSH @SR : @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH @SR : @0x0230 value =====");
      if (mem22E !==16'h1234) tb_error("====== PUSH @SR : @0x022E value =====");
      if (mem22C !==16'h5678) tb_error("====== PUSH @SR : @0x022C value =====");
      if (mem22A !==16'h0000) tb_error("====== PUSH @SR : @0x022A value =====");
      if (mem228 !==16'h0000) tb_error("====== PUSH @SR : @0x0228 value =====");

      // Addressing mode: x(SR)
      @(r15==16'hF400);
      if (r1     !==(`PER_SIZE+16'h002A)) tb_error("====== PUSH @SR : SP value      =====");
      if (mem250 !==16'h75e2) tb_error("====== PUSH @SR : @0x0250 value =====");
      if (mem24E !==16'h1cc4) tb_error("====== PUSH @SR : @0x024E value =====");
      if (mem24C !==16'h12a6) tb_error("====== PUSH @SR : @0x024c value =====");
      if (mem24A !==16'h5679) tb_error("====== PUSH @SR : @0x024a value =====");
      if (mem248 !==16'h9a6a) tb_error("====== PUSH @SR : @0x0248 value =====");
      if (mem246 !==16'hde97) tb_error("====== PUSH @SR : @0x0246 value =====");
      if (mem244 !==16'h0f4c) tb_error("====== PUSH @SR : @0x0244 value =====");
      if (mem242 !==16'hcbc3) tb_error("====== PUSH @SR : @0x0242 value =====");
      if (mem240 !==16'h870e) tb_error("====== PUSH @SR : @0x0240 value =====");
      if (mem23E !==16'h43fe) tb_error("====== PUSH @SR : @0x023e value =====");
      if (mem23C !==16'h1fc2) tb_error("====== PUSH @SR : @0x023c value =====");
      if (mem23A !==16'h3d3b) tb_error("====== PUSH @SR : @0x023a value =====");
      if (mem238 !==16'h71d9) tb_error("====== PUSH @SR : @0x0238 value =====");
      if (mem236 !==16'h178d) tb_error("====== PUSH @SR : @0x0236 value =====");
      if (mem234 !==(`PER_SIZE+16'h0034)) tb_error("====== PUSH @SR : @0x0234 value =====");
      if (mem232 !==(`PER_SIZE+16'h0032)) tb_error("====== PUSH @SR : @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH @SR : @0x0230 value =====");
      if (mem22E !==16'h1234) tb_error("====== PUSH @SR : @0x022E value =====");
      if (mem22C !==16'h71d9) tb_error("====== PUSH @SR : @0x022C value =====");
      if (mem22A !==16'h178d) tb_error("====== PUSH @SR : @0x022A value =====");
      if (mem228 !==16'h0000) tb_error("====== PUSH @SR : @0x0228 value =====");

      
      /* -------------- TEST POP INSTRUCTION WITH SR AS ARGUMENT ------------------- */

      // Addressing mode: x(SR)
      @(r15==16'hF500);
      if (r1     !==(`PER_SIZE+16'h002E)) tb_error("====== PUSH @SR : SP value      =====");
      if (mem250 !==16'h75e2) tb_error("====== PUSH @SR : @0x0250 value =====");
      if (mem24E !==16'h1cc4) tb_error("====== PUSH @SR : @0x024E value =====");
      if (mem24C !==16'h12a6) tb_error("====== PUSH @SR : @0x024c value =====");
      if (mem24A !==16'h5679) tb_error("====== PUSH @SR : @0x024a value =====");
      if (mem248 !==16'h9a6a) tb_error("====== PUSH @SR : @0x0248 value =====");
      if (mem246 !==16'hde97) tb_error("====== PUSH @SR : @0x0246 value =====");
      if (mem244 !==16'h0f4c) tb_error("====== PUSH @SR : @0x0244 value =====");
      if (mem242 !==16'hcbc3) tb_error("====== PUSH @SR : @0x0242 value =====");
      if (mem240 !==16'h870e) tb_error("====== PUSH @SR : @0x0240 value =====");
      if (mem23E !==16'h43fe) tb_error("====== PUSH @SR : @0x023e value =====");
      if (mem23C !==16'h1fc2) tb_error("====== PUSH @SR : @0x023c value =====");
      if (mem23A !==16'h3d3b) tb_error("====== PUSH @SR : @0x023a value =====");
      if (mem238 !==16'h71d9) tb_error("====== PUSH @SR : @0x0238 value =====");
      if (mem236 !==16'h178d) tb_error("====== PUSH @SR : @0x0236 value =====");
      if (mem234 !==16'h71d9) tb_error("====== PUSH @SR : @0x0234 value =====");
      if (mem232 !==16'h178d) tb_error("====== PUSH @SR : @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH @SR : @0x0230 value =====");
      if (mem22E !==16'h1234) tb_error("====== PUSH @SR : @0x022E value =====");
      if (mem22C !==16'h71d9) tb_error("====== PUSH @SR : @0x022C value =====");
      if (mem22A !==16'h178d) tb_error("====== PUSH @SR : @0x022A value =====");
      if (mem228 !==16'h0000) tb_error("====== PUSH @SR : @0x0228 value =====");

      // Addressing mode: SR
      @(r15==16'hF600);
      if (r1     !==16'h1234) tb_error("====== PUSH @SR : SP value      =====");
      if (mem250 !==16'h75e2) tb_error("====== PUSH @SR : @0x0250 value =====");
      if (mem24E !==16'h1cc4) tb_error("====== PUSH @SR : @0x024E value =====");
      if (mem24C !==16'h12a6) tb_error("====== PUSH @SR : @0x024c value =====");
      if (mem24A !==16'h5679) tb_error("====== PUSH @SR : @0x024a value =====");
      if (mem248 !==16'h9a6a) tb_error("====== PUSH @SR : @0x0248 value =====");
      if (mem246 !==16'hde97) tb_error("====== PUSH @SR : @0x0246 value =====");
      if (mem244 !==16'h0f4c) tb_error("====== PUSH @SR : @0x0244 value =====");
      if (mem242 !==16'hcbc3) tb_error("====== PUSH @SR : @0x0242 value =====");
      if (mem240 !==16'h870e) tb_error("====== PUSH @SR : @0x0240 value =====");
      if (mem23E !==16'h43fe) tb_error("====== PUSH @SR : @0x023e value =====");
      if (mem23C !==16'h1fc2) tb_error("====== PUSH @SR : @0x023c value =====");
      if (mem23A !==16'h3d3b) tb_error("====== PUSH @SR : @0x023a value =====");
      if (mem238 !==16'h71d9) tb_error("====== PUSH @SR : @0x0238 value =====");
      if (mem236 !==16'h178d) tb_error("====== PUSH @SR : @0x0236 value =====");
      if (mem234 !==16'h71d9) tb_error("====== PUSH @SR : @0x0234 value =====");
      if (mem232 !==16'h178d) tb_error("====== PUSH @SR : @0x0232 value =====");
      if (mem230 !==16'h0000) tb_error("====== PUSH @SR : @0x0230 value =====");
      if (mem22E !==16'h1234) tb_error("====== PUSH @SR : @0x022E value =====");
      if (mem22C !==16'h71d9) tb_error("====== PUSH @SR : @0x022C value =====");
      if (mem22A !==16'h178d) tb_error("====== PUSH @SR : @0x022A value =====");
      if (mem228 !==16'h0000) tb_error("====== PUSH @SR : @0x0228 value =====");
    
      stimulus_done = 1;
   end

