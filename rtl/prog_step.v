`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Program step register.
// 
// Additional Comments: See US 2959351, Fig. 62.
//
// Copyright (c) 2015 Robert Abeles
//
// This source file is free software; you can redistribute it
// and/or modify it under the terms of the GNU Lesser General
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any
// later version.
//
// This source is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General
// Public License along with this source; if not, download it
// from http://www.opencores.org/lgpl.shtml
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module prog_step (
    input rst,
    input ap, dp,
	 input dx, d0, d10,
    input [0:3] early_idx, ontime_idx,
	 input man_prog_reset, rips,
	 input [0:6] adder_out, sel_store_out,
	 input prog_ped_regen, prog_add, // see tlu 86d
	 
	 output reg [0:6] early_out, ontime_out,
	 output [0:6] ped_out,
	 output prog_restart_sig
    );

	reg [0:6] digits [0:15];
	reg ri_prog_step;
	
	//-----------------------------------------------------------------------------
	// AP -- Read digits RAM, write early and ontime outs
	//       Start/stop RI control
	//			Generate prog_restart_sig
	//-----------------------------------------------------------------------------
	digit_pulse pr_sig (rst, ap, ~rips, 1'b1, prog_restart_sig);
	always @(posedge ap)
		if (rst) begin
			ri_prog_step <= 0;
			early_out <= `biq_blank;
			ontime_out <= `biq_blank;
		end else begin
		   if (d0) begin
				ri_prog_step <= rips;
			end
			early_out <= (dx | d10)? `biq_blank : digits[early_idx];
			ontime_out <= man_prog_reset? `biq_0 : early_out;
		end;
	
	//-----------------------------------------------------------------------------
	// DP
	//-----------------------------------------------------------------------------
	assign ped_out = ri_prog_step? sel_store_out 
	               : prog_ped_regen? ontime_out 
						: prog_add? adder_out 
						: `biq_blank;
	always @(posedge dp)
		digits[ontime_idx] <= (dx | d0)? `biq_blank : ped_out;

endmodule
