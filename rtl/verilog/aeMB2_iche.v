/* $Id: aeMB2_iche.v,v 1.5 2008-04-28 00:54:31 sybreon Exp $
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
 * Instruction Cache Block
 * @file aeMB2_iche.v

 * This is a non-optional instruction cache for single cycle
   operations. The maximum line width is 16 words (512 bits)
 
 * Single port synchronous RAM is used as the main cache DATA
   block. A single port asynchronous RAM is used as the TAG block.

 * The sizes need to be selected carefully to minimise resource
   wastage. Details are provided in the documentation.
 
 */

// 63@158 - X3S

module aeMB2_iche (/*AUTOARG*/
   // Outputs
   ich_dat, ich_hit, ich_fb,
   // Inputs
   ich_adr, iwb_dat_i, iwb_ack_i, gclk, grst, iena, gpha
   );
   parameter AEMB_IWB = 32;   
   parameter AEMB_ICH = 11;
   parameter AEMB_IDX = 6;   
   parameter AEMB_HTX = 1;   
   
   // Cache
   input [AEMB_IWB-1:2] ich_adr;
   output [31:0] 	ich_dat;
   output 		ich_hit; ///< cache hit
   output 		ich_fb; ///< cache hit
   
   // Wishbone
   input [31:0] 	iwb_dat_i;
   input 		iwb_ack_i;
   
   // SYS signals
   input 		gclk,
			grst,
			iena,
			gpha;      

   // SOME MATH
   localparam 		SIZ = AEMB_ICH-2; // 2^SIZ entries
   localparam 		BLK = AEMB_ICH-AEMB_IDX; // 2^BLK blocks 
   localparam 		LNE = AEMB_IDX-2; // 2^LNE lines per block
       
   localparam 		TAG = AEMB_IWB-AEMB_ICH; // TAG length
   localparam 		VAL = (1<<LNE); // VAL values (max 16)
   
   /*AUTOWIRE*/
   /*AUTOREG*/
   
   assign 		ich_fb = ich_hit;
   
   // 1-of-X decoder
   // FIXME: Make decoder dynamic.
   // TODO: Factorise into primitive
   reg [VAL:1] 		rDEC; 		
   always @(/*AUTOSENSE*/ich_adr)
     case (ich_adr[AEMB_IDX-1:2])
       4'h0: rDEC <= #1 16'h0001;
       4'h1: rDEC <= #1 16'h0002;
       4'h2: rDEC <= #1 16'h0004;
       4'h3: rDEC <= #1 16'h0008;
       4'h4: rDEC <= #1 16'h0010;
       4'h5: rDEC <= #1 16'h0020;
       4'h6: rDEC <= #1 16'h0040;
       4'h7: rDEC <= #1 16'h0080;
       4'h8: rDEC <= #1 16'h0100;
       4'h9: rDEC <= #1 16'h0200;
       4'hA: rDEC <= #1 16'h0400;
       4'hB: rDEC <= #1 16'h0800;
       4'hC: rDEC <= #1 16'h1000;
       4'hD: rDEC <= #1 16'h2000;
       4'hE: rDEC <= #1 16'h4000;
       4'hF: rDEC <= #1 16'h8000;      
     endcase // case (ich_adr[AEMB_IDX-1:2])
   
   wire [VAL:1] 	wDEC = rDEC[VAL:1]; // resize decoder   

   // explode the address bits
   wire [VAL:1] 	oVAL, iVAL;   
   wire [SIZ:1] 	aLNE = ich_adr[AEMB_ICH-1:2]; // line address
   wire [BLK:1] 	aTAG = ich_adr[AEMB_ICH-1:AEMB_IDX]; // block address   
   wire [TAG:1] 	iTAG = ich_adr[AEMB_IWB-1:AEMB_ICH]; // current TAG value
   wire [TAG:1] 	oTAG; 		

   // HIT CHECKS
   wire 		hTAG = ((iTAG ^ oTAG) == {(TAG){1'b0}}); // 100.0
			//~|(iTAG ^ oTAG); // 98
			//(iTAG == oTAG); // 85
   wire 		hVAL = //|(oVAL & wDEC);   
			((oVAL & wDEC) != {(VAL){1'b0}});
   
   assign 		ich_hit = hTAG & hVAL;
   assign 		iVAL = (hTAG) ? // BLOCK/LINE fill check
			       oVAL | wDEC : // LINE fill
			       wDEC; // BLOCK replace
   
   /* 
    aeMB2_tpsram AUTO_TEMPLATE (
    .AW(SIZ), 
    .DW(6'd32),
    
    .dat_o(),
    .dat_i(iwb_dat_i[31:0]),
    .adr_i(aLNE[SIZ:1]),
    .rst_i(),
    .ena_i(iwb_ack_i),
    .clk_i(gclk),
    .wre_i(iwb_ack_i),
    
    .xdat_o(ich_dat[31:0]),
    .xdat_i(),    
    .xadr_i(aLNE[SIZ:1]),
    .xrst_i(grst),
    .xena_i(iena),
    .xclk_i(gclk),
    .xwre_i(),            
    ) 
    
    aeMB2_sparam AUTO_TEMPLATE (
    .AW(BLK), 
    .DW(VAL+TAG),
    
    .dat_o({oVAL, oTAG}),
    .dat_i({iVAL, iTAG}),
    .adr_i(aTAG[BLK:1]),
    .ena_i(iwb_ack_i),
    .clk_i(gclk),
    .wre_i(iwb_ack_i),
    )    
    */

   // CACHE TAG BLOCK
   aeMB2_sparam
     #(/*AUTOINSTPARAM*/
       // Parameters
       .AW				(BLK),			 // Templated
       .DW				(VAL+TAG))		 // Templated
   tag0
     (/*AUTOINST*/
      // Outputs
      .dat_o				({oVAL, oTAG}),		 // Templated
      // Inputs
      .adr_i				(aTAG[BLK:1]),		 // Templated
      .dat_i				({iVAL, iTAG}),		 // Templated
      .wre_i				(iwb_ack_i),		 // Templated
      .clk_i				(gclk),			 // Templated
      .ena_i				(iwb_ack_i));		 // Templated

   // CACHE DATA BLOCK   
   // Writes on successful IWB bus transfers.
   // Reads on pipeline enable.
   aeMB2_tpsram
     #(/*AUTOINSTPARAM*/
       // Parameters
       .AW				(SIZ),			 // Templated
       .DW				(6'd32))		 // Templated
   data0
     (/*AUTOINST*/
      // Outputs
      .dat_o				(),			 // Templated
      .xdat_o				(ich_dat[31:0]),	 // Templated
      // Inputs
      .adr_i				(aLNE[SIZ:1]),		 // Templated
      .dat_i				(iwb_dat_i[31:0]),	 // Templated
      .wre_i				(iwb_ack_i),		 // Templated
      .ena_i				(iwb_ack_i),		 // Templated
      .rst_i				(),			 // Templated
      .clk_i				(gclk),			 // Templated
      .xadr_i				(aLNE[SIZ:1]),		 // Templated
      .xdat_i				(),			 // Templated
      .xwre_i				(),			 // Templated
      .xena_i				(iena),			 // Templated
      .xrst_i				(grst),			 // Templated
      .xclk_i				(gclk));			 // Templated
   
endmodule // aeMB2_iche

/*
 $Log: not supported by cvs2svn $
 Revision 1.4  2008/04/26 17:57:43  sybreon
 Minor performance improvements.

 Revision 1.3  2008/04/26 01:09:06  sybreon
 Passes basic tests. Minor documentation changes to make it compatible with iverilog pre-processor.

 Revision 1.2  2008/04/20 16:34:32  sybreon
 Basic version with some features left out.

 Revision 1.1  2008/04/18 00:21:52  sybreon
 Initial import.
*/