`timescale 1ns / 1ps
//=============================================================================
//        __
//   \\__/ o\    (C) 2011,2012  Robert Finch
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//  
//	SimpleMMU.v
//  - maps 128MB into 512 256kB blocks
//  - supports 32 tasks per mmu
//  
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//                                                                          
//
// 20 block RAMs // 106 LUTs // 42 FF's // 190 MHz
//=============================================================================
//
module SimpleMMU(num, rst_i, clk_i, dma_i, kernel_mode, cyc_i, stb_i, ack_o, we_i, adr_i, dat_i, dat_o, rclk, pc_i, pc_o, ea_i, ea_o);
parameter pIOAddress = 24'hDC4000;
input [2:0] num;		// mmu number
input rst_i;			// core reset
input clk_i;			// clock
input dma_i;			// 1=DMA cycle is active
input kernel_mode;		// 1=processor is in kernel mode
input cyc_i;			// bus cycle active
input stb_i;			// data transfer strobe
output ack_o;			// data transfer acknowledge
input we_i;				// write enable
input [23:0] adr_i;		// I/O register address
input [15:0] dat_i;		// data input
output [15:0] dat_o;	// data output
reg [15:0] dat_o;
input rclk;				// read clock (~clk)
input [27:0] pc_i;		// program counter / instruction pointer input
output [27:0] pc_o;		// mapped version of program counter
reg [27:0] pc_o;
input [27:0] ea_i;		// effective data address input
output [27:0] ea_o;		// effective data address mapped
reg [27:0] ea_o;

reg map_enable;
reg forceHi;
reg su;					// 1= system
reg [3:0] fuse;
reg ofuse3;
reg [7:0] accessKey;
reg [7:0] operateKey;
reg [2:0] kvmmu;
reg ack1, ack2;

always @(posedge clk_i)
begin
	ack1 <= cs;
	ack2 <= ack1 & cs;
end
assign ack_o = cs ? (we_i ? 1'b1 : ack2) : 1'b0;

wire cs = cyc_i && stb_i && (adr_i[23:12]==pIOAddress[23:12]);
wire [7:0] oKey =
	dma_i ? 8'd1 :
	su ? 8'd0 :
	operateKey
	;
reg [13:0] rmrad;
reg [13:0] rmra;
reg [13:0] rmrb;
wire [13:0] mwa = {accessKey[4:0],adr_i[9:1]};
wire [13:0] mrad = {accessKey[4:0],adr_i[9:1]};
wire [13:0] mra = {oKey[4:0],pc_i[26:18]};
wire [13:0] mrb = {oKey[4:0],ea_i[26:18]};
wire [9:0] mro0,mro1,mro2;

always @(posedge clk_i) rmrad <= mrad;
always @(posedge rclk) rmra <= mra;
always @(posedge rclk) rmrb <= mrb;
wire thisMMU = kvmmu==accessKey[7:5];

wire pe_stb;
wire pe_km;
edge_det u1 (.rst(rst_i), .clk(clk_i), .ce(1'b1), .i(stb_i), .pe(pe_stb), .ne(), .ee() );
edge_det u2 (.rst(rst_i), .clk(clk_i), .ce(1'b1), .i(kernel_mode), .pe(pe_km), .ne(), .ee() );

mapram u3
(
	.wclk(clk_i),
	.wr(cs & we_i & su & ~adr_i[10] & thisMMU),
	.wa(mwa),
	.i(dat_i[9:0]),
	.rclk(~clk_i),
	.ra0(mrad),
	.ra1(mra),
	.ra2(mrb),
	.o0(mro0),
	.o1(mro1),
	.o2(mro2)
);

always @(posedge clk_i)
if (rst_i) begin
	map_enable <= 1'b0;
	kvmmu <= 3'd0;
	su <= 1'b1;
	fuse <= 4'hF;
	ofuse3 <= 1'b1;
	accessKey <= 8'h00;
	operateKey <= 8'h00;
end
else begin
	ofuse3 <= fuse[3];
	if (!fuse[3] && !dma_i && pe_stb)
		fuse <= fuse - 4'd1;
	if (fuse[3] & !ofuse3)
		su <= 1'b0;
	else if (pe_km)
		su <= 1'b1;

	if (cs) begin
		if (we_i) begin
			if (su) begin
				casex(adr_i[10:0])
//				11'b0xxxxxxxxxx:	if (thisMMU) map[mwa] <= dat_i[9:0];
				11'h40x:	if (oKey==8'h00 && (adr_i[2:0]==num))
									kvmmu <= dat_i[2:0];
				11'h412:	fuse <= dat_i[2:0];
				11'h414:	accessKey <= dat_i[7:0];
				11'h416:	operateKey <= dat_i[7:0];
				11'h418:	map_enable <= dat_i[0];
				endcase
			end
		end
		else begin
			if ((adr_i[2:0]==num) && oKey==8'd0 && adr_i[10:4]==7'b1000000)
				dat_o <= {5'd0,kvmmu};
			else if (thisMMU)
				casex(adr_i[10:0])
				11'b0xxxxxxxxxx:	dat_o <= mro0;
				11'h410:	dat_o <= su;
				11'h412:	dat_o <= fuse;
				11'h414:	dat_o <= accessKey;
				11'h416:	dat_o <= operateKey;
				11'h418:	dat_o <= map_enable;
				default:	dat_o <= 16'h0000;
				endcase
			else
				dat_o <= 16'h0000;
		end
	end
	else
		dat_o <= 16'h0000;
end

always @(pc_i) pc_o[17:0] <= pc_i[17:0];
always @(ea_i) ea_o[17:0] <= ea_i[17:0];

always @(rmra or oKey or kvmmu or mro1 or cs or map_enable)
begin
	if (!map_enable)
		pc_o[27:18] <= pc_i[27:18];
	else if (kvmmu==oKey[7:5])
		pc_o[27:18] <= mro1;
	else
		pc_o[27:18] <= 10'h000;
end

always @(rmrb or oKey or kvmmu or mro2 or cs or cyc_i or ea_i or map_enable)
begin
	if (cyc_i|~map_enable)		// I/O cycles are not mapped
		ea_o[27:18] <= ea_i[27:18];
	else if (kvmmu==oKey[7:5])
		ea_o[27:18] <= mro2;
	else
		ea_o[27:18] <= 10'h000;
end

endmodule

module mapram(wclk, wr, wa, i, rclk, ra0, ra1, ra2, o0, o1, o2);
input wclk;
input wr;
input [13:0] wa;
input [9:0] i;
input rclk;
input [13:0] ra0;
input [13:0] ra1;
input [13:0] ra2;
output [9:0] o0;
output [9:0] o1;
output [9:0] o2;

reg [9:0] map [0:16383];
reg [13:0] rra0,rra1,rra2;

always @(posedge wclk)
	if (wr) map[wa] <= i;
always @(posedge rclk) rra0 <= ra0;
always @(posedge rclk) rra1 <= ra1;
always @(posedge rclk) rra2 <= ra2;

assign o0 = map[rra0];
assign o1 = map[rra1];
assign o2 = map[rra2];

endmodule
