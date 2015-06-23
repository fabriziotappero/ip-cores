//                              -*- Mode: Verilog -*-
// Filename        : oks8_tb.v
// Description     : OKS8 CPU Simulation using model RAM/ROM
// Author          : Jian Li
// Created On      : Sat Jan 07 09:09:49 2006
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!

/*
 * Copyright (C) 2006 to Jian Li
 * Contact: kongzilee@yahoo.com.cn
 * 
 * This source file may be used and distributed without restriction
 * provided that this copyright statement is not removed from the file
 * and that any derivative works contain the original copyright notice
 * and the associated disclaimer.
 * 
 * THIS SOFTWARE IS PROVIDE "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
 * SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

`include "oks8_defines.v"
`include "oks8.v"

// synopsys translate_off
`timescale 1ns / 10ps
// synopsys translate_on

// =====================================================================
// OKS8 CPU SIMULATION
// This is only for simulation purposes. It can be used to simulate
// RTL and also Gate Level Netlist. 
//
// All ROM codes should be loaded from a file named "oks8sim.rom".
//
// =====================================================================
module oks8_tb ();

  parameter iw = `W_INST;

  reg clk_i, rst_i, int_i;

  wire clk_o;
  wire ien_o;
  wire den_o;
  wire we_o;
  wire rst_o;
  wire [15:0] add_o;
  wire [7:0] dat_i, dat_o;

  oks8  mcu0 (/*AUTOINST*/
	// Outputs
	.rst_o		(rst_o),
	.clk_o		(clk_o),
	.ien_o		(ien_o),
	.den_o		(den_o),
	.we_o		(we_o),
	.add_o		(add_o),
	.dat_o		(dat_o),
	// Inputs
	.rst_i		(rst_i),
	.clk_i		(clk_i),
	.int_i		(int_i),
	// Inputs
	.dat_i		(dat_i)
	);

  ex_mem imem(/*AUTOINST*/
	.clk		(clk_o),
	.address	(add_o[iw-1:0]),
	.en			(ien_o),
	.we			(we_o),
	.din		(dat_o),
	.dout		(dat_i)
	);

  ex_mem dmem(/*AUTOINST*/
	.clk		(clk_o),
	.address	(add_o[iw-1:0]),
	.en			(den_o),
	.we			(we_o),
	.din		(dat_o),
	.dout		(dat_i)
	);

//
// SIMULATED CLOCK & RESET
//
initial begin

  $readmemh("../../sw/oks8sim.rom",imem.mem);

  int_i = 0;
  clk_i = 0;
  rst_i = 1;

  $display ("time ", $time, " reset ON");
  $dumpfile("oks8sim.vcd");
  $dumpvars(1, clk_i, rst_i, int_i);
  $dumpvars(1, clk_o, rst_o);
  $dumpvars(1, add_o, dat_i, dat_o, ien_o, den_o, we_o);
  $dumpvars(1, mcu0.s$_clk, mcu0.p$_clk);
  $dumpvars(1, mcu0.pow0.idle, mcu0.pow0.stop);
  $dumpvars(1, mcu0.dc_final, mcu0.ex_final, mcu0.pc);
  $dumpvars(1, mcu0.s$_fen);
  $dumpvars(1, mcu0.d0.en_i, mcu0.d0.op, mcu0.d0.fin_o);
  $dumpvars(1, mcu0.ex0.en_i, mcu0.ex0.alu, mcu0.ex0.sts);
  $dumpvars(1, mcu0.ex0.r1, mcu0.ex0.r1_t, mcu0.ex0.r2, mcu0.ex0.r2_t, mcu0.ex0.r3);
  $dumpvars(1, mcu0.ex0.src_finish, mcu0.ex0.dst_finish, mcu0.ex0.ex_final);
  $dumpvars(1, mcu0.ex0.skp_o, mcu0.ex0.do_int_);

  $dumpon;

  #40 rst_i = 0;
  $display ("time ", $time, " reset OFF");

  #2000 int_i = 1;	// Simulate a interrupt
  #100 int_i = 0;

  #3000 rst_i = 0;
  $monitoroff;
  $display("time ", $time, " End of Bench");
  $stop;

end

  always clk_i = #5 ~clk_i;

endmodule	// oks8_tb

// =====================================================================
// SIMULATION RAM/ROM
// Provides 2K of RAM/ROM Space from 0000h
// =====================================================================
module ex_mem (/*AUTOARG*/
  // Inputs
  clk, address, en, we, din,
  // Outputs
  dout );

parameter ew = `W_INST;
parameter depth = 8192;

input			clk;
input [ew-1:0]	address;
input			en;
input			we;
input [7:0]		din;
output [7:0]	dout;

reg [ew-1:0]	addr_r;
reg [7:0]		mem[0:depth-1];

always @(posedge clk)
   addr_r <= address;
   
assign dout = (en) ? mem[addr_r] : `DAT_Z;

always @(posedge clk)
   if (en && we) mem[address] <= din;

endmodule	// ex_mem

// =====================================================================
