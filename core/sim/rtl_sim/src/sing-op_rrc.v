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
/*                 SINGLE-OPERAND ARITHMETIC: RRC[.B] INSTRUCTION            */
/*---------------------------------------------------------------------------*/
/* Test the RRC[.B] instruction.                                             */
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


      // RRC (WORD MODE)
      //--------------------------------------------------------

      // Addressing mode: Rn
      @(r15==16'h1000);
      if (r4     !==16'h1999) tb_error("====== RRC (Rn mode): test 1 (result) =====");
      if (r5     !==16'h0000) tb_error("====== RRC (Rn mode): test 1 (C flag) =====");

      if (r6     !==16'h1999) tb_error("====== RRC (Rn mode): test 2 (result) =====");
      if (r7     !==16'h0001) tb_error("====== RRC (Rn mode): test 2 (C flag) =====");

      if (r8     !==16'h9999) tb_error("====== RRC (Rn mode): test 3 (result) =====");
      if (r9     !==16'h0004) tb_error("====== RRC (Rn mode): test 3 (C flag) =====");

      if (r10    !==16'h9999) tb_error("====== RRC (Rn mode): test 4 (result) =====");
      if (r11    !==16'h0005) tb_error("====== RRC (Rn mode): test 4 (C flag) =====");


      // Addressing mode: @Rn
      @(r15==16'h2000);
      if (mem200 !==16'h1999)             tb_error("====== RRC (@Rn mode): test 1 (result)  =====");
      if (r4     !==(`PER_SIZE+16'h0000)) tb_error("====== RRC (@Rn mode): test 1 (address) =====");
      if (r5     !==16'h0000)             tb_error("====== RRC (@Rn mode): test 1 (C flag)  =====");

      if (mem202 !==16'h1999)             tb_error("====== RRC (@Rn mode): test 2 (result)  =====");
      if (r6     !==(`PER_SIZE+16'h0002)) tb_error("====== RRC (@Rn mode): test 2 (address) =====");
      if (r7     !==16'h0001)             tb_error("====== RRC (@Rn mode): test 2 (C flag)  =====");

      if (mem204 !==16'h9999)             tb_error("====== RRC (@Rn mode): test 3 (result)  =====");
      if (r8     !==(`PER_SIZE+16'h0004)) tb_error("====== RRC (@Rn mode): test 3 (address) =====");
      if (r9     !==16'h0004)             tb_error("====== RRC (@Rn mode): test 3 (C flag)  =====");

      if (mem206 !==16'h9999)             tb_error("====== RRC (@Rn mode): test 4 (result)  =====");
      if (r10    !==(`PER_SIZE+16'h0006)) tb_error("====== RRC (@Rn mode): test 4 (address) =====");
      if (r11    !==16'h0005)             tb_error("====== RRC (@Rn mode): test 4 (C flag)  =====");


      // Addressing mode: @Rn+
      @(r15==16'h3000);
      if (mem208 !==16'h1999)             tb_error("====== RRC (@Rn+ mode): test 1 (result)  =====");
      if (r4     !==(`PER_SIZE+16'h000A)) tb_error("====== RRC (@Rn+ mode): test 1 (address) =====");
      if (r5     !==16'h0000)             tb_error("====== RRC (@Rn+ mode): test 1 (C flag)  =====");

      if (mem20A !==16'h1999)             tb_error("====== RRC (@Rn+ mode): test 2 (result)  =====");
      if (r6     !==(`PER_SIZE+16'h000C)) tb_error("====== RRC (@Rn+ mode): test 2 (address) =====");
      if (r7     !==16'h0001)             tb_error("====== RRC (@Rn+ mode): test 2 (C flag)  =====");

      if (mem20C !==16'h9999)             tb_error("====== RRC (@Rn+ mode): test 3 (result)  =====");
      if (r8     !==(`PER_SIZE+16'h000E)) tb_error("====== RRC (@Rn+ mode): test 3 (address) =====");
      if (r9     !==16'h0004)             tb_error("====== RRC (@Rn+ mode): test 3 (C flag)  =====");

      if (mem20E !==16'h9999)             tb_error("====== RRC (@Rn+ mode): test 4 (result)  =====");
      if (r10    !==(`PER_SIZE+16'h0010)) tb_error("====== RRC (@Rn+ mode): test 4 (address) =====");
      if (r11    !==16'h0005)             tb_error("====== RRC (@Rn+ mode): test 4 (C flag)  =====");


      // Addressing mode: X(Rn)
      @(r15==16'h4000);
      if (mem210 !==16'h1999) tb_error("====== RRC (X(Rn) mode): test 1 (result)  =====");
      if (r5     !==16'h0000) tb_error("====== RRC (X(Rn) mode): test 1 (C flag)  =====");

      if (mem212 !==16'h1999) tb_error("====== RRC (X(Rn) mode): test 2 (result)  =====");
      if (r7     !==16'h0001) tb_error("====== RRC (X(Rn) mode): test 2 (C flag)  =====");

      if (mem214 !==16'h9999) tb_error("====== RRC (X(Rn) mode): test 3 (result)  =====");
      if (r9     !==16'h0004) tb_error("====== RRC (X(Rn) mode): test 3 (C flag)  =====");

      if (mem216 !==16'h9999) tb_error("====== RRC (X(Rn) mode): test 4 (result)  =====");
      if (r11    !==16'h0005) tb_error("====== RRC (X(Rn) mode): test 4 (C flag)  =====");


      // Addressing mode: EDE
      @(r15==16'h5000);
      if (mem218 !==16'h1999) tb_error("====== RRC (EDE mode): test 1 (result)  =====");
      if (r5     !==16'h0000) tb_error("====== RRC (EDE mode): test 1 (C flag)  =====");

      if (mem21A !==16'h1999) tb_error("====== RRC (EDE mode): test 2 (result)  =====");
      if (r7     !==16'h0001) tb_error("====== RRC (EDE mode): test 2 (C flag)  =====");

      if (mem21C !==16'h9999) tb_error("====== RRC (EDE mode): test 3 (result)  =====");
      if (r9     !==16'h0004) tb_error("====== RRC (EDE mode): test 3 (C flag)  =====");

      if (mem21E !==16'h9999) tb_error("====== RRC (EDE mode): test 4 (result)  =====");
      if (r11    !==16'h0005) tb_error("====== RRC (EDE mode): test 4 (C flag)  =====");


      // Addressing mode: &EDE
      @(r15==16'h6000);
      if (mem220 !==16'h1999) tb_error("====== RRC (&EDE mode): test 1 (result)  =====");
      if (r5     !==16'h0000) tb_error("====== RRC (&EDE mode): test 1 (C flag)  =====");

      if (mem222 !==16'h1999) tb_error("====== RRC (&EDE mode): test 2 (result)  =====");
      if (r7     !==16'h0001) tb_error("====== RRC (&EDE mode): test 2 (C flag)  =====");

      if (mem224 !==16'h9999) tb_error("====== RRC (&EDE mode): test 3 (result)  =====");
      if (r9     !==16'h0004) tb_error("====== RRC (&EDE mode): test 3 (C flag)  =====");

      if (mem226 !==16'h9999) tb_error("====== RRC (&EDE mode): test 4 (result)  =====");
      if (r11    !==16'h0005) tb_error("====== RRC (&EDE mode): test 4 (C flag)  =====");


      // Clear Memory
      //--------------------------------------------------------
      @(r15==16'h7000);


      // RRC (BYTE MODE)
      //--------------------------------------------------------

      // Addressing mode: Rn
      @(r15==16'h8000);
      if (r4     !==16'h0019) tb_error("====== RRC.B (Rn mode): test 1 (result) =====");
      if (r5     !==16'h0000) tb_error("====== RRC.B (Rn mode): test 1 (C flag) =====");

      if (r6     !==16'h0019) tb_error("====== RRC.B (Rn mode): test 2 (result) =====");
      if (r7     !==16'h0001) tb_error("====== RRC.B (Rn mode): test 2 (C flag) =====");

      if (r8     !==16'h0099) tb_error("====== RRC.B (Rn mode): test 3 (result) =====");
      if (r9     !==16'h0004) tb_error("====== RRC.B (Rn mode): test 3 (C flag) =====");

      if (r10    !==16'h0099) tb_error("====== RRC.B (Rn mode): test 4 (result) =====");
      if (r11    !==16'h0005) tb_error("====== RRC.B (Rn mode): test 4 (C flag) =====");


      // Addressing mode: @Rn (low byte)
      @(r15==16'h9000);
      if (mem200 !==16'h2519)             tb_error("====== RRC.B (@Rn mode): test 1, low byte (result)  =====");
      if (r4     !==(`PER_SIZE+16'h0000)) tb_error("====== RRC.B (@Rn mode): test 1, low byte (address) =====");
      if (r5     !==16'h0000)             tb_error("====== RRC.B (@Rn mode): test 1, low byte (C flag)  =====");

      if (mem202 !==16'h2519)             tb_error("====== RRC.B (@Rn mode): test 2, low byte (result)  =====");
      if (r6     !==(`PER_SIZE+16'h0002)) tb_error("====== RRC.B (@Rn mode): test 2, low byte (address) =====");
      if (r7     !==16'h0001)             tb_error("====== RRC.B (@Rn mode): test 2, low byte (C flag)  =====");

      if (mem204 !==16'h2599)             tb_error("====== RRC.B (@Rn mode): test 3, low byte (result)  =====");
      if (r8     !==(`PER_SIZE+16'h0004)) tb_error("====== RRC.B (@Rn mode): test 3, low byte (address) =====");
      if (r9     !==16'h0004)             tb_error("====== RRC.B (@Rn mode): test 3, low byte (C flag)  =====");

      if (mem206 !==16'h2599)             tb_error("====== RRC.B (@Rn mode): test 4, low byte (result)  =====");
      if (r10    !==(`PER_SIZE+16'h0006)) tb_error("====== RRC.B (@Rn mode): test 4, low byte (address) =====");
      if (r11    !==16'h0005)             tb_error("====== RRC.B (@Rn mode): test 4, low byte (C flag)  =====");

      // Addressing mode: @Rn (high byte)
      @(r15==16'h9001);
      if (mem208 !==16'h1925)             tb_error("====== RRC.B (@Rn mode): test 1, high byte (result)  =====");
      if (r4     !==(`PER_SIZE+16'h0009)) tb_error("====== RRC.B (@Rn mode): test 1, high byte (address) =====");
      if (r5     !==16'h0000)             tb_error("====== RRC.B (@Rn mode): test 1, high byte (C flag)  =====");

      if (mem20A !==16'h1925)             tb_error("====== RRC.B (@Rn mode): test 2, high byte (result)  =====");
      if (r6     !==(`PER_SIZE+16'h000B)) tb_error("====== RRC.B (@Rn mode): test 2, high byte (address) =====");
      if (r7     !==16'h0001)             tb_error("====== RRC.B (@Rn mode): test 2, high byte (C flag)  =====");

      if (mem20C !==16'h9925)             tb_error("====== RRC.B (@Rn mode): test 3, high byte (result)  =====");
      if (r8     !==(`PER_SIZE+16'h000D)) tb_error("====== RRC.B (@Rn mode): test 3, high byte (address) =====");
      if (r9     !==16'h0004)             tb_error("====== RRC.B (@Rn mode): test 3, high byte (C flag)  =====");

      if (mem20E !==16'h9925)             tb_error("====== RRC.B (@Rn mode): test 4, high byte (result)  =====");
      if (r10    !==(`PER_SIZE+16'h000F)) tb_error("====== RRC.B (@Rn mode): test 4, high byte (address) =====");
      if (r11    !==16'h0005)             tb_error("====== RRC.B (@Rn mode): test 4, high byte (C flag)  =====");


      // Addressing mode: @Rn+ (low byte)
      @(r15==16'hA000);
      if (mem210 !==16'h2519)             tb_error("====== RRC.B (@Rn+ mode): test 1, low byte (result)  =====");
      if (r4     !==(`PER_SIZE+16'h0011)) tb_error("====== RRC.B (@Rn+ mode): test 1, low byte (address) =====");
      if (r5     !==16'h0000)             tb_error("====== RRC.B (@Rn+ mode): test 1, low byte (C flag)  =====");

      if (mem212 !==16'h2519)             tb_error("====== RRC.B (@Rn+ mode): test 2, low byte (result)  =====");
      if (r6     !==(`PER_SIZE+16'h0013)) tb_error("====== RRC.B (@Rn+ mode): test 2, low byte (address) =====");
      if (r7     !==16'h0001)             tb_error("====== RRC.B (@Rn+ mode): test 2, low byte (C flag)  =====");

      if (mem214 !==16'h2599)             tb_error("====== RRC.B (@Rn+ mode): test 3, low byte (result)  =====");
      if (r8     !==(`PER_SIZE+16'h0015)) tb_error("====== RRC.B (@Rn+ mode): test 3, low byte (address) =====");
      if (r9     !==16'h0004)             tb_error("====== RRC.B (@Rn+ mode): test 3, low byte (C flag)  =====");

      if (mem216 !==16'h2599)             tb_error("====== RRC.B (@Rn+ mode): test 4, low byte (result)  =====");
      if (r10    !==(`PER_SIZE+16'h0017)) tb_error("====== RRC.B (@Rn+ mode): test 4, low byte (address) =====");
      if (r11    !==16'h0005)             tb_error("====== RRC.B (@Rn+ mode): test 4, low byte (C flag)  =====");

      // Addressing mode: @Rn+ (high byte)
      @(r15==16'hA001);
      if (mem218 !==16'h1925)             tb_error("====== RRC.B (@Rn+ mode): test 1, high byte (result)  =====");
      if (r4     !==(`PER_SIZE+16'h001A)) tb_error("====== RRC.B (@Rn+ mode): test 1, high byte (address) =====");
      if (r5     !==16'h0000)             tb_error("====== RRC.B (@Rn+ mode): test 1, high byte (C flag)  =====");

      if (mem21A !==16'h1925)             tb_error("====== RRC.B (@Rn+ mode): test 2, high byte (result)  =====");
      if (r6     !==(`PER_SIZE+16'h001C)) tb_error("====== RRC.B (@Rn+ mode): test 2, high byte (address) =====");
      if (r7     !==16'h0001)             tb_error("====== RRC.B (@Rn+ mode): test 2, high byte (C flag)  =====");

      if (mem21C !==16'h9925)             tb_error("====== RRC.B (@Rn+ mode): test 3, high byte (result)  =====");
      if (r8     !==(`PER_SIZE+16'h001E)) tb_error("====== RRC.B (@Rn+ mode): test 3, high byte (address) =====");
      if (r9     !==16'h0004)             tb_error("====== RRC.B (@Rn+ mode): test 3, high byte (C flag)  =====");

      if (mem21E !==16'h9925)             tb_error("====== RRC.B (@Rn+ mode): test 4, high byte (result)  =====");
      if (r10    !==(`PER_SIZE+16'h0020)) tb_error("====== RRC.B (@Rn+ mode): test 4, high byte (address) =====");
      if (r11    !==16'h0005)             tb_error("====== RRC.B (@Rn+ mode): test 4, high byte (C flag)  =====");


      // Addressing mode: X(Rn) (low byte)
      @(r15==16'hB000);
      if (mem220 !==16'h2519) tb_error("====== RRC.B (X(Rn) mode): test 1, low byte (result)  =====");
      if (r5     !==16'h0000) tb_error("====== RRC.B (X(Rn) mode): test 1, low byte (C flag)  =====");

      if (mem222 !==16'h2519) tb_error("====== RRC.B (X(Rn) mode): test 2, low byte (result)  =====");
      if (r7     !==16'h0001) tb_error("====== RRC.B (X(Rn) mode): test 2, low byte (C flag)  =====");

      if (mem224 !==16'h2599) tb_error("====== RRC.B (X(Rn) mode): test 3, low byte (result)  =====");
      if (r9     !==16'h0004) tb_error("====== RRC.B (X(Rn) mode): test 3, low byte (C flag)  =====");

      if (mem226 !==16'h2599) tb_error("====== RRC.B (X(Rn) mode): test 4, low byte (result)  =====");
      if (r11    !==16'h0005) tb_error("====== RRC.B (X(Rn) mode): test 4, low byte (C flag)  =====");

      // Addressing mode: X(Rn) (high byte)
      @(r15==16'hB001);
      if (mem228 !==16'h1925) tb_error("====== RRC.B (X(Rn) mode): test 1, high byte (result)  =====");
      if (r5     !==16'h0000) tb_error("====== RRC.B (X(Rn) mode): test 1, high byte (C flag)  =====");

      if (mem22A !==16'h1925) tb_error("====== RRC.B (X(Rn) mode): test 2, high byte (result)  =====");
      if (r7     !==16'h0001) tb_error("====== RRC.B (X(Rn) mode): test 2, high byte (C flag)  =====");

      if (mem22C !==16'h9925) tb_error("====== RRC.B (X(Rn) mode): test 3, high byte (result)  =====");
      if (r9     !==16'h0004) tb_error("====== RRC.B (X(Rn) mode): test 3, high byte (C flag)  =====");

      if (mem22E !==16'h9925) tb_error("====== RRC.B (X(Rn) mode): test 4, high byte (result)  =====");
      if (r11    !==16'h0005) tb_error("====== RRC.B (X(Rn) mode): test 4, high byte (C flag)  =====");

      // Addressing mode: EDE (low byte)
      @(r15==16'hC000);
      if (mem230 !==16'h2519) tb_error("====== RRC.B (EDE mode): test 1, low byte (result)  =====");
      if (r5     !==16'h0000) tb_error("====== RRC.B (EDE mode): test 1, low byte (C flag)  =====");

      if (mem232 !==16'h2519) tb_error("====== RRC.B (EDE mode): test 2, low byte (result)  =====");
      if (r7     !==16'h0001) tb_error("====== RRC.B (EDE mode): test 2, low byte (C flag)  =====");

      if (mem234 !==16'h2599) tb_error("====== RRC.B (EDE mode): test 3, low byte (result)  =====");
      if (r9     !==16'h0004) tb_error("====== RRC.B (EDE mode): test 3, low byte (C flag)  =====");

      if (mem236 !==16'h2599) tb_error("====== RRC.B (EDE mode): test 4, low byte (result)  =====");
      if (r11    !==16'h0005) tb_error("====== RRC.B (EDE mode): test 4, low byte (C flag)  =====");

      // Addressing mode: EDE (high byte)
      @(r15==16'hC001);
      if (mem238 !==16'h1925) tb_error("====== RRC.B (EDE mode): test 1, high byte (result)  =====");
      if (r5     !==16'h0000) tb_error("====== RRC.B (EDE mode): test 1, high byte (C flag)  =====");

      if (mem23A !==16'h1925) tb_error("====== RRC.B (EDE mode): test 2, high byte (result)  =====");
      if (r7     !==16'h0001) tb_error("====== RRC.B (EDE mode): test 2, high byte (C flag)  =====");

      if (mem23C !==16'h9925) tb_error("====== RRC.B (EDE mode): test 3, high byte (result)  =====");
      if (r9     !==16'h0004) tb_error("====== RRC.B (EDE mode): test 3, high byte (C flag)  =====");

      if (mem23E !==16'h9925) tb_error("====== RRC.B (EDE mode): test 4, high byte (result)  =====");
      if (r11    !==16'h0005) tb_error("====== RRC.B (EDE mode): test 4, high byte (C flag)  =====");


      // Addressing mode: &EDE (low byte)
      @(r15==16'hD000);
      if (mem240 !==16'h2519) tb_error("====== RRC.B (&EDE mode): test 1, low byte (result)  =====");
      if (r5     !==16'h0000) tb_error("====== RRC.B (&EDE mode): test 1, low byte (C flag)  =====");

      if (mem242 !==16'h2519) tb_error("====== RRC.B (&EDE mode): test 2, low byte (result)  =====");
      if (r7     !==16'h0001) tb_error("====== RRC.B (&EDE mode): test 2, low byte (C flag)  =====");

      if (mem244 !==16'h2599) tb_error("====== RRC.B (&EDE mode): test 3, low byte (result)  =====");
      if (r9     !==16'h0004) tb_error("====== RRC.B (&EDE mode): test 3, low byte (C flag)  =====");

      if (mem246 !==16'h2599) tb_error("====== RRC.B (&EDE mode): test 4, low byte (result)  =====");
      if (r11    !==16'h0005) tb_error("====== RRC.B (&EDE mode): test 4, low byte (C flag)  =====");

      // Addressing mode: &EDE (high byte)
      @(r15==16'hD001);
      if (mem248 !==16'h1925) tb_error("====== RRC.B (&EDE mode): test 1, high byte (result)  =====");
      if (r5     !==16'h0000) tb_error("====== RRC.B (&EDE mode): test 1, high byte (C flag)  =====");

      if (mem24A !==16'h1925) tb_error("====== RRC.B (&EDE mode): test 2, high byte (result)  =====");
      if (r7     !==16'h0001) tb_error("====== RRC.B (&EDE mode): test 2, high byte (C flag)  =====");

      if (mem24C !==16'h9925) tb_error("====== RRC.B (&EDE mode): test 3, high byte (result)  =====");
      if (r9     !==16'h0004) tb_error("====== RRC.B (&EDE mode): test 3, high byte (C flag)  =====");

      if (mem24E !==16'h9925) tb_error("====== RRC.B (&EDE mode): test 4, high byte (result)  =====");
      if (r11    !==16'h0005) tb_error("====== RRC.B (&EDE mode): test 4, high byte (C flag)  =====");

      stimulus_done = 1;
   end

