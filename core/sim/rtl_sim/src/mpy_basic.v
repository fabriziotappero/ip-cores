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
/*                          HARDWARE MULTIPLIER                              */
/*---------------------------------------------------------------------------*/
/* Test the hardware multiplier:                                             */
/*                                - MPY  mode.                               */
/*                                - MPYS mode.                               */
/*                                - MAC  mode.                               */
/*                                - MACS mode.                               */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 18 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2009-08-04 23:44:12 +0200 (Tue, 04 Aug 2009) $          */
/*===========================================================================*/
    

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
`ifdef MULTIPLIER
      repeat(5) @(posedge mclk);
      stimulus_done = 0;


      // UNSIGNED MULTIPLICATION
      //--------------------------------------------------------

      @(r15===16'h0001);
      if (r10 !== 16'h7F14) tb_error("====== UNSIGNED MULTIPLICATION: RESLO  (1) =====");
      if (r11 !== 16'h007B) tb_error("====== UNSIGNED MULTIPLICATION: RESHI  (1) =====");
      if (r12 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLICATION: SUMEXT (1) =====");

      @(r15===16'h0002);
      if (r10 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLICATION: RESLO  (2) =====");
      if (r11 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLICATION: RESHI  (2) =====");
      if (r12 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLICATION: SUMEXT (2) =====");

      @(r15===16'h0003);
      if (r10 !== 16'h0001) tb_error("====== UNSIGNED MULTIPLICATION: RESLO  (3) =====");
      if (r11 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLICATION: RESHI  (3) =====");
      if (r12 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLICATION: SUMEXT (3) =====");

      @(r15===16'h0004);
      if (r10 !== 16'h0001) tb_error("====== UNSIGNED MULTIPLICATION: RESLO  (4) =====");
      if (r11 !== 16'h3FFF) tb_error("====== UNSIGNED MULTIPLICATION: RESHI  (4) =====");
      if (r12 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLICATION: SUMEXT (4) =====");

      @(r15===16'h0005);
      if (r10 !== 16'h0001) tb_error("====== UNSIGNED MULTIPLICATION: RESLO  (5) =====");
      if (r11 !== 16'hFFFE) tb_error("====== UNSIGNED MULTIPLICATION: RESHI  (5) =====");
      if (r12 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLICATION: SUMEXT (5) =====");

      @(r15===16'h0006);
      if (r10 !== 16'h8001) tb_error("====== UNSIGNED MULTIPLICATION: RESLO  (6) =====");
      if (r11 !== 16'h7FFE) tb_error("====== UNSIGNED MULTIPLICATION: RESHI  (6) =====");
      if (r12 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLICATION: SUMEXT (6) =====");

      @(r15===16'h0007);
      if (r10 !== 16'h8000) tb_error("====== UNSIGNED MULTIPLICATION: RESLO  (7) =====");
      if (r11 !== 16'h3FFF) tb_error("====== UNSIGNED MULTIPLICATION: RESHI  (7) =====");
      if (r12 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLICATION: SUMEXT (7) =====");

      @(r15===16'h0008);
      if (r10 !== 16'h8000) tb_error("====== UNSIGNED MULTIPLICATION: RESLO  (8) =====");
      if (r11 !== 16'h7FFF) tb_error("====== UNSIGNED MULTIPLICATION: RESHI  (8) =====");
      if (r12 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLICATION: SUMEXT (8) =====");

      @(r15===16'h0009);
      if (r10 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLICATION: RESLO  (9) =====");
      if (r11 !== 16'h4000) tb_error("====== UNSIGNED MULTIPLICATION: RESHI  (9) =====");
      if (r12 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLICATION: SUMEXT (9) =====");

      $display("Unsigned Multiplication test completed (MPY mode).");

      // SIGNED MULTIPLICATION
      //--------------------------------------------------------

      @(r15===16'h0001);
      if (r10 !== 16'h7F14) tb_error("====== SIGNED MULTIPLICATION: RESLO  (1) =====");
      if (r11 !== 16'hE7F9) tb_error("====== SIGNED MULTIPLICATION: RESHI  (1) =====");
      if (r12 !== 16'hFFFF) tb_error("====== SIGNED MULTIPLICATION: SUMEXT (1) =====");

      @(r15===16'h0002);
      if (r10 !== 16'h0000) tb_error("====== SIGNED MULTIPLICATION: RESLO  (2) =====");
      if (r11 !== 16'h0000) tb_error("====== SIGNED MULTIPLICATION: RESHI  (2) =====");
      if (r12 !== 16'h0000) tb_error("====== SIGNED MULTIPLICATION: SUMEXT (2) =====");

      @(r15===16'h0003);
      if (r10 !== 16'h0001) tb_error("====== SIGNED MULTIPLICATION: RESLO  (3) =====");
      if (r11 !== 16'h0000) tb_error("====== SIGNED MULTIPLICATION: RESHI  (3) =====");
      if (r12 !== 16'h0000) tb_error("====== SIGNED MULTIPLICATION: SUMEXT (3) =====");

      @(r15===16'h0004);
      if (r10 !== 16'h0001) tb_error("====== SIGNED MULTIPLICATION: RESLO  (4) =====");
      if (r11 !== 16'h3FFF) tb_error("====== SIGNED MULTIPLICATION: RESHI  (4) =====");
      if (r12 !== 16'h0000) tb_error("====== SIGNED MULTIPLICATION: SUMEXT (4) =====");

      @(r15===16'h0005);
      if (r10 !== 16'h0001) tb_error("====== SIGNED MULTIPLICATION: RESLO  (5) =====");
      if (r11 !== 16'h0000) tb_error("====== SIGNED MULTIPLICATION: RESHI  (5) =====");
      if (r12 !== 16'h0000) tb_error("====== SIGNED MULTIPLICATION: SUMEXT (5) =====");

      @(r15===16'h0006);
      if (r10 !== 16'h8001) tb_error("====== SIGNED MULTIPLICATION: RESLO  (6) =====");
      if (r11 !== 16'hFFFF) tb_error("====== SIGNED MULTIPLICATION: RESHI  (6) =====");
      if (r12 !== 16'hFFFF) tb_error("====== SIGNED MULTIPLICATION: SUMEXT (6) =====");

      @(r15===16'h0007);
      if (r10 !== 16'h8000) tb_error("====== SIGNED MULTIPLICATION: RESLO  (7) =====");
      if (r11 !== 16'hC000) tb_error("====== SIGNED MULTIPLICATION: RESHI  (7) =====");
      if (r12 !== 16'hFFFF) tb_error("====== SIGNED MULTIPLICATION: SUMEXT (7) =====");

      @(r15===16'h0008);
      if (r10 !== 16'h8000) tb_error("====== SIGNED MULTIPLICATION: RESLO  (8) =====");
      if (r11 !== 16'h0000) tb_error("====== SIGNED MULTIPLICATION: RESHI  (8) =====");
      if (r12 !== 16'h0000) tb_error("====== SIGNED MULTIPLICATION: SUMEXT (8) =====");

      @(r15===16'h0009);
      if (r10 !== 16'h0000) tb_error("====== SIGNED MULTIPLICATION: RESLO  (9) =====");
      if (r11 !== 16'h4000) tb_error("====== SIGNED MULTIPLICATION: RESHI  (9) =====");
      if (r12 !== 16'h0000) tb_error("====== SIGNED MULTIPLICATION: SUMEXT (9) =====");

      $display("Signed Multiplication test completed (MPYS mode)");

      
      // UNSIGNED MULTIPLY ACCUMULATE
      //--------------------------------------------------------

      @(r15===16'h0001);
      if (r10 !== 16'h7F14) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESLO  (1) =====");
      if (r11 !== 16'hC07B) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESHI  (1) =====");
      if (r12 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: SUMEXT (1) =====");

      @(r15===16'h0002);
      if (r10 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESLO  (2) =====");
      if (r11 !== 16'hC000) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESHI  (2) =====");
      if (r12 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: SUMEXT (2) =====");

      @(r15===16'h0003);
      if (r10 !== 16'h0001) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESLO  (3) =====");
      if (r11 !== 16'hC000) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESHI  (3) =====");
      if (r12 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: SUMEXT (3) =====");

      @(r15===16'h0004);
      if (r10 !== 16'h0001) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESLO  (4) =====");
      if (r11 !== 16'hFFFF) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESHI  (4) =====");
      if (r12 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: SUMEXT (4) =====");

      @(r15===16'h0005);
      if (r10 !== 16'h0001) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESLO  (5) =====");
      if (r11 !== 16'hBFFE) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESHI  (5) =====");
      if (r12 !== 16'h0001) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: SUMEXT (5) =====");

      @(r15===16'h0006);
      if (r10 !== 16'h8001) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESLO  (6) =====");
      if (r11 !== 16'h3FFE) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESHI  (6) =====");
      if (r12 !== 16'h0001) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: SUMEXT (6) =====");

      @(r15===16'h0007);
      if (r10 !== 16'h8000) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESLO  (7) =====");
      if (r11 !== 16'hFFFF) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESHI  (7) =====");
      if (r12 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: SUMEXT (7) =====");

      @(r15===16'h0008);
      if (r10 !== 16'h8000) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESLO  (8) =====");
      if (r11 !== 16'h3FFF) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESHI  (8) =====");
      if (r12 !== 16'h0001) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: SUMEXT (8) =====");

      @(r15===16'h0009);
      if (r10 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESLO  (9) =====");
      if (r11 !== 16'h0000) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: RESHI  (9) =====");
      if (r12 !== 16'h0001) tb_error("====== UNSIGNED MULTIPLY ACCUMULATE: SUMEXT (9) =====");

      $display("Unsigned Multiply Accumulate test completed (MAC mode)");


      // SIGNED MULTIPLY ACCUMULATE
      //--------------------------------------------------------

      @(r15===16'h0001);
      if (r10 !== 16'h7F14) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESLO  (1) =====");
      if (r11 !== 16'hA7F9) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESHI  (1) =====");
      if (r12 !== 16'hFFFF) tb_error("====== SIGNED MULTIPLY ACCUMULATE: SUMEXT (1) =====");

      @(r15===16'h0002);
      if (r10 !== 16'h0000) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESLO  (2) =====");
      if (r11 !== 16'hC000) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESHI  (2) =====");
      if (r12 !== 16'hFFFF) tb_error("====== SIGNED MULTIPLY ACCUMULATE: SUMEXT (2) =====");

      @(r15===16'h0003);
      if (r10 !== 16'h0001) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESLO  (3) =====");
      if (r11 !== 16'hC000) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESHI  (3) =====");
      if (r12 !== 16'hFFFF) tb_error("====== SIGNED MULTIPLY ACCUMULATE: SUMEXT (3) =====");

      @(r15===16'h0004);
      if (r10 !== 16'h0001) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESLO  (4) =====");
      if (r11 !== 16'hFFFF) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESHI  (4) =====");
      if (r12 !== 16'hFFFF) tb_error("====== SIGNED MULTIPLY ACCUMULATE: SUMEXT (4) =====");

      @(r15===16'h0005);
      if (r10 !== 16'h0001) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESLO  (5) =====");
      if (r11 !== 16'hC000) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESHI  (5) =====");
      if (r12 !== 16'hFFFF) tb_error("====== SIGNED MULTIPLY ACCUMULATE: SUMEXT (5) =====");

      @(r15===16'h0006);
      if (r10 !== 16'h8001) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESLO  (6) =====");
      if (r11 !== 16'hBFFF) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESHI  (6) =====");
      if (r12 !== 16'hFFFF) tb_error("====== SIGNED MULTIPLY ACCUMULATE: SUMEXT (6) =====");

      @(r15===16'h0007);
      if (r10 !== 16'h8000) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESLO  (7) =====");
      if (r11 !== 16'h8000) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESHI  (7) =====");
      if (r12 !== 16'hFFFF) tb_error("====== SIGNED MULTIPLY ACCUMULATE: SUMEXT (7) =====");

      @(r15===16'h0008);
      if (r10 !== 16'h8000) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESLO  (8) =====");
      if (r11 !== 16'hC000) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESHI  (8) =====");
      if (r12 !== 16'hFFFF) tb_error("====== SIGNED MULTIPLY ACCUMULATE: SUMEXT (8) =====");

      @(r15===16'h0009);
      if (r10 !== 16'h0000) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESLO  (9) =====");
      if (r11 !== 16'h0000) tb_error("====== SIGNED MULTIPLY ACCUMULATE: RESHI  (9) =====");
      if (r12 !== 16'h0000) tb_error("====== SIGNED MULTIPLY ACCUMULATE: SUMEXT (9) =====");

      $display("Signed Multiply Accumulate test completed (MACS mode)");


      // 16-BIT RD/WR ACCESS OPERANDS
      //--------------------------------------------------------

      @(r15===16'h0001);
      if (r10 !== 16'h1234) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP1_MPY  (1) =====");
      if (r11 !== 16'h1234) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP1_MPYS (1) =====");
      if (r12 !== 16'h1234) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP1_MAC  (1) =====");
      if (r13 !== 16'h1234) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP1_MACS (1) =====");
      if (r14 !== 16'h5678) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP2      (1) =====");

      @(r15===16'h0002);
      if (r10 !== 16'h4321) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP1_MPY  (2) =====");
      if (r11 !== 16'h4321) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP1_MPYS (2) =====");
      if (r12 !== 16'h4321) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP1_MAC  (2) =====");
      if (r13 !== 16'h4321) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP1_MACS (2) =====");
      if (r14 !== 16'h8765) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP2      (2) =====");

      @(r15===16'h0003);
      if (r10 !== 16'h9ABC) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP1_MPY  (3) =====");
      if (r11 !== 16'h9ABC) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP1_MPYS (3) =====");
      if (r12 !== 16'h9ABC) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP1_MAC  (3) =====");
      if (r13 !== 16'h9ABC) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP1_MACS (3) =====");
      if (r14 !== 16'hDEF0) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP2      (3) =====");

      @(r15===16'h0004);
      if (r10 !== 16'hCBA9) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP1_MPY  (4) =====");
      if (r11 !== 16'hCBA9) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP1_MPYS (4) =====");
      if (r12 !== 16'hCBA9) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP1_MAC  (4) =====");
      if (r13 !== 16'hCBA9) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP1_MACS (4) =====");
      if (r14 !== 16'h0FED) tb_error("====== 16-BIT RD/WR ACCESS OPERANDS: OP2      (4) =====");

      $display("16-BIT RD/WR Access operands test completed");
     

      // 8-BIT RD/WR ACCESS OPERANDS
      //--------------------------------------------------------

      @(r15===16'h0001);
      if (r10 !== 16'h1234) tb_error("====== 8-BIT RD/WR ACCESS OPERANDS: OP1_MPY  (1) =====");
      if (r11 !== 16'h00ab) tb_error("====== 8-BIT RD/WR ACCESS OPERANDS: OP1_MPY  (2) =====");

      @(r15===16'h0002);
      if (r10 !== 16'h5678) tb_error("====== 8-BIT RD/WR ACCESS OPERANDS: OP1_MPYS (1) =====");
      if (r11 !== 16'h00bc) tb_error("====== 8-BIT RD/WR ACCESS OPERANDS: OP1_MPYS (2) =====");

      @(r15===16'h0003);
      if (r10 !== 16'h9abc) tb_error("====== 8-BIT RD/WR ACCESS OPERANDS: OP1_MAC  (1) =====");
      if (r11 !== 16'h00de) tb_error("====== 8-BIT RD/WR ACCESS OPERANDS: OP1_MAC  (2) =====");

      @(r15===16'h0004);
      if (r10 !== 16'hdef0) tb_error("====== 8-BIT RD/WR ACCESS OPERANDS: OP1_MACS (1) =====");
      if (r11 !== 16'h00ed) tb_error("====== 8-BIT RD/WR ACCESS OPERANDS: OP1_MACS (2) =====");

      @(r15===16'h0005);
      if (r10 !== 16'h4321) tb_error("====== 8-BIT RD/WR ACCESS OPERANDS: OP2      (1) =====");
      if (r11 !== 16'h00dc) tb_error("====== 8-BIT RD/WR ACCESS OPERANDS: OP2      (2) =====");

      @(r15===16'h0006);
      if (r10 !== 16'h8765) tb_error("====== 8-BIT RD/WR ACCESS OPERANDS: RESLO    (1) =====");
      if (r11 !== 16'h00cb) tb_error("====== 8-BIT RD/WR ACCESS OPERANDS: RESLO    (2) =====");

      @(r15===16'h0007);
      if (r10 !== 16'hcba9) tb_error("====== 8-BIT RD/WR ACCESS OPERANDS: RESHI    (1) =====");
      if (r11 !== 16'h00ba) tb_error("====== 8-BIT RD/WR ACCESS OPERANDS: RESHI    (2) =====");


      $display("8-BIT RD/WR Access operands test completed");


      stimulus_done = 1;
`else

       $display(" ===============================================");
       $display("|               SIMULATION SKIPPED              |");
       $display("|      (hardware multiplier not included)       |");
       $display(" ===============================================");
       $finish;
`endif
   end

