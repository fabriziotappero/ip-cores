`timescale 1ns / 1ps
// ============================================================================
//        __
//   \\__/ o\    (C) 2006-2014  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@finitron.ca
//       ||
//
//	rtfTextController3.v
//		text controller
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
//	Text Controller
//
//	FEATURES
//
//	This core requires an external timing generator to provide horizontal
//	and vertical sync signals, but otherwise can be used as a display
//  controller on it's own. However, this core may also be embedded within
//  another core such as a VGA controller.
//
//	Window positions are referenced to the rising edge of the vertical and
//	horizontal sync pulses.
//
//	The core includes an embedded dual port RAM to hold the screen
//	characters.
//
//
//--------------------------------------------------------------------
// Registers
//
//      00 -         nnnnnnnn  number of columns (horizontal displayed number of characters)
//      01 -         nnnnnnnn  number of rows    (vertical displayed number of characters)
//      02 -       n nnnnnnnn  window left       (horizontal sync position - reference for left edge of displayed)
//      03 -       n nnnnnnnn  window top        (vertical sync position - reference for the top edge of displayed)
//      04 -         ---nnnnn  maximum scan line (char ROM max value is 7)
//		05 -         hhhhwwww  pixel size, hhhh=height,wwww=width
//      07 -       n nnnnnnnn  color code for transparent background
//      08 -         -BPnnnnn  cursor start / blink control
//                             BP: 00=no blink
//                             BP: 01=no display
//                             BP: 10=1/16 field rate blink
//                             BP: 11=1/32 field rate blink
//      09 -        ----nnnnn  cursor end
//      10 - aaaaaaaa aaaaaaaaa  start address (index into display memory)
//      11 - aaaaaaaa aaaaaaaaa  cursor position
//      12 - aaaaaaaa aaaaaaaaa  light pen position
//--------------------------------------------------------------------
//
// ============================================================================

module rtfTextController3(
	rst_i, clk_i,
	cyc_i, stb_i, ack_o, we_i, adr_i, dat_i, dat_o,
	lp, curpos,
	vclk, hsync, vsync, blank, border, rgbIn, rgbOut
);
parameter COLS = 12'd56;
parameter ROWS = 12'd31;
parameter pTextAddress = 32'hFFD00000;
parameter pBitmapAddress = 32'hFFD20000;
parameter pRegAddress = 32'hFFDA0000;

// Syscon
input  rst_i;			// reset
input  clk_i;			// clock

// Slave signals
input  cyc_i;			// cycle valid
input  stb_i;			// data strobe
output ack_o;			// transfer acknowledge
input  we_i;			// write
input  [31:0] adr_i;	// address
input  [31:0] dat_i;	// data input
output [31:0] dat_o;	// data output
reg    [31:0] dat_o;

//
input lp;				// light pen
input [15:0] curpos;	// cursor position

// Video signals
input vclk;				// video dot clock
input hsync;			// end of scan line
input vsync;			// end of frame
input blank;			// blanking signal
input border;			// border area
input [24:0] rgbIn;		// input pixel stream
output reg [24:0] rgbOut;	// output pixel stream


reg [23:0] bkColor24;	// background color
reg [23:0] fgColor24;	// foreground color
wire [23:0] tcColor24;	// transparent color

wire pix;				// pixel value from character generator 1=on,0=off

reg [15:0] rego;
reg [11:0] windowTop;
reg [11:0] windowLeft;
reg [11:0] numCols;
reg [11:0] numRows;
reg [11:0] charOutDelay;
reg [ 1:0] mode;
reg [ 4:0] maxScanline;
reg [ 4:0] maxScanpix;
reg [ 4:0] cursorStart, cursorEnd;
reg [15:0] cursorPos;
reg [1:0] cursorType;
reg [15:0] startAddress;
reg [ 2:0] rBlink;
reg [ 3:0] bdrColorReg;
reg [ 3:0] pixelWidth;	// horizontal pixel width in clock cycles
reg [ 3:0] pixelHeight;	// vertical pixel height in scan lines

wire [11:0] hctr;		// horizontal reference counter (counts clocks since hSync)
wire [11:0] scanline;	// scan line
wire [11:0] row;		// vertical reference counter (counts rows since vSync)
wire [11:0] col;		// horizontal column
reg  [ 4:0] rowscan;	// scan line within row
wire nxt_row;			// when to increment the row counter
wire nxt_col;			// when to increment the column counter
wire [ 5:0] bcnt;		// blink timing counter
wire blink;
reg  iblank;

wire nhp;				// next horizontal pixel
wire ld_shft = nxt_col & nhp;


// display and timing signals
reg [15:0] txtAddr;		// index into memory
reg [15:0] penAddr;
wire [8:0] txtOut;		// character code
wire [8:0] charOut;		// character ROM output
wire [8:0] txtBkColor;	// background color code
wire [8:0] txtFgColor;	// foreground color code
reg  [8:0] txtTcCode;	// transparent color code
reg  bgt;

wire [27:0] tdat_o;
wire [8:0] chdat_o;

wire [2:0] scanindex = scanline[2:0];


//--------------------------------------------------------------------
// Address Decoding
// I/O range Dx
//--------------------------------------------------------------------
wire cs_text = cyc_i && stb_i && (adr_i[31:16]==pTextAddress[31:16]);
wire cs_rom  = cyc_i && stb_i && (adr_i[31:16]==pBitmapAddress[31:16]);
wire cs_reg  = cyc_i && stb_i && (adr_i[31: 8]==pRegAddress[31:8]);
wire cs_any = cs_text|cs_rom|cs_reg;

// Register outputs
always @(posedge clk_i)
	if (cs_text) dat_o <= {4'd0,tdat_o};
	else if (cs_rom) dat_o <= {23'd0,chdat_o};
	else if (cs_reg) dat_o <= {16'd0,rego};
	else dat_o <= 32'h0000;

//always @(posedge clk_i)
//	if (cs_text) begin
//		$display("TC WRite: %h %h", adr_i, dat_i);
//		$stop;
//	end

//--------------------------------------------------------------------
// Video Memory
//--------------------------------------------------------------------
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Address Calculation:
//  - Simple: the row times the number of  cols plus the col plus the
//    base screen address
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

wire [17:0] rowcol = row * numCols;
always @(posedge vclk)
	txtAddr <= startAddress + rowcol[15:0] + col;

// text screen RAM
syncRam4kx9_1rw1r textRam0
(
	.wclk(clk_i),
	.wadr(adr_i[13:2]),
	.i(dat_i[8:0]),
	.wo(tdat_o[8:0]),
	.wce(cs_text),
	.we(we_i),
	.wrst(1'b0),

	.rclk(vclk),
	.radr(txtAddr[11:0]),
	.o(txtOut),
	.rce(ld_shft),
	.rrst(1'b0)
);

// screen attribute RAM
syncRam4kx9_1rw1r fgColorRam
(
	.wclk(clk_i),
	.wadr(adr_i[13:2]),
	.i(dat_i[18:10]),
	.wo(tdat_o[18:10]),
	.wce(cs_text),
	.we(we_i),
	.wrst(1'b0),

	.rclk(vclk),
	.radr(txtAddr[11:0]),
	.o(txtFgColor),
	.rce(ld_shft),
	.rrst(1'b0)
);

// screen attribute RAM
syncRam4kx9_1rw1r bkColorRam
(
	.wclk(clk_i),
	.wadr(adr_i[13:2]),
	.i(dat_i[27:19]),
	.wo(tdat_o[27:19]),
	.wce(cs_text),
	.we(we_i),
	.wrst(1'b0),

	.rclk(vclk),
	.radr(txtAddr[11:0]),
	.o(txtBkColor),
	.rce(ld_shft),
	.rrst(1'b0)
);


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Character bitmap ROM
// - room for 512 characters
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
syncRam4kx9_1rw1r charRam0
(
	.wclk(clk_i),
	.wadr(adr_i[13:2]),
	.i(dat_i),
	.wo(chdat_o),
	.wce(cs_rom),
	.we(1'b0),//we_i),
	.wrst(1'b0),

	.rclk(vclk),
	.radr({txtOut,rowscan[2:0]}),
	.o(charOut),
	.rce(ld_shft),
	.rrst(1'b0)
);


// pipeline delay - sync color with character bitmap output
reg [8:0] txtBkCode1;
reg [8:0] txtFgCode1;
always @(posedge vclk)
	if (nhp & ld_shft) txtBkCode1 <= txtBkColor;
always @(posedge vclk)
	if (nhp & ld_shft) txtFgCode1 <= txtFgColor;

//--------------------------------------------------------------------
// bus interfacing
// - there is a two cycle latency for reads, an ack is generated
//   after the synchronous RAM read
// - writes can be acknowledged right away.
//--------------------------------------------------------------------
reg ramRdy,ramRdy1;
always @(posedge clk_i)
begin
	ramRdy1 <= cs_any;
	ramRdy <= ramRdy1 & cs_any;
end

assign ack_o = cs_any ? (we_i ? 1'b1 : ramRdy) : 1'b0;


//--------------------------------------------------------------------
// Registers
//
// RW   00 -         nnnnnnnn  number of columns (horizontal displayed number of characters)
// RW   01 -         nnnnnnnn  number of rows    (vertical displayed number of characters)
//  W   02 -       n nnnnnnnn  window left       (horizontal sync position - reference for left edge of displayed)
//  W   03 -       n nnnnnnnn  window top        (vertical sync position - reference for the top edge of displayed)
//  W   04 -         ---nnnnn  maximum scan line (char ROM max value is 7)
//	W	05 -         hhhhwwww  pixel size, hhhh=height,wwww=width
//  W   07 -       n nnnnnnnn  transparent color
//  W   08 -         -BPnnnnn  cursor start / blink control
//                             BP: 00=no blink
//                             BP: 01=no display
//                             BP: 10=1/16 field rate blink
//                             BP: 11=1/32 field rate blink
//  W   09 -        ----nnnnn  cursor end
//  W   10 - aaaaaaaa aaaaaaaaa  start address (index into display memory)
//  W   11 - aaaaaaaa aaaaaaaaa  cursor position
//  R   12 - aaaaaaaa aaaaaaaaa  light pen position
//--------------------------------------------------------------------

//--------------------------------------------------------------------
// Light Pen
//--------------------------------------------------------------------
wire lpe;
edge_det u1 (.rst(rst_i), .clk(clk_i), .ce(1'b1), .i(lp), .pe(lpe), .ne(), .ee() );

always @(posedge clk_i)
	if (rst_i)
		penAddr <= 32'h0000_0000;
	else begin
		if (lpe)
			penAddr <= txtAddr;
	end


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Register read port
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
always @(cs_reg or cursorPos or penAddr or adr_i or numCols or numRows)
	if (cs_reg) begin
		case(adr_i[5:2])
		4'd0:		rego <= numCols;
		4'd1:		rego <= numRows;
		4'd11:		rego <= cursorPos;
		4'd12:		rego <= penAddr;
		default:	rego <= 16'h0000;
		endcase
	end
	else
		rego <= 16'h0000;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Register write port
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

reg interlace;
always @(posedge clk_i)
	if (rst_i) begin
// 104x63
/*
		windowTop    <= 12'd26;
		windowLeft   <= 12'd260;
		pixelWidth   <= 4'd0;
		pixelHeight  <= 4'd1;		// 525 pixels (408 with border)
*/
// 52x31
/*
		// 84x47
		windowTop    <= 12'd16;
		windowLeft   <= 12'd90;
		pixelWidth   <= 4'd1;		// 681 pixels
		pixelHeight  <= 4'd1;		// 384 pixels
*/
		// 56x31
		windowTop    <= 12'd16;
		windowLeft   <= 12'd56;
		pixelWidth   <= 4'd2;		// 455 pixels
		pixelHeight  <= 4'd2;		// 256 pixels
		numCols      <= COLS;
		numRows      <= ROWS;
		maxScanline  <= 5'd7;
		maxScanpix   <= 5'd7;
		rBlink       <= 3'b111;		// 01 = non display
		startAddress <= 16'h0000;
		cursorStart  <= 5'd00;
		cursorEnd    <= 5'd31;
		cursorPos    <= 16'h0003;
		cursorType 	 <= 2'b00;
		txtTcCode    <= 9'h1ff;
		charOutDelay <= 12'd2;
	end
	else begin
		
		if (cs_reg & we_i) begin	// register write ?

			case(adr_i[5:2])
			4'd00:	begin
					numCols    <= dat_i[15:0];		// horizontal displayed
					charOutDelay <= dat_i[31:16];
					end
			4'd01:	numRows    <= dat_i;
			4'd02:	windowLeft <= dat_i[11:0];
			4'd03:	windowTop  <= dat_i[11:0];		// vertical sync position
			4'd04:	maxScanline <= dat_i[4:0];
			4'd05:	begin
					pixelHeight <= dat_i[7:4];
					pixelWidth  <= dat_i[3:0];	// horizontal pixel width
					end
			4'd07:	txtTcCode   <= dat_i[4:0];
			4'd08:	begin
					cursorStart <= dat_i[4:0];	// scan line sursor starts on
					rBlink      <= dat_i[7:5];
					cursorType  <= dat_i[9:8];
					end
			4'd09:	cursorEnd   <= dat_i[4:0];	// scan line cursor ends on
			4'd10:	startAddress <= dat_i;
			4'd11:	cursorPos <= dat_i;
			endcase
		end
	end


//--------------------------------------------------------------------
//--------------------------------------------------------------------

// "Box" cursor bitmap
reg [7:0] curout;
always @(scanindex or cursorType)
	case({cursorType,scanindex})
	// Box cursor
	5'b00_000:	curout = 8'b11111111;
	5'b00_001:	curout = 8'b10000001;
	5'b00_010:	curout = 8'b10000001;
	5'b00_011:	curout = 8'b10000001;
	5'b00_100:	curout = 8'b10000001;
	5'b00_101:	curout = 8'b10000001;
	5'b00_110:	curout = 8'b10011001;
	5'b00_111:	curout = 8'b11111111;
	// vertical bar cursor
	5'b01_000:	curout = 8'b11000000;
	5'b01_001:	curout = 8'b10000000;
	5'b01_010:	curout = 8'b10000000;
	5'b01_011:	curout = 8'b10000000;
	5'b01_100:	curout = 8'b10000000;
	5'b01_101:	curout = 8'b10000000;
	5'b01_110:	curout = 8'b10000000;
	5'b01_111:	curout = 8'b11000000;
	// underline cursor
	5'b10_000:	curout = 8'b00000000;
	5'b10_001:	curout = 8'b00000000;
	5'b10_010:	curout = 8'b00000000;
	5'b10_011:	curout = 8'b00000000;
	5'b10_100:	curout = 8'b00000000;
	5'b10_101:	curout = 8'b00000000;
	5'b10_110:	curout = 8'b00000000;
	5'b10_111:	curout = 8'b11111111;
	// Asterisk
	5'b11_000:	curout = 8'b00000000;
	5'b11_001:	curout = 8'b00000000;
	5'b11_010:	curout = 8'b00100100;
	5'b11_011:	curout = 8'b00011000;
	5'b11_100:	curout = 8'b01111110;
	5'b11_101:	curout = 8'b00011000;
	5'b11_110:	curout = 8'b00100100;
	5'b11_111:	curout = 8'b00000000;
	endcase


//-------------------------------------------------------------
// Video Stuff
//-------------------------------------------------------------

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

// Horizontal counter:
//
HVCounter uhv1
(
	.rst(rst_i),
	.vclk(vclk),
	.pixcce(1'b1),
	.sync(hsync),
	.cnt_offs(windowLeft),
	.pixsz(pixelWidth),
	.maxpix(maxScanpix),
	.nxt_pix(nhp),
	.pos(col),
	.nxt_pos(nxt_col),
	.ctr(hctr)
);


// Vertical counter:
//
HVCounter uhv2
(
	.rst(rst_i),
	.vclk(vclk),
	.pixcce(pe_hsync),
	.sync(vsync),
	.cnt_offs(windowTop),
	.pixsz(pixelHeight),
	.maxpix(maxScanline),
	.nxt_pix(nvp),
	.pos(row),
	.nxt_pos(nxt_row),
	.ctr(scanline)
);

always @(posedge vclk)
	rowscan <= scanline - row * (maxScanline+1);


// Blink counter
//
VT163 #(6) ub1
(
	.clk(vclk),
	.clr_n(!rst_i),
	.ent(pe_vsync),
	.enp(1'b1),
	.ld_n(1'b1),
	.d(6'd0),
	.q(bcnt),
	.rco()
);

wire blink_en = (cursorPos+2==txtAddr) && (scanline[4:0] >= cursorStart) && (scanline[4:0] <= cursorEnd);

VT151 ub2
(
	.e_n(!blink_en),
	.s(rBlink),
	.i0(1'b1), .i1(1'b0), .i2(bcnt[4]), .i3(bcnt[5]),
	.i4(1'b1), .i5(1'b0), .i6(bcnt[4]), .i7(bcnt[5]),
	.z(blink),
	.z_n()
);

always @(posedge vclk)
	if (nhp & ld_shft)
		bkColor24 <= {txtBkCode1[8:6],5'h10,txtBkCode1[5:3],5'h10,txtBkCode1[2:0],5'h10};
always @(posedge vclk)
	if (nhp & ld_shft)
		fgColor24 <= {txtFgCode1[8:6],5'h10,txtFgCode1[5:3],5'h10,txtFgCode1[2:0],5'h10};

always @(posedge vclk)
	if (nhp & ld_shft)
		bgt <= txtBkCode1==txtTcCode;


// Convert character bitmap to pixels
// For convenience, the character bitmap data in the ROM is in the
// opposite bit order to what's needed for the display. The following
// just alters the order without adding any hardware.
//
wire [7:0] charRev = {
	charOut[0],
	charOut[1],
	charOut[2],
	charOut[3],
	charOut[4],
	charOut[5],
	charOut[6],
	charOut[7]
};

wire [7:0] charout1 = blink ? (charRev ^ curout) : charRev;

// Convert parallel to serial
ParallelToSerial ups1
(
	.rst(rst_i),
	.clk(vclk),
	.ce(nhp),
	.ld(ld_shft),
	.qin(1'b0),
	.d(charout1),
	.qh(pix)
);


// Pipelining Effect:
// - character output is delayed by 2 or 3 character times relative to the video counters
//   depending on the resolution selected
// - this means we must adapt the blanking signal by shifting the blanking window
//   two or three character times.
wire bpix = hctr[1] ^ scanline[4];// ^ blink;
always @(posedge vclk)
	if (nhp)	
		iblank <= (row >= numRows) || (col >= numCols + charOutDelay) || (col < charOutDelay);
	

// Choose between input RGB and controller generated RGB
// Select between foreground and background colours.
always @(posedge vclk)
	if (nhp) begin
		casex({blank,iblank,border,bpix,pix})
		5'b1xxxx:	rgbOut <= 25'h0000000;
		5'b01xxx:	rgbOut <= rgbIn;
		5'b0010x:	rgbOut <= 24'hBF2020;
		5'b0011x:	rgbOut <= 24'hDFDFDF;
		5'b000x0:	rgbOut <= bgt ? rgbIn : bkColor24;
		5'b000x1:	rgbOut <= fgColor24;
		default:	rgbOut <= rgbIn;
		endcase
	end

endmodule

