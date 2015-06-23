`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Distributor register.
// 
// Additional Comments: See US 2959351, Fig. 61.
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

module distributor (
   input rst,
   input ap, cp, dp,
	input dx, d0, d10,
   input [0:6] selected_storage,
	input ri_dist,	// commutator 81f, dx:bp
   input [0:6] acc_ontime,
	input start_acc_dist_ri, end_acc_dist_ri, acc_dist_ri,
	input man_acc_reset,
	input [0:3] early_idx, ontime_idx,
	 
   output reg[0:6] ontime_out, early_out,
	output dist_back_sig
   );

	reg [0:6] digits [0:15];
	reg ri_dist_from_stor, dist_regen_ctl, ri_from_acc, ri_from_acc_delay;
	
	//-----------------------------------------------------------------------------
	// A -- Read digits RAM, write early and ontime outs
	//-----------------------------------------------------------------------------
	always @(posedge ap)
		if (rst) begin
			early_out  <= `biq_blank;
			ontime_out <= `biq_blank;
		end else begin
			early_out  <= (dist_regen_ctl | d10)? `biq_blank : digits[early_idx];
			ontime_out <= dx?            `biq_0 
			            : man_acc_reset? (d0? `biq_plus : `biq_0) 
			            :                early_out;
		end;
	
	//-----------------------------------------------------------------------------
   // C
	//-----------------------------------------------------------------------------
   always @(posedge cp)
		if (rst) begin
			ri_dist_from_stor <= 0;
			dist_regen_ctl <= 0;
			ri_from_acc <= 0;
			ri_from_acc_delay <= 0;
		end else begin
			if (d10) begin
				ri_dist_from_stor <= 0;
			end else if (ri_dist) begin
				ri_dist_from_stor <= 1;
			end
			
			if (d10 | end_acc_dist_ri) begin
				dist_regen_ctl <= 0;
			end else if (ri_dist | start_acc_dist_ri) begin
				dist_regen_ctl <= 1;
			end
			
			if (acc_dist_ri) begin
				ri_from_acc_delay <= 1;
			end else if (ri_from_acc_delay) begin
				ri_from_acc_delay <= 0;
				ri_from_acc <= 1;
			end else begin
				ri_from_acc <= 0;
			end
		end;

   //-----------------------------------------------------------------------------
   // D
	//-----------------------------------------------------------------------------
   always @(posedge dp)
      digits[ontime_idx] <= ri_dist_from_stor? selected_storage 
		                    : ri_from_acc?       acc_ontime 
		                    :                    ontime_out;
	digit_pulse bk_sig (rst, dp, ~dist_regen_ctl, 1'b1, dist_back_sig);
	
endmodule
