// ============================================================================
//  Keyboard 
//  - Reads keys from PS2 style keyboard
//
//	2010-2011  Robert Finch
//	robfinch<remove>@FPGAfield.ca
//
//
//  This source code is available for evaluation and validation purposes
//  only. This copyright statement and disclaimer must remain present in
//  the file.
//
//
//	NO WARRANTY.
//  THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
//  EXPRESS OR IMPLIED. The user must assume the entire risk of using the
//  Work.
//
//  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
//  INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
//  THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.
//
//  IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
//  IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
//  REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
//  LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
//  AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
//  LOSSES RELATING TO SUCH UNAUTHORIZED USE.
//
//
//	Convert a PS2 keyboard to ascii
//
//	Reg
//	$00		ascii code - bit 15 = strobe
//	$01		access this address clears keyboard strobe
//	
//
//	Verilog 1995
//	Webpack 9.2i  xc3s1200-4fg320
//	64 slices / 118 LUTs / 175.009 MHz
//  72 ff's / 2 BRAM (2048x16)
//
// ============================================================================

// PS2 scan codes
`define SC_LSHIFT	8'h12
`define SC_RSHIFT	8'h59
`define SC_CTRL		8'h14
`define SC_ALT		8'h11
`define SC_DEL		8'h71	// extend
`define SC_LCTRL	8'h58
`define SC_EXTEND	8'hE0
`define SC_KEYUP	8'hF0

module FF_PS2KbdToAscii(rst_i, clk_i, cyc_i, stb_i, ack_o, adr_i, dat_o, kclk, kd, irq, rst_o);
input rst_i;				// reset
input clk_i;				// master clock
input cyc_i;
input stb_i;
output ack_o;				// ready
input [43:0] adr_i;			// address
output [15:0] dat_o;		// data output
inout kclk;				// keyboard clock from keyboard
tri kclk;
inout kd;				// keyboard data
tri kd;
output irq;				// data available
output rst_o;			// reset output CTRL-ALT-DEL was pressed

wire cs = cyc_i && stb_i && (adr_i[43:4]==40'hFFF_FFDC_000);

reg strobe;
wire ps2_irq;
reg ps2_irq1;
reg ps2_cs;
wire [15:0] ps2_o;

// keyboard state
reg keyup;
reg extend;				// extended keycode active
reg shift;				// shift status
reg ctrl;				// control status
reg alt;				// alt status
reg x;

reg [7:0] sc;

assign ack_o = cs;

wire ign;
wire [7:0] xlat_o;
PS2ScanToAscii u1
(
	.shift(shift),
	.ctrl(ctrl),
	.alt(1'b0),
	.sc(sc),
	.extend(x),
	.ascii(xlat_o)
);
assign irq = strobe;
assign dat_o = cs ? {strobe,7'b0,xlat_o} : 16'h0000;


FF_PS2kbd u2
(
	.rst_i(rst_i),
	.clk_i(clk_i),
	.cyc_i(ps2_cs),
	.stb_i(ps2_cs),
	.ack_o(),
	.we_i(1'b0),
	.adr_i(44'hFFF_FFDC_0000),
	.dat_i(16'h0000),
	.dat_o(ps2_o),
	.vol_o(),
	.irq(ps2_irq),
	.kclk(kclk),
	.kd(kd)
);


// This little machine takes care of issuing a read cycle to the ps2 keyboard
// when data is present.
always @(posedge clk_i)
	if (rst_i) begin
		ps2_cs <= 0;
		ps2_irq1 <= 0;
	end
	else begin
		// has an PS2 keyboard event happened ?
		// If so, read the ps2 port
		ps2_irq1 <= ps2_irq;
		if (ps2_irq & ~ps2_irq1)
			ps2_cs <= 1;
		else
			ps2_cs <= 0;
	end


// This machine
// 1) clears the strobe line on an access to the keyboard strobe clear address
// 2) activates the strobe on a keydown event, filtering out special keys
// like control and alt
// 3) captures the state of ctrl,alt and shift and filters these codes out
always @(posedge clk_i)
	if (rst_i) begin
		keyup <= 0;
		extend <= 0;
		shift <= 0;
		ctrl <= 0;
		alt <= 0;
		sc <= 0;
		x <= 1'b0;
		strobe <= 0;
	end
	else begin
		if (cs & adr_i[1])
			strobe <= 0;
		if (ps2_cs) begin
			case (ps2_o[7:0])
			`SC_KEYUP:	keyup <= 1;
			`SC_EXTEND:	extend <= 1;
			default:
				begin
				case(ps2_o[7:0])
				`SC_CTRL:	ctrl <= ~keyup;
				`SC_ALT:	alt <= ~keyup;
				`SC_LSHIFT,
				`SC_RSHIFT:	shift <= ~keyup;
				default:
					begin
					sc <= ps2_o;
					x <= extend;
					strobe <= keyup ? strobe : 1;
					end
				endcase
				keyup <= 0;
				extend <= 0;
				end
			endcase
		end
	end

// CTRL-ALT-DEL
assign rst_o = ps2_o[7:0]==`SC_DEL && alt && ctrl;

endmodule
