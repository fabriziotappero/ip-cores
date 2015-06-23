`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////////
// 
// 4004 Counter sub-module
// 
// This file is part of the MCS-4 project hosted at OpenCores:
//      http://www.opencores.org/cores/mcs-4/
// 
// Copyright © 2012 by Reece Pollack <rrpollack@opencores.org>
// 
// These materials are provided under the Creative Commons
// "Attribution-NonCommercial-ShareAlike" Public License. They
// are NOT "public domain" and are protected by copyright.
// 
// This work based on materials provided by Intel Corporation and
// others under the same license. See the file doc/License for
// details of this license.
//
////////////////////////////////////////////////////////////////////////

module counter(
	input  wire	sysclk,
	input  wire	step_a,
	input  wire	step_b,
	output reg	q = 1'b0
	);

	reg q_n = 1'b1;
	always @(posedge sysclk) begin
		if (step_a)	q <= ~q_n;
		if (step_b) q_n <= q;
	end

endmodule
