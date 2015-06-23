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
/*                        SERIAL DEBUG INTERFACE                             */
/*---------------------------------------------------------------------------*/
/* Test the serial debug interface:                                          */
/*                           - Interrupts when going out of halt mode.       */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 19 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2009-08-04 23:47:15 +0200 (Tue, 04 Aug 2009) $          */
/*===========================================================================*/

reg [15:0] r13_bkup;

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
`ifdef DBG_EN
`ifdef DBG_I2C
      #1 dbg_en = 1;
      repeat(30) @(posedge mclk);
      stimulus_done = 0;

`ifdef DBG_RST_BRK_EN
      dbg_i2c_wr(CPU_CTL,  16'h0002);  // RUN
`endif

      // Wait until software initialization is done
      if (r15!==(`PER_SIZE+16'h0000))
	@(r15==(`PER_SIZE+16'h0000));


      dbg_i2c_wr(CPU_CTL,  16'h0001);  // HALT
      repeat(150) @(posedge mclk);
      r13_bkup = r13;
	
      // Generate a GPIO interrupt
      p1_din[0] = 1'b1;
      repeat(150) @(posedge mclk);

      // Re-start the CPU
      dbg_i2c_wr(CPU_CTL,  16'h0002);  // RUN
      repeat(150) @(posedge mclk);

      // Make sure the interrupt was serviced
      if (r14 !== 16'haaaa) tb_error("====== Interrupt was not properly serviced =====");
      
      // Make sure the program resumed execution when coming back from IRQ
      if (r13 === r13_bkup) tb_error("====== Program didn't properly resumed execution =====");


      p1_din[1] = 1'b1;     
      stimulus_done = 1;
`else

       $display(" ===============================================");
       $display("|               SIMULATION SKIPPED              |");
       $display("|   (serial debug interface I2C not included)   |");
       $display(" ===============================================");
       $finish;
`endif
`else

       $display(" ===============================================");
       $display("|               SIMULATION SKIPPED              |");
       $display("|      (serial debug interface not included)    |");
       $display(" ===============================================");
       $finish;
`endif
   end

