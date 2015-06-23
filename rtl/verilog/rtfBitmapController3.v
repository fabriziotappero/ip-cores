`timescale 1ns / 1ps
// ============================================================================
//  Bitmap Controller3
//  - Displays a bitmap from memory.
//
//
//        __
//   \\__/ o\    (C) 2008-2015  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@finitron.ca
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
//  The default base screen address is:
//		$0400000 - the second 4MiB of RAM
//
//
//	Verilog 1995
//
// ref: XC7a100t-1CSG324
// 600 LUTs / 3 BRAMs / 425 FF's
// 196 MHz
// ============================================================================

module rtfBitmapController3(
	rst_i,
	s_clk_i, s_cyc_i, s_stb_i, s_ack_o, s_we_i, s_adr_i, s_dat_i, s_dat_o, irq_o,
	m_clk_i, m_bte_o, m_cti_o, m_cyc_o, m_stb_o, m_ack_i, m_we_o, m_sel_o, m_adr_o, m_dat_i, m_dat_o,
	vclk, hsync, vsync, blank, rgbo, xonoff
);
parameter pIOAddress = 32'hFFDC5000;
parameter BM_BASE_ADDR1 = 32'h0040_0000;
parameter BM_BASE_ADDR2 = 32'h0050_0000;
parameter REG_CTRL = 10'd0;
parameter REG_CTRL2 = 10'd1;
parameter REG_HDISPLAYED = 10'd2;
parameter REG_VDISPLAYED = 10'd3;
parameter REG_PAGE1ADDR = 10'd5;
parameter REG_PAGE2ADDR = 10'd6;
parameter REG_REFDELAY = 10'd7;

parameter BPP6 = 3'd0;
parameter BPP8 = 3'd1;
parameter BPP9 = 3'd2;
parameter BPP12 = 3'd3;
parameter BPP15 = 3'd4;
parameter BPP16 = 3'd5;
parameter BPP24 = 3'd6;
parameter BPP32 = 3'd7;

// SYSCON
input rst_i;				// system reset

// Peripheral slave port
input s_clk_i;
input s_cyc_i;
input s_stb_i;
output s_ack_o;
input s_we_i;
input [31:0] s_adr_i;
input [31:0] s_dat_i;
output [31:0] s_dat_o;
reg [31:0] s_dat_o;
output irq_o;

// Video Master Port
// Used to read memory via burst access
input m_clk_i;				// system bus interface clock
output [1:0] m_bte_o;
output [2:0] m_cti_o;
output m_cyc_o;			// video burst request
output m_stb_o;
output m_we_o;
output [15:0] m_sel_o;
input  m_ack_i;			// vid_acknowledge from memory
output [31:0] m_adr_o;	// address for memory access
input  [127:0] m_dat_i;	// memory data input
output [127:0] m_dat_o;

// Video
input vclk;				// Video clock 85.71 MHz
input hsync;				// start/end of scan line
input vsync;				// start/end of frame
input blank;			// blank the output
output [23:0] rgbo;		// 24-bit RGB output
reg [23:0] rgbo;

input xonoff;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// IO registers
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
reg m_cyc_o;
reg [31:0] m_adr_o;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
wire cs = s_cyc_i && s_stb_i && (s_adr_i[31:12]==pIOAddress[31:12]);
reg ack,ack1;
always @(posedge s_clk_i)
begin
	ack1 <= cs;
	ack <= ack1 & cs;
end
assign s_ack_o = cs ? (s_we_i ? 1'b1 : ack) : 1'b0;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
reg [11:0] hDisplayed,vDisplayed;
reg [31:0] bm_base_addr1,bm_base_addr2;
reg [2:0] color_depth;
wire [7:0] fifo_cnt;
reg onoff;
reg [2:0] hres,vres;
reg greyscale;
reg page;
reg pals;				// palette select
reg [11:0] hrefdelay;
reg [11:0] vrefdelay;
reg [11:0] hctr;		// horizontal reference counter
wire [11:0] hctr1 = hctr - hrefdelay;
reg [11:0] vctr;		// vertical reference counter
wire [11:0] vctr1 = vctr - vrefdelay;
reg [31:0] baseAddr;	// base address register
wire [127:0] rgbo1;
reg [11:0] pixelRow;
reg [11:0] pixelCol;
wire [31:0] pal_wo;
wire [31:0] pal_o;

always @(page or bm_base_addr1 or bm_base_addr2)
	baseAddr = page ? bm_base_addr2 : bm_base_addr1;

// Color palette RAM for 8bpp modes
syncRam512x32_1rw1r upal1
(
	.wrst(1'b0),
	.wclk(s_clk_i),
	.wce(cs & s_adr_i[11]),
	.we(s_we_i),
	.wadr(s_adr_i[10:2]),
	.i(s_dat_i),
	.wo(pal_wo),
	.rrst(1'b0),
	.rclk(vclk),
	.rce(1'b1),
	.radr({pals,rgbo4[7:0]}),
	.o(pal_o)
);

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
always @(posedge s_clk_i)
if (rst_i) begin
	page <= 1'b0;
	pals <= 1'b0;
	hres <= 3'd4;
	vres <= 3'd3;
	hDisplayed <= 12'd340;
	vDisplayed <= 12'd256;
	onoff <= 1'b1;
	color_depth <= BPP12;
	greyscale <= 1'b0;
	bm_base_addr1 <= BM_BASE_ADDR1;
	bm_base_addr2 <= BM_BASE_ADDR2;
	hrefdelay <= 12'd54;//12'd218;
	vrefdelay <= 12'd16;//12'd27;
end
else begin
	if (cs) begin
		if (s_we_i) begin
			casex(s_adr_i[11:2])
			REG_CTRL:
				begin
					onoff <= s_dat_i[0];
					color_depth <= s_dat_i[10:8];
					greyscale <= s_dat_i[11];
					hres <= s_dat_i[18:16];
					vres <= s_dat_i[21:19];
				end
			REG_CTRL2:
				begin
					page <= s_dat_i[16];
					pals <= s_dat_i[17];
				end
			REG_HDISPLAYED:	hDisplayed <= s_dat_i[11:0];
			REG_VDISPLAYED:	vDisplayed <= s_dat_i[11:0];
			REG_PAGE1ADDR:	bm_base_addr1 <= s_dat_i;
			REG_PAGE2ADDR:	bm_base_addr2 <= s_dat_i;
			REG_REFDELAY:
				begin
					hrefdelay <= s_dat_i[11:0];
					vrefdelay <= s_dat_i[27:16];
				end
			endcase
		end
		casex(s_adr_i[11:2])
		REG_CTRL:
			begin
				s_dat_o[0] <= onoff;
				s_dat_o[10:8] <= color_depth;
				s_dat_o[11] <= greyscale;
				s_dat_o[18:16] <= hres;
				s_dat_o[21:19] <= vres;
			end
		REG_CTRL2:	
			begin
				s_dat_o[16] <= page;
				s_dat_o[17] <= pals;
			end
		REG_HDISPLAYED:	s_dat_o <= hDisplayed;
		REG_VDISPLAYED:	s_dat_o <= vDisplayed;
		REG_PAGE1ADDR:	s_dat_o <= bm_base_addr1;
		REG_PAGE2ADDR:	s_dat_o <= bm_base_addr2;
		REG_REFDELAY:	s_dat_o <= {vrefdelay,4'h0,hrefdelay};
		10'b1xxx_xxxx_xx:	s_dat_o <= pal_wo;
		endcase
	end
	else
		s_dat_o <= 32'd0;
end

assign irq_o = 1'b0;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Horizontal and Vertical timing reference counters
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

wire pe_hsync;
wire pe_vsync;
edge_det edh1
(
	.rst(rst_i),
	.clk(vclk),
	.ce(1'b1),
	.i(hsync),
	.pe(pe_hsync),
	.ne(),
	.ee()
);

edge_det edv1
(
	.rst(rst_i),
	.clk(vclk),
	.ce(1'b1),
	.i(vsync),
	.pe(pe_vsync),
	.ne(),
	.ee()
);

reg [3:0] hc;
always @(posedge vclk)
if (rst_i)
	hc <= 4'd1;
else if (pe_hsync) begin
	hc <= 4'd1;
	pixelCol <= -hrefdelay;
end
else begin
	if (hc==hres) begin
		hc <= 4'd1;
		pixelCol <= pixelCol + 1;
	end
	else
		hc <= hc + 4'd1;
end

reg [3:0] vc;
always @(posedge vclk)
if (rst_i)
	vc <= 4'd1;
else if (pe_vsync) begin
	vc <= 4'd1;
	pixelRow <= -vrefdelay;
end
else begin
	if (pe_hsync) begin
		vc <= vc + 4'd1;
		if (vc==vres) begin
			vc <= 4'd1;
			pixelRow <= pixelRow + 1;
		end
	end
end

reg [4:0] shifts;
always @(color_depth)
case(color_depth)
BPP6:	shifts = 5'd21;
BPP8:	shifts = 5'd16;
BPP9:	shifts = 5'd14;
BPP12:	shifts = 5'd10;
BPP15:	shifts = 5'd8;
BPP16:	shifts = 5'd8;
BPP24:	shifts = 5'd5;
BPP32:	shifts = 5'd4;
endcase

wire vFetch = pixelRow < vDisplayed;
wire fifo_rrst = pixelCol==12'hFFE;
wire fifo_wrst = pe_hsync;

wire[31:0] grAddr;
reg [11:0] fetchCol;

gfx_CalcAddress u1
(
	.base_address_i(baseAddr),
	.color_depth_i(color_depth),
	.hdisplayed_i(hDisplayed),
	.x_coord_i(0),
	.y_coord_i(pixelRow),
	.address_o(grAddr),
	.mb_o(),
	.me_o()
);

// The following bypasses loading the fifo when all the pixels from a scanline
// are buffered in the fifo and the pixel row doesn't change. Since the fifo
// pointers are reset at the beginning of a scanline, the fifo can be used like
// a cache.
wire blankEdge;
edge_det ed2(.rst(rst_i), .clk(m_clk_i), .ce(1'b1), .i(blank), .pe(blankEdge), .ne(), .ee() );
reg do_loads;
reg [11:0] opixelRow;
reg load_fifo;
always @(posedge m_clk_i)
	//load_fifo <= fifo_cnt < 10'd1000 && vFetch && onoff && xonoff && !m_cyc_o && do_loads;
	load_fifo <= fifo_cnt < 8'd224 && vFetch && onoff && xonoff && fetchCol < hDisplayed && !m_cyc_o && do_loads;
reg [11:0] hCmp;
always @(color_depth)
case(color_depth)
BPP6:	hCmp = 12'd5120;
BPP8:	hCmp = 12'd4096;
BPP9:	hCmp = 12'd3583;
BPP12:	hCmp = 12'd2559;
BPP15:	hCmp = 12'd2048;
BPP16:	hCmp = 12'd2048;
BPP24:	hCmp = 12'd1279;
BPP32:	hCmp = 12'd1024;
default:	hCmp = 12'd1024;
endcase
always @(posedge m_clk_i)
	// if hDisplayed > hCmp we always load because the fifo isn't large enough to act as a cache.
	if (!(hDisplayed < hCmp))
		do_loads <= 1'b1;
	// otherwise load the fifo only when the row changes to conserve memory bandwidth
	else if (pixelRow != opixelRow)
		do_loads <= 1'b1;
	else if (blankEdge)
		do_loads <= 1'b0;

assign m_bte_o = 2'b00;
assign m_cti_o = 3'b000;
assign m_stb_o = 1'b1;
assign m_we_o = 1'b0;
assign m_sel_o = 16'hFFFF;
assign m_dat_o = 128'd0;

reg [31:0] adr;
always @(posedge m_clk_i)
if (rst_i) begin
	wb_nack();
	fetchCol <= 12'd0;
	opixelRow <= 12'hFFF;
end
else begin
	if (fifo_wrst) begin
		fetchCol <= 12'd0;
		adr <= grAddr;
		opixelRow <= pixelRow;
	end
	else if (load_fifo) begin
		m_cyc_o <= 1'b1;
		m_adr_o <= adr;
	end
	if (m_cyc_o & m_ack_i) begin
		fetchCol <= fetchCol + shifts;
		wb_nack();
		adr <= adr + 32'd16;
	end
end

task wb_nack;
begin
	m_cyc_o <= 1'b0;
end
endtask

reg [11:0] pixelColD1;
reg [23:0] rgbo2,rgbo4;
reg [127:0] rgbo3;
always @(posedge vclk)
	case(color_depth)
	BPP6:	rgbo4 <= greyscale ? {3{rgbo3[5:0],2'b00}} : {2'b00,rgbo3[5:0]};
	BPP8:	rgbo4 <= greyscale ? {3{rgbo3[7:0]}} : rgbo3[7:0];
	BPP9:	rgbo4 <= {rgbo3[8:6],5'b0,rgbo3[5:3],5'b0,rgbo3[2:0],5'b0};
	BPP12:	rgbo4 <= {rgbo3[11:8],4'h0,rgbo3[7:4],4'h0,rgbo3[3:0],4'h0};
	BPP15:	rgbo4 <= {rgbo3[14:10],3'b0,rgbo3[9:5],3'b0,rgbo3[4:0],3'b0};
	BPP16:	rgbo4 <= {rgbo3[15:11],3'b0,rgbo3[10:5],2'b0,rgbo3[4:0],3'b0};
	BPP24:	rgbo4 <= rgbo3;
	BPP32:	rgbo4 <= rgbo3[23:0];
	endcase

reg rd_fifo,rd_fifo1,rd_fifo2;
reg de;
always @(posedge vclk)
	if (rd_fifo1)
		de <= ~blank;

always @(posedge vclk)
	if (onoff && xonoff && !blank) begin
		if (color_depth[2:1]==2'b00 && !greyscale)
			rgbo <= pal_o;
		else
			rgbo <= rgbo4[23:0];
	end
	else
		rgbo <= 24'd0;

// Before the hrefdelay expires, pixelCol will be negative, which is greater
// than hDisplayed as the value is unsigned. That means that fifo reading is
// active only during the display area 0 to hDisplayed.
wire shift1 = hc==hres;
reg [4:0] shift_cnt;
always @(posedge vclk)
if (pe_hsync)
	shift_cnt <= 5'd1;
else begin
	if (shift1) begin
		if (pixelCol==12'hFFF)
			shift_cnt <= shifts;
		else if (!pixelCol[11]) begin
			shift_cnt <= shift_cnt + 5'd1;
			if (shift_cnt==shifts)
				shift_cnt <= 5'd1;
		end
		else
			shift_cnt <= 5'd1;
	end
end

wire next_strip = (shift_cnt==shifts) && (hc==hres);

wire vrd;
always @(posedge vclk) pixelColD1 <= pixelCol;
reg shift,shift2;
always @(posedge vclk) shift2 <= shift1;
always @(posedge vclk) shift <= shift2;
always @(posedge vclk) rd_fifo2 <= next_strip;
always @(posedge vclk) rd_fifo <= rd_fifo2;
always @(posedge vclk)
	if (rd_fifo)
		rgbo3 <= rgbo1;
	else if (shift) begin
		case(color_depth)
		BPP6:	rgbo3 <= {rgbo3[127:6]};
		BPP8:	rgbo3 <= {rgbo3[127:8]};
		BPP9:	rgbo3 <= {rgbo3[127:9]};
		BPP12:	rgbo3 <= {rgbo3[127:12]};
		BPP15:	rgbo3 <= {rgbo3[127:16]};
		BPP16:	rgbo3 <= {rgbo3[127:16]};
		BPP24:	rgbo3 <= {rgbo3[127:24]};
		BPP32:	rgbo3 <= {rgbo3[127:32]};
		endcase
	end


rtfVideoFifo3 uf1
(
	.wrst(fifo_wrst),
	.wclk(m_clk_i),
	.wr(m_cyc_o & m_ack_i),
	.di(m_dat_i),
	.rrst(fifo_rrst),
	.rclk(vclk),
	.rd(rd_fifo),
	.dout(rgbo1),
	.cnt(fifo_cnt)
);

endmodule

