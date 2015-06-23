`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////////
// 
// 4004 Arithmetic Logic Unit
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

module alu(
	input  wire			sysclk,
	
	// Inputs from the Timing and I/O board
	input  wire			a12,
	input  wire			m12,
	input  wire			x12,
	input  wire			poc,
	
	// Common 4-bit data bus
	inout  wire	[3:0]	data,

	// Outputs to the Instruction Decode board
	output wire			acc_0,
	output wire			add_0,
	output reg			cy_1,

	// Inputs from the Instruction Decode board
	input  wire			cma,
	input  wire			write_acc_1,
	input  wire			write_carry_2,
	input  wire			read_acc_3,
	input  wire			add_group_4,
	input  wire			inc_group_5,
	input  wire			sub_group_6,
	input  wire			ior,
	input  wire			iow,
	input  wire			ral,
	input  wire			rar,
	input  wire			ope_n,
	input  wire			daa,
	input  wire			dcl,
	input  wire			inc_isz,
	input  wire			kbp,
	input  wire			o_ib,
	input  wire			tcs,
	input  wire			xch,
	input  wire			n0342,
	input  wire			x21_clk2,
	input  wire			x31_clk2,
	input  wire			com_n,
	
	// Outputs to external pins
	output wire			cmram0,
	output wire			cmram1,
	output wire			cmram2,
	output wire			cmram3,
	output wire			cmrom
	);

	reg [3:0]	acc;
	reg 		cy;

	// Decode logic
	wire n0854		= ~(~x12);
	wire n0351		= ~(x21_clk2 | ~dcl);
	wire n0415		= ~(x21_clk2 | ope_n);
	wire add_ib		= ~(x31_clk2 | ~inc_isz);
	wire cy_ib		= ~(x31_clk2 | ~iow);
	wire acb_ib		= ~((x31_clk2 | ~xch) & (x21_clk2 | ~iow));
	wire n0477		= ~((~x31_clk2 & ~ior) | (a12 & ior));
	wire adc_cy		= ~(write_carry_2 | n0477);
	wire add_acc	= ~(write_acc_1 | n0477);
	wire adsr		= ~(x31_clk2 | ~rar);
	wire adsl		= ~(x31_clk2 | ~ral);
	wire acc_adac	= ~(~cma | n0342);
	wire acc_ada	= ~(read_acc_3 | n0342);
	wire cy_ada		= ~(add_group_4 | n0342);
	wire cy_adac	= ~(sub_group_6 | n0342);

	// Latch the incoming data bus
	reg [3:0] tmp;					// It's the name used in simulator!
	always @(posedge sysclk) begin
		if (~n0342)
			tmp <= data;
		if (m12)
			tmp <= 4'b1111;
	end
	
	// Invert some of the incoming data
	reg n0893, n0891, n0889, n0887;	// D3, D2, D1, D0
	always @(posedge sysclk) begin
		if (sub_group_6) begin
			n0887 <=  tmp[0];
			n0889 <= ~tmp[1];
			n0891 <=  tmp[2];
			n0893 <= ~tmp[3];
		end
		if (~(sub_group_6 | m12)) begin
			n0887 <= ~tmp[0];
			n0889 <=  tmp[1];
			n0891 <= ~tmp[2];
			n0893 <=  tmp[3];
		end
	end

	// Feedback from Accumulator
	reg n0873, n0872, n0871, n0870;
	always @(posedge sysclk) begin
		if (m12)
			{n0873, n0872, n0871, n0870} <= 4'b1010;
		if (acc_ada)
			{n0873, n0872, n0871, n0870} <= acc;
		if (acc_adac)
			{n0873, n0872, n0871, n0870} <= ~acc;
	end

	// Carry generator
	wire n0546 = ~(inc_group_5 | n0342);
	reg n0550;
	always @(posedge sysclk) begin
		if (m12)		n0550 <= 1'b0;
		if (n0546)		n0550 <= 1'b1;
		if (cy_adac)	n0550 <= ~cy;
		if (cy_ada)		n0550 <= cy;
	end
	wire n0911 = ~(n0550 ? (n0887 | n0870) : (n0887 & n0870));
	wire n0553 = n0911;
	wire n0912 = ~(n0553 ? (n0889 | n0871) : (n0889 & n0871));
	wire n0556 = n0912;
	wire n0913 = ~(n0556 ? (n0891 | n0872) : (n0891 & n0872));
	wire n0559 = n0913;
	wire n0914 = ~(n0559 ? (n0893 | n0873) : (n0893 & n0873));
	wire n0861 = n0914;

	// Adder
	wire n0877 = ~((n0893 & n0559 & n0873) | (n0861 & (n0893 | n0873 | n0559)));
	wire n0878 = ~((n0877 & n0550 & n0870) | (n0553 & (n0887 | n0870 | n0550)));
	wire n0875 = ~((n0889 & n0553 & n0871) | (n0556 & (n0889 | n0871 | n0553)));
	wire n0879 = ~((n0891 & n0556 & n0872) | (n0559 & (n0891 | n0872 | n0556)));
	wire n0846 = ~n0878;
	wire n0847 =  n0875;
	wire n0848 = ~n0879;
	wire n0514 =  n0877;

	// Shifter / Accumulator and Carry
	reg [3:0] acc_out;					// {n0356, n0348, n0347, n0346}
	wire n0803 = ~((acc_out[3] & (acc_out[2] | acc_out[1])) | cy_1);
	wire n0403 = ~(~daa | n0803);
	wire [3:0] acc_in = {n0514, n0848, n0847, n0846};
	always @(posedge sysclk) begin
		if (adsr)
			{acc, cy} <= {cy_1, acc_in};
		if (add_acc)
			acc <= acc_in;
		if (adsl)
			{cy, acc} <= {acc_in, cy_1};
		if (adc_cy)
			cy <= n0861;
		if (n0403 & n0415)
			cy <= 1'b1;
		// Dynamic refresh would occur during M12
	end
	
	// Accumulator output latch
	always @(posedge sysclk) begin
		if (n0854) begin
			cy_1 <= cy;
			acc_out <= acc;
		end
	end
	assign acc_0 = ~|acc_out;
	assign add_0 = ~|acc_in;

	// Keyboard Process logic
	wire n0378 = ~((daa & n0803) | o_ib);
	wire n0345 =  kbp & (acc_out == 4'b1000);
	wire n0354 =  kbp & (acc_out == 4'b0100);
	wire n0363 =  kbp & (acc_out == 4'b0010);
	wire n0370 =  kbp & (acc_out == 4'b0001);
	wire n0377 = (kbp & (acc_out == 4'b0000)) | ~n0378;
	wire n0358 = ~(n0345 | n0354 | n0363 | n0370 | n0377 |       n0403);
	wire n0366 = ~(        n0354 | n0363 | n0370 | n0377 | tcs        );
	wire n0359 = ~(n0345 |                 n0370 | n0377 | tcs        );
	wire n0357 = ~(n0345 |         n0363 |         n0377 |       n0403);

	// Data output mux
	reg [3:0] dout;
	always @(*) begin
		dout = 4'bzzzz;
		if (acb_ib)
			dout = acc_out;
		if (add_ib)
			dout = acc_in;
		if (cy_ib)
			dout = {3'bxxx, cy_1};
		if (n0415)
			dout = {n0358, n0366, n0359, n0357};
	end
	assign data = dout;
	
	// Generate CMROM / CMRAMn
	// This may get moved to the Timing & I/O board
	// Inputs: {n0355, n0364, n0371}, n0351, poc, com_n
	wire n0355 = ~acc_out[2];
	wire n0364 = ~acc_out[1];
	wire n0371 = ~acc_out[0];
	reg n0749, n0750, n0751;
	always @(posedge sysclk) begin
		if (poc) begin
			n0749 <= 1'b1;
			n0750 <= 1'b1;
			n0751 <= 1'b1;
		end
		else begin
			if (n0351) begin
				n0749 <= n0355;
				n0750 <= n0364;
				n0751 <= n0371;
			end
		end
	end

	assign cmram3 = ~(com_n | n0749);
	assign cmram2 = ~(com_n | n0750);
	assign cmram1 = ~(com_n | n0751);
	assign cmram0 = ~(com_n | ~n0749 | ~n0750 | ~n0751);
	assign cmrom  = ~(com_n | poc);
	
endmodule
