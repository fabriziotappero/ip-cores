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
/*                   TWO-OPERAND ARITHMETIC: ADD.B INSTRUCTION               */
/*---------------------------------------------------------------------------*/
/* Test the ADD.B instruction with all addressing modes                      */
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


      // ADD.B: Check when source is Rn
      //--------------------------------------------------------
      @(r15==16'h2000);

      if (r4     !==16'h00cc) tb_error("====== ADD.B Rn Rm    =====");

      if (mem210 !==16'haaef) tb_error("====== ADD.B Rn x(Rm) =====");
      if (mem212 !==16'hcd66) tb_error("====== ADD.B Rn x(Rm) =====");

      if (mem214 !==16'h11ef) tb_error("====== ADD.B Rn EDE   =====");
      if (mem216 !==16'habaa) tb_error("====== ADD.B Rn EDE   =====");

      if (mem218 !==16'h77b6) tb_error("====== ADD.B Rn &EDE  =====");
      if (mem21A !==16'h7f44) tb_error("====== ADD.B Rn &EDE  =====");


      // ADD.B: Check when source is @Rn
      //--------------------------------------------------------
      @(r15==16'h3000);

      if (r5     !==16'h0032) tb_error("====== ADD.B @Rn Rm    =====");
      if (r6     !==16'h0021) tb_error("====== ADD.B @Rn Rm    =====");

      if (mem210 !==16'h55cc) tb_error("====== ADD.B @Rn x(Rm) =====");
      if (mem212 !==16'haabb) tb_error("====== ADD.B @Rn x(Rm) =====");
      if (mem214 !==16'h5600) tb_error("====== ADD.B @Rn x(Rm) =====");
      if (mem216 !==16'hdcba) tb_error("====== ADD.B @Rn x(Rm) =====");

      if (mem218 !==16'h1198) tb_error("====== ADD.B @Rn EDE =====");
      if (mem21A !==16'heedd) tb_error("====== ADD.B @Rn EDE =====");
      if (mem21C !==16'h1dbf) tb_error("====== ADD.B @Rn EDE =====");
      if (mem21E !==16'hd02e) tb_error("====== ADD.B @Rn EDE =====");

      if (mem220 !==16'h2210) tb_error("====== ADD.B @Rn &EDE  =====");
      if (mem222 !==16'h88cc) tb_error("====== ADD.B @Rn &EDE  =====");
      if (mem224 !==16'h2c39) tb_error("====== ADD.B @Rn &EDE  =====");
      if (mem226 !==16'h4a3d) tb_error("====== ADD.B @Rn &EDE  =====");


      // ADD.B: Check when source is @Rn+
      //--------------------------------------------------------
      @(r15==16'h4000);

      if (r4     !==(`PER_SIZE+16'h0011)) tb_error("====== ADD.B @Rn+ Rm    =====");
      if (r5     !==16'h0052)             tb_error("====== ADD.B @Rn+ Rm    =====");
      if (r6     !==(`PER_SIZE+16'h0014)) tb_error("====== ADD.B @Rn+ Rm    =====");
      if (r7     !==16'h0035)             tb_error("====== ADD.B @Rn+ Rm    =====");

      if (mem210 !==16'haadd)             tb_error("====== ADD.B @Rn+ x(Rm) =====");
      if (mem212 !==16'h9966)             tb_error("====== ADD.B @Rn+ x(Rm) =====");
      if (mem214 !==16'h5ac0)             tb_error("====== ADD.B @Rn+ x(Rm) =====");
      if (mem216 !==16'h1cb6)             tb_error("====== ADD.B @Rn+ x(Rm) =====");
      if (r9     !==(`PER_SIZE+16'h0008)) tb_error("====== ADD.B @Rn+ x(Rm) =====");

      if (mem218 !==16'h11cc)             tb_error("====== ADD.B @Rn+ EDE 1=====");
      if (mem21A !==16'hbaff)             tb_error("====== ADD.B @Rn+ EDE 2=====");
      if (mem21C !==16'h1e0c)             tb_error("====== ADD.B @Rn+ EDE 3=====");
      if (mem21E !==16'he0f2)             tb_error("====== ADD.B @Rn+ EDE 4=====");
      if (r10    !==(`PER_SIZE+16'h0008)) tb_error("====== ADD.B @Rn+ EDE 5=====");

      if (mem220 !==16'h5599)             tb_error("====== ADD.B @Rn+ &EDE  =====");
      if (mem222 !==16'h21dd)             tb_error("====== ADD.B @Rn+ &EDE  =====");
      if (mem224 !==16'h5cd3)             tb_error("====== ADD.B @Rn+ &EDE  =====");
      if (mem226 !==16'h4dd6)             tb_error("====== ADD.B @Rn+ &EDE  =====");
      if (r11    !==(`PER_SIZE+16'h0008)) tb_error("====== ADD.B @Rn+ &EDE  =====");


      // ADD.B: Check when source is #N
      //--------------------------------------------------------
      @(r15==16'h5000);

      if (r4     !==16'h008a) tb_error("====== ADD.B #N  Rm    =====");

      if (mem210 !==16'haabb) tb_error("====== ADD.B #N  x(Rm) =====");
      if (mem212 !==16'h9944) tb_error("====== ADD.B #N  x(Rm) =====");
      if (mem214 !==16'ha9ba) tb_error("====== ADD.B #N  x(Rm) =====");
      if (mem216 !==16'hd15a) tb_error("====== ADD.B #N  x(Rm) =====");

      if (mem218 !==16'h11cc) tb_error("====== ADD.B #N  EDE =====");
      if (mem21A !==16'hbacc) tb_error("====== ADD.B #N  EDE =====");
      if (mem21C !==16'h1e1a) tb_error("====== ADD.B #N  EDE =====");
      if (mem21E !==16'hf2c2) tb_error("====== ADD.B #N  EDE =====");

      if (mem220 !==16'haabb) tb_error("====== ADD.B #N  &EDE  =====");
      if (mem222 !==16'h77ee) tb_error("====== ADD.B #N  &EDE  =====");
      if (mem224 !==16'ha205) tb_error("====== ADD.B #N  &EDE  =====");
      if (mem226 !==16'hc3e8) tb_error("====== ADD.B #N  &EDE  =====");


      // ADD.B: Check when source is x(Rn)
      //--------------------------------------------------------
      @(r15==16'h6000);

      if (r5     !==16'h00cb) tb_error("====== ADD.B x(Rn) Rm    =====");
      if (r6     !==16'h0098) tb_error("====== ADD.B x(Rn) Rm    =====");

      if (mem210 !==16'haa33) tb_error("====== ADD.B x(Rn) x(Rm) =====");
      if (mem212 !==16'h6655) tb_error("====== ADD.B x(Rn) x(Rm) =====");
      if (mem214 !==16'ha26a) tb_error("====== ADD.B x(Rn) x(Rm) =====");
      if (mem216 !==16'ha151) tb_error("====== ADD.B x(Rn) x(Rm) =====");

      if (mem218 !==16'h33ee) tb_error("====== ADD.B x(Rn) EDE =====");
      if (mem21A !==16'h43cc) tb_error("====== ADD.B x(Rn) EDE =====");
      if (mem21C !==16'h3729) tb_error("====== ADD.B x(Rn) EDE =====");
      if (mem21E !==16'h72c4) tb_error("====== ADD.B x(Rn) EDE =====");

      if (mem220 !==16'h0044) tb_error("====== ADD.B x(Rn) &EDE  =====");
      if (mem222 !==16'h32cc) tb_error("====== ADD.B x(Rn) &EDE  =====");
      if (mem224 !==16'h0d82) tb_error("====== ADD.B x(Rn) &EDE  =====");
      if (mem226 !==16'h58c1) tb_error("====== ADD.B x(Rn) &EDE  =====");


      // ADD.B: Check when source is EDE
      //--------------------------------------------------------
      @(r15==16'h7000);

      if (r5     !==16'h0076) tb_error("====== ADD.B EDE  Rm    =====");
      if (r6     !==16'h00e9) tb_error("====== ADD.B EDE  Rm    =====");

      if (mem210 !==16'haadd) tb_error("====== ADD.B EDE  x(Rm) =====");
      if (mem212 !==16'haa55) tb_error("====== ADD.B EDE  x(Rm) =====");
      if (mem214 !==16'ha60a) tb_error("====== ADD.B EDE  x(Rm) =====");
      if (mem216 !==16'he15b) tb_error("====== ADD.B EDE  x(Rm) =====");

      if (mem218 !==16'h11cc) tb_error("====== ADD.B EDE  EDE =====");
      if (mem21A !==16'hbaff) tb_error("====== ADD.B EDE  EDE =====");
      if (mem21C !==16'h1e0c) tb_error("====== ADD.B EDE  EDE =====");
      if (mem21E !==16'he0f2) tb_error("====== ADD.B EDE  EDE =====");

      if (mem220 !==16'h113a) tb_error("====== ADD.B EDE  &EDE  =====");
      if (mem222 !==16'h21dd) tb_error("====== ADD.B EDE  &EDE  =====");
      if (mem224 !==16'h2ca3) tb_error("====== ADD.B EDE  &EDE  =====");
      if (mem226 !==16'h4ad3) tb_error("====== ADD.B EDE  &EDE  =====");


      // ADD.B: Check when source is &EDE
      //--------------------------------------------------------
      @(r15==16'h8000);

      if (r5     !==16'h00aa) tb_error("====== ADD.B &EDE  Rm    =====");
      if (r6     !==16'h00dd) tb_error("====== ADD.B &EDE  Rm    =====");

      if (mem210 !==16'haadd) tb_error("====== ADD.B &EDE  x(Rm) =====");
      if (mem212 !==16'h10dd) tb_error("====== ADD.B &EDE  x(Rm) =====");
      if (mem214 !==16'hac12) tb_error("====== ADD.B &EDE  x(Rm) =====");
      if (mem216 !==16'h41db) tb_error("====== ADD.B &EDE  x(Rm) =====");

      if (mem218 !==16'h11cc) tb_error("====== ADD.B &EDE  EDE   =====");
      if (mem21A !==16'h3277) tb_error("====== ADD.B &EDE  EDE   =====");
      if (mem21C !==16'h1604) tb_error("====== ADD.B &EDE  EDE   =====");
      if (mem21E !==16'h6072) tb_error("====== ADD.B &EDE  EDE   =====");

      if (mem220 !==16'haaee) tb_error("====== ADD.B &EDE  &EDE  =====");
      if (mem222 !==16'h32ee) tb_error("====== ADD.B &EDE  &EDE  =====");
      if (mem224 !==16'had24) tb_error("====== ADD.B &EDE  &EDE  =====");
      if (mem226 !==16'h62eb) tb_error("====== ADD.B &EDE  &EDE  =====");


      // ADD.B: Check when source is CONST
      //--------------------------------------------------------
      @(r15==16'h9000);

      if (r4     !==16'h0044) tb_error("====== ADD.B #+0 Rm    =====");
      if (r5     !==16'h0056) tb_error("====== ADD.B #+1 Rm    =====");
      if (r6     !==16'h0068) tb_error("====== ADD.B #+2 Rm    =====");
      if (r7     !==16'h007b) tb_error("====== ADD.B #+4 Rm    =====");
      if (r8     !==16'h0090) tb_error("====== ADD.B #+8 Rm    =====");
      if (r9     !==16'h0098) tb_error("====== ADD.B #-1 Rm    =====");

      if (mem210 !==16'haa44) tb_error("====== ADD.B #+0 x(Rm) =====");
      if (mem212 !==16'haa56) tb_error("====== ADD.B #+1 x(Rm) =====");
      if (mem214 !==16'haa68) tb_error("====== ADD.B #+2 x(Rm) =====");
      if (mem216 !==16'haa7b) tb_error("====== ADD.B #+4 x(Rm) =====");
      if (mem218 !==16'haa3d) tb_error("====== ADD.B #+8 x(Rm) =====");
      if (mem21A !==16'haa98) tb_error("====== ADD.B #-1 x(Rm) =====");
      if (mem21C !==16'haa55) tb_error("====== ADD.B #+0 x(Rm) =====");
      if (mem21E !==16'hbc55) tb_error("====== ADD.B #+1 x(Rm) =====");
      if (mem220 !==16'hce55) tb_error("====== ADD.B #+2 x(Rm) =====");
      if (mem222 !==16'he155) tb_error("====== ADD.B #+4 x(Rm) =====");
      if (mem224 !==16'hf655) tb_error("====== ADD.B #+8 x(Rm) =====");
      if (mem226 !==16'h3255) tb_error("====== ADD.B #-1 x(Rm) =====");

      if (mem230 !==16'haa44) tb_error("====== ADD.B #+0 EDE =====");
      if (mem232 !==16'haa56) tb_error("====== ADD.B #+1 EDE =====");
      if (mem234 !==16'haa68) tb_error("====== ADD.B #+2 EDE =====");
      if (mem236 !==16'haa7b) tb_error("====== ADD.B #+4 EDE =====");
      if (mem238 !==16'haa3d) tb_error("====== ADD.B #+8 EDE =====");
      if (mem23A !==16'haa98) tb_error("====== ADD.B #-1 EDE =====");
      if (mem23C !==16'haa55) tb_error("====== ADD.B #+0 EDE =====");
      if (mem23E !==16'hbc55) tb_error("====== ADD.B #+1 EDE =====");
      if (mem240 !==16'hce55) tb_error("====== ADD.B #+2 EDE =====");
      if (mem242 !==16'he155) tb_error("====== ADD.B #+4 EDE =====");
      if (mem244 !==16'hf655) tb_error("====== ADD.B #+8 EDE =====");
      if (mem246 !==16'h3255) tb_error("====== ADD.B #-1 EDE =====");

//	#
//	# NOTE: The following section would not fit in the smallest ROM
//      #       configuration. Therefore, it is executed at the end of
//      #       the "two-op_add.v" pattern.
//	#

//      if (mem250 !==16'haa44) tb_error("====== ADD.B #+0 &EDE =====");
//      if (mem252 !==16'haa56) tb_error("====== ADD.B #+1 &EDE =====");
//      if (mem254 !==16'haa68) tb_error("====== ADD.B #+2 &EDE =====");
//      if (mem256 !==16'haa7b) tb_error("====== ADD.B #+4 &EDE =====");
//      if (mem258 !==16'haa3d) tb_error("====== ADD.B #+8 &EDE =====");
//      if (mem25A !==16'haa98) tb_error("====== ADD.B #-1 &EDE =====");
//      if (mem25C !==16'haa55) tb_error("====== ADD.B #+0 &EDE =====");
//      if (mem25E !==16'hbc55) tb_error("====== ADD.B #+1 &EDE =====");
//      if (mem260 !==16'hce55) tb_error("====== ADD.B #+2 &EDE =====");
//      if (mem262 !==16'he155) tb_error("====== ADD.B #+4 &EDE =====");
//      if (mem264 !==16'hf655) tb_error("====== ADD.B #+8 &EDE =====");
//      if (mem266 !==16'h3255) tb_error("====== ADD.B #-1 &EDE =====");

      stimulus_done = 1;
   end

