// ============================================================================
//  Bitmap Controller (416h x 262v x 8bpp):
//  - Displays a bitmap from memory.
//  - the video mode timing to be 1680x1050
//
//
//	(C) 2008,2010,2011  Robert Finch
//	robfinch<remove>@opencores.org
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
//		$20000 - the second 128 kb of RAM
//
//
//	Verilog 1995
//	Webpack 9.2i  xc3s1200-4fg320
//	64 slices / 118 LUTs / 175.009 MHz
//  72 ff's / 2 BRAM (2048x16)
//
// ============================================================================

module rtfBitmapController(
	rst_i, clk_i, bte_o, cti_o, cyc_o, stb_o, ack_i, we_o, sel_o, adr_o, dat_i, dat_o,
	vclk, eol, eof, blank, rgbo, page
);
parameter BM_BASE_ADDR1 = 44'h000_0002_0000;
parameter BM_BASE_ADDR2 = 44'h000_0004_0000;

// SYSCON
input rst_i;				// system reset
input clk_i;				// system bus interface clock

// Video Master Port
// Used to read memory via burst access
output [1:0] bte_o;
output [2:0] cti_o;
output cyc_o;			// video burst request
output stb_o;
input  ack_i;			// vid_acknowledge from memory
output we_o;
output [ 1:0] sel_o;
output [43:0] adr_o;	// address for memory access
input  [15:0] dat_i;	// memory data input
output [15:0] dat_o;

// Video
input vclk;				// Video clock 73.529 MHz
input eol;				// end of scan line
input eof;				// end of frame
input blank;			// blank the output
output [7:0] rgbo;		// 8-bit RGB output
reg [7:0] rgbo;

input page;				// which page to display


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// IO registers
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
reg [1:0] bte_o;
reg [2:0] cti_o;
reg cyc_o;
reg stb_o;
reg we_o;
reg [1:0] sel_o;
reg [43:0] adr_o;
reg [15:0] dat_o;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
wire [11:0] hctr;		// horizontal reference counter
wire [11:0] vctr;		// vertical reference counter
wire [11:0] vctr1 = vctr + 12'd4;
reg [43:0] baseAddr;	// base address register
wire [7:0] rgbo1;
reg [11:0] pixelRow;
reg [11:0] pixelCol;

always @(page)
	baseAddr = page ? BM_BASE_ADDR2 : BM_BASE_ADDR1;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Horizontal and Vertical timing reference counters
// - The memory fetch address is determined from these counters.
// - The counters are setup with negative values so that the zero
//   point coincides with the top left of the display.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

counter #(12) u1 (.rst(1'b0), .clk(vclk), .ce(1'b1), .ld(eol), .d(12'hEE4), .q(hctr));
counter #(12) u2 (.rst(1'b0), .clk(vclk), .ce(eol),  .ld(eof), .d(12'hFDC), .q(vctr));


// Pixel row and column are derived from the horizontal and vertical counts.

always @(vctr1)
	pixelRow = vctr1[11:2];
always @(hctr)
	pixelCol = hctr[11:1];
	

wire vFetch = (vctr < 12'd1050) || (vctr > 12'hFF8);

// Video Request Block
// 416x262
// - Issue a request for access to memory every 160 clock cycles
// - Reset the request flag once an access has been initiated.
// - 128 bytes (pixels) are read per scan line
// - It takes about 18 clock cycles @ 25 MHz to access 32 bytes of data
//   through the memory contoller, or about 53 video clocks
//   83 video clocks with a 16 MHZ memory controller.

reg [2:0] vreq;

// Must be vclk. vid_req will be active for numerous clock cycles as
// a burst type fetch is used. The ftch and vFetch may only be
// active for a single video clock cycle. vclk must be used so these
// signals are not missed due to a clock domain crossing. We luck
// out here because of the length of time vid_req is active.
//
always @(posedge vclk)
begin
	if (vFetch) begin
		if (vctr1[1:0]!=2'd3) begin	// we only need 13 memory accesses
			if (hctr==12'd16) vreq <= 3'b100;
			if (hctr==12'd176) vreq <= 3'b101;
			if (hctr==12'd336) vreq <= 3'b110;
			if (hctr==12'd496) vreq <= 3'b111;
		end
		else
			if (hctr==12'd16) vreq <= 3'b100;
	end
	if (cyc_o) vreq <= 3'b000;
end
	
// Cross the clock domain with the request signal
reg do_cyc;
always @(posedge clk_i)
	do_cyc <= vreq[2];

wire[19:0] rowOffset = pixelRow * 10'd416;
reg [8:0] fetchCol;

// - read from assigned video memory address, using burst mode reads
// - 32 pixels at a time are read
// - video data is fetched one pixel row in advance
//
reg [3:0] bcnt;
always @(posedge clk_i)
if (rst_i) begin
	bte_o <= 2'b00;		// linear burst
	cti_o <= 3'b000;	// classic cycle
	cyc_o <= 1'b0;
	stb_o <= 1'b0;
	sel_o <= 2'b00;
	we_o <= 1'b0;
	adr_o <= 44'h000_0000_0000;
	dat_o <= 16'h0000;
	fetchCol <= 9'd0;
	bcnt <= 4'd0;
end
else begin
	if (do_cyc & !cyc_o) begin
		cti_o <= 3'b010;	// incrementing burst cycle
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 2'b11;
		bcnt <= 4'd0;
		fetchCol <= {vctr1[1:0],vreq[1:0],5'h00};
		// This works out to be an even multiple of 32 bytes
		adr_o <= baseAddr + rowOffset + 10'd416 + {vctr1[1:0],vreq[1:0],5'h00};
	end
	if (cyc_o & ack_i) begin
		adr_o <= adr_o + 32'd2;
		fetchCol <= fetchCol + 9'd2;
		bcnt <= bcnt + 4'd1;
		if (bcnt==4'd14)
			cti_o <= 3'b111;	// end of burst
		if (bcnt==4'd15) begin
			cti_o <= 3'b000;	// classic cycles again
			cyc_o <= 1'b0;
			stb_o <= 1'b0;
			sel_o <= 2'b00;
			adr_o <= 44'h000_0000_0000;
		end
	end
end


always @(posedge vclk)
	rgbo <= rgbo1;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Video Line Buffer
// - gets written in bursts, but read continuously
// - buffer is used as two halves - one half is displayed (read) while
//   the other is fetched (write).
// - only the lower eleven bits of the address are used as an index,
//   these bits will match with the addresses generated by the burst
//   controller above.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// Storage for 2048x8 bit pixels (2048x8 data)

RAMB16_S9_S18 ram0
(
	.CLKA(vclk),
	.ADDRA({pixelRow[0],pixelCol[8:1],~pixelCol[0]}),	// <- pixelCol[0] nonsense, we need the highest pixel first
	.DIA(8'hFF),
	.DIPA(1'b1),
	.DOA(rgbo1),
	.ENA(1'b1),
	.WEA(1'b0),
	.SSRA(blank),

	.CLKB(clk_i),
	.ADDRB({~pixelRow[0],fetchCol[8:1]}),
	.DIB(dat_i),
	.DIPB(2'b11),
	.DOB(),
	.ENB(cyc_o),
	.WEB(ack_i),
	.SSRB(1'b0)
);

endmodule
