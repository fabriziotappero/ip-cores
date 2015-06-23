`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////////
// 
// 4004 Instruction Pointer Array
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

module instruction_pointer (
	input  wire			sysclk,					// 50 MHz FPGA clock

	// Inputs from the Timing and I/O board
	input  wire			clk1,
	input  wire			clk2,
	input  wire			a12,
	input  wire			a22,
	input  wire			a32,
	input  wire			m12,
	input  wire			m22,
	input  wire			x12,
	input  wire			x22,
	input  wire			x32,
	input  wire			poc,					// Power-On Clear (reset)
	input  wire			m12_m22_clk1_m11_m12,	// M12+M22+CLK1~(M11+M12)

	// Common 4-bit data bus
	inout  wire	[3:0]	data,

	// Inputs from the Instruction Decode board
	input  wire			jcn_isz,				// JCN+ISZ
	input  wire			jin_fin,				// JIN+FIN
	input  wire			jun_jms,				// JUN+JMS
	input  wire			cn_n,					// ~CN
	input  wire			bbl,					// BBL
	input  wire			jms,					// JMS
	input  wire			sc,						// SC (Single Cycle)
	input  wire			dc						// DC (Double Cycle, ~SC)
	);

	reg  [11:0]	dram_array [0:3];
	reg  [11:0]	dram_temp;
	wire  [3:0]	din_n;

	wire inh = (jin_fin & sc) | ((jun_jms | (jcn_isz & ~cn_n)) & dc);

	// Row Counter stuff
	wire [1:0]	addr_ptr;				// Effective Address counter
	wire		addr_ptr_step;			// CLK2(JMS&DC&M22+BBL(M22+X12+X22))
	
	assign addr_ptr_step = ~(~clk2 | ~(((m22 | x12 | x22) & bbl) |
									   (m22 & dc & jms)));
	counter addr_ptr_0 (
		.sysclk(sysclk), 
		.step_a(clk1), 
		.step_b(addr_ptr_step), 
		.q(addr_ptr[0])
	);
	counter addr_ptr_1 (
		.sysclk(sysclk), 
		.step_a( addr_ptr[0]), 
		.step_b(~addr_ptr[0]), 
		.q(addr_ptr[1])
	);

	// Refresh counter stuff
	wire [1:0]	addr_rfsh;				// Row Refresh counter
	wire		addr_rfsh_step;			// (~INH)&X32&CLK2
	
	assign addr_rfsh_step = ~inh & x32 & clk2;
	
	counter addr_rfsh_0 (
		.sysclk(sysclk), 
		.step_a(clk1), 
		.step_b(addr_rfsh_step), 
		.q(addr_rfsh[0])
	);
	counter addr_rfsh_1 (
		.sysclk(sysclk), 
		.step_a( addr_rfsh[0]), 
		.step_b(~addr_rfsh[0]), 
		.q(addr_rfsh[1])
	);

	// Row selection mux
	reg  [1:0]	row;					// {N0409, N0420}
	always @(posedge sysclk) begin
		if (x12)
			row <= addr_rfsh;
		if (x32)
			row <= addr_ptr;
	end


	// Row Precharge/Read/Write stuff
	wire		precharge;				// (~INH)(X11+X31)CLK1
	wire		row_read;				// (~POC)CLK2(X12+X32)~INH
	wire		row_write;				// ((~SC)(JIN+FIN))CLK1(M11+X21~INH)

	reg n0517;
	always @(posedge sysclk) begin
		if (clk2)
			n0517 <= ~(m22 | x22);
	end
	assign precharge = ~(n0517 | inh | ~clk1);

	assign row_read = ~poc & clk2 & (x12 | x32) & ~inh;
	
	reg n0438;
	always @(posedge sysclk) begin
		if (clk2)
			n0438 <= ~((x12 & ~inh) | a32);
	end
	assign row_write = ~(n0438 | (jin_fin & ~sc) | ~clk1);


	// Column Read selection stuff
	reg n0416;
	always @(posedge sysclk) begin
		if (clk2)
			n0416 <= ~x32;
	end
	wire radb0 = ~(n0416 | clk2);

	reg n0384;
	always @(posedge sysclk) begin
		if (clk2)
			n0384 <= ~a12;
	end
	wire radb1 = ~(n0384 | clk2);

	reg n0374;
	always @(posedge sysclk) begin
		if (clk2)
			n0374 <= ~a22;
	end
	wire radb2 = ~(n0374 | clk2);


	// Column Write selection stuff
	wire n0322 = ~(sc | cn_n);
	wire wadb0 = ~(~clk2 | ~(a12 | (sc & jin_fin & x32) |
						(((jcn_isz & n0322) | (jun_jms & ~sc)) & m22)));
	wire wadb1 = ~(~clk2 | ~(a22 | (sc & jin_fin & x22) |
						(((jcn_isz & n0322) | (jun_jms & ~sc)) & m12)));
	wire wadb2 = ~(~clk2 | ~(a32 | (jun_jms & ~sc & x22)));


	// Manage the row data buffer
	always @(posedge sysclk) begin
		if (precharge)
			dram_temp <= 12'b0;
		
		if (row_read)
			dram_temp <= dram_array[row];
		
		if (wadb0)
			dram_temp[ 3:0] <= ~din_n;
		if (wadb1)
			dram_temp[ 7:4] <= ~din_n;
		if (wadb2)
			dram_temp[11:8] <= ~din_n;
	end

	// Handle row writes
	always @(posedge sysclk) begin
		if (row_write)
			dram_array[row] <= dram_temp;
	end

	// Manage the data output mux
	reg   [3:0]	dout;
	always @* begin
		(* PARALLEL_CASE *)
		case (1'b1)
			radb0:		dout = dram_temp[ 3:0];
			radb1:		dout = dram_temp[ 7:4];
			radb2:		dout = dram_temp[11:8];
			default:	dout = 4'bzzzz;
		endcase
	end
	assign data = dout;
	
	// Data In mux and incrementer
	reg [3:0] incr_in;
	always @(posedge sysclk) begin
		if (m12_m22_clk1_m11_m12)
			incr_in <= data;
	end

	reg carry_out, carry_in;
	wire [4:0] incr_out = (a12 | ((a22 | a32) & carry_in)) ?
			(incr_in + 4'b0001) : {1'b0, incr_in};
	always @(posedge sysclk) begin
		if (clk2)
			carry_out <= incr_out[4];
		if (clk1)
			carry_in <= carry_out;
	end
	assign din_n = ~incr_out[3:0];

endmodule
