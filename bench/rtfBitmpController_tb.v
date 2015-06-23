// ============================================================================
//  Bitmap Controller Test Bench
//
//        __
//   \\__/ o\    (C) 2008-2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//
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
//	Verilog 1995
//
// ============================================================================

module rtfBitmapController_tb();

reg rst;
reg pixel_clk;
reg sys_clk;
wire hsync;
wire vsync;
wire blank;
wire border;
wire [23:0] bm_rgb;
reg bmp_clk;
wire [1:0] bm_bte;
wire [2:0] bm_cti;
wire bm_cyc;
wire bm_stb;
wire bm_ack;
wire [33:0] bm_adr_o;
wire [31:0] bm_dat_i;
reg cyc,stb,we;
reg [33:0] adr;
reg [31:0] dat;
reg [7:0] state;
reg [9:0] x;
wire ack;

initial begin
	#0 rst <= 1'b0;
	#0 pixel_clk <= 1'b0;
	#0 bmp_clk <= 1'b0;
	#0 sys_clk <= 1'b0;
	#0 lfsr <= 32'd0;
	#10 rst <= 1'b1;
	#40 rst <= 1'b0;
end

always #5.83 pixel_clk <= ~pixel_clk;
always #4 bmp_clk <= ~bmp_clk;
always #20 sys_clk <= ~sys_clk;

	
reg [31:0] lfsr;
wire lfsr_fb; 
xnor(lfsr_fb,lfsr[0],lfsr[1],lfsr[21],lfsr[31]);
assign bm_ack = bm_cyc;
assign bm_dat_i = lfsr;
always @(posedge bmp_clk)
	lfsr <= {lfsr[30:0],lfsr_fb};

WXGASyncGen1366x768_60Hz u3
(
	.rst(rst),
	.clk(pixel_clk),
	.hSync(hsync),
	.vSync(vsync),
	.blank(blank),
	.border(border)
);

rtfBitmapController ubmc
(
	.rst_i(rst),
	
	.s_clk_i(sys_clk),
	.s_cyc_i(cyc),
	.s_stb_i(cyc),
	.s_ack_o(ack),
	.s_we_i(we),
	.s_adr_i(adr),
	.s_dat_i(dat),

	.clk_i(bmp_clk),
	.bte_o(bm_bte),
	.cti_o(bm_cti),
	.bl_o(bm_bl),
	.cyc_o(bm_cyc),
	.stb_o(bm_stb),
	.ack_i(bm_ack),
	.we_o(),
	.sel_o(),
	.adr_o(bm_adr_o),
	.dat_i(bm_dat_i),
	.dat_o(),

	.vclk(pixel_clk),
	.hSync(hsync),
	.vSync(vsync),
	.blank(blank),
	.rgbo(bm_rgb),
	.xonoff(1'b1)
);

always @(posedge sys_clk)
if (rst) begin
	state <= 8'd0;
end
else begin
case(state)
0:	begin
	x <= 0;
	wb_write(32'hFFDC5000,32'h00000601);
	end
1:	wb_nack();
2:	wb_write(32'hFFDC5002,12'd1364);
3:	wb_nack();
4:	wb_write(32'hFFDC5800+x,lfsr);
5:	wb_nack();
6:	begin
		x <= x + 10'd1;
		if (x < 10'd512)
			state <= 4;
		else
			next_state();
	end
7:	state <= 7;
endcase
end

task wb_write;
input [31:0] ad;
input [31:0] dt;
begin
	cyc <= 1'b1;
	we <= 1'b1;
	adr <= {ad,2'b00};
	dat <= dt;
	next_state();
end
endtask

task wb_nack;
begin
	if (ack) begin
		cyc <= 1'b0;
		we <= 1'b0;
		next_state();
	end
end
endtask

task next_state;
begin
	state <= state + 8'd1;
end
endtask

endmodule
