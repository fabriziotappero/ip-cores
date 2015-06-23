// ============================================================================
//  Bitmap Controller (1364h x 768v x 8bpp):
//  - Displays a bitmap from memory.
//  - the video mode timing to be 1366x768
//
//
//	(C) 2008-2012  Robert Finch
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
//		$200000 - the second 2MiB of RAM
//
//
//	Verilog 1995
//
// ============================================================================

module rtfBitmapController1364x768(
	rst_i, clk_i, bte_o, cti_o, bl_o, cyc_o, stb_o, ack_i, we_o, sel_o, adr_o, dat_i, dat_o,
	vclk, eol, eof, blank, rgbo, page
);
parameter BM_BASE_ADDR1 = 32'h0020_0000;
parameter BM_BASE_ADDR2 = 32'h0040_0000;

// SYSCON
input rst_i;				// system reset
input clk_i;				// system bus interface clock

// Video Master Port
// Used to read memory via burst access
output [1:0] bte_o;
output [2:0] cti_o;
output [5:0] bl_o;
output cyc_o;			// video burst request
output stb_o;
input  ack_i;			// vid_acknowledge from memory
output we_o;
output [ 3:0] sel_o;
output [31:0] adr_o;	// address for memory access
input  [31:0] dat_i;	// memory data input
output [31:0] dat_o;

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
reg [5:0] bl_o;
reg sync_o;
reg cyc_o;
reg stb_o;
reg we_o;
reg [3:0] sel_o;
reg [31:0] adr_o;
reg [31:0] dat_o;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
wire [11:0] hctr;		// horizontal reference counter
wire [11:0] hctr1 = hctr - 12'd434;
wire [11:0] vctr;		// vertical reference counter
wire [11:0] vctr1 = vctr - 12'd27;
reg [31:0] baseAddr;	// base address register
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

counter #(12) u1 (.rst(1'b0), .clk(vclk), .ce(1'b1), .ld(eol), .d(12'h1), .q(hctr));
counter #(12) u2 (.rst(1'b0), .clk(vclk), .ce(eol),  .ld(eof), .d(12'h1), .q(vctr));

// Pixel row and column are derived from the horizontal and vertical counts.

always @(vctr1)
	pixelRow = vctr1[11:0];
always @(hctr1)
	pixelCol = hctr1[11:0];
	

wire vFetch = vctr1 < 12'd768;

// Video Request Block
// 1364x768
// There are 1800 clock available on a scan line. For simplicity we
// use only 1364 of 1366 pixel on the display. 1364 is a multiple
// of four bytes, which is the unit being burst fetched.
// - 1364 =21*64+20 bytes
// 22 burst accesses are required, with the last burst being only for
//  5 data words (20 bytes). This means we have a budget of about 80
// pixel clock cycles per burst. (1800/22) This works out to about 31
// system clocks. The pixel to system clock ratio is about 2.58:1.
// Burst length is set to 16. The burst controller should be able
// to fetch a word (32 bits) every clock cycle, plus some overhead
// for memory latency. The memory clock is much faster than the system
// clock. 
// - 
// - Issue a request for access to memory every 80 clock cycles
// - Reset the request flag once an access has been initiated.
// - 1364 bytes (pixels) are read per scan line
// - It takes about ___ clock cycles @ 33 MHz to access 64 bytes of data
//   through the memory contoller.

reg [5:0] vreq;

// Must be vclk. vid_req will be active for numerous clock cycles as
// a burst type fetch is used. The ftch and vFetch may only be
// active for a single video clock cycle. vclk must be used so these
// signals are not missed due to a clock domain crossing. We luck
// out here because of the length of time vid_req is active.
//
always @(posedge vclk)
begin
	if (vFetch) begin
		if (hctr==12'd16 ) vreq <= 6'b100000;
		if (hctr==12'd96 ) vreq <= 6'b100001;
		if (hctr==12'd176) vreq <= 6'b100010;
		if (hctr==12'd256) vreq <= 6'b100011;
		if (hctr==12'd336) vreq <= 6'b100100;
		if (hctr==12'd416) vreq <= 6'b100101;
		if (hctr==12'd496) vreq <= 6'b100110;
		if (hctr==12'd576) vreq <= 6'b100111;
		if (hctr==12'd656) vreq <= 6'b101000;
		if (hctr==12'd736) vreq <= 6'b101001;
		if (hctr==12'd816) vreq <= 6'b101010;
		if (hctr==12'd896) vreq <= 6'b101011;
		if (hctr==12'd976) vreq <= 6'b101100;
		if (hctr==12'd1056) vreq <= 6'b101101;
		if (hctr==12'd1136) vreq <= 6'b101110;
		if (hctr==12'd1216) vreq <= 6'b101111;
		if (hctr==12'd1296) vreq <= 6'b110000;
		if (hctr==12'd1376) vreq <= 6'b110001;
		if (hctr==12'd1456) vreq <= 6'b110010;
		if (hctr==12'd1536) vreq <= 6'b110011;
		if (hctr==12'd1616) vreq <= 6'b110100;
		if (hctr==12'd1696) vreq <= 6'b110101;
	end
	if (cyc_o) vreq <= 6'b000000;
end
	
// Cross the clock domain with the request signal
reg do_cyc;
always @(posedge clk_i)
	do_cyc <= vreq[5];

wire[23:0] rowOffset = pixelRow * 11'd1364;
reg [11:0] fetchCol;

// - read from assigned video memory address, using burst mode reads
// - 64 pixels at a time are read
// - video data is fetched one pixel row in advance
//
reg [4:0] bcnt;
always @(posedge clk_i)
if (rst_i) begin
	bte_o <= 2'b00;		// linear burst
	cti_o <= 3'b000;	// classic cycle
	bl_o <= 6'd0;
	cyc_o <= 1'b0;
	stb_o <= 1'b0;
	sel_o <= 4'b0000;
	we_o <= 1'b0;
	adr_o <= 32'h0000_0000;
	dat_o <= 32'h0000_0000;
	fetchCol <= 9'd0;
	bcnt <= 4'd0;
end
else begin
	if (do_cyc & !cyc_o) begin
		cti_o <= 3'b010;	// incrementing burst cycle
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'b1111;
		bcnt <= 5'd0;
		bl_o <= vreq==6'b110101 ? 6'd5: 6'd16;
		fetchCol <= {vreq[4:0],6'h00};
		adr_o <= baseAddr + rowOffset + 12'd1364 + {vreq[4:0],6'h00};
	end
	if (cyc_o & ack_i) begin
		fetchCol <= fetchCol + 12'd4;
		bcnt <= bcnt + 5'd1;
		if (bl_o==6'd5 ? bcnt==5'd3 : bcnt==5'd14)
			cti_o <= 3'b111;	// end of burst
		if (bl_o==6'd5 ? bcnt==5'd4 : bcnt==5'd15) begin
			cti_o <= 3'b000;	// classic cycles again
			bl_o <= 6'd0;
			cyc_o <= 1'b0;
			stb_o <= 1'b0;
			sel_o <= 4'b0000;
			adr_o <= 32'h0000_0000;
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
rtfBitmapLineBuffer u3
(
  .clka(clk_i), // input clka
  .ena(cyc_o), // input ena
  .wea(ack_i), // input [0 : 0] wea
  .addra({~pixelRow[0],fetchCol[10:2]}), // input [9 : 0] addra
  .dina(dat_i), // input [31 : 0] dina
 
  .clkb(vclk), // input clkb
  .addrb({pixelRow[0],pixelCol[10:2],~pixelCol[1:0]}), // input [11 : 0] addrb
  .doutb(rgbo1) // output [7 : 0] doutb
);

endmodule
