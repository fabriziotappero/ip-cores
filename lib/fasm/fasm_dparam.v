/* $Id: fasm_dparam.v,v 1.2 2008/06/05 20:53:16 sybreon Exp $
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
 * DUAL PORT ASYNCHRONOUS MEMORY BLOCK
 * Synthesis proven on:
 * - Xilinx ISE
 * - Altera Quartus (>=8.0) 
 */

module fasm_dparam (/*AUTOARG*/
   // Outputs
   dat_o, xdat_o,
   // Inputs
   dat_i, adr_i, wre_i, stb_i, clk_i, rst_i, xdat_i, xadr_i, xwre_i,
   xstb_i, xclk_i, xrst_i
   ) ;
   parameter AW = 5; // 32
   parameter DW = 2; // x2

   // PORT A - READ-ONLY
   output [DW-1:0] dat_o;  
   input [DW-1:0]  dat_i; // ignored
   input [AW-1:0]  adr_i;
   input 	   wre_i; // ignored
   input 	   stb_i; // ignored
   
   input 	   clk_i,
		   rst_i;

   // PORT X - READ/WRITE
   output [DW-1:0] xdat_o;  
   input [DW-1:0]  xdat_i;
   input [AW-1:0]  xadr_i;
   input 	   xwre_i;
   input 	   xstb_i; // ignored
   
   input 	   xclk_i,
		   xrst_i;

   reg [DW-1:0]    lram [(1<<AW)-1:0];
   
   always @(posedge xclk_i)
     if (xwre_i) lram[xadr_i] <= #1 xdat_i;	
   
   assign 	   dat_o = lram[adr_i];
   assign 	   xdat_o = lram[xadr_i];   
   
   // ### SIMULATION ONLY ###
   // synopsys translate_off
   integer i;
   initial begin
      for (i=0; i<(1<<AW); i=i+1) begin
	 lram[i] <= $random;	 
      end
   end
   // synopsys translate_on
      
endmodule // fasm_dparam
