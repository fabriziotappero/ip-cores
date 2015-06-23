`timescale 1ns / 1ps
// ============================================================================
//  Bitmap Controller2
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

module rtfBitmapController2(
	rst_i,
	s_clk_i, s_cyc_i, s_stb_i, s_ack_o, s_we_i, s_adr_i, s_dat_i, s_dat_o, irq_o,
	m_clk_i, m_cyc_o, m_stb_o, m_ack_i, m_adr_o, m_dat_i,
	vclk, hSync, vSync, blank, rgbPriority, rgbo, xonoff
);
parameter pIOAddress = 32'hFFDC5000;
parameter BM_BASE_ADDR1 = 32'h0040_0000;
parameter BM_BASE_ADDR2 = 32'h0080_0000;
parameter REG_CTRL = 10'd0;
parameter REG_CTRL2 = 10'd1;
parameter REG_HDISPLAYED = 10'd2;
parameter REG_VDISPLAYED = 10'd3;
parameter REG_PAGE1ADDR = 10'd5;
parameter REG_PAGE2ADDR = 10'd6;
parameter REG_REFDELAY = 10'd7;

parameter BPP6 = 3'd0;
parameter BPP8 = 3'd1;
parameter BPP12 = 3'd2;
parameter BPP16 = 3'd3;
parameter BPP24 = 3'd4;
parameter BPP30 = 3'd6;

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
output m_cyc_o;			// video burst request
output m_stb_o;
input  m_ack_i;			// vid_acknowledge from memory
output [31:0] m_adr_o;	// address for memory access
input  [127:0] m_dat_i;	// memory data input

// Video
input vclk;				// Video clock 85.71 MHz
input hSync;			// start/end of scan line
input vSync;			// start/end of frame
input blank;			// blank the output
output [1:0] rgbPriority;
reg [1:0] rgbPriority;
output [23:0] rgbo;		// 24-bit RGB output
reg [23:0] rgbo;

input xonoff;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// IO registers
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
reg m_cyc_o;
reg m_stb_o;
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
wire [8:0] fifo_cnt;
reg onoff;
reg [1:0] hres,vres;
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
wire [31:0] rgbo1;
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
	hres <= 2'b01;
	vres <= 2'b01;
	hDisplayed <= 12'd672;	// must be a multiple of 16
	vDisplayed <= 12'd384;
	onoff <= 1'b1;
	color_depth <= BPP12;
	greyscale <= 1'b0;
	bm_base_addr1 <= BM_BASE_ADDR1;
	bm_base_addr2 <= BM_BASE_ADDR2;
	hrefdelay <= 12'd218;
	vrefdelay <= 12'd27;
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
					hres <= s_dat_i[17:16];
					vres <= s_dat_i[19:18];
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
				s_dat_o[17:16] <= hres;
				s_dat_o[19:18] <= vres;
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
// - The memory fetch address is determined from these counters.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
wire hSyncEdge, vSyncEdge;
edge_det ed0(.rst(rst_i), .clk(vclk), .ce(1'b1), .i(hSync), .pe(hSyncEdge), .ne(), .ee() );
edge_det ed1(.rst(rst_i), .clk(vclk), .ce(1'b1), .i(vSync), .pe(vSyncEdge), .ne(), .ee() );

always @(posedge vclk)
if (rst_i)        	hctr <= 1;
else if (hSyncEdge) hctr <= 1;
else            	hctr <= hctr + 1;

always @(posedge vclk)
if (rst_i)        	vctr <= 1;
else if (vSyncEdge) vctr <= 1;
else if (hSyncEdge) vctr <= vctr + 1;


// Pixel row and column are derived from the horizontal and vertical counts.

always @(posedge vclk)
	case(vres)
	2'b00:		pixelRow <= vctr1[11:0];
	2'b01:		pixelRow <= vctr1[11:1];
	2'b10:		pixelRow <= vctr1[11:2];
	default:	pixelRow <= vctr1[11:2];
	endcase
always @(hctr1)
	case(hres)
	2'b00:		pixelCol = hctr1[11:0];
	2'b01:		pixelCol = hctr1[11:1];
	2'b10:		pixelCol = hctr1[11:2];
	default:	pixelCol = hctr1[11:2];
	endcase
	
wire vFetch = pixelRow < vDisplayed;
wire fifo_rst = hctr[11:4]==8'h00;

wire[23:0] rowOffset = pixelRow * hDisplayed;
reg [11:0] fetchCol;

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
	load_fifo <= fifo_cnt < 9'd500 && vFetch && onoff && xonoff && fetchCol < hDisplayed && !m_cyc_o && do_loads;
reg [11:0] hCmp;
always @(color_depth)
case(color_depth)
BPP6:	hCmp = 12'd2048;
BPP8:	hCmp = 12'd2048;
BPP12:	hCmp = 12'd1024;
BPP16:	hCmp = 12'd1024;
BPP24:	hCmp = 12'd512;
default:	hCmp = 12'd512;
endcase
always @(posedge m_clk_i)
	if (!(hDisplayed < hCmp))
		do_loads <= 1'b1;
	else if (pixelRow != opixelRow)
		do_loads <= 1'b1;
	else if (blankEdge)
		do_loads <= 1'b0;

reg [31:0] adr;
always @(posedge m_clk_i)
if (rst_i) begin
	wb_nack();
	fetchCol <= 12'd0;
	opixelRow <= 12'hFFF;
end
else begin
	if (fifo_rst) begin
		fetchCol <= 12'd0;
		adr <= baseAddr + rowOffset;
		opixelRow <= pixelRow;
	end
	else if (load_fifo) begin
		m_cyc_o <= 1'b1;
		m_stb_o <= 1'b1;
		m_adr_o <= adr;
	end
	if (m_cyc_o & m_ack_i) begin
		case(color_depth)
		BPP6,BPP8:		fetchCol <= fetchCol + 12'd16;
		BPP12,BPP16:	fetchCol <= fetchCol + 12'd8;
		default:		fetchCol <= fetchCol + 12'd4;
		endcase
		wb_nack();
		adr <= adr + 32'd16;
	end
end

task wb_nack;
begin
	m_cyc_o <= 1'b0;
	m_stb_o <= 1'b0;
	m_adr_o <= 32'h0000_0000;
end
endtask

reg [11:0] pixelColD1;
reg [31:0] rgbo2,rgbo3,rgbo4;
always @(posedge vclk)
	case(color_depth)
	BPP6:	rgbo4 <= greyscale ? {3{rgbo2[5:0],2'b00}} : {rgbo2[7:6],6'b00,rgbo2[5:4],6'b00,rgbo2[3:2],6'b00,rgbo2[1:0],6'b00};
	BPP8:	rgbo4 <= greyscale ? {3{rgbo2[7:0]}} : rgbo2;
	BPP12:	rgbo4 <= {rgbo3[15:14],6'd0,rgbo3[11:8],4'h0,rgbo3[7:4],4'h0,rgbo3[3:0],4'h0};
	BPP16:	rgbo4 <= {rgbo3[14:10],3'b0,rgbo3[9:5],3'b0,rgbo3[4:0],3'b0};
	default:	rgbo4 <= rgbo1;
	endcase

reg rd_fifo,rd_fifo1,rd_fifo2;
reg de;
always @(posedge vclk)
	if (rd_fifo1)
		de <= ~blank;

always @(posedge vclk)
	if (onoff & xonoff & de) begin
		if (color_depth[2:1]==2'b00 && !greyscale) begin
			rgbo <= pal_o;
			rgbPriority <= pal_o[31:30];
		end
		else begin
			rgbo <= rgbo4[23:0];
			rgbPriority <= rgbo4[31:30];
		end
	end
	else
		rgbo <= 24'd0;

// Before the hrefdelay expires, pixelCol will be negative, which is greater
// than hDisplayed as the value is unsigned. That means that fifo reading is
// active only during the display area 0 to hDisplayed.
wire vrd;
always @(posedge vclk) pixelColD1 <= pixelCol;
always @(posedge vclk)
if (pixelCol < hDisplayed + 12'd8)
	case({color_depth[2:1],hres})
	4'b0000:	rd_fifo1 <= hctr[1:0]==2'b00;	// 4 clocks
	4'b0001:	rd_fifo1 <= hctr[2:0]==3'b000;	// 8 clocks
	4'b0010:	rd_fifo1 <= hctr[3:0]==4'b0000;	// 16 clocks
	4'b0011:	rd_fifo1 <= hctr[3:0]==4'b0000;	// unsupported
	4'b0100:	rd_fifo1 <= hctr[0]==1'b0;		// 2 clocks
	4'b0101:	rd_fifo1 <= hctr[1:0]==2'b00;	// 4 clocks
	4'b0110:	rd_fifo1 <= hctr[2:0]==3'b000;	// 8 clocks (twice as often as a byte)
	4'b0111:	rd_fifo1 <= hctr[2:0]==3'b000;
	4'b1000:	rd_fifo1 <= 1'b0;
	4'b1001:	rd_fifo1 <= 1'b0;
	4'b1010:	rd_fifo1 <= 1'b0;
	4'b1011:	rd_fifo1 <= 1'b0;
	4'b1100:	rd_fifo1 <= 1'b1;
	4'b1101:	rd_fifo1 <= hctr[0]==1'b0;
	4'b1110:	rd_fifo1 <= hctr[1:0]==2'b00;
	4'b1111:	rd_fifo1 <= hctr[1:0]==2'b00;
	endcase
else
	rd_fifo1 <= 1'b0;
reg shift,shift1,shift2;
always @(posedge vclk)
if (pixelCol < hDisplayed + 12'd8)
	case({color_depth[2:1],hres})
	// shift four times as often as a load
	4'b0000:	shift1 <= 1'b1;
	4'b0001:	shift1 <= hctr[0]==1'b0;
	4'b0010:	shift1 <= hctr[1:0]==2'b00;
	4'b0011:	shift1 <= hctr[1:0]==2'b00;
	// shift twice as often as a load
	4'b0100:	shift1 <= 1'b1;
	4'b0101:	shift1 <= hctr[0]==1'b0;
	4'b0110:	shift1 <= hctr[1:0]==2'b00;	
	4'b0111:	shift1 <= hctr[1:0]==2'b00;
	// unsupported color depth
	4'b1000:	shift1 <= 1'b0;	
	4'b1001:	shift1 <= 1'b0;
	4'b1010:	shift1 <= 1'b0;
	4'b1011:	shift1 <= 1'b0;
	// nothing to shift (all loads)
	4'b1100:	shift1 <= 1'b0;
	4'b1101:	shift1 <= 1'b0;
	4'b1110:	shift1 <= 1'b0;	
	4'b1111:	shift1 <= 1'b0;
	endcase
always @(posedge vclk) shift2 <= shift1;
always @(posedge vclk) shift <= shift2;
always @(posedge vclk) rd_fifo2 <= rd_fifo1;
always @(posedge vclk) rd_fifo <= rd_fifo2;
always @(posedge vclk)
	if (rd_fifo)
		rgbo2 <= rgbo1;
	else if (shift)
		rgbo2 <= {8'h00,rgbo2[31:8]};
always @(posedge vclk)
	if (rd_fifo)
		rgbo3 <= rgbo1;
	else if (shift)
		rgbo3 <= {16'h0000,rgbo3[31:16]};

rtfVideoFifo2 uf1
(
	.rst(fifo_rst),
	.wclk(m_clk_i),
	.wr(m_cyc_o & m_ack_i),
	.di(m_dat_i),
	.rclk(vclk),
	.rd(rd_fifo),
	.do(rgbo1),
	.cnt(fifo_cnt)
);

endmodule

