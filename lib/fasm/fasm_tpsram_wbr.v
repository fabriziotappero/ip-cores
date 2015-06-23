/* $Id: fasm_tpsram.v,v 1.1 2008/06/05 20:51:56 sybreon Exp $
**
** FASM MEMORY LIBRARY
** Copyright (C) 2004-2009 Shawn Tan <shawn.tan@aeste.net>
** All rights reserved.
** 
** FASM is free software: you can redistribute it and/or modify it
** under the terms of the GNU Lesser General Public License as
** published by the Free Software Foundation, either version 3 of the
** License, or (at your option) any later version.
**
** FASM is distributed in the hope that it will be useful, but WITHOUT
** ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
** or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
** Public License for more details.
**
** You should have received a copy of the GNU Lesser General Public
** License along with FASM. If not, see <http:**www.gnu.org/licenses/>.
*/
/*
 * TWO PORT SYNCHRONOUS RAM - WRITE-BEFORE-READ
 * Synthesis proven on:
 * - Xilinx ISE
 * - Altera Quartus (>=8.0) 
 */

module fasm_tpsram_wbr (/*AUTOARG*/
   // Outputs
   dat_o, xdat_o,
   // Inputs
   dat_i, adr_i, wre_i, stb_i, rst_i, clk_i, xdat_i, xadr_i, xwre_i,
   xstb_i, xrst_i, xclk_i
   );

   parameter AW = 8;  ///< address space (2^AW) words
   parameter DW = 32; ///< data word width bits

   // wishbone port a
   output [DW-1:0] dat_o; // DO
   input [DW-1:0]  dat_i; // DI - unused
   input [AW-1:0]  adr_i; // A
   input 	   wre_i; // WE - unused
   input 	   stb_i; // CS
   
   input 	   rst_i,
		   clk_i;

   // wishbone port x
   output [DW-1:0] xdat_o; // DO - unused
   input [DW-1:0]  xdat_i; // DI
   input [AW-1:0]  xadr_i; // A
   input 	   xwre_i; // WE
   input 	   xstb_i; // CS
   
   input 	   xrst_i,
		   xclk_i;
   
   // address latch
   reg [AW-1:0]    rA, rX;   
   
   // memory block
   reg [DW-1:0]    bram [(1<<AW)-1:0]; 
   
   always @(posedge clk_i)
     if (stb_i)
       begin
	  rA <= #1 adr_i;
	  if (wre_i) // strobe and write-enable
	    bram[adr_i] <= #1 dat_i;	  
       end

   always @(posedge xclk_i)
     if (xstb_i)
       begin
	  rX <= #1 xadr_i;	  
       end

   //assign 	   xdat_o = {(DW){1'bX}}; // write-thru
   assign 	   xdat_o = bram[rX]; // write-thru
   assign 	   dat_o = bram[rA]; // write-thru
   
   // ### SIMULATION ONLY ###
   // synopsys translate_off
   integer i;
   initial begin
      for (i=0; i<(1<<AW); i=i+1) begin
	 bram[i] <= $random;	 
      end
   end   
   // synopsys translate_on
   
endmodule // fasm_dpsram
