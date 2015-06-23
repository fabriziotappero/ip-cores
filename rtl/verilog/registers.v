//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile library, registers                                ////
////                                                              ////
////  Description                                                 ////
////  Different type of registers                                 ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////   - add more different registers                             ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2010 Authors and OPENCORES.ORG                 ////
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
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`ifdef DFF
`define MODULE dff
module `BASE`MODULE ( d, q, clk, rst);
`undef MODULE
	parameter width = 1;	
	parameter reset_value = {width{1'b0}};

	input [width-1:0] d; 
	input clk, rst;
	output reg [width-1:0] q;
	
	always @ (posedge clk or posedge rst)
	if (rst)
		q <= reset_value;
	else
		q <= d;

endmodule
`endif

`ifdef DFF_ARRAY
`define MODULE dff_array
module `BASE`MODULE ( d, q, clk, rst);
`undef MODULE

	parameter width = 1;
        parameter depth = 2;
	parameter reset_value = 1'b0;

	input [width-1:0] d; 
	input clk, rst;
	output [width-1:0] q;
        reg  [0:depth-1] q_tmp [width-1:0];
	integer i;
	always @ (posedge clk or posedge rst)
	if (rst) begin
            for (i=0;i<depth;i=i+1)
		q_tmp[i] <= {width{reset_value}};
	end else begin
            q_tmp[0] <= d;
            for (i=1;i<depth;i=i+1)
		q_tmp[i] <= q_tmp[i-1];
        end
        
    assign q = q_tmp[depth-1];
    
endmodule
`endif

`ifdef DFF_CE
`define MODULE dff_ce
module `BASE`MODULE ( d, ce, q, clk, rst);
`undef MODULE

	parameter width = 1;	
	parameter reset_value = {width{1'b0}};
	
	input [width-1:0] d; 
	input ce, clk, rst;
	output reg [width-1:0] q;

	always @ (posedge clk or posedge rst)
	if (rst)
		q <= reset_value;
	else
		if (ce)
			q <= d;

endmodule
`endif

`ifdef DFF_CE_CLEAR
`define MODULE dff_ce_clear
module `BASE`MODULE ( d, ce, clear, q, clk, rst);
`undef MODULE

	parameter width = 1;	
	parameter reset_value = {width{1'b0}};
	
	input [width-1:0] d; 
	input ce, clear, clk, rst;
	output reg [width-1:0] q;

	always @ (posedge clk or posedge rst)
	if (rst)
	    q <= reset_value;
	else
            if (ce)
                if (clear)
                    q <= {width{1'b0}};
                else
                    q <= d;

endmodule
`endif

`ifdef DF_CE_SET
`define MODULE dff_ce_set
module `BASE`MODULE ( d, ce, set, q, clk, rst);
`undef MODULE

	parameter width = 1;	
	parameter reset_value = {width{1'b0}};
	
	input [width-1:0] d; 
	input ce, set, clk, rst;
	output reg [width-1:0] q;

	always @ (posedge clk or posedge rst)
	if (rst)
	    q <= reset_value;
	else
            if (ce)
                if (set)
                    q <= {width{1'b1}};
                else
                    q <= d;

endmodule
`endif

`ifdef SPR
`define MODULE spr
module `BASE`MODULE ( sp, r, q, clk, rst);
`undef MODULE

        //parameter width = 1;
        parameter reset_value = 1'b0;
        
        input sp, r;
        output reg q;
        input clk, rst;
        
        always @ (posedge clk or posedge rst)
        if (rst)
            q <= reset_value;
        else
            if (sp)
                q <= 1'b1;
            else if (r)
                q <= 1'b0;

endmodule
`endif

`ifdef SRP
`define MODULE srp
module `BASE`MODULE ( s, rp, q, clk, rst);
`undef MODULE

        parameter width = 1;
        parameter reset_value = 0;
        
        input s, rp;
        output reg q;
        input clk, rst;
        
        always @ (posedge clk or posedge rst)
        if (rst)
            q <= reset_value;
        else
            if (rp)
                q <= 1'b0;
            else if (s)
                q <= 1'b1;

endmodule
`endif

`ifdef ALTERA

`ifdef DFF_SR
// megafunction wizard: %LPM_FF%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: lpm_ff 

// ============================================================
// File Name: dff_sr.v
// Megafunction Name(s):
// 			lpm_ff
//
// Simulation Library Files(s):
// 			lpm
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 9.1 Build 304 01/25/2010 SP 1 SJ Full Version
// ************************************************************


//Copyright (C) 1991-2010 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
`define MODULE dff_sr
module `BASE`MODULE (
`undef MODULE

	aclr,
	aset,
	clock,
	data,
	q);

	input	  aclr;
	input	  aset;
	input	  clock;
	input	  data;
	output	  q;

	wire [0:0] sub_wire0;
	wire [0:0] sub_wire1 = sub_wire0[0:0];
	wire  q = sub_wire1;
	wire  sub_wire2 = data;
	wire  sub_wire3 = sub_wire2;

	lpm_ff	lpm_ff_component (
				.aclr (aclr),
				.clock (clock),
				.data (sub_wire3),
				.aset (aset),
				.q (sub_wire0)
				// synopsys translate_off
				,
				.aload (),
				.enable (),
				.sclr (),
				.sload (),
				.sset ()
				// synopsys translate_on
				);
	defparam
		lpm_ff_component.lpm_fftype = "DFF",
		lpm_ff_component.lpm_type = "LPM_FF",
		lpm_ff_component.lpm_width = 1;


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: ACLR NUMERIC "1"
// Retrieval info: PRIVATE: ALOAD NUMERIC "0"
// Retrieval info: PRIVATE: ASET NUMERIC "1"
// Retrieval info: PRIVATE: ASET_ALL1 NUMERIC "1"
// Retrieval info: PRIVATE: CLK_EN NUMERIC "0"
// Retrieval info: PRIVATE: DFF NUMERIC "1"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
// Retrieval info: PRIVATE: SCLR NUMERIC "0"
// Retrieval info: PRIVATE: SLOAD NUMERIC "0"
// Retrieval info: PRIVATE: SSET NUMERIC "0"
// Retrieval info: PRIVATE: SSET_ALL1 NUMERIC "1"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: PRIVATE: UseTFFdataPort NUMERIC "0"
// Retrieval info: PRIVATE: nBit NUMERIC "1"
// Retrieval info: CONSTANT: LPM_FFTYPE STRING "DFF"
// Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_FF"
// Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "1"
// Retrieval info: USED_PORT: aclr 0 0 0 0 INPUT NODEFVAL aclr
// Retrieval info: USED_PORT: aset 0 0 0 0 INPUT NODEFVAL aset
// Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL clock
// Retrieval info: USED_PORT: data 0 0 0 0 INPUT NODEFVAL data
// Retrieval info: USED_PORT: q 0 0 0 0 OUTPUT NODEFVAL q
// Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
// Retrieval info: CONNECT: q 0 0 0 0 @q 0 0 1 0
// Retrieval info: CONNECT: @aclr 0 0 0 0 aclr 0 0 0 0
// Retrieval info: CONNECT: @aset 0 0 0 0 aset 0 0 0 0
// Retrieval info: CONNECT: @data 0 0 1 0 data 0 0 0 0
// Retrieval info: LIBRARY: lpm lpm.lpm_components.all
// Retrieval info: GEN_FILE: TYPE_NORMAL dff_sr.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL dff_sr.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL dff_sr.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL dff_sr.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL dff_sr_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL dff_sr_bb.v FALSE
// Retrieval info: LIB_FILE: lpm
`endif

`else

`ifdef DFF_SR
`define MODULE dff_sr
module `BASE`MODULE ( aclr, aset, clock, data, q);
`undef MODULE

    input	  aclr;
    input	  aset;
    input	  clock;
    input	  data;
    output reg	  q;

   always @ (posedge clock or posedge aclr or posedge aset)
     if (aclr)
       q <= 1'b0;
     else if (aset)
       q <= 1'b1;
     else
       q <= data;

endmodule
`endif

`endif

// LATCH
// For targtes not supporting LATCH use dff_sr with clk=1 and data=1
`ifdef ALTERA

`ifdef LATCH
`define MODULE latch
module `BASE`MODULE ( d, le, q, clk);
`undef MODULE
input d, le;
output q;
input clk;
dff_sr i0 (.aclr(), .aset(), .clock(1'b1), .data(1'b1), .q(q));
endmodule
`endif

`else

`ifdef LATCH
`define MODULE latch
module `BASE`MODULE ( d, le, q, clk);
`undef MODULE
input d, le;
input clk;
always @ (le or d)
if (le)
    d <= q;
endmodule
`endif

`endif

`ifdef SHREG
`define MODULE shreg
module `BASE`MODULE ( d, q, clk, rst);
`undef MODULE

parameter depth = 10;
input d;
output q;
input clk, rst;

reg [1:depth] dffs;

always @ (posedge clk or posedge rst)
if (rst)
    dffs <= {depth{1'b0}};
else
    dffs <= {d,dffs[1:depth-1]};
assign q = dffs[depth];
endmodule
`endif

`ifdef SHREG_CE
`define MODULE shreg_ce
module `BASE`MODULE ( d, ce, q, clk, rst);
`undef MODULE
parameter depth = 10;
input d, ce;
output q;
input clk, rst;

reg [1:depth] dffs;

always @ (posedge clk or posedge rst)
if (rst)
    dffs <= {depth{1'b0}};
else
    if (ce)
        dffs <= {d,dffs[1:depth-1]};
assign q = dffs[depth];
endmodule
`endif

`ifdef DELAY
`define MODULE delay
module `BASE`MODULE ( d, q, clk, rst);
`undef MODULE
parameter depth = 10;
input d;
output q;
input clk, rst;

reg [1:depth] dffs;

always @ (posedge clk or posedge rst)
if (rst)
    dffs <= {depth{1'b0}};
else
    dffs <= {d,dffs[1:depth-1]};
assign q = dffs[depth];
endmodule
`endif

`ifdef DELAY_EMPTYFLAG
`define MODULE delay_emptyflag
module `BASE`MODULE ( d, q, emptyflag, clk, rst);
`undef MODULE
parameter depth = 10;
input d;
output q, emptyflag;
input clk, rst;

reg [1:depth] dffs;

always @ (posedge clk or posedge rst)
if (rst)
    dffs <= {depth{1'b0}};
else
    dffs <= {d,dffs[1:depth-1]};
assign q = dffs[depth];
assign emptyflag = !(|dffs);
endmodule
`endif

`ifdef PULSE2TOGGLE
`define MODULE pulse2toggle
module `BASE`MODULE ( pl, q, clk, rst);
`undef MODULE
input pl;
output reg q;
input clk, rst;
always @ (posedge clk or posedge rst)
if (rst)
    q <= 1'b0;
else
    q <= pl ^ q;
endmodule
`endif

`ifdef TOGGLE2PULSE
`define MODULE toggle2pulse
module `BASE`MODULE (d, pl, clk, rst);
`undef MODULE
input d;
output pl;
input clk, rst;
reg dff;
always @ (posedge clk or posedge rst)
if (rst)
    dff <= 1'b0;
else
    dff <= d;
assign pl = d ^ dff;
endmodule
`endif

`ifdef SYNCHRONIZER
`define MODULE synchronizer
module `BASE`MODULE (d, q, clk, rst);
`undef MODULE
input d;
output reg q;
input clk, rst;
reg dff;
always @ (posedge clk or posedge rst)
if (rst)
    {q,dff} <= 2'b00;
else
    {q,dff} <= {dff,d};
endmodule
`endif

`ifdef CDC
`define MODULE cdc
module `BASE`MODULE ( start_pl, take_it_pl, take_it_grant_pl, got_it_pl, clk_src, rst_src, clk_dst, rst_dst);
`undef MODULE
input start_pl;
output take_it_pl;
input take_it_grant_pl; // note: connect to take_it_pl to generate automatic ack
output got_it_pl;
input clk_src, rst_src;
input clk_dst, rst_dst;
wire take_it_tg, take_it_tg_sync;
wire got_it_tg, got_it_tg_sync;
// src -> dst
`define MODULE pulse2toggle
`BASE`MODULE p2t0 (
`undef MODULE
    .pl(start_pl),
    .q(take_it_tg),
    .clk(clk_src),
    .rst(rst_src));

`define MODULE synchronizer
`BASE`MODULE sync0 (
`undef MODULE
    .d(take_it_tg),
    .q(take_it_tg_sync),
    .clk(clk_dst),
    .rst(rst_dst));
    
`define MODULE toggle2pulse
`BASE`MODULE t2p0 (
`undef MODULE
    .d(take_it_tg_sync),
    .pl(take_it_pl),
    .clk(clk_dst),
    .rst(rst_dst));

// dst -> src
`define MODULE pulse2toggle
`BASE`MODULE p2t1 (
`undef MODULE
    .pl(take_it_grant_pl),
    .q(got_it_tg),
    .clk(clk_dst),
    .rst(rst_dst));

`define MODULE synchronizer
`BASE`MODULE sync1 (
`undef MODULE
    .d(got_it_tg),
    .q(got_it_tg_sync),
    .clk(clk_src),
    .rst(rst_src));

`define MODULE toggle2pulse
`BASE`MODULE t2p1 (
`undef MODULE
    .d(got_it_tg_sync),
    .pl(got_it_pl),
    .clk(clk_src),
    .rst(rst_src));

endmodule
`endif
