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
/*                 SINGLE-OPERAND ARITHMETIC: RETI  INSTRUCTION              */
/*---------------------------------------------------------------------------*/
/* Test the RETI instruction.                                                */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 192 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2013-12-17 21:15:28 +0100 (Tue, 17 Dec 2013) $          */
/*===========================================================================*/

integer    i;
reg [15:0] temp_val;

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

      // RETI Instruction test
      //--------------------------
      @(r15==16'h1000);
      if (r3    !==16'h0000) tb_error("====== RESET Vector: R3  value  =====");
      if (r4    !==16'h0000) tb_error("====== RESET Vector: R4  value  =====");
      if (r5    !==16'h0000) tb_error("====== RESET Vector: R5  value  =====");
      if (r6    !==16'h0000) tb_error("====== RESET Vector: R6  value  =====");
      if (r7    !==16'h0000) tb_error("====== RESET Vector: R7  value  =====");
      if (r8    !==16'h0000) tb_error("====== RESET Vector: R8  value  =====");
      if (r9    !==16'h0000) tb_error("====== RESET Vector: R9  value  =====");
      if (r10   !==16'h0000) tb_error("====== RESET Vector: R10 value  =====");
      if (r11   !==16'h0000) tb_error("====== RESET Vector: R11 value  =====");
      if (r12   !==16'h0000) tb_error("====== RESET Vector: R12 value  =====");
      if (r13   !==16'h0000) tb_error("====== RESET Vector: R13 value  =====");
      if (r14   !==16'h0000) tb_error("====== RESET Vector: R14 value  =====");


      // RETI Instruction test
      //--------------------------
      @(r15==16'h2000);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== RETI: SP value      =====");
      if (r2    !==16'h010f)             tb_error("====== RETI: SR value      =====");
      if (r5    !==16'h1234)             tb_error("====== RETI: R5 value      =====");


      // Test interruption 0
      //--------------------------
      @(r15==16'h3000);
      repeat(2) @(posedge mclk);
      irq[`IRQ_NR-16:0] = {`IRQ_NR-16+1{1'b1}};
      repeat(15) @(posedge mclk);
      irq[`IRQ_NR-16:0] = {`IRQ_NR-16+1{1'b0}};

      @(r15==16'h3001);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== IRQ  0: SP value      =====");
      if (r2[3] !==1'b1)                 tb_error("====== IRQ  0: GIE value     =====");
      if (r6    !==16'h5678)             tb_error("====== IRQ  0: R6 value      =====");
      if (r7    !==16'h0000)             tb_error("====== IRQ  0: R7 value      =====");
      if (r8    !==(`PER_SIZE+16'h004e)) tb_error("====== IRQ  0: R8 value      =====");


      // Test interruption 1
      //--------------------------
      @(r15==16'h4000);
      repeat(2) @(posedge mclk);
      irq[`IRQ_NR-15:0] = {`IRQ_NR-15+1{1'b1}};
      repeat(15) @(posedge mclk);
      irq[`IRQ_NR-15:0] = {`IRQ_NR-15+1{1'b0}};

      @(r15==16'h4001);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== IRQ  1: SP value      =====");
      if (r2[3] !==1'b1)                 tb_error("====== IRQ  1: GIE value     =====");
      if (r6    !==16'h9abc)             tb_error("====== IRQ  1: R6 value      =====");
      if (r7    !==16'h0000)             tb_error("====== IRQ  1: R7 value      =====");
      if (r8    !==(`PER_SIZE+16'h004e)) tb_error("====== IRQ  1: R8 value      =====");


      // Test interruption 2
      //--------------------------
      @(r15==16'h5000);
      repeat(2) @(posedge mclk);
      irq[`IRQ_NR-14:0] = {`IRQ_NR-14+1{1'b1}};
      repeat(15) @(posedge mclk);
      irq[`IRQ_NR-14:0] = {`IRQ_NR-14+1{1'b0}};

      @(r15==16'h5001);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== IRQ  2: SP value      =====");
      if (r2[3] !==1'b1)                 tb_error("====== IRQ  2: GIE value     =====");
      if (r6    !==16'hdef1)             tb_error("====== IRQ  2: R6 value      =====");
      if (r7    !==16'h0000)             tb_error("====== IRQ  2: R7 value      =====");
      if (r8    !==(`PER_SIZE+16'h004e)) tb_error("====== IRQ  2: R8 value      =====");


      // Test interruption 3
      //--------------------------
      @(r15==16'h6000);
      repeat(2) @(posedge mclk);
      irq[`IRQ_NR-13:0] = {`IRQ_NR-13+1{1'b1}};
      repeat(15) @(posedge mclk);
      irq[`IRQ_NR-13:0] = {`IRQ_NR-13+1{1'b0}};

      @(r15==16'h6001);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== IRQ  3: SP value      =====");
      if (r2[3] !==1'b1)                 tb_error("====== IRQ  3: GIE value     =====");
      if (r6    !==16'h2345)             tb_error("====== IRQ  3: R6 value      =====");
      if (r7    !==16'h0000)             tb_error("====== IRQ  3: R7 value      =====");
      if (r8    !==(`PER_SIZE+16'h004e)) tb_error("====== IRQ  3: R8 value      =====");


      // Test interruption 4
      //--------------------------
      @(r15==16'h7000);
      repeat(2) @(posedge mclk);
      irq[`IRQ_NR-12:0] = {`IRQ_NR-12+1{1'b1}};
      repeat(15) @(posedge mclk);
      irq[`IRQ_NR-12:0] = {`IRQ_NR-12+1{1'b0}};

      @(r15==16'h7001);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== IRQ  4: SP value      =====");
      if (r2[3] !==1'b1)                 tb_error("====== IRQ  4: GIE value     =====");
      if (r6    !==16'h6789)             tb_error("====== IRQ  4: R6 value      =====");
      if (r7    !==16'h0000)             tb_error("====== IRQ  4: R7 value      =====");
      if (r8    !==(`PER_SIZE+16'h004e)) tb_error("====== IRQ  4: R8 value      =====");


      // Test interruption 5
      //--------------------------
      @(r15==16'h8000);
      repeat(2) @(posedge mclk);
      irq[`IRQ_NR-11:0] = {`IRQ_NR-11+1{1'b1}};
      repeat(15) @(posedge mclk);
      irq[`IRQ_NR-11:0] = {`IRQ_NR-11+1{1'b0}};

      @(r15==16'h8001);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== IRQ  5: SP value      =====");
      if (r2[3] !==1'b1)                 tb_error("====== IRQ  5: GIE value     =====");
      if (r6    !==16'habcd)             tb_error("====== IRQ  5: R6 value      =====");
      if (r7    !==16'h0000)             tb_error("====== IRQ  5: R7 value      =====");
      if (r8    !==(`PER_SIZE+16'h004e)) tb_error("====== IRQ  5: R8 value      =====");


      // Test interruption 6
      //--------------------------
      @(r15==16'h9000);
      repeat(2) @(posedge mclk);
      irq[`IRQ_NR-10:0] = {`IRQ_NR-10+1{1'b1}};
      repeat(15) @(posedge mclk);
      irq[`IRQ_NR-10:0] = {`IRQ_NR-10+1{1'b0}};

      @(r15==16'h9001);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== IRQ  6: SP value      =====");
      if (r2[3] !==1'b1)                 tb_error("====== IRQ  6: GIE value     =====");
      if (r6    !==16'hef12)             tb_error("====== IRQ  6: R6 value      =====");
      if (r7    !==16'h0000)             tb_error("====== IRQ  6: R7 value      =====");
      if (r8    !==(`PER_SIZE+16'h004e)) tb_error("====== IRQ  6: R8 value      =====");


      // Test interruption 7
      //--------------------------
      @(r15==16'ha000);
      repeat(2) @(posedge mclk);
      irq[`IRQ_NR-9:0] = {`IRQ_NR-9+1{1'b1}};
      repeat(15) @(posedge mclk);
      irq[`IRQ_NR-9:0] = {`IRQ_NR-9+1{1'b0}};

      @(r15==16'ha001);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== IRQ  7: SP value      =====");
      if (r2[3] !==1'b1)                 tb_error("====== IRQ  7: GIE value     =====");
      if (r6    !==16'h3456)             tb_error("====== IRQ  7: R6 value      =====");
      if (r7    !==16'h0000)             tb_error("====== IRQ  7: R7 value      =====");
      if (r8    !==(`PER_SIZE+16'h004e)) tb_error("====== IRQ  7: R8 value      =====");


      // Test interruption 8
      //--------------------------
      @(r15==16'hb000);
      repeat(2) @(posedge mclk);
      irq[`IRQ_NR-8:0] = {`IRQ_NR-8+1{1'b1}};
      repeat(15) @(posedge mclk);
      irq[`IRQ_NR-8:0] = {`IRQ_NR-8+1{1'b0}};

      @(r15==16'hb001);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== IRQ  8: SP value      =====");
      if (r2[3] !==1'b1)                 tb_error("====== IRQ  8: GIE value     =====");
      if (r6    !==16'h789a)             tb_error("====== IRQ  8: R6 value      =====");
      if (r7    !==16'h0000)             tb_error("====== IRQ  8: R7 value      =====");
      if (r8    !==(`PER_SIZE+16'h004e)) tb_error("====== IRQ  8: R8 value      =====");


      // Test interruption 9
      //--------------------------
      @(r15==16'hc000);
      repeat(2) @(posedge mclk);
      irq[`IRQ_NR-7:0] = {`IRQ_NR-7+1{1'b1}};
      repeat(15) @(posedge mclk);
      irq[`IRQ_NR-7:0] = {`IRQ_NR-7+1{1'b0}};

      @(r15==16'hc001);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== IRQ  9: SP value      =====");
      if (r2[3] !==1'b1)                 tb_error("====== IRQ  9: GIE value     =====");
      if (r6    !==16'hbcde)             tb_error("====== IRQ  9: R6 value      =====");
      if (r7    !==16'h0000)             tb_error("====== IRQ  9: R7 value      =====");
      if (r8    !==(`PER_SIZE+16'h004e)) tb_error("====== IRQ  9: R8 value      =====");


      // Test interruption 10
      //--------------------------
      @(r15==16'hd000);
      repeat(2) @(posedge mclk);
      irq[`IRQ_NR-6:0] = {`IRQ_NR-6+1{1'b1}};
      repeat(15) @(posedge mclk);
      irq[`IRQ_NR-6:0] = {`IRQ_NR-6+1{1'b0}};

      @(r15==16'hd001);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== IRQ 10: SP value      =====");
      if (r2[3] !==1'b1)                 tb_error("====== IRQ 10: GIE value     =====");
      if (r6    !==16'hf123)             tb_error("====== IRQ 10: R6 value      =====");
      if (r7    !==16'h0000)             tb_error("====== IRQ 10: R7 value      =====");
      if (r8    !==(`PER_SIZE+16'h004e)) tb_error("====== IRQ 10: R8 value      =====");


      // Test interruption 11
      //--------------------------
      @(r15==16'he000);
      repeat(2) @(posedge mclk);
      irq[`IRQ_NR-5:0] = {`IRQ_NR-5+1{1'b1}};
      repeat(15) @(posedge mclk);
      irq[`IRQ_NR-5:0] = {`IRQ_NR-5+1{1'b0}};

      @(r15==16'he001);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== IRQ 11: SP value      =====");
      if (r2[3] !==1'b1)                 tb_error("====== IRQ 11: GIE value     =====");
      if (r6    !==16'h4567)             tb_error("====== IRQ 11: R6 value      =====");
      if (r7    !==16'h0000)             tb_error("====== IRQ 11: R7 value      =====");
      if (r8    !==(`PER_SIZE+16'h004e)) tb_error("====== IRQ 11: R8 value      =====");


      // Test interruption 12
      //--------------------------
      @(r15==16'hf000);
      repeat(2) @(posedge mclk);
      irq[`IRQ_NR-4:0] = {`IRQ_NR-4+1{1'b1}};
      repeat(15) @(posedge mclk);
      irq[`IRQ_NR-4:0] = {`IRQ_NR-4+1{1'b0}};

      @(r15==16'hf001);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== IRQ 12: SP value      =====");
      if (r2[3] !==1'b1)                 tb_error("====== IRQ 12: GIE value     =====");
      if (r6    !==16'h89ab)             tb_error("====== IRQ 12: R6 value      =====");
      if (r7    !==16'h0000)             tb_error("====== IRQ 12: R7 value      =====");
      if (r8    !==(`PER_SIZE+16'h004e)) tb_error("====== IRQ 12: R8 value      =====");


      // Test interruption 13
      //--------------------------
      @(r15==16'hf100);
      repeat(2) @(posedge mclk);
      irq[`IRQ_NR-3:0] = {`IRQ_NR-3+1{1'b1}};
      repeat(15) @(posedge mclk);
      irq[`IRQ_NR-3:0] = {`IRQ_NR-3+1{1'b0}};

      @(r15==16'hf101);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== IRQ 13: SP value      =====");
      if (r2[3] !==1'b1)                 tb_error("====== IRQ 13: GIE value     =====");
      if (r6    !==16'hcdef)             tb_error("====== IRQ 13: R6 value      =====");
      if (r7    !==16'h0000)             tb_error("====== IRQ 13: R7 value      =====");
      if (r8    !==(`PER_SIZE+16'h004e)) tb_error("====== IRQ 13: R8 value      =====");


      // Test interruption NMI:	 rising edge
      //--------------------------------------
  `ifdef NMI
      @(r15==16'hf200);
      repeat(2) @(negedge mclk);
      nmi       = 1'b1;
      @(posedge nmi_detect);
      irq[`IRQ_NR-3:0] = {`IRQ_NR-3+1{1'b1}};
      repeat(8) @(posedge mclk);
      nmi       = 1'b0;
      repeat(2) @(posedge mclk);
      irq[`IRQ_NR-3:0] = {`IRQ_NR-3+1{1'b0}};

      @(r15==16'hf201);
      if (r1    !==(`PER_SIZE+16'h0052)) tb_error("====== NMI: SP value      =====");
      if (r2[3] !==1'b1)                 tb_error("====== NMI: GIE value     =====");
      if (r6    !==16'h0123)             tb_error("====== NMI: R6 value      =====");
      if (r7    !==16'h0000)             tb_error("====== NMI: R7 value      =====");
      if (r8    !==(`PER_SIZE+16'h004e)) tb_error("====== NMI: R8 value      =====");

      if (r9    !==16'h0000)             tb_error("====== NMI: NMIE   value  =====");
      if (r10   !==16'h0010)             tb_error("====== NMI: NMIIFG value  =====");
   `endif

      stimulus_done = 1;
   end

