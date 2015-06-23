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
/*                   TWO-OPERAND ARITHMETIC: MOV INSTRUCTION                 */
/*---------------------------------------------------------------------------*/
/* Test the MOV instruction with all addressing modes                        */
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

      // Initialize memory
      //--------------------------------------------------------

      @(mem200==16'h0001);
      if (mem200 !== 16'h0001) tb_error("====== Initialize memory error: @0x200 =====");
      if (mem202 !== 16'h0000) tb_error("====== Initialize memory error: @0x202 =====");
      if (mem204 !== 16'h1111) tb_error("====== Initialize memory error: @0x204 =====");
      if (mem206 !== 16'h2222) tb_error("====== Initialize memory error: @0x206 =====");
      if (mem208 !== 16'h3333) tb_error("====== Initialize memory error: @0x208 =====");
      if (mem20A !== 16'h4444) tb_error("====== Initialize memory error: @0x20A =====");
      if (mem20C !== 16'h5555) tb_error("====== Initialize memory error: @0x20C =====");
      if (mem20E !== 16'h6666) tb_error("====== Initialize memory error: @0x20E =====");
      if (mem210 !== 16'h7777) tb_error("====== Initialize memory error: @0x210 =====");
      if (mem212 !== 16'h8888) tb_error("====== Initialize memory error: @0x212 =====");
      if (mem214 !== 16'h9999) tb_error("====== Initialize memory error: @0x214 =====");
      if (mem216 !== 16'hAAAA) tb_error("====== Initialize memory error: @0x216 =====");
      if (mem218 !== 16'hBBBB) tb_error("====== Initialize memory error: @0x218 =====");
      if (mem21A !== 16'hCCCC) tb_error("====== Initialize memory error: @0x21A =====");
      if (mem21C !== 16'hDDDD) tb_error("====== Initialize memory error: @0x21C =====");
      if (mem21E !== 16'hEEEE) tb_error("====== Initialize memory error: @0x21E =====");
      if (mem220 !== 16'hFFFF) tb_error("====== Initialize memory error: @0x220 =====");
      if (mem222 !== 16'h1122) tb_error("====== Initialize memory error: @0x222 =====");

      // Auto-increment: R1
      //--------------------------------------------------------
      @(mem200==16'h1000);
      if (r1     !== (`DMEM_BASE+16'h0004)) tb_error("====== Auto-increment (R1): R1     - test 1 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R1): R2     - test 1 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R1): R3     - test 1 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R1): R4     - test 1 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R1): R5     - test 1 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R1): R6     - test 1 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R1): R7     - test 1 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R1): R8     - test 1 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R1): R9     - test 1 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R1): R10    - test 1 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R1): R11    - test 1 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R1): R12    - test 1 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R1): R13    - test 1 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R1): R14    - test 1 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R1): R15    - test 1 =====");
      if (mem202 !== 16'h0000)              tb_error("====== Auto-increment (R1): @0x202 - test 1 =====");

      @(mem200==16'h1001);
      if (r1     !== (`DMEM_BASE+16'h0006)) tb_error("====== Auto-increment (R1): R1     - test 2 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R1): R2     - test 2 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R1): R3     - test 2 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R1): R4     - test 2 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R1): R5     - test 2 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R1): R6     - test 2 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R1): R7     - test 2 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R1): R8     - test 2 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R1): R9     - test 2 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R1): R10    - test 2 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R1): R11    - test 2 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R1): R12    - test 2 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R1): R13    - test 2 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R1): R14    - test 2 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R1): R15    - test 2 =====");
      if (mem202 !== 16'h1111)              tb_error("====== Auto-increment (R1): @0x202 - test 2 =====");

      @(mem200==16'h1002);
      if (r1     !== (`DMEM_BASE+16'h0008)) tb_error("====== Auto-increment (R1): R1     - test 3 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R1): R2     - test 3 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R1): R3     - test 3 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R1): R4     - test 3 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R1): R5     - test 3 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R1): R6     - test 3 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R1): R7     - test 3 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R1): R8     - test 3 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R1): R9     - test 3 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R1): R10    - test 3 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R1): R11    - test 3 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R1): R12    - test 3 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R1): R13    - test 3 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R1): R14    - test 3 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R1): R15    - test 3 =====");
      if (mem202 !== 16'h2222)              tb_error("====== Auto-increment (R1): @0x202 - test 3 =====");


      // Auto-increment: R2 (@R2+ addressing mode generated constant 8)
      //----------------------------------------------------------------
      @(mem200==16'h2000);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R2): R1     - test 1 =====");
      if (r2     !== 16'h0004)              tb_error("====== Auto-increment (R2): R2     - test 1 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R2): R3     - test 1 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R2): R4     - test 1 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R2): R5     - test 1 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R2): R6     - test 1 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R2): R7     - test 1 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R2): R8     - test 1 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R2): R9     - test 1 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R2): R10    - test 1 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R2): R11    - test 1 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R2): R12    - test 1 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R2): R13    - test 1 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R2): R14    - test 1 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R2): R15    - test 1 =====");
      if (mem202 !== 16'h0000)              tb_error("====== Auto-increment (R2): @0x202 - test 1 =====");

      @(mem200==16'h2001);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R2): R1     - test 2 =====");
      if (r2     !== 16'h0004)              tb_error("====== Auto-increment (R2): R2     - test 2 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R2): R3     - test 2 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R2): R4     - test 2 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R2): R5     - test 2 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R2): R6     - test 2 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R2): R7     - test 2 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R2): R8     - test 2 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R2): R9     - test 2 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R2): R10    - test 2 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R2): R11    - test 2 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R2): R12    - test 2 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R2): R13    - test 2 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R2): R14    - test 2 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R2): R15    - test 2 =====");
      if (mem202 !== 16'h0008)              tb_error("====== Auto-increment (R2): @0x202 - test 2 =====");

      @(mem200==16'h2002);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R2): R1     - test 3 =====");
      if (r2     !== 16'h0004)              tb_error("====== Auto-increment (R2): R2     - test 3 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R2): R3     - test 3 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R2): R4     - test 3 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R2): R5     - test 3 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R2): R6     - test 3 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R2): R7     - test 3 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R2): R8     - test 3 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R2): R9     - test 3 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R2): R10    - test 3 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R2): R11    - test 3 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R2): R12    - test 3 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R2): R13    - test 3 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R2): R14    - test 3 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R2): R15    - test 3 =====");
      if (mem202 !== 16'h0008)              tb_error("====== Auto-increment (R2): @0x202 - test 3 =====");


      // Auto-increment: R3
      //--------------------------------------------------------
      @(mem200==16'h3000);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R3): R1     - test 1 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R3): R2     - test 1 =====");
      if (r3     !== (`DMEM_BASE+16'h0008)) tb_error("====== Auto-increment (R3): R3     - test 1 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R3): R4     - test 1 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R3): R5     - test 1 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R3): R6     - test 1 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R3): R7     - test 1 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R3): R8     - test 1 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R3): R9     - test 1 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R3): R10    - test 1 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R3): R11    - test 1 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R3): R12    - test 1 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R3): R13    - test 1 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R3): R14    - test 1 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R3): R15    - test 1 =====");
      if (mem202 !== 16'h0000)              tb_error("====== Auto-increment (R3): @0x202 - test 1 =====");

      @(mem200==16'h3001);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R3): R1     - test 2 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R3): R2     - test 2 =====");
      if (r3     !== (`DMEM_BASE+16'h0008)) tb_error("====== Auto-increment (R3): R3     - test 2 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R3): R4     - test 2 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R3): R5     - test 2 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R3): R6     - test 2 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R3): R7     - test 2 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R3): R8     - test 2 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R3): R9     - test 2 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R3): R10    - test 2 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R3): R11    - test 2 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R3): R12    - test 2 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R3): R13    - test 2 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R3): R14    - test 2 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R3): R15    - test 2 =====");
      if (mem202 !== 16'hFFFF)              tb_error("====== Auto-increment (R3): @0x202 - test 2 =====");

      @(mem200==16'h3002);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R3): R1     - test 3 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R3): R2     - test 3 =====");
      if (r3     !== (`DMEM_BASE+16'h0008)) tb_error("====== Auto-increment (R3): R3     - test 3 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R3): R4     - test 3 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R3): R5     - test 3 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R3): R6     - test 3 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R3): R7     - test 3 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R3): R8     - test 3 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R3): R9     - test 3 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R3): R10    - test 3 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R3): R11    - test 3 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R3): R12    - test 3 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R3): R13    - test 3 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R3): R14    - test 3 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R3): R15    - test 3 =====");
      if (mem202 !== 16'hFFFF)              tb_error("====== Auto-increment (R3): @0x202 - test 3 =====");


      // Auto-increment: R4
      //--------------------------------------------------------
      @(mem200==16'h4000);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R4): R1     - test 1 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R4): R2     - test 1 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R4): R3     - test 1 =====");
      if (r4     !== (`DMEM_BASE+16'h000A)) tb_error("====== Auto-increment (R4): R4     - test 1 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R4): R5     - test 1 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R4): R6     - test 1 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R4): R7     - test 1 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R4): R8     - test 1 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R4): R9     - test 1 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R4): R10    - test 1 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R4): R11    - test 1 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R4): R12    - test 1 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R4): R13    - test 1 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R4): R14    - test 1 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R4): R15    - test 1 =====");
      if (mem202 !== 16'h0000)              tb_error("====== Auto-increment (R4): @0x202 - test 1 =====");

      @(mem200==16'h4001);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R4): R1     - test 2 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R4): R2     - test 2 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R4): R3     - test 2 =====");
      if (r4     !== (`DMEM_BASE+16'h000C)) tb_error("====== Auto-increment (R4): R4     - test 2 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R4): R5     - test 2 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R4): R6     - test 2 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R4): R7     - test 2 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R4): R8     - test 2 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R4): R9     - test 2 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R4): R10    - test 2 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R4): R11    - test 2 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R4): R12    - test 2 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R4): R13    - test 2 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R4): R14    - test 2 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R4): R15    - test 2 =====");
      if (mem202 !== 16'h4444)              tb_error("====== Auto-increment (R4): @0x202 - test 2 =====");

      @(mem200==16'h4002);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R4): R1     - test 3 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R4): R2     - test 3 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R4): R3     - test 3 =====");
      if (r4     !== (`DMEM_BASE+16'h000E)) tb_error("====== Auto-increment (R4): R4     - test 3 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R4): R5     - test 3 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R4): R6     - test 3 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R4): R7     - test 3 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R4): R8     - test 3 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R4): R9     - test 3 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R4): R10    - test 3 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R4): R11    - test 3 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R4): R12    - test 3 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R4): R13    - test 3 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R4): R14    - test 3 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R4): R15    - test 3 =====");
      if (mem202 !== 16'h5555)              tb_error("====== Auto-increment (R4): @0x202 - test 3 =====");


      // Auto-increment: R5
      //--------------------------------------------------------
      @(mem200==16'h5000);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R5): R1     - test 1 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R5): R2     - test 1 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R5): R3     - test 1 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R5): R4     - test 1 =====");
      if (r5     !== (`DMEM_BASE+16'h000C)) tb_error("====== Auto-increment (R5): R5     - test 1 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R5): R6     - test 1 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R5): R7     - test 1 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R5): R8     - test 1 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R5): R9     - test 1 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R5): R10    - test 1 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R5): R11    - test 1 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R5): R12    - test 1 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R5): R13    - test 1 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R5): R14    - test 1 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R5): R15    - test 1 =====");
      if (mem202 !== 16'h0000)              tb_error("====== Auto-increment (R5): @0x202 - test 1 =====");

      @(mem200==16'h5001);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R5): R1     - test 2 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R5): R2     - test 2 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R5): R3     - test 2 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R5): R4     - test 2 =====");
      if (r5     !== (`DMEM_BASE+16'h000E)) tb_error("====== Auto-increment (R5): R5     - test 2 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R5): R6     - test 2 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R5): R7     - test 2 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R5): R8     - test 2 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R5): R9     - test 2 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R5): R10    - test 2 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R5): R11    - test 2 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R5): R12    - test 2 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R5): R13    - test 2 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R5): R14    - test 2 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R5): R15    - test 2 =====");
      if (mem202 !== 16'h5555)              tb_error("====== Auto-increment (R5): @0x202 - test 2 =====");

      @(mem200==16'h5002);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R5): R1     - test 3 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R5): R2     - test 3 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R5): R3     - test 3 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R5): R4     - test 3 =====");
      if (r5     !== (`DMEM_BASE+16'h0010)) tb_error("====== Auto-increment (R5): R5     - test 3 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R5): R6     - test 3 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R5): R7     - test 3 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R5): R8     - test 3 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R5): R9     - test 3 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R5): R10    - test 3 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R5): R11    - test 3 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R5): R12    - test 3 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R5): R13    - test 3 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R5): R14    - test 3 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R5): R15    - test 3 =====");
      if (mem202 !== 16'h6666)              tb_error("====== Auto-increment (R5): @0x202 - test 3 =====");


      // Auto-increment: R6
      //--------------------------------------------------------
      @(mem200==16'h6000);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R6): R1     - test 1 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R6): R2     - test 1 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R6): R3     - test 1 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R6): R4     - test 1 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R6): R5     - test 1 =====");
      if (r6     !== (`DMEM_BASE+16'h000E)) tb_error("====== Auto-increment (R6): R6     - test 1 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R6): R7     - test 1 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R6): R8     - test 1 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R6): R9     - test 1 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R6): R10    - test 1 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R6): R11    - test 1 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R6): R12    - test 1 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R6): R13    - test 1 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R6): R14    - test 1 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R6): R15    - test 1 =====");
      if (mem202 !== 16'h0000)              tb_error("====== Auto-increment (R6): @0x202 - test 1 =====");

      @(mem200==16'h6001);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R6): R1     - test 2 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R6): R2     - test 2 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R6): R3     - test 2 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R6): R4     - test 2 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R6): R5     - test 2 =====");
      if (r6     !== (`DMEM_BASE+16'h0010)) tb_error("====== Auto-increment (R6): R6     - test 2 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R6): R7     - test 2 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R6): R8     - test 2 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R6): R9     - test 2 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R6): R10    - test 2 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R6): R11    - test 2 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R6): R12    - test 2 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R6): R13    - test 2 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R6): R14    - test 2 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R6): R15    - test 2 =====");
      if (mem202 !== 16'h6666)              tb_error("====== Auto-increment (R6): @0x202 - test 2 =====");

      @(mem200==16'h6002);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R6): R1     - test 3 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R6): R2     - test 3 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R6): R3     - test 3 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R6): R4     - test 3 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R6): R5     - test 3 =====");
      if (r6     !== (`DMEM_BASE+16'h0012)) tb_error("====== Auto-increment (R6): R6     - test 3 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R6): R7     - test 3 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R6): R8     - test 3 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R6): R9     - test 3 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R6): R10    - test 3 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R6): R11    - test 3 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R6): R12    - test 3 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R6): R13    - test 3 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R6): R14    - test 3 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R6): R15    - test 3 =====");
      if (mem202 !== 16'h7777)              tb_error("====== Auto-increment (R6): @0x202 - test 3 =====");


      // Auto-increment: R7
      //--------------------------------------------------------
      @(mem200==16'h7000);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R7): R1     - test 1 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R7): R2     - test 1 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R7): R3     - test 1 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R7): R4     - test 1 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R7): R5     - test 1 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R7): R6     - test 1 =====");
      if (r7     !== (`DMEM_BASE+16'h0010)) tb_error("====== Auto-increment (R7): R7     - test 1 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R7): R8     - test 1 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R7): R9     - test 1 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R7): R10    - test 1 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R7): R11    - test 1 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R7): R12    - test 1 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R7): R13    - test 1 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R7): R14    - test 1 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R7): R15    - test 1 =====");
      if (mem202 !== 16'h0000)              tb_error("====== Auto-increment (R7): @0x202 - test 1 =====");

      @(mem200==16'h7001);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R7): R1     - test 2 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R7): R2     - test 2 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R7): R3     - test 2 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R7): R4     - test 2 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R7): R5     - test 2 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R7): R6     - test 2 =====");
      if (r7     !== (`DMEM_BASE+16'h0012)) tb_error("====== Auto-increment (R7): R7     - test 2 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R7): R8     - test 2 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R7): R9     - test 2 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R7): R10    - test 2 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R7): R11    - test 2 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R7): R12    - test 2 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R7): R13    - test 2 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R7): R14    - test 2 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R7): R15    - test 2 =====");
      if (mem202 !== 16'h7777)              tb_error("====== Auto-increment (R7): @0x202 - test 2 =====");

      @(mem200==16'h7002);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R7): R1     - test 3 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R7): R2     - test 3 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R7): R3     - test 3 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R7): R4     - test 3 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R7): R5     - test 3 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R7): R6     - test 3 =====");
      if (r7     !== (`DMEM_BASE+16'h0014)) tb_error("====== Auto-increment (R7): R7     - test 3 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R7): R8     - test 3 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R7): R9     - test 3 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R7): R10    - test 3 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R7): R11    - test 3 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R7): R12    - test 3 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R7): R13    - test 3 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R7): R14    - test 3 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R7): R15    - test 3 =====");
      if (mem202 !== 16'h8888)              tb_error("====== Auto-increment (R7): @0x202 - test 3 =====");


      // Auto-increment: R8
      //--------------------------------------------------------
      @(mem200==16'h8000);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R8): R1     - test 1 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R8): R2     - test 1 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R8): R3     - test 1 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R8): R4     - test 1 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R8): R5     - test 1 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R8): R6     - test 1 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R8): R7     - test 1 =====");
      if (r8     !== (`DMEM_BASE+16'h0012)) tb_error("====== Auto-increment (R8): R8     - test 1 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R8): R9     - test 1 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R8): R10    - test 1 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R8): R11    - test 1 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R8): R12    - test 1 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R8): R13    - test 1 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R8): R14    - test 1 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R8): R15    - test 1 =====");
      if (mem202 !== 16'h0000)              tb_error("====== Auto-increment (R8): @0x202 - test 1 =====");

      @(mem200==16'h8001);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R8): R1     - test 2 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R8): R2     - test 2 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R8): R3     - test 2 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R8): R4     - test 2 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R8): R5     - test 2 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R8): R6     - test 2 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R8): R7     - test 2 =====");
      if (r8     !== (`DMEM_BASE+16'h0014)) tb_error("====== Auto-increment (R8): R8     - test 2 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R8): R9     - test 2 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R8): R10    - test 2 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R8): R11    - test 2 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R8): R12    - test 2 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R8): R13    - test 2 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R8): R14    - test 2 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R8): R15    - test 2 =====");
      if (mem202 !== 16'h8888)              tb_error("====== Auto-increment (R8): @0x202 - test 2 =====");

      @(mem200==16'h8002);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R8): R1     - test 3 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R8): R2     - test 3 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R8): R3     - test 3 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R8): R4     - test 3 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R8): R5     - test 3 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R8): R6     - test 3 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R8): R7     - test 3 =====");
      if (r8     !== (`DMEM_BASE+16'h0016)) tb_error("====== Auto-increment (R8): R8     - test 3 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R8): R9     - test 3 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R8): R10    - test 3 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R8): R11    - test 3 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R8): R12    - test 3 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R8): R13    - test 3 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R8): R14    - test 3 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R8): R15    - test 3 =====");
      if (mem202 !== 16'h9999)              tb_error("====== Auto-increment (R8): @0x202 - test 3 =====");


      // Auto-increment: R9
      //--------------------------------------------------------
      @(mem200==16'h9000);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R9): R1     - test 1 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R9): R2     - test 1 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R9): R3     - test 1 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R9): R4     - test 1 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R9): R5     - test 1 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R9): R6     - test 1 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R9): R7     - test 1 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R9): R8     - test 1 =====");
      if (r9     !== (`DMEM_BASE+16'h0014)) tb_error("====== Auto-increment (R9): R9     - test 1 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R9): R10    - test 1 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R9): R11    - test 1 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R9): R12    - test 1 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R9): R13    - test 1 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R9): R14    - test 1 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R9): R15    - test 1 =====");
      if (mem202 !== 16'h0000)              tb_error("====== Auto-increment (R9): @0x202 - test 1 =====");

      @(mem200==16'h9001);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R9): R1     - test 2 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R9): R2     - test 2 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R9): R3     - test 2 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R9): R4     - test 2 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R9): R5     - test 2 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R9): R6     - test 2 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R9): R7     - test 2 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R9): R8     - test 2 =====");
      if (r9     !== (`DMEM_BASE+16'h0016)) tb_error("====== Auto-increment (R9): R9     - test 2 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R9): R10    - test 2 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R9): R11    - test 2 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R9): R12    - test 2 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R9): R13    - test 2 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R9): R14    - test 2 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R9): R15    - test 2 =====");
      if (mem202 !== 16'h9999)              tb_error("====== Auto-increment (R9): @0x202 - test 2 =====");

      @(mem200==16'h9002);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R9): R1     - test 3 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R9): R2     - test 3 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R9): R3     - test 3 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R9): R4     - test 3 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R9): R5     - test 3 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R9): R6     - test 3 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R9): R7     - test 3 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R9): R8     - test 3 =====");
      if (r9     !== (`DMEM_BASE+16'h0018)) tb_error("====== Auto-increment (R9): R9     - test 3 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R9): R10    - test 3 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R9): R11    - test 3 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R9): R12    - test 3 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R9): R13    - test 3 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R9): R14    - test 3 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R9): R15    - test 3 =====");
      if (mem202 !== 16'hAAAA)              tb_error("====== Auto-increment (R9): @0x202 - test 3 =====");


      // Auto-increment: R10
      //--------------------------------------------------------
      @(mem200==16'hA000);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R10): R1     - test 1 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R10): R2     - test 1 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R10): R3     - test 1 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R10): R4     - test 1 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R10): R5     - test 1 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R10): R6     - test 1 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R10): R7     - test 1 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R10): R8     - test 1 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R10): R9     - test 1 =====");
      if (r10    !== (`DMEM_BASE+16'h0016)) tb_error("====== Auto-increment (R10): R10    - test 1 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R10): R11    - test 1 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R10): R12    - test 1 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R10): R13    - test 1 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R10): R14    - test 1 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R10): R15    - test 1 =====");
      if (mem202 !== 16'h0000)              tb_error("====== Auto-increment (R10): @0x202 - test 1 =====");

      @(mem200==16'hA001);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R10): R1     - test 2 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R10): R2     - test 2 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R10): R3     - test 2 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R10): R4     - test 2 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R10): R5     - test 2 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R10): R6     - test 2 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R10): R7     - test 2 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R10): R8     - test 2 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R10): R9     - test 2 =====");
      if (r10    !== (`DMEM_BASE+16'h0018)) tb_error("====== Auto-increment (R10): R10    - test 2 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R10): R11    - test 2 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R10): R12    - test 2 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R10): R13    - test 2 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R10): R14    - test 2 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R10): R15    - test 2 =====");
      if (mem202 !== 16'hAAAA)              tb_error("====== Auto-increment (R10): @0x202 - test 2 =====");

      @(mem200==16'hA002);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R10): R1     - test 3 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R10): R2     - test 3 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R10): R3     - test 3 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R10): R4     - test 3 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R10): R5     - test 3 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R10): R6     - test 3 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R10): R7     - test 3 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R10): R8     - test 3 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R10): R9     - test 3 =====");
      if (r10    !== (`DMEM_BASE+16'h001A)) tb_error("====== Auto-increment (R10): R10    - test 3 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R10): R11    - test 3 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R10): R12    - test 3 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R10): R13    - test 3 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R10): R14    - test 3 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R10): R15    - test 3 =====");
      if (mem202 !== 16'hBBBB)              tb_error("====== Auto-increment (R10): @0x202 - test 3 =====");


      // Auto-increment: R11
      //--------------------------------------------------------
      @(mem200==16'hB000);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R11): R1     - test 1 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R11): R2     - test 1 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R11): R3     - test 1 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R11): R4     - test 1 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R11): R5     - test 1 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R11): R6     - test 1 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R11): R7     - test 1 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R11): R8     - test 1 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R11): R9     - test 1 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R11): R10    - test 1 =====");
      if (r11    !== (`DMEM_BASE+16'h0018)) tb_error("====== Auto-increment (R11): R11    - test 1 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R11): R12    - test 1 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R11): R13    - test 1 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R11): R14    - test 1 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R11): R15    - test 1 =====");
      if (mem202 !== 16'h0000)              tb_error("====== Auto-increment (R11): @0x202 - test 1 =====");

      @(mem200==16'hB001);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R11): R1     - test 2 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R11): R2     - test 2 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R11): R3     - test 2 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R11): R4     - test 2 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R11): R5     - test 2 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R11): R6     - test 2 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R11): R7     - test 2 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R11): R8     - test 2 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R11): R9     - test 2 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R11): R10    - test 2 =====");
      if (r11    !== (`DMEM_BASE+16'h001A)) tb_error("====== Auto-increment (R11): R11    - test 2 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R11): R12    - test 2 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R11): R13    - test 2 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R11): R14    - test 2 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R11): R15    - test 2 =====");
      if (mem202 !== 16'hBBBB)              tb_error("====== Auto-increment (R11): @0x202 - test 2 =====");

      @(mem200==16'hB002);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R11): R1     - test 3 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R11): R2     - test 3 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R11): R3     - test 3 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R11): R4     - test 3 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R11): R5     - test 3 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R11): R6     - test 3 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R11): R7     - test 3 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R11): R8     - test 3 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R11): R9     - test 3 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R11): R10    - test 3 =====");
      if (r11    !== (`DMEM_BASE+16'h001C)) tb_error("====== Auto-increment (R11): R11    - test 3 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R11): R12    - test 3 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R11): R13    - test 3 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R11): R14    - test 3 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R11): R15    - test 3 =====");
      if (mem202 !== 16'hCCCC)              tb_error("====== Auto-increment (R11): @0x202 - test 3 =====");


      // Auto-increment: R12
      //--------------------------------------------------------
      @(mem200==16'hC000);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R12): R1     - test 1 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R12): R2     - test 1 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R12): R3     - test 1 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R12): R4     - test 1 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R12): R5     - test 1 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R12): R6     - test 1 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R12): R7     - test 1 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R12): R8     - test 1 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R12): R9     - test 1 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R12): R10    - test 1 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R12): R11    - test 1 =====");
      if (r12    !== (`DMEM_BASE+16'h001A)) tb_error("====== Auto-increment (R12): R12    - test 1 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R12): R13    - test 1 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R12): R14    - test 1 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R12): R15    - test 1 =====");
      if (mem202 !== 16'h0000)              tb_error("====== Auto-increment (R12): @0x202 - test 1 =====");

      @(mem200==16'hC001);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R12): R1     - test 2 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R12): R2     - test 2 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R12): R3     - test 2 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R12): R4     - test 2 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R12): R5     - test 2 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R12): R6     - test 2 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R12): R7     - test 2 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R12): R8     - test 2 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R12): R9     - test 2 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R12): R10    - test 2 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R12): R11    - test 2 =====");
      if (r12    !== (`DMEM_BASE+16'h001C)) tb_error("====== Auto-increment (R12): R12    - test 2 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R12): R13    - test 2 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R12): R14    - test 2 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R12): R15    - test 2 =====");
      if (mem202 !== 16'hCCCC)              tb_error("====== Auto-increment (R12): @0x202 - test 2 =====");

      @(mem200==16'hC002);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R12): R1     - test 3 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R12): R2     - test 3 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R12): R3     - test 3 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R12): R4     - test 3 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R12): R5     - test 3 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R12): R6     - test 3 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R12): R7     - test 3 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R12): R8     - test 3 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R12): R9     - test 3 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R12): R10    - test 3 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R12): R11    - test 3 =====");
      if (r12    !== (`DMEM_BASE+16'h001E)) tb_error("====== Auto-increment (R12): R12    - test 3 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R12): R13    - test 3 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R12): R14    - test 3 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R12): R15    - test 3 =====");
      if (mem202 !== 16'hDDDD)              tb_error("====== Auto-increment (R12): @0x202 - test 3 =====");


      // Auto-increment: R13
      //--------------------------------------------------------
      @(mem200==16'hD000);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R13): R1     - test 1 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R13): R2     - test 1 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R13): R3     - test 1 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R13): R4     - test 1 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R13): R5     - test 1 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R13): R6     - test 1 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R13): R7     - test 1 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R13): R8     - test 1 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R13): R9     - test 1 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R13): R10    - test 1 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R13): R11    - test 1 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R13): R12    - test 1 =====");
      if (r13    !== (`DMEM_BASE+16'h001C)) tb_error("====== Auto-increment (R13): R13    - test 1 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R13): R14    - test 1 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R13): R15    - test 1 =====");
      if (mem202 !== 16'h0000)              tb_error("====== Auto-increment (R13): @0x202 - test 1 =====");

      @(mem200==16'hD001);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R13): R1     - test 2 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R13): R2     - test 2 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R13): R3     - test 2 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R13): R4     - test 2 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R13): R5     - test 2 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R13): R6     - test 2 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R13): R7     - test 2 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R13): R8     - test 2 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R13): R9     - test 2 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R13): R10    - test 2 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R13): R11    - test 2 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R13): R12    - test 2 =====");
      if (r13    !== (`DMEM_BASE+16'h001E)) tb_error("====== Auto-increment (R13): R13    - test 2 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R13): R14    - test 2 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R13): R15    - test 2 =====");
      if (mem202 !== 16'hDDDD)              tb_error("====== Auto-increment (R13): @0x202 - test 2 =====");

      @(mem200==16'hD002);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R13): R1     - test 3 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R13): R2     - test 3 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R13): R3     - test 3 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R13): R4     - test 3 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R13): R5     - test 3 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R13): R6     - test 3 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R13): R7     - test 3 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R13): R8     - test 3 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R13): R9     - test 3 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R13): R10    - test 3 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R13): R11    - test 3 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R13): R12    - test 3 =====");
      if (r13    !== (`DMEM_BASE+16'h0020)) tb_error("====== Auto-increment (R13): R13    - test 3 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R13): R14    - test 3 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R13): R15    - test 3 =====");
      if (mem202 !== 16'hEEEE)              tb_error("====== Auto-increment (R13): @0x202 - test 3 =====");


      // Auto-increment: R14
      //--------------------------------------------------------
      @(mem200==16'hE000);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R14): R1     - test 1 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R14): R2     - test 1 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R14): R3     - test 1 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R14): R4     - test 1 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R14): R5     - test 1 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R14): R6     - test 1 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R14): R7     - test 1 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R14): R8     - test 1 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R14): R9     - test 1 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R14): R10    - test 1 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R14): R11    - test 1 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R14): R12    - test 1 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R14): R13    - test 1 =====");
      if (r14    !== (`DMEM_BASE+16'h001E)) tb_error("====== Auto-increment (R14): R14    - test 1 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R14): R15    - test 1 =====");
      if (mem202 !== 16'h0000)              tb_error("====== Auto-increment (R14): @0x202 - test 1 =====");

      @(mem200==16'hE001);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R14): R1     - test 2 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R14): R2     - test 2 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R14): R3     - test 2 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R14): R4     - test 2 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R14): R5     - test 2 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R14): R6     - test 2 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R14): R7     - test 2 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R14): R8     - test 2 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R14): R9     - test 2 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R14): R10    - test 2 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R14): R11    - test 2 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R14): R12    - test 2 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R14): R13    - test 2 =====");
      if (r14    !== (`DMEM_BASE+16'h0020)) tb_error("====== Auto-increment (R14): R14    - test 2 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R14): R15    - test 2 =====");
      if (mem202 !== 16'hEEEE)              tb_error("====== Auto-increment (R14): @0x202 - test 2 =====");

      @(mem200==16'hE002);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R14): R1     - test 3 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R14): R2     - test 3 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R14): R3     - test 3 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R14): R4     - test 3 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R14): R5     - test 3 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R14): R6     - test 3 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R14): R7     - test 3 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R14): R8     - test 3 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R14): R9     - test 3 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R14): R10    - test 3 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R14): R11    - test 3 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R14): R12    - test 3 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R14): R13    - test 3 =====");
      if (r14    !== (`DMEM_BASE+16'h0022)) tb_error("====== Auto-increment (R14): R14    - test 3 =====");
      if (r15    !== 16'h0000)              tb_error("====== Auto-increment (R14): R15    - test 3 =====");
      if (mem202 !== 16'hFFFF)              tb_error("====== Auto-increment (R14): @0x202 - test 3 =====");


      // Auto-increment: R15
      //--------------------------------------------------------
      @(mem200==16'hF000);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R15): R1     - test 1 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R15): R2     - test 1 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R15): R3     - test 1 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R15): R4     - test 1 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R15): R5     - test 1 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R15): R6     - test 1 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R15): R7     - test 1 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R15): R8     - test 1 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R15): R9     - test 1 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R15): R10    - test 1 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R15): R11    - test 1 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R15): R12    - test 1 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R15): R13    - test 1 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R15): R14    - test 1 =====");
      if (r15    !== (`DMEM_BASE+16'h0020)) tb_error("====== Auto-increment (R15): R15    - test 1 =====");
      if (mem202 !== 16'h0000)              tb_error("====== Auto-increment (R15): @0x202 - test 1 =====");

      @(mem200==16'hF001);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R15): R1     - test 2 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R15): R2     - test 2 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R15): R3     - test 2 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R15): R4     - test 2 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R15): R5     - test 2 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R15): R6     - test 2 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R15): R7     - test 2 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R15): R8     - test 2 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R15): R9     - test 2 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R15): R10    - test 2 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R15): R11    - test 2 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R15): R12    - test 2 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R15): R13    - test 2 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R15): R14    - test 2 =====");
      if (r15    !== (`DMEM_BASE+16'h0022)) tb_error("====== Auto-increment (R15): R15    - test 2 =====");
      if (mem202 !== 16'hFFFF)              tb_error("====== Auto-increment (R15): @0x202 - test 2 =====");

      @(mem200==16'hF002);
      if (r1     !== 16'h0000)              tb_error("====== Auto-increment (R15): R1     - test 3 =====");
      if (r2     !== 16'h0000)              tb_error("====== Auto-increment (R15): R2     - test 3 =====");
      if (r3     !== 16'h0000)              tb_error("====== Auto-increment (R15): R3     - test 3 =====");
      if (r4     !== 16'h0000)              tb_error("====== Auto-increment (R15): R4     - test 3 =====");
      if (r5     !== 16'h0000)              tb_error("====== Auto-increment (R15): R5     - test 3 =====");
      if (r6     !== 16'h0000)              tb_error("====== Auto-increment (R15): R6     - test 3 =====");
      if (r7     !== 16'h0000)              tb_error("====== Auto-increment (R15): R7     - test 3 =====");
      if (r8     !== 16'h0000)              tb_error("====== Auto-increment (R15): R8     - test 3 =====");
      if (r9     !== 16'h0000)              tb_error("====== Auto-increment (R15): R9     - test 3 =====");
      if (r10    !== 16'h0000)              tb_error("====== Auto-increment (R15): R10    - test 3 =====");
      if (r11    !== 16'h0000)              tb_error("====== Auto-increment (R15): R11    - test 3 =====");
      if (r12    !== 16'h0000)              tb_error("====== Auto-increment (R15): R12    - test 3 =====");
      if (r13    !== 16'h0000)              tb_error("====== Auto-increment (R15): R13    - test 3 =====");
      if (r14    !== 16'h0000)              tb_error("====== Auto-increment (R15): R14    - test 3 =====");
      if (r15    !== (`DMEM_BASE+16'h0024)) tb_error("====== Auto-increment (R15): R15    - test 3 =====");
      if (mem202 !== 16'h1122)              tb_error("====== Auto-increment (R15): @0x202 - test 3 =====");





      stimulus_done = 1;
   end
