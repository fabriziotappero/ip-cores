/* $Id: fasm_sparam.v,v 1.2 2008/06/05 20:55:15 sybreon Exp $
**
** VIRTUAL PERIPHERAL INPUT/OUTPUT LIBRARY
** Copyright (C) 2004-2009 Shawn Tan <shawn.tan@aeste.net>
** All rights reserved.
** 
** LITE is free software: you can redistribute it and/or modify it
** under the terms of the GNU Lesser General Public License as
** published by the Free Software Foundation, either version 3 of the
** License, or (at your option) any later version.
**
** LITE is distributed in the hope that it will be useful, but WITHOUT
** ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
** or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
** Public License for more details.
**
** You should have received a copy of the GNU Lesser General Public
** License along with FASM. If not, see <http:**www.gnu.org/licenses/>.
*/
/*
 * GENERAL PURPOSE I/O
 */

module vpio_gpio (/*AUTOARG*/
   // Outputs
   wb_dat_o, wb_ack_o,
   // Inouts
   gpio_io,
   // Inputs
   wb_dat_i, wb_adr_i, wb_stb_i, wb_sel_i, wb_wre_i, wb_clk_i,
   wb_rst_i
   );
   parameter IO = 8;

   // WISHBONE SLAVE
   output [IO-1:0] wb_dat_o;
   output 	   wb_ack_o;
   
   input [IO-1:0]  wb_dat_i;
   input 	   wb_adr_i;
   input 	   wb_stb_i,
		   wb_sel_i,
		   wb_wre_i,
		   wb_clk_i,
		   wb_rst_i;   

   // GPIO I/F
   inout [IO-1:0]  gpio_io;

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			wb_ack_o;
   reg [IO-1:0]		wb_dat_o;
   // End of automatics
   
   reg [IO-1:0] 	rTRIS, // Direction - 1:output, 0:input
			rPORT;
   
   wire 		wb_stb = wb_stb_i & wb_sel_i;
   wire 		wb_wre = wb_stb_i & wb_sel_i & wb_wre_i;   
   
   // WISHBONE SIDE
   always @(posedge wb_clk_i)
     if (wb_rst_i) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rPORT <= {(1+(IO-1)){1'b0}};
	rTRIS <= {(1+(IO-1)){1'b0}};
	// End of automatics
     end else if (wb_wre) begin
	if (wb_adr_i) rPORT <= #1 wb_dat_i;
	if (!wb_adr_i) rTRIS <= #1 wb_dat_i;	
     end

   always @(posedge wb_clk_i)
     if (wb_rst_i) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	wb_ack_o <= 1'h0;
	wb_dat_o <= {(1+(IO-1)){1'b0}};
	// End of automatics
     end else begin
	wb_ack_o <= #1 !wb_ack_o & wb_stb;
	
	case (wb_adr_i) // WAR
	  1'b0: wb_dat_o <= #1 rTRIS;
	  1'b1: wb_dat_o <= #1 rPORT;
	endcase // case (wb_adr_i)
     end // else: !if(wb_rst_i)
   
   // GPIO SIDE
   integer 	   i;
   reg [IO-1:0]    rGPIO;   // async latch
   assign gpio_io = rGPIO;
   
   always @(/*AUTOSENSE*/rPORT or rTRIS)
     for (i=0;i<IO;i=i+1)
       rGPIO[i] <= (rTRIS[i]) ? rPORT[i] : 1'bZ;
      
endmodule // vpio_gpio
