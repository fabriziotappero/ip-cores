/* $Id: aeMB2_memif.v,v 1.3 2008-04-26 17:57:43 sybreon Exp $
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
 * Memory Interface Wrapper
 * @file aeMB2_memif.v

 * A wrapper for the data/xsel bus interfaces.
 
 */

// 89@380

module aeMB2_memif (/*AUTOARG*/
   // Outputs
   xwb_wre_o, xwb_tag_o, xwb_stb_o, xwb_sel_o, xwb_mx, xwb_fb,
   xwb_dat_o, xwb_cyc_o, xwb_adr_o, sel_mx, exc_dwb, dwb_wre_o,
   dwb_tag_o, dwb_stb_o, dwb_sel_o, dwb_mx, dwb_fb, dwb_dat_o,
   dwb_cyc_o, dwb_adr_o,
   // Inputs
   xwb_dat_i, xwb_ack_i, sfr_mx, opd_of, opc_of, opb_of, opa_of,
   msr_ex, mem_ex, imm_of, grst, gpha, gclk, dwb_dat_i, dwb_ack_i,
   dena
   );   
   parameter AEMB_DWB = 32;
   parameter AEMB_XWB = 3;
   parameter AEMB_XSL = 1;
   
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [AEMB_DWB-1:2] dwb_adr_o;		// From dwbif0 of aeMB2_dwbif.v
   output		dwb_cyc_o;		// From dwbif0 of aeMB2_dwbif.v
   output [31:0]	dwb_dat_o;		// From dwbif0 of aeMB2_dwbif.v
   output		dwb_fb;			// From dwbif0 of aeMB2_dwbif.v
   output [31:0]	dwb_mx;			// From dwbif0 of aeMB2_dwbif.v
   output [3:0]		dwb_sel_o;		// From dwbif0 of aeMB2_dwbif.v
   output		dwb_stb_o;		// From dwbif0 of aeMB2_dwbif.v
   output		dwb_tag_o;		// From dwbif0 of aeMB2_dwbif.v
   output		dwb_wre_o;		// From dwbif0 of aeMB2_dwbif.v
   output [1:0]		exc_dwb;		// From dwbif0 of aeMB2_dwbif.v
   output [3:0]		sel_mx;			// From dwbif0 of aeMB2_dwbif.v
   output [AEMB_XWB-1:2] xwb_adr_o;		// From xslif0 of aeMB2_xslif.v
   output		xwb_cyc_o;		// From xslif0 of aeMB2_xslif.v
   output [31:0]	xwb_dat_o;		// From xslif0 of aeMB2_xslif.v
   output		xwb_fb;			// From xslif0 of aeMB2_xslif.v
   output [31:0]	xwb_mx;			// From xslif0 of aeMB2_xslif.v
   output [3:0]		xwb_sel_o;		// From xslif0 of aeMB2_xslif.v
   output		xwb_stb_o;		// From xslif0 of aeMB2_xslif.v
   output		xwb_tag_o;		// From xslif0 of aeMB2_xslif.v
   output		xwb_wre_o;		// From xslif0 of aeMB2_xslif.v
   // End of automatics
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		dena;			// To xslif0 of aeMB2_xslif.v, ...
   input		dwb_ack_i;		// To dwbif0 of aeMB2_dwbif.v
   input [31:0]		dwb_dat_i;		// To dwbif0 of aeMB2_dwbif.v
   input		gclk;			// To xslif0 of aeMB2_xslif.v, ...
   input		gpha;			// To xslif0 of aeMB2_xslif.v, ...
   input		grst;			// To xslif0 of aeMB2_xslif.v, ...
   input [15:0]		imm_of;			// To xslif0 of aeMB2_xslif.v, ...
   input [AEMB_DWB-1:2]	mem_ex;			// To dwbif0 of aeMB2_dwbif.v
   input [7:0]		msr_ex;			// To dwbif0 of aeMB2_dwbif.v
   input [31:0]		opa_of;			// To xslif0 of aeMB2_xslif.v, ...
   input [1:0]		opb_of;			// To dwbif0 of aeMB2_dwbif.v
   input [5:0]		opc_of;			// To xslif0 of aeMB2_xslif.v, ...
   input [31:0]		opd_of;			// To dwbif0 of aeMB2_dwbif.v
   input [7:5]		sfr_mx;			// To dwbif0 of aeMB2_dwbif.v
   input		xwb_ack_i;		// To xslif0 of aeMB2_xslif.v
   input [31:0]		xwb_dat_i;		// To xslif0 of aeMB2_xslif.v
   // End of automatics
   /*AUTOWIRE*/
   
   aeMB2_xslif
     #(/*AUTOINSTPARAM*/
       // Parameters
       .AEMB_XSL			(AEMB_XSL),
       .AEMB_XWB			(AEMB_XWB))
   xslif0
     (/*AUTOINST*/
      // Outputs
      .xwb_adr_o			(xwb_adr_o[AEMB_XWB-1:2]),
      .xwb_dat_o			(xwb_dat_o[31:0]),
      .xwb_sel_o			(xwb_sel_o[3:0]),
      .xwb_tag_o			(xwb_tag_o),
      .xwb_stb_o			(xwb_stb_o),
      .xwb_cyc_o			(xwb_cyc_o),
      .xwb_wre_o			(xwb_wre_o),
      .xwb_fb				(xwb_fb),
      .xwb_mx				(xwb_mx[31:0]),
      // Inputs
      .xwb_dat_i			(xwb_dat_i[31:0]),
      .xwb_ack_i			(xwb_ack_i),
      .imm_of				(imm_of[15:0]),
      .opc_of				(opc_of[5:0]),
      .opa_of				(opa_of[31:0]),
      .gclk				(gclk),
      .grst				(grst),
      .dena				(dena),
      .gpha				(gpha));   
   
   aeMB2_dwbif
     #(/*AUTOINSTPARAM*/
       // Parameters
       .AEMB_DWB			(AEMB_DWB))
   dwbif0
     (/*AUTOINST*/
      // Outputs
      .dwb_adr_o			(dwb_adr_o[AEMB_DWB-1:2]),
      .dwb_sel_o			(dwb_sel_o[3:0]),
      .dwb_stb_o			(dwb_stb_o),
      .dwb_cyc_o			(dwb_cyc_o),
      .dwb_tag_o			(dwb_tag_o),
      .dwb_wre_o			(dwb_wre_o),
      .dwb_dat_o			(dwb_dat_o[31:0]),
      .dwb_fb				(dwb_fb),
      .sel_mx				(sel_mx[3:0]),
      .dwb_mx				(dwb_mx[31:0]),
      .exc_dwb				(exc_dwb[1:0]),
      // Inputs
      .dwb_dat_i			(dwb_dat_i[31:0]),
      .dwb_ack_i			(dwb_ack_i),
      .imm_of				(imm_of[15:0]),
      .opd_of				(opd_of[31:0]),
      .opc_of				(opc_of[5:0]),
      .opa_of				(opa_of[1:0]),
      .opb_of				(opb_of[1:0]),
      .msr_ex				(msr_ex[7:0]),
      .mem_ex				(mem_ex[AEMB_DWB-1:2]),
      .sfr_mx				(sfr_mx[7:5]),
      .gclk				(gclk),
      .grst				(grst),
      .dena				(dena),
      .gpha				(gpha));
      
   
endmodule // aeMB2_memif

/*
 $Log: not supported by cvs2svn $
 Revision 1.2  2008/04/26 01:09:06  sybreon
 Passes basic tests. Minor documentation changes to make it compatible with iverilog pre-processor.

 Revision 1.1  2008/04/18 00:21:52  sybreon
 Initial import.
*/