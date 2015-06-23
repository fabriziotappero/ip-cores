/* $Id: aeMB2_brcc.v,v 1.3 2008-04-26 01:09:05 sybreon Exp $
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
 * Branch Condition Checker
 * @file aeMB2_brcc.v
 
 * This controls the decision to branch/delay. The actualy branch
   target is calculated in the ALU.
 
 */

module aeMB2_brcc (/*AUTOARG*/
   // Outputs
   bra_ex,
   // Inputs
   opd_of, ra_of, rd_of, opc_of, gclk, grst, dena, iena, gpha
   );
   parameter AEMB_HTX = 1;   
   
   input [31:0] opd_of;   
   input [4:0] 	ra_of;
   input [4:0] 	rd_of;
   input [5:0] 	opc_of;   

   output [1:0] bra_ex;
   
   // SYS signals
   input 	gclk,
		grst,
		dena,
		iena,
		gpha;      

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [1:0]		bra_ex;
   // End of automatics
   
   // TODO: replace comparators with logic
   
   /* Branch Control */
   wire 	wRTD = (opc_of == 6'o55);
   wire 	wBCC = (opc_of == 6'o47) | (opc_of == 6'o57);
   wire 	wBRU = (opc_of == 6'o46) | (opc_of == 6'o56);
   
   wire 	wBEQ = (opd_of == 32'd0);
   wire 	wBLT = opd_of[31];
   wire 	wBLE = wBLT | wBEQ;   
   wire 	wBNE = ~wBEQ;
   wire 	wBGE = ~wBLT;
   wire 	wBGT = ~wBLE;   
   
   reg 		 xcc;
   
   always @(/*AUTOSENSE*/rd_of or wBEQ or wBGE or wBGT or wBLE or wBLT
	    or wBNE) begin
      case (rd_of[2:0])
	3'o0: xcc <= wBEQ;
	3'o1: xcc <= wBNE;
	3'o2: xcc <= wBLT;
	3'o3: xcc <= wBLE;
	3'o4: xcc <= wBGT;
	3'o5: xcc <= wBGE;
	default: xcc <= 1'bX;
      endcase // case (rd_of[2:0])
   end // always @ (...
   
   always @(posedge gclk)
     if (grst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	bra_ex <= 2'h0;
	// End of automatics
     end else if (dena) begin
	bra_ex[1] <= #1 (wRTD | wBRU | (wBCC & xcc)); // branch
	bra_ex[0] <= #1 (wBRU) ? ra_of[4] : rd_of[4]; // delay	
     end
      
endmodule // aeMB2_brcc

/*
 $Log: not supported by cvs2svn $
 Revision 1.2  2008/04/20 16:34:32  sybreon
 Basic version with some features left out.

 Revision 1.1  2008/04/18 00:21:52  sybreon
 Initial import.
*/