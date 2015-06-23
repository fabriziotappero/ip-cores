//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 Soc PC project
// http://opencores.org/project,next186
//
// Filename: cache_controller.v
// Description: Part of the Next186 SoC PC project, cache controller
// Version 1.0
// Creation date: Jan2012
//
// Author: Nicolae Dumitrache 
// e-mail: ndumitrache@opencores.org
//
/////////////////////////////////////////////////////////////////////////////////
// 
// Copyright (C) 2012 Nicolae Dumitrache
// 
// This source file may be used and distributed without 
// restriction provided that this copyright statement is not 
// removed from the file and that any derivative work contains 
// the original copyright notice and the associated disclaimer.
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
// PURPOSE. See the GNU Lesser General Public License for more 
// details. 
// 
// You should have received a copy of the GNU Lesser General 
// Public License along with this source; if not, download it 
// from http://www.opencores.org/lgpl.shtml 
// 
///////////////////////////////////////////////////////////////////////////////////
// Additional Comments: 
//
// preloaded with bootstrap code
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`define WAYS	2	// 2^ways
`define SETS	4	// 2^sets

module cache_controller(
	 input [20:0] addr,
     output [31:0] dout,
	 input [31:0]din,
	 input clk,	
	 input mreq,
	 input [3:0]wmask,
	 output ce,	// clock enable for CPU
	 input [15:0]ddr_din,
	 output reg[15:0]ddr_dout,
	 input ddr_clk,
	 input cache_write_data, // 1 when data must be written to cache, on posedge ddr_clk
	 input cache_read_data, // 1 when data must be read from cache, on posedge ddr_clk
	 output reg ddr_rd = 0,
	 output reg ddr_wr = 0,
	 output reg [12:0] waddr,
	 input flush
    );
	
	reg flushreq = 1'b0;
	reg [`WAYS+`SETS:0]flushcount = 0;
	wire r_flush = flushcount[`WAYS+`SETS];
	wire [`SETS-1:0]index = r_flush ? flushcount[`SETS-1:0] : addr[8+`SETS-1:8];
	wire [(1<<`WAYS)-1:0]fit;
	wire [(1<<`WAYS)-1:0]free;
	wire wr = |wmask;
	
	reg [(1<<`WAYS)-1:0]cache_dirty[0:(1<<`SETS)-1] = 
		{4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h1, 4'h1, 4'h1, 4'h1};
	reg [`WAYS-1:0]cache_lru[0:(1<<`WAYS)-1][0:(1<<`SETS)-1] =
		{{2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
		 {2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1},
		 {2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2},
		 {2'h3, 2'h3, 2'h3, 2'h3, 2'h3, 2'h3, 2'h3, 2'h3, 2'h3, 2'h3, 2'h3, 2'h3, 2'h3, 2'h3, 2'h3, 2'h3}};
	reg [12-`SETS:0]cache_addr[0:(1<<`WAYS)-1][0:(1<<`SETS)-1]=
		{{9'h000, 9'h000, 9'h000, 9'h000, 9'h000, 9'h000, 9'h000, 9'h000, 9'h000, 9'h000, 9'h000, 9'h000, 9'h0ff, 9'h0ff, 9'h0ff, 9'h0ff},
		 {9'h001, 9'h001, 9'h001, 9'h001, 9'h001, 9'h001, 9'h001, 9'h001, 9'h001, 9'h001, 9'h001, 9'h001, 9'h000, 9'h000, 9'h000, 9'h000},
		 {9'h002, 9'h002, 9'h002, 9'h002, 9'h002, 9'h002, 9'h002, 9'h002, 9'h002, 9'h002, 9'h002, 9'h002, 9'h001, 9'h001, 9'h001, 9'h001},
		 {9'h003, 9'h003, 9'h003, 9'h003, 9'h003, 9'h003, 9'h003, 9'h003, 9'h003, 9'h003, 9'h003, 9'h003, 9'h002, 9'h002, 9'h002, 9'h002}};
	
	reg [2:0]STATE = 0;
	reg [6:0]lowaddr = 0; //cache mem address
	reg s_lowaddr5 = 0;
	wire [31:0]cache_QA;
	wire [`WAYS-1:0]lru[(1<<`WAYS)-1:0];

	genvar i;
	for(i=0; i<(1<<`WAYS); i=i+1) begin
		assign fit[i] = ~r_flush && (cache_addr[i][index] == addr[20:8+`SETS]);
		assign free[i] = r_flush ? (flushcount[`WAYS+`SETS-1:`SETS] == i) : ~|cache_lru[i][index];
		assign lru[i] = {`WAYS{fit[i]}} & cache_lru[i][index];
	end

	wire hit = |fit;
	wire st0 = STATE == 3'b000;
	assign ce = st0 && (~mreq || hit);
	wire dirty = |(free & cache_dirty[index]);	

	wire [`WAYS-1:0]blk = flushcount[`WAYS+`SETS-1:`SETS] | {|fit[3:2], fit[3] | fit[1]};
	wire [`WAYS-1:0]fblk = {|free[3:2], free[3] | free[1]};
	wire [`WAYS-1:0]csblk = lru[0] | lru[1] | lru[2] | lru[3];

	always @(posedge ddr_clk) begin
		if(cache_write_data || cache_read_data) lowaddr <= lowaddr + 1;
		ddr_dout <= lowaddr[0] ? cache_QA[15:0] : cache_QA[31:16];
	end
		
	cache cache_mem
	(
		.clka(ddr_clk), // input clka
		.ena(cache_write_data | cache_read_data), // input ena
		.wea({4{cache_write_data}} & {lowaddr[0], lowaddr[0], ~lowaddr[0], ~lowaddr[0]}), // input [3 : 0] wea
		.addra({blk, ~index[`SETS-1:2], index[1:0], lowaddr[6:1]}), // input [11 : 0] addra
		.dina({ddr_din, ddr_din}), // input [31 : 0] dina
		.douta(cache_QA), // output [31 : 0] douta
		.clkb(clk), // input clkb
		.enb(mreq & hit & st0), // input enb
		.web({4{mreq & hit & st0 & wr}} & wmask), // input [3 : 0] web
		.addrb({blk, ~index[`SETS-1:2], index[1:0], addr[7:2]}), // input [11 : 0] addrb
		.dinb(din), // input [31 : 0] dinb
		.doutb(dout) // output [31 : 0] doutb
	);


	for(i=0; i<(1<<`WAYS); i=i+1)
		always @(posedge clk)
			if(st0 && mreq)
				if(hit) begin
					cache_lru[i][index] <= fit[i] ? {`WAYS{1'b1}} : cache_lru[i][index] - (cache_lru[i][index] > csblk); 
					if(fit[i]) cache_dirty[index][i] <= cache_dirty[index][i] | wr;
				end else if(free[i]) cache_dirty[index][i] <= 1'b0;

		
	always @(posedge clk) begin
		s_lowaddr5 <= lowaddr[6];
		flushreq <= ~flushcount[`WAYS+`SETS] & (flushreq | flush);
		
		case(STATE)
			3'b000: begin
				if(mreq && !hit) begin	// cache miss
					waddr <= {cache_addr[fblk][index], index}; 
					if(!r_flush) cache_addr[fblk][index] <= addr[20:8+`SETS];
					ddr_rd <= ~dirty & ~r_flush;
					ddr_wr <= dirty;
					STATE <= dirty ? 3'b011 : 3'b100;
				end else flushcount[`WAYS+`SETS] <= flushcount[`WAYS+`SETS] | flushreq;
			end
			3'b011: begin	// write cache to ddr
				ddr_rd <= ~r_flush; //1'b1;
				if(s_lowaddr5) begin
					ddr_wr <= 1'b0;
					STATE <= 3'b111;
				end
			end
			3'b111: begin // read cache from ddr
				if(~s_lowaddr5) STATE <= 3'b100;
			end
			3'b100: begin	
				if(r_flush) begin
					flushcount <= flushcount + 1;
					STATE <= 3'b000;
				end else if(s_lowaddr5) STATE <= 3'b101;
			end
			3'b101: begin
				ddr_rd <= 1'b0;
				if(~s_lowaddr5) STATE <= 3'b000;
			end
		endcase
	end
	
endmodule


module seg_map(
	 input CLK,
	 input [3:0]cpuaddr,
	 output [8:0]cpurdata,
	 input [8:0]cpuwdata,
	 input [4:0]memaddr,
	 output [8:0]memdata,
	 input WE
    );

	reg [8:0]map[0:31] = {9'h000, 9'h001, 9'h002, 9'h003, 9'h004, 9'h005, 9'h006, 9'h007, 9'h008, 9'h009,
								 9'h00a, 9'h00b,	// VGA seg 1 and 2
								 9'h012, 9'h013, 9'h014, 9'h015,
								 9'h016,	// HMA
								 9'h001, 9'h002, 9'h003, 9'h004, 9'h005, 9'h006, 9'h007, 9'h008, 9'h009, 
								 9'h00a, 9'h00b, 9'h00c, 9'h00d, 9'h00e, 9'h00f}; // VGA seg 1..6								 
	assign memdata = map[memaddr];
	assign cpurdata = map[{1'b0, cpuaddr}];
//	initial $readmemh("segmap.mem", map);
	
	always @(posedge CLK) 
		if(WE) map[{1'b0, cpuaddr}] <= cpuwdata;

endmodule
