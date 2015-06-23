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

module fasm_stack (/*AUTOARG*/
   // Outputs
   dat_o, rok_o, wok_o,
   // Inputs
   dat_i, rde_i, wre_i, rst_i, ena_i, clk_i
   );

   parameter AW = 4;
   parameter DW = 32;

   output [DW-1:0] dat_o;
   output 	   rok_o,
		   wok_o;

   input [DW-1:0]  dat_i;
   input 	   rde_i,
		   wre_i;

   input 	   rst_i,
		   ena_i,
		   clk_i;

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			rok_o;
   reg			wok_o;
   // End of automatics

   reg [AW:1] 		rRADR;
   wire [AW:1] 		rWADR = (rde_i) ? rRADR - 1 : rRADR + 1;   

   always @(posedge clk_i)
     if (rst_i) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rRADR <= {(1+(AW)-(1)){1'b0}};
	// End of automatics
     end else if (ena_i) begin
	rRADR <= #1 rWADR;	
     end
   
   /*
    fasm_tparam AUTO_TEMPLATE (
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
    )
    */
   
   fasm_tparam
     #(/*AUTOINSTPARAM*/
       // Parameters
       .AW				(AW),			 // Templated
       .DW				(DW))			 // Templated
   stack0
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
   
endmodule // fasm_stack

/*
 $Log$
 */