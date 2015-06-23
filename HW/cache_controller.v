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
// 8 lines of 256bytes each
// preloaded with bootstrap code (last 4 lines)
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps


module cache_controller(
    input [19:0] addr,
    output [31:0] dout,
	 input [31:0]din,
	 input clk,	// 3xCLK
	 input mreq,
	 input wr,
	 input [3:0]wmask,
	 output ce,	// clock enable for CPU
	 input [31:0]ddr_din,
	 output [31:0]ddr_dout,
	 input ddr_clk,
	 input cache_write_data, // 1 when data must be written to cache, on posedge ddr_clk
	 input [5:0]lowaddr,
	 output reg ddr_rd = 0,
	 output reg ddr_wr = 0,
	 output reg [11:0] waddr
    );
	
	wire [7:0]fit;
	wire [7:0]free;
	reg [15:0]cache0 = 16'h0000; // 8'b:addr, 3'b:count, 1'b:dirty
	reg [15:0]cache1 = 16'h0012; // 8'b:addr, 3'b:count, 1'b:dirty
	reg [15:0]cache2 = 16'h0024; // 8'b:addr, 3'b:count, 1'b:dirty
	reg [15:0]cache3 = 16'h0036; // 8'b:addr, 3'b:count, 1'b:dirty
	reg [15:0]cache4 = 16'hffc9; // 8'b:addr, 3'b:count, 1'b:dirty
	reg [15:0]cache5 = 16'hffdb; // 8'b:addr, 3'b:count, 1'b:dirty
	reg [15:0]cache6 = 16'hffed; // 8'b:addr, 3'b:count, 1'b:dirty
	reg [15:0]cache7 = 16'hffff; // 8'b:addr, 3'b:count, 1'b:dirty
	
	reg dirty;	
	reg [2:0]STATE = 0;
	reg ps_lowaddr5 = 0;
	reg s_lowaddr5 = 0;

	assign fit[0] = cache0[15:4] == addr[19:8];
	assign fit[1] = cache1[15:4] == addr[19:8];
	assign fit[2] = cache2[15:4] == addr[19:8];
	assign fit[3] = cache3[15:4] == addr[19:8];
	assign fit[4] = cache4[15:4] == addr[19:8];
	assign fit[5] = cache5[15:4] == addr[19:8];
	assign fit[6] = cache6[15:4] == addr[19:8];
	assign fit[7] = cache7[15:4] == addr[19:8];
	
	assign free[0] = cache0[3:1] == 3'b000;
   assign free[1] = cache1[3:1] == 3'b000;
   assign free[2] = cache2[3:1] == 3'b000;
   assign free[3] = cache3[3:1] == 3'b000;
   assign free[4] = cache4[3:1] == 3'b000;
   assign free[5] = cache5[3:1] == 3'b000;
   assign free[6] = cache6[3:1] == 3'b000;
   assign free[7] = cache7[3:1] == 3'b000;

	wire hit = |fit;
	wire st0 = STATE == 0;
	assign ce = st0 && (~mreq || hit);

	wire [2:0]blk =  {fit[4] | fit[5] | fit[6] | fit[7], fit[2] | fit[3] | fit[6] | fit[7], fit[1] | fit[3] | fit[5] | fit[7]};
	wire [2:0]fblk = {free[4] | free[5] | free[6] | free[7], free[2] | free[3] | free[6] | free[7], free[1] | free[3] | free[5] | free[7]};
	wire [2:0]csblk = ({3{fit[0]}} & cache0[3:1]) | ({3{fit[1]}} & cache1[3:1]) |
							({3{fit[2]}} & cache2[3:1]) | ({3{fit[3]}} & cache3[3:1]) |
							({3{fit[4]}} & cache4[3:1]) | ({3{fit[5]}} & cache5[3:1]) |
							({3{fit[6]}} & cache6[3:1]) | ({3{fit[7]}} & cache7[3:1]);
	
	cache cache_mem (
	  .clka(ddr_clk), // input clka
	  .wea({4{cache_write_data}}), // input [3 : 0] wea
	  .addra({blk, lowaddr}), // input [8 : 0] addra
	  .dina(ddr_din), // input [31 : 0] dina
	  .douta(ddr_dout), // output [31 : 0] douta
	  .clkb(clk), // input clkb
	  .enb(mreq & hit & st0),
	  .web(wmask), // input [3 : 0] web
	  .addrb({blk, addr[7:2]}), // input [8 : 0] addrb
	  .dinb(din), // input [31 : 0] dinb
	  .doutb(dout) // output [31 : 0] doutb
	);
	
	
	always @(cache0, cache1, cache2, cache3, cache4, cache5, cache6, cache7) begin
		dirty = 1'bx;
		case(1)
			free[0]: begin dirty = cache0[0]; end		
			free[1]:	begin dirty = cache1[0]; end
			free[2]:	begin dirty = cache2[0]; end
			free[3]:	begin dirty = cache3[0]; end
			free[4]:	begin dirty = cache4[0]; end
			free[5]:	begin dirty = cache5[0]; end
			free[6]:	begin dirty = cache6[0]; end
			free[7]:	begin dirty = cache7[0]; end
		endcase
	end
	

	always @(posedge clk) begin
		ps_lowaddr5 <= lowaddr[5];
		s_lowaddr5 <= ps_lowaddr5;
		
		case(STATE)
			3'b000: begin
				if(mreq) begin
					if(hit) begin	// cache hit
						cache0[3:1] <= fit[0] ? 3'b111 : cache0[3:1] - (cache0[3:1] > csblk); 
						cache1[3:1] <= fit[1] ? 3'b111 : cache1[3:1] - (cache1[3:1] > csblk); 
						cache2[3:1] <= fit[2] ? 3'b111 : cache2[3:1] - (cache2[3:1] > csblk); 
						cache3[3:1] <= fit[3] ? 3'b111 : cache3[3:1] - (cache3[3:1] > csblk); 
						cache4[3:1] <= fit[4] ? 3'b111 : cache4[3:1] - (cache4[3:1] > csblk); 
						cache5[3:1] <= fit[5] ? 3'b111 : cache5[3:1] - (cache5[3:1] > csblk); 
						cache6[3:1] <= fit[6] ? 3'b111 : cache6[3:1] - (cache6[3:1] > csblk); 
						cache7[3:1] <= fit[7] ? 3'b111 : cache7[3:1] - (cache7[3:1] > csblk); 
					end else begin	// cache miss
						case(fblk)	// free block
							0:	begin waddr <= cache0[15:4]; cache0[15:4] <= addr[19:8]; end
							1:	begin waddr <= cache1[15:4]; cache1[15:4] <= addr[19:8]; end
							2:	begin waddr <= cache2[15:4]; cache2[15:4] <= addr[19:8]; end
							3:	begin waddr <= cache3[15:4]; cache3[15:4] <= addr[19:8]; end
							4:	begin waddr <= cache4[15:4]; cache4[15:4] <= addr[19:8]; end
							5:	begin waddr <= cache5[15:4]; cache5[15:4] <= addr[19:8]; end
							6:	begin waddr <= cache6[15:4]; cache6[15:4] <= addr[19:8]; end
							7:	begin waddr <= cache7[15:4]; cache7[15:4] <= addr[19:8]; end
						endcase
						ddr_rd <= ~dirty;
						ddr_wr <= dirty;
						STATE <= dirty ? 3'b011 : 3'b100;
					end
					if(hit) case(1) // free or hit block
						fit[0]: cache0[0] <= (cache0[0] | wr);
						fit[1]: cache1[0] <= (cache1[0] | wr);
						fit[2]: cache2[0] <= (cache2[0] | wr);
						fit[3]: cache3[0] <= (cache3[0] | wr);
						fit[4]: cache4[0] <= (cache4[0] | wr);
						fit[5]: cache5[0] <= (cache5[0] | wr);
						fit[6]: cache6[0] <= (cache6[0] | wr);
						fit[7]: cache7[0] <= (cache7[0] | wr);
					endcase else case(1)
						free[0]: cache0[0] <= 0;
						free[1]: cache1[0] <= 0;
						free[2]: cache2[0] <= 0;
						free[3]: cache3[0] <= 0;
						free[4]: cache4[0] <= 0;
						free[5]: cache5[0] <= 0;
						free[6]: cache6[0] <= 0;
						free[7]: cache7[0] <= 0;
					endcase				
				end
			end
			3'b011: begin	// write cache to ddr
				ddr_rd <= 1'b1;
				if(s_lowaddr5) begin
					ddr_wr <= 1'b0;
					STATE <= 3'b111;
				end
			end
			3'b111: begin // read cache from ddr
				if(~s_lowaddr5) STATE <= 3'b100;
			end
			3'b100: begin	
				if(s_lowaddr5) STATE <= 3'b101;
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
	 input [3:0]addr,
	 output [9:0]rdata,
	 input [9:0]wdata,
	 input [3:0]addr1,
	 output [9:0]data1,
	 input WE
    );

 RAM16X1D #(.INIT(16'haaaa) ) RAM16X1D_inst0 
 (
      .DPO(data1[0]),     // Read-only 1-bit data output for DPRA
      .SPO(rdata[0]),     // Rw/ 1-bit data output for A0-A3
      .A0(addr[0]),       // Rw/ address[0] input bit
      .A1(addr[1]),       // Rw/ address[1] input bit
      .A2(addr[2]),       // Rw/ address[2] input bit
      .A3(addr[3]),       // Rw/ address[3] input bit
      .D(wdata[0]),         // Write 1-bit data input
      .DPRA0(addr1[0]), // Read address[0] input bit
      .DPRA1(addr1[1]), // Read address[1] input bit
      .DPRA2(addr1[2]), // Read address[2] input bit
      .DPRA3(addr1[3]), // Read address[3] input bit
      .WCLK(CLK),   // Write clock input
      .WE(WE)        // Write enable input
   );	
	
 RAM16X1D #(.INIT(16'hcccc) ) RAM16X1D_inst1
 (
      .DPO(data1[1]),     // Read-only 1-bit data output for DPRA
      .SPO(rdata[1]),     // Rw/ 1-bit data output for A0-A3
      .A0(addr[0]),       // Rw/ address[0] input bit
      .A1(addr[1]),       // Rw/ address[1] input bit
      .A2(addr[2]),       // Rw/ address[2] input bit
      .A3(addr[3]),       // Rw/ address[3] input bit
      .D(wdata[1]),         // Write 1-bit data input
      .DPRA0(addr1[0]), // Read address[0] input bit
      .DPRA1(addr1[1]), // Read address[1] input bit
      .DPRA2(addr1[2]), // Read address[2] input bit
      .DPRA3(addr1[3]), // Read address[3] input bit
      .WCLK(CLK),   // Write clock input
      .WE(WE)        // Write enable input
   );	

 RAM16X1D #(.INIT(16'hf0f0) ) RAM16X1D_inst2 
 (
      .DPO(data1[2]),     // Read-only 1-bit data output for DPRA
      .SPO(rdata[2]),     // Rw/ 1-bit data output for A0-A3
      .A0(addr[0]),       // Rw/ address[0] input bit
      .A1(addr[1]),       // Rw/ address[1] input bit
      .A2(addr[2]),       // Rw/ address[2] input bit
      .A3(addr[3]),       // Rw/ address[3] input bit
      .D(wdata[2]),         // Write 1-bit data input
      .DPRA0(addr1[0]), // Read address[0] input bit
      .DPRA1(addr1[1]), // Read address[1] input bit
      .DPRA2(addr1[2]), // Read address[2] input bit
      .DPRA3(addr1[3]), // Read address[3] input bit
      .WCLK(CLK),   // Write clock input
      .WE(WE)        // Write enable input
   );	

 RAM16X1D #(.INIT(16'hff00) ) RAM16X1D_inst3 
 (
      .DPO(data1[3]),     // Read-only 1-bit data output for DPRA
      .SPO(rdata[3]),     // Rw/ 1-bit data output for A0-A3
      .A0(addr[0]),       // Rw/ address[0] input bit
      .A1(addr[1]),       // Rw/ address[1] input bit
      .A2(addr[2]),       // Rw/ address[2] input bit
      .A3(addr[3]),       // Rw/ address[3] input bit
      .D(wdata[3]),         // Write 1-bit data input
      .DPRA0(addr1[0]), // Read address[0] input bit
      .DPRA1(addr1[1]), // Read address[1] input bit
      .DPRA2(addr1[2]), // Read address[2] input bit
      .DPRA3(addr1[3]), // Read address[3] input bit
      .WCLK(CLK),   // Write clock input
      .WE(WE)        // Write enable input
   );	


 RAM16X1D #(.INIT(16'h0000) ) RAM16X1D_inst4 
 (
      .DPO(data1[4]),     // Read-only 1-bit data output for DPRA
      .SPO(rdata[4]),     // Rw/ 1-bit data output for A0-A3
      .A0(addr[0]),       // Rw/ address[0] input bit
      .A1(addr[1]),       // Rw/ address[1] input bit
      .A2(addr[2]),       // Rw/ address[2] input bit
      .A3(addr[3]),       // Rw/ address[3] input bit
      .D(wdata[4]),         // Write 1-bit data input
      .DPRA0(addr1[0]), // Read address[0] input bit
      .DPRA1(addr1[1]), // Read address[1] input bit
      .DPRA2(addr1[2]), // Read address[2] input bit
      .DPRA3(addr1[3]), // Read address[3] input bit
      .WCLK(CLK),   // Write clock input
      .WE(WE)        // Write enable input
   );	

 RAM16X1D #(.INIT(16'h0000) ) RAM16X1D_inst5 
 (
      .DPO(data1[5]),     // Read-only 1-bit data output for DPRA
      .SPO(rdata[5]),     // Rw/ 1-bit data output for A0-A3
      .A0(addr[0]),       // Rw/ address[0] input bit
      .A1(addr[1]),       // Rw/ address[1] input bit
      .A2(addr[2]),       // Rw/ address[2] input bit
      .A3(addr[3]),       // Rw/ address[3] input bit
      .D(wdata[5]),         // Write 1-bit data input
      .DPRA0(addr1[0]), // Read address[0] input bit
      .DPRA1(addr1[1]), // Read address[1] input bit
      .DPRA2(addr1[2]), // Read address[2] input bit
      .DPRA3(addr1[3]), // Read address[3] input bit
      .WCLK(CLK),   // Write clock input
      .WE(WE)        // Write enable input
   );	

 RAM16X1D #(.INIT(16'h0000) ) RAM16X1D_inst6 
 (
      .DPO(data1[6]),     // Read-only 1-bit data output for DPRA
      .SPO(rdata[6]),     // Rw/ 1-bit data output for A0-A3
      .A0(addr[0]),       // Rw/ address[0] input bit
      .A1(addr[1]),       // Rw/ address[1] input bit
      .A2(addr[2]),       // Rw/ address[2] input bit
      .A3(addr[3]),       // Rw/ address[3] input bit
      .D(wdata[6]),         // Write 1-bit data input
      .DPRA0(addr1[0]), // Read address[0] input bit
      .DPRA1(addr1[1]), // Read address[1] input bit
      .DPRA2(addr1[2]), // Read address[2] input bit
      .DPRA3(addr1[3]), // Read address[3] input bit
      .WCLK(CLK),   // Write clock input
      .WE(WE)        // Write enable input
   );	

 RAM16X1D #(.INIT(16'h0000) ) RAM16X1D_inst7 
 (
      .DPO(data1[7]),     // Read-only 1-bit data output for DPRA
      .SPO(rdata[7]),     // Rw/ 1-bit data output for A0-A3
      .A0(addr[0]),       // Rw/ address[0] input bit
      .A1(addr[1]),       // Rw/ address[1] input bit
      .A2(addr[2]),       // Rw/ address[2] input bit
      .A3(addr[3]),       // Rw/ address[3] input bit
      .D(wdata[7]),         // Write 1-bit data input
      .DPRA0(addr1[0]), // Read address[0] input bit
      .DPRA1(addr1[1]), // Read address[1] input bit
      .DPRA2(addr1[2]), // Read address[2] input bit
      .DPRA3(addr1[3]), // Read address[3] input bit
      .WCLK(CLK),   // Write clock input
      .WE(WE)        // Write enable input
   );	

 RAM16X1D #(.INIT(16'h0000) ) RAM16X1D_inst8 
 (
      .DPO(data1[8]),     // Read-only 1-bit data output for DPRA
      .SPO(rdata[8]),     // Rw/ 1-bit data output for A0-A3
      .A0(addr[0]),       // Rw/ address[0] input bit
      .A1(addr[1]),       // Rw/ address[1] input bit
      .A2(addr[2]),       // Rw/ address[2] input bit
      .A3(addr[3]),       // Rw/ address[3] input bit
      .D(wdata[8]),         // Write 1-bit data input
      .DPRA0(addr1[0]), // Read address[0] input bit
      .DPRA1(addr1[1]), // Read address[1] input bit
      .DPRA2(addr1[2]), // Read address[2] input bit
      .DPRA3(addr1[3]), // Read address[3] input bit
      .WCLK(CLK),   // Write clock input
      .WE(WE)        // Write enable input
   );	

 RAM16X1D #(.INIT(16'h0000) ) RAM16X1D_inst9 
 (
      .DPO(data1[9]),     // Read-only 1-bit data output for DPRA
      .SPO(rdata[9]),     // Rw/ 1-bit data output for A0-A3
      .A0(addr[0]),       // Rw/ address[0] input bit
      .A1(addr[1]),       // Rw/ address[1] input bit
      .A2(addr[2]),       // Rw/ address[2] input bit
      .A3(addr[3]),       // Rw/ address[3] input bit
      .D(wdata[9]),         // Write 1-bit data input
      .DPRA0(addr1[0]), // Read address[0] input bit
      .DPRA1(addr1[1]), // Read address[1] input bit
      .DPRA2(addr1[2]), // Read address[2] input bit
      .DPRA3(addr1[3]), // Read address[3] input bit
      .WCLK(CLK),   // Write clock input
      .WE(WE)        // Write enable input
   );	
endmodule
