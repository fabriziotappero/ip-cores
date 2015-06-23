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
/*                   TWO-OPERAND ARITHMETIC: MOV.B INSTRUCTION               */
/*---------------------------------------------------------------------------*/
/* Test the MOV.B instruction with all addressing modes                      */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 134 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2012-03-22 21:31:06 +0100 (Thu, 22 Mar 2012) $          */
/*===========================================================================*/

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

      // Check reset values
      //--------------------------------------------------------
      if (r2 !==16'h0000) tb_error("R2  reset value");
      if (r3 !==16'h0000) tb_error("R3  reset value");
      if (r4 !==16'h0000) tb_error("R4  reset value");
      if (r5 !==16'h0000) tb_error("R5  reset value");
      if (r6 !==16'h0000) tb_error("R6  reset value");
      if (r7 !==16'h0000) tb_error("R7  reset value");
      if (r8 !==16'h0000) tb_error("R8  reset value");
      if (r9 !==16'h0000) tb_error("R9  reset value");
      if (r10!==16'h0000) tb_error("R10 reset value");
      if (r11!==16'h0000) tb_error("R11 reset value");
      if (r12!==16'h0000) tb_error("R12 reset value");
      if (r13!==16'h0000) tb_error("R13 reset value");
      if (r14!==16'h0000) tb_error("R14 reset value");
      if (r15!==16'h0000) tb_error("R15 reset value");


      // Make sure initialization worked fine
      //--------------------------------------------------------
      @(r15==16'h1000);

      if (r2 !==16'h0002) tb_error("R2  initialization");
      if (r3 !==16'h3333) tb_error("R3  initialization");
      if (r4 !==16'h4444) tb_error("R4  initialization");
      if (r5 !==16'h5555) tb_error("R5  initialization");
      if (r6 !==16'h6666) tb_error("R6  initialization");
      if (r7 !==16'h7777) tb_error("R7  initialization");
      if (r8 !==16'h8888) tb_error("R8  initialization");
      if (r9 !==16'h9999) tb_error("R9  initialization");      
      if (r10!==16'haaaa) tb_error("R10 initialization");
      if (r11!==16'hbbbb) tb_error("R11 initialization");
      if (r12!==16'hcccc) tb_error("R12 initialization");
      if (r13!==16'hdddd) tb_error("R13 initialization");
      if (r14!==16'heeee) tb_error("R14 initialization");


      // MOV.B: Check when source is Rn
      //--------------------------------------------------------
      @(r15==16'h2000);

      if (r4     !==16'h0055) tb_error("====== MOV.B Rn Rm    =====");
      if (mem210 !==16'haa34) tb_error("====== MOV.B Rn x(Rm) =====");
      if (mem212 !==16'h7855) tb_error("====== MOV.B Rn x(Rm) =====");
      if (mem214 !==16'h11cd) tb_error("====== MOV.B Rn EDE   =====");
      if (mem216 !==16'h1299) tb_error("====== MOV.B Rn EDE   =====");
      if (mem218 !==16'h772e) tb_error("====== MOV.B Rn &EDE  =====");
      if (mem21A !==16'h4c33) tb_error("====== MOV.B Rn &EDE  =====");


      // MOV.B: Check when source is @Rn
      //--------------------------------------------------------
      @(r15==16'h3000);

      if (r5     !==16'h0033) tb_error("====== MOV.B @Rn Rm    =====");
      if (r6     !==16'h0044) tb_error("====== MOV.B @Rn Rm    =====");

      if (mem210 !==16'haa22) tb_error("====== MOV.B @Rn x(Rm) =====");
      if (mem212 !==16'h4455) tb_error("====== MOV.B @Rn x(Rm) =====");
      if (mem214 !==16'h5a55) tb_error("====== MOV.B @Rn x(Rm) =====");
      if (mem216 !==16'h77a5) tb_error("====== MOV.B @Rn x(Rm) =====");

      if (mem218 !==16'h11aa) tb_error("====== MOV.B @Rn EDE =====");
      if (mem21A !==16'hccee) tb_error("====== MOV.B @Rn EDE =====");
      if (mem21C !==16'h1edd) tb_error("====== MOV.B @Rn EDE =====");
      if (mem21E !==16'hffe1) tb_error("====== MOV.B @Rn EDE =====");

      if (mem220 !==16'h2233) tb_error("====== MOV.B @Rn &EDE  =====");
      if (mem222 !==16'h55dd) tb_error("====== MOV.B @Rn &EDE  =====");
      if (mem224 !==16'h2d66) tb_error("====== MOV.B @Rn &EDE  =====");
      if (mem226 !==16'h88d2) tb_error("====== MOV.B @Rn &EDE  =====");


      // MOV.B: Check when source is @Rn+
      //--------------------------------------------------------
      @(r15==16'h4000);


      if (r4     !==(`PER_SIZE+16'h0011)) tb_error("====== MOV.B @Rn+ Rm    =====");
      if (r5     !==16'h0033)             tb_error("====== MOV.B @Rn+ Rm    =====");
      if (r6     !==(`PER_SIZE+16'h0014)) tb_error("====== MOV.B @Rn+ Rm    =====");
      if (r7     !==16'h0044)             tb_error("====== MOV.B @Rn+ Rm    =====");

      if (mem210 !==16'haa22)             tb_error("====== MOV.B @Rn+ x(Rm) =====");
      if (mem212 !==16'h4455)             tb_error("====== MOV.B @Rn+ x(Rm) =====");
      if (mem214 !==16'h5a55)             tb_error("====== MOV.B @Rn+ x(Rm) =====");
      if (mem216 !==16'h77a5)             tb_error("====== MOV.B @Rn+ x(Rm) =====");
      if (r9     !==(`PER_SIZE+16'h0008)) tb_error("====== MOV.B @Rn+ x(Rm) =====");

      if (mem218 !==16'h11aa)             tb_error("====== MOV.B @Rn+ EDE =====");
      if (mem21A !==16'hccee)             tb_error("====== MOV.B @Rn+ EDE =====");
      if (mem21C !==16'h1edd)             tb_error("====== MOV.B @Rn+ EDE =====");
      if (mem21E !==16'hffe1)             tb_error("====== MOV.B @Rn+ EDE =====");
      if (r10    !==(`PER_SIZE+16'h0008)) tb_error("====== MOV.B @Rn+ EDE =====");

      if (mem220 !==16'h2233)             tb_error("====== MOV.B @Rn+ &EDE  =====");
      if (mem222 !==16'h55dd)             tb_error("====== MOV.B @Rn+ &EDE  =====");
      if (mem224 !==16'h2d66)             tb_error("====== MOV.B @Rn+ &EDE  =====");
      if (mem226 !==16'h88d2)             tb_error("====== MOV.B @Rn+ &EDE  =====");
      if (r11    !==(`PER_SIZE+16'h0008)) tb_error("====== MOV.B @Rn+ &EDE  =====");


      // MOV.B: Check when source is #N
      //--------------------------------------------------------
      @(r15==16'h5000);

      if (r4     !==16'h0034) tb_error("====== MOV.B #N  Rm    =====");

      if (mem210 !==16'haa22) tb_error("====== MOV.B #N  x(Rm) =====");
      if (mem212 !==16'h4455) tb_error("====== MOV.B #N  x(Rm) =====");
      if (mem214 !==16'h5a66) tb_error("====== MOV.B #N  x(Rm) =====");
      if (mem216 !==16'h88a5) tb_error("====== MOV.B #N  x(Rm) =====");

      if (mem218 !==16'h11aa) tb_error("====== MOV.B #N  EDE =====");
      if (mem21A !==16'hccee) tb_error("====== MOV.B #N  EDE =====");
      if (mem21C !==16'h1eee) tb_error("====== MOV.B #N  EDE =====");
      if (mem21E !==16'h11e1) tb_error("====== MOV.B #N  EDE =====");

      if (mem220 !==16'haa33) tb_error("====== MOV.B #N  &EDE  =====");
      if (mem222 !==16'h55ee) tb_error("====== MOV.B #N  &EDE  =====");
      if (mem224 !==16'hae77) tb_error("====== MOV.B #N  &EDE  =====");
      if (mem226 !==16'h99ea) tb_error("====== MOV.B #N  &EDE  =====");


      // MOV.B: Check when source is x(Rn)
      //--------------------------------------------------------
      @(r15==16'h6000);

      if (r5     !==16'h0033) tb_error("====== MOV.B x(Rn) Rm    =====");
      if (r6     !==16'h0044) tb_error("====== MOV.B x(Rn) Rm    =====");

      if (mem210 !==16'haa22) tb_error("====== MOV.B x(Rn) x(Rm) =====");
      if (mem212 !==16'h4455) tb_error("====== MOV.B x(Rn) x(Rm) =====");
      if (mem214 !==16'h5a55) tb_error("====== MOV.B x(Rn) x(Rm) =====");
      if (mem216 !==16'h77a5) tb_error("====== MOV.B x(Rn) x(Rm) =====");

      if (mem218 !==16'h11aa) tb_error("====== MOV.B x(Rn) EDE =====");
      if (mem21A !==16'hccee) tb_error("====== MOV.B x(Rn) EDE =====");
      if (mem21C !==16'h1edd) tb_error("====== MOV.B x(Rn) EDE =====");
      if (mem21E !==16'hffe1) tb_error("====== MOV.B x(Rn) EDE =====");

      if (mem220 !==16'h2233) tb_error("====== MOV.B x(Rn) &EDE  =====");
      if (mem222 !==16'h55dd) tb_error("====== MOV.B x(Rn) &EDE  =====");
      if (mem224 !==16'h2d66) tb_error("====== MOV.B x(Rn) &EDE  =====");
      if (mem226 !==16'h88d2) tb_error("====== MOV.B x(Rn) &EDE  =====");


      // MOV.B: Check when source is EDE
      //--------------------------------------------------------
      @(r15==16'h7000);

      if (r5     !==16'h0033) tb_error("====== MOV.B EDE  Rm    =====");
      if (r6     !==16'h0044) tb_error("====== MOV.B EDE  Rm    =====");

      if (mem210 !==16'haa22) tb_error("====== MOV.B EDE  x(Rm) =====");
      if (mem212 !==16'h4455) tb_error("====== MOV.B EDE  x(Rm) =====");
      if (mem214 !==16'h5a55) tb_error("====== MOV.B EDE  x(Rm) =====");
      if (mem216 !==16'h77a5) tb_error("====== MOV.B EDE  x(Rm) =====");

      if (mem218 !==16'h11aa) tb_error("====== MOV.B EDE  EDE =====");
      if (mem21A !==16'hccee) tb_error("====== MOV.B EDE  EDE =====");
      if (mem21C !==16'h1edd) tb_error("====== MOV.B EDE  EDE =====");
      if (mem21E !==16'hffe1) tb_error("====== MOV.B EDE  EDE =====");

      if (mem220 !==16'h2233) tb_error("====== MOV.B EDE  &EDE  =====");
      if (mem222 !==16'h55dd) tb_error("====== MOV.B EDE  &EDE  =====");
      if (mem224 !==16'h2d66) tb_error("====== MOV.B EDE  &EDE  =====");
      if (mem226 !==16'h88d2) tb_error("====== MOV.B EDE  &EDE  =====");


      // MOV.B: Check when source is &EDE
      //--------------------------------------------------------
      @(r15==16'h8000);

      if (r5     !==16'h0033) tb_error("====== MOV.B &EDE  Rm    =====");
      if (r6     !==16'h0044) tb_error("====== MOV.B &EDE  Rm    =====");

      if (mem210 !==16'haa22) tb_error("====== MOV.B &EDE  x(Rm) =====");
      if (mem212 !==16'h4455) tb_error("====== MOV.B &EDE  x(Rm) =====");
      if (mem214 !==16'h5a55) tb_error("====== MOV.B &EDE  x(Rm) =====");
      if (mem216 !==16'h77a5) tb_error("====== MOV.B &EDE  x(Rm) =====");

      if (mem218 !==16'h11aa) tb_error("====== MOV.B &EDE  EDE   =====");
      if (mem21A !==16'hccee) tb_error("====== MOV.B &EDE  EDE   =====");
      if (mem21C !==16'h1edd) tb_error("====== MOV.B &EDE  EDE   =====");
      if (mem21E !==16'hffe1) tb_error("====== MOV.B &EDE  EDE   =====");

      if (mem220 !==16'h2233) tb_error("====== MOV.B &EDE  &EDE  =====");
      if (mem222 !==16'h55dd) tb_error("====== MOV.B &EDE  &EDE  =====");
      if (mem224 !==16'h2d66) tb_error("====== MOV.B &EDE  &EDE  =====");
      if (mem226 !==16'h88d2) tb_error("====== MOV.B &EDE  &EDE  =====");


      // MOV.B: Check when source is CONST
      //--------------------------------------------------------
      @(r15==16'h9000);

      if (r4     !==16'h0000) tb_error("====== MOV.B #+0 Rm    =====");
      if (r5     !==16'h0001) tb_error("====== MOV.B #+1 Rm    =====");
      if (r6     !==16'h0002) tb_error("====== MOV.B #+2 Rm    =====");
      if (r7     !==16'h0004) tb_error("====== MOV.B #+4 Rm    =====");
      if (r8     !==16'h0008) tb_error("====== MOV.B #+8 Rm    =====");
      if (r9     !==16'h00ff) tb_error("====== MOV.B #-1 Rm    =====");

      if (mem210 !==16'h4400) tb_error("====== MOV.B #+0 x(Rm) =====");
      if (mem212 !==16'h5501) tb_error("====== MOV.B #+1 x(Rm) =====");
      if (mem214 !==16'h6602) tb_error("====== MOV.B #+2 x(Rm) =====");
      if (mem216 !==16'h7704) tb_error("====== MOV.B #+4 x(Rm) =====");
      if (mem218 !==16'h3508) tb_error("====== MOV.B #+8 x(Rm) =====");
      if (mem21A !==16'h99ff) tb_error("====== MOV.B #-1 x(Rm) =====");
      if (mem21C !==16'h00aa) tb_error("====== MOV.B #+0 x(Rm) =====");
      if (mem21E !==16'h01bb) tb_error("====== MOV.B #+1 x(Rm) =====");
      if (mem220 !==16'h02cc) tb_error("====== MOV.B #+2 x(Rm) =====");
      if (mem222 !==16'h04dd) tb_error("====== MOV.B #+4 x(Rm) =====");
      if (mem224 !==16'h08ee) tb_error("====== MOV.B #+8 x(Rm) =====");
      if (mem226 !==16'hff33) tb_error("====== MOV.B #-1 x(Rm) =====");

      if (mem230 !==16'h4400) tb_error("====== MOV.B #+0 EDE =====");
      if (mem232 !==16'h5501) tb_error("====== MOV.B #+1 EDE =====");
      if (mem234 !==16'h6602) tb_error("====== MOV.B #+2 EDE =====");
      if (mem236 !==16'h7704) tb_error("====== MOV.B #+4 EDE =====");
      if (mem238 !==16'h3508) tb_error("====== MOV.B #+8 EDE =====");
      if (mem23A !==16'h99ff) tb_error("====== MOV.B #-1 EDE =====");
      if (mem23C !==16'h00aa) tb_error("====== MOV.B #+0 EDE =====");
      if (mem23E !==16'h01bb) tb_error("====== MOV.B #+1 EDE =====");
      if (mem240 !==16'h02cc) tb_error("====== MOV.B #+2 EDE =====");
      if (mem242 !==16'h04dd) tb_error("====== MOV.B #+4 EDE =====");
      if (mem244 !==16'h08ee) tb_error("====== MOV.B #+8 EDE =====");
      if (mem246 !==16'hff33) tb_error("====== MOV.B #-1 EDE =====");

//	#
//	# NOTE: The following section would not fit in the smallest ROM
//      #       configuration. Therefore, it is executed at the end of
//      #       the "two-op_mov.v" pattern.
//	#

//      if (mem250 !==16'h4400) tb_error("====== MOV.B #+0 &EDE =====");
//      if (mem252 !==16'h5501) tb_error("====== MOV.B #+1 &EDE =====");
//      if (mem254 !==16'h6602) tb_error("====== MOV.B #+2 &EDE =====");
//      if (mem256 !==16'h7704) tb_error("====== MOV.B #+4 &EDE =====");
//      if (mem258 !==16'h3508) tb_error("====== MOV.B #+8 &EDE =====");
//      if (mem25A !==16'h99ff) tb_error("====== MOV.B #-1 &EDE =====");
//      if (mem25C !==16'h00aa) tb_error("====== MOV.B #+0 &EDE =====");
//      if (mem25E !==16'h01bb) tb_error("====== MOV.B #+1 &EDE =====");
//      if (mem260 !==16'h02cc) tb_error("====== MOV.B #+2 &EDE =====");
//      if (mem262 !==16'h04dd) tb_error("====== MOV.B #+4 &EDE =====");
//      if (mem264 !==16'h08ee) tb_error("====== MOV.B #+8 &EDE =====");
//      if (mem266 !==16'hff33) tb_error("====== MOV.B #-1 &EDE =====");

      #100;

      stimulus_done = 1;
   end

