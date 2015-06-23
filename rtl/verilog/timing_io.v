`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////////
// 
// 4004 Timing and I/O Interfaces
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

module timing_io(
	input  wire			sysclk,
	input  wire			clk1_pad,
	input  wire			clk2_pad,
	input  wire			poc_pad,
	input  wire			ior,
	
	// Timing and I/O Board Outputs
	output wire			clk1,
	output wire			clk2,
	output wire			a12,
	output wire			a22,
	output wire			a32,
	output wire			m12,
	output wire			m22,
	output wire			x12,
	output wire			x22,
	output wire			x32,
	output wire			gate,
	output reg			poc,
	
	// External I/O Pad conditioning
	inout  wire	[3:0]	data,
	inout  wire [3:0]	data_pad,
	input  wire			test_pad,
	output reg			n0432,
	output reg			sync_pad,
	input  wire			cmrom,
	output wire			cmrom_pad,
	input  wire			cmram0,
	output wire			cmram0_pad,
	input  wire			cmram1,
	output wire			cmram1_pad,
	input  wire			cmram2,
	output wire			cmram2_pad,
	input  wire			cmram3,
	output wire			cmram3_pad
    );

	// Simple pass-throughs
	assign clk1 = clk1_pad;
	assign clk2 = clk2_pad;
	assign cmrom_pad  = cmrom;
	assign cmram0_pad = cmram0;
	assign cmram1_pad = cmram1;
	assign cmram2_pad = cmram2;
	assign cmram3_pad = cmram3;


	// Generate the 8 execution phase indicators
	reg [0:7] master = 8'h00;
	reg [0:7] slave  = 8'h00;
	always @(posedge sysclk) begin
		if (clk2)
			master <= {~|slave[0:6], slave[0:6]};
		else
			sync_pad <= master[7];

		if (clk1)
			slave <= master;
	end

	assign a12 = slave[0];
	assign a22 = slave[1];
	assign a32 = slave[2];
	assign m12 = slave[3];
	assign m22 = slave[4];
	assign x12 = slave[5];
	assign x22 = slave[6];
	assign x32 = slave[7];


	// Generate the DRAM Input Gate signal
	// Properly called M12+M22+CLK1~(M11&M12)
	wire n0279 = ~(a32 | m12);
	reg n0278;
	always @(posedge sysclk) begin
		if (clk2)
			n0278 <= n0279;
	end
	wire n0708 = ~((n0278 & clk1) | m12 | m22);
	assign gate = ~n0708;

	
	// Generate a clean POC signal
	always @(posedge sysclk) begin
		if (poc_pad)	poc <= 1'b1;
		else if (a12)	poc <= 1'b0;
		else			poc <= poc;
	end
	
	// Generate a clean ~TEST signal (n0432)
	always @(posedge sysclk) begin
		n0432 <= ~test_pad;
	end

	// Manage the Data I/O pads
	reg L;
	always @(posedge sysclk) begin
		if (clk2)
			L <= a32 | m12 | (x12 & (ior | poc));
	end

	wire n0702 = ~clk2;
	reg n0685;
	reg n0699;
	reg n0707;
	always @(posedge sysclk) begin
		if (clk1) begin
			n0685 <= ~L;
			n0707 <=  L;
		end
		if (n0702)
			n0699 <= ~L;
	end
	wire n0700 = n0707 | (L & n0702) | poc;
	wire n0659 = (clk2 & n0685) | (clk1 & L);
	wire n0676 = clk1 | n0685 | n0699;
	
	// Incoming data from the external pads
	reg [3:0] data_in;
	always @* begin
		if (n0659)		data_in = 4'b1111;
		else if (n0676)	data_in = 4'bzzzz;
		else if (poc)	data_in = 4'b0000;
		else 			data_in = data_pad;
	end
	assign data = data_in;

	// Outgoing data to the external pads
	reg [3:0] data_out;
	always @(posedge sysclk) begin
		if (n0702)
			data_out <= data;
	end
	assign data_pad = poc ? 4'b0000 : (n0700 ? 4'bzzzz : data_out);

endmodule
