/*
 * rtc_timer_tb.v
 * 
 * Copyright (c) 2012, BABY&HW. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

`timescale 1ns/1ns

module rtc_timer_tb  ; 

  parameter time_acc_modulo = 38'd256000000000/1000000;

  reg rst;
  reg clk;
  wire         adj_ld_done;
  wire [37:0]  time_reg_ns;
  wire [47:0]  time_reg_sec;
  reg period_ld;
  reg [39:0]  period_in;
  reg adj_ld;
  reg [31:0]  adj_ld_data;
  reg [39:0]  period_adj;
  reg time_ld;
  reg [37:0] time_reg_ns_in;
  reg [47:0] time_reg_sec_in;
  rtc  
   DUT  ( 
      .rst (rst ) ,
      .clk (clk ) ,
      .time_ld (time_ld ) ,
      .time_reg_ns_in (time_reg_ns_in ) ,
      .time_reg_sec_in (time_reg_sec_in ) ,
      .time_reg_ns (time_reg_ns ) ,
      .time_reg_sec (time_reg_sec ) ,
      .time_one_pps ( ) ,
      .time_ptp_ns ( ) ,
      .time_ptp_sec ( ) ,
      .period_ld (period_ld ) ,
      .period_in (period_in ) ,
      .adj_ld (adj_ld ) ,
      .period_adj (period_adj ) ,
      .adj_ld_data (adj_ld_data ) ,
      .adj_ld_done ( ) ); 
  defparam DUT.time_acc_modulo = time_acc_modulo;


initial begin 
	clk = 1'b0;
	forever #4  clk = !clk;
end
initial begin 
	rst = 1'b0;
	@(posedge clk);
	rst = 1'b1;
	@(posedge clk);
	rst = 1'b0;
end

// main process
integer i;
initial begin

	/////////////////////////
	// reset default values
	/////////////////////////
	
	@(posedge rst);
	// frequency load
	period_ld        =  1'b0;
	period_in[39:32] =  8'h00;        // ns
	period_in[31: 0] = 32'h00000000;  // ns fraction
	// time load
	time_ld              =  1'b0;
	time_reg_ns_in[37:8] = 30'd0;          // ns
	time_reg_ns_in[ 7:0] =  8'h00;         // ns fraction
	time_reg_sec_in      = 48'd0;
	// time fine tune load
	adj_ld      =  1'b0;
	adj_ld_data = 32'd10;
	period_adj  = 40'h00_00000000;
	@(negedge rst);

	////////////////////
	// time adjustment
	////////////////////

	for (i=0; i<20; i=i+1) @(posedge clk);
	// load default period
        period_ld          =  1'b1;
	period_in[39:32]   =  8'h08;        // ns
	period_in[31: 0]   = 32'h00000000;  // ns fraction
	@(posedge clk);
        period_ld          =  1'b0;

	for (i=0; i<20; i=i+1) @(posedge clk);
	// load time ToD values
	time_ld              =  1'b1;
	time_reg_ns_in[37:8] = time_acc_modulo/256 - 30'd100;  // ns
	time_reg_ns_in[ 7:0] =  8'h00;         // ns fraction
	time_reg_sec_in      = 48'd10;
	@(posedge clk);
	time_ld              =  1'b0;
	
	for (i=0; i<20; i=i+1) @(posedge clk);
	// fine tune time difference by 0
	adj_ld            =  1'b1;
	adj_ld_data       = 32'd100;
	period_adj[39:32] =  8'h08;        // ns           // positive change
	period_adj[31: 0] = 32'h00000000;  // ns fraction
	@(posedge clk);
	adj_ld            =  1'b0;

	for (i=0; i<300; i=i+1) @(posedge clk);
	
	for (i=0; i<20; i=i+1) @(posedge clk);
	// fine tune time difference by 0
	adj_ld            =  1'b1;
	adj_ld_data       = 32'd100;
	period_adj[39:32] =  8'hfb;        // ns           // -5 negative change
	period_adj[31: 0] = 32'h00000000;  // ns fraction
	@(posedge clk);
	adj_ld            =  1'b0;

	for (i=0; i<300; i=i+1) @(posedge clk);
	
	for (i=0; i<20; i=i+1) @(posedge clk);
	// fine tune time difference by 0
	adj_ld            =  1'b1;
	adj_ld_data       = 32'd100;
	period_adj[39:32] =  8'hf0;        // ns           // -16 negative change
	period_adj[31: 0] = 32'h00000000;  // ns fraction
	@(posedge clk);
	adj_ld            =  1'b0;

	for (i=0; i<300; i=i+1) @(posedge clk);

	for (i=0; i<20; i=i+1) @(posedge clk);
	// fine tune frequency difference
        period_ld          =  1'b1;
	period_in[39:32]   =  8'h08;        // ns
	period_in[31: 0]   = 32'h10200000;  // ns fraction
	@(posedge clk);
        period_ld          =  1'b0;

	for (i=0; i<20; i=i+1) @(posedge clk);
	// fine tune time difference
	adj_ld            =  1'b1;
	adj_ld_data       = 32'd10;
	period_adj[39:32] =  8'h02;        // ns           // positive change
	period_adj[31: 0] = 32'h20800000;  // ns fraction
	@(posedge clk);
	adj_ld            =  1'b0;

	for (i=0; i<500; i=i+1) @(posedge clk);
	$stop;
end

// sec+ns watchpoint
wire [47:0] time_reg_sec_in_    = time_reg_sec_in[47:0];
wire [29:0] time_reg_ns_in_     = time_reg_ns_in[37:8];
wire [47:0] time_reg_sec_       = time_reg_sec[47:0];
wire [29:0] time_reg_ns_        = time_reg_ns[37:8];
wire [ 7:0] period_ns_          = period_in[39:32];
wire [ 7:0] period_adj_ns_      = period_adj[39:32];
wire        time_reg_sec_inc_   = DUT.time_acc_48s_inc;
// ns fraction watchpoint
wire [ 7:0] time_reg_ns_in_f     = time_reg_ns_in[7:0];
wire [ 7:0] time_reg_ns_f        = time_reg_ns[7:0];
wire [31:0] period_ns_f          = period_in[31:0];
wire [31:0] period_adj_ns_f      = period_adj[31:0];

// ns time incremental watchpoint
reg  [47:0] time_reg_sec__d1;
reg  [29:0] time_reg_ns__d1;
always @(posedge clk) begin
	time_reg_sec__d1 <= time_reg_sec_;
	time_reg_ns__d1  <= time_reg_ns_;
end
wire [29:0] time_reg_sec__delta = time_reg_sec_-time_reg_sec__d1;
wire [29:0] time_reg_ns__delta = (time_reg_sec__d1!=time_reg_sec_)?
				(DUT.time_acc_modulo/256-(time_reg_ns__d1-time_reg_ns_)):
				(time_reg_ns_-time_reg_ns__d1);
wire [37:0] time_acc_30n_08f_pre = DUT.time_acc_30n_08f_pre_pos - DUT.time_acc_30n_08f_pre_neg;

// Delta-Sigma circuit watchpoint
wire [23:0] time_adj_08n_32f_24f = rtc_timer_tb.DUT.time_adj_08n_32f[23:0];

endmodule

