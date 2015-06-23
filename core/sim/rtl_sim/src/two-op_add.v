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
/*                 TWO-OPERAND ARITHMETIC: ADD INSTRUCTION                   */
/*---------------------------------------------------------------------------*/
/* Test the ADD instruction with all addressing modes                        */
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


      // ADD: Check when source is Rn
      //--------------------------------------------------------
      @(r15==16'h2000);

      if (r5     !==16'h9999) tb_error("====== ADD Rn Rm    =====");
      if (r4     ===16'h1234) tb_error("====== ADD Rn PC    =====");
      if (mem210 !==16'h5555) tb_error("====== ADD Rn x(Rm) =====");
      if (mem212 !==16'h9abc) tb_error("====== ADD Rn EDE   =====");
      if (mem214 !==16'h6789) tb_error("====== ADD Rn &EDE  =====");


      // ADD: Check when source is @Rn
      //--------------------------------------------------------
      @(r15==16'h3000);

      if (r5     !==16'h7777) tb_error("====== ADD @Rn Rm    =====");
      if (r4     ===16'h0000) tb_error("====== ADD @Rn PC    =====");
      if (mem210 !==16'h6666) tb_error("====== ADD @Rn x(Rm) =====");
      if (mem212 !==16'hed2e) tb_error("====== ADD @Rn EDE   =====");
      if (mem214 !==16'h4653) tb_error("====== ADD @Rn &EDE  =====");


      // ADD: Check when source is @Rn+
      //--------------------------------------------------------
      @(r15==16'h4000);

      if (r4     !==(`PER_SIZE+16'h0002)) tb_error("====== ADD @Rn+ Rm    =====");
      if (r5     !==16'haaaa)             tb_error("====== ADD @Rn+ Rm    =====");

      if (r6     !==(`PER_SIZE+16'h0006)) tb_error("====== ADD @Rn+ PC    =====");

      if (r7     !==(`PER_SIZE+16'h0010)) tb_error("====== ADD @Rn+ x(Rm) =====");
      if (mem210 !==16'h6666)             tb_error("====== ADD @Rn+ x(Rm) =====");

      if (r8     !==(`PER_SIZE+16'h0008)) tb_error("====== ADD @Rn+ EDE =====");
      if (mem212 !==16'hed2e)             tb_error("====== ADD @Rn+ EDE   =====");

      if (r9     !==(`PER_SIZE+16'h0004)) tb_error("====== ADD @Rn+ &EDE =====");
      if (mem214 !==16'h4653)             tb_error("====== ADD @Rn+ &EDE  =====");

      // ADD: Check when source is #N
      //--------------------------------------------------------
      @(r15==16'h5000);

      if (r4     !==16'h4444) tb_error("====== ADD #N  Rm    =====");
      if (r5     !==16'h0000) tb_error("====== ADD #N  PC    =====");
      if (mem230 !==16'hae8c) tb_error("====== ADD #N  x(Rm) =====");
      if (mem210 !==16'h5d50) tb_error("====== ADD #N  EDE   =====");
      if (mem206 !==16'h6ea1) tb_error("====== ADD #N  &EDE  =====");


      // ADD: Check when source is x(Rn)
      //--------------------------------------------------------
      @(r15==16'h6000);

      if (r5     !==16'h957b) tb_error("====== ADD x(Rn) Rm    =====");
      if (r6     ===16'h0000) tb_error("====== ADD x(Rn) PC    =====");
      if (mem214 !==16'h5776) tb_error("====== ADD x(Rn) x(Rm) =====");
      if (mem220 !==16'h937b) tb_error("====== ADD x(Rn) EDE   =====");
      if (mem208 !==16'hace4) tb_error("====== ADD x(Rn) &EDE  =====");


      // ADD: Check when source is EDE
      //--------------------------------------------------------
      @(r15==16'h7000);

      if (r4     !==16'h06f7) tb_error("====== ADD EDE Rm    =====");
      if (r6     ===16'h0000) tb_error("====== ADD EDE PC    =====");
      if (mem214 !==16'h0946) tb_error("====== ADD EDE x(Rm) =====");
      if (mem216 !==16'hb933) tb_error("====== ADD EDE EDE   =====");
      if (mem212 !==16'h2ab2) tb_error("====== ADD EDE &EDE  =====");


      // ADD: Check when source is &EDE
      //--------------------------------------------------------
      @(r15==16'h8000);

      if (r4     !==16'h66f5) tb_error("====== ADD &EDE Rm    =====");
      if (r6     ===16'h0000) tb_error("====== ADD &EDE PC    =====");
      if (mem214 !==16'h82d1) tb_error("====== ADD &EDE x(Rm) =====");
      if (mem218 !==16'hca4e) tb_error("====== ADD &EDE EDE   =====");
      if (mem202 !==16'h1338) tb_error("====== ADD &EDE &EDE  =====");


      // ADD: Check when source is CONST
      //--------------------------------------------------------
      @(r15==16'h9000);

      if (r4     !==16'h4444) tb_error("====== ADD #+0 Rm    =====");
      if (r5     !==16'h5556) tb_error("====== ADD #+1 Rm    =====");
      if (r6     !==16'h6668) tb_error("====== ADD #+2 Rm    =====");
      if (r7     !==16'h777b) tb_error("====== ADD #+4 Rm    =====");
      if (r8     !==16'h8890) tb_error("====== ADD #+8 Rm    =====");
      if (r9     !==16'h9998) tb_error("====== ADD #-1 Rm    =====");

      if (r11    !==16'h1234) tb_error("====== ADD #+4 PC    =====");

      if (mem210 !==16'h4444) tb_error("====== ADD #+0 x(Rm) =====");
      if (mem212 !==16'h5556) tb_error("====== ADD #+1 x(Rm) =====");
      if (mem214 !==16'h6668) tb_error("====== ADD #+2 x(Rm) =====");
      if (mem216 !==16'h777b) tb_error("====== ADD #+4 x(Rm) =====");
      if (mem218 !==16'h8890) tb_error("====== ADD #+8 x(Rm) =====");
      if (mem21A !==16'h9998) tb_error("====== ADD #-1 x(Rm) =====");

      if (mem220 !==16'h4444) tb_error("====== ADD #+0 EDE   =====");
      if (mem222 !==16'h5556) tb_error("====== ADD #+1 EDE   =====");
      if (mem224 !==16'h6668) tb_error("====== ADD #+2 EDE   =====");
      if (mem226 !==16'h777b) tb_error("====== ADD #+4 EDE   =====");
      if (mem228 !==16'h8890) tb_error("====== ADD #+8 EDE   =====");
      if (mem22A !==16'h9998) tb_error("====== ADD #-1 EDE   =====");

      if (mem230 !==16'h4444) tb_error("====== ADD #+0 &EDE  =====");
      if (mem232 !==16'h5556) tb_error("====== ADD #+1 &EDE  =====");
      if (mem234 !==16'h6668) tb_error("====== ADD #+2 &EDE  =====");
      if (mem236 !==16'h777b) tb_error("====== ADD #+4 &EDE  =====");
      if (mem238 !==16'h8890) tb_error("====== ADD #+8 &EDE  =====");
      if (mem23A !==16'h9998) tb_error("====== ADD #-1 &EDE  =====");


      // ADD: Check Flags
      //--------------------------------------------------------

      @(r15==16'hA000);
      if (r2    !==16'h0000) tb_error("====== ADD FLAG: Flag   check error: V=0, N=0, Z=0, C=0 =====");
      if (r5    !==16'h0999) tb_error("====== ADD FLAG: Result check error: V=0, N=0, Z=0, C=0 =====");

      @(r15==16'hA001);
      if (r2    !==16'h0001) tb_error("====== ADD FLAG: Flag   check error: V=0, N=0, Z=0, C=1 =====");
      if (r5    !==16'h0001) tb_error("====== ADD FLAG: Result check error: V=0, N=0, Z=0, C=1 =====");

      @(r15==16'hA002);
      if (r2    !==16'h0002) tb_error("====== ADD FLAG: Flag   check error: V=0, N=0, Z=1, C=0 =====");
      if (r5    !==16'h0000) tb_error("====== ADD FLAG: Result check error: V=0, N=0, Z=1, C=0 =====");

      @(r15==16'hA003);
      if (r2    !==16'h0004) tb_error("====== ADD FLAG: Flag   check error: V=0, N=1, Z=0, C=0 =====");
      if (r5    !==16'hff10) tb_error("====== ADD FLAG: Result check error: V=0, N=1, Z=0, C=0 =====");

      @(r15==16'hA004);
      if (r2    !==16'h0104) tb_error("====== ADD FLAG: Flag   check error: V=1, N=1, Z=0, C=0 =====");
      if (r5    !==16'h800f) tb_error("====== ADD FLAG: Result check error: V=1, N=1, Z=0, C=0 =====");

      @(r15==16'hA005);
      if (r2    !==16'h0101) tb_error("====== ADD FLAG: Flag   check error: V=1, N=0, Z=0, C=1 =====");
      if (r5    !==16'h7f00) tb_error("====== ADD FLAG: Result check error: V=1, N=0, Z=0, C=1 =====");

//    ---------------- TEST WHEN SOURCE IS CONSTANT IN BYTE MODE ------ */
//    #
//    # NOTE: The following section would not fit in the smallest ROM
//    #       configuration for the "two-op_add-b.v" pattern.
//    #       It is therefore executed here.
//    #
      @(r15==16'hB000);


      if (mem250 !==16'haa44) tb_error("====== ADD.B #+0 &EDE =====");
      if (mem252 !==16'haa56) tb_error("====== ADD.B #+1 &EDE =====");
      if (mem254 !==16'haa68) tb_error("====== ADD.B #+2 &EDE =====");
      if (mem256 !==16'haa7b) tb_error("====== ADD.B #+4 &EDE =====");
      if (mem258 !==16'haa3d) tb_error("====== ADD.B #+8 &EDE =====");
      if (mem25A !==16'haa98) tb_error("====== ADD.B #-1 &EDE =====");
      if (mem25C !==16'haa55) tb_error("====== ADD.B #+0 &EDE =====");
      if (mem25E !==16'hbc55) tb_error("====== ADD.B #+1 &EDE =====");
      if (mem260 !==16'hce55) tb_error("====== ADD.B #+2 &EDE =====");
      if (mem262 !==16'he155) tb_error("====== ADD.B #+4 &EDE =====");
      if (mem264 !==16'hf655) tb_error("====== ADD.B #+8 &EDE =====");
      if (mem266 !==16'h3255) tb_error("====== ADD.B #-1 &EDE =====");


      // ADD.B: Check Flags
      //--------------------------------------------------------

      @(r15==16'hC000);
      if (r2    !==16'h0000) tb_error("====== ADD.B FLAG: Flag   check error: V=0, N=0, Z=0, C=0 =====");
      if (r5    !==16'h0009) tb_error("====== ADD.B FLAG: Result check error: V=0, N=0, Z=0, C=0 =====");

      @(r15==16'hC001);
      if (r2    !==16'h0001) tb_error("====== ADD.B FLAG: Flag   check error: V=0, N=0, Z=0, C=1 =====");
      if (r5    !==16'h0001) tb_error("====== ADD.B FLAG: Result check error: V=0, N=0, Z=0, C=1 =====");

      @(r15==16'hC002);
      if (r2    !==16'h0002) tb_error("====== ADD.B FLAG: Flag   check error: V=0, N=0, Z=1, C=0 =====");
      if (r5    !==16'h0000) tb_error("====== ADD.B FLAG: Result check error: V=0, N=0, Z=1, C=0 =====");

      @(r15==16'hC003);
      if (r2    !==16'h0004) tb_error("====== ADD.B FLAG: Flag   check error: V=0, N=1, Z=0, C=0 =====");
      if (r5    !==16'h00f3) tb_error("====== ADD.B FLAG: Result check error: V=0, N=1, Z=0, C=0 =====");

      @(r15==16'hC004);
      if (r2    !==16'h0104) tb_error("====== ADD.B FLAG: Flag   check error: V=1, N=1, Z=0, C=0 =====");
      if (r5    !==16'h008f) tb_error("====== ADD.B FLAG: Result check error: V=1, N=1, Z=0, C=0 =====");

      @(r15==16'hC005);
      if (r2    !==16'h0101) tb_error("====== ADD.B FLAG: Flag   check error: V=1, N=0, Z=0, C=1 =====");
      if (r5    !==16'h007f) tb_error("====== ADD.B FLAG: Result check error: V=1, N=0, Z=0, C=1 =====");

      stimulus_done = 1;
   end

