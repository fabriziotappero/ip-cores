`timescale 1ns / 1ps
// ============================================================================
//        __
//   \\__/ o\    (C) 2014  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@finitron.ca
//       ||
//
// FT816Float_tb.v
//  - Test Bench for triple precision floating point accelerator
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
// ============================================================================
//
module FT816Float_tb();

reg clk;
reg rst;
reg vda;
reg rw;
reg [23:0] ad;
wire [7:0] db;
reg [7:0] dbo;
wire rdy;
reg [7:0] state;
reg [7:0] retstate;
reg fix2flt;
reg [95:0] value;

initial begin
	#1 clk <= 1'b0;
	#5 rst <= 1'b1;
	#100 rst <= 1'b0;
end

always #5 clk <= ~clk;

assign db = rw ? {8{1'bz}} : dbo;

FT816Float u1 (
	.rst(rst),
	.clk(clk),
	.vda(vda),
	.rw(rw),
	.ad(ad),
	.db(db),
	.rdy(rdy)
);


always @(posedge clk)
if (rst)
	state <= 8'h00;
else begin
state <= state + 8'd1;
case(state)
8'h00:	begin
			value <= 96'h00000000000000004D20000;	// MAXINT
			fix2flt <= 1'b1;
			state <= 8'h80;
			retstate <= 8'h01;
			 b_write(24'hFEA20F,8'd17); 	// prime bus
		end
8'h01:  if (rdy) b_write(24'hFEA20F,8'd17); else state <= state;// SWAP
8'h03:  if (rdy) b_read(24'hFEA20F); else state <= state;
8'h04:	if (rdy) begin
			if (db[7]) state <= state - 1;
		end
		else
			state <= state;
8'h05:	begin
			value <= 96'h000000000000000004D20000;	// MAXINT
			fix2flt <= 1'b1;
			state <= 8'h80;
			retstate <= 8'h06;
		end
8'h06:  if (rdy) b_write(24'hFEA20F,8'h06); else state <= state;// MUL
8'h08:  if (rdy) b_read(24'hFEA20F); else state <= state;
8'h09:	if (rdy) begin
			if (db[7]) state <= state - 1;
		end
		else
			state <= state;
8'h20:	state <= state;
// This subroutine writes a value to FAC1.
8'h80:	if (rdy) b_write(24'hFEA200,value[7:0]); else state <= state;
8'h81:  if (rdy) b_write(24'hFEA201,value[15:8]); else state <= state;
8'h82:  if (rdy) b_write(24'hFEA202,value[23:16]); else state <= state;
8'h83:  if (rdy) b_write(24'hFEA203,value[31:24]); else state <= state;
8'h84:  if (rdy) b_write(24'hFEA204,value[39:32]); else state <= state;
8'h85:  if (rdy) b_write(24'hFEA205,value[47:40]); else state <= state;
8'h86:  if (rdy) b_write(24'hFEA206,value[55:48]); else state <= state;
8'h87:  if (rdy) b_write(24'hFEA207,value[63:56]); else state <= state;
8'h88:  if (rdy) b_write(24'hFEA208,value[71:64]); else state <= state;
8'h89:  if (rdy) b_write(24'hFEA209,value[79:72]); else state <= state;
8'h8A:  if (rdy) b_write(24'hFEA20A,value[87:80]); else state <= state;
8'h8B:  if (rdy) begin b_write(24'hFEA20B,value[95:88]); if (fix2flt) state <= 8'h90; else state <= retstate; end else state <= state;
8'h90:  if (rdy) b_write(24'hFEA20F,8'h05); else state <= state;// FIX2FLT
8'h92:  if (rdy) b_read(24'hFEA20F); else state <= state;
8'h93:	if (rdy) begin
			if (db[7]) state <= state - 1;
			else state <= retstate;
		end
		else
			state <= state;
endcase
end

task b_write;
input [23:0] adr;
input [7:0] dat;
begin
	vda <= 1'b1;
	rw <= 1'b0;
	ad <= adr;
	dbo <= dat;
end
endtask

task b_read;
input [23:0] adr;
begin
	vda <= 1'b1;
	rw <= 1'b1;
	ad <= adr;
end
endtask

endmodule
