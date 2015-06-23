/* $Id: aeMB2_spsram.v,v 1.1 2008-04-20 16:33:39 sybreon Exp $
** 
** AEMB2 EDK 6.2 COMPATIBLE CORE
** Copyright (C) 2004-2008 Shawn Tan <shawn.tan@aeste.net>
** 
** This file is part of AEMB.
**
** AEMB is free software: you can redistribute it and/or modify it
** under the terms of the GNU Lesser General Public License as
** published by the Free Software Foundation, either version 3 of the
** License, or (at your option) any later version.
**
** AEMB is distributed in the hope that it will be useful, but WITHOUT
** ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
** or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
** Public License for more details.
**
** You should have received a copy of the GNU Lesser General Public
** License along with AEMB. If not, see <http:**www.gnu.org/licenses/>.
*/

/** 
 * @file aeMB2_spsram.v
 * @brief On-chip singla-port synchronous SRAM. 

 * Infer a write-before-read block RAM.

 * NOTES: Quartus (<=7.2) does not infer a block RAM with read enable.
 
 */

module aeMB2_spsram (/*AUTOARG*/
   // Outputs
   dat_o,
   // Inputs
   adr_i, dat_i, wre_i, ena_i, rst_i, clk_i
   ) ;
   parameter AW = 8;
   parameter DW = 32;

   // PORT A - READ/WRITE
   output [DW-1:0] dat_o;  
   input [AW-1:0]  adr_i;
   input [DW-1:0]  dat_i;
   input 	   wre_i,
		   ena_i,		   
		   rst_i,
		   clk_i;
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [DW-1:0]		dat_o;
   // End of automatics
   reg [DW:1] 	   rRAM [(1<<AW)-1:0];
   reg [AW:1] 	   rADR;
   
   always @(posedge clk_i)
     if (wre_i) rRAM[adr_i] <= #1 dat_i;

   always @(posedge clk_i)
     if (rst_i)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       dat_o <= {(1+(DW-1)){1'b0}};
       // End of automatics
     else if (ena_i) 
       dat_o <= #1 rRAM[adr_i];	

   // --- SIMULATION ONLY ------------------------------------
   // synopsys translate_off
   integer i;
   initial begin
      for (i=0; i<(1<<AW); i=i+1) begin
	 rRAM[i] <= $random;	 
      end
   end
   // synopsys translate_on
   
endmodule // aeMB2_spsram
