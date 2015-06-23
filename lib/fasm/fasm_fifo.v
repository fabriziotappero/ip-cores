/* $Id: fasm_fifo.v,v 1.2 2008/06/05 21:07:13 sybreon Exp $
**
** FASM MEMORY LIBRARY
** Copyright (C) 2004-2008 Shawn Tan <shawn.tan@aeste.net>
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
 * SMALL INTERNAL BUFFER (FIFO)
 * Synthesis proven on:
 * - Xilinx ISE
 * - Altera Quartus (>=8.0) 
 */

module fasm_fifo (/*AUTOARG*/
   // Outputs
   dat_o, rok_o, wok_o,
   // Inputs
   dat_i, rde_i, wre_i, clr_i, rst_i, ena_i, clk_i
   );
   parameter AW = 4; // fifo depth
   parameter DW = 32; // fifo width

   output [DW-1:0] dat_o;
   output 	   rok_o, // empty signal
		   wok_o; // full signal
   
   input [DW-1:0]  dat_i;
   input 	   rde_i,
 		   wre_i;   
   
   input 	   clr_i,
		   rst_i,
		   ena_i,
		   clk_i; // global clock
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			rok_o;
   reg			wok_o;
   // End of automatics
   
   reg [AW:1] 	rRADR, 
			rWADR;
   
   wire 		wWRE = wre_i & wok_o;
   wire 		wRDE = rde_i & rok_o;   

   //wire [AW:1] 		wRNXT = {~^rRADR[2:1],rRADR[AW:2]};
   //wire [AW:1] 		wWNXT = {~^rWADR[2:1],rWADR[AW:2]};
   wire [AW:1] 		wRNXT = rRADR + 1;
   wire [AW:1] 		wWNXT = rWADR + 1;   
   
   always @(posedge clk_i)
     if (rst_i | clr_i) begin
	rok_o <= 1'b0;
	wok_o <= 1'b1;	
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rRADR <= {(1+(AW)-(1)){1'b0}};
	rWADR <= {(1+(AW)-(1)){1'b0}};
	// End of automatics
     end else if (ena_i) begin

	if (wWRE) rWADR <= #1 wWNXT;	
	if (wRDE) rRADR <= #1 wRNXT;	

	if (wWRE ^ wRDE) begin
	   if (wWRE) begin
	      wok_o <= #1 (wWNXT != rRADR); // FIXME: use XOR	   
	      rok_o <= #1 1'b1;
	   end else begin
	      wok_o <= #1 1'b1;
	      rok_o <= #1 (wRNXT != rWADR);	      
	   end
	end
	
     end // if (ena_i)
   
   /* fasm_tparam AUTO_TEMPLATE 
    (
    .AW(AW),
    .DW(DW),

    .clk_i(clk_i),
    .rst_i(),
    .stb_i(),
    .wre_i(),    
    .dat_i(),
    .adr_i(rRADR),
    .dat_o(dat_o),    
    
    .xclk_i(clk_i),
    .xrst_i(),
    .xstb_i(),
    .xwre_i(wWRE),
    .xadr_i(rWADR),
    .xdat_i(dat_i),
    .xdat_o(),
    ); */
   
   fasm_tparam
     #(/*AUTOINSTPARAM*/
       // Parameters
       .AW				(AW),			 // Templated
       .DW				(DW))			 // Templated
   fiforam0
     (/*AUTOINST*/
      // Outputs
      .dat_o				(dat_o),		 // Templated
      .xdat_o				(),			 // Templated
      // Inputs
      .dat_i				(),			 // Templated
      .adr_i				(rRADR),		 // Templated
      .wre_i				(),			 // Templated
      .stb_i				(),			 // Templated
      .rst_i				(),			 // Templated
      .clk_i				(clk_i),		 // Templated
      .xdat_i				(dat_i),		 // Templated
      .xadr_i				(rWADR),		 // Templated
      .xwre_i				(wWRE),			 // Templated
      .xstb_i				(),			 // Templated
      .xrst_i				(),			 // Templated
      .xclk_i				(clk_i));		 // Templated

   // ### SIMULATION ONLY ###
   // synopsys translate_on
   initial begin
      // This depends on target technology. All regular FPGAs have a
      // 16x1 dual port asynchronous RAM block.
      if (AW > 4) $display("Warning: FIFO too large!");
      if (AW < 2) $display("Warning: FIFO too small!");      
   end
   // synopsys translate_off
   
endmodule // fasm_fifo
