/* $Id: aeMB2_pipe.v,v 1.4 2008-05-01 08:32:58 sybreon Exp $
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
 * System signal controller
 * @file aeMB2_pipe.v

 * Generates clock, reset, and enable signals. Hardware clock/reset
   managers can be instantiated here.
 
 */

module aeMB2_pipe (/*AUTOARG*/
   // Outputs
   brk_if, gpha, gclk, grst, dena, iena,
   // Inputs
   bra_ex, dwb_fb, xwb_fb, ich_fb, fet_fb, msr_ex, exc_dwb, exc_iwb,
   exc_ill, sys_clk_i, sys_int_i, sys_rst_i, sys_ena_i
   );
   parameter AEMB_HTX = 1;   

   output [1:0] brk_if; 
   input [1:0] 	bra_ex;
   input 	dwb_fb;
   input 	xwb_fb;   
   input 	ich_fb;
   input 	fet_fb;
   input [9:0] 	msr_ex;   
   
   output 	gpha,
		gclk,
		grst,
		dena,
		iena;   

   input [1:0] 	exc_dwb;
   input 	exc_iwb;
   input 	exc_ill;   
   
   input 	sys_clk_i,
		sys_int_i,
		sys_rst_i,
		sys_ena_i;
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [1:0]		brk_if;
   reg			gpha;
   // End of automatics
   reg [1:0] 		rst;   
   reg 			por;
   reg 			fet;
   reg 			hit;   
   
   // Instantiate clock/reset managers
   assign 		gclk = sys_clk_i;
   assign 		grst = !rst[1];

   // run instruction side pipeline
   assign 		iena = ich_fb &
			       xwb_fb & 
			       dwb_fb & 
			       sys_ena_i;
   // run data side pipeline
   assign 		dena = iena;

   // interrupt process - latches onto any interrupt until it is handled
   reg 			int_lat; ///< interrupt latch
			
   always @(posedge sys_clk_i)
     if (sys_rst_i) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	int_lat <= 1'h0;
	// End of automatics
     end else begin	
	int_lat <= #1 msr_ex[1] & (int_lat | sys_int_i);	
     end

   // exception process - exceptions handled immediately
   wire 		exc_lat; ///< exception latch
   assign exc_lat = exc_ill | exc_dwb[1];   

   always @(posedge gclk)
     if (grst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	brk_if <= 2'h0;
	// End of automatics
     end else if (dena) begin	
	// TODO: consider MSR[9:8]
	brk_if[1] <= #1 exc_lat; // HIGH PRIORITY - exception
	brk_if[0] <= #1 !exc_lat & !msr_ex[9] & !msr_ex[3] & int_lat; // LOW PRIORITY - interrupt (not BIP/EIP)
     end
   
   // RESET DELAY
   always @(posedge sys_clk_i)
     if (sys_rst_i) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rst <= 2'h0;
	// End of automatics
     end else begin
	rst <= #1 {rst[0], !sys_rst_i};
     end

   // PHASE TOGGLE
   always @(posedge sys_clk_i)
     if (sys_rst_i) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	gpha <= 1'h0;
	// End of automatics
     end else if (dena | grst) begin
	gpha <= #1 !gpha;
     end
   
endmodule // aeMB2_pipe

