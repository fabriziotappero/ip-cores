/* $Id: aeMB2_regs.v,v 1.4 2008-04-26 17:57:43 sybreon Exp $
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
 * Register File Wrapper
 * @file aeMB2_regs.v

 * A collection of general purpose and special function registers.
 
 */

// 200@207

module aeMB2_regs (/*AUTOARG*/
   // Outputs
   opd_if, opb_if, opa_if,
   // Inputs
   xwb_mx, sfr_mx, sel_mx, rpc_mx, rd_of, rd_ex, mux_of, mux_ex,
   mul_mx, ich_dat, grst, gpha, gclk, dwb_mx, dena, bsf_mx, alu_mx
   );

   parameter AEMB_HTX = 1;

   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [31:0]	opa_if;			// From gprf0 of aeMB2_gprf.v
   output [31:0]	opb_if;			// From gprf0 of aeMB2_gprf.v
   output [31:0]	opd_if;			// From gprf0 of aeMB2_gprf.v
   // End of automatics
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [31:0]		alu_mx;			// To gprf0 of aeMB2_gprf.v
   input [31:0]		bsf_mx;			// To gprf0 of aeMB2_gprf.v
   input		dena;			// To gprf0 of aeMB2_gprf.v
   input [31:0]		dwb_mx;			// To gprf0 of aeMB2_gprf.v
   input		gclk;			// To gprf0 of aeMB2_gprf.v
   input		gpha;			// To gprf0 of aeMB2_gprf.v
   input		grst;			// To gprf0 of aeMB2_gprf.v
   input [31:0]		ich_dat;		// To gprf0 of aeMB2_gprf.v
   input [31:0]		mul_mx;			// To gprf0 of aeMB2_gprf.v
   input [2:0]		mux_ex;			// To gprf0 of aeMB2_gprf.v
   input [2:0]		mux_of;			// To gprf0 of aeMB2_gprf.v
   input [4:0]		rd_ex;			// To gprf0 of aeMB2_gprf.v
   input [4:0]		rd_of;			// To gprf0 of aeMB2_gprf.v
   input [31:2]		rpc_mx;			// To gprf0 of aeMB2_gprf.v
   input [3:0]		sel_mx;			// To gprf0 of aeMB2_gprf.v
   input [31:0]		sfr_mx;			// To gprf0 of aeMB2_gprf.v
   input [31:0]		xwb_mx;			// To gprf0 of aeMB2_gprf.v
   // End of automatics
   /*AUTOWIRE*/

   // TODO: Add special function registers
      
   aeMB2_gprf
     #(/*AUTOINSTPARAM*/
       // Parameters
       .AEMB_HTX			(AEMB_HTX))
   gprf0
     (/*AUTOINST*/
      // Outputs
      .opa_if				(opa_if[31:0]),
      .opb_if				(opb_if[31:0]),
      .opd_if				(opd_if[31:0]),
      // Inputs
      .mux_of				(mux_of[2:0]),
      .mux_ex				(mux_ex[2:0]),
      .ich_dat				(ich_dat[31:0]),
      .rd_of				(rd_of[4:0]),
      .rd_ex				(rd_ex[4:0]),
      .sel_mx				(sel_mx[3:0]),
      .rpc_mx				(rpc_mx[31:2]),
      .xwb_mx				(xwb_mx[31:0]),
      .dwb_mx				(dwb_mx[31:0]),
      .alu_mx				(alu_mx[31:0]),
      .sfr_mx				(sfr_mx[31:0]),
      .mul_mx				(mul_mx[31:0]),
      .bsf_mx				(bsf_mx[31:0]),
      .gclk				(gclk),
      .grst				(grst),
      .dena				(dena),
      .gpha				(gpha));

endmodule // aeMB2_regs

/*
 $Log: not supported by cvs2svn $
 Revision 1.3  2008/04/26 01:09:06  sybreon
 Passes basic tests. Minor documentation changes to make it compatible with iverilog pre-processor.

 Revision 1.2  2008/04/21 12:11:38  sybreon
 Passes arithmetic tests with single thread.

 Revision 1.1  2008/04/18 00:21:52  sybreon
 Initial import.
*/