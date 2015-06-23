//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Xess Traffic Cop                                            ////
////                                                              ////
////  This file is part of the OR1K test application              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  This block connectes the RISC and peripheral controller     ////
////  cores together.                                             ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2002 OpenCores                                 ////
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
 module 
  wb_traffic_cop_arb 
    #( parameter 
      multitarg=1'b0,
      t0_addr=2'b00,
      t0_addr_w=2,
      t17_addr=2'b00,
      t17_addr_w=2,
      wb_addr_width=32,
      wb_byte_lanes=4,
      wb_data_width=32)
     (
 input   wire                 i0_wb_cyc_i,
 input   wire                 i0_wb_stb_i,
 input   wire                 i0_wb_we_i,
 input   wire                 i1_wb_cyc_i,
 input   wire                 i1_wb_stb_i,
 input   wire                 i1_wb_we_i,
 input   wire                 i2_wb_cyc_i,
 input   wire                 i2_wb_stb_i,
 input   wire                 i2_wb_we_i,
 input   wire                 i3_wb_cyc_i,
 input   wire                 i3_wb_stb_i,
 input   wire                 i3_wb_we_i,
 input   wire                 i4_wb_cyc_i,
 input   wire                 i4_wb_stb_i,
 input   wire                 i4_wb_we_i,
 input   wire                 i5_wb_cyc_i,
 input   wire                 i5_wb_stb_i,
 input   wire                 i5_wb_we_i,
 input   wire                 i6_wb_cyc_i,
 input   wire                 i6_wb_stb_i,
 input   wire                 i6_wb_we_i,
 input   wire                 i7_wb_cyc_i,
 input   wire                 i7_wb_stb_i,
 input   wire                 i7_wb_we_i,
 input   wire                 t0_wb_ack_i,
 input   wire                 t0_wb_err_i,
 input   wire                 wb_clk_i,
 input   wire                 wb_rst_i,
 input   wire    [ 3 :  0]        i0_wb_sel_i,
 input   wire    [ 3 :  0]        i1_wb_sel_i,
 input   wire    [ 3 :  0]        i2_wb_sel_i,
 input   wire    [ 3 :  0]        i3_wb_sel_i,
 input   wire    [ 3 :  0]        i4_wb_sel_i,
 input   wire    [ 3 :  0]        i5_wb_sel_i,
 input   wire    [ 3 :  0]        i6_wb_sel_i,
 input   wire    [ 3 :  0]        i7_wb_sel_i,
 input   wire    [ 31 :  0]        i0_wb_adr_i,
 input   wire    [ 31 :  0]        i0_wb_dat_i,
 input   wire    [ 31 :  0]        i1_wb_adr_i,
 input   wire    [ 31 :  0]        i1_wb_dat_i,
 input   wire    [ 31 :  0]        i2_wb_adr_i,
 input   wire    [ 31 :  0]        i2_wb_dat_i,
 input   wire    [ 31 :  0]        i3_wb_adr_i,
 input   wire    [ 31 :  0]        i3_wb_dat_i,
 input   wire    [ 31 :  0]        i4_wb_adr_i,
 input   wire    [ 31 :  0]        i4_wb_dat_i,
 input   wire    [ 31 :  0]        i5_wb_adr_i,
 input   wire    [ 31 :  0]        i5_wb_dat_i,
 input   wire    [ 31 :  0]        i6_wb_adr_i,
 input   wire    [ 31 :  0]        i6_wb_dat_i,
 input   wire    [ 31 :  0]        i7_wb_adr_i,
 input   wire    [ 31 :  0]        i7_wb_dat_i,
 input   wire    [ 31 :  0]        t0_wb_dat_i,
 output   wire                 i0_wb_ack_o,
 output   wire                 i0_wb_err_o,
 output   wire                 i1_wb_ack_o,
 output   wire                 i1_wb_err_o,
 output   wire                 i2_wb_ack_o,
 output   wire                 i2_wb_err_o,
 output   wire                 i3_wb_ack_o,
 output   wire                 i3_wb_err_o,
 output   wire                 i4_wb_ack_o,
 output   wire                 i4_wb_err_o,
 output   wire                 i5_wb_ack_o,
 output   wire                 i5_wb_err_o,
 output   wire                 i6_wb_ack_o,
 output   wire                 i6_wb_err_o,
 output   wire                 i7_wb_ack_o,
 output   wire                 i7_wb_err_o,
 output   wire                 t0_wb_cyc_o,
 output   wire                 t0_wb_stb_o,
 output   wire                 t0_wb_we_o,
 output   wire    [ 3 :  0]        t0_wb_sel_o,
 output   wire    [ 31 :  0]        i0_wb_dat_o,
 output   wire    [ 31 :  0]        i1_wb_dat_o,
 output   wire    [ 31 :  0]        i2_wb_dat_o,
 output   wire    [ 31 :  0]        i3_wb_dat_o,
 output   wire    [ 31 :  0]        i4_wb_dat_o,
 output   wire    [ 31 :  0]        i5_wb_dat_o,
 output   wire    [ 31 :  0]        i6_wb_dat_o,
 output   wire    [ 31 :  0]        i7_wb_dat_o,
 output   wire    [ 31 :  0]        t0_wb_adr_o,
 output   wire    [ 31 :  0]        t0_wb_dat_o);
localparam            tc_iin_w=wb_addr_width + wb_data_width+wb_byte_lanes+4;
localparam            tc_tin_w=wb_data_width+2;
//
// Internal wires & registers
//
wire	[tc_iin_w-1:0]	i0_in, i1_in,
			i2_in, i3_in,
			i4_in, i5_in,
			i6_in, i7_in;
wire	[tc_tin_w-1:0]	i0_out, i1_out,
			i2_out, i3_out,
			i4_out, i5_out,
			i6_out, i7_out;
wire	[tc_iin_w-1:0]	t0_out;
wire	[tc_tin_w-1:0]	t0_in;
wire	[7:0]		req_i;
wire	[2:0]		req_won;
reg			req_cont;
reg	[2:0]		req_r;
//
// Group WB initiator 0 i/f inputs and outputs
//
assign i0_in = {i0_wb_cyc_i, i0_wb_stb_i, i0_wb_adr_i,i0_wb_sel_i, i0_wb_we_i, i0_wb_dat_i};
assign {i0_wb_dat_o, i0_wb_ack_o, i0_wb_err_o} = i0_out;
//
// Group WB initiator 1 i/f inputs and outputs
//
assign i1_in = {i1_wb_cyc_i, i1_wb_stb_i, i1_wb_adr_i,i1_wb_sel_i, i1_wb_we_i, i1_wb_dat_i};
assign {i1_wb_dat_o, i1_wb_ack_o, i1_wb_err_o} = i1_out;
//
// Group WB initiator 2 i/f inputs and outputs
//
assign i2_in = {i2_wb_cyc_i, i2_wb_stb_i, i2_wb_adr_i,i2_wb_sel_i, i2_wb_we_i, i2_wb_dat_i};
assign {i2_wb_dat_o, i2_wb_ack_o, i2_wb_err_o} = i2_out;
//
// Group WB initiator 3 i/f inputs and outputs
//
assign i3_in = {i3_wb_cyc_i, i3_wb_stb_i, i3_wb_adr_i,i3_wb_sel_i, i3_wb_we_i, i3_wb_dat_i};
assign {i3_wb_dat_o, i3_wb_ack_o, i3_wb_err_o} = i3_out;
//
// Group WB initiator 4 i/f inputs and outputs
//
assign i4_in = {i4_wb_cyc_i, i4_wb_stb_i, i4_wb_adr_i,i4_wb_sel_i, i4_wb_we_i, i4_wb_dat_i};
assign {i4_wb_dat_o, i4_wb_ack_o, i4_wb_err_o} = i4_out;
//
// Group WB initiator 5 i/f inputs and outputs
//
assign i5_in = {i5_wb_cyc_i, i5_wb_stb_i, i5_wb_adr_i,i5_wb_sel_i, i5_wb_we_i, i5_wb_dat_i};
assign {i5_wb_dat_o, i5_wb_ack_o, i5_wb_err_o} = i5_out;
//
// Group WB initiator 6 i/f inputs and outputs
//
assign i6_in = {i6_wb_cyc_i, i6_wb_stb_i, i6_wb_adr_i,i6_wb_sel_i, i6_wb_we_i, i6_wb_dat_i};
assign {i6_wb_dat_o, i6_wb_ack_o, i6_wb_err_o} = i6_out;
//
// Group WB initiator 7 i/f inputs and outputs
//
assign i7_in = {i7_wb_cyc_i, i7_wb_stb_i, i7_wb_adr_i,i7_wb_sel_i, i7_wb_we_i, i7_wb_dat_i};
assign {i7_wb_dat_o, i7_wb_ack_o, i7_wb_err_o} = i7_out;
//
// Group WB target 0 i/f inputs and outputs
//
assign {t0_wb_cyc_o, t0_wb_stb_o, t0_wb_adr_o,t0_wb_sel_o, t0_wb_we_o, t0_wb_dat_o} = t0_out;
assign t0_in = {t0_wb_dat_i, t0_wb_ack_i, t0_wb_err_i};
//
// Assign to WB initiator i/f outputs
//
// Either inputs from the target are assigned or zeros.
//
assign i0_out = (req_won == 3'd0) ? t0_in : {tc_tin_w{1'b0}};
assign i1_out = (req_won == 3'd1) ? t0_in : {tc_tin_w{1'b0}};
assign i2_out = (req_won == 3'd2) ? t0_in : {tc_tin_w{1'b0}};
assign i3_out = (req_won == 3'd3) ? t0_in : {tc_tin_w{1'b0}};
assign i4_out = (req_won == 3'd4) ? t0_in : {tc_tin_w{1'b0}};
assign i5_out = (req_won == 3'd5) ? t0_in : {tc_tin_w{1'b0}};
assign i6_out = (req_won == 3'd6) ? t0_in : {tc_tin_w{1'b0}};
assign i7_out = (req_won == 3'd7) ? t0_in : {tc_tin_w{1'b0}};
//
// Assign to WB target i/f outputs
//
// Assign inputs from initiator to target outputs according to
// which initiator has won. If there is no request for the target,
// assign zeros.
//
assign t0_out = (req_won == 3'd0) ? i0_in :
		(req_won == 3'd1) ? i1_in :
		(req_won == 3'd2) ? i2_in :
		(req_won == 3'd3) ? i3_in :
		(req_won == 3'd4) ? i4_in :
		(req_won == 3'd5) ? i5_in :
		(req_won == 3'd6) ? i6_in :
		(req_won == 3'd7) ? i7_in : {tc_iin_w{1'b0}};
//
// Determine if an initiator has address of the target.
//
assign req_i[0] = i0_wb_cyc_i &
	((i0_wb_adr_i[wb_addr_width-1:wb_addr_width-t0_addr_w] == t0_addr) |
	 multitarg & (i0_wb_adr_i[wb_addr_width-1:wb_addr_width-t17_addr_w] == t17_addr));
assign req_i[1] = i1_wb_cyc_i &
	((i1_wb_adr_i[wb_addr_width-1:wb_addr_width-t0_addr_w] == t0_addr) |
	 multitarg & (i1_wb_adr_i[wb_addr_width-1:wb_addr_width-t17_addr_w] == t17_addr));
assign req_i[2] = i2_wb_cyc_i &
	((i2_wb_adr_i[wb_addr_width-1:wb_addr_width-t0_addr_w] == t0_addr) |
	 multitarg & (i2_wb_adr_i[wb_addr_width-1:wb_addr_width-t17_addr_w] == t17_addr));
assign req_i[3] = i3_wb_cyc_i &
	((i3_wb_adr_i[wb_addr_width-1:wb_addr_width-t0_addr_w] == t0_addr) |
	 multitarg & (i3_wb_adr_i[wb_addr_width-1:wb_addr_width-t17_addr_w] == t17_addr));
assign req_i[4] = i4_wb_cyc_i &
	((i4_wb_adr_i[wb_addr_width-1:wb_addr_width-t0_addr_w] == t0_addr) |
	 multitarg & (i4_wb_adr_i[wb_addr_width-1:wb_addr_width-t17_addr_w] == t17_addr));
assign req_i[5] = i5_wb_cyc_i &
	((i5_wb_adr_i[wb_addr_width-1:wb_addr_width-t0_addr_w] == t0_addr) |
	 multitarg & (i5_wb_adr_i[wb_addr_width-1:wb_addr_width-t17_addr_w] == t17_addr));
assign req_i[6] = i6_wb_cyc_i &
	((i6_wb_adr_i[wb_addr_width-1:wb_addr_width-t0_addr_w] == t0_addr) |
	 multitarg & (i6_wb_adr_i[wb_addr_width-1:wb_addr_width-t17_addr_w] == t17_addr));
assign req_i[7] = i7_wb_cyc_i &
	((i7_wb_adr_i[wb_addr_width-1:wb_addr_width-t0_addr_w] == t0_addr) |
	 multitarg & (i7_wb_adr_i[wb_addr_width-1:wb_addr_width-t17_addr_w] == t17_addr));
//
// Determine who gets current access to the target.
//
// If current initiator still asserts request, do nothing
// (keep current initiator).
// Otherwise check each initiator's request, starting from initiator 0
// (highest priority).
// If there is no requests from initiators, park initiator 0.
//
assign req_won = req_cont ? req_r :
		 req_i[0] ? 3'd0 :
		 req_i[1] ? 3'd1 :
		 req_i[2] ? 3'd2 :
		 req_i[3] ? 3'd3 :
		 req_i[4] ? 3'd4 :
		 req_i[5] ? 3'd5 :
		 req_i[6] ? 3'd6 :
		 req_i[7] ? 3'd7 : 3'd0;
//
// Check if current initiator still wants access to the target and if
// it does, assert req_cont.
//
always @(req_r or req_i)
	case (req_r)	// synopsys parallel_case
		3'd0: req_cont = req_i[0];
		3'd1: req_cont = req_i[1];
		3'd2: req_cont = req_i[2];
		3'd3: req_cont = req_i[3];
		3'd4: req_cont = req_i[4];
		3'd5: req_cont = req_i[5];
		3'd6: req_cont = req_i[6];
		3'd7: req_cont = req_i[7];
	endcase
//
// Register who has current access to the target.
//
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		req_r <=   3'd0;
	else
		req_r <=   req_won;
  endmodule
