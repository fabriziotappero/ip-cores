/*
Author: Sebastien Riou (acapola)
Creation date: 14:22:43 01/29/2011 

$LastChangedDate: 2011-01-29 13:16:17 +0100 (Sat, 29 Jan 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 11 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/test/TriWire.v $				 

This file is under the BSD licence:
Copyright (c) 2011, Sebastien Riou

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
The names of contributors may not be used to endorse or promote products derived from this software without specific prior written permission. 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
`default_nettype none
`timescale 1ns / 1ps

/*****************************************************************
* module triwire: bidirectional wire bus model with delay
*
* This module models the two ends of a bidirectional bus with
* transport (not inertial) delays in each direction. The
* bus has a width of WIDTH and the delays are as follows:
* a->b has a delay of Ta_b (in `timescale units)
* b->a has a delay of Tb_a (in `timescale units)
* The two delays will typically be the same. This model
* overcomes the problem of "echoes" at the receiving end of the
* wire by ensuring that data is only transmitted down the wire
* when the received data is Z. That means that there may be
* collisions resulting in X at the local end, but X's are not
* transmitted to the other end, which is a limitation of the
* model. Another compromise made in the interest of simulation
* speed is that the bus is not treated as individual wires, so
* a Z on any single wire may prevent data from being transmitted
* on other wires.
*
* The delays are reals so that they may vary throughout the
* course of a simulation. To change the delay, use the Verilog
* force command. Here is an example instantiation template:
*
real Ta_b=1, Tb_a=1;
always(Ta_b) force triwire.Ta_b = Ta_b;
always(Tb_a) force triwire.Tb_a = Tb_a;
triwire #(.WIDTH(WIDTH)) triwire (.a(a),.b(b));

* Kevin Neilson, Xilinx, 2007
*****************************************************************/
module triwire #(parameter WIDTH=1) (inout wire [WIDTH-1:0] a, b);
	real Ta_b=1, Tb_a=1;
	reg [WIDTH-1:0] a_dly = 'bz, b_dly = 'bz;
	always @(a) a_dly <= #(Ta_b) b_dly==={WIDTH{1'bz}} ? a : 'bz;
	always @(b) b_dly <= #(Tb_a) a_dly==={WIDTH{1'bz}} ? b : 'bz;
	assign b = a_dly, a = b_dly;
endmodule 

//delay fixed at build time here
//Sebastien Riou
module TriWirePullup #(parameter UNIDELAY=1) 
							(inout wire a, b);
	reg a_dly = 'bz, b_dly = 'bz;
	always @(a) begin
		if(b_dly!==1'b0) begin
			if(a===1'b0)
				a_dly <= #(UNIDELAY) 1'b0;
			else
				a_dly <= #(UNIDELAY) 1'bz;
		end
	end
	always @(b) begin
		if(a_dly!==1'b0) begin
			if(b===1'b0)
				b_dly <= #(UNIDELAY) 1'b0;
			else
				b_dly <= #(UNIDELAY) 1'bz;
		end
	end
	assign b = a_dly, a = b_dly;
	pullup(a);
	pullup(b);
endmodule
/*module TriWireFixed #(parameter WIDTH=1) 
							(inout wire [WIDTH-1:0] a, b);
	tran (a,b);//not supported by xilinx ISE, even just in simulation :-S
	specify
		(a*>b)=(1,1);
		(b*>a)=(1,1);
	endspecify
endmodule */
`default_nettype wire
