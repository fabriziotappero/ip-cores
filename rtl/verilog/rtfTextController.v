// ============================================================================
//	(C) 2006-2012  Robert Finch
//	robfinch@<remove>opencores.org
//
//	rtfTextController.v
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
//      07 -         ---nnnnn  color code for transparent background
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

module rtfTextController(
	rst_i, clk_i,
	cyc_i, stb_i, ack_o, we_i, sel_i, adr_i, dat_i, dat_o,
	lp, curpos,
	vclk, eol, eof, blank, border, rgbIn, rgbOut
);
parameter COLS = 12'd56;
parameter ROWS = 12'd31;

// Syscon
input  rst_i;			// reset
input  clk_i;			// clock

// Slave signals
input  cyc_i;			// cycle valid
input  stb_i;			// data strobe
output ack_o;			// transfer acknowledge
input  we_i;			// write
input  [ 1:0] sel_i;	// byte select
input  [63:0] adr_i;	// address
input  [15:0] dat_i;	// data input
output [15:0] dat_o;	// data output
reg    [15:0] dat_o;

//
input lp;				// light pen
input [15:0] curpos;	// cursor position

// Video signals
input vclk;				// video dot clock
input eol;				// end of scan line
input eof;				// end of frame
input blank;			// blanking signal
input border;			// border area
input [24:0] rgbIn;		// input pixel stream
output reg [24:0] rgbOut;	// output pixel stream


wire [23:0] bkColor24;	// background color
wire [23:0] fgColor24;	// foreground color
wire [23:0] tcColor24;	// transparent color

wire pix;				// pixel value from character generator 1=on,0=off

reg [15:0] rego;
reg [11:0] windowTop;
reg [11:0] windowLeft;
reg [11:0] numCols;
reg [11:0] numRows;
reg [ 1:0] mode;
reg [ 4:0] maxScanline;
reg [ 4:0] maxScanpix;
reg [ 4:0] cursorStart, cursorEnd;
reg [15:0] cursorPos;
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
wire [3:0] txtBkCode;	// background color code
wire [4:0] txtFgCode;	// foreground color code
reg  [4:0] txtTcCode;	// transparent color code
reg  bgt;

wire [8:0] tdat_o;
wire [8:0] cdat_o;
wire [8:0] chdat_o;

wire [2:0] scanindex = scanline[2:0];


//--------------------------------------------------------------------
// Address Decoding
// I/O range FFDx
//--------------------------------------------------------------------
wire cs_text = cyc_i && stb_i && (adr_i[63:16]==48'hFFFF_FFFF_FFD0);
wire cs_color= cyc_i && stb_i && (adr_i[63:16]==48'hFFFF_FFFF_FFD1);
wire cs_rom  = cyc_i && stb_i && (adr_i[63:16]==48'hFFFF_FFFF_FFD2);
wire cs_reg  = cyc_i && stb_i && (adr_i[63: 8]==56'hFFFF_FFFF_FFDA_00);
wire cs_any = cs_text|cs_color|cs_rom|cs_reg;

// Register outputs
always @(posedge clk_i)
	if (cs_text) dat_o <= tdat_o;
	else if (cs_color) dat_o <= cdat_o;
	else if (cs_rom) dat_o <= chdat_o;
	else if (cs_reg) dat_o <= rego;
	else dat_o <= 16'h0000;


//--------------------------------------------------------------------
// Video Memory
//--------------------------------------------------------------------
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Address Calculation:
//  - Simple: the row times the number of  cols plus the col plue the
//    base screen address
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

wire [17:0] rowcol = row * numCols;
always @(posedge vclk)
	txtAddr <= startAddress + rowcol + col;

// text screen RAM
syncRam4kx9_1rw1r textRam0
(
	.wclk(clk_i),
	.wadr(adr_i[13:1]),
	.i(dat_i),
	.wo(tdat_o),
	.wce(cs_text),
	.we(we_i),
	.wrst(1'b0),

	.rclk(vclk),
	.radr(txtAddr[12:0]),
	.o(txtOut),
	.rce(ld_shft),
	.rrst(1'b0)
);

// screen attribute RAM
syncRam4kx9_1rw1r colorRam0
(
	.wclk(clk_i),
	.wadr(adr_i[13:1]),
	.i(dat_i),
	.wo(cdat_o),
	.wce(cs_color),
	.we(we_i),
	.wrst(1'b0),

	.rclk(vclk),
	.radr(txtAddr[12:0]),
	.o({txtBkCode,txtFgCode}),
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
	.wadr(adr_i[11:0]),
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
reg [3:0] txtBkCode1;
reg [4:0] txtFgCode1;
always @(posedge vclk)
	if (nhp & ld_shft) txtBkCode1 <= txtBkCode;
always @(posedge vclk)
	if (nhp & ld_shft) txtFgCode1 <= txtFgCode;

//--------------------------------------------------------------------
// bus interfacing
// - there is a two cycle latency for reads, an ack is generated
//   after the synchronous RAM read
// - writes can be acknowledged right away.
//--------------------------------------------------------------------
reg ramRdy,ramRdy1;
always @(posedge clk_i)
begin
	ramRdy1 <= cs_any & !(ramRdy1|ramRdy);
	ramRdy <= ramRdy1 & cs_any;
end

assign ack_o = (cyc_i & stb_i) ? (we_i ? cs_any : ramRdy) : 1'b0;


//--------------------------------------------------------------------
// Registers
//
//      00 -         nnnnnnnn  number of columns (horizontal displayed number of characters)
//      01 -         nnnnnnnn  number of rows    (vertical displayed number of characters)
//      02 -       n nnnnnnnn  window left       (horizontal sync position - reference for left edge of displayed)
//      03 -       n nnnnnnnn  window top        (vertical sync position - reference for the top edge of displayed)
//      04 -         ---nnnnn  maximum scan line (char ROM max value is 7)
//		05 -         hhhhwwww  pixel size, hhhh=height,wwww=width
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
always @(cs_reg or cursorPos or penAddr or adr_i)
	if (cs_reg) begin
		case(adr_i[4:1])
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
		windowTop    <= 12'd12;
		windowLeft   <= 12'd128;
		pixelWidth   <= 4'd2;
		pixelHeight  <= 4'd2;		// 262 pixels (248 with border)

		numCols      <= COLS;
		numRows      <= ROWS;
		maxScanline  <= 5'd7;
		maxScanpix   <= 5'd7;
		rBlink       <= 3'b111;		// 01 = non display
		startAddress <= 16'h0000;
		cursorStart  <= 5'd00;
		cursorEnd    <= 5'd31;
		cursorPos    <= 16'h0003;
		txtTcCode    <= 5'd31;
	end
	else begin
		
		if (cs_reg & we_i) begin	// register write ?

			case(adr_i[4:1])
			4'd00:	numCols    <= dat_i;		// horizontal displayed
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
always @(scanindex)
	case(scanindex)
	3'd0:	curout = 8'b11111111;
	3'd1:	curout = 8'b10000001;
	3'd2:	curout = 8'b10000001;
	3'd3:	curout = 8'b10000001;
	3'd4:	curout = 8'b10000001;
	3'd5:	curout = 8'b10000001;
	3'd6:	curout = 8'b10011001;
	3'd7:	curout = 8'b11111111;
	endcase


//-------------------------------------------------------------
// Video Stuff
//-------------------------------------------------------------

// Horizontal counter:
//

HVCounter uhv1
(
	.rst(rst_i),
	.vclk(vclk),
	.pixcce(1'b1),
	.sync(eol),
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
	.pixcce(eol),
	.sync(eof),
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
	.ent(eol & eof),
	.enp(1'b1),
	.ld_n(1'b1),
	.d(6'd0),
	.q(bcnt)
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

// These tables map a five bit color code to an 24 bit color value.
rtfColorROM ucm1 (.clk(vclk), .ce(nhp & ld_shft), .code(txtBkCode1),  .color(bkColor24) );
rtfColorROM ucm2 (.clk(vclk), .ce(nhp & ld_shft), .code(txtFgCode1),  .color(fgColor24) );
always @(posedge vclk)
	if (nhp & ld_shft)
		bgt <= {1'b0,txtBkCode1}==txtTcCode;


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
// - character output is delayed by 3 character times relative to the video counters.
// - this means we must adapt the blanking signal by shifting the blanking window
//   three character times.
wire bpix = hctr[1] ^ scanline[4];// ^ blink;
always @(posedge vclk)
	if (nhp)	
		iblank <= (row >= numRows) || (col >= numCols + 2) || (col < 2);
	

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

