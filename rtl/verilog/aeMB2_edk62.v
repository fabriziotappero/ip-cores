/* $Id: aeMB2_edk62.v,v 1.8 2008-05-01 08:32:58 sybreon Exp $
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
 * Top Level Core
 * @file aeMB2_edk62.v

 * This implements an EDK 6.2 software compatible core. It implements
   all the software instructions except for division and cache writes.
 
 */

module aeMB2_edk62 (/*AUTOARG*/
   // Outputs
   xwb_wre_o, xwb_tag_o, xwb_stb_o, xwb_sel_o, xwb_dat_o, xwb_cyc_o,
   xwb_adr_o, iwb_wre_o, iwb_tag_o, iwb_stb_o, iwb_sel_o, iwb_cyc_o,
   iwb_adr_o, dwb_wre_o, dwb_tag_o, dwb_stb_o, dwb_sel_o, dwb_dat_o,
   dwb_cyc_o, dwb_adr_o,
   // Inputs
   xwb_dat_i, xwb_ack_i, sys_rst_i, sys_int_i, sys_ena_i, sys_clk_i,
   iwb_dat_i, iwb_ack_i, dwb_dat_i, dwb_ack_i
   );
   // BUS WIDTHS
   parameter AEMB_IWB = 32; ///< INST bus width
   parameter AEMB_DWB = 32; ///< DATA bus width
   parameter AEMB_XWB = 7; ///< XCEL bus width

   // CACHE PARAMETERS
   parameter AEMB_ICH = 11; ///< instruction cache size
   parameter AEMB_IDX = 6; ///< cache index size

   // OPTIONAL HARDWARE
   parameter AEMB_BSF = 1; ///< optional barrel shift
   parameter AEMB_MUL = 1; ///< optional multiplier
   parameter AEMB_DIV = 0; ///< optional divider (future)
   parameter AEMB_FPU = 0; ///< optional floating point unit (future)

   // DEPRECATED PARAMETERS
   localparam AEMB_XSL = 1; ///< implement XSL bus
   localparam AEMB_HTX = 1; ///< hardware thread extension
      
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [AEMB_DWB-1:2] dwb_adr_o;		// From memif0 of aeMB2_memif.v
   output		dwb_cyc_o;		// From memif0 of aeMB2_memif.v
   output [31:0]	dwb_dat_o;		// From memif0 of aeMB2_memif.v
   output [3:0]		dwb_sel_o;		// From memif0 of aeMB2_memif.v
   output		dwb_stb_o;		// From memif0 of aeMB2_memif.v
   output		dwb_tag_o;		// From memif0 of aeMB2_memif.v
   output		dwb_wre_o;		// From memif0 of aeMB2_memif.v
   output [AEMB_IWB-1:2] iwb_adr_o;		// From iwbif0 of aeMB2_iwbif.v
   output		iwb_cyc_o;		// From iwbif0 of aeMB2_iwbif.v
   output [3:0]		iwb_sel_o;		// From iwbif0 of aeMB2_iwbif.v
   output		iwb_stb_o;		// From iwbif0 of aeMB2_iwbif.v
   output		iwb_tag_o;		// From iwbif0 of aeMB2_iwbif.v
   output		iwb_wre_o;		// From iwbif0 of aeMB2_iwbif.v
   output [AEMB_XWB-1:2] xwb_adr_o;		// From memif0 of aeMB2_memif.v
   output		xwb_cyc_o;		// From memif0 of aeMB2_memif.v
   output [31:0]	xwb_dat_o;		// From memif0 of aeMB2_memif.v
   output [3:0]		xwb_sel_o;		// From memif0 of aeMB2_memif.v
   output		xwb_stb_o;		// From memif0 of aeMB2_memif.v
   output		xwb_tag_o;		// From memif0 of aeMB2_memif.v
   output		xwb_wre_o;		// From memif0 of aeMB2_memif.v
   // End of automatics
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		dwb_ack_i;		// To memif0 of aeMB2_memif.v
   input [31:0]		dwb_dat_i;		// To memif0 of aeMB2_memif.v
   input		iwb_ack_i;		// To iche0 of aeMB2_iche.v, ...
   input [31:0]		iwb_dat_i;		// To iche0 of aeMB2_iche.v, ...
   input		sys_clk_i;		// To pip0 of aeMB2_pipe.v
   input		sys_ena_i;		// To pip0 of aeMB2_pipe.v
   input		sys_int_i;		// To pip0 of aeMB2_pipe.v
   input		sys_rst_i;		// To pip0 of aeMB2_pipe.v
   input		xwb_ack_i;		// To memif0 of aeMB2_memif.v
   input [31:0]		xwb_dat_i;		// To memif0 of aeMB2_memif.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [31:0]		alu_ex;			// From exec0 of aeMB2_exec.v
   wire [31:0]		alu_mx;			// From exec0 of aeMB2_exec.v
   wire [31:2]		bpc_ex;			// From exec0 of aeMB2_exec.v
   wire [1:0]		bra_ex;			// From brcc0 of aeMB2_brcc.v
   wire [1:0]		brk_if;			// From pip0 of aeMB2_pipe.v
   wire [31:0]		bsf_mx;			// From exec0 of aeMB2_exec.v
   wire			dena;			// From pip0 of aeMB2_pipe.v
   wire			dwb_fb;			// From memif0 of aeMB2_memif.v
   wire [31:0]		dwb_mx;			// From memif0 of aeMB2_memif.v
   wire			fet_fb;			// From iwbif0 of aeMB2_iwbif.v
   wire			gclk;			// From pip0 of aeMB2_pipe.v
   wire			gpha;			// From pip0 of aeMB2_pipe.v
   wire			grst;			// From pip0 of aeMB2_pipe.v
   wire			hzd_bpc;		// From ctrl0 of aeMB2_ctrl.v
   wire			hzd_fwd;		// From ctrl0 of aeMB2_ctrl.v
   wire [AEMB_IWB-1:2]	ich_adr;		// From iwbif0 of aeMB2_iwbif.v
   wire [31:0]		ich_dat;		// From iche0 of aeMB2_iche.v
   wire			ich_fb;			// From iche0 of aeMB2_iche.v
   wire			ich_hit;		// From iche0 of aeMB2_iche.v
   wire			iena;			// From pip0 of aeMB2_pipe.v
   wire [15:0]		imm_of;			// From ctrl0 of aeMB2_ctrl.v
   wire [31:2]		mem_ex;			// From exec0 of aeMB2_exec.v
   wire [7:0]		msr_ex;			// From exec0 of aeMB2_exec.v
   wire [31:0]		mul_mx;			// From exec0 of aeMB2_exec.v
   wire [2:0]		mux_ex;			// From ctrl0 of aeMB2_ctrl.v
   wire [2:0]		mux_of;			// From ctrl0 of aeMB2_ctrl.v
   wire [31:0]		opa_if;			// From regs0 of aeMB2_regs.v
   wire [31:0]		opa_of;			// From ctrl0 of aeMB2_ctrl.v
   wire [31:0]		opb_if;			// From regs0 of aeMB2_regs.v
   wire [31:0]		opb_of;			// From ctrl0 of aeMB2_ctrl.v
   wire [5:0]		opc_of;			// From ctrl0 of aeMB2_ctrl.v
   wire [31:0]		opd_if;			// From regs0 of aeMB2_regs.v
   wire [31:0]		opd_of;			// From ctrl0 of aeMB2_ctrl.v
   wire [4:0]		ra_of;			// From ctrl0 of aeMB2_ctrl.v
   wire [4:0]		rd_ex;			// From ctrl0 of aeMB2_ctrl.v
   wire [4:0]		rd_of;			// From ctrl0 of aeMB2_ctrl.v
   wire [31:2]		rpc_if;			// From iwbif0 of aeMB2_iwbif.v
   wire [31:2]		rpc_mx;			// From iwbif0 of aeMB2_iwbif.v
   wire [3:0]		sel_mx;			// From memif0 of aeMB2_memif.v
   wire [31:0]		sfr_mx;			// From exec0 of aeMB2_exec.v
   wire			xwb_fb;			// From memif0 of aeMB2_memif.v
   wire [31:0]		xwb_mx;			// From memif0 of aeMB2_memif.v
   // End of automatics
   /*AUTOREG*/
   
   aeMB2_pipe
     pip0
       (/*AUTOINST*/
	// Outputs
	.brk_if				(brk_if[1:0]),
	.gpha				(gpha),
	.gclk				(gclk),
	.grst				(grst),
	.dena				(dena),
	.iena				(iena),
	// Inputs
	.bra_ex				(bra_ex[1:0]),
	.dwb_fb				(dwb_fb),
	.xwb_fb				(xwb_fb),
	.ich_fb				(ich_fb),
	.fet_fb				(fet_fb),
	.msr_ex				(msr_ex[3:0]),
	.sys_clk_i			(sys_clk_i),
	.sys_int_i			(sys_int_i),
	.sys_rst_i			(sys_rst_i),
	.sys_ena_i			(sys_ena_i));   
   
   aeMB2_iche
     #(/*AUTOINSTPARAM*/
       // Parameters
       .AEMB_IWB			(AEMB_IWB),
       .AEMB_ICH			(AEMB_ICH),
       .AEMB_IDX			(AEMB_IDX),
       .AEMB_HTX			(AEMB_HTX))
   iche0
     (/*AUTOINST*/
      // Outputs
      .ich_dat				(ich_dat[31:0]),
      .ich_hit				(ich_hit),
      .ich_fb				(ich_fb),
      // Inputs
      .ich_adr				(ich_adr[AEMB_IWB-1:2]),
      .iwb_dat_i			(iwb_dat_i[31:0]),
      .iwb_ack_i			(iwb_ack_i),
      .gclk				(gclk),
      .grst				(grst),
      .iena				(iena),
      .gpha				(gpha));   
   
   aeMB2_iwbif
     #(/*AUTOINSTPARAM*/
       // Parameters
       .AEMB_IWB			(AEMB_IWB),
       .AEMB_HTX			(AEMB_HTX))
   iwbif0
     (/*AUTOINST*/
      // Outputs
      .iwb_adr_o			(iwb_adr_o[AEMB_IWB-1:2]),
      .iwb_stb_o			(iwb_stb_o),
      .iwb_sel_o			(iwb_sel_o[3:0]),
      .iwb_wre_o			(iwb_wre_o),
      .iwb_cyc_o			(iwb_cyc_o),
      .iwb_tag_o			(iwb_tag_o),
      .ich_adr				(ich_adr[AEMB_IWB-1:2]),
      .fet_fb				(fet_fb),
      .rpc_if				(rpc_if[31:2]),
      .rpc_mx				(rpc_mx[31:2]),
      // Inputs
      .iwb_ack_i			(iwb_ack_i),
      .iwb_dat_i			(iwb_dat_i[31:0]),
      .ich_hit				(ich_hit),
      .msr_ex				(msr_ex[7:5]),
      .hzd_bpc				(hzd_bpc),
      .hzd_fwd				(hzd_fwd),
      .bra_ex				(bra_ex[1:0]),
      .bpc_ex				(bpc_ex[31:2]),
      .gclk				(gclk),
      .grst				(grst),
      .dena				(dena),
      .iena				(iena),
      .gpha				(gpha));

   aeMB2_ctrl
     #(/*AUTOINSTPARAM*/
       // Parameters
       .AEMB_HTX			(AEMB_HTX))
   ctrl0
     (/*AUTOINST*/
      // Outputs
      .opa_of				(opa_of[31:0]),
      .opb_of				(opb_of[31:0]),
      .opd_of				(opd_of[31:0]),
      .opc_of				(opc_of[5:0]),
      .ra_of				(ra_of[4:0]),
      .rd_of				(rd_of[4:0]),
      .imm_of				(imm_of[15:0]),
      .rd_ex				(rd_ex[4:0]),
      .mux_of				(mux_of[2:0]),
      .mux_ex				(mux_ex[2:0]),
      .hzd_bpc				(hzd_bpc),
      .hzd_fwd				(hzd_fwd),
      // Inputs
      .opa_if				(opa_if[31:0]),
      .opb_if				(opb_if[31:0]),
      .opd_if				(opd_if[31:0]),
      .brk_if				(brk_if[1:0]),
      .bra_ex				(bra_ex[1:0]),
      .rpc_if				(rpc_if[31:2]),
      .alu_ex				(alu_ex[31:0]),
      .ich_dat				(ich_dat[31:0]),
      .gclk				(gclk),
      .grst				(grst),
      .dena				(dena),
      .iena				(iena),
      .gpha				(gpha));

   aeMB2_brcc
     #(/*AUTOINSTPARAM*/
       // Parameters
       .AEMB_HTX			(AEMB_HTX))
   brcc0
     (/*AUTOINST*/
      // Outputs
      .bra_ex				(bra_ex[1:0]),
      // Inputs
      .opd_of				(opd_of[31:0]),
      .ra_of				(ra_of[4:0]),
      .rd_of				(rd_of[4:0]),
      .opc_of				(opc_of[5:0]),
      .gclk				(gclk),
      .grst				(grst),
      .dena				(dena),
      .iena				(iena),
      .gpha				(gpha));   

   aeMB2_exec
     #(/*AUTOINSTPARAM*/
       // Parameters
       .AEMB_IWB			(AEMB_IWB),
       .AEMB_DWB			(AEMB_DWB),
       .AEMB_MUL			(AEMB_MUL),
       .AEMB_BSF			(AEMB_BSF),
       .AEMB_HTX			(AEMB_HTX))
   exec0
     (/*AUTOINST*/
      // Outputs
      .alu_ex				(alu_ex[31:0]),
      .alu_mx				(alu_mx[31:0]),
      .bpc_ex				(bpc_ex[31:2]),
      .bsf_mx				(bsf_mx[31:0]),
      .mem_ex				(mem_ex[31:2]),
      .msr_ex				(msr_ex[7:0]),
      .mul_mx				(mul_mx[31:0]),
      .sfr_mx				(sfr_mx[31:0]),
      // Inputs
      .dena				(dena),
      .gclk				(gclk),
      .gpha				(gpha),
      .grst				(grst),
      .imm_of				(imm_of[15:0]),
      .opa_of				(opa_of[31:0]),
      .opb_of				(opb_of[31:0]),
      .opc_of				(opc_of[5:0]),
      .opd_of				(opd_of[31:0]),
      .ra_of				(ra_of[4:0]),
      .rd_of				(rd_of[4:0]));   
   
   aeMB2_memif
     #(/*AUTOINSTPARAM*/
       // Parameters
       .AEMB_DWB			(AEMB_DWB),
       .AEMB_XWB			(AEMB_XWB),
       .AEMB_XSL			(AEMB_XSL))
   memif0
     (/*AUTOINST*/
      // Outputs
      .dwb_adr_o			(dwb_adr_o[AEMB_DWB-1:2]),
      .dwb_cyc_o			(dwb_cyc_o),
      .dwb_dat_o			(dwb_dat_o[31:0]),
      .dwb_fb				(dwb_fb),
      .dwb_mx				(dwb_mx[31:0]),
      .dwb_sel_o			(dwb_sel_o[3:0]),
      .dwb_stb_o			(dwb_stb_o),
      .dwb_tag_o			(dwb_tag_o),
      .dwb_wre_o			(dwb_wre_o),
      .sel_mx				(sel_mx[3:0]),
      .xwb_adr_o			(xwb_adr_o[AEMB_XWB-1:2]),
      .xwb_cyc_o			(xwb_cyc_o),
      .xwb_dat_o			(xwb_dat_o[31:0]),
      .xwb_fb				(xwb_fb),
      .xwb_mx				(xwb_mx[31:0]),
      .xwb_sel_o			(xwb_sel_o[3:0]),
      .xwb_stb_o			(xwb_stb_o),
      .xwb_tag_o			(xwb_tag_o),
      .xwb_wre_o			(xwb_wre_o),
      // Inputs
      .dena				(dena),
      .dwb_ack_i			(dwb_ack_i),
      .dwb_dat_i			(dwb_dat_i[31:0]),
      .gclk				(gclk),
      .gpha				(gpha),
      .grst				(grst),
      .imm_of				(imm_of[15:0]),
      .mem_ex				(mem_ex[AEMB_DWB-1:2]),
      .msr_ex				(msr_ex[7:0]),
      .opa_of				(opa_of[31:0]),
      .opb_of				(opb_of[1:0]),
      .opc_of				(opc_of[5:0]),
      .opd_of				(opd_of[31:0]),
      .sfr_mx				(sfr_mx[7:5]),
      .xwb_ack_i			(xwb_ack_i),
      .xwb_dat_i			(xwb_dat_i[31:0]));        

   aeMB2_regs
     #(/*AUTOINSTPARAM*/
       // Parameters
       .AEMB_HTX			(AEMB_HTX))
   regs0
     (/*AUTOINST*/
      // Outputs
      .opa_if				(opa_if[31:0]),
      .opb_if				(opb_if[31:0]),
      .opd_if				(opd_if[31:0]),
      // Inputs
      .alu_mx				(alu_mx[31:0]),
      .bsf_mx				(bsf_mx[31:0]),
      .dena				(dena),
      .dwb_mx				(dwb_mx[31:0]),
      .gclk				(gclk),
      .gpha				(gpha),
      .grst				(grst),
      .ich_dat				(ich_dat[31:0]),
      .mul_mx				(mul_mx[31:0]),
      .mux_ex				(mux_ex[2:0]),
      .mux_of				(mux_of[2:0]),
      .rd_ex				(rd_ex[4:0]),
      .rd_of				(rd_of[4:0]),
      .rpc_mx				(rpc_mx[31:2]),
      .sel_mx				(sel_mx[3:0]),
      .sfr_mx				(sfr_mx[31:0]),
      .xwb_mx				(xwb_mx[31:0]));   
   
endmodule // aeMB2_edk62

/*
 $Log: not supported by cvs2svn $
 Revision 1.7  2008/04/27 19:52:46  sybreon
 added iwb_tag_o signal tied to MSR_ICE.

 Revision 1.6  2008/04/26 17:57:43  sybreon
 Minor performance improvements.

 Revision 1.5  2008/04/26 01:11:30  sybreon
 Fixed minor typos.

 Revision 1.4  2008/04/26 01:09:05  sybreon
 Passes basic tests. Minor documentation changes to make it compatible with iverilog pre-processor.

 Revision 1.3  2008/04/21 12:11:38  sybreon
 Passes arithmetic tests with single thread.

 Revision 1.2  2008/04/20 16:34:32  sybreon
 Basic version with some features left out.

 Revision 1.1  2008/04/18 00:21:52  sybreon
 Initial import.
*/