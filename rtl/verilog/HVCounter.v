// HVCounter.v
// Horizontal / Vertical counter:
//
// horizontal pixel prescale counter
// Each pixel may be multiple clocks wide
//
// 37 slices / 64 LUTs / 161.525 MHz
// 28 ff's / 1 Mult

module HVCounter(
	rst, vclk, pixcce, sync, cnt_offs, pixsz, maxpix, nxt_pix, pos, nxt_pos, ctr
);
input rst;
input vclk;				// video clock
input pixcce;			// pixel counter clock enable
input sync;				// synchronization input (eol or eof)
input [11:0] cnt_offs;	// counter offset: top or left of display area
input [3:0] pixsz;		// size of a pixel in video clock
input [4:0] maxpix;		// maximum pixels for width / height of character
output nxt_pix;			// when the next pixel will happen
output [11:0] pos;		// current row or column position
output nxt_pos;			// flag: when the row or column is about to change
output [11:0] ctr;		// counter output

reg [11:0] pos;
reg [11:0] ctr;
reg nxt_pix;

wire [11:0] ctr1;
wire nxp;
reg [23:0] x4096;

// Lookup reciprocal of number of pixels per character
// - used to calculate the column position
reg [11:0] inv;
always @(posedge vclk)
	case(maxpix)
	5'd00:	inv <= 12'd4095;
	5'd01:	inv <= 12'd2048;
	5'd02:	inv <= 12'd1365;
	5'd03:  inv <= 12'd1024;
	5'd04:	inv <= 12'd0819;
	5'd05:	inv <= 12'd0683;
	5'd06:	inv <= 12'd0585;
	5'd07:	inv <= 12'd0512;
	5'd08:	inv <= 12'd0455;
	5'd09:	inv <= 12'd0409;
	5'd10:	inv <= 12'd0372;
	5'd11:	inv <= 12'd0341;
	5'd12:	inv <= 12'd0315;
	5'd13:	inv <= 12'd0292;
	5'd14:	inv <= 12'd0273;
	5'd15:	inv <= 12'd0256;
	5'd16:	inv <= 12'd0240;
	5'd17:	inv <= 12'd0227;
	5'd18:	inv <= 12'd0215;
	5'd19:	inv <= 12'd0204;
	5'd20:	inv <= 12'd0195;
	5'd21:	inv <= 12'd0186;
	5'd22:	inv <= 12'd0178;
	5'd23:	inv <= 12'd0170;
	5'd24:	inv <= 12'd0163;
	5'd25:	inv <= 12'd0157;
	5'd26:	inv <= 12'd0151;
	5'd27:	inv <= 12'd0146;
	5'd28:	inv <= 12'd0141;
	5'd29:	inv <= 12'd0136;
	5'd30:	inv <= 12'd0132;
	5'd31:	inv <= 12'd0128;
	endcase


// Calculate character position
// - divide the raw count by the number of pixels per character
// - done by multiplying by the reciprocal
always @(posedge vclk)
	x4096 <= ctr * inv;
always @(x4096)
	pos <= x4096[23:12];
always @(posedge vclk)		// pipeline delay
	ctr <= ctr1;
always @(posedge vclk)
	nxt_pix <= nxp;

// Pixel width counter
// Controls number of clock cycles per pixel
VT163 #(4) u1
(
	.clk(vclk),
	.clr_n(!rst),
	.ent(pixcce),
	.enp(1'b1),
	.ld_n(!sync & !nxp),		// synchronize count to start of scan
	.d(4'hF-pixsz),
	.q(),
	.rco(nxp)
);


// Pixel counter
// - raw pixel count
// - just increments every time the nxt_pix signal is active
// - synchronized to the end-of-line or end-of-frame signal
VT163 #(12) u2
(
	.clk(vclk),
	.clr_n(!rst),
	.ent(nxp),
	.enp(1'b1),
	.ld_n(!sync),					// synchronize count to start of scan
	.d(12'h000-cnt_offs),
	.q(ctr1),
	.rco()
);


// Detect when the position changes
// - compare current pos to previous pos when the position might change
change_det #(12) u3
(
	.rst(rst),
	.clk(vclk),
	.ce(nxt_pix),
	.i(pos),
	.cd(nxt_pos)
);

endmodule
