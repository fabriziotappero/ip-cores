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
/* $Rev: 95 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2011-02-24 21:37:57 +0100 (Thu, 24 Feb 2011) $          */
/*===========================================================================*/

integer    i;
reg [15:0] temp_val;

integer inst_cnt;
always @(inst_number)
  inst_cnt <= inst_cnt+1;

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

`ifdef NMI

      // Test NMI disabled
      //--------------------------
      @(r15==16'h1000);
      $display(" Test NMI disabled");

      @(r15==16'h1001);
      #(2000);
      inst_cnt = 0;
      #(2000);
      if (inst_cnt !==16'h0000)  tb_error("====== NMI rising edge: CPU is not sleeping =====");
      nmi       = 1'b1;
      #(6000);
      if (inst_cnt !==16'h0000)  tb_error("====== NMI rising edge: CPU is not sleeping =====");

      wkup[0]            = 1'b1;
      @(negedge mclk)
      irq[`IRQ_NR-16]    = 1'b1;
      @(negedge irq_acc[`IRQ_NR-16])
      wkup[0]            = 1'b0;
      irq[`IRQ_NR-16]    = 1'b0;

      @(r15==16'h1002);
      nmi       = 1'b0;

      if (r6    !==16'h0000)  tb_error("====== NMI disabled: NMI irq was taken       =====");
      if (r14   !==16'h0000)  tb_error("====== NMI disabled: flag is set after reset =====");
      if (r13   !==16'h0010)  tb_error("====== NMI disabled: flag is not set         =====");
      if (r12   !==16'h0000)  tb_error("====== NMI disabled: flag was not cleared    =====");
      if (r11   !==16'h0000)  tb_error("====== NMI disabled: flag is set             =====");


      // Test NMI rising edge
      //--------------------------
      @(r15==16'h2000);
      $display(" Test NMI rising edge");

      @(r15==16'h2001);

      #(2000);
      inst_cnt = 0;
      #(2000);
      if (inst_cnt !==16'h0000)  tb_error("====== NMI rising edge: CPU is not sleeping =====");
      #(2000);
      nmi      = 1'b1;

      #(2000);
      if (r6       !==16'h0001)  tb_error("====== NMI rising edge: NMI irq was not taken first time =====");
      if (inst_cnt ===16'h0000)  tb_error("====== NMI rising edge: CPU did not woke up because of NMI =====");
      inst_cnt = 0;
      #(2000);
      if (inst_cnt !==16'h0000)  tb_error("====== NMI rising edge: CPU is not sleeping =====");
      #(2000);
      nmi      = 1'b0;

      #(4000);
      if (r6       !==16'h0001)  tb_error("====== NMI rising edge: NMI irq was taken with falling edge =====");
      if (inst_cnt !==16'h0000)  tb_error("====== NMI rising edge: CPU is not sleeping =====");
      #(2000);
      nmi      = 1'b1;

      #(2000);
      if (r6       !==16'h0002)  tb_error("====== NMI rising edge: NMI irq was not taken second time =====");
      if (inst_cnt ===16'h0000)  tb_error("====== NMI rising edge: CPU did not woke up because of NMI =====");
      inst_cnt = 0;
      #(2000);
      if (inst_cnt ===16'h0000)  tb_error("====== NMI rising edge: CPU is not running =====");
      #(2000);
      nmi      = 1'b0;
      #(4000);
      if (r6       !==16'h0002)  tb_error("====== NMI rising edge: NMI irq was taken with falling edge =====");


      // Test NMI falling edge
      //--------------------------
      @(r15==16'h3000);
`ifdef WATCHDOG
      $display(" Test NMI falling edge");
`else
      $display(" Skip NMI falling edge (Watchdog is not included)");
`endif

      @(r15==16'h3001);

      #(2000);
      inst_cnt = 0;
      #(2000);
      if (inst_cnt !==16'h0000)  tb_error("====== NMI falling edge: CPU is not sleeping =====");
      #(2000);
      nmi      = 1'b1;

      #(2000);
`ifdef WATCHDOG
      if (r6       !==16'h0000)  tb_error("====== NMI falling edge: NMI irq was taken with rising edge =====");
      if (inst_cnt !==16'h0000)  tb_error("====== NMI falling edge: CPU is not sleeping =====");
      #(2000);
      if (inst_cnt !==16'h0000)  tb_error("====== NMI falling edge: CPU is not sleeping =====");
`else
      #(2000);
`endif
      #(2000);
      nmi      = 1'b0;

      #(2000);
      if (r6       !==16'h0001)  tb_error("====== NMI falling edge: NMI irq was not taken first time =====");
      if (inst_cnt ===16'h0000)  tb_error("====== NMI falling edge: CPU did not woke up because of NMI =====");
      inst_cnt = 0;
      #(2000);
      if (inst_cnt !==16'h0000)  tb_error("====== NMI falling edge: CPU is not sleeping =====");
      #(2000);
      nmi      = 1'b1;

      #(2000);
`ifdef WATCHDOG
      if (r6       !==16'h0001)  tb_error("====== NMI falling edge: NMI irq was taken with rising edge =====");
      if (inst_cnt !==16'h0000)  tb_error("====== NMI falling edge: CPU is not sleeping =====");
      #(2000);
      if (inst_cnt !==16'h0000)  tb_error("====== NMI falling edge: CPU is not sleeping =====");
`else
      #(2000);
`endif
      #(2000);
      nmi      = 1'b0;

      #(2000);
      if (r6       !==16'h0002)  tb_error("====== NMI falling edge: NMI irq was not taken second time =====");
      if (inst_cnt ===16'h0000)  tb_error("====== NMI falling edge: CPU did not woke up because of NMI =====");
      inst_cnt = 0;
      #(2000);
      if (inst_cnt ===16'h0000)  tb_error("====== NMI falling edge: CPU is not out of LPM4 =====");
      #(2000);

      // Test NMI nested from Maskable-IRQ
      //-----------------------------------
      @(r15==16'h4000);
      $display(" Test NMI nested from Maskable-IRQ");

      @(r15==16'h4001);
      #(2000);
      inst_cnt = 0;
      #(2000);
      if (inst_cnt !==16'h0000)  tb_error("====== NMI nested: CPU is not sleeping =====");
      #(2000);
      wkup[0]            = 1'b1;
      irq[`IRQ_NR-16]    = 1'b1;
      @(negedge irq_acc[`IRQ_NR-16])
      wkup[0]            = 1'b0;
      irq[`IRQ_NR-16]    = 1'b0;
      nmi                = 1'b1;

      @(r15==16'h4002);
      if (r6       !==16'h0001)  tb_error("====== NMI nested: NMI irq was not taken =====");
      if (inst_cnt ===16'h0000)  tb_error("====== NMI nested: CPU did not woke up   =====");
      if (r10      !==16'h5679)  tb_error("====== NMI nested: NMI was not nested from IRQ =====");


`else
      $display(" ===============================================");
      $display("|               SIMULATION SKIPPED              |");
      $display("|         (the NMI support is not included)     |");
      $display(" ===============================================");
      $finish;
`endif

      stimulus_done = 1;
   end
