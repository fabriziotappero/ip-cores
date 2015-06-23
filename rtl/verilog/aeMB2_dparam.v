/* $Id: aeMB2_dparam.v,v 1.1 2008-04-26 17:57:43 sybreon Exp $
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
 * @file aeMB2_dparam.v
 * @brief On-chip dual-port asynchronous SRAM.

 * This will be implemented as distributed RAM with one read/write
   port and one read-only port.
  
 */

// 32x64 = 77
// 64x32 = 146

module aeMB2_dparam (/*AUTOARG*/
   // Outputs
   dat_o, xdat_o,
   // Inputs
   adr_i, dat_i, wre_i, xadr_i, xdat_i, xwre_i, clk_i, ena_i
   ) ;
   parameter AW = 5; // 32
   parameter DW = 2; // x2

   // PORT A - READ/WRITE
   output [DW-1:0] dat_o;  
   input [AW-1:0]  adr_i;
   input [DW-1:0]  dat_i;
   input 	   wre_i;
   
   // PORT X - READ ONLY
   output [DW-1:0] xdat_o;  
   input [AW-1:0]  xadr_i;
   input [DW-1:0]  xdat_i;
   input 	   xwre_i;
   
   // SYSCON
   input 	   clk_i, 
		   ena_i;

   /*AUTOREG*/   
   reg [DW-1:0]    rRAM [(1<<AW)-1:0];
   
   always @(posedge clk_i)
     if (wre_i) rRAM[adr_i] <= #1 dat_i;	
   
   assign 	   dat_o = rRAM[adr_i];
   assign 	   xdat_o = rRAM[xadr_i];   
   
   // --- SIMULATION ONLY ------------------------------------
   // synopsys translate_off
   integer 	   i;
   initial begin
      for (i=0; i<(1<<AW); i=i+1) 
	begin
	   rRAM[i] <= {(DW){1'b0}};
end
   end
   // synopsys translate_on
   
endmodule // aeMB2_dparam

/*
 $Log: not supported by cvs2svn $
 Revision 1.1  2008/04/20 16:33:39  sybreon
 Initial import.
*/