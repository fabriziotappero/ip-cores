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
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 18 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2009-08-04 23:44:12 +0200 (Tue, 04 Aug 2009) $          */
/*===========================================================================*/
    
`define NO_TIMEOUT

integer     i;
reg  [31:0] result;

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
`ifdef MULTIPLIER
      repeat(5) @(posedge mclk);
      stimulus_done = 0;
      i = 0;
     

      for ( i=0; i < 'h10000; i=i+1)
	begin
	   @(r15);
	   result = r8*r9;
	   if (r10 !== result[15:0])
	     begin
		$display("ERROR: OP1 = 0x%h / OP2 = 0x%h", r8, r9);
		$display("ERROR: Result is: SUMEXT = 0x%h / RESHI = 0x%h / RESLO = 0x%h", r12, r11, r10);
		$display("ERROR: Expected : SUMEXT = 0x%h / RESHI = 0x%h / RESLO = 0x%h", 0, result[31:16], result[15:0]);
		tb_error("====== UNSIGNED MULTIPLICATION: RESLO =====");
	     end
	   if (r11 !== result[31:16])
	     begin
		$display("ERROR: OP1 = 0x%h / OP2 = 0x%h", r8, r9);
		$display("ERROR: Result is: SUMEXT = 0x%h / RESHI = 0x%h / RESLO = 0x%h", r12, r11, r10);
		$display("ERROR: Expected : SUMEXT = 0x%h / RESHI = 0x%h / RESLO = 0x%h", 0, result[31:16], result[15:0]);
		tb_error("====== UNSIGNED MULTIPLICATION: RESHI =====");
	     end
	   if (r12 !== 16'h0000)
	     begin
		$display("ERROR: OP1 = 0x%h / OP2 = 0x%h", r8, r9);
		$display("ERROR: Result is: SUMEXT = 0x%h / RESHI = 0x%h / RESLO = 0x%h", r12, r11, r10);
		$display("ERROR: Expected : SUMEXT = 0x%h / RESHI = 0x%h / RESLO = 0x%h", 0, result[31:16], result[15:0]);
		tb_error("====== UNSIGNED MULTIPLICATION: SUMEXT =====");
	     end

	   if (r15[7:0]==8'h00)
	     $display("OP2 = 0x%h done", r9);
	end



      stimulus_done = 1;
`else

       $display(" ===============================================");
       $display("|               SIMULATION SKIPPED              |");
       $display("|      (hardware multiplier not included)       |");
       $display(" ===============================================");
       $finish;
`endif
   end

