//////////////////////////////////////////////////////////////////////
////                                                              ////
//// mem_regf                                                     ////
////                                                              ////
//// This file is part of the SXP opencores effort.               ////
//// <http://www.opencores.org/cores/sxp/>                        ////
////                                                              ////
//// Module Description:                                          ////
//// memory based reg file module                                 ////
////                                                              ////
//// To Do:                                                       ////
////                                                              ////
//// Author(s):                                                   ////
//// - Sam Gladstone                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 Sam Gladstone and OPENCORES.ORG           ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// $Id: mem_regf.v,v 1.3 2001-11-09 00:00:04 samg Exp $ 
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.2  2001/11/08 23:53:40  samg
// integrated common memories
//
//

module mem_regf (
		clk,			// system clock
		reset_b,		// power on reset
		halt,			// system wide halt
	   	addra,			// Port A read address 
                a_en,			// Port A read enable
		addrb,			// Port B read address 
                b_en,			// Port B read enable 
		addrc,			// Port C write address 
	        dc,			// Port C write data 
		wec,			// Port C write enable 

		qra,			// Port A registered output data	
		qrb);			// Port B registered output data 	

parameter AWIDTH = 4;
parameter DSIZE  = 32;

input clk;
input reset_b;
input halt;
input [AWIDTH-1:0] addra;
input a_en;
input [AWIDTH-1:0] addrb;
input b_en;
input [AWIDTH-1:0] addrc;
input [DSIZE-1:0] dc;
input wec;

output [DSIZE-1:0] qra;
reg [DSIZE-1:0] qra;

output [DSIZE-1:0] qrb;
reg [DSIZE-1:0] qrb;


// Internal varibles and signals

wire [DSIZE-1:0] qa;				// output of reg a from memory
wire [DSIZE-1:0] qb;				// output of reg a from memory

reg mem_a_enable;			// latency adjustment register for memory
reg mem_b_enable;			// latency adjustment register for memory

reg [DSIZE-1:0] mem_bypass_a_data;		// bypass data in case of write to same address
reg [DSIZE-1:0] mem_bypass_b_data;		// bypass data in case of write to same address

reg mem_bypass_a_enable;		// adjust for latency with bypass enable a
reg mem_bypass_b_enable;		// adjust for letency with bypass enable b

wire bypass_a;				// signal that bypass of port A needs to happen
wire bypass_b;				// signal that bypass of port B needs to happen

reg [AWIDTH-1:0] r_addra;		// registered address A
reg [AWIDTH-1:0] r_addrb;		// registered address B

wire [AWIDTH-1:0] mem_input_a;			// memory input mux result for port A
wire [AWIDTH-1:0] mem_input_b;			// memory input mux result for port B


/* Stall technique for memories that can't stall on their own.

   Memories cannot be stalled and they will lose a small piece of
   data at the beginning and end of the stall cycle.

   The trick is to store the address inputs to the memory into a register
   and then mux the registered address input back into the memory input
   during the stall.  

   But, you only can about the memory stall protection if the customer of
   the memory is stalled, you don't care at all if just the source gets
   stalled.
*/

always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      begin
        r_addra <= 'b 0;
        r_addrb <= 'b 0;
      end
    else
      if (!halt)
        begin
          r_addra <= mem_input_a;
          r_addrb <= mem_input_b;
        end
  end

assign mem_input_a = (halt) ? r_addra : addra;
assign mem_input_b = (halt) ? r_addrb : addrb;

generic_dpram #(AWIDTH,DSIZE) i1_generic_dpram (
  	   	.rclk(clk),
		.rrst(!reset_b),
		.rce(1'b 1),
                .oe(1'b 1),
    		.raddr(mem_input_a),
		.do(qa),

  		.wclk(clk),
		.wrst(!reset_b),
                .wce(1'b 1),
		.we(wec),
		.waddr(addrc),
		.di(dc));
		
		 
generic_dpram #(AWIDTH,DSIZE) i2_generic_dpram (
  	   	.rclk(clk),
		.rrst(!reset_b),
		.rce(1'b 1),
                .oe(1'b 1),
    		.raddr(mem_input_b),
		.do(qb),

  		.wclk(clk),
		.wrst(!reset_b),
                .wce(1'b 1),
		.we(wec),
		.waddr(addrc),
		.di(dc));
		


assign bypass_a = ((addrc == mem_input_a) && a_en && wec) ? 1'b 1 : 1'b 0;
assign bypass_b = ((addrc == mem_input_b) && b_en && wec) ? 1'b 1 : 1'b 0;

// Allow write back to bypass memory for Port A 
always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      begin
        mem_bypass_a_data <= 'b 0;
        mem_bypass_a_enable <= 'b 0;
      end
    else
      if (!halt)
        begin
          mem_bypass_a_data <= dc;		// Simulate memory latency
          mem_bypass_a_enable <= bypass_a;	// Store bypass enable
        end
  end      

// Allow write back to bypass memory for Port B 
always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      begin
        mem_bypass_b_data <= 'b 0;
        mem_bypass_b_enable <= 'b 0;
      end
    else
      if (!halt) 
        begin
          mem_bypass_b_data <= dc;		// Simulate memory latency
          mem_bypass_b_enable <= bypass_b;	// Store bypass enable
        end
  end      

// Keep the enable signals properly alligned for A reg
always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      mem_a_enable <= 1'b 0;
    else
      if (!halt)
        mem_a_enable <= a_en;
  end
      
// Keep the enable signals properly alligned for B reg
always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      mem_b_enable <= 1'b 0;
    else
      if (!halt)
        mem_b_enable <= b_en;
  end


// ----------------  Output Section ---------------

// chooses proper data from either bypass or memory for register A
always @(mem_bypass_a_enable or mem_bypass_a_data or mem_a_enable or qa)
  begin
    if (mem_bypass_a_enable)
      qra = mem_bypass_a_data;
    else
      if (mem_a_enable)
        qra = qa;
      else
        qra = {DSIZE{1'b x}};
  end


// chooses proper data from either bypass or memory for register B
always @(mem_bypass_b_enable or mem_bypass_b_data or mem_b_enable or qb)
  begin
    if (mem_bypass_b_enable)
      qrb = mem_bypass_b_data;
    else
      if (mem_b_enable)
        qrb = qb;
      else
        qrb = {DSIZE{1'b x}};
  end

endmodule
