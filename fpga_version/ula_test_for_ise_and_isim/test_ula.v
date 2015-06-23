`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:16:22 04/08/2012
// Design Name:   ula
// Module Name:   C:/proyectos_xilinx/ulaplus/test_reference_ula.v
// Project Name:  ulaplus
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ula
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_standard_ula;

	// Inputs
	reg clk14;
	wire [15:0] a;
	wire [7:0] din;
	wire mreq_n;
	wire iorq_n;
	wire wr_n;
	wire rfsh_n;
	reg [7:0] vramdout;
	reg ear;
	reg [4:0] kbcolumns;

	// Outputs
	wire [7:0] dout;
	wire clkcpu;
	wire msk_int_n;
	wire [13:0] va;
	wire [7:0] vramdin;
	wire vramoe;
	wire vramcs;
	wire vramwe;
	wire mic;
	wire spk;
	wire [7:0] kbrows;
	wire r;
	wire g;
	wire b;
	wire i;
	wire csync;

	// Instantiate the Unit Under Test (UUT)
	ula uut (
		.clk14(clk14), 
		.a(a), 
		.din(din), 
		.dout(dout), 
		.mreq_n(mreq_n), 
		.iorq_n(iorq_n), 
		.rd_n(1'b1), 
		.wr_n(wr_n), 
		.rfsh_n(rfsh_n),
		.clkcpu(clkcpu), 
		.msk_int_n(msk_int_n), 
		.va(va), 
		.vramdout(vramdout), 
		.vramdin(vramdin), 
		.vramoe(vramoe), 
		.vramcs(vramcs), 
		.vramwe(vramwe), 
		.ear(ear), 
		.mic(mic), 
		.spk(spk), 
		.kbrows(kbrows), 
		.kbcolumns(kbcolumns), 
		.r(r), 
		.g(g), 
		.b(b), 
		.i(i), 
		.csync(csync)
	);

	z80memio cpu (
		.clk(clkcpu),
	   .a(a),
		.d(din),
		.mreq_n(mreq_n),
		.iorq_n(iorq_n),
		.wr_n(wr_n),
		.rfsh_n(rfsh_n)
	);

	initial begin
		// Initialize Inputs
		clk14 = 0;
		vramdout = 8'b01010101;
		ear = 0;
		kbcolumns = 0;
	end
	
	always begin
		clk14 = #35.714286 ~clk14;
	end      
endmodule
